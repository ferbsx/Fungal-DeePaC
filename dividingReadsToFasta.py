import glob
import random
from random import sample

random.seed(0)

# # Input training folders:
# pathogenicReadFiles = glob.glob("/home/nasrif/SCRATCH_NOBAK/logSimulation/trainingReads/pathogenic/*.fq")
# nonpathogenicReadFiles = glob.glob("/home/nasrif/SCRATCH_NOBAK/logSimulation/trainingReads/nonpathogenic/*.fq")
#
# # Output training file name prefixes
# pathogenicFasta = '/home/nasrif/SCRATCH_NOBAK/logSimulation/train-pos-log-sample'
# nonpathogenicFasta = '/home/nasrif/SCRATCH_NOBAK/logSimulation/train-neg-log-sample'


# Input validation folders:
pathogenicReadFiles = glob.glob("/home/nasrif/SCRATCH_NOBAK/logSimulation/validationReads/pathogenic/*.fq")
nonpathogenicReadFiles = glob.glob("/home/nasrif/SCRATCH_NOBAK/logSimulation/validationReads/nonpathogenic/*.fq")

# Output validation file name prefixes
pathogenicFasta = '/home/nasrif/SCRATCH_NOBAK/logSimulation/val-pos-log-sample'
nonpathogenicFasta = '/home/nasrif/SCRATCH_NOBAK/logSimulation/val-neg-log-sample'


for file in pathogenicReadFiles:
    pfastaList = []
    print(file)
    with open(file, 'r') as fq:
        readNextLine = False
        for line in fq:
            if line[0] == '@':
                name = '>' + line[1:]
                readNextLine = True
            elif readNextLine:
                readNextLine = False
                pfastaList.append([name, line])

    # divide the reads from this genome into 4 files
    samples = sample(pfastaList, len(pfastaList))
    print("Number of reads in file: " + str(len(pfastaList)))
    for i in range(4):
        number = i + 1
        # print(number)
        pFasta = pathogenicFasta + str(number) + '.fasta'
        # print(pFasta)
        if number == 1:
            # print('we are in sample NUMEROOO UNOOO.')
            with open(pFasta, 'a+') as outputFasta:
                print('sample ONE: ' + str(len(samples[:round(0.25*len(samples))])))
                for read in samples[:round(0.25*len(samples))]:
                    outputFasta.write(read[0])
                    outputFasta.write(read[1])
        elif number == 2:
            # print('we are in sample twooooooo.')
            with open(pFasta, 'a+') as outputFasta:
                print('sample TWO: ' + str(len(samples[round(0.25*len(samples)):round(0.5*len(samples))])))
                for read in samples[round(0.25*len(samples)):round(0.5*len(samples))]:
                    outputFasta.write(read[0])
                    outputFasta.write(read[1])
        elif number == 3:
            # print('we are in sample 3.')
            with open(pFasta, 'a+') as outputFasta:
                print('sample THREE: ' + str(len(samples[round(0.5*len(samples)):round(0.75*len(samples))])))
                for read in samples[round(0.5*len(samples)):round(0.75*len(samples))]:
                    outputFasta.write(read[0])
                    outputFasta.write(read[1])
        elif number == 4:
            # print('we are in sample por, por favor.')
            with open(pFasta, 'a+') as outputFasta:
                print('sample FOUR: ' + str(len(samples[round(0.75 * len(samples)):])))
                for read in samples[round(0.75 * len(samples)):]:
                    outputFasta.write(read[0])
                    outputFasta.write(read[1])


for file in nonpathogenicReadFiles:
    npfastaList = []
    print(file)
    with open(file, 'r') as fq:
        readNextLine = False
        for line in fq:
            if line[0] == '@':
                name = '>' + line[1:]
                readNextLine = True
            elif readNextLine:
                readNextLine = False
                npfastaList.append([name, line])

    # divide the reads from this genome into 4 files
    samples = sample(npfastaList, len(npfastaList))
    print("Number of reads in file: " + str(len(npfastaList)))

    for i in range(4):
        number = i + 1
        # print(number)
        npFasta = nonpathogenicFasta + str(number) + '.fasta'
        # print(npFasta)
        if number == 1:
            # print('we are in sample NUMEROOO UNOOO.')
            with open(npFasta, 'a+') as outputFasta:
                print('sample ONE: ' + str(len(samples[:round(0.25*len(samples))])))
                for read in samples[:round(0.25*len(samples))]:
                    outputFasta.write(read[0])
                    outputFasta.write(read[1])
        elif number == 2:
            # print('we are in sample twooooooo.')
            with open(npFasta, 'a+') as outputFasta:
                print('sample TWO: ' + str(len(samples[round(0.25*len(samples)):round(0.5*len(samples))])))
                for read in samples[round(0.25*len(samples)):round(0.5*len(samples))]:
                    outputFasta.write(read[0])
                    outputFasta.write(read[1])
        elif number == 3:
            # print('we are in sample 3.')
            with open(npFasta, 'a+') as outputFasta:
                print('sample THREE: ' + str(len(samples[round(0.5*len(samples)):round(0.75*len(samples))])))
                for read in samples[round(0.5*len(samples)):round(0.75*len(samples))]:
                    outputFasta.write(read[0])
                    outputFasta.write(read[1])
        elif number == 4:
            # print('we are in sample por, por favor.')
            with open(npFasta, 'a+') as outputFasta:
                print('sample FOUR: ' + str(len(samples[round(0.75 * len(samples)):])))
                for read in samples[round(0.75 * len(samples)):]:
                    outputFasta.write(read[0])
                    outputFasta.write(read[1])
