#!/bin/bash 

# Read settings
ETH=$(jq -r .ethnicity_list settings.json)
DBS=$(jq -r .plinkFile)

# Convert ethnicity to array 
readarray -t ETH_ARR < <(jq -r '.[]' <<<"$ETH")
declare -p ETH_ARR

# Convert datasets to array 
readarray -t DBS_ARR < <(jq -r '.[]' <<<"$DBS")
declare -p DBS_ARR

# Load module 
module load r/3.5.0

# For each database, and ethnicity, run HLA imputation
for DB in ${DBS_ARR[@]}; do
  for ETH in ${ETH_ARR[@]}; do
    sbatch utils/SUBMIT_HLA_LOCUS.sh $DB $ETH
  done
done

