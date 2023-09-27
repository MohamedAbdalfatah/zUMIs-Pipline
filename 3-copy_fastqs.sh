#!/bin/bash
# Step 1: Execute the 1-lims.sh script and save the output to lims_info.txt
sh /scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV/SCMARATOCOV_03/scripts/1-lims.sh "$1"
# Step 2: Activate the desired conda environment
source /scratch/groups/hheyn/software/anaconda3/bin/activate cellranger
# Step 2: Run the 2-write_fastq_paths.py script and generate the fastq_paths.tab file
python /scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV/SCMARATOCOV_03/scripts/2-write_fastq_paths.py --info_file lims_${1}.txt --subproject "$1"
# Step 3: Specify the target directory where you want to copy the files
[ -w "$2" ] && echo "You have permission to target directory" || echo "You do not have permission to target directory"
target_directory="$2"
# Step 4: Check if fastq_paths.tab file exists and copy the files
if [ -f "./fastq_paths_${1}.tab" ]; then
    while IFS=$'\t' read -r -a fields; do
        # Extract the path from the second column (index 1)
        path=${fields[1]}
        # Copy the file to the target directory using rsync
        rsync -avL "$path" "$target_directory"
    done < "./fastq_paths_${1}.tab"
else
    echo "fastq_paths.tab file not found."
fi
# Step 5: Change permissions of the target directory
chmod g+rwx "$2"
# Step 6: Deactivate conda env
source /scratch/groups/hheyn/software/anaconda3/bin/deactivate

