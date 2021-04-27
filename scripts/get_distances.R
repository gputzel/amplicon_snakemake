library(phyloseq)

ps.rar <- readRDS(snakemake@input[['rds']])

l <- list(
  "bray" = phyloseq::distance(ps.rar,method='bray'),
  "jaccard" = phyloseq::distance(ps.rar,method='jaccard',binary=TRUE),
  "jsd" = phyloseq::distance(ps.rar,method='jsd'),
  "unifrac" = phyloseq::distance(ps.rar,method='unifrac'),
  "wunifrac" = phyloseq::distance(ps.rar,method='wunifrac')
)

saveRDS(object=l,file=snakemake@output[['rds']])