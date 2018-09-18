#!/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    sink(stderr())
    cat(paste0("Usage: ", scriptName))
    cat(" -option=value <input.lst|input.lst|input1.lst input2.lst >pValue
Options
    -a|alt  STR  The alternative hypothesis ([two.sided], greater, less)
                 You can specify just the initial letter
    -m|mu   DOU  A parameter used to form the null hypothesis for one-sample test[0]
    -h|help      Show help
")
    q(save = 'no')
}

alternative = 'two.sided'
mu = 0

if(length(args) >= 1){
  for(i in 1:length(args)){
    arg = args[i]
    
    if(arg == '-h' || arg == '-help') usage()
    
    tmp = parseArg(arg, 'a(lt)?', 'alt')
    if(!is.null(tmp)){
        alternative = tmp
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

sink(stderr())
cat('Check if the following variables are correct as expected:')
cat('\nalternative\t'); cat(alternative)
cat('\nmu\t'); if(exists('mu')) cat(mu)
cat('\nsample1\t'); if(length(args) >= 1) cat(args[1])
cat('\nsample2\t'); if(length(args) >= 2) cat(args[2])
cat('\n')
sink()

myCmd = 'wilcoxRes = wilcox.test(x = sample1[[1]], alternative = alternative'
if(length(args) >= 2){
    sample1 = read.delim(args[1], header = F)
    sample2 = read.delim(args[2], header = F)
    myCmd = paste0(myCmd, ', y = sample2[[1]]')
}else{
    if(length(args) == 1){
        sample1 = read.delim(args[1], header = F)
    }else{
        sample1 = read.delim(file('stdin'), header = F)
    }
    myCmd = paste0(myCmd, ', mu = mu')
}
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

pValue = wilcoxRes$p.value
cat(pValue); cat('\n')

#write.table(pValues, stdout(), row.names = F, col.names = F)
