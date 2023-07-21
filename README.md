# Deal with permession deined probelm 

## The peroblem

Proudaction team decide to block the new members from access the FASTQ files in proudaction directory 

## Sloutions

### zUMIs Pipline 

**Step 1** Establish the directory of the project

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

**STEP 2** Copy the FASTQ Files

We wrote a script to copy files from production to any directory we need

The input of the script is two argument 1- the subproject and 2- the target directory which is the directory you need to copy the file to it

How it is work?

It is generate the lims info and then generate the fastq path, after that the script copy each fastq to the target directory

Notes:

The person will run this script:
- You Should have access to copy the fastq files from production (I asked about this in Friday meeting and most of you have it)
- You should be in /scratch_isilon/groups/singlecell/shared/projects/copy_files  where is the scripts in
- You should have pandas in your environment since 2-write_fastq_paths.py need it

The person will request to run this script

- You should create the target directory where is the files will copy to
- You should give all of group member permission to write in this directory

**copy_fastqs.sh** script to copy the file

You can find it in /scratch_isilon/groups/singlecell/shared/projects/copy_files/copy_fastqs.sh

```{}
#!/bin/bash

# Step 1: Execute the 1-lims.sh script and save the output to lims_info.txt
sh /scratch_isilon/groups/singlecell/shared/projects/copy_files/scripts/1-lims.sh "$1"

# Step 2: Activate the desired conda environment
source /scratch/groups/hheyn/software/anaconda3/bin/activate cellranger

# Step 2: Run the 2-write_fastq_paths.py script and generate the fastq_paths.tab file
python /scratch_isilon/groups/singlecell/shared/projects/copy_files/scripts/2-write_fastq_paths.py --info_file lims_${1}.txt --subproject "$1"

# Step 3: Specify the target directory where you want to copy the files
[ -w "$2" ] && echo "You have permission to target directory" || echo "You do not have permission to target directory"
target_directory="$2"

# Step 4: Check if fastq_paths.tab file exists and copy the files
if [ -f "./fastq_paths.tab" ]; then
    while IFS=$'\t' read -r -a fields; do
        # Extract the path from the second column (index 1)
        path=${fields[1]}

        # Copy the file to the target directory using rsync
        rsync -avL "$path" "$target_directory"
    done < "./fastq_paths.tab"
else
    echo "fastq_paths.tab file not found."
fi

# Step 5: Change permissions of the target directory
chmod g+rwx "$2"

# Step 6: Deactivate conda env
source /scratch/groups/hheyn/software/anaconda3/bin/deactivate
```

Let's Test? :partying_face::boom:

```{}
cd /scratch_isilon/groups/singlecell/shared/projects/copy_files
./copy_fastqs.sh SCMARATOCOV_02 /scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV/SCMARATOCOV_02/fastq_dir
```

**No NEED**
Also, I wrote a script to know what is the total size of fastq files you will copy them to estimate the number of cores and mem you need to use in your job

You can use it like this:
```{}
./calculate_size.sh SCMARATOCOV_02
```
**STEP 3**
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
