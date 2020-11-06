# run on python3
import argparse

parser = argparse.ArgumentParser(description='This script sorts your fasta file by species and counts the number of '
                                             'reads per species in that fasta file. '
                                             'This is useful if you downsample your data (resulting in an unsorted '
                                             'fasta file) and want to run an evaluation (`deepac eval`) which requires a'
                                             ' sorted file and a csv file. '
                                             'This script will output 2 files in the same directory as the input file: '
                                             'one fasta file named `<your-input-fasta-name>-sorted.fasta` and a csv file'
                                             ' named `<your-input-fasta-name>.csv` containing the species counts: '
                                             '<species-name>; <Number-of-reads-for-this-species> \n '
                                             '(eg: GCA_001975905.1_Dipser_v1_genomic; 5216\n'
                                             'GCA_001636715.1_AAP_1.0_genomic; 5015\n).')

parser.add_argument('reads', type=str,
                    help='input file containing reads from unsorted species [.fasta format]')
parser.add_argument('--sort', '-s', action='store_true',
                    help='if tag present, we do not assume the original fasta is sorted and produce both sorted.fasta '
                         'and the csv file.')
# parser.add_argument('--output_name', '-n', type=str, required=False, default="sorted",
#                     help='string for the name of the output files, (default = sorted), '
#                          'default output: [sorted.fasta')
# parser.add_argument('--output_directory', '-o', type=str, required=False, default=".",
#                     help='directory to write output files to (default: current directory)')
args = parser.parse_args()


inputDict = {}
count = []
with open(args.reads, 'r') as inFasta:
    print('Reading INPUT: ' + args.reads)
    for line in inFasta:
        if line[0] == '>':
            species = line.split('/')[-1].split('_')[1]
            fullSpecies = line
        else:
            read = line.splitlines()[0]
            read = read + '\n'
            if species in inputDict:
                inputDict[species].append([fullSpecies, read])
            else:
                inputDict[species] = [[fullSpecies, read]]

# output_file = args.output_directory + "/" + args.output_name + ".fasta"

if args.sort:
    outFastaName = args.reads.split('.fasta')[0] + '-sorted.fasta'
    with open(outFastaName, 'a+') as outFasta:
        print('CREATING OUTPUT FILE: ' + outFastaName)
        for key in inputDict.keys():
            for read in inputDict[key]:
                outFasta.write(read[0])
                outFasta.write(read[1])

outCSVName = args.reads.split('.fasta')[0] + '.csv'
with open(outCSVName, 'a+') as outcsv:
    print('CREATING OUTPUT FILE: ' + outCSVName)
    for key, value in inputDict.items():
        outcsv.write(str(key) + '; ' + str(len(value)) + '\n')

print('Mission accomplished!')