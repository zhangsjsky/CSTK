#!/usr/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
suppressMessages(library(Hmisc))

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" <input.tsv >result.tsv
Option:
    -h                              Show help
Input: columns of observed values and predicted values without header
")
    q(save='no')
}

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        if(arg == '-h') usage()
    }
}

data = read.delim(file('stdin'), header = F)

result = rcorr.cens(data$V1, data$V2, outx = F)
result['SE'] = result['S.D.']/2
df = data.frame(result, row.names = names(result))
write.table(df, stdout(), sep = "\t", col.names = F, quote = F)
