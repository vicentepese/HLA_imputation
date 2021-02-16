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
  - *def*: Default HIBAG model (models can be downloaded from the [HIBAG pre-set models] ())
  - *DRB3*: Default HIBAG models do not containg the DRB3 locus, therefore a separate model must be provided (please contact [Aditya] (https://github.com/adiamb))
  - *DRB4* Same as DRB3
  - *DRB5* Same as DRB3
- *pkinkFile*: **list** of full paths to the PLINK binary files that are to be imputed (without the extension, see example in `settings.json`)
- *locus*: **list** of loci (accepts A, B, C, DPB1, DQA1, DQB1, DRB1, DRB3, DRB4, and DRB5)
- *output*: Full path to the directory where HLA imputated files will be stored. 

It is recommended to 

