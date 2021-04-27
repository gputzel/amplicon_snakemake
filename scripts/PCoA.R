library(phyloseq)
library(tidyverse)
library(vegan)

ps.rar <- readRDS(snakemake@input[['ps']])
distances <- readRDS(snakemake@input[['distances']])

distance.measure <- snakemake@wildcards[['measure']]

pcoa_plan_name <- snakemake@wildcards[['plan']]

pcoa_plan <- snakemake@config$pcoa_plots[[pcoa_plan_name]]

color_attr <- pcoa_plan$color_variable
shape_attr <- pcoa_plan$shape_variable

do.plot <- function(ps.obj,dist.obj,color_attr,shape_attr=shape_attr){
  ord <- ordinate(ps.obj,distance=dist.obj,method='PCoA')
  var <- paste0(round(100*ord$values$Relative_eig[c(1,2)],digits = 1),'%)')
  data.frame(
    Sample = sample_names(ps.obj),
    sample_data(ps.obj),
    data.frame(ord$vectors[,c('Axis.1','Axis.2')])
  ) %>%
    ggplot(aes_string('Axis.1','Axis.2',color=color_attr,label='Sample',shape=shape_attr)) +
    geom_point(size=3) + 
    stat_ellipse(level=0.68) +
    #geom_text_repel() +
    xlab(paste0("Axis.1 (",var[1])) +
    ylab(paste0("Axis.2 (",var[2])) +
    theme_bw() +
    theme(axis.text=element_text(size=14),axis.title=element_text(size=14))
}

g <- do.plot(ps.rar,distances[[distance.measure]],color_attr=color_attr,shape_attr = shape_attr)

saveRDS(object=g,file=snakemake@output[['rds']])