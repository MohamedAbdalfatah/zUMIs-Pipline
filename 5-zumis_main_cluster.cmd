#!/bin/bash
#SBATCH --job-name=zumis_main    
#SBATCH --output=logs/%x.slurm.%J.out        # define where our output and error from the job will be stored
#SBATCH --error=logs/%x.slurm.%J.err
#SBATCH --time=10:00:00 # set a maximum time that the job will take HH:MM:SS (process will be terminated after this is reached)
#SBATCH --cpus-per-task=20
#SBATCH --mem=120G
#SBATCH -q normal

## these are the modules available on the new cluster
module load pigz/2.6-GCCcore-10.3.0; module load HDF5/1.10.7-gompi-2020b; module load R/4.1.2-foss-2021b;

## This is the new path to zumis:
PATH_TO_ZUMIS="/scratch_isilon/groups/singlecell/shared/software/zUMIs"

PATH_TO_YAML="/scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV/SCMARATOCOV_03/zUMIs_SMARTseq2_generated.yaml"

$PATH_TO_ZUMIS/zUMIs.sh -c -y $PATH_TO_YAML


