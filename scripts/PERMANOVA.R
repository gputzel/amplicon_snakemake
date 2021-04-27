library(vegan)
library(phyloseq)

ps.rar <- readRDS(snakemake@input[['ps']])
distances <- readRDS(snakemake@input[['distances']])

distance.measure <- snakemake@wildcards[['measure']]

pcoa_plan_name <- snakemake@wildcards[['plan']]

pcoa_plan <- snakemake@config$pcoa_plots[[pcoa_plan_name]]

formula.string <- pcoa_plan[['PERMANOVA']]
permutations <- pcoa_plan[['PERMANOVA_permutations']]

do.test <- function(ps.obj,dist.obj){
  my.formula <- as.formula(paste0("dist.obj",formula.string))
  vegan::adonis(my.formula,
                data = data.frame(sample_data(ps.obj)),
                permutations=permutations
  )
}

res <- do.test(ps.obj = ps.rar,dist.obj = distances[[distance.measure]])

saveRDS(object=res,file=snakemake@output[['rds']])