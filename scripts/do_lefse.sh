#!/bin/bash

#Before running this script, do the following to activate a conda virtualenv where I have installed the lefse Bioconda package
source activate lefse

echo "Formatting LEfSe input..."
lefse-format_input.py lefse_input.txt lefse_input.in -c 1 -u 2 -o 1000000
echo "Running LEfSe..."
run_lefse.py lefse_input.in lefse_results.res
echo "Plotting LEfSe results..."
lefse-plot_res.py lefse_results.res lefse_results.png --dpi 300
echo "Plotting cladogram..."
lefse-plot_cladogram.py lefse_results.res cladogram.pdf --format pdf --dpi 300 --right_space_prop 0.2 --abrv_stop_lev 10 --abrv_start_lev 3
if [ ! -d biomarkers ]
then
    mkdir biomarkers
fi
lefse-plot_features.py lefse_input.in lefse_results.res biomarkers/ --dpi 300
source deactivate
