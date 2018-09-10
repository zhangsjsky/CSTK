#!/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf <input.tsv
Option:
    Common:
    -m|-method  pearson             Which correlation coefficient to computed[spearman]
                spearman/kendall
    -h                              Show help
")
  q(save='no')
}

myPdf = 'correlation.pdf'
myMethod = 'spearman'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        if(arg == '-h') usage()
        tmp = parseArg(arg, 'm(ethod)?', 'm'); if(!is.null(tmp)) myMethod = tmp
    }
}

data = read.delim(file('stdin'), header = T, check.names = F)

attach(data)

colNames = colnames(data)
colNum = length(colNames)

res = data.frame()

for(i in 1:(colNum-1)){
    for(j in (i+1):colNum){
        corr = round(cor(data[i], data[j], method = myMethod), 3)
        cat(paste0(colNames[i], "\t", colNames[j], "\t", corr, "\n"))
    }
}
