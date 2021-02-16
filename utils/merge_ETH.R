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
file.list <- list.files("Output_ETH/")

########## MERGE BY ETHNICITY ############

# Iterate over ethnicities
for (eth in eths){
  
  # Filter file list
  file.list_eth <- file.list[grepl(pattern = eth, x = file.list)]
  
  # Import first file 
  eth.data <- get(load(paste0("Output_ETH/", file.list_eth[1])))
  
  # Get probs and data
  eth.df <- eth.data$value
  locus <- eth.data$locus
  prob.df <- eth.df[,c("sample.id", "FID", "IID", "prob")]
  colnames(prob.df) <- c("sample.id", "FID", "IID", paste0("prob_", locus))
  
  # Data 
  eth.df <- eth.data$value[,c("sample.id", "FID", "IID", "allele1", "allele2")]
  colnames(eth.df) <- c("sample.id", "FID", "IID", paste0(locus, ".1"), paste0(locus, ".2"))
  
  # Merge the rest of the loci
  for (file in file.list_eth[2:length(file.list_eth)]){
    
    # Import file 
    eth.data <- get(load(paste0("Output_ETH/", file)))
    
    # Get probs and data
    eth.loop <- eth.data$value
    locus <- eth.data$locus
    prob.loop <- eth.loop[,c("sample.id", "FID", "IID", "prob")]
    colnames(prob.loop) <- c("sample.id", "FID", "IID", paste0("prob_", locus))
    
    # Data 
    eth.loop <- eth.loop[,c("sample.id", "FID", "IID", "allele1", "allele2")]
    colnames(eth.loop) <- c("sample.id", "FID", "IID", paste0(locus, ".1"), paste0(locus, ".2"))
    
    # Merge 
    eth.df <- merge(eth.df, eth.loop, by = c("sample.id", "FID", "IID"))
    prob.df <- merge(prob.df, prob.loop, by = c("sample.id", "FID", "IID"))
    
    
  }
  
  # Save 
  write.table(x = eth.df, file = paste0("Output_ETH/Merged/HLA_", eth, ".csv"), sep = ",", 
              row.names = FALSE, col.names = TRUE)
  write.table(x = prob.df, file = paste0("Output_ETH/Merged/prob_", eth, ".csv"), sep = ",", 
              row.names = FALSE, col.names = TRUE)
  
  
  
}

# rbind HLA and pribs
files <- list.files("Output_ETH/Merged")
hla.files <- files[grepl(pattern = "HLA", x = files)]
prob.files <- files[grepl(pattern = "prob", x = files)]

hla.df <- data.frame()
for (file in hla.files){
  data.df <- read.table(file = paste0("Output_ETH/Merged/",file), header = TRUE, sep = ",")
  hla.df <- rbind.fill(hla.df, data.df)
}

# Probs
probs.df <- data.frame()
for (file in prob.files){
  data.df <- read.table(file = paste0("Output_ETH/Merged/",file), header = TRUE, sep = ",")
  probs.df <- rbind.fill(probs.df, data.df)
}

# Write 
write.table(x = hla.df, file = "Data/HLA_df.csv", sep = ",",row.names = FALSE, col.names = TRUE)
write.table(x = probs.df, file = "Data/probs.csv", sep = ",",row.names = FALSE, col.names = TRUE)


############### MERGE BY LOCUS #############

# Loci
loci <- c("A", "B", "C", "DPB1", "DQA1", "DQB1", "DRB1", "DRB3", "DRB4", "DRB5")
file.list <- list.files("Output_ETH/")

# Rbind each locus
file.merge.list <- c()
for (locus in loci){
  
  # Initialize
  locus.df <- data.frame()

  # Filter 
  file.locus <- file.list[grepl(pattern = paste0("_", locus,"_"), x = file.list)]
  
  for (file in file.locus){
    get(load(paste0("Output_ETH/",file)))
    pred.guess$value <- pred.guess$value[,c("sample.id", "allele1", "allele2")]
    colnames(pred.guess$value) <- c("sample.id", paste0(locus,".1"), paste0(locus,".2"))
    locus.df <- rbind(locus.df, pred.guess$value)
    
  }
  
  # Write 
  write.table(x = locus.df, file = paste0("Output_ETH/Merged/HLA_", locus, ".csv"), sep = ",", 
              row.names = FALSE, col.names = TRUE)
  # Merge 
  file.merge.list <- c(file.merge.list, paste0("Output_ETH/Merged/HLA_", locus, ".csv"))  
}

# Merge all locus 
import.list <- llply(file.merge.list, read.csv)
data <- Reduce(function(x, y) merge(x, y, all=T, 
                                    by=c("sample.id")), import.list, accumulate=F)
data$sample.id <- llply(data$sample.id, function (x) as.character(x) %>% strsplit("-") %>% unlist() %>% head(n=1)) %>% unlist()

# Write 
write.table(x = data.frame(data), file = "Data/HLA_df.csv", sep = ",",row.names = FALSE, col.names = TRUE)
