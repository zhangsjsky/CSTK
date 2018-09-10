#!/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    sink(stderr())
    cat("Usage: scriptName.R -option=value <input.data >pValueWithEstimatedOddRatio.tsv
Options
    -a|alt  STR  Indicates the alternative hypothesis ([two.sided], greater, less)
                 You can specify just the initial letter
    -h           Show help
Note: each set of the four numbers should be place in each column by the order of
      -------------------------
      1      |      3    
      -------------------------
      2      |      4    
      -------------------------
")
    q(save = 'no')
}

alternative = 'two.sided'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        
        tmp = parseArg(arg, 'a(lt)?', 'alt'); if(!is.null(tmp)) alternative = tmp
        
        if(arg == '-h') usage()
    }
}

data = read.delim(file('stdin'), header = F)

fun = function(x){
    m = matrix(x, nrow = 2)
    result = fisher.test(m, alternative = alternative)
    c(result$p.value, result$estimate)
}

pValues = t(apply(data, 1, fun))
write.table(pValues, stdout(), row.names = F, col.names = F)
