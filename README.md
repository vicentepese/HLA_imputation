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


