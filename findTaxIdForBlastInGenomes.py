import glob

# Input validation folders:
valFiles = glob.glob("./allgenomes/val/*.fna")
trainFiles = glob.glob("./allgenomes/training/*.fna")
testFiles = glob.glob("./allgenomes/test/*.fna")

# Output validation file name prefixes
# pathogenicFasta = '/home/nasrif/SCRATCH_NOBAK/logSimulation/val-pos-log-sample'
# nonpathogenicFasta = '/home/nasrif/SCRATCH_NOBAK/logSimulation/val-neg-log-sample'

valOut = "./valTaxID.txt"
trainOut = "./trainTaxID.txt"
testut = "./testTaxID.txt"

def find(input, output):
    with open(output, "a+") as out:
        for file in input:
            out.write('\n' + file + '\n')
            # taxID = []
            print(file)
            with open(file, 'r') as fna:
                for line in fna:
                    if line[0] == ">":
                        # taxID.append()
                        # out.write(", ")
                        out.write(", " + line.split(">")[1].split(" ")[0])


# find(valFiles, valOut)
find(trainFiles, trainOut)
find(testFiles, testut)