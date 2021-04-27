configfile: "config.json"
import jinja2


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

rule relative_abundance_Rmd:
    input:
        "templates/RelativeAbundance.Rmd.temp"
    output:
        "RNotebooks/RelativeAbundance.Rmd"
    run:
        template = jinja2.Environment(loader=jinja2.FileSystemLoader('./templates/')).get_template('RelativeAbundance.Rmd.temp')
        with open("RNotebooks/RelativeAbundance.Rmd",'w') as fo:
            fo.write(template.render(
                    x_axis_var=config["relative_abundance_plots"]["x_axis_var"],
                    taxranks=config["relative_abundance_plots"]["taxranks"]
                )
            )

rule relative_abundance:
    input:
        phyloseq_rds=config["phyloseq_rds_file"],
        Rmd="RNotebooks/RelativeAbundance.Rmd"
    output:
        "output/RelativeAbundance.html"
    script:
        "RNotebooks/RelativeAbundance.Rmd"

rule lefse_input:
    input:
        rds="output/RData/phyloseq_sample_data.rds"
    output:
        txt="output/lefse/lefse_input.txt"
    script:
        "scripts/lefse_input.R"

rule lefse:
    input:
        "output/lefse/lefse_input.txt"
    output:
        "output/lefse/do_lefse.sh",
        "output/lefse/cladogram.pdf",
        "output/lefse/lefse_results.png",
        "output/lefse/lefse_results.res"
    shell:
        "cp scripts/do_lefse.sh output/lefse/do_lefse.sh; cd output/lefse; ./do_lefse.sh"

rule pcoa:
    input:
        rmd="RNotebooks/PCoA.Rmd",
        rds="output/RData/phyloseq_sample_data.rds"
    output:
        "output/PCoA.html"
    script:
        "RNotebooks/PCoA.Rmd"
