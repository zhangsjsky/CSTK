#!/usr/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
suppressPackageStartupMessages(library('gplots'))

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf <input.tsv
Option:
    Common:
    -p|pdf      FILE    The output figure in pdf[heatmap2.pdf]
    -w|width    INT     The figure width
    -m|main     STR     The main title
    -mainS      DOU     The size of main title
    -header             With header
    -rower              With row names
    -h|help             Show help
    
    heatmap specific:
    -t|trace    STR     The trace
    -k|key      STR     The key title
    -cexR       DOU     The row cex[1]
    -cexC       DOU     The col cex[1]
    -strR       DOU     Angle of row labels, in degrees from horizontal
    -strC       DOU     Angle of column labels, in degrees from horizontal
    -offsetR    DOU     The offset between row labels and the edge of the plotting region[0.5]
    -offsetC    DOU     The offset between column labels and the edge of the plotting region[0.5]
")
    q(save = 'no')
}

myPdf = 'heatmap2.pdf'
mainS = 20

header = FALSE
trace = 'none'
key = NA
cexR = 1
cexC = 1
strR = NULL
strC = NULL
offsetR = 0.5
offsetC = 0.5

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        if(arg == '-h' || arg == '-help') usage()
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) width = tmp
        tmp = parseArg(arg, 'm(ain)?', 'm'); if(!is.null(tmp)) main = tmp
        tmp = parseArgNum(arg, 'mainS', 'mainS'); if(!is.null(tmp)) mainS = tmp
        if(arg == '-header') header = TRUE
        if(arg == '-rower') rower = TRUE
        tmp = parseArg(arg, 't(race)?', 't'); if(!is.null(tmp)) trace = tmp
        tmp = parseArg(arg, 'k(ey)?', 'k'); if(!is.null(tmp)) key = tmp
        tmp = parseArgNum(arg, 'cexR', 'cexR'); if(!is.null(tmp)) cexR = tmp
        tmp = parseArgNum(arg, 'cexC', 'cexC'); if(!is.null(tmp)) cexC = tmp
        tmp = parseArgNum(arg, 'strR', 'strR'); if(!is.null(tmp)) strR = tmp
        tmp = parseArgNum(arg, 'strC', 'strC'); if(!is.null(tmp)) strC = tmp
        tmp = parseArgNum(arg, 'offsetR', 'offsetR'); if(!is.null(tmp)) offsetR = tmp
        tmp = parseArgNum(arg, 'offsetC', 'offsetC'); if(!is.null(tmp)) offsetC = tmp
    }
}

data = read.delim(file('stdin'), header = header)

if(exists('width')){
    pdf(myPdf, width = width)
}else{
    pdf(myPdf)
}

if(exists('rower')){
    m = as.matrix(data[-1])
    rownames(m) = data[[1]]
}else{
    m = as.matrix(data)
}

heatmap.2(m, trace = trace, key.title = key, cexRow = cexR, cexCol = cexC, strRow = strR, strCol = strC, 
                                             offsetRow = offsetR, offsetCol = offsetC)
