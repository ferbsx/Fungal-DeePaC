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

## Sub-sampling simulated reads:

## RC-CNN model training:

## Evaluating our best-performing RC-CNN:

## running and comparing with BLAST:

## Plotting:

