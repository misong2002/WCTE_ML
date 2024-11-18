#!/bin/bash
#SBATCH --account=def-blairt2k
#SBATCH --time=1-0:00:00
#SBATCH --mem=100G
#SBATCH --output=%x.%A.out
#SBATCH --error=%x.%A.err
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:4

# Run WatChMaL in singularity after copying large files/directories to node's local disk
# usage: run_watchmal_jobs.sh [-t] -i singularity_image -c path_to_copy [-c another_path_to_copy] -w watchmal_directory -- watchmal_command [watchmal command options]
# -t                          Run in test mode (don’t copy files, run watchmal command with “-c job” option to print out the full config without actually running)
# -i singularity_image        Location of the singularity image to use
# -c path_to_copy             Copy file to node’s local storage for faster training
# -w watchmal_directory       Location of WatChMaL repository
# -- watchmal_command [opt]   Full command to run inside singularity is anything that comes after --

module load apptainer


PATHS_TO_COPY=()
while [ $# -gt 0 ]; do
  case "$1" in
    -t)
      TEST=true
      ;;
    -i)
      shift
      SINGULARITY_FILE="$1"
      ;;
    -w)
      shift
      WATCHMAL_DIR="$1"
      ;;
    -c)
      shift
      PATHS_TO_COPY+=("$1")
      ;;
    --)
      shift
      break
      ;;
  esac
  shift
done

if [ -z $WATCHMAL_DIR ]; then
  echo "WatChMaL directory not provided. Use -w option."
  exit 1;
fi

echo "entering directory $WATCHMAL_DIR"
cd "$WATCHMAL_DIR"

if [ -z $SINGULARITY_FILE ]; then
  echo "Singularity image file not provided. Use -i option."
  exit 1;
fi

export APPTAINER_BIND="/project,/scratch,/home/$USER"

if [ -z "$TEST" ]; then
  if [ -n "$SLURM_TMPDIR" ]; then
    for PATH_TO_COPY in "${PATHS_TO_COPY[@]}"; do
      echo "copying $PATH_TO_COPY to $SLURM_TMPDIR"
      rsync -ahvPR "$PATH_TO_COPY" "$SLURM_TMPDIR"
      export APPTAINER_BIND="${APPTAINER_BIND},${SLURM_TMPDIR}/${PATH_TO_COPY##*/./}:${PATH_TO_COPY}"
    done
    SINGULARITY_FILE_MOVED="$SLURM_TMPDIR/${SINGULARITY_FILE##*/}"
    echo "copying singularity file from $SINGULARITY_FILE to $SINGULARITY_FILE_MOVED"
    rsync -ahvP "$SINGULARITY_FILE" "$SINGULARITY_FILE_MOVED"
  else
    SINGULARITY_FILE_MOVED="$SINGULARITY_FILE"
  fi
  echo "running command:"
  echo "  $@"
  echo "inside $SINGULARITY_FILE_MOVED"
  echo "with binds: $APPTAINER_BIND"
  echo ""
  singularity exec --env PYTHONUNBUFFERED=1 --nv "$SINGULARITY_FILE_MOVED" $@
else
  for PATH_TO_COPY in "${PATHS_TO_COPY[@]}"; do
    echo "skipping copying $PATH_TO_COPY to $SLURM_TMPDIR"
  done
  echo "running command:"
  echo "  $@ -c job"
  echo "inside $SINGULARITY_FILE"
  echo ""
  singularity exec --env PYTHONUNBUFFERED=1 "$SINGULARITY_FILE" $@ -c job
fi

