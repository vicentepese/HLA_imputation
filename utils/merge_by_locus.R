# Import libraries
library(jsonlite)
library(tidyverse)
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
library(parallel)
library(plyr)

########## IMPORT ##########
setwd("~/HLA_imputation")

# Import settings
settings <- jsonlite::fromJSON('settings.json')

# Import ethnicities
eths <- settings$ethnicity_list

# Import filelist
file.list <- list.files("Output/")

########### MERGE BY LOCUS #############

# Parse files and loci 
file.names <- list.files(settings$output, full.names = TRUE)
loci <- settings$locus

# For each locus, merge all the files 
for (locus in loci){
  
  # Verbose
  print(paste("Merging", locus, "locus"))
  
  # Filter files 
  files.locus <- file.names[grep(pattern = paste0("HLA_", locus), x = file.names)]
  
  # Merge each file 
  HLA.df <- data.frame()
  probs.df <- data.frame()
  for (file in files.locus){
    
    # Load file
    file.df <- get(load(file))
    
    # Parse posterior probabilities
    probs.locus <- file.df$value[,c("sample.id", "FID", "IID", "prob")]
    colnames(probs.locus) <- c("sample.id", "FID", "IID", paste0("prob.", locus))
    
    # Parse HLA calls 
    hla.locus <- file.df$value[,c("sample.id", "FID", "IID", "allele1","allele2")]
    colnames(hla.locus) <- c("sample.id", "FID", "IID", paste0(locus,".1"), paste0(locus, ".2"))
    
    # Bind by row 
    HLA.df <- rbind(HLA.df, hla.locus)
    probs.df <- rbind(probs.df, probs.locus)
    
  }
  
  # Write in csv
  write.csv(x = HLA.df, file = paste0("HLAtemp_", locus, ".csv"), row.names = FALSE)
  write.csv(x = probs.df, file = paste0("PROBStemp_", locus, ".csv"), row.names = FALSE)
  
}

############# MERGE LOCI ##############

# Get files and filter by temporary files 
files.loci <- Filter(function(x) grepl(pattern = "temp", x = x), list.files())

# Load HLA calls and probabilities of the first locus
HLA.df <- read.csv(files.loci[grepl(x = files.loci, pattern = paste0("HLAtemp_", loci[1]))])
probs.df <-  read.csv(files.loci[grepl(x = files.loci, pattern = paste0("PROBStemp_", loci[1]))])

# Merge with the rest of locus 
for (locus in tail(loci, n = -1)){
  
  # Load HLA calls and probabilities
  hla.locus <- read.csv(files.loci[grepl(x = files.loci, pattern = paste0("HLAtemp_", locus))])
  probs.locus <- read.csv(files.loci[grepl(x = files.loci, pattern = paste0("PROBStemp_", locus))])
  
  # Merge
  HLA.df <- merge(HLA.df, hla.locus, by = c("sample.id", "FID", "IID"))
  probs.df <- merge(probs.df, probs.locus, by = c("sample.id", "FID", "IID"))
}

# Write Output
write.csv(x = HLA.df, file = "HLA_df.csv", row.names = FALSE)
write.csv(x = probs.df, file = "probs_df.csv", row.names = FALSE)

# Remove temporary files 
files.temp <- list.files()[grepl(x = list.files(), pattern = "temp")]
file.remove(files.temp)
