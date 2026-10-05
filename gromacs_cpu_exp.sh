#!/bin/bash

source /home/apps/softwares/knit/knit.sh

knit_set_program_description \
    "PARAM Rudra 20 PF GROMACS MPI experiment using Intel MPI mpirun."


# ============================================================
# CONFIGURATION
# ============================================================

# Real experiment directory.
#
# Knit changes the working directory to:
#
#   jobs/<job-id>/
#
# Therefore use an absolute path for the application directory.

EXPERIMENT_DIR="/home/apps/knit/water-cut1.0_GMX50_bare/3072"

# Load GROMACS environment
source "/home/apps/knit/loadGromacs.sh"

# GROMACS MPI executable
GMX_EXECUTABLE="/home/apps/spack/opt/spack/linux-cascadelake/gromacs-2026.1-pvlg3o7p2vjfv6v6rfwnk6pvbsnsr2n4/bin/gmx_mpi"


# ============================================================
# MPI ENVIRONMENT
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
    echo "Intel MPI bootstrap:"
    export I_MPI_HYDRA_BOOTSTRAP=slurm
    echo "I_MPI_HYDRA_BOOTSTRAP=${I_MPI_HYDRA_BOOTSTRAP}"

    echo
    echo "Intel MPI fabric:"
    export I_MPI_FABRICS=shm:ofi
    echo "I_MPI_FABRICS=${I_MPI_FABRICS}"

    echo
    echo "GROMACS:"
    "${GMX_EXECUTABLE}" --version
}


# ============================================================
# EXECUTABLE CHECK
# ============================================================

check_executable()
{
    echo
    echo "EXECUTABLE CHECK"
    echo "----------------------------------------"

    echo "GROMACS executable:"
    echo "${GMX_EXECUTABLE}"

    if [[ ! -f "${GMX_EXECUTABLE}" ]]; then
        echo
        echo "ERROR: GROMACS executable does not exist:"
        echo "${GMX_EXECUTABLE}"
        return 1
    fi

    if [[ ! -x "${GMX_EXECUTABLE}" ]]; then
        echo
        echo "ERROR: GROMACS executable is not executable:"
        echo "${GMX_EXECUTABLE}"
        return 1
    fi

    ls -lh "${GMX_EXECUTABLE}"

    echo
    file "${GMX_EXECUTABLE}"

    return 0
}


# ============================================================
# SINGLE NODE GROMACS
# ============================================================

@job "gromacs-test" "Run GROMACS PME benchmark on one Rudra node."

gromacs_test()
{
    echo "========================================"
    echo "       KNIT GROMACS - SINGLE NODE"
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
    echo "GROMACS EXPERIMENT DIRECTORY"
    echo "----------------------------------------"

    echo "${EXPERIMENT_DIR}"

    if [[ ! -d "${EXPERIMENT_DIR}" ]]; then
        echo "ERROR: Experiment directory does not exist:"
        echo "${EXPERIMENT_DIR}"
        return 1
    fi

    cd "${EXPERIMENT_DIR}" || return 1

    echo
    echo "INPUT FILES"
    echo "----------------------------------------"

    ls -lh pme.mdp conf.gro topol.top

    echo
    echo "========================================"
    echo "GENERATING GROMACS INPUT"
    echo "========================================"

    "${GMX_EXECUTABLE}" grompp \
        -f pme.mdp \
        -c conf.gro \
        -p topol.top \
        -o water_pme.tpr

    GROMPP_RC=$?

    if [[ ${GROMPP_RC} -ne 0 ]]; then
        echo
        echo "ERROR: grompp failed."
        return ${GROMPP_RC}
    fi

    echo
    echo "========================================"
    echo "RUNNING GROMACS"
    echo "========================================"

    START_TIME=$(date +%s)

    mpirun \
        -np 48 \
        "${GMX_EXECUTABLE}" \
        mdrun \
        -nsteps 5000 \
        -s water_pme.tpr

    MPI_RC=$?

    END_TIME=$(date +%s)
    WALL_TIME=$((END_TIME - START_TIME))

    echo
    echo "========================================"
    echo "GROMACS RUN FINISHED"
    echo "========================================"

    echo "Exit code     : ${MPI_RC}"
    echo "Wall time     : ${WALL_TIME} seconds"

    return "${MPI_RC}"
}

@done


# ============================================================
# MULTI-NODE GROMACS
# ============================================================

@job "gromacs-multinode" "Run GROMACS PME benchmark across multiple Rudra nodes."

gromacs_multinode()
{
    echo "========================================"
    echo "       KNIT GROMACS - MULTI NODE"
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
    echo "GROMACS EXPERIMENT DIRECTORY"
    echo "----------------------------------------"

    echo "${EXPERIMENT_DIR}"

    cd "${EXPERIMENT_DIR}" || return 1

    echo
    echo "INPUT FILES"
    echo "----------------------------------------"

    ls -lh pme.mdp conf.gro topol.top

    echo
    echo "========================================"
    echo "GENERATING GROMACS INPUT"
    echo "========================================"

    "${GMX_EXECUTABLE}" grompp \
        -f pme.mdp \
        -c conf.gro \
        -p topol.top \
        -o water_pme.tpr

    GROMPP_RC=$?

    if [[ ${GROMPP_RC} -ne 0 ]]; then
        echo
        echo "ERROR: grompp failed."
        return ${GROMPP_RC}
    fi

    echo
    echo "========================================"
    echo "RUNNING MULTI-NODE GROMACS"
    echo "========================================"

    echo "MPI ranks     : ${SLURM_NTASKS}"
    echo "Nodes         : ${SLURM_JOB_NUM_NODES}"
    echo "Ranks/node    : ${SLURM_NTASKS_PER_NODE:-not-set}"

    START_TIME=$(date +%s)

    mpirun \
        -np "${SLURM_NTASKS}" \
        "${GMX_EXECUTABLE}" \
        mdrun \
        -nsteps 5000 \
        -s water_pme.tpr

    MPI_RC=$?

    END_TIME=$(date +%s)
    WALL_TIME=$((END_TIME - START_TIME))

    echo
    echo "========================================"
    echo "MULTI-NODE GROMACS FINISHED"
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

