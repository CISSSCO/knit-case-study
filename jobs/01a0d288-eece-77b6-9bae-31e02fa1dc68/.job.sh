#!/bin/bash
#SBATCH --job-name=knit-lammps-multi
#SBATCH --partition=debug
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=48
#SBATCH --time=01:00:00
#SBATCH --signal=B:USR1@60
#SBATCH --exclusive
#SBATCH --output=/home/apps/knit/jobs/01a0d288-eece-77b6-9bae-31e02fa1dc68/.stdout
#SBATCH --error=/home/apps/knit/jobs/01a0d288-eece-77b6-9bae-31e02fa1dc68/.stderr
#SBATCH --mem=180G
export KNIT_JOB_PREFIX=/home/apps/knit/jobs/01a0d288-eece-77b6-9bae-31e02fa1dc68
export KNIT_SOURCE_ID=01a0d288-eece-77b6-9bae-31e02fa1dc68
export KNIT_SOURCE_COMMAND=submit
export KNIT_SETUP_PREFIX=/home/apps/knit/setups/default
source /home/apps/knit/setups/default/.activate.sh
export _KNIT_PREFIX=/home/apps/knit/.knit
cd /home/apps/knit
export _KNIT_JUMP_TO_DIR=/home/apps/knit/jobs/01a0d288-eece-77b6-9bae-31e02fa1dc68
exec /home/apps/knit/lammps_cpu_exp.sh submit lammps_multinode
