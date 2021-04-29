library(ggplot2)

g <- readRDS(snakemake@input[['rds']])

plan_name <- snakemake@wildcards[['plan']]
plan <- snakemake@config$taxonomy_barplots[[plan_name]]

ggsave(filename=snakemake@output[['pdf']],plot=g,
       height=plan$PDF_height,
       width=plan$PDF_width
      )