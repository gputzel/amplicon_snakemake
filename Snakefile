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
        html="output/SampleInfo.html"
    script:
        "scripts/SampleInfo.Rmd"

rule subset_phylosseq:
    input:
        rds="output/RData/phyloseq_with_sample_data.rds"
    output:
        rds="output/RData/ps_subsets/{subset}.rds"
    script:
        "scripts/subset_samples.R"
