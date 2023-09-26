#!/bin/bash
#SBATCH --job-name=zumis_re-mux   
#SBATCH --output=logs/%x.slurm.%J.out        # define where our output and error from the job will be stored
#SBATCH --error=logs/%x.slurm.%J.err
#SBATCH --time=1:00:00 # set a maximum time that the job will take HH:MM:SS (process will be terminated after this is reached)
#SBATCH --cpus-per-task=10
#SBATCH -q normal
#SBATCH --mem=2G
  

## these are the modules available on the new cluster
module load pigz/2.6-GCCcore-10.3.0; module load HDF5/1.10.7-gompi-2020b; module load R/4.1.2-foss-2021b;

## This is the new path to zumis:
PATH_TO_ZUMIS="/scratch_isilon/groups/singlecell/shared/software/zUMIs"

## new cluster path to pigz
PATH_TO_PIGZ="/software/crgadm/software/pigz/2.6-GCCcore-10.3.0/bin/pigz"
NUM_THREADS=10

PATH_TO_DEMULTIPLEXED_FASTQS="/scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV/SCMARATOCOV_03/fastq_dir/"

Rscript $PATH_TO_ZUMIS/misc/merge_demultiplexed_fastq.R \
--dir $PATH_TO_DEMULTIPLEXED_FASTQS \
--pigz $PATH_TO_PIGZ \
--threads $NUM_THREADS 
