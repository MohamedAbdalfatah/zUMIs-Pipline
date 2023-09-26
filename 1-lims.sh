#!/bin/bash

# Get information for each library (flow cell, lane, sample id, etc.)
# $1  needs to be the name of the project
scripts/limsq.py -sp $1 | sed 's/;/\t/g' > "lims_info.txt"

echo "Created LIMS information file: lims_info.txt"
