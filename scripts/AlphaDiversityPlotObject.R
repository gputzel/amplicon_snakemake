library(tidyverse)

plan_name <- snakemake@wildcards[['plan']]
plan <- snakemake@config$alpha_diversity[[plan_name]]
x_variable <- plan$x_variable

df <- readRDS(snakemake@input[['rds']])

max.shannon <- max(df$Shannon)
g <- df %>%
  ggplot(aes_string(x_variable,'Shannon',Sample='Sample')) + geom_jitter(height=0,width=0.05) +
  scale_y_continuous(limits=c(0,1.05*max.shannon)) +
  theme_bw() +
  theme(axis.text=element_text(size=12),axis.title=element_text(size=12)) + ylab("Shannon index")

saveRDS(object=g,file = snakemake@output[['rds']])