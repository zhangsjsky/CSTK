#!/usr/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    sink(stderr())
    cat(paste0("Usage: ", scriptName))
    cat(" -option=value <input.lst|<input1.lst input2.lst|input1.lst input2.lst >pValue
Note: When date are input only form STDIN, the data will be compare with -mu.
      E.g.: run with '-mu=0 <input.lst'
Option:
    -p|pair      Pair
    -a|alt  STR  The alternative hypothesis: [two.sided], greatr or less
    -m|mu   DOU  A number indicating the true value of the mean
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
        tmp = parseArgNum(arg, 'm(u)?', 'mu')
        if(!is.null(tmp)){
            mu = tmp
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
    }
}

if(length(args) == 0){
    pValue = t.test(values1, mu=mu, paired = myPair, alternative = myAlt)$p.value
}else{
    if(length(values1) == 1) values1=rep(values1[1], 2)
    if(length(values2) == 1) values2=rep(values2[1], 2)
    pValue = t.test(values1, values2, paired = myPair, alternative = myAlt)$p.value
}

write.table(pValue, stdout(), row.names = F, col.names = F)
