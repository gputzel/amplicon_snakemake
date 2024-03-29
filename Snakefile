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

rule normalize:
    input:
        rds="output/RData/ps_subsets/{subset}.rds"
    output:
        rds="output/RData/ps_subsets_normalized/{subset}.rds"
    script:
        "scripts/normalize.R"


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

distance_measures={'BrayCurtis':'bray','BinaryJaccard':'jaccard','UniFrac':'unifrac','WeightedUniFrac':'wunifrac'}

def pcoa_PDF_input(wildcards):
    d={}
    d['rds']='output/RData/PCoA/' + wildcards['plan'] + "/" + distance_measures[wildcards['measure']] + ".rds" 
    return(d)

rule pcoa_PDF:
    input:
        unpack(pcoa_PDF_input)
    output:
        pdf="output/figures/PCoA/{plan}/{measure}.pdf"
    script:
        "scripts/PCoA_plot.R"

rule PERMANOVA:
    input:
        unpack(pcoa_ggplot2_object_input) #Uses exactly the same inputs
    output:
        rds="output/RData/PERMANOVA/{plan}/{measure}.rds" 
    script:
        "scripts/PERMANOVA.R"

def PCoA_report_input(wildcards):
    d={}
    plan=wildcards['plan'] 
    subset=config['pcoa_plots'][plan]['sample_subset']
    d['ps']="output/RData/ps_subsets_rarefied/" + subset + ".rds"
    for measure in ['bray','jaccard','unifrac','wunifrac']:
        d['pcoa_' + measure] = 'output/RData/PCoA/' + plan + '/' + measure + '.rds'
        d['PERMANOVA_' + measure] = 'output/RData/PERMANOVA/' + plan + '/' + measure + '.rds'
    for measure_name in distance_measures.keys():
        d['pcoa_' + measure_name + '_PDF'] = 'output/figures/PCoA/' + plan + '/' + measure_name + '.pdf'
    d['Rmd']='scripts/PCoA.Rmd'
    return d

rule pcoa_report:
    input:
        unpack(PCoA_report_input)
    output:
        "output/HTML/PCoA/{plan}.html"
    script:
        "scripts/PCoA.Rmd"

rule all_pcoa_reports:
    input:
        ["output/HTML/PCoA/" + plan + ".html" for plan in config['pcoa_plots'].keys()]

rule long_form_data:
    input:
        rds="output/RData/ps_subsets_normalized/{subset}.rds"
    output:
        rds="output/RData/long_form_data/{subset}.rds"
    script:
        "scripts/long_form_data.R"

def taxonomy_barplot_input(wildcards):
    plan_name=wildcards['plan']
    plan=config['taxonomy_barplots'][plan_name]
    subset=plan['sample_subset']
    d={}
    d['rds']="output/RData/long_form_data/" + subset + ".rds"
    return d

rule taxonomy_barplot:
    input:
        unpack(taxonomy_barplot_input)
    output:
        rds="output/RData/TaxonomyBarplots/{plan}/{rank}.rds"
    script:
        "scripts/TaxonomyBarplot.R"

rule taxonomy_barplot_PDF:
    input:
        rds="output/RData/TaxonomyBarplots/{plan}/{rank}.rds"
    output:
        pdf="output/figures/TaxonomyBarplots/{plan}/{rank}.pdf"
    script:
        "scripts/TaxonomyBarplotPDF.R"

def taxonomy_barplots_HTML_input(wildcards):
    plan = wildcards['plan']
    d={}
    d['Rmd']="scripts/TaxonomyBarplots.Rmd"
    for rank in ['Genus','Family','Order','Class','Phylum']:
        d[rank] = "output/RData/TaxonomyBarplots/" + plan + "/" + rank + ".rds"
        d[rank + '_PDF'] = "output/figures/TaxonomyBarplots/" + plan + "/" + rank + ".pdf"
    return d

rule taxonomy_barplots_HTML:
    input:
        unpack(taxonomy_barplots_HTML_input)
    output:
        "output/HTML/TaxonomyBarplots/{plan}.html"
    script:
        "scripts/TaxonomyBarplots.Rmd"

def alpha_diversity_input(wildcards):
    d={}
    plan = wildcards['plan']
    subset = config['alpha_diversity'][plan]['sample_subset']
    d['rds']="output/RData/ps_subsets_rarefied/" + subset + ".rds"
    return d

rule alpha_diversity:
    input:
        unpack(alpha_diversity_input)
    output:
        rds="output/RData/AlphaDiversity/{plan}.rds"
    script:
        "scripts/AlphaDiversity.R"        

rule alpha_diversity_ggplot2_object:
    input:
        rds="output/RData/AlphaDiversity/{plan}.rds"
    output:
        rds="output/RData/AlphaDiversityPlot/{plan}.rds"
    script:
        "scripts/AlphaDiversityPlotObject.R"

rule alpha_diversity_plot:
    input:
        rds="output/RData/AlphaDiversityPlot/{plan}.rds"
    output:
        pdf="output/figures/AlphaDiversity/{plan}.pdf"
    script:
        "scripts/AlphaDiversityPlot.R"

rule alpha_diversity_HTML:
    input:
        Rmd="scripts/AlphaDiversity.Rmd",
        ggplot="output/RData/AlphaDiversityPlot/{plan}.rds",
        df="output/RData/AlphaDiversity/{plan}.rds",
        pdf="output/figures/AlphaDiversity/{plan}.pdf"
    output:
        "output/HTML/AlphaDiversity/{plan}.html"
    script:
        "scripts/AlphaDiversity.Rmd"

def differential_abundance_input(wildcards):
    d={}
    plan_name=wildcards['plan']
    plan=config['differential_abundance'][plan_name]
    subset=plan['sample_subset']
    d['rds']="output/RData/ps_subsets/" + subset + ".rds"
    return d

rule differential_abundance:
    input:
        unpack(differential_abundance_input)
    output:
        rds="output/RData/DifferentialAbundanceResults/{plan}.rds"
    script:
        "scripts/DifferentialAbundance.R"

rule differential_abundance_xlsx:
    input:
        rds="output/RData/DifferentialAbundanceResults/{plan}.rds"
    output:
        xlsx="output/XLSX/DifferentialAbundanceResults/{plan}.xlsx"
    script:
        "scripts/DifferentialAbundanceXLSX.R"

def differential_abundance_OTU_plots_input(wildcards):
    d={}
    plan_name=wildcards['plan']
    plan=config['differential_abundance'][plan_name]
    subset=plan['sample_subset']
    d['ps']="output/RData/ps_subsets_normalized/" + subset + ".rds"
    d['res']="output/RData/DifferentialAbundanceResults/{plan}.rds"
    return d

rule differential_abundance_OTU_plots:
    input:
        unpack(differential_abundance_OTU_plots_input)
    output:
        zip="output/figures/DifferentialAbundance/{plan}.zip"
    script:
        "scripts/DifferentialAbundancePlots.R"

rule differential_abundance_single_plot:
    input:
        unpack(differential_abundance_OTU_plots_input)
    output:
        rds="output/RData/DifferentialAbundanceSinglePlot/{plan}.rds"
    script:
        "scripts/DifferentialAbundanceSinglePlot.R"

rule differential_abundance_single_plot_PDF:
    input:
        rds="output/RData/DifferentialAbundanceSinglePlot/{plan}.rds",
        res="output/RData/DifferentialAbundanceResults/{plan}.rds"
    output:
        pdf="output/figures/DifferentialAbundanceSinglePlot/{plan}.pdf"
    script:
        "scripts/DifferentialAbundanceSinglePlotPDF.R"

rule differential_abundance_HTML:
    input:
        Rmd="scripts/DifferentialAbundance.Rmd",
        res="output/RData/DifferentialAbundanceResults/{plan}.rds",
        ggplot="output/RData/DifferentialAbundanceSinglePlot/{plan}.rds",
        pdf="output/figures/DifferentialAbundanceSinglePlot/{plan}.pdf",
        zip="output/figures/DifferentialAbundance/{plan}.zip",
        xlsx="output/XLSX/DifferentialAbundanceResults/{plan}.xlsx"
    output:
        "output/HTML/DifferentialAbundance/{plan}.html"
    script:
        "scripts/DifferentialAbundance.Rmd"

rule list_plans:
    run:
        print("PCoA plots:")
        for plan in config['pcoa_plots'].keys():
            print("\t" + plan)
        print("Taxonomy barplots:")
        for plan in config['taxonomy_barplots'].keys():
            print("\t" + plan)
        print("Alpha diversity:")
        for plan in config['alpha_diversity'].keys():
            print("\t" + plan)
        print("Differential abundance:")
        for plan in config['differential_abundance'].keys():
            print("\t" + plan)

def run_all_input(wildcards):
    d={}
    d['SampleInfo']='output/HTML/SampleInfo.html'
    for plan in config['pcoa_plots'].keys():
        d["PCoA_" + plan]="output/HTML/PCoA/" + plan + ".html"
    for plan in config['taxonomy_barplots'].keys():
        d["Taxonomy_" + plan]="output/HTML/TaxonomyBarplots/" + plan + ".html"
    for plan in config['alpha_diversity'].keys():
        d["AlphaDiversity_" + plan]="output/HTML/AlphaDiversity/" + plan + ".html"
    for plan in config['differential_abundance'].keys():
        d["DA_" + plan]="output/HTML/DifferentialAbundance/" + plan + ".html"
    return d

rule run_all:
    input:
        unpack(run_all_input)
