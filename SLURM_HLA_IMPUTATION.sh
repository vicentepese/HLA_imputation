#!/bin/bash 

#SBATCH --job-name=IMPUTE_HLA
#SBATCH --output=IMPUTE_HLA.out
#SBATCH --error=IMPUTE_HLA.err
#SBATCH --mem-per-cpu=16000
#SBATCH --array=0-10
#SBATCH --account=mignot
#SBATCH --time=12:00:00

# Read settings
FILE=$(jq -r .plinkFile settings.json)
LOCI=$(jq -r .locus settings.json)
MODEL=$(jq -r .model settings.json)
OUT=$(jq -r .output settings.json)

# Convert locus to array 
readarray -t LOCI_ARR < <(jq -r '.[]' <<<"$LOCI")
declare -p LOCI_ARR

# Get locus
LOCUS=${LOCI_ARR[$SLURM_ARRAY_TASK_ID]}

# Load model 
module load r/4.0.3 
Rscript HLA_imputation.R --file $FILE --locus $LOCUS --model $MODEL --out $OUT
