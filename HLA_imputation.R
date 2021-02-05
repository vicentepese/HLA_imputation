# Import libraries
library(jsonlite)
library(tidyverse)
library(readr)
library(data.table)
library(ggrepel)
library(viridis)
library(hrbrthemes)
library(HIBAG)
library(parallel)
library(ggplot2)
library(gridExtra)
library(rlist)
library(plotly)
library(optparse)

########## IMPORT ##########
setwd("~/Documents/HLA_imputation")

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
  make_option(c("-m", "--model"), type = "character", default=NULL,
              help = "Trained HIBAG model used for imputation", metavar = "character"),
  make_option(c("-o", "--out"), type = "character", default = "HLA_imputed",
              help = "Output name", metavar = "character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# Check that arguments are passes
if (is.null(opt$file) | is.null(opt$locus) | is.null(opt$model)){
  print_help(opt_parser)
  stop("All arguments must be supplied", call.=FALSE)
}

# Check that passes locus are acceptable
if (opt$locus %notin% c("A","B","C","DPB1","DQA1","DRB1","DRB3", "DRB4", "DRB5")){
  stop("Loci provided must be any of the following options: \r
  A, B, C, DPB1, DQA1, DQB1, DRB1, DRB3, DRB4 or DRB5", call.=FALSE)
}

########## HLA IMPUTATION ############

# Load pre-fit model and comvert to hlaMODEL
model.list <- get(load(opt$model))
model <- model.list[opt$locus]

# Import file
gname <- opt$file
yourgeno <- hlaBED2Geno(bed.fn=paste(gname, ".bed", sep = ''), fam.fn=paste(gname, ".fam", sep='')
                        , bim.fn=paste(gname, ".bim", sep=''), assembly = 'hg19')
summary(yourgeno)

# Make cluster 
cl <- makeCluster(10)

# Make predictions
model.hla <- hlaModelFromObj(model)
summary(model.hla)
pred.guess <- predict(model.hla, yourgeno, type="response+prob", nclassifiers=100, cl=cl, match.type="Position")
pred.guess$value$FID <- pred.guess$value$sample.id %>% lapply(function(x) strsplit(x,"-") %>% unlist() %>% .[1]) %>% unlist()
pred.guess$value$IID <- pred.guess$value$sample.id %>% lapply(function(x) strsplit(x,"-") %>% unlist() %>% tail(n=1)) %>% unlist()
save(pred.guess, file = paste0(opt$out, '_' , locus, '.RData'))