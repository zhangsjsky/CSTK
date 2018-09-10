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

data = read.delim(file('stdin'), header = T)

cor = cor(data)

colNames = colnames(data)

cat("Category\t")
write.table(cor, stdout(), row.names = T, col.names = T, sep = "\t", quote = F)

