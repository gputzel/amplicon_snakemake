configfile: "config.json"

def import_sample_data_input(wildcards):
    d={}
    if "xlsx" in config["import_sample_data"].keys():
        d["xlsx"]=config["import_sample_data"]["xlsx"]
    d["rds"]=config["phyloseq_rds_file"]
    return d

rule import_sample_data:
    input:
        unpack(import_sample_data_input)
    output:
        rds="output/RData/phyloseq_with_sample_data.rds"
    script:
        "scripts/import_sample_data.R"

rule sample_info:
    input:
        rds="output/RData/phyloseq_with_sample_data.rds",
        Rmd="scripts/SampleInfo.Rmd"
    output:
        html="output/HTML/SampleInfo.html"
    script:
        "scripts/SampleInfo.Rmd"

rule subset_phyloseq:
    input:
        rds="output/RData/phyloseq_with_sample_data.rds"
    output:
        rds="output/RData/ps_subsets/{subset}.rds"
    script:
        "scripts/subset_samples.R"

rule rarefy:
    input:
        rds="output/RData/ps_subsets/{subset}.rds"
    output:
        rds="output/RData/ps_subsets_rarefied/{subset}.rds"
    script:
        "scripts/rarefy.R"

rule get_distances:
    input:
        rds="output/RData/ps_subsets_rarefied/{subset}.rds"
    output:
        rds="output/RData/distances/{subset}.rds"
    script:
        "scripts/get_distances.R"

def pcoa_ggplot2_object_input(wildcards):
    pcoa_plan = wildcards['plan']
    subset = config['pcoa_plots'][pcoa_plan]['sample_subset']
    d={}
    d['ps'] = "output/RData/ps_subsets_rarefied/" + subset + ".rds"
    d['distances'] = "output/RData/distances/" + subset + ".rds"
    return d

rule pcoa_ggplot2_object:
    input:
        unpack(pcoa_ggplot2_object_input)
    output:
        rds="output/RData/PCoA/{plan}/{measure}.rds"
    script:
        "scripts/PCoA.R"

rule PERMANOVA:
    input:
        unpack(pcoa_ggplot2_object_input) #Uses exactly the same inputs
    output:
        rds="output/RData/PERMANOVA/{plan}/{measure}.rds" 
    script:
        "scripts/PERMANOVA.R"
