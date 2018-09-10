#!/usr/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    sink(stderr())
    cat("Usage: scriptName.R -option=value <input.data >pValue
Option:
    -p|pair      Pair
    -a|alt  STR  The alternative hypothesis: [two.sided], greatr or less
    -h           Show help
")
    sink()
    q(save= 'no')
}

myPair = FALSE
myAlt = 'two.sided'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        
        if(arg == '-h') usage()
        
        tmp = parseArg(arg, 'p(air)?', 'pair')
        if(arg == '-p' || arg == '-pair'){
            myPair = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'a(lt)?', 'alt')
        if(!is.null(tmp)){
            myAlt = tmp
            args[i] = NA
            next
        }
    }
}
args = args[!is.na(args)]

if(length(args) >= 2){
    values1 = read.delim(args[1], header = F)[[1]]
    values2 = read.delim(args[2], header = F)[[1]]
}else{
    data = read.delim(file('stdin'), header = F)
    if(length(args) == 1){
      values1 = data[[1]]
      values2 = read.delim(args[1], header = F)[[1]]
    }else{
      values1 = data[[1]]
      values2 = data[[1]]
    }
}

pValue = t.test(values1, values2, paired = myPair, alternative = myAlt)$p.value

write.table(pValue, stdout(), row.names = F, col.names = F)
