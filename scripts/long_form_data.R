library(phyloseq)

ps.rel <- readRDS(snakemake@input[['rds']])

tax.ranks <- c('Genus','Family','Order','Class','Phylum')
names(tax.ranks) <- tax.ranks
glom.data <- lapply(tax.ranks,function(rank) tax_glom(ps.rel,taxrank=rank))
long.data <- lapply(glom.data,psmelt)

saveRDS(object=long.data,file = snakemake@output[['rds']])