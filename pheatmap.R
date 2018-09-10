#!/usr/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
library(pheatmap)

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf <input.tsv
Example for input.tsv (with Col1 as row names):
Y\\X    Individual1  Individual2
Gene1  10           11
Gene2  20           30
Option:
    -p|pdf        FILE  The output figure in pdf[pheatmap.pdf]
    -w|width      INT   The figure width
    -height       INT   The figure height
      
    -m|main       STR   The main title

    -header             With header
    -rower              With row names

    -log          DOU   Log transform all original value
    -add          DOU   Add value to all original value (priority to -log)
    
     
    -noClusterR         Don't cluster rows
    -noClusterC         Don't cluster columns
    -method       STR   Clustering method ([complete], ...)
    -distanceR    STR   Distance measure used in clustering rows ([euclidean], correlation, ...)
    -distanceC    STR   Distance measure used in clustering cols ([euclidean], correlation, ...)
    -s|scale      STR   Scale values in which direction (row, column, [none])
    -annoR        TSV   Annotation for row. The file must include header (will be used as annotation name) as the first line and row names as the first column, e.g:
                          rowName  Type    Expression
                          Gene1    Coding  10
                          Gene2    lncRNA  20
                        These row names must match with the row names in the input.tsv
    -annoC        TSV   Similar to -annoC, but for columns, e.g:
                          rowName  Age  Gender
                          Individual1  18  Male
                          Individual2  20  Female
                        These row names must match with the header in the input.tsv
    -d|displayNum       Display number in the cell

    -colorL       COL   Color for low value(e.g. white)
    -colorH       COL   Color for high value(e.g. navy)
    -colorN       INT   The continual colar mapping tile number[100]
    -noRowName          Don't show row names
    -noColName          Don't show column names
    -cexR         DOU   The row font size (>=0.5)
    -cexC         DOU   The col font size (>=0.5)
    -borderColor  COL   Color of cell borders([grey60], NA, ...)
    -treeHeightR  DOU   The height of a tree for rows[50]
    -treeHeightC  DOU   The height of a tree for column[50]
    -cexN         DOU   Fontsize of the numbers displayed in cells[8]
    -h|help             Show help
")
    q(save = 'no')
}

myPdf = 'pheatmap.pdf'
mainS = 20
header = FALSE
clusterR = TRUE
clusterC = TRUE
method = 'complete'
distanceR = 'euclidean'
distanceC = 'euclidean'
myScale = 'none'
displayNum = FALSE
colorN = 100
showRowName = TRUE
showColName = TRUE
borderColor = 'grey60'
treeHeightR = 50
treeHeightC = 50

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        if(arg == '-h' || arg == '-help') usage()
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) width = tmp
        tmp = parseArgNum(arg, 'height', 'height'); if(!is.null(tmp)) height = tmp
        
        tmp = parseArg(arg, 'm(ain)?', 'm'); if(!is.null(tmp)) main = tmp
        #tmp = parseArgNum(arg, 'mainS', 'mainS'); if(!is.null(tmp)) mainS = tmp
        
        if(arg == '-header') header = TRUE
        if(arg == '-rower') rower = TRUE
        
        tmp = parseArgNum(arg, 'add', 'add'); if(!is.null(tmp)) add = tmp
        tmp = parseArgNum(arg, 'log', 'log'); if(!is.null(tmp)) logBase = tmp
        
        if(arg == '-noClusterR') clusterR = FALSE
        if(arg == '-noClusterC') clusterC = FALSE
        tmp = parseArg(arg, 'method', 'method'); if(!is.null(tmp)) method = tmp
        tmp = parseArg(arg, 'distanceR', 'distanceR'); if(!is.null(tmp)) distanceR = tmp
        tmp = parseArg(arg, 'distanceC', 'distanceC'); if(!is.null(tmp)) distanceC = tmp
        tmp = parseArg(arg, 's(cale)?', 'scale'); if(!is.null(tmp)) myScale = tmp
        tmp = parseArg(arg, 'annoR', 'annoR'); if(!is.null(tmp)) annoR = tmp
        tmp = parseArg(arg, 'annoC', 'annoC'); if(!is.null(tmp)) annoC = tmp
        if(arg == '-d' || arg == '-displayNum') displayNum = TRUE
        
        tmp = parseArg(arg, 'colorL', 'colorL'); if(!is.null(tmp)) colorL = tmp
        tmp = parseArg(arg, 'colorH', 'colorH'); if(!is.null(tmp)) colorH = tmp
        tmp = parseArgNum(arg, 'colorN', 'colorN'); if(!is.null(tmp)) colorN = tmp
        if(arg == '-noRowName') showRowName = FALSE
        if(arg == '-noColName') showColName = FALSE
        tmp = parseArgNum(arg, 'cexR', 'cexR'); if(!is.null(tmp)) cexR = tmp
        tmp = parseArgNum(arg, 'cexC', 'cexC'); if(!is.null(tmp)) cexC = tmp
        tmp = parseArg(arg, 'borderColor', 'borderColor'); if(!is.null(tmp)) borderColor = tmp
        tmp = parseArgNum(arg, 'treeHeightR', 'treeHeightR'); if(!is.null(tmp)) treeHeightR = tmp
        tmp = parseArgNum(arg, 'treeHeightC', 'treeHeightC'); if(!is.null(tmp)) treeHeightC = tmp
        tmp = parseArgNum(arg, 'cexN', 'cexN'); if(!is.null(tmp)) cexN = tmp
    }
}

cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:'))
cat('\npdf\t'); cat(myPdf)
cat('\nwidth\t'); if(exists('width')) cat(width)
cat('\nheight\t'); if(exists('height')) cat(height)
cat('\nmain\t'); if(exists('main')) cat(main)
#cat('\nmainS\t'); cat(mainS)
cat('\nheader\t'); cat(header)
cat('\nrower\t'); if(exists('rower')) cat(rower)
cat('\nadd\t'); if(exists('add')) cat(add)
cat('\nlog\t'); if(exists('logBase')) cat(logBase)
cat('\nclusterR\t'); cat(clusterR)
cat('\nclusterC\t'); cat(clusterC)
cat('\nmethod\t'); cat(method)
cat('\ndistanceR\t'); cat(distanceR)
cat('\ndistanceC\t'); cat(distanceC)
cat('\nscale\t'); cat(myScale)
cat('\ndisplayNum\t'); cat(displayNum)
cat('\nannoR\t'); if(exists('annoR')) cat(annoR)
cat('\nannoC\t'); if(exists('annoC')) cat(annoC)
cat('\ncolorL\t'); if(exists('colorL')) cat(colorL)
cat('\ncolorH\t'); if(exists('colorH')) cat(colorH)
cat('\ncolorN\t'); cat(colorN)
cat('\nshowRowName\t'); cat(showRowName)
cat('\nshowColName\t'); cat(showColName)
cat('\ncexR\t'); if(exists('cexR')) cat(cexR)
cat('\ncexC\t'); if(exists('cexC')) cat(cexC)
cat('\nborderColor\t'); cat(borderColor)
cat('\ntreeHeightR\t'); cat(treeHeightR)
cat('\ntreeHeightC\t'); cat(treeHeightC)
cat('\ncexN\t'); if(exists('cexN')) cat(cexN)
cat('\n')

myCmd = 'pdf(myPdf, onefile=F'
if(exists('width')) myCmd = paste0(myCmd, ', width = width')
if(exists('height')) myCmd = paste0(myCmd, ', height = height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))


if(exists('rower')){
    data = read.delim(file('stdin'), header = header, check.names = F, row.names = 1)
}else{
    data = read.delim(file('stdin'), header = header, check.names = F)
}
m = as.matrix(data)
if(exists('add')) m = m + add
if(exists('logBase')) m = log(m, base = logBase)

myCmd = 'pheatmap(m, cluster_rows = clusterR, cluster_cols = clusterC, clustering_method = method, clustering_distance_rows = distanceR, clustering_distance_cols = distanceC, scale = myScale, display_numbers = displayNum, show_rownames = showRowName, show_colnames = showColName, border_color = borderColor, treeheight_row = treeHeightR, treeheight_col = treeHeightC'

#if(exists('witdth')) myCmd = paste0(myCmd, ', width = width')
if(exists('main')) myCmd = paste0(myCmd, ', main = main')

if(exists('annoR')){
    annoR = read.delim(annoR, header = TRUE, check.names = F)
    rownames(annoR) = annoR[[1]]
    annoR = annoR[-1]
    myCmd = paste0(myCmd, ', annotation_row = annoR')
}
if(exists('annoC')){
    annoC = read.delim(annoC, header = TRUE, check.names = F)
    rownames(annoC) = gsub('-', '.', annoC[[1]])
    annoC = annoC[-1]
    myCmd = paste0(myCmd, ', annotation_col = annoC')
}

if(exists('colorL') && exists('colorH')){
    color = colorRampPalette(c(colorL, colorH))(colorN)
    myCmd = paste0(myCmd, ', color = color')
}
if(exists('cexR')) myCmd = paste0(myCmd, ', fontsize_row = cexR')
if(exists('cexC')) myCmd = paste0(myCmd, ', fontsize_col = cexC')
if(exists('cexN')) myCmd = paste0(myCmd, ', fontsize_number = cexN')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))