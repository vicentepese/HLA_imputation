#!/bin/bash 

###################################################################
# Script Name	   : SUBMIT_HLA_LOCUS.sh                                                                                    
# Description	   : Submits jobs to Stanford SCG through SLURM                                                                    
# Args           : 
#   --database: Full path to database
#   --ethnicity: Ethnicity to impute
# Author         : Vicente Peris Sempere                                                
# Email          : vipese@stanford.edu
# Copyright      : Vicente Peris Sempere, 2021
# Year           : 2021                                          
###################################################################

#SBATCH --job-name=IMPUTE_HLA
#SBATCH --output=IMPUTE_HLA.out
#SBATCH --error=IMPUTE_HLA.err
#SBATCH --mem-per-cpu=16000
#SBATCH --array=0-10
#SBATCH --account=mignot
#SBATCH --time=12:00:00

# Parse arguments
PROGNAME=$0

usage() {
  cat << EOF >&2
Usage: $PROGNAME [-p <path>]
-d <database>: Path to the database, up to the prefix
-e <ethnicity>: Ethnicity: EUR, SAS, EAS, AFR or AMR
EOF
  exit 1
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    echo '-d <database>: Path to the database, up to the prefix'
    echo '-e <ethnicity>: Ethnicity: EUR, SAS, EAS, AFR or AMR'
    shift
    shift
    ;;
    -d|--database)
    FILE="$2"
    shift 
    shift 
    ;;
    -e|--ethnicity)
    ETH="$2"
    shift
    shift
    ;;
    *)    
    usage 
esac
done

# Read settings
LOCI=$(jq -r .locus settings.json)
OUT=$(jq -r .output settings.json)

# Convert locus to array 
readarray -t LOCI_ARR < <(jq -r '.[]' <<<"$LOCI")
declare -p LOCI_ARR

# Get locus
LOCUS=${LOCI_ARR[$SLURM_ARRAY_TASK_ID]}

# Load module 
module load r/3.5.0

# Run HLA imputation in the given locus
if [ -z $ETH ]; then 
    Rscript HLA_imputation.R --file $FILE --locus $LOCUS --out $OUT 
else
    Rscript HLA_imputation.R --file $FILE --locus $LOCUS --out $OUT --eth $ETH
fi
