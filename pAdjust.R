#!/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    sink(stderr())
    cat("Usage: scriptName.R -option=value <input.tsv >result.tsv
Option:
    -m|method  STR  correction method.  Can be abbreviated. (holm, hochberg, hommel, bonferroni, BH, BY, [fdr], none)
                    You can specify just the initial letter
    -i|index   INT  The column index (1-based start) of p-values in input.tsv[1]
    -h|help         Show help
Output:
    Adjusted p-values will be appended to the last column of the input
")
    q(save = 'no')
}

method = 'fdr'
pIndex = 1

if(length(args) >= 1){
    for(i in 1:length(args)){
      arg = args[i]
    
      tmp = parseArg(arg, 'm(ethod)?', 'method'); if(!is.null(tmp)) method = tmp
      tmp = parseArgNum(arg, 'i(ndex)?', 'index'); if(!is.null(tmp)) pIndex = tmp
      
      if(arg == '-h' || arg == '-help') usage()
    }
}
sink(stderr())
cat('Check if the following variables are correct as expected:')
cat('\nmethod\t'); cat(method)
cat('\npIndex\t'); cat(pIndex)
cat('\n')
sink()

data = read.delim(file('stdin'), header = F)

adjustedPs = p.adjust(data[[pIndex]], method = method)

write.table(cbind(data, adjustedPs), stdout(), row.names = F, col.names = F, quote = FALSE, sep = "\t")
