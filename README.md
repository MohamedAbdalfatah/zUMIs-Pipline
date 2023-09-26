# Deal with permession deined probelm 

## The peroblem

Proudaction team decide to block the new members from access the FASTQ files in proudaction directory 


### zUMIs Pipline 

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
./1-lims.sh SCMARATOCOV_03
```

## **Step 3**

Copy FASTQs

```{}
source ~/.bashrc
conda activate sc_py
python scripts/3-copy_lims_files.py lims_info.txt fastq_dir
```

## **Step 4**


Since I'm using zUMIs to work with smart-seq covid project, I need to copy files and scripts from "/scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV"

This script create the working directory of subproject with all of what you need to work with zUMIs 

```{}
#!/bin/bash

# Get the subproject folder name from the command-line argument
subproject_folder="$1"

# create a subproject folder and the logs subfolder
mkdir "$subproject_folder"
mkdir "$subproject_folder"/logs
mkdir "$subproject_folder"/outs
mkdir "$subproject_folder"/fastq_dir

# Copy the scripts
cp -r SCMARATOCOV_01-updated/scripts/ "$subproject_folder/"

# Go to the new subproject
cd "$subproject_folder"

# copy yaml file
cp ../SCMARATOCOV_01-updated/zUMIs_SMARTseq2_generated.yaml .

# Replace old folder by new folder for path
sed -i 's|SCMARATOCOV_01-updated|'"$subproject_folder"'|g' *yaml
sed -i 's|SCMARATOCOV_01-updated|'"$subproject_folder"'|g' scripts/*

# Change the permissions so that other group members can execute/write/read inside of the newly created directory
cd ..
chmod g+rwX $subproject_folder -R
chmod -R 777 "$subproject_folder"/fastq_dir
```

**RUN THIS SCRIPT**

You should be in "/scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV"

```{}
cd /scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV
./new_prepare_zUMIs.sh SCMARATOCOV_01
```

Since zUMIs requires the cell identity to be encoded in one of the fastq files, already demultiplexed files can be incompatible eg. in Smart-seq data.

zUMIs provide a way to recombine fastq files and generate an arbitrary index sequence. All you need to provide is the path to the folder containing the individual fastq files that should be combined. Fastq file names are expected in the format of bcl2fastq (XYZ_R1_001.fastq.gz) or SRA's fastq-dump (XYZ_1.fastq.gz). Fastq files are assumed to be gzipped.

```{}
sbatch scripts/4-zumis_remultiplex_preprocessing_cluster.cmd 
```

**STEP 4**
```{}
sbatch --dependency=afterok: "job_ID_of_first_job" scripts/5-zumis_main_cluster.cmd
```
**STEP 5**

Generate seurat object and run some QC

```{}
R -e "rmarkdown::render('generate_seurate_from_zUMIs.Rmd', output_file='generate_seurate_from_zUMIs_SCMARATOCOV_02.html',
                        params = list(subproject = 'SCMARATOCOV_02'))"
R -e "rmarkdown::render('generate_seurate_from_zUMIs.Rmd', output_file='generate_seurate_from_zUMIs_SCMARATOCOV_01.html',
                        params = list(subproject = 'SCMARATOCOV_01'))"
```
