#!/bin/bash 

# Datasets
PREFIX=/labs/mignot/LIFTOVER_GERA_2018/CHR6_concat_EAS_CLEAN_pass1_lifted_over_SORTED
OUTFIX=CHR6_concat_EAS_CLEAN_pass1_lifted_over_SORTED
sampleIDs=/labs/mignot/LGI1/imputePipeline_v2.0.0/LGI1_patlist.txt

# Load module and convert to binary 
module load qctool/v2.0.1
qctool_v2.0.1 \
-g $PREFIX.bgen \
-s $PREFIX.sample \
-assume-chromosome 6 \
-compare-variants-by position,alleles \
-incl-samples $sampleIDs \
-threads 16 \
-threshold 0.8 \
-ofiletype binary_ped \
-og Data/$OUTFIX \
-os Data/$OUTFIX.sample

# Convert format of fam file 
awk 'NR>2 {print $0}' Data/$OUTFIX.sample > temp
awk 'FNR==NR{a[NR]=$1;next}{$1=a[FNR]}1' temp Data/$OUTFIX.fam > fam_temp && mv fam_temp Data/$OUTFIX.fam
awk 'FNR==NR{a[NR]=$2;next}{$2=a[FNR]}1' temp Data/$OUTFIX.fam  > fam_temp && mv fam_temp Data/$OUTFIX.fam

# Parse duplicate variants (based on position and allele codes)
module load plink
plink --bfile Data/$OUTFIX --list-duplicate-vars suppress-first \
    --allow-no-sex --out tmp > tmp
awk '{print $4}' tmp.dupvar > temp_dupSNPs
rm -r tmp*

# Parse duplicated  FIDs
awk '{seen[$1,$2]++}' Data/$OUTFIX.fam > temp_dupFIDs

# Remove duplicated variants
plink --bfile Data/$OUTFIX --remove temp_dupFIDs --exclude temp_dupSNPs\
    --allow-no-sex \
    --make-bed --out gwastempFilt > gwastempFilt
mv gwastempFilt.bim Data_filt/$OUTFIX.bim
mv gwastempFilt.bed Data_filt/$OUTFIX.bed
mv gwastempFilt.fam Data_filt/$OUTFIX.fam 

rm *temp*