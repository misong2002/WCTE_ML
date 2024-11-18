#!/bin/bash
########################################################
# 
# Purpose: Script for starting a Jupyter Notebook server
#
# Usage: ./start_jupyternotebook.sh
#
# Reference: https://docs.computecanada.ca/wiki/Jupyter
#
########################################################

# Necessary for Compute Canada systems
unset XDG_RUNTIME_DIR

cd ~

hn=$(hostname -s)
url=$(jupyter notebook list | grep -m1 -Po "(?<=${hn}:)[0-9]+")
pattern="http://${hn}:([0-9]+)[^ ]*"
if /project/def-blairt2k/machine_learning/print_instructions.sh; then
  echo "Jupyter was already running in another job, so ending this job. Instructions above should still work."
else
  echo "Starting jupyter..."
  jupyter notebook --no-browser --ip=$hn 2> >(grep -m1 -q "http" && sleep 10 && /project/def-blairt2k/machine_learning/print_instructions.sh) &
fi
