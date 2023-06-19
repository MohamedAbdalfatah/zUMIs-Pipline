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
./scripts/1-lims.sh "$1"

# Step 2: Run the 2-write_fastq_paths.py script and generate the fastq_paths.tab file
python scripts/2-write_fastq_paths.py --info_file lims_${1}.txt --subproject "$1"

# Step 3: Specify the target directory where you want to copy the files
[ -w "$2" ] && echo "You have permission to target directory" || echo "You do not have permission to target directory"
target_directory="$2"

# Step 4: Check if fastq_paths.tab file exists and copy the files
if [ -f "./fastq_paths.tab" ]; then
    while IFS=$'\t' read -r -a fields; do
        # Extract the path from the second column (index 1)
        path=${fields[1]}

        # Copy the file to the target directory
        cp "$path" "$target_directory"
    done < "./fastq_paths.tab"
else
    echo "fastq_paths.tab file not found."
fi

chmod -R 440 "$2"
chmod -R g+rwx .
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

### Cell-Ranger Pipline 

Here we will use scMapper pipline 

```{r}
mkdir subproject
cd subproject
mkdir data
echo subprojects > data/subproject_list.txt
```

**STEP 1** 

Very important, you need to spacify the "-lims_path /scratch/groups/singlecell/software/limsq"

```{r}
module load Python/2.7.18-GCCcore-11.2.0
python 1-lims_info_file_downloader.py -input_subproject_id_list_file ../data/subproject_list.txt -output_dir ../data/ -lims_path /scratch/groups/singlecell/software/limsq
module unload Python/2.7.18-GCCcore-11.2.0
```

**STEP 2**

```{r}
module load Python/3.8.6-GCCcore-10.2.0
python3 2-lims_info_to_metadata.py -input_lims_info_file ../data/all_subproject_raw_lims_info.tsv -output_metadata_file ../data/metadata.tsv
```

**STEP 3** (Some one will do it for you)

Here we will ask for a help from some one to copy the files of fastq to "/scratch_isilon/groups/singlecell/shared/projects/copy_files/fastq_dir" this directory I will use it instead of proudaction directory (since we don't have access to it), it will contain all of FASTQ related to cellranger for all of the projects and I will have permession to them.

```{}
cd /scratch_isilon/groups/singlecell/shared/projects/copy_files
./copy_fastqs.sh subproject /scratch_isilon/groups/singlecell/shared/projects/copy_files/fastq_dir
```

**STEP 4**

Very Important to specify -fastq_dir /scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV/SCMARATOCOV_02/fastq_dir where is you copied the fastq files to.

```{}
module load Python/3.8.6-GCCcore-10.2.0
python3 3-write_fastq_path.py -input_lims_info_file ../data/all_subproject_raw_lims_info.tsv -input_metadata_file ../data/metadata.tsv -out_dir ../data/ -fastq_dir /scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV/SCMARATOCOV_02/fastq_dir
```

**STEP 5**

```{}
module load Python/3.8.6-GCCcore-10.2.0
python3 4-cellranger_jobscript_creator.py -input_fastq_path_file ../data/fastq_path.csv -input_working_directory ../ -cluster_mode new -cellranger_version v6_1_2
```

