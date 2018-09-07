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
    -p|pdf          FILE    The output figure in pdf[figure.pdf]
    -w|width        INT     The figure width
    -m|main         STR     The main title
    -mainS          DOU     The size of main title
    
    -t|transpose            Transpose the input
    -nF|noFull              Whether the segment plots will occupy a full circle or only the (upper) semicircle only
    -s|scale                Scale the columns of the data matrix independently so that 
                            the maximum value in each column is 1 and the minimum is 0
    -nR|noRadius            The radii corresponding to each variable in the data will be drawn
    -l|loc          INTs    Numeric of length 2 when all plots should be superimposed (for a ‘spider plot’)
    -lty            STR     The line type[1]
    -len            DOU     Scale factor for the length of radii or segments[1]
    -k|keyLoc       INTs    X and Y coordinates of the unit key
    -f|flip                 If the label locations should flip up and down from diagram to diagram
    -seg                    Draw a segment diagram
    -h|help                 Show help
")
  q(save='no')
}


myPdf = 'figure.pdf'
mainS = 20
full = TRUE
flip = FALSE

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]

        if(arg == '-t' || arg == '-transpose') transpose = TRUE
        if(arg == '-nF' || arg == '-noFull') full = FALSE
        if(arg == '-s' || arg == '-scale') myScale = TRUE
        if(arg == '-nR' || arg == '-noRadius')  noRadius = TRUE
        tmp = parseArg(arg, 'l(oc)?', 'l')
        if(!is.null(tmp)){
            loc = strsplit(arg, '=', fixed = T)[[1]]
            loc = as.numeric(strsplit(loc[2], ',', fixed = T)[[1]])
        }
        tmp = parseArg(arg, 'lty', 'lty'); if(!is.null(tmp)) lty = tmp
        tmp = parseArgAsNum(arg, 'len', 'len'); if(!is.null(tmp)) len = tmp
        tmp = parseArg(arg, 'k(eyLoc)?', 'l')
        if(!is.null(tmp)){
            keyLoc = strsplit(arg, '=', fixed = T)[[1]]
            keyLoc = as.numeric(strsplit(keyLoc[2], ',', fixed = T)[[1]])
        }
        if(arg == '-f' || arg == '-flip') flip = TRUE
        if(arg == '-seg') segment = TRUE
        
        if(arg == '-h' || arg == '-help') usage()
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgAsNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) width = tmp
        tmp = parseArg(arg, 'm(ain)?', 'm'); if(!is.null(tmp)) main = tmp
        tmp = parseArgAsNum(arg, 'mainS', 'mainS'); if(!is.null(tmp)) mainS = tmp

  }
}
if(exists('width')){
  pdf(myPdf, width = width)
}else{
  pdf(myPdf)
}

data = read.delim(file('stdin'), header = T)
require(grDevices)

if(exists('transpose')) data = t(data)

rownames(data) = data[, 1]

data = data[-1]

data = mtcars[, 1:7]

myCmd = 'stars(data, full = full, flip.labels = flip'

if(exists('myScale')) myCmd = paste0(myCmd, ', scale = TRUE')
if(exists('noRadius')) myCmd = paste0(myCmd, ', radius = FALSE')
if(exists('loc')) myCmd = paste0(myCmd, ', locations = loc')
if(exists('lty')) myCmd = paste0(myCmd, ', lty = lty')
if(exists('len')) myCmd = paste0(myCmd, ', len = len')
if(exists('keyLoc')) myCmd = paste0(myCmd, ', key.loc = keyLoc')
if(exists('segment')) myCmd = paste0(myCmd, ', draw.segments = TRUE')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))
