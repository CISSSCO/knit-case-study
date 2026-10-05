#!/bin/bash
#SBATCH --job-name=knit-gromacs-multi
#SBATCH --partition=gpu-debug
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
#SBATCH --time=01:00:00
#SBATCH --signal=B:USR1@60
#SBATCH --gpus-per-node=2
#SBATCH --exclusive
#SBATCH --output=/home/apps/knit/jobs/01a0e679-54a2-7f2a-9ee8-fa7a33f8d4c4/.stdout
#SBATCH --error=/home/apps/knit/jobs/01a0e679-54a2-7f2a-9ee8-fa7a33f8d4c4/.stderr
#SBATCH --mem=180G
export KNIT_JOB_PREFIX=/home/apps/knit/jobs/01a0e679-54a2-7f2a-9ee8-fa7a33f8d4c4
export KNIT_SOURCE_ID=01a0e679-54a2-7f2a-9ee8-fa7a33f8d4c4
export KNIT_SOURCE_COMMAND=submit
export KNIT_SETUP_PREFIX=/home/apps/knit/setups/default
source /home/apps/knit/setups/default/.activate.sh
export _KNIT_PREFIX=/home/apps/knit/.knit
cd /home/apps/knit
export _KNIT_JUMP_TO_DIR=/home/apps/knit/jobs/01a0e679-54a2-7f2a-9ee8-fa7a33f8d4c4
exec /home/apps/knit/gromacs_gpu_exp.sh submit gromacs_multinode
