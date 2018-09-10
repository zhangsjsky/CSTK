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
Option:
  Input:
    -header                With header
    -rower                 With row names.
                           If the input is standard R talbe (e.g. output of write.table with rowname and colname is TRUE), 
                           DON'T specifiy this option because the rower is auto recognized.
  Output:
    -p|pdf         FILE    The output figure in pdf[figure.pdf]
    -w|width       INT     The figure width
    -m|main        STR     The main title
    -mainS         DOU     The size of main title
  Tool:
    -d|distance    STR     The distance method ([euclidean], manhattan, )
    -l|linkage     STR     The linkage method ([complete], average)
    -s|scale       STR     Scale data values:
                             row:
                             col:
                             r1: each row sum up to 1
                             c1: each col sum up to 1
    -noClusterR            Don't cluster rows
    -noClusterC            Don't cluster columns
    -colAnnoN1     DOUs    Comma-separated column numeric annotation 1
    -colAnnoC1     STRs    Comma-separated column categoric annotation 1
    -rowAnnoN1     DOUs    Comma-separated row numeric annotation 1
    -rowAnnoC1     STRs    Comma-separated row categoric annotation 1
  Aesthetics:
    -colorL        COL     Color for low value(e.g. navy)
    -colorM        COL     Color for medium value(e.g. white)
    -colorH        COL     Color for high value(e.g. firebrick3)
    -colorN        INT     The continual colar mapping tile number[100]
    -cellW         INT     Cell width
    -cellH         INT     Cell height
    -fontS         DOU     The font size
    -noLegend              Don't show legend
  Other:
    -h|help                Show help
")
    q(save = 'no')
}

myPdf = 'figure.pdf'
mainS = 20
header = FALSE
distance = 'euclidean'
linkage = 'complete'
colorN = 100
legend = TRUE

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        
        if(arg == '-header') header = TRUE
        if(arg == '-rower') rower = TRUE
        
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgAsNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) myWidth = tmp
        tmp = parseArg(arg, 'm(ain)?', 'm'); if(!is.null(tmp)) main = tmp
        tmp = parseArgAsNum(arg, 'mainS', 'mainS'); if(!is.null(tmp)) mainS = tmp
        
        tmp = parseArg(arg, 'd(istance)?', 'd'); if(!is.null(tmp)) distance = tmp
        tmp = parseArg(arg, 'l(inkage)?', 'l'); if(!is.null(tmp)) linkage = tmp
        tmp = parseArg(arg, 's(cale)?', 's'); if(!is.null(tmp)) myScale = tmp
        if(arg == '-noClusterR') clusterR = FALSE
        if(arg == '-noClusterC') clusterC = FALSE
        tmp = parseArgNums(arg, 'colAnnoN1', 'colAnnoN1'); if(!is.null(tmp)) colAnnoN1 = tmp
        tmp = parseArgStrs(arg, 'colAnnoC1', 'colAnnoC1'); if(!is.null(tmp)) colAnnoC1 = tmp
        tmp = parseArgNums(arg, 'rowAnnoN1', 'rowAnnoN1'); if(!is.null(tmp)) rowAnnoN1 = tmp
        tmp = parseArgStrs(arg, 'rowAnnoC1', 'rowAnnoC1'); if(!is.null(tmp)) rowAnnoC1 = tmp
        
        tmp = parseArg(arg, 'colorL', 'colorL'); if(!is.null(tmp)) colorL = tmp
        tmp = parseArg(arg, 'colorM', 'colorM'); if(!is.null(tmp)) colorM = tmp
        tmp = parseArg(arg, 'colorH', 'colorH'); if(!is.null(tmp)) colorH = tmp
        tmp = parseArgAsNum(arg, 'colorN', 'colorN'); if(!is.null(tmp)) colorN = tmp
        tmp = parseArgAsNum(arg, 'cellW', 'cellW'); if(!is.null(tmp)) cellWidth = tmp
        tmp = parseArgAsNum(arg, 'cellH', 'cellH'); if(!is.null(tmp)) cellHeght = tmp
        tmp = parseArgAsNum(arg, 'fontS', 'fontS'); if(!is.null(tmp)) fontSize = tmp
        if(arg == '-noLegend') legend = FALSE
        
        if(arg == '-h' || arg == '-help') usage()
    }
}

data = read.delim(file('stdin'), header = header)

myCmd = 'pdf(myPdf'
if(exists('myWidth')) myCmd = paste0(myCmd, ', width = myWidth')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

if(exists('rower')){
    m = as.matrix(data[-1])
    rownames(m) = data[[1]]
}else{
    m = as.matrix(data)
}

if(exists('clusterR')){
    Rowv = NA
}else{
    Rowv = c(distance, linkage)
}
if(exists('clusterC')){
    Colv = NA
}else{
    Colv = c(distance, linkage)
}
if(exists('colorL') && exists('colorH')){
    if(exists('colorM')){
        color = colorRampPalette(c(colorL, colorM, colorH))(colorN)
    }else{
        color = colorRampPalette(c(colorL, colorH))(colorN)
    }
}

colAnno = list()
if(exists('colAnnoN1')) colAnno = c(colAnno, list(Num1 = colAnnoN1))
if(exists('colAnnoC1')) colAnno = c(colAnno, list(Cat1 = factor(colAnnoC1)))
rowAnno = list()
if(exists('rowAnnoN1')) rowAnno = c(rowAnno, list(Num1 = rowAnnoN1))
if(exists('rowAnnoC1')) rowAnno = c(rowAnno, list(Cat1 = factor(rowAnnoC1)))

myCmd = "aheatmap(m, Rowv = Rowv, Colv = Colv, legend = legend"
if(exists('cellWidth')) myCmd = paste0(myCmd, ', cellwidth = cellWidth')
if(exists('cellHeight')) myCmd = paste0(myCmd, ', cellheight = cellHeight')
if(exists('fontSize')) myCmd = paste0(myCmd, ', fontsize = fontSize')
if(exists('myScale')) myCmd = paste0(myCmd, ', scale = myScale')
if(exists('color')) myCmd = paste0(myCmd, ', color = color')
if(length(colAnno) > 0) myCmd = paste0(myCmd, ', annCol = colAnno')
if(length(rowAnno) > 0) myCmd = paste0(myCmd, ', annRow = rowAnno')
if(exists('main')) myCmd = paste0(myCmd, ', main = main')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))
