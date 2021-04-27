library(ggplot2)

g <- readRDS(snakemake@input[['rds']])

ggsave(filename=snakemake@output[['pdf']],plot=g)