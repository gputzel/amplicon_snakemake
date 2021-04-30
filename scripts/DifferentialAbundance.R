library(phyloseq)
library(DESeq2)
library(tidyverse)

plan_name <- snakemake@wildcards[['plan']]
plan <- snakemake@config$differential_abundance[[plan_name]]

prefilter_name <- plan$prefilter
prefilter_string <- snakemake@config$prefilters[[prefilter_name]]$prefilter_function
design_string <- plan$design
attribute <- plan$attribute
group1_plus <- plan$group1_plus
group2_minus <- plan$group2_minus

ps <- readRDS(snakemake@input[['rds']])

dds <- phyloseq_to_deseq2(ps,design=as.formula(design_string))


for(variable in all.vars(design(dds))){
  cat(variable,'\n')
  colData(dds)[,variable] <- droplevels(colData(dds)[,variable])
}

eval(parse(text=paste0('prefilter <- ',prefilter_string)))

dds.filtered <- prefilter(dds)

dds.filtered <- DESeq(dds.filtered,minReplicatesForReplace = Inf,fitType = 'mean')

res <- results(dds.filtered,c(attribute,group1_plus,group2_minus),tidy=T)

tax.df <- tax_table(ps) %>%
  data.frame %>%
  rownames_to_column('row')

res.annot <- res %>%
  left_join(tax.df,by=c('row'='row')) %>%
  arrange(padj) %>%
  rename(OTU=row)

saveRDS(object=res.annot,file=snakemake@output[['rds']])