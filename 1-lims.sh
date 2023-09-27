#!/bin/bash

# Get information for each library (flow cell, lane, sample id, etc.)
# $1  needs to be the name of the project
/scratch/groups/singlecell/software/limsq -sp $1 | sed 's/;/\t/g' > lims_${1}.txt

echo "Created LIMS information file: lims_${1}.txt"
