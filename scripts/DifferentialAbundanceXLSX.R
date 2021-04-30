library(openxlsx)
library(tidyverse)

plan_name <- snakemake@wildcards[['plan']]
plan <- snakemake@config$differential_abundance[[plan_name]]

prefilter_name <- plan$prefilter
prefilter_string <- snakemake@config$prefilters[[prefilter_name]]$prefilter_function
design_string <- plan$design
attribute <- plan$attribute
group1_plus <- plan$group1_plus
group2_minus <- plan$group2_minus

res <- readRDS(snakemake@input[['rds']])

res %>%
  filter(!is.na(padj)) %>%
  filter(padj < 0.1) -> res.de

res.de.up <- res.de %>%
  filter(log2FoldChange > 0)

res.de.down <- res.de %>%
  filter(log2FoldChange < 0)

l <- list(res.de.up,res.de.down)
names(l) <- c(
  paste0("Higher in ",group1_plus),
  paste0("Higher in ",group2_minus)
)

openxlsx::write.xlsx(l,file=snakemake@output[['xlsx']])