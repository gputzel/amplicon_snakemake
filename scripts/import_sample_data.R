library(phyloseq)
library(tidyverse)
library(openxlsx)

config <- snakemake@config$import_sample_data

stopifnot("xlsx" %in% names(snakemake@input))

sample.df <- openxlsx::read.xlsx(snakemake@input[["xlsx"]])

rownames(sample.df) <- sample.df[,1]

sample.df <- sample.df[,-1]

factor.columns <- names(config$columns_factor)

for(c in factor.columns){
    stopifnot(c %in% names(config$columns_factor))
    new.order <- config$columns_factor[[c]]
    sample.df[,c] <- factor(sample.df[,c],levels=new.order)
}

ps.file <- snakemake@input[["rds"]]

ps <- readRDS(ps.file)

for(t in config$transform_ps_sample_names){
    sample_names(ps) <- gsub(t$Before,t$After,sample_names(ps))
}

cat("sample_names(ps) - rownames(sample.df):\n")

setdiff(sample_names(ps),rownames(sample.df))

cat("rownames(sample.df) - sample_names(ps):\n")

setdiff(rownames(sample.df),sample_names(ps))

names.from.metadata <- rownames(sample.df)
names.from.phyloseq <- sample_names(ps)

stopifnot(all(names.from.metadata %in% names.from.phyloseq))
stopifnot(all(names.from.phyloseq %in% names.from.metadata))

sample.df <- sample.df[names.from.phyloseq,,drop=FALSE]
sample_data(ps) <- sample_data(sample.df)

saveRDS(object=ps,file=snakemake@output[["rds"]])
