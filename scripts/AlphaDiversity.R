library(phyloseq)
library(tidyverse)

ps.rar <- readRDS(snakemake@input[['rds']])

df <- data.frame(
  sample_data(ps.rar),
  estimate_richness(ps.rar)
) %>%
  rownames_to_column('Sample')

saveRDS(object=df,file = snakemake@output[['rds']])