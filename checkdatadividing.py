mainFile = 'C:/Users/ferdous.nasri/share/ubuntuVM/GCA_000002525.1_ASM252v1_genomic.fq'
s1 = 'C:/Users/ferdous.nasri/share/ubuntuVM/train-pos-linear-sample1.fasta'
s2 = 'C:/Users/ferdous.nasri/share/ubuntuVM/train-pos-linear-sample2.fasta'
s3 = 'C:/Users/ferdous.nasri/share/ubuntuVM/train-pos-linear-sample3.fasta'
s4 = 'C:/Users/ferdous.nasri/share/ubuntuVM/train-pos-linear-sample4.fasta'

fullList = []
with open(mainFile, 'r') as fq:
    for line in fq:
        if line[0] == '@':
            fullList.append(line[1:])

sample1List = []
with open(s1, 'r') as s:
    for line in s:
        if line[0] == '>':
            sample1List.append(line[1:])

sample2List = []
with open(s2, 'r') as s:
    for line in s:
        if line[0] == '>':
            sample2List.append(line[1:])

sample3List = []
with open(s3, 'r') as s:
    for line in s:
        if line[0] == '>':
            sample3List.append(line[1:])

sample4List = []
with open(s4, 'r') as s:
    for line in s:
        if line[0] == '>':
            sample4List.append(line[1:])

listWithoutSample1 = []
for i in fullList:
    if i not in sample1List:
        listWithoutSample1.append(i)
print(len(listWithoutSample1))

listWithoutSample2 = []
for i in listWithoutSample1:
    if i not in sample2List:
        listWithoutSample2.append(i)
print(len(listWithoutSample2))

listWithoutSample3 = []
for i in listWithoutSample2:
    if i not in sample3List:
        listWithoutSample3.append(i)
print(len(listWithoutSample3))

listWithoutSample4 = []
for i in listWithoutSample3:
    if i not in sample4List:
        listWithoutSample4.append(i)


print(listWithoutSample4)