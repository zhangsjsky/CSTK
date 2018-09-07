#!/bin/env Rscript
args <- commandArgs(TRUE)

usage = function(){
  cat('Usage: scriptName.R -option=value <input.data >pValue\n',file=stderr())
  cat('Option:\n',file=stderr())
  cat('\t-d\tSTR\tDistribution (pnorm, punif, etc)[pnorm]\n',file=stderr())
  cat('\t-h\t\tShow help\n',file=stderr())
  q(save='no')
}

distr='pnorm'

if(length(args) >= 1){
  for(i in 1:length(args)){
    arg=args[i]
    if(arg == '-h'){
      usage()
    }
    if(grepl('^-d', arg)){
      arg.split = strsplit(arg, '=', fixed = T)[[1]]
      if(is.na(arg.split[2])){
        stop('Please specify the value of -d')
      }else{
        distr=arg.split[2]
      }
    }
  }
}

data = read.delim(file('stdin'), header = F)

fun = function(x){
  x = x[!is.na(x)]
  x = x + runif(length(x), -min(x)/100000, min(x)/100000)
  ks.test(x, distr, min(x), max(x))$p.value
}

pValues = apply(data, 1, fun)
write.table(pValues, stdout(), row.names=F, col.names=F)
