#!/usr/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
library(NMF)

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf <input.tsv
input.tsv is a table with column names and row names. E.g.:
  Sample1	Sample2
  Gene1	350	220
  Gene2	313	264
Option:
  Output:
    -p|pdf          FILE       The output figure in pdf[figure.pdf]
    -w|width        INT        The pdf width[12]
       height       INT        The pdf height
  Efficiency:
    -t|thread       INT        The thread[1]
  Tool:
    -r|rank         INTs       The comma-separated factorization rank[2,3,4,5,6]
    -a|algorithm    STR        The NMF algorithm: ([brunet], lee, nsNMF, offset, pe-nmf, snmf/r, snmf/l)
    -s|seed         STR/INT    The seed method: (random, none, ica, nndsvd)
                               Default is the random with 123456 as initiation number
  Other:
    -h|help                    Show help
")
    q(save = 'no')
}

myPdf = 'figure.pdf'
myWidth = 12
thread = 1
rank = 2:6
algorithm = 'brunet'
seed = 123456

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgAsNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) myWidth = tmp
        tmp = parseArgAsNum(arg, 'height', 'height'); if(!is.null(tmp)) height = tmp
        tmp = parseArgAsNum(arg, 't(hread)?', 't'); if(!is.null(tmp)) thread = tmp
        tmp = parseArgNums(arg, 'r(ank)?', 'r'); if(!is.null(tmp)) rank = tmp
        tmp = parseArg(arg, 'a(lgorithm)?', 'a'); if(!is.null(tmp)) algorithm = tmp
        tmp = parseArg(arg, 's(eed)?', 's'); if(!is.null(tmp)) seed = tmp
        if(arg == '-h' || arg == '-help') usage()
    }
}

myCmd = 'pdf(myPdf'
if(exists('myWidth')) myCmd = paste0(myCmd, ', width = myWidth')
if(exists('height')) myCmd = paste0(myCmd, ', height = height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

data = read.delim(file('stdin'))
#data(esGolub)
#esGolub = esGolub[1:200,]
#esGolub$Sample = NULL
#data = esGolub

options = paste0('vtp', thread)

myCmd = 'res = nmf(data, rank, algorithm, seed, .opt = options'
if(is.numeric(seed)) myCmd = paste0(myCmd, ', nrun = 150')
myCmd = paste0(myCmd, ')')

cat(paste0('[INFO] ', Sys.time(), ' Start NMF...\n'))
eval(parse(text = myCmd))
cat(paste0('[INFO] ', Sys.time(), ' Finish NMF\n'))

cat('Summary:\n')
summary(res)
#summary(res, target = data)

plot(res)

if(length(rank) == 1){
    cat('fit:\n')
    fit(res)
    
    cat('featureScore:\n')
    s = featureScore(res)
    summary(s)

    cat('extractFeatures:\n')
    s = extractFeatures(res)
    str(s)

    layout(cbind(1,2))
    basismap(res, subsetRow = TRUE)
    coefmap(res)

    V.hat = fitted(res)
    w = basis(res)
    h = coef(res)
}

layout(1)
consensusmap(res)
#consensusmap(res, annCol = data)
