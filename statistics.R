#!/bin/env Rscript

args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf <input.tsv >statistics.tsv
Option:
    -d|direction  STR   R: summarize all values in each row
                        C: summarize all values in each column

    -s|sum              Summary
    -m|mean             Mean
    -sd                 Standard deviation
    -v|variance         Variance
    -q|quantile   DOUs  The quantiles in range of 0 to 1

    -r|rower            With row names (in the first column)
       header           With column name (in the first line)
    -h|help             Show help
")
    q(save = 'no')
}

header = FALSE

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        tmp = parseArg(arg, 'd(irection)?', 'd'); if(!is.null(tmp)) direction = tmp
        
        if(arg == '-s' || arg == '-sum') mySum = TRUE
        if(arg == '-m' || arg == '-mean') myMean = TRUE
        if(arg == '-sd') SD = TRUE
        if(arg == '-v' || arg == '-variance') variance = TRUE
        tmp = parseArgNums(arg, 'q(uantile)?', 'q'); if(!is.null(tmp)) quantiles = tmp
        if(arg == '-r' || arg == '-rower') rower = TRUE
        if(arg == '-header') header = TRUE
        if(arg == '-h' || arg == '-help') usage()
    }
}

sink(stderr())
cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:'))
cat('\ndirection\t'); cat(direction)
cat('\nsum\t'); if(exists('mySum')) cat(mySum)
cat('\nmean\t'); if(exists('myMean')) cat(myMean)
cat('\nsd\t'); if(exists('SD')) cat(SD)
cat('\nvariance\t'); if(exists('variance')) cat(variance)
cat('\nquantile\t'); if(exists('quantiles')) cat(quantiles)
cat('\nrower\t'); if(exists('rower')) cat(rower)
cat('\nheader\t'); if(exists('header')) cat(header)
cat('\n')
sink()

data = read.delim(file('stdin'), header = header, check.names = F)
showColName = FALSE
if(exists('rower')){
    rownames(data) = data[[1]]
    data = data[-1]
    showColName = TRUE
}

quantileFun = function(x){
    quantile(x, probs = quantiles)
}

by = ifelse(direction == 'R', 1, 2)
statDF = data.frame()
if(exists('mySum')){
    sumMat = t(apply(data, by, sum))
    rownames(sumMat) = "Sum"
    statDF = rbind(statDF, sumMat)
}
if(exists('myMean')){
    meanMat = t(apply(data, by, mean))
    rownames(meanMat) = "Mean"
    statDF = rbind(statDF, meanMat)
}
if(exists('SD')){
    sdMat = t(apply(data, by, sd))
    rownames(sdMat) = "SD"
    statDF = rbind(statDF, sdMat)
}
if(exists('variance')){
    varMat = t(apply(data, by, var))
    rownames(varMat) = "Variance"
    statDF = rbind(statDF, varMat)
}
if(exists('quantiles')){
    if(length(quantiles) == 1){
        quantileMat = t(apply(data, by, quantileFun))
    }else{
        quantileMat = apply(data, by, quantileFun)
    }
    rownames(quantileMat) = paste0("Quantile", quantiles)
    statDF = rbind(statDF, quantileMat)
}

if(direction == 'R'){
    colnames(statDF) = rownames(data)
}else{
    colnames(statDF) = colnames(data)
}

write.table(statDF, stdout(), row.names = T, col.names = showColName, sep = "\t", quote = F)
