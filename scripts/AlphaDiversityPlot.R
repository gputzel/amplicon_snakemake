library(tidyverse)

g <- readRDS(snakemake@input[['rds']])

plan_name <- snakemake@wildcards[['plan']]
plan <- snakemake@config$alpha_diversity[[plan_name]]

ggsave(filename=snakemake@output[['pdf']],plot=g,
       width=plan$PDF_width,height=plan$PDF_height)