#!/bin/bash 

# Read settings
DBS=$(jq -r .plinkFile settings.json)

# Convert datasets to array 
readarray -t DBS_ARR < <(jq -r '.[]' <<<"$DBS")
declare -p DBS_ARR

# For each database, run_HLA imputation
for DB in ${DBS_ARR[@]}; do
    sbatch utils/SUBMIT_HLA_LOCUS.sh --database $DB 
done

