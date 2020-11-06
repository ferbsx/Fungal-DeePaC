import csv
import random
from random import sample

random.seed(0)
testProportion = 0.1
validationProportion = 0.1
trainingProportion = 0.8


def openCSVToList(fileName, listName):
    file = open(fileName, 'r')
    fileReader = csv.reader(file, delimiter=',')

    try:
        for line in fileReader:
            listName.append([line[0], line[1], line[2], line[3], line[4], line[5]])
    finally:
        file.close()


def writeDownloadLinksToBash(listName, outputFileName, downloadDirectory):
    # This produces a bash file [outputFileName] which when clicked on:
    # downloads the genomes named in the corresponding list [listName] (with wget) in a new folder [downloadDirectory],
    # which is made (if it doesn't already exist) for that group, eg: ./positiveTraining/ and unzip them (with gunzip)
    #
    # !! Run on Linux (wget and gunzip are pre-installed on Ubuntu)
    file = open(outputFileName, 'w')
    try:
        for x in listName:
            ftp = str(x[5]) + '/' + str(x[5].split('/')[9:10][0]) + '_genomic.fna.gz'
            getFTP = 'wget --timestamping ' + ftp + ' -P ' + downloadDirectory + '\n'
            file.write(getFTP)
            fileName = downloadDirectory + str(x[5].split('/')[9:10][0]) + '_genomic.fna.gz'
            unzipFile = 'gunzip ' + fileName + '\n'
            file.write(unzipFile)
    # rsync --copy-links --times --verbose rsync://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/003/947/045/GCA_003947045.1_NRRL20438v1/GCA_003947045.1_NRRL20438v1_genomic.fna.gz ./positiveTest/

    # wget --timestamping ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/001/477/545/GCA_001477545.1_Pneu_cari_B80_V3/GCA_001477545.1_Pneu_cari_B80_V3_genomic.fna.gz -P ./positiveTraining/
    # gunzip ./positiveTraining/GCA_001477545.1_Pneu_cari_B80_V3_genomic.fna.gz
    finally:
        file.close()


# Read classes details
hh = []
openCSVToList('./PositiveDetails.csv', hh)

nhh_animal = []
openCSVToList('./NegativeAnimalDetails.csv', nhh_animal)

nhh_plant = []
openCSVToList('./NegativePlantDetails.csv', nhh_plant)

# Separation into Training, Validation, and Test:
proportionSum = testProportion + validationProportion + trainingProportion
if proportionSum != 1.0:
    raise Exception('The proportion of Training, Validation and Test should sum up to 1.0. The sum is: {}'.format(proportionSum))

# Positive class
positive_test = sample(hh, round(testProportion*len(hh))-2)
# add Candida albicans and Aspergillus fumigatus into the positive test dataset
findCalbicans = [y[0] == '5476' for y in hh]
findAfumigatus = [y[0] == '746128' for y in hh]

positive_test.append(hh[findCalbicans.index(True)])
positive_test.append(hh[findAfumigatus.index(True)])
# print(len(positive_test))

positiveTrainingAndValidation = [x for x in hh if x not in positive_test]
# print(len(positiveTrainingAndValidation))

positive_validation = sample(positiveTrainingAndValidation, round(validationProportion * len(hh)))
# print(len(positive_validation))

# 0.8
positive_training = [x for x in positiveTrainingAndValidation if x not in positive_validation]
# print(len(positive_training))


# Negative class
negative_plant_test = sample(nhh_plant, round(testProportion*len(nhh_plant))-1)
negative_animal_test = sample(nhh_animal, round(testProportion*len(nhh_animal))-1)
# Add `Pyricularia oryzae` (plant) and `Batrachochytrium dendrobatidis` (animal) into Negative class test.
findPoryzae = [y[0] == '318829' for y in nhh_plant]
findBdendrobatidis = [y[0] == '109871' for y in nhh_animal]
negative_plant_test.append(nhh_plant[findPoryzae.index(True)])
negative_animal_test.append(nhh_animal[findBdendrobatidis.index(True)])

negative_test = negative_animal_test + negative_plant_test

negativeTrainingAndValidation_animal = [x for x in nhh_animal if x not in negative_test]
negativeTrainingAndValidation_plant = [x for x in nhh_plant if x not in negative_test]

negative_animal_validation = sample(negativeTrainingAndValidation_animal, round(validationProportion*len(nhh_animal)))
negative_plant_validation = sample(negativeTrainingAndValidation_plant, round(validationProportion*len(nhh_plant)))
negative_validation = negative_animal_validation + negative_plant_validation

negative_animal_training = [x for x in negativeTrainingAndValidation_animal if x not in negative_validation]
negative_plant_training = [x for x in negativeTrainingAndValidation_plant if x not in negative_validation]
negative_training = negative_animal_training + negative_plant_training


print(negative_animal_training)
print(negative_animal_validation)
print(negative_animal_test)


# Save Download links into bash files
writeDownloadLinksToBash(positive_training, './downloadLinks-hhTraining.sh', './positiveTraining/')
writeDownloadLinksToBash(positive_validation, './downloadLinks-hhValidation.sh', './positiveValidation/')
writeDownloadLinksToBash(positive_test, './downloadLinks-hhTest.sh', './positiveTest/')

writeDownloadLinksToBash(negative_training, './downloadLinks-nhhTraining.sh', './negativeTraining/')
writeDownloadLinksToBash(negative_validation, './downloadLinks-nhhValidation.sh', './negativeValidation/')
writeDownloadLinksToBash(negative_test, './downloadLinks-nhhTest.sh', './negativeTest/')

# TODO:
# the download links files produced do not need to be separated into files any more,
# all genomes are now downloaded and kept in `./allGenomes/`