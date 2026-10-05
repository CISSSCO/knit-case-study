# 1. Hello World with SLURM

    ./hello.sh submit \
        --name hello-slurm \
        --job-name knit-hello \
        --queue debug \
        --nodes 1 \
        --walltime 00:10:00 \
        -- hello


# 2. GROMACS


## Single Node

    ./experiment_gromacs.sh submit \
        --name gromacs-test \
        --job-name knit-gromacs \
        --queue debug \
        --nodes 1 \
        --walltime 01:00:00 \
        -- gromacs-test


## Multi Node

    ./experiment_gromacs.sh submit \
        --name gromacs-multinode \
        --job-name knit-gromacs-multi \
        --queue debug \
        --nodes 4 \
        --walltime 01:00:00 \
        -- gromacs-multinode


# 3. LAMMPS


## Single Node

    ./lammps_cpu_exp.sh submit \
        --name lammps-test \
        --job-name knit-lammps \
        --queue debug \
        --nodes 1 \
        --walltime 01:00:00 \
        -- lammps-test


## Multi Node

    ./lammps_cpu_exp.sh submit \
        --name lammps-multinode \
        --job-name knit-lammps-multi \
        --queue debug \
        --nodes 4 \
        --walltime 01:00:00 \
        -- lammps-multinode


# 4. Check Experiment Output

Knit stores each submitted experiment under:

    jobs/<job-id>/


## Standard Output

    cat jobs/<job-id>/.stdout


## Standard Error

    cat jobs/<job-id>/.stderr


## Follow Output

    tail -f jobs/<job-id>/.stdout


