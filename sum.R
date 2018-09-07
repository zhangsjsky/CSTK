#!/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf <input.tsv >summarized.tsv
Summary results will be output in order of mean, quantiles
Option:
    -b|by           1/2     1: summarize all values in each row
                            2: summarize all values in each column
    -s|skip         INTs    Skip rows/columns when summarizing
    -m|mean                 Summarize mean
    -q|quantiles    DOUs    The quantiles in range of 0 to 1
    -tp|transpose           Transpose the output
    -h|help                 Show help
")
    q(save = 'no')
}

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        tmp = parseArgAsNum(arg, 'b(y)?', 'b'); if(!is.null(tmp)) by = tmp
        tmp = parseArg(arg, 's(kip)?', 's'); if(!is.null(tmp)) skip = as.numeric(strsplit(tmp, ',', fixed = T)[[1]])
        if(arg == '-m' || arg == '-mean') myMean = TRUE
        tmp = parseArg(arg, 'q(uantile)?', 'q'); if(!is.null(tmp)) quantiles = as.numeric(strsplit(tmp, ',', fixed = T)[[1]])
        if(arg == '-tp' || arg == '-transpose') tp = TRUE
        if(arg == '-h' || arg == '-help') usage()
    }
}
data = read.delim(file('stdin'), header = F)

if(by == 1){
    if(exists('skip')){
        Rs = data[skip]
        toSumData = data[-skip]
    }else{
        Rs = data.frame(dumy = 1:nrow(data))
        toSumData = data
    }
    if(exists('myMean')) Rs = cbind(Rs, mean = apply(toSumData, by, mean))
    if(exists('quantiles')) Rs = cbind(Rs, t(apply(toSumData, by, function(x){quantile(x, probs=quantiles)})))
    Rs = cbind(Rs, toSumData)
    if(!exists('skip')) Rs = Rs[-1]
}else{
    if(exists('skip')){
        Rs = data[skip, ]
        toSumData = data[-skip, ]
    }else{
        Rs = data.frame()
        toSumData = data
    }
    if(exists('myMean')) Rs = rbind(Rs, t(apply(toSumData, by, mean)))
    if(exists('quantiles')){
        if(length(quantiles) == 1){
            Rs = rbind(Rs, t(apply(toSumData, by, function(x){quantile(x, probs=quantiles)})))
        }else{
            Rs = rbind(Rs, apply(toSumData, by, function(x){quantile(x, probs=quantiles)}))
        }
    }
    Rs = rbind(Rs, toSumData)
}
if(exists('tp')) Rs = t(Rs)

Rs = as.data.frame(Rs)
write.table(Rs, stdout(), row.names = F, col.names = F, sep = "\t", quote = F)
