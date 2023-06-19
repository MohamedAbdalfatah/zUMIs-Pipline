This script is written to work with scMapper  not zUMIs
Why? Because zUMIs (SMART-seq) need all fastq file from one subproject to be in one directory but  scMapper (10X) assume each gem_id (sample) have its directory and the fastqs for each gem_id should be in this format /subproject/jobs/gem_id/fastq the gem_id changed depends on the samples for each subproject
in order to run this you need to have a csv file with fastq path and gem_id
The script will return a new file with new column contain the path after generating the new path with cellranger structure in scMapper
Step 1
python 1-lims_info_file_downloader.py -input_subproject_id_list_file ../data/subproject_list.txt -output_dir ../data/ -lims_path /scratch/groups/singlecell/software/limsq
Step 2
 python3 2-lims_info_to_metadata.py -input_lims_info_file ../data/all_subproject_raw_lims_info.tsv -output_metadata_file ../data/metadata.tsv
Step 3
This script will generate fastq_path_not_found.csv since we don't have access to the file, if we have access to the file it will generate fastq_path.csv
python3 3-write_fastq_path.py -input_lims_info_file ../data/all_subproject_raw_lims_info.tsv -input_metadata_file ../data/metadata.tsv -out_dir ../data/
Step 4
The copy_files_cellreanger script
#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./add_filepath.sh <input1> <input2> <csv_file>"
  exit 1
fi

# Read input values from command-line arguments
input1="$1"
input2="$2"
csv_file="$3"

# Check if the CSV file exists
if [ ! -f "$csv_file" ]; then
  echo "CSV file not found: $csv_file"
  exit 1
fi

# Create a new file to store the updated CSV
output_file="${csv_file%.*}_updated.csv"

# Process the CSV file line by line
while IFS=',' read -r -a columns; do
  # Extract gem_id from the first column
  gem_id="${columns[0]}"

  # Skip the header line
  if [[ $gem_id == "gem_id" ]]; then
    # Append the new column header
    echo "${columns[*]},to_copy" >> "$output_file"
    continue
  fi

  # Construct the file path
  file_path="$input1/$input2/jobs/$gem_id/fastq"

  # Append the file path as a new column to the current line
  echo "${columns[*]},$file_path" >> "$output_file"

  # Copy the file from fastq_path to to_copy directory
  fastq_path="${columns[2]}"
  cp "$fastq_path" "$file_path"
done < "$csv_file"

echo "New column added. Files copied to the to_copy directory. Updated CSV file: $output_file"
 here how to run it
cd /scratch_isilon/groups/singlecell/shared/projects/copy_files 
./copy_scMaper.sh mohamed SCGTEST_49 fastq_path_not_found.csv
Alternative, for cell ranger, you can use  copy_fastqs.cmd script to copy all files to one directory and after copy you can use  3-write_fastq_path.py script with  -fastq_dir which is detect the path of fastqs as where is the copied files
Step 1
python 1-lims_info_file_downloader.py -input_subproject_id_list_file ../data/subproject_list.txt -output_dir ../data/ -lims_path /scratch/groups/singlecell/software/limsq
Step 2
 python3 2-lims_info_to_metadata.py -input_lims_info_file ../data/all_subproject_raw_lims_info.tsv -output_metadata_file ../data/metadata.tsv
Step 3
cd /scratch_isilon/groups/singlecell/shared/projects/copy_files
sbatch copy_fastqs.cmd SCGTEST_49 /scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV/SCMARATOCOV_02/fastq_dir
Step 4
 python3 3-write_fastq_path.py -input_lims_info_file ../data/all_subproject_raw_lims_info.tsv -input_metadata_file ../data/metadata.tsv -out_dir ../data/ -fastq_dir /scratch_isilon/groups/singlecell/shared/projects/SCMARATOCOV/SCMARATOCOV_02/fastq_dir
