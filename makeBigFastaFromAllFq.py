import glob
# import gzip

# Input training folders:
pathogenicReadFiles1 = glob.glob("/home/nasrif/SCRATCH_NOBAK/logSimulation/testReads/pathogenic/*1.fq")
nonpathogenicReadFiles1 = glob.glob("/home/nasrif/SCRATCH_NOBAK/logSimulation/testReads/nonpathogenic/*1.fq")

pathogenicReadFiles2 = glob.glob("/home/nasrif/SCRATCH_NOBAK/logSimulation/testReads/pathogenic/*2.fq")
nonpathogenicReadFiles2 = glob.glob("/home/nasrif/SCRATCH_NOBAK/logSimulation/testReads/nonpathogenic/*2.fq")

# Output training file name prefixes
pathogenicFasta1 = '/home/nasrif/SCRATCH_NOBAK/logSimulation/test1-pos-log-all.fasta'
nonpathogenicFasta1 = '/home/nasrif/SCRATCH_NOBAK/logSimulation/test1-neg-log-all.fasta'

pathogenicFasta2 = '/home/nasrif/SCRATCH_NOBAK/logSimulation/test2-pos-log-all.fasta'
nonpathogenicFasta2 = '/home/nasrif/SCRATCH_NOBAK/logSimulation/test2-neg-log-all.fasta'

# # Input validation folders:
# pathogenicReadFiles = glob.glob("/home/nasrif/SCRATCH_NOBAK/logSimulation/validationReads/pathogenic/*.fq.gz")
# nonpathogenicReadFiles = glob.glob("/home/nasrif/SCRATCH_NOBAK/logSimulation/validationReads/nonpathogenic/*.fq.gz")
#
# # Output validation file name prefixes
# pathogenicFasta = '/home/nasrif/SCRATCH_NOBAK/logSimulation/val-pos-log-all.fasta'
# nonpathogenicFasta = '/home/nasrif/SCRATCH_NOBAK/logSimulation/val-neg-log-all.fasta'

for file in pathogenicReadFiles1:
    pfastaList = []
    print(file)
    with open(file, 'r') as fq:
        readNextLine = False
        for line in fq:
            if line[0] == '@':
                name = '>' + line[1:].splitlines()[0] + '\n'
                # print(name)
                readNextLine = True
            elif readNextLine:
                readNextLine = False
                read = line.splitlines()[0] + '\n'
                pfastaList.append([name, read])
        print(len(pfastaList))

    with open(pathogenicFasta1, 'a+') as outputFasta:
        for read in pfastaList:
            outputFasta.write(read[0])
            outputFasta.write(read[1])



for file in pathogenicReadFiles2:
    pfastaList1 = []
    print(file)
    with open(file, 'r') as fq:
        readNextLine = False
        for line in fq:
            if line[0] == '@':
                name = '>' + line[1:].splitlines()[0] + '\n'
                # print(name)
                readNextLine = True
            elif readNextLine:
                readNextLine = False
                read = line.splitlines()[0] + '\n'
                pfastaList1.append([name, read])
        print(len(pfastaList1))

    with open(pathogenicFasta2, 'a+') as outputFasta:
        for read in pfastaList1:
            outputFasta.write(read[0])
            outputFasta.write(read[1])


for file in nonpathogenicReadFiles1:
    npfastaList = []
    print(file)
    with open(file, 'r') as fq:
        readNextLine = False
        for line in fq:
            if line[0] == '@':
                name = '>' + line[1:].splitlines()[0] + '\n'
                # print(name)
                readNextLine = True
            elif readNextLine:
                readNextLine = False
                read = line.splitlines()[0] + '\n'
                npfastaList.append([name, read])
        print(len(npfastaList))

    with open(nonpathogenicFasta1, 'a+') as outputFasta:
        for read in npfastaList:
            outputFasta.write(read[0])
            outputFasta.write(read[1])


for file in nonpathogenicReadFiles2:
    npfastaList2 = []
    print(file)
    with open(file, 'r') as fq:
        readNextLine = False
        for line in fq:
            if line[0] == '@':
                name = '>' + line[1:].splitlines()[0] + '\n'
                # print(name)
                readNextLine = True
            elif readNextLine:
                readNextLine = False
                read = line.splitlines()[0] + '\n'
                npfastaList2.append([name, read])
        print(len(npfastaList2))

    with open(nonpathogenicFasta2, 'a+') as outputFasta:
        for read in npfastaList2:
            outputFasta.write(read[0])
            outputFasta.write(read[1])


# for file in nonpathogenicReadFiles:
#     npfastaList = []
#     print(file)
#     with gzip.open(file, 'r') as fq:
#         c = fq.read()
#         content = c.splitlines()
#         readNextLine = False
#         for line in content:
#             line = line.decode("utf-8")
#             if line[0] == '@':
#                 name = '>' + line[1:] + '\n'
#                 readNextLine = True
#             elif readNextLine:
#                 readNextLine = False
#                 read = line + '\n'
#                 npfastaList.append([name, read])
#
#     with open(nonpathogenicFasta, 'w+') as outputFasta:
#         for read in npfastaList:
#             outputFasta.write(read[0])
#             outputFasta.write(read[1])

