library(tidyverse)
library(RColorBrewer)

long.data <- readRDS(snakemake@input[['rds']])

plan_name <- snakemake@wildcards[['plan']]
plan <- snakemake@config$taxonomy_barplots[[plan_name]]

n_labelled_taxa <- plan$n_labelled_taxa
facet_variable <- plan$facet_variable
taxrank <- snakemake@wildcards[['rank']]

do.plot <- function(df,rank,n_labelled_taxa){
  df %>%
    group_by(OTU) %>%
    summarize(avg.abundance = mean(Abundance)) %>%
    arrange(-avg.abundance) %>%
    head(n=n_labelled_taxa) %>%
    .$OTU -> top.taxa ## OTU is just a placeholder for a higher-level taxon
  taxon <- as.character(df[,rank])
  df$taxon <- ifelse(df$OTU %in% top.taxa,taxon,'~Other')
  df %>%
    ggplot(aes_string('Sample','Abundance',fill='taxon','Classification'=rank)) +
    geom_bar(stat='identity') +
    scale_fill_brewer(palette='Set1') +
    labs(fill='Classification') +
    theme(axis.text.x=element_blank(),axis.text.y=element_blank()) + ylab("Relative Abundance")
}

g <- do.plot(long.data[[taxrank]],taxrank,n_labelled_taxa) +
  facet_wrap(as.formula(paste0('~',facet_variable)),scales='free_x')

saveRDS(object=g,file = snakemake@output[['rds']])