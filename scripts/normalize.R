library(phyloseq)

ps <- readRDS(snakemake@input[['rds']])

ps.rel <- transform_sample_counts(ps,function(x)x/sum(x))

saveRDS(object=ps.rel,file=snakemake@output[['rds']])