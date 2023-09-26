# zUMIs Pipline 

## **Step 1** Establish the directory of the project

```{}
mkdir SCMARATOCOV_03
mkdir SCMARATOCOV_03/logs
mkdir SCMARATOCOV_03/outs
mkdir SCMARATOCOV_03/fastq_dir
cd SCMARATOCOV_03
```

## **Step 2** 

Get Lims info

```{}
./scripts/1-lims.sh SCMARATOCOV_03
```

## **Step 3**

Copy FASTQs

```{}
source ~/.bashrc
conda activate sc_py
python scripts/3-copy_lims_files.py lims_info.txt fastq_dir
```

## **Step 4**

Since zUMIs requires the cell identity to be encoded in one of the fastq files, already demultiplexed files can be incompatible eg. in Smart-seq data.

zUMIs provide a way to recombine fastq files and generate an arbitrary index sequence. All you need to provide is the path to the folder containing the individual fastq files that should be combined. Fastq file names are expected in the format of bcl2fastq (XYZ_R1_001.fastq.gz) or SRA's fastq-dump (XYZ_1.fastq.gz). Fastq files are assumed to be gzipped.

### Script 

```{}
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
```

### How to run

```{}
sed -i 's|SCMARATOCOV_02|'"SCMARATOCOV_03"'|g' scripts/4-zumis_remultiplex_preprocessing_cluster.cmd 
sbatch scripts/4-zumis_remultiplex_preprocessing_cluster.cmd 
```

## **STEP 5** Run ZUMIs

### The script

```{}
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
```

### How to run 

```{}
sed -i 's|SCMARATOCOV_02|'"SCMARATOCOV_03"'|g' scripts/5-zumis_main_cluster.cmd
sed -i 's|SCMARATOCOV_02|'"SCMARATOCOV_03"'|g' zUMIs_SMARTseq2_generated.yaml
sbatch --dependency=afterok: "job_ID_of_first_job" scripts/5-zumis_main_cluster.cmd
```

**STEP 6**

Generate seurat object and run some QC

```{}
R -e "rmarkdown::render('generate_seurate_from_zUMIs.Rmd', output_file='generate_seurate_from_zUMIs_SCMARATOCOV_02.html',
                        params = list(subproject = 'SCMARATOCOV_02'))"
R -e "rmarkdown::render('generate_seurate_from_zUMIs.Rmd', output_file='generate_seurate_from_zUMIs_SCMARATOCOV_01.html',
                        params = list(subproject = 'SCMARATOCOV_01'))"
```
