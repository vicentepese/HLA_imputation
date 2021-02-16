## ---------------------------
##
## Script name: HLA_imputation.R
##
## Purpose of script: Provided a file, a locus (and optional; an ethnicity)
##  performs HLA imputation using HIBAG.  
##
## Author: Vicente Peris Sempere, MSc BME
##
## Year Created: 2021
##
## Copyright (c) Vicente Peris Sempere, 2021
## Email: vipese@stanford.edu
##
## ---------------------------

# Import libraries
library(jsonlite)
library(tidyverse)
library(data.table)
library(HIBAG)
library(parallel)
library(rlist)

########## IMPORT ##########
setwd("~/HLA_imputation")

# Import settings
settings <- jsonlite::fromJSON('settings.json')

# Create command
`%notin%`<- Negate(`%in%`)

########### READ ARUGMENTS ############
 
# List of argumetns
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="dataset filename", metavar="character"),
  make_option(c("-l", "--locus"), type="character", default=NULL, 
              help="Locus to be imputed", metavar="character"),
  make_option(c("-o", "--out"), type = "character", default = "HLA_IMP_",
              help = "Output name", metavar = "character"),
  make_option(c("-e", "--eth"), type = "character", default=NULL,
              help = "Ethnicity name", metavar = "character")
); 
 
# Parse arguments
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# Check that arguments are passes
if (is.null(opt$file)){
  print_help(opt_parser)
  stop("Please provide a file through --file argument.", call.=FALSE)
}

# Check that passes locus are acceptable
if (opt$locus %notin% c("A","B","C","DPB1","DQA1","DQB1","DRB1","DRB3", "DRB4", "DRB5")){
  stop("Loci provided must be any of the following options: \r
  A, B, C, DPB1, DQA1, DQB1, DRB1, DRB3, DRB4 or DRB5", call.=FALSE)
}

########## HLA IMPUTATION ############

# If no ethnicity, load default model, otherwise load ethnicity specific model
if (is.null(opt$eth)){
  
  # Load model
  model.list <- get(load(settings$models$def))
  drb3 <- get(load(settings$models$DRB3))
  drb4 <- get(load(settings$models$DRB4))
  drb5 <- get(load(settings$models$DRB5))
  
  # Merge models with DRB3, DRB4 and DRB5
  model.list[["DRB3"]] <- drb3
  model.list[["DRB4"]] <- drb4
  model.list[["DRB5"]] <- drb5
  
   # Import PLINK binary file
  gname <- opt$file
  yourgeno <- hlaBED2Geno(bed.fn=paste(gname, ".bed", sep = ''), fam.fn=paste(gname, ".fam", sep='')
                          , bim.fn=paste(gname, ".bim", sep=''), assembly = 'hg19')
    
  # Summary of imnput file
  summary(yourgeno)

} else{
  
  # Load model based on ethnicity
  switch(opt$eth, 
         "EUR"= {model.list <- get(load(settings$models$EURmodel))},
         "SAS"= {model.list <- get(load(settings$models$ASImodel))},
         "EAS"= {model.list <- get(load(settings$models$ASImodel))},
         "AMR"= {model.list <- get(load(settings$models$EURmodel))},
         "AFR"= {model.list <- get(load(settings$models$AFRmodel))}
         )
  
  # Load ethnicity data 
  eth.df <- read.table(file = settings$ethnicity, header = TRUE, sep = ",")
  eth.df$sample.id <- paste0(eth.df$FID, rep("-", nrow(eth.df)), eth.df$IID)
  
  # Import PLINK binary file
  gname <- opt$file
  yourgeno <- hlaBED2Geno(bed.fn=paste(gname, ".bed", sep = ''), fam.fn=paste(gname, ".fam", sep='')
                          , bim.fn=paste(gname, ".bim", sep=''), assembly = 'hg19')

  # Filter by ethnicity
  eth_ids <- eth.df %>% filter(Population == opt$eth) %>% .['sample.id'] %>% unlist()
  sample.idx <- which(yourgeno$sample.id %in% eth_ids)
  yourgeno$sample.id <- yourgeno$sample.id[sample.idx]
  yourgeno$genotype <- yourgeno$genotype[,sample.idx]
  
  # Summary of input file
  summary(yourgeno)
  
}

# Make cluster for parallelization
cl <- makeCluster(10)

# Filter model based on input locus
model <- model.list[[opt$locus]]

# Make predictions with HIBAG
model.hla <- hlaModelFromObj(model)
summary(model.hla)
pred.guess <- predict(model.hla, yourgeno, type="response+prob", cl=cl, match.type="Position")

# Import .fam file 
fam.file <- read.table(file = paste0(gname, ".fam"), sep = " ", header = FALSE)
sample.id <- paste(fam.file$V1, fam.file$V2, sep = "-")

# Modify sample.id and create FID and IID
pred.guess$value$sample.id <- sample.id
pred.guess$value$FID <- pred.guess$value$sample.id %>% lapply(function(x) strsplit(x,"-") %>% unlist() %>% .[1]) %>% unlist()
pred.guess$value$IID <- pred.guess$value$sample.id %>% lapply(function(x) strsplit(x,"-") %>% unlist() %>% tail(n=1)) %>% unlist()

# Save file as .RData
prefix <- opt$file %>% strsplit("/") %>% unlist() %>% tail(n=1)
if (is.null(opt$eth)){
  save(pred.guess, file = paste0(opt$out, prefix,'_HLA_', opt$locus, "_", opt$eth, '.RData'))
} else{
    save(pred.guess, file = paste0(opt$out, prefix, "_eth_HLA_", opt$locus, '.RData'))
}
