#!/bin/bash

source /home/apps/softwares/knit/knit.sh

knit_set_program_description \
    "PARAM Rudra 20 PF HPC experiment."

@job "hello" "Run a basic Slurm test on PARAM Rudra."
hello() {
    echo "========================================"
    echo "       KNIT / PARAM RUDRA TEST"
    echo "========================================"

    echo "Hostname : $(hostname)"
    echo "Date     : $(date)"

    echo
    echo "SLURM"
    echo "----------------------------------------"
    echo "Job ID       : ${SLURM_JOB_ID:-not-set}"
    echo "Job Name     : ${SLURM_JOB_NAME:-not-set}"
    echo "Partition    : ${SLURM_JOB_PARTITION:-not-set}"
    echo "Nodes        : ${SLURM_JOB_NUM_NODES:-not-set}"
    echo "NodeList     : ${SLURM_JOB_NODELIST:-not-set}"
    echo "Tasks        : ${SLURM_NTASKS:-not-set}"
    echo "CPUs/node    : ${SLURM_CPUS_ON_NODE:-not-set}"

    echo
    echo "ALLOCATED HOSTS"
    echo "----------------------------------------"

    scontrol show hostnames "${SLURM_JOB_NODELIST}"
}

@done

knit "$@"

