#!/bin/bash

# Check if input and output paths were provided as arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_directory> <output_directory>"
  exit 1
fi

# Set input and output paths from the provided arguments
input_dir="$1"
output_dir="$2"

# Loop through all FASTQ files in the input directory
for file in "$input_dir"/*.fastq.gz; do
  if [[ "$file" =~ ([A-Z0-9]+)_([0-9]+)_IDT-DUI-NXT-([0-9]+)_([12]).fastq.gz ]]; then
    prefix="${BASH_REMATCH[1]}"
    idt_dui_nxt="${BASH_REMATCH[3]}"
    read_number="${BASH_REMATCH[4]}"

    # Combine read 1 (_1)
    if [ "$read_number" == "1" ]; then
      cat "$file" >> "$output_dir/${prefix}_IDT-DUI-NXT-${idt_dui_nxt}_1.fastq.gz"
    fi

    # Combine read 2 (_2)
    if [ "$read_number" == "2" ]; then
      cat "$file" >> "$output_dir/${prefix}_IDT-DUI-NXT-${idt_dui_nxt}_2.fastq.gz"
    fi
  fi
done
