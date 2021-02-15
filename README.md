# Fungal-DeePaC
**code and supplementary materials for my Master's thesis**

In this file, I will explain the order in which the files in this repository were used to produce the results shown in my Master 
thesis. As the data files are rather large and reproducible using the following files, we do not upload them. If you would like to have certain data files, please don't hesitate to reach out to me (via email: <ferdousnasri@zedat.fu-berlin.de>). I will gladly provide them.

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
- `preproc_config_training.ini`: an example of the configuration files used to pre-process the input data for the model. (Turn `.fasta` into `.npy` files.) To run this file, a DeePaC command, eg: `deepac preproc preproc_config_training.ini` needs to run.
- `fungi-all-log-cnn-edt26.ini`: an example of the configuration files used to train RC-CNN. This one is from our best performing RC-CNN (the file includes all the details, such as which data files, architecture, hyperparameter setting were used.). To train a model, the following command needs to be used: `deepac train -c fungi-all-log-cnn-edt26.ini` (for run-time details, the command can be preceded with `time `).

For more examples and descriptions, please look into the DeePaC tool [1] (documentation: https://rki_bioinformatics.gitlab.io/DeePaC/, other examples: https://gitlab.com/dacs-hpi/deepac/-/tree/master/deepac/builtin/config)

## Evaluating our best-performing RC-CNN:
- `sortDownsampledFasta.py`: python file which sorts downsamplaed fasta files by species and counts the number of reads per species (needed for DeePaC evaluation on downsampled data).
- `f-all-eval-testpaired.ini`: configuration file used to evaluate single and paired-test reads. To run the evaluation, the following command needs to run: `deepac eval -r f-all-eval-testpaired.ini`.
- `f-all-eval-species-testpaired.ini`: configuration file used to run a species-based evaluation of the paired-test reads. To run the evaluation, the following command needs to run: `deepac eval -s f-all-eval-species-testpaired.ini`.

For more examples and descriptions, please look into the DeePaC tool [1] (documentation: https://rki_bioinformatics.gitlab.io/DeePaC/, other examples: https://gitlab.com/dacs-hpi/deepac/-/tree/master/deepac/builtin/config_templates)

## Comparison with BLAST:
- `findTaxIdForBlastInGenomes.py`: python script, which extracts tax IDs from each species (needed for blast)
- `allBlastFungi.rds`: R data file with all those tax IDs included in the table. 
- `BlastComparisonK.R`: R script which builds the BLAST Database using all training genomes, runs BLAST to create predictions for test data, and processes the results (determining if predictions were consistent with the ground truth or not). This script was copied (and slightly modified to fit our data) from the published work from J. Bartoszewicz in DeePac paper [1] (openly available: https://gitlab.com/dacs-hpi/deepac/-/tree/master/supplement_paper/Rscripts/comparative).
- `BlastPerformance.R`: R script which calculates read-by-read performance of BLAST on single and paired test reads. This script was copied (and slightly modified to fit our data) from the published work from J. Bartoszewicz in DeePac paper [1] (openly available: https://gitlab.com/dacs-hpi/deepac/-/tree/master/supplement_paper/Rscripts/comparative).
- `BlastSpecies.R`: R script which calculates the species-based performance of BLASt on paired test reads. This script was copied (and slightly modified to fit our data) from the published work from J. Bartoszewicz in DeePac paper [1] (openly available: https://gitlab.com/dacs-hpi/deepac/-/tree/master/supplement_paper/Rscripts/comparative).
- `/Blast/*`: This folder includes all the files produced by running the `BlastComparisonK.R` on the paired-test data-set (not including the library Blast creates from the training genomes).

## Results:
- `allModelConfigsAndResults.xlsx`: excel file where each column represents one trained model. The configurations of that model are noted and at the bottom the results from that training round.
- `nn-fungi-all-log-cnn-edt26-metrics.xlsx`: excel file including all the evaluation results run on different epochs and sets on our best RC-CNN files.
- `training-fungi-all-log-cnn-edt26.csv`: CSV file with the training and validation results produced by DeePaC after every training epoch of our best RC-CNN model.
- `Blast_ReadByRead_AllTrainingGenomes.csv`: csv file produced by `BlastPerformance.R`.
- `Blast_Species_test_paired_AllTrainingGenomes.csv`: csv file produced by `BlastSpecies.R`.


### References:
[1]: Jakub M Bartoszewicz, Anja Seidel, Robert Rentzsch, Bernhard Y Renard, DeePaC: predicting pathogenic potential of novel DNA with reverse-complement neural networks, Bioinformatics, Volume 36, Issue 1, 1 January 2020, Pages 81–89, https://doi.org/10.1093/bioinformatics/btz541