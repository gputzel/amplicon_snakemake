library(phyloseq)

ps <- readRDS(snakemake@input[['rds']])

sample.subset.name <- snakemake@wildcards$subset

filter_string <- snakemake@config$sample_subsets[[sample.subset.name]]

sample.df <- data.frame(sample_data(ps))

indices <- with(sample.df,eval(parse(text=filter_string)))

ps.subset <- subset_samples(ps,indices)

saveRDS(ps.subset,file=snakemake@output[['rds']])