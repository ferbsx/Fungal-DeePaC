# Fungal-DeePaC
code and supplementary materials for my Master's thesis

Here, I will explain the order in which the files in this repository were used to produce the results shown in my Master 
thesis.

## Fungal metadata:
- `allFungalMetadata.csv`: This is a large table with 982 fungal species names, along with their label and the source of that label. The species with publicly available genomes (471) have more information.
If there is more than one source for one label, the sources are presented as `[source 1], [source 2]`, otherwise they are simply written without brackets `source`.

## Data collection:
- `NCBI-collectDownloadLinks.py`: python script goes through the csv file and collects the download links. It then produces an output bash file which has a `wget` command with every ftp download link.

## Read Simulation:
- `allFungi_sizes.rds`: an R data file which lists only species with genomic data, and in which set they are in (train, test, val). This file also includes the genome sizes which is calculated by the `Do.GetSizes <- T` command in `Simulate.R`.
- `Simulate.R`: R script, copied from the published work from J. Bartoszewicz in DeePac paper [1] (openly available: https://gitlab.com/dacs-hpi/deepac/-/tree/master/supplement_paper/Rscripts/read_simulation).
There has been some changes as we added the logarithmic proportional read simulation. Here, you can chnage the following parameters to have reads simulated proportional to log10 or natural log of the genome size:
`LogTransformation <- F # if True, it will use log10 or natural log`
`NaturalLog <- F # if True, it will use the natural log instead of log10`
- `SimulationWrapper.r`: R script needed for the `Simulate.R` to run. Completely copied from the published work from J. Bartoszewicz in DeePac paper [1] (openly available: https://gitlab.com/dacs-hpi/deepac/-/tree/master/supplement_paper/Rscripts/read_simulation). 

## Sub-sampling simulated reads:

## RC-CNN model training:

## Evaluating our best-performing RC-CNN:

## running and comparing with BLAST:

## Plotting:



### References:
[1]: Jakub M Bartoszewicz, Anja Seidel, Robert Rentzsch, Bernhard Y Renard, DeePaC: predicting pathogenic potential of novel DNA with reverse-complement neural networks, Bioinformatics, Volume 36, Issue 1, 1 January 2020, Pages 81–89, https://doi.org/10.1093/bioinformatics/btz541