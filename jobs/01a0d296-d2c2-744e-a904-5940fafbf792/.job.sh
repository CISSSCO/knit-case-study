#!/bin/bash
#SBATCH --job-name=knit-hello
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
#SBATCH --time=00:10:00
#SBATCH --signal=B:USR1@60
#SBATCH --exclusive
#SBATCH --output=/home/apps/knit/jobs/01a0d296-d2c2-744e-a904-5940fafbf792/.stdout
#SBATCH --error=/home/apps/knit/jobs/01a0d296-d2c2-744e-a904-5940fafbf792/.stderr
#SBATCH --mem=180G
export KNIT_JOB_PREFIX=/home/apps/knit/jobs/01a0d296-d2c2-744e-a904-5940fafbf792
export KNIT_SOURCE_ID=01a0d296-d2c2-744e-a904-5940fafbf792
export KNIT_SOURCE_COMMAND=submit
export KNIT_SETUP_PREFIX=/home/apps/knit/setups/default
source /home/apps/knit/setups/default/.activate.sh
export _KNIT_PREFIX=/home/apps/knit/.knit
cd /home/apps/knit
export _KNIT_JUMP_TO_DIR=/home/apps/knit/jobs/01a0d296-d2c2-744e-a904-5940fafbf792
exec /home/apps/knit/hello.sh submit hello
