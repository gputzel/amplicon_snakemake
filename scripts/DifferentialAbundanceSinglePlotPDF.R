library(tidyverse)

g <- readRDS(snakemake@input[['rds']])
res <- readRDS(snakemake@input[['res']]) #Just to know how wide to make the plot

ggsave(filename=snakemake@output[['pdf']],plot=g,width=0.15*nrow(res),height=6)