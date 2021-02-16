#!/bin/bash 

###################################################################
# Script Name	 : SLURM_HLA_IMPUTATION_ETH.sh                                                                                     
# Description	 : Pre-submission of HLA imputation                                                                    
# Args           : None                                                                                           
# Author         : Vicente Peris Sempere                                                
# Email          : vipese@stanford.edu
# Copyright      : Vicente Peris Sempere, 2021
# Year           : 2021                                          
###################################################################

# Read settings
DBS=$(jq -r .plinkFile settings.json)

# Convert datasets to array 
readarray -t DBS_ARR < <(jq -r '.[]' <<<"$DBS")
declare -p DBS_ARR

# For each database, run_HLA imputation
for DB in ${DBS_ARR[@]}; do
    sbatch utils/SUBMIT_HLA_LOCUS.sh --database $DB 
done

