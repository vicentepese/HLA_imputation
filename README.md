# HLA imputation in SLURM

## Requirements
### Languages
> R v4.0.2 (may be functional in lower versions) <br>
> SLURM
### R libraries
> jsonlite 1.7.0 <br>
> tidyverse 1.3.0 <br>
> data.table 1.12.8 <br>
> HIBAG 1.24.0 <br>
> parellel 4.0.2 <br>
> rlist 0.4.6.1 <br>

## Introduction
This pipeline is designed to improved to HLA imputation of the `utils` functions in the [GWAS_pipeline](https://github.com/vicentepese/GWAS_pipeline). HLA imputation is computationally heavy and time consuming. For this reason, this pipeline imputes, for each database, each locus (and ethnicity if provided) separatelly allowing parallelization of tasks. 

The pipeline utilizes HLA Genotype Imputation with Attribute Bagging [(HIBAG)](http://www.bioconductor.org/packages/release/bioc/html/HIBAG.html) on Simple Linux Utility for Resource Management [(SLURM)](https://slurm.schedmd.com/documentation.html). For HLA imputation on a local computer, please see the [`utils/HLA_imputation` on GWAS_pipeline](https://github.com/vicentepese/GWAS_pipeline)

## Usage

This pipeline uses a *settings*-based logic, whereby all paths to files are stored in `settings.json`. The following fields must be filled-up to run the HLA imputation:
- *models*:
  - *def*: Full path to the Default HIBAG model (models can be downloaded from the [HIBAG pre-set models] ()).
  - *DRB3*: Full path to the Default HIBAG models do not containg the DRB3 locus, therefore a separate model must be provided (please contact [Aditya](https://github.com/adiamb)).
  - *DRB4* Same as DRB3.
  - *DRB5* Same as DRB3.
- *pkinkFile*: **list** of full paths to the PLINK binary files that are to be imputed (without the extension, see example in `settings.json`).
- *locus*: **list** of loci - accepts A, B, C, DPB1, DQA1, DQB1, DRB1, DRB3, DRB4, and DRB5.
- *output*: Full path to the directory where HLA imputated files will be stored. 

Subsequently, run `bash SLURM_HLA_IMPUTATION.sh`

*Note*: PLINK binary files *must* be cleaned up and QCed before being inputed to the pipeline given that HIBAG does not allow duplicated or multiallelic variants. 


### Impute by ethnicity

This pipeline allows to impute by ethnicity, whereby each ethnicity can be imputed using different, ethnic-specific, models. In addition to the fields previously stated, the following fiels in `settings.json` must be filled-up:
- *models*
  -  *EURmodel*: HIBAG model for imputation of Europeans (EUR) and Americans (AMR).
  -  *ASImodel*: HIBAG model for imputation of South Asian (SAS) and East Asian (EAS).
  -  *AFRmodel*: HIBAG model for imputation of African (AFR).
- *ethnicity*: Full path to the a `.csv` file containing the ethnicity of each subject and composed of three columns (**including headers**):
  - FID: Family ID
  - IID: Individual ID
  - Population: Superpopulation/ethnicity - accepts AFR, EUR, SAS, EAS, and AMR

These superpopulations are based on the categorization of ethnicities followed by [1000 Genomes](https://www.internationalgenome.org/category/population/). For imputation of ethnicites, please see the [ancestry imputation pipeline](https://github.com/vicentepese/ancestry_imputation).

## Utils 
Some utils are included in the `utils` directory.

### `bgen2binary.sh` 
Recommended QC for binary files (includes conversion from `.bgen` to PLINK binary files).

### `merge_by_locus.sh`
Merges files by locus, and subsequently, each merges again each loci to produce a final file with all subjects and loci. Can be used both when imputing only by locus, and by locus and ethnicity. 

### `SUBMTI_HLA_LOCUS.sh`
File that submits jobs through SLURM - may be modified to change accounts and other parameters. 
 


