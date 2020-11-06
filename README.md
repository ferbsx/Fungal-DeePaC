# Fungal-DeePaC
code and supplementary materials for my Master's thesis

Here, I will explain the order in which the files in this repository were used to produce the results shown in my Master 
thesis.

## Fungal metadata:
- `allFungalMetadata.csv`: This is a large table with 982 fungal species names, along with their label and the source of that label. The species with publicly available genomes (471) have more information.
If there is more than one source for one label, the sources are presented as `[source 1], [source 2]`, otherwise they are simply written without brackets `source`.

## Data collection:
- `divideData.py`: python script which divides the fungal species from the positive and negative group into training (80%), validation (10%) and test (10%) sets. The file `allFungalMetadata.csv` already includes this added information (the delegation of species to the different sets which was used in the thesis).
- `NCBI-collectDownloadLinks.py`: python script goes through the csv file and collects the download links. It then produces an output bash file which has a `wget` command with every ftp download link.

## Read Simulation:
- `allFungi_sizes.rds`: an R data file which lists only species with genomic data, and in which set they are in (train, test, val). This file also includes the genome sizes which is calculated by the `Do.GetSizes <- T` command in `Simulate.R`.
- `Simulate.R`: R script, copied from the published work from J. Bartoszewicz in DeePac paper [1] (openly available: https://gitlab.com/dacs-hpi/deepac/-/tree/master/supplement_paper/Rscripts/read_simulation).
There has been some changes as we added the logarithmic proportional read simulation. Here, you can chnage the following parameters to have reads simulated proportional to log10 or natural log of the genome size:
`LogTransformation <- T # if True, it will use log10 or natural log`
`NaturalLog <- F # if True, it will use the natural log instead of log10`
- `SimulationWrapper.r`: R script needed for the `Simulate.R` to run. Completely copied from the published work from J. Bartoszewicz in DeePac paper [1] (openly available: https://gitlab.com/dacs-hpi/deepac/-/tree/master/supplement_paper/Rscripts/read_simulation). 

## Sub-sampling simulated reads:
- `dividingReadsToFasta.py`: Turns `.fq` files produced by the read simulation step into 4 `.fasta` files, each with a randomly-sampled independent quarter of the reads from each species.  
- `checkdatadividing.py`: tests the sub-sampling was done correctly (each file has different reads from the same species.)
- `makeBigFastaFromAllFq.py`: turns the produced `fq` files produced for each species from the read simulation step and turns them into `fasta` files with all the reads from each class written in one file (needed to run `rservoir_subsample.sh` and run evaluation later).
- `rservoir_subsample.sh`: bash script which sub-samples 2.5% of the complete training/val positive/negative fasta files. (This original command was created by J. Bartoszewicz.)

## RC-CNN model training:

## Evaluating our best-performing RC-CNN:

## running and comparing with BLAST:
- `findTaxIdForBlastInGenomes.py`:

## Plotting:



### References:
[1]: Jakub M Bartoszewicz, Anja Seidel, Robert Rentzsch, Bernhard Y Renard, DeePaC: predicting pathogenic potential of novel DNA with reverse-complement neural networks, Bioinformatics, Volume 36, Issue 1, 1 January 2020, Pages 81–89, https://doi.org/10.1093/bioinformatics/btz541