#!/bin/bash

source /home/apps/softwares/knit/knit.sh

knit_set_program_description \
    "PARAM Rudra 20 PF LAMMPS MPI experiment using OpenMPI."


# ============================================================
# CONFIGURATION
# ============================================================

# IMPORTANT:
#
# Knit changes the working directory to:
#
#   jobs/<job-id>/
#
# Therefore NEVER construct paths using $PWD.
#
# Always use the real experiment directory.

EXPERIMENT_DIR="/home/apps/knit/"

# Load LAMMPS / MPI environment
source "/home/apps/knit/loadLammps.sh"

# LAMMPS MPI executable
LAMMPS_EXECUTABLE="/home/apps/spack/opt/spack/linux-cascadelake/lammps-20250722.3-4dwl4bkyshwzbrou5ylumnf5mmu7dl3t/bin/lmp"


# ============================================================
# COMMON MPI ENVIRONMENT
# ============================================================

setup_mpi_environment()
{
    echo
    echo "MPI ENVIRONMENT"
    echo "----------------------------------------"

    echo "MPI launcher:"
    which mpirun || true

    echo
    echo "MPI version:"
    mpirun --version 2>&1 | head -n 5 || true

    echo
    echo "MPI environment:"
    env | grep -E \
        '^(OMPI|PMI|PMIX|SLURM)' \
        | sort \
        || true

    echo
    echo "LAMMPS:"
    "${LAMMPS_EXECUTABLE}" -h 2>&1 | head -n 10 || true
}


# ============================================================
# EXECUTABLE CHECK
# ============================================================

check_executable()
{
    echo
    echo "EXECUTABLE CHECK"
    echo "----------------------------------------"

    echo "LAMMPS executable:"
    echo "${LAMMPS_EXECUTABLE}"

    if [[ ! -f "${LAMMPS_EXECUTABLE}" ]]; then
        echo
        echo "ERROR: LAMMPS executable does not exist:"
        echo "${LAMMPS_EXECUTABLE}"
        return 1
    fi

    if [[ ! -x "${LAMMPS_EXECUTABLE}" ]]; then
        echo
        echo "ERROR: LAMMPS executable is not executable:"
        echo "${LAMMPS_EXECUTABLE}"
        return 1
    fi

    ls -lh "${LAMMPS_EXECUTABLE}"

    echo
    file "${LAMMPS_EXECUTABLE}"

    return 0
}


# ============================================================
# SINGLE NODE LAMMPS
# ============================================================

@job "lammps-test" "Run LAMMPS using mpirun on one Rudra node."

lammps_test()
{
    echo "========================================"
    echo "       KNIT LAMMPS - SINGLE NODE"
    echo "========================================"

    echo
    echo "SLURM ALLOCATION"
    echo "----------------------------------------"

    echo "Job ID        : ${SLURM_JOB_ID:-not-set}"
    echo "Job Name      : ${SLURM_JOB_NAME:-not-set}"
    echo "Partition     : ${SLURM_JOB_PARTITION:-not-set}"
    echo "Nodes         : ${SLURM_JOB_NUM_NODES:-not-set}"
    echo "NodeList      : ${SLURM_JOB_NODELIST:-not-set}"
    echo "Tasks         : ${SLURM_NTASKS:-not-set}"
    echo "Tasks/node    : ${SLURM_NTASKS_PER_NODE:-not-set}"
    echo "CPUs/node     : ${SLURM_CPUS_ON_NODE:-not-set}"

    echo
    echo "ALLOCATED HOSTS"
    echo "----------------------------------------"

    scontrol show hostnames "${SLURM_JOB_NODELIST}"

    check_executable || return 1

    setup_mpi_environment

    echo
    echo "LAMMPS EXPERIMENT DIRECTORY"
    echo "----------------------------------------"

    echo "${EXPERIMENT_DIR}"

    if [[ ! -d "${EXPERIMENT_DIR}" ]]; then
        echo "ERROR: Experiment directory does not exist:"
        echo "${EXPERIMENT_DIR}"
        return 1
    fi

    cd "${EXPERIMENT_DIR}" || return 1

    echo
    echo "INPUT FILE"
    echo "----------------------------------------"

    if [[ ! -f "in.lj.txt" ]]; then
        echo "ERROR: LAMMPS input file does not exist:"
        echo "${EXPERIMENT_DIR}/in.lj.txt"
        return 1
    fi

    ls -lh in.lj.txt

    echo
    echo "========================================"
    echo "RUNNING LAMMPS"
    echo "========================================"

    echo "MPI ranks     : 8"
    echo "Input file    : in.lj.txt"

    START_TIME=$(date +%s)

    mpirun \
        -np 8 \
        "${LAMMPS_EXECUTABLE}" \
        -in in.lj.txt

    MPI_RC=$?

    END_TIME=$(date +%s)
    WALL_TIME=$((END_TIME - START_TIME))

    echo
    echo "========================================"
    echo "LAMMPS RUN FINISHED"
    echo "========================================"

    echo "Exit code     : ${MPI_RC}"
    echo "Wall time     : ${WALL_TIME} seconds"

    return "${MPI_RC}"
}

@done


# ============================================================
# MULTI-NODE LAMMPS
# ============================================================

@job "lammps-multinode" "Run LAMMPS across multiple Rudra nodes using OpenMPI mpirun."

lammps_multinode()
{
    echo "========================================"
    echo "       KNIT LAMMPS - MULTI NODE"
    echo "========================================"

    echo
    echo "SLURM ALLOCATION"
    echo "----------------------------------------"

    echo "Job ID        : ${SLURM_JOB_ID:-not-set}"
    echo "Job Name      : ${SLURM_JOB_NAME:-not-set}"
    echo "Partition     : ${SLURM_JOB_PARTITION:-not-set}"
    echo "Nodes         : ${SLURM_JOB_NUM_NODES:-not-set}"
    echo "NodeList      : ${SLURM_JOB_NODELIST:-not-set}"
    echo "Tasks         : ${SLURM_NTASKS:-not-set}"
    echo "Tasks/node    : ${SLURM_NTASKS_PER_NODE:-not-set}"
    echo "CPUs/node     : ${SLURM_CPUS_ON_NODE:-not-set}"

    echo
    echo "ALLOCATED HOSTS"
    echo "----------------------------------------"

    scontrol show hostnames "${SLURM_JOB_NODELIST}"

    check_executable || return 1

    setup_mpi_environment

    echo
    echo "LAMMPS EXPERIMENT DIRECTORY"
    echo "----------------------------------------"

    echo "${EXPERIMENT_DIR}"

    cd "${EXPERIMENT_DIR}" || return 1

    echo
    echo "INPUT FILE"
    echo "----------------------------------------"

    if [[ ! -f "in.lj.txt" ]]; then
        echo "ERROR: LAMMPS input file does not exist:"
        echo "${EXPERIMENT_DIR}/in.lj.txt"
        return 1
    fi

    ls -lh in.lj.txt

    echo
    echo "LAMMPS APPLICATION"
    echo "----------------------------------------"

    echo "Application   : LAMMPS"
    echo "Executable    : ${LAMMPS_EXECUTABLE}"
    echo "MPI launcher  : mpirun"
    echo "MPI ranks     : ${SLURM_NTASKS}"
    echo "Nodes         : ${SLURM_JOB_NUM_NODES}"
    echo "Ranks/node    : ${SLURM_NTASKS_PER_NODE:-not-set}"
    echo "Input file    : in.lj.txt"

    echo
    echo "MPI HOST LIST"
    echo "----------------------------------------"

    HOSTS=$(scontrol show hostnames "${SLURM_JOB_NODELIST}")

    echo "${HOSTS}"

    echo
    echo "MPI RANK DISTRIBUTION"
    echo "----------------------------------------"

    echo "Expected:"
    echo "${SLURM_NTASKS} MPI ranks"
    echo "${SLURM_NTASKS_PER_NODE:-unknown} ranks per node"

    echo
    echo "========================================"
    echo "RUNNING MULTI-NODE LAMMPS"
    echo "========================================"

    START_TIME=$(date +%s)

    mpirun \
        -np "${SLURM_NTASKS}" \
        "${LAMMPS_EXECUTABLE}" \
        -in in.lj.txt

    MPI_RC=$?

    END_TIME=$(date +%s)
    WALL_TIME=$((END_TIME - START_TIME))

    echo
    echo "========================================"
    echo "MULTI-NODE LAMMPS FINISHED"
    echo "========================================"

    echo "Exit code     : ${MPI_RC}"
    echo "Wall time     : ${WALL_TIME} seconds"

    return "${MPI_RC}"
}

@done


# ============================================================
# KNIT CLI
# ============================================================

knit "$@"
