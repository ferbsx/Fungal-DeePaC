# Blast comparison
# `BlastComparison.R` runs blast. It assumes a specific directory structure that I inherited from Carlus. For each 
# species, 
# all reads should be in one file (one file per species - basically what read simulation spits out. In your case, you'd 
# have to divide your subsampled fastas accordingly).
# (ignore the use.suppTable = T option and set it to false, it was a viral dataset problem)


# Script by Carlus Deneke, modified by Jakub Bartoszewicz

# special care for the choice of the correct parameters, the default, megablast, aims at aligning nearly identical sequences. 
# Better choices for mismatch/gap penalties are "task -dc-megablast" or "task -blastn"
# see http://www.ncbi.nlm.nih.gov/books/NBK279675/ and http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3848038/

require(stringr, quietly = T)
options(warn=1)

MatchBlastResults2IMG <- function(Blast,IMGdata, groundTruth=F, use.suppTable=F, suppTable=NULL){
  
  
  if(groundTruth == T){
    query_acc <- sapply(strsplit(as.character(Blast$Query),"[/]"), function(x) tail(x,1))
    query_acc <- str_replace(string=query_acc, pattern="\\.fq.*", replacement="")
    # query_acc = Blast$Query as a list, 
    # turning "/home/nasrif/SCRATCH_NOBAK/logSimulation/testReads/nonpathogenic/GCA_000002495.2_MG8_genomic.fq.000002004" into "GCA_000002495.2_MG8_genomic"
    # (the query_acc for each file is just the species name repeated X number of reads or rows), proof: 
    # unique(query_acc)
    
    # map to IMG and extract species and label
    Query2IMG <- match(query_acc,as.character(IMGdata$assembly_accession))
    # the assembly_accession row where query_acc is on
    # unique(Query2IMG)
    
    Query_Species <- as.character(IMGdata$species.name)[Query2IMG]
    # The species name
    # unique(Query_Species)
    
    Query_Label <- IMGdata$human.Hosted[Query2IMG]
    # The species label from DB (True for human pathogenic or positive group, else: False)
    # unique(Query_Label)
    
    # print("in ground")
  }
  # print("in match")
  
  ### HERE: we will extract the accession numbers form the Blast target field, which will have this structure:
  ### Assembly_accession|WGS_accession, for example: GCA_001972265.1|BCHE01000001.1
  ### I used the same trick for bacteria: https://gitlab.com/rki_bioinformatics/DeePaC/-/commit/b8d60a6b28bf7d603eddb86515d2ce08b9e02ecd#46ae82a6e71923a910d1ddaa5b60440a0e211aac
  ### But it got overwritten in the viral script.
  myReferences_acc <- str_replace(string=as.character(Blast$Target), pattern="\\|.*", replacement="")
  # turns "GCA_000193285.1|GL877010.1" into "GCA_000193285.1" and saves them in myReferences_acc
  # This list usually has many different strings:
  # unique(myReferences_acc)
  
  
  ### the following was very much tailored to the viral dataset, so your changes weren't really compatible
  # myReferences_acc <- str_replace(string=as.character(Blast$Target), pattern=".*_", replacement="")
  #myReferences <- str_replace(string=as.character(Blast$Target), pattern="^._", replacement="")
  # if(use.suppTable){
  #  reptable <- read.table(suppTable)
  #  ids_right = as.character(reptable$V2)
  #  names(ids_right) <- as.character(reptable$V1)
  #  myReferences <- ids_right[myReferences]
  # }
  # myReferences_acc <- sapply(1:length(myReferences), function(x){IMGdata[grepl(pattern = myReferences[x], x = IMGdata$tax.id, fixed = T),"assembly_accession"]})
  # print("in match")
  
  for (i in 1:length(myReferences_acc)) {
    if (length(myReferences_acc[[i]]) == 0) {
      # print("yes")
      myReferences_acc[[i]] = factor(NA)
    }
  }
  
  # print("in match")
  # map to IMG and extract species and label
  Match2IMG <- match(unlist(myReferences_acc),as.character(IMGdata$refseq_assembly_accession))
  #
  Matched_Species <- as.character(IMGdata$species.name)[Match2IMG]
  Matched_Label <- IMGdata$human.Hosted[Match2IMG]
  
  # check if multiple alignments
  # which(duplicated(Blast$Query) )
  
  # MultipleAlignments <- grepl("XS",myAlignment[,"Other"])
  
  if(groundTruth == T){
    # print(Blast$Target[1])
    # print(myReferences_acc[1])
    # print("in match")
    
    # print(Matched_Species)
    # print(Matched_Label)
    # print(all(is.na(Matched_Species)))
    # print(all(is.na(Matched_Label)))
    
    # print(Query_Species)
    # print(Query_Label)
    myData <- data.frame(Reference = Blast$Target, assembly_accession = myReferences_acc, MatchedSpecies = Matched_Species, MatchedLabel = Matched_Label, QuerySpecies = Query_Species, QueryLabel = Query_Label)
    # print("in gt")
  } else {
    myData <- data.frame(Reference = Blast$Target, assembly_accession = myReferences_acc, MatchedSpecies = Matched_Species, MatchedLabel = Matched_Label)
  }
  # myData <- data.frame(Reference = myReferences_raw,MultipleAlignments = MultipleAlignments, Bioproject.Accession = myReferences_Bioproject.Accession, MatchedSpecies = Matched_Species, MatchedLabel = Matched_Label)
  
  rownames(myData) <- sapply(strsplit(as.character(Blast$Query),"[/]"), function(x) tail(x,1))
  # print("hello")
  
  return(myData)
}

# HomeFolder <- "~/SCRATCH_NOBAK/Benchmark_virS"
# HomeFolder <- "/home/nasrif/SCRATCH_NOBAK"
# HomeFolder <- "/share/MA_fungi_deepac/data"
HomeFolder <- "C:/Users/ferdous.nasri/share/ubuntuVM/MA_fungi_deepac/data"

# ProjectFolder <-  "logSimulation/benchmarkSub"
ProjectFolder <-  "benchmarkData"
# WorkingDirectory <- "HP_NHP"
# Choose test folder
# ReadType <- "Val_250bp"
# ReadType <- "test_oneSide"
ReadType <- "test_paired"
Fold <- 1


# IMGdata <- readRDS(file.path(HomeFolder,ProjectFolder,"VHDB_all.rds") )
IMGdata <- readRDS(file.path(HomeFolder,"allBlastFungi.rds") )
# suppTable: Not used for fungi
# suppTable = "/home/nasrif/SCRATCH_NOBAK/blastrepair/ids_tab"
use.suppTable = F

# Set to true if you don't have a built library on all your training genomes (/home/nasrif/SCRATCH_NOBAK/Blast/AllTrainingGenomes_fold1)
Do.BuildDB <- F

# Folder containing all training (positive and negative class) genomes including a file named AllTrainingGenomes_fold*.fasta where * is `Fold`
TrainingFastaGenomesFolder <- HomeFolder
# TrainingFastaGenomesFolder <- "../share/ubuntuVM/MA_fungi_deepac/data"
Do.RunBlast <- F

Do.ProcessBlast <- T
# Switch for All Strain DB
# This would only make a difference if you had multiple strains per species. (Fungal data don't, hence F.)
Do.AllStrains <- F

# multi core
# Cores = 100
Cores = 2

# --------------------------------------------------------------------------
# load libraries functions and databases

require(foreach, quietly = T)

# Set path

# TestFolders_all <- list.dirs(file.path(HomeFolder,ProjectFolder,"OtherData",WorkingDirectory,"testData","Reads"),recursive = F, full.names = F)
TestFolders_all <- list.dirs(file.path(HomeFolder,ProjectFolder),recursive = F, full.names = F)
TestFolders_all <- grep(ReadType,TestFolders_all,value = T)
TestReadFolder <- grep(paste("fold",Fold,sep=""),TestFolders_all, value = T)
# Finds the path to this folder: "Home/Project/fold1_Left_250bp"

# Path2TestFiles <- file.path(HomeFolder,ProjectFolder,"OtherData",WorkingDirectory,"testData","Reads",TestReadFolder)
Path2TestFiles <- file.path(HomeFolder,ProjectFolder,TestReadFolder)



if(Cores > 1) {
  library(doParallel)
  registerDoParallel(Cores)
}


# --------------------------------------------------------------------------
# create blast database

# load all training genomes:

# DBdir <- file.path(HomeFolder,ProjectFolder,"OtherData",WorkingDirectory,"Benchmark","Blast")
# DBdir <- file.path(HomeFolder,ProjectFolder, "Blast")
DBdir <- file.path(HomeFolder,"Blast")
# this file is where some output will be in (it shouldn't already exist)
dir.create(DBdir, showWarnings=T) # Ferdous changed to T

if(Do.BuildDB == T){
  
  # GenomeFastas <- list.files(file.path(HomeFolder,ProjectFolder,"OtherData",WorkingDirectory,"Benchmark"), full.names = T, pattern = "fasta" )
  # GenomeFastas <- list.files(file.path(HomeFolder, ProjectFolder, "trainingReads", "pathogenic"), full.names = T, pattern = "fasta" )
  GenomeFastas <- list.files(TrainingFastaGenomesFolder, full.names = T, pattern = "fasta" )
  
  if(Do.AllStrains == T) {
    GenomeFasta_selected <- grep("AllStrains",GenomeFastas,value = T)
    DBTitle <- "AllStrains"
    DBOutput <- file.path(DBdir,paste("AllStrains_fold",Fold, sep=""))
  } else {
    GenomeFasta_selected <- grep("AllTrainingGenomes",GenomeFastas,value = T)
    DBTitle <- "AllTrainingGenomes"
    DBOutput <- file.path(DBdir,paste("AllTrainingGenomes_fold",Fold, sep=""))
  }
  GenomeFasta_selected <- grep(paste("fold",Fold,sep=""),GenomeFasta_selected, value=T)
  
  if(length(GenomeFasta_selected) != 1) stop(paste("No Genomes fasta file found in", TrainingFastaGenomesFolder, "for library building"))
  
  Time <- system.time( system(paste("makeblastdb -in",GenomeFasta_selected,"-input_type fasta -dbtype nucl -title",DBTitle,"-out",DBOutput) ) )
  
  print(paste("Blast library building took",paste(round(summary(Time),1),collapse=";"),"s"))
}



# --------------------------------------------------------------------------
# run blast


if(Do.AllStrains == T) {
  DBOutput <- file.path(DBdir,paste("AllStrains_fold",Fold, sep=""))
  MappingFolder <- "AllStrains"
} else {
  DBOutput <- file.path(DBdir,paste("AllTrainingGenomes_fold",Fold,sep=""))
  # "/share/MA_fungi_deepac/data/Blast/AllTrainingGenomes_fold1"
  MappingFolder <- "AllTrainingGenomes"
}

dir.create(file.path(Path2TestFiles,"Blast"))
# "Home/Project/test/fold1_Left_250bp/Blast"

# abort if exists already
dir.create(file.path(Path2TestFiles,"Blast",MappingFolder))
# "Home/Project/test/fold1_Left_250bp/Blast/AllTrainingGenomes/"

# write log
LogFile <- file.path(Path2TestFiles,"Blast",MappingFolder,"Log.txt")
sink(file = file.path(Path2TestFiles,"Blast",MappingFolder,"ScreenOutput.txt"), append = T, type = "output", split = T)


if(Do.RunBlast ==T) {
  
  # find all read files
  ReadFiles <- list.files(Path2TestFiles,pattern="fa$",full.names = T)
  
  write(paste("Starting blast alignment on",Sys.time()),file = LogFile, append = F)
  print(paste("New run on",date()))
  
  # Options
  Options <- "-task dc-megablast" # for inter-species comparisons
  # Options <- "-task blastn" # the traditional program used for inter-species comparisons
  
  # loop over all read files
  
  StartTime <- proc.time()
  
  Check <-  foreach(i = 1:length(ReadFiles)) %do% {
    print(paste("Processing item",i,":",ReadFiles[i]))
    
    InFile <- ReadFiles[i]
    OutFile <- file.path(Path2TestFiles,"Blast",MappingFolder,sub("fa","blast",tail(strsplit(ReadFiles[i],"[/]")[[1]],1)) )
    
    Time <- system.time( system(paste("blastn -outfmt 6 -max_target_seqs 1 -num_threads ",Cores, " ", Options,"-db",DBOutput,"-query",InFile,"-out",OutFile) ) )
    write(paste("Blast alignment of file",InFile,"took",paste(round(summary(Time),1),collapse=";"),"s"),file = LogFile, append = T)
    
    return(file.exists(OutFile))
  }
  
  EndTime <- proc.time()
  
  print(paste("Blast alignment took",(EndTime[3]-StartTime[3])/60,"min") )
  # "Blast alignment took 1270.35155 min" (Ferdous, Test one sided)
  print("---Finito")
  
}

# ==========================================
# Blast Processing

if(Do.ProcessBlast == T) {
  # load functions
  BlastFiles <- list.files(file.path(Path2TestFiles,"Blast",MappingFolder),pattern = "blast$", full.names = T)
  
  StartTime <- proc.time()
  
  Check <- foreach(i = 1:length(BlastFiles)) %do% {
    
    print(paste("Processing file",i))
    
    Time1 <- proc.time()
    
    Blast <- read.table(BlastFiles[i])
    colnames(Blast) <- c("Query","Target","PercentIdentity","Alignment_length","mismatches","gap_opens","query_Start","query_End","target_Start","target_End","Evalue","BitScore")
    
    # remove secondary hits
    Dups <- which(duplicated(Blast$Query))
    if(length(Dups>0)) { 
      Blast <- Blast[-Dups,]
    }
    
    # print("hello after if")
    # Match to IMG
    Blast_matched <- MatchBlastResults2IMG (Blast= Blast,IMGdata = IMGdata, T, use.suppTable, suppTable)
    
    # print("hello blas")
    # print(Blast_matched)
    
    Time <- proc.time() - Time1
    write(paste("Blast analysis of file",BlastFiles[i],"took",paste(round(summary(Time),1),collapse=";"),"s"),file = LogFile, append = T)
    # 3.00878333333333 min for one side of test data
    
    saveRDS(Blast_matched,sub("[.]blast","_matched.rds",BlastFiles[i]))
    
    print(file.exists(sub("[.]blast","_matched.rds",BlastFiles[i])) )
    
    return(file.exists(sub("[.]blast","_matched.rds",BlastFiles[i]))  )
    
  }
  
  EndTime <- proc.time()
  
  print(paste("Blast Analysis took",(EndTime[3]-StartTime[3])/60,"min") )
  
  
}
warnings()
sink()







