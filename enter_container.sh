###################################################################
#
# Purpose: Start the Singularity container
#
# Usage: ./enter_container.sh [script]
#
#  [script]: Optional argument to run a script instead of enter bash shell
#
# Description of arguments below: 
#
#     --bind: Let the given directory be visible inside container
#             (Note: needs to be absolute path, not symlink)
#
#     --nv: Enable GPU access
#
#     bash: Start a bash shell (instead of jsut executing a command)
#
####################################################################

module load singularity/3.8

SCRIPT_TO_RUN=/bin/bash
if [[ $1 != "" ]]; then
	SCRIPT_TO_RUN=$1
fi

CONTAINER_PATH=/project/def-blairt2k/machine_learning/containers/base_ml_recommended.simg
SCRATCH_DIR=/scratch/${USER}
PROJECT_DIR=/project/def-blairt2k
PROJECT_DIR_TARGET=$(readlink -f /project/def-blairt2k)

echo "running ${SCRIPT_TO_RUN} in ${CONTAINER_PATH}"
singularity exec --nv --bind "${PROJECT_DIR},${PROJECT_DIR_TARGET},${SCRATCH_DIR},${HOME}" ${CONTAINER_PATH} ${SCRIPT_TO_RUN}
