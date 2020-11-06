# R
# R version 3.5 and higher
# install.packages("foreach")
# install.packages("doParallel")
# library(foreach)
# install bioawk (conda)
source("./SimulationWrapper.R") # make sure the mason directory is correct on this file

Workers <- 96

Do.TrainingData <- T
Do.ValidationData <- T
Do.TestData <- T
Do.Balance <- T
Do.Balance.test <- T
Do.GetSizes <- T # Don't change this to F
IMG.Sizes <- F
Do.Clean <- T # Change to T
Cleaned <- T
Simulator <- "Mason"
# Only affects Mason v0.x
AllowNsFromGenome <- T

ReadLength <- 250
MeanFragmentSize <- 600
FragmentStdDev <- 60
ReadMargin <- 10

TotalTrainingReadNumber <- 8e07 # change, means 40 mil training read per class.
TotalValidationReadNumber <- 1e07 # change, means 5 mil validation reads per class.
TotalTestReadNumber <- 1e07 # change, means 5 mil test reads per class.
Proportional2GenomeSize <- T

LogTransformation <- F # if True, it will use log10 or natural log
NaturalLog <- F # if True, it will use the natural log instead of log10

pairedEnd <- F
test.pairedEnd <- T

FastaFileLocation <- "/home/nasrif/SCRATCH_NOBAK/allGenomes"
test.FastaFileLocation <- "/home/nasrif/SCRATCH_NOBAK/allGenomes"
TrainingTargetDirectory <- "/home/nasrif/SCRATCH_NOBAK/linearSimulation/trainingReads" # change
ValidationTargetDirectory <- "/home/nasrif/SCRATCH_NOBAK/linearSimulation/validationReads" # change
TestTargetDirectory <- "/home/nasrif/SCRATCH_NOBAK/linearSimulation/testReads" # change
FastaExtension <- "fna"
FilenamePostfixPattern <- ""

HomeFolder <- "/home/nasrif/" # change
ProjectFolder <- "SCRATCH_NOBAK" # change, used as (homefolder+this+IMGfile)
IMGFile <- "allFungi.rds" # change
IMGFile.new <- "allFungi_sizes.rds" # change

if (Do.Clean){
  
  FastaFiles <- system(paste0("find ", file.path(FastaFileLocation), " -type f -name '*", FastaExtension, "'"), intern=T)
  # ignore old temp files
  FastaFiles <- FastaFiles[!grepl("\\.temp\\.", FastaFiles)]
  
  library(foreach)
  cat(paste("###Cleaning###\n"))
  
  Check <- foreach(f = FastaFiles) %do% {
    cat(paste(f, "\n"))
    tempFasta <- sub(paste0("[.]",FastaExtension),paste0(".temp.",FastaExtension),f)
    # 6 std devs in NEAT
    if (pairedEnd){
      min.contig <- MeanFragmentSize + 6 * FragmentStdDev + ReadMargin
    } else {
      min.contig <- ReadLength + ReadMargin
    }
    status = system(paste("bioawk -cfastx '{if(length($seq) > ", min.contig," ) {print \">\"$name \" \" $comment;print $seq}}'",f,">",tempFasta ) )
    
    if(status != 0){
      cat(paste("ERROR\n"))
    }
    if (file.info(tempFasta)$size > 0){
      system(paste("cat", tempFasta, ">", f))
    } else {
      cat(paste0("WARNING: all contigs of ", basename(f), " are shorter than ", min.contig, ". Using the longest contig.\n"))
      status = system(paste("bioawk -cfastx 'length($seq) > max_length {max_length = length($seq); max_name=$name; max_comment=$comment; max_seq = $seq} END{print \">\"max_name \" \" max_comment;print max_seq}'",f,">",tempFasta ) )
      if (file.info(tempFasta)$size > 0){
        system(paste("cat", tempFasta, ">", f))
      } else {
        cat(paste("ERROR\n"))
      }
    }
    file.remove(tempFasta)
  }
  
  test.FastaFiles <- system(paste0("find ", file.path(test.FastaFileLocation), " -type f -name '*", FastaExtension, "'"), intern=T)
  # ignore old temp files
  test.FastaFiles <- test.FastaFiles[!grepl("\\.temp\\.", test.FastaFiles)]
  
  Check <- foreach(f = test.FastaFiles) %do% {
    cat(paste(f, "\n"))
    tempFasta <- sub(paste0("[.]",FastaExtension),paste0(".temp.",FastaExtension),f)
    # 6 std devs in NEAT
    if (test.pairedEnd){
      min.contig <- MeanFragmentSize + 6 * FragmentStdDev + ReadMargin
    } else {
      min.contig <- ReadLength + ReadMargin
    }
    status = system(paste("bioawk -cfastx '{if(length($seq) > ", min.contig," ) {print \">\"$name \" \" $comment;print $seq}}'",f,">",tempFasta ) )
    
    if(status != 0){
      cat(paste("ERROR\n"))
    }
    if (file.info(tempFasta)$size > 0){
      system(paste("cat", tempFasta, ">", f))
    } else {
      cat(paste0("WARNING: all contigs of ", basename(f), " are shorter than ", min.contig, ". Using the longest contig.\n"))
      status = system(paste("bioawk -cfastx 'length($seq) > max_length {max_length = length($seq); max_name=$name; max_comment=$comment; max_seq =     $seq} END{print \">\"max_name \" \" max_comment;print max_seq}'",f,">",tempFasta ) )
      if (file.info(tempFasta)$size > 0){
        system(paste("cat", tempFasta, ">", f))
      } else {
        cat(paste("ERROR\n"))
      }
    }
    file.remove(tempFasta)
  }
  cat(paste("###Cleaning done###\n"))
}

if (Do.GetSizes) {
  IMGdata <- readRDS(file.path(HomeFolder,ProjectFolder,IMGFile))
  calcSize <- function(x){
    if (x$fold1 == "test"){
      file.loc <- test.FastaFileLocation
    }
    if (x$fold1 != "test"){
      file.loc <- FastaFileLocation
    }
    if ((LogTransformation) & (NaturalLog)){
      return (log(as.numeric(system(paste0("find ", file.loc, " -type f -name '", x$assembly_accession, "*' | xargs grep -v \">\" | wc | awk '{print $3-$1}'"), intern=T))))
    }
    if ((LogTransformation) & (!NaturalLog)){
      return (log10(as.numeric(system(paste0("find ", file.loc, " -type f -name '", x$assembly_accession, "*' | xargs grep -v \">\" | wc | awk '{print $3-$1}'"), intern=T))))
    }
    if (!LogTransformation){
      return (as.numeric(system(paste0("find ", file.loc, " -type f -name '", x$assembly_accession, "*' | xargs grep -v \">\" | wc | awk '{print $3-$1}'"), intern=T)))
    }
  }
  
  IMGdata$Genome.Size <- sapply(1:nrow(IMGdata), function(i){calcSize(IMGdata[i,c("assembly_accession", "fold1")])})
  saveRDS(IMGdata, file.path(HomeFolder,ProjectFolder,IMGFile.new))
} else {
  IMGdata <- readRDS(file.path(HomeFolder,ProjectFolder,IMGFile))
}

if (IMG.Sizes) {
  IMGdata$Genome.Size <- as.numeric(IMGdata$Genome.Size.....assembled)
}

if (Do.Balance) {
  TrainingReadNumber <- TotalTrainingReadNumber / 2 # per class across all genomes
  ValidationReadNumber <- TotalValidationReadNumber / 2 # per class across all genomes
  training.Fix.Coverage <- F
  validation.Fix.Coverage <- F
} else {
  TrainingReadNumber <- TotalTrainingReadNumber * ReadLength / sum(IMGdata$Genome.Size[IMGdata$fold1 == "train"]) # coverage
  ValidationReadNumber <- TotalValidationReadNumber * ReadLength / sum(IMGdata$Genome.Size[IMGdata$fold1 == "val"]) # coverage
  training.Fix.Coverage <- T
  validation.Fix.Coverage <- T
}
if (Do.Balance.test) {
  TestReadNumber <- TotalTestReadNumber / 2 # per class across all genomes
  test.Fix.Coverage <- F
} else {
  TestReadNumber <- TotalTestReadNumber * ReadLength / sum(IMGdata$Genome.Size[IMGdata$fold1 == "test"]) # coverage
  test.Fix.Coverage <- T
}

Simulate.Dataset <- function(SetName, ReadNumber, Proportional2GenomeSize, Fix.Coverage, ReadLength, pairedEnd, FastaFileLocation, IMGdata, TargetDirectory, MeanFragmentSize = 600, FragmentStdDev = 60, Workers = 1, Simulator = c("Neat", "Mason", "Mason2"), Cleaned = T, FastaExtension = ".fna", FilenamePostfixPattern = "_", ReadMargin = 10, AllowNsFromGenome = F){
  
  dir.create(file.path(TargetDirectory), showWarnings = FALSE)
  
  GroupMembers <- IMGdata[IMGdata$fold1 == SetName,]
  
  GroupMembers_HP <- which(GroupMembers$human.Hosted)
  GroupMembers_NP <- which(!GroupMembers$human.Hosted)
  if (length(GroupMembers_HP) > 0 ){
    Check.train_HP <- Simulate.Reads.fromMultipleGenomes (Members = GroupMembers_HP, TotalReadNumber = ReadNumber, Proportional2GenomeSize = Proportional2GenomeSize, Fix.Coverage = Fix.Coverage, ReadLength = ReadLength, pairedEnd = pairedEnd, FastaFileLocation = FastaFileLocation, IMGdata = GroupMembers, TargetDirectory = file.path(TargetDirectory, "pathogenic"), FastaExtension = FastaExtension, MeanFragmentSize = MeanFragmentSize, FragmentStdDev = FragmentStdDev, Workers = Workers, Simulator = Simulator, Cleaned = Cleaned, FilenamePostfixPattern = FilenamePostfixPattern, ReadMargin = ReadMargin, AllowNsFromGenome = AllowNsFromGenome)
  }
  if (length(GroupMembers_NP) > 0 ){
    Check.train_NP <- Simulate.Reads.fromMultipleGenomes (Members = GroupMembers_NP, TotalReadNumber = ReadNumber, Proportional2GenomeSize = Proportional2GenomeSize, Fix.Coverage = Fix.Coverage, ReadLength = ReadLength, pairedEnd = pairedEnd, FastaFileLocation = FastaFileLocation, IMGdata = GroupMembers, TargetDirectory = file.path(TargetDirectory, "nonpathogenic"), FastaExtension = FastaExtension, MeanFragmentSize = MeanFragmentSize, FragmentStdDev = FragmentStdDev, Workers = Workers, Simulator = Simulator, Cleaned = Cleaned, FilenamePostfixPattern = FilenamePostfixPattern, ReadMargin = ReadMargin, AllowNsFromGenome = AllowNsFromGenome)
  }
}


# Simulate test reads
if(Do.TestData == T){
  cat("###Simulating test data...###")
  Simulate.Dataset("test", TestReadNumber, Proportional2GenomeSize, test.Fix.Coverage, ReadLength, test.pairedEnd, test.FastaFileLocation, IMGdata, TestTargetDirectory, Workers = Workers, Simulator = Simulator, Cleaned = Cleaned, FastaExtension = FastaExtension, FilenamePostfixPattern = FilenamePostfixPattern, ReadMargin = ReadMargin, AllowNsFromGenome = AllowNsFromGenome)
  cat("###Done!###")
}

# Simulate validation reads
# simulate for each class
if(Do.ValidationData == T){
  cat("###Simulating validation data...###")
  Simulate.Dataset("val", ValidationReadNumber, Proportional2GenomeSize, validation.Fix.Coverage, ReadLength, pairedEnd, FastaFileLocation, IMGdata, ValidationTargetDirectory, Workers = Workers, Simulator = Simulator, Cleaned = Cleaned, FastaExtension = FastaExtension, FilenamePostfixPattern = FilenamePostfixPattern, ReadMargin = ReadMargin, AllowNsFromGenome = AllowNsFromGenome)
  cat("###Done!###")
}

# Simulate training reads
# simulate for each class
if(Do.TrainingData == T){
  cat("###Simulating training data...###")
  Simulate.Dataset("train", TrainingReadNumber, Proportional2GenomeSize, training.Fix.Coverage, ReadLength, pairedEnd, FastaFileLocation, IMGdata, TrainingTargetDirectory, Workers = Workers, Simulator = Simulator, Cleaned = Cleaned, FastaExtension = FastaExtension, FilenamePostfixPattern = FilenamePostfixPattern, ReadMargin = ReadMargin, AllowNsFromGenome = AllowNsFromGenome)
  cat("###Done!###")
}