# `BlastPerformance.R` calculates per-read performance, correcting for missing predictions (blast gives no info if it 
# doesn't find a match, so you have to tell the script manually how many reads there should be).

# Val_250bp_fold1
# P <- 125000
# N <- 125000


# 5000023 (all one sided test)
P <- 2500010
N <- 2500013

# P should be equal to the number of pathogenic read pairs (so the same as number of pathogenic "left" reads and pathogenic "right" reads). 
# N should be equal to the number of nonpathogenic pairs.

    
sra <- F
Paired <- T
SetName <- "ReadByRead"
# Path.L <- "C:/Users/ferdous.nasri/share/ubuntuVM/MA_fungi_deepac/data/benchmarkData/Val_250bp_fold1/Blast/"
Path.L <- "C:/Users/ferdous.nasri/share/ubuntuVM/MA_fungi_deepac/data/benchmarkData/test_oneSide_fold1/Blast/"
# Path.L <- "/home/nasrif/SCRATCH_NOBAK/logSimulation/benchmarkSub/Val_250bp_fold1/Blast/"

# Path.R <- "SCRATCH_NOBAK/Benchmark_ROGAL/PathogenReads/OtherData/HP_NHP/testData/Reads/TempoRight_250bp_fold1/Blast/"
Path.R <- "C:/Users/ferdous.nasri/share/ubuntuVM/MA_fungi_deepac/data/benchmarkData/test_paired_fold1/Blast/"

# Path.NP <- "C:/Users/ferdous.nasri/share/ubuntuVM/MA_fungi_deepac/data/benchmarkData/Val_250bp_fold1/"

accept.anything <- Vectorize(function (x,y) {
    if (is.na(x)) return (y)
    if (is.na(y)) return (x)
    if (x==!y) return (NA)
    if (x==y) return (x)
})

get.performance <- function (prediction, y, P=0, N=0) {
    TP <- sum(prediction==T & y==T)
    TN <- sum(prediction==F & y==F)    
    FP <- sum(prediction==T & y==F)    
    FN <- sum(prediction==F & y==T)
    
    if (P<0) P = TP + FN
    if (N<0) N = TN + FP
    
    # sensitivity or true positive rate / recall (TPR)
    sensitivity = TP/(TP+FN)
    #specificity
    specificity = TN/(TN+FP)
    # precision
    precision = TP/(TP+FP)
    # accuracy (ACC)
    ACC = (TP + TN) / (TP + FP + FN + TN)
    # F1 score
    F1 = 2 * precision * sensitivity / (precision + sensitivity)
    # MCC
    MCC_denominator <- sqrt( ( as.numeric(TP)+ FP) * (as.numeric(TP) +  FN ) * (  as.numeric(TN) +  FP ) * (  as.numeric(TN) +  FN ) )
    if(MCC_denominator == 0) MCC_denominator <- 1
    MCC = (as.numeric(TP) * TN - as.numeric(FP) * FN) / MCC_denominator
    
    # sensitivity or true positive rate / recall (TPR)
    total.sensitivity = TP/P
    # specificity
    total.specificity = TN/N
    # precision
    total.precision = precision
    # accuracy (ACC)
    total.ACC = (TP + TN) / (P + N)
    # F1 score
    total.F1 = 2 * total.precision * total.sensitivity / (total.precision + total.sensitivity)
    # MCC
    total.MCC = MCC
    
    predictions = length(prediction)/(P+N)
    
    return(data.frame(TPR = sensitivity, TNR=specificity,PPV = precision, ACC = ACC, F1 = F1, MCC = MCC, total.TPR = total.sensitivity, total.TNR=total.specificity,total.PPV = total.precision, total.ACC = total.ACC, total.F1 = total.F1, total.MCC = total.MCC, predictions = predictions))
}

# for (trainingSet in c("AllTrainingGenomes", "AllStrains")){
trainingSet <- "AllTrainingGenomes"
file.paths <- list.files(path = paste0(Path.L, trainingSet), pattern = "matched\\.rds$", full.names = T)
file.data <- lapply(file.paths, readRDS)
merged.L <- do.call("rbind", file.data)
merged.L$read <- rownames(merged.L)
if (sra){
    merged.L$read <- gsub('.$', '', merged.L$read)
    merged.L$QuerySpecies = "SRA"
}

if (Paired){
    file.paths <- list.files(path = paste0(Path.R, trainingSet), pattern = "matched\\.rds$", full.names = T)
    file.data <- lapply(file.paths, readRDS)
    merged.R <- do.call("rbind", file.data)    
    merged.R$read <- rownames(merged.R)
    
    if (sra){
        merged.R$read <- gsub('.$', '', merged.R$read)
        merged.R$QuerySpecies = "SRA"
    }
    merged.join <- merge(merged.L, merged.R, by = "read", all = TRUE, suffixes = c(".L", ".R"))

    merged.join$QuerySpecies <- merged.join$QuerySpecies.L
    merged.join$QuerySpecies[is.na(merged.join$QuerySpecies)] <- merged.join$QuerySpecies.R[is.na(merged.join$QuerySpecies)]
    merged.join$QueryLabel <- merged.join$QueryLabel.L
    merged.join$QueryLabel[is.na(merged.join$QueryLabel)] <- merged.join$QueryLabel.R[is.na(merged.join$QueryLabel)] 
    merged.join$Prediction <- accept.anything(merged.join$MatchedLabel.L, merged.join$MatchedLabel.R)   
    merged.pred <- merged.join[!is.na(merged.join$Prediction),] 
}

test.L <- get.performance(merged.L$MatchedLabel[!is.na(merged.L$MatchedLabel)], 
                          merged.L$QueryLabel[!is.na(merged.L$MatchedLabel)], 
                          P, 
                          N)

if (Paired){
    test.R <- get.performance(merged.R$MatchedLabel[!is.na(merged.R$MatchedLabel)], 
                              merged.R$QueryLabel[!is.na(merged.R$MatchedLabel)], 
                              P, 
                              N)
    test <- get.performance(merged.pred$Prediction, merged.pred$QueryLabel, P, N)    
    results <- do.call("rbind", list(test.L,test.R,test))  
    rownames(results) <- c("test.L","test.R","test")
} else {
    results <- test.L
    rownames(results) <- c("test.L")
}
write.csv2(results, file = paste0(Path.R, "Blast_",SetName,"_", trainingSet, ".csv"))    
# }

# df_NP <- readRDS(file.path(Path.NP,"blastPerformanceNPVal.rds") )

