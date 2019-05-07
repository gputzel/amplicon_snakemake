library(phyloseq)
library(tidyverse)

mapping.file <- snakemake@input[["mapping"]]
ps.file <- snakemake@input[["rds"]]

sample.df <- read.table(mapping.file,sep='\t',row.names=1,comment.char="",header=T)

config <- snakemake@config$import_sample_data

columns <- names(config$columns)

sample.df <- sample.df[,columns,drop=FALSE]

for (column in columns){
    vals <- config$columns[[column]]
    sample.df[,column] <- factor(sample.df[,column],levels=vals)
}

ps <- readRDS(ps.file)

names.from.metadata <- rownames(sample.df)
names.from.phyloseq <- sample_names(ps)

stopifnot(all(names.from.metadata %in% names.from.phyloseq))
stopifnot(all(names.from.phyloseq %in% names.from.metadata))

sample.df <- sample.df[names.from.phyloseq,,drop=FALSE]
sample_data(ps) <- sample_data(sample.df)

saveRDS(object=ps,file=snakemake@output[["rds"]])