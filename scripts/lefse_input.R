library(phyloseq)
library(ggp.16s)

ps <- readRDS(snakemake@input[['rds']])

ggp.16s::generate.lefse.input(ps,
                              sample.attributes=snakemake@config[['lefse']][['sample_attributes']],
                              clean.taxonomy = FALSE,
                              lowest.rank='Genus',
                              filename=snakemake@output[['txt']]
                             )