library(phyloseq)

min_reads <- snakemake@config$min_reads

ps <- readRDS(snakemake@input[['rds']])

totals <- sample_sums(ps)

dropped <- names(totals[totals < min_reads])

ps.rar <- phyloseq::rarefy_even_depth(ps,sample.size = min_reads,rngseed = 1)

attr(ps.rar,"dropped_samples") <- dropped

saveRDS(ps.rar,file=snakemake@output[['rds']])