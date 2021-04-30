library(phyloseq)
library(tidyverse)

plan_name <- snakemake@wildcards[['plan']]
plan <- snakemake@config$differential_abundance[[plan_name]]

prefilter_name <- plan$prefilter
prefilter_string <- snakemake@config$prefilters[[prefilter_name]]$prefilter_function
design_string <- plan$design
attribute <- plan$attribute
group1_plus <- plan$group1_plus
group2_minus <- plan$group2_minus

ps.rel <- readRDS(snakemake@input[['ps']])
res <- readRDS(snakemake@input[['res']])

res %>%
  filter(!is.na(padj)) %>%
  filter(padj < 0.1) %>%
  arrange(-log2FoldChange) %>%
  mutate(label=paste(OTU,Genus,sep=':')) -> res.de

rownames(res.de) <- res.de$OTU

df.long <- psmelt(ps.rel)

g <- df.long %>%
  filter(OTU %in% res.de$OTU) %>%
  mutate(label=paste(OTU,Genus,sep=':')) %>%
  mutate(label=factor(label,levels=res.de$label)) %>%
  ggplot(aes_string('label','Abundance',color=attribute,Sample='Sample',OTU='OTU',Genus='Genus',Family='Family')) +
    geom_boxplot() +
    geom_point(position=position_jitterdodge()) +
    xlab("OTU") +
    ylab("Relative abundance") +
    theme_bw(14) +
    theme(axis.text.x=element_text(angle=90))

saveRDS(object=g,file=snakemake@output[['rds']])