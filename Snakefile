configfile: "config.json"
import jinja2

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
