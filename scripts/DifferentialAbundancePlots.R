library(tidyverse)
library(phyloseq)
library(ggbeeswarm)

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
  filter(padj < 0.1) -> res.de

rownames(res.de) <- res.de$OTU

df.long <- psmelt(ps.rel)

tdir <- tempdir()
newdir <- file.path(tdir,plan_name)

if(dir.exists(newdir)){
  cat("Directory already exists: ",newdir,"\n")
  #unlink(newdir)
} else {
  dir.create(newdir)
}

for(row in res.de$OTU){
  genus <- as.character(res.de[row,'Genus'])
  cat(row,'\n')
  filename <- file.path(newdir,paste0(row,'_',genus,'.pdf'))
  df.long %>%
    filter(OTU==row) %>%
    ggplot(aes_string(attribute,'Abundance')) + geom_beeswarm() +
    ylab("Relative abundance") + ggtitle(paste0(row,'_',genus)) +
    theme(
      plot.title=element_text(hjust=0.5),
      axis.text=element_text(size=12),
      axis.title=element_text(size=12)
    ) -> g
  ggsave(filename=filename,g)
}

## Horrible stuff that we have to do to get around the fact that
## zip can't SIMPLY COMPRESS THE DIRECTORY YOU POINT IT TO
## and PUT THE RESULT WHERE YOU TELL IT TO
## https://stackoverflow.com/questions/8174979/unix-zipping-sub-directory-not-including-parent-directory/
#cat("Current working directory: ",getwd(),'\n')
#cat("Desired zip output location: ",snakemake@output[['zip']],'\n')
#cat("Desired zip output location in directory: ",dirname(snakemake@output[['zip']]),'\n')
#cat("normalizePath thereof:",normalizePath(dirname(snakemake@output[['zip']])),'\n')
absolute.zip.path <- file.path(
  normalizePath(dirname(snakemake@output[['zip']])),
  paste0(plan_name,'.zip')
)
command <- paste0('(cd ',tdir,'; zip -r ',absolute.zip.path,' ',plan_name,')')

system(command)