#!/bin/env Rscript

args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
suppressMessages(library(ComplexHeatmap))
suppressMessages(library(circlize))

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf input.tsv[ input2.tsv ...]
Tsv file must include column and row names, e.g:
    C1  C2  C3
    R1  -0.5  1.2  -1.0
    R2  -0.2  0.3  -0.2
    R3  1.55  0.4  -1.0
Option:
    -p|pdf    FILE  The output figure in pdf[complexHeatmap.pdf]
    -w|width  INT   The figure width
    -height   INT   The figure height
    
    NOTE: The following options are for the first heatmap (if there are multiple heatmaps)
    -colTitle         STR  Column title
    -colTitleSide     STR  Put column title on which side([top],bottom)
    -colTitleSize     DOU  The font size of column title[15]
    -colTitleFace     STR  The font face of column title(bold)
    -colTitleRot      INT  Rotation for column title(0,90,180,270)
    -colTitleCol      STR  Column title color[black]
    -colTitleFill     STR  Color to fill the background of column title
    -colTitleBorder   STR  Color of background border of column title
    
    -colNoName             Don't show column name
    -colNameSide      STR  Put column name on which side([top],bottom)
    -colNameSize      DOU  The font size of column name
    -colNameCol       STR  Column name color[black]
    -colNameCenter         Align column name centered
    -colNameRot       DOU  Rotation for column name
    
    -colNotCluster         Don't do column cluster
    -colNoDend             Don't show column dendrogram
    -colDendSide      STR  Put column dendrogram on which side([top],bottom)
    -colDendHeight    DOU  Height of column dendrogram in cm unit[1]
    -colClusterDis    STR  Distance method for column cluster(pearson,spearman,kendall)
    -colDendCol       STR  Color of column dendrogram line
    -colDendNotReorder     Don't reorder column dendrogram
    -colSplitKmeans   INT  Split column cluster to INT group by k-means
    -colSplitCutree   INT  Split column cluster to INT group by cutree
    -colSplitGap      DOU  Gap between column slices in mm unit
    
    -colBlock                  STR  Add column block annotation with the specified STR as name.
                                    Block number is specified by -colSplitKmeans
    -colBox                    STR  Add column boxplot annotation with the specified STR as name
    -colBoxNoOutlier                Don't show outlier for column boxplot annotation
    -colHist                   STR  Add column histogram annotation with the specified STR as name
    -colHistBreak              INT  Set column histogram annotation with INT breaks[11]
    -colDensity                STR  Add column density annotation with the specified STR as name
    -colDensityType            STR  Draw column density annotation as specified type(violin, heatmap)
    -colJoy                    STR  Add column joyplot annotation with the specified STR as name
    -colSimpleAnnoSize         DOU  Height of each column simple annotation in cm unit(not work currently, don't know why)
    -colAnnoNameSide           STR  Put the column mean simple annotation name on which side(left, [right])
    -colMeanSimple             STR  Add column mean simple annotation with the specified STR as name
    -colMeanSimpleHeight       DOU  Column mean simple annotation height in cm unit[0.5]
    -colMeanSimpleLegendTitle  STR  Column mean simple annotation legend title[-colMeanSimple]
    -colMeanSimpleLegendAt     INTs Column mean simple annotation legend tick values
    -colMeanSimpleLegendLabel  INTs Column mean simple annotation legend labels
    -colMeanSimpleLegendDir    STR  Column mean simple annotation legend direction(horizontal,[vertical])
    -colMeanPoint              STR  Add column mean point annotation with the specified STR as name
    -colMeanLine               STR  Add column mean line annotation with the specified STR as name
    -colMeanLineSmooth              Draw column mean line annotation with loess smooth(May interupt the process with error in predLoess())
    -colMeanBar                STR  Add column mean barplot annotation with the specified STR as name
    -colMeanText                    Add column mean text annotation
    NOTE: for all annotations, their names must be different
    
    -rowTitle         STR  Row title
    -rowTitleSide     STR  Put row title on which side([left],right)
    -rowTitleSize     DOU  The font size of row title[15]
    -rowTitleFace     STR  The font face of row title(bold)
    -rowTitleRot      INT  Rotation for row title(0,90,180,270)
    -rowTitleCol      STR  Row title color[black]
    -rowTitleFill     STR  Color to fill the background of row title
    -rowTitleBorder   STR  Color of background border of row title
    
    -rowNoName             Don't show row name
    -rowNameSide      STR  Put row name on which side([left],right)
    -rowNameSize      DOU  The font size of row name
    -rowNameCol       STR  Column name color[black]
    -rowNameCenter         Align row name centered
    -rowNameRot       DOU  Rotation for row name
    
    -rowNotCluster         Don't do row cluster
    -rowNoDend             Don't show row dendrogram
    -rowDendSide      STR  Put row dendrogram on which side([left],right)
    -rowDendWidth     DOU  Width of row dendrogram in cm unit[1]
    -rowClusterDis    STR  Distance method for row cluster(pearson,spearman,kendall)
    -rowDendCol       STR  Color of row dendrogram line
    -rowDendNotReorder     Don't reorder row dendrogram
    -rowSplitKmeans   INT  Split row cluster to INT group by k-means
    -rowSplitCutree   INT  Split row cluster to INT group by cutree
    -rowSplitGap      DOU  Gap between row slices in mm unit
    
    -rowBlock             STR  Add row block annotation with the specified STR as name.
                               Block number is specified by -rowSplitKmeans
    -rowBox               STR  Add row boxplot annotation with the specified STR as name
    -rowBoxNoOutlier           Don't show outlier for row boxplot annotation
    -rowHist              STR  Add row histogram annotation with the specified STR as name
    -rowHistBreak         INT  Set row histogram annotation with INT breaks[11]
    -rowDensity           STR  Add row density annotation with the specified STR as name
    -rowDensityType       STR  Draw row density annotation as specified type(violin, heatmap)
    -rowJoy               STR  Add row joyplot annotation with the specified STR as name
    -rowSimpleAnnoSize    DOU  Width of each row simple annotation in cm unit(not work currently, don't know why)
    -rowAnnoNameSide      STR  Put the row mean simple annotation name on which side(top, [bottom])
    -rowMeanSimple        STR  Add row mean simple annotation with the specified STR as name
    -rowMeanSimpleWidth   DOU  Row mean simple annotation width in cm unit[0.5]
    -rowMeanPoint         STR  Add row mean point annotation with the specified STR as name
    -rowMeanLine          STR  Add row mean line annotation with the specified STR as name
    -rowMeanLineSmooth         Draw row mean line annotation with loess smooth(May interupt the process with error in predLoess())
    -rowMeanBar           STR  Add row mean barplot annotation with the specified STR as name
    -rowMeanText               Add row mean text annotation
    NOTE: for all annotations, their names must be different
    
    -htLegendTitle     STR   Heatmap legend title[matrix_1]
    -htLegendAt        INTs  Heatmap legend tick values
    -htLegendLabel     STRs  Heatmap legend tick labels
    -htLegendHeight    DOU   Heatmap legend height in cm unit
    -htLegendTitlePos  STR   Heatmap legend title position(topleft,topcenter,lefttop-rot,leftcenter-rot)
    -htLegendColorBar        Discrete color mapping legend
    -htLegendDir       STR   Heatmap legend direction(horizontal,[vertical])
    -htLegendSide      STR   Put heatmap legend on which side(left,[right],top,bottom)
    
    -annoLegendSide    STR   Put annotation legends on which side(left,[right],top,bottom)
    
    -NAcol            STR  Color for NA value in cell
    -border           STR  Color of heatmap body border
    -rectGp           STR  Color of the border of the grids in the heatmap
    -showValueInCell       Show each value of the input data in each cell
    
    -densityHt              Draw heatmap as density heatmap
    -ylim             DOUs  Y limit for density heatmap
    -ylab             STR   Y label for density heatmap[Value]
    -mcCore           INT   Calculate the pairwise Kolmogorov-Smirnov distance in INT cores parallelly

    NOTE: The following options are for the heatmap list
    -verticalConcat              Concatenate each heatmap vertically
    -mainHeatmap            INT  Take which heatmap as main[1]
    -figureColTitle         STR  The column name for the whole heatmap list
    -figureRowTitle         STR  The row name for the whole heatmap list
    -heatmapGap             DOU  The space between heatmaps in cm unit
    -figureRowDendSide      STR  Put row dendrogram on which side([left],right)
    -figureRowSubTitleSide  STR  Put row subtitle on which side(left,right)
    -noAutoAdjust                Show row/column names of all heatmaps
    
    -h|help  Show help
")
    q(save = 'no')
}

myPdf = 'complexHeatmap.pdf'
colTitleCol = 'black'
colNameCol = 'black'
colNotCluster = FALSE
rowTitleCol = 'black'
rowNameCol = 'black'
ylab = 'Value'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        if(arg == '-h' || arg == '-help') usage()
        tmp = parseArg(arg, 'p(df)?', 'p')
        if(!is.null(tmp)){
            myPdf  = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'w(idth)?', 'w')
        if(!is.null(tmp)){
            width = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'height', 'height')
        if(!is.null(tmp)){
            height = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colTitle', 'colTitle')
        if(!is.null(tmp)){
            colTitle = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colTitleSide', 'colTitleSide')
        if(!is.null(tmp)){
            colTitleSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'colTitleSize', 'colTitleSize')
        if(!is.null(tmp)){
            colTitleSize = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colTitleFace', 'colTitleFace')
        if(!is.null(tmp)){
            colTitleFace = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'colTitleRot', 'colTitleRot')
        if(!is.null(tmp)){
            colTitleRot = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colTitleCol', 'colTitleCol')
        if(!is.null(tmp)){
            colTitleCol = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colTitleFill', 'colTitleFill')
        if(!is.null(tmp)){
            colTitleFill = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colTitleBorder', 'colTitleBorder')
        if(!is.null(tmp)){
            colTitleBorder = tmp
            args[i] = NA
            next
        }
        if(arg == '-colNoName'){
            colNoName = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colNameSide', 'colNameSide')
        if(!is.null(tmp)){
            colNameSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'colNameSize', 'colNameSize')
        if(!is.null(tmp)){
            colNameSize = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colNameCol', 'colNameCol')
        if(!is.null(tmp)){
            colNameCol = tmp
            args[i] = NA
            next
        }
        if(arg == '-colNameCenter'){
            colNameCenter = TRUE
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'colNameRot', 'colNameRot')
        if(!is.null(tmp)){
            colNameRot = tmp
            args[i] = NA
            next
        }
        if(arg == '-colNotCluster'){
            colNotCluster = TRUE
            args[i] = NA
            next
        }
        if(arg == '-colNoDend'){
            colNoDend = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colDendSide', 'colDendSide')
        if(!is.null(tmp)){
            colDendSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colDendHeight', 'colDendHeight')
        if(!is.null(tmp)){
            colDendHeight = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colClusterDis', 'colClusterDis')
        if(!is.null(tmp)){
            colClusterDis = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colDendCol', 'colDendCol')
        if(!is.null(tmp)){
            colDendCol = tmp
            args[i] = NA
            next
        }
        if(arg == '-colDendNotReorder'){
            colDendNotReorder = TRUE
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'colSplitKmeans', 'colSplitKmeans')
        if(!is.null(tmp)){
            colSplitKmeans = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'colSplitCutree', 'colSplitCutree')
        if(!is.null(tmp)){
            colSplitCutree = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'colSplitGap', 'colSplitGap')
        if(!is.null(tmp)){
            colSplitGap = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colBlock', 'colBlock')
        if(!is.null(tmp)){
            colBlock = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colBox', 'colBox')
        if(!is.null(tmp)){
            colBox = tmp
            args[i] = NA
            next
        }
        if(arg == '-colBoxNoOutlier'){
            colBoxNoOutlier = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colHist', 'colHist')
        if(!is.null(tmp)){
            colHist = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'colHistBreak', 'colHistBreak')
        if(!is.null(tmp)){
            colHistBreak = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colDensity', 'colDensity')
        if(!is.null(tmp)){
            colDensity = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colDensityType', 'colDensityType')
        if(!is.null(tmp)){
            colDensityType = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colJoy', 'colJoy')
        if(!is.null(tmp)){
            colJoy = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'colSimpleAnnoSize', 'colSimpleAnnoSize')
        if(!is.null(tmp)){
            colSimpleAnnoSize = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colMeanSimple', 'colMeanSimple')
        if(!is.null(tmp)){
            colMeanSimple = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'colMeanSimpleHeight', 'colMeanSimpleHeight')
        if(!is.null(tmp)){
            colMeanSimpleHeight = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colMeanSimpleLegendTitle', 'colMeanSimpleLegendTitle')
        if(!is.null(tmp)){
            colMeanSimpleLegendTitle = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNums(arg, 'colMeanSimpleLegendAt', 'colMeanSimpleLegendAt')
        if(!is.null(tmp)){
            colMeanSimpleLegendAt = tmp
            args[i] = NA
            next
        }
        tmp = parseArgStrs(arg, 'colMeanSimpleLegendLabel', 'colMeanSimpleLegendLabel')
        if(!is.null(tmp)){
            colMeanSimpleLegendLabel = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colMeanSimpleLegendDir', 'colMeanSimpleLegendDir')
        if(!is.null(tmp)){
            colMeanSimpleLegendDir = tmp
            args[i] = NA
            next
        }
        if(arg == '-colMeanSimpleValue'){
            colMeanSimpleValue = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colMeanPoint', 'colMeanPoint')
        if(!is.null(tmp)){
            colMeanPoint = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colMeanLine', 'colMeanLine')
        if(!is.null(tmp)){
            colMeanLine = tmp
            args[i] = NA
            next
        }
        if(arg == '-colMeanLineSmooth'){
            colMeanLineSmooth = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'colMeanBar', 'colMeanBar')
        if(!is.null(tmp)){
            colMeanBar = tmp
            args[i] = NA
            next
        }
        if(arg == '-colMeanText'){
            colMeanText = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowTitle', 'rowTitle')
        if(!is.null(tmp)){
            rowTitle = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowTitleSide', 'rowTitleSide')
        if(!is.null(tmp)){
            rowTitleSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rowTitleSize', 'rowTitleSize')
        if(!is.null(tmp)){
            rowTitleSize = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowTitleFace', 'rowTitleFace')
        if(!is.null(tmp)){
            rowTitleFace = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rowTitleRot', 'rowTitleRot')
        if(!is.null(tmp)){
            rowTitleRot = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowTitleCol', 'rowTitleCol')
        if(!is.null(tmp)){
            rowTitleCol = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowTitleFill', 'rowTitleFill')
        if(!is.null(tmp)){
            rowTitleFill = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowTitleBorder', 'rowTitleBorder')
        if(!is.null(tmp)){
            rowTitleBorder = tmp
            args[i] = NA
            next
        }
        if(arg == '-rowNoName'){
            rowNoName = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowNameSide', 'rowNameSide')
        if(!is.null(tmp)){
            rowNameSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rowNameSize', 'rowNameSize')
        if(!is.null(tmp)){
            rowNameSize = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowNameCol', 'rowNameCol')
        if(!is.null(tmp)){
            rowNameCol = tmp
            args[i] = NA
            next
        }
        if(arg == '-rowNameCenter'){
            rowNameCenter = TRUE
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rowNameRot', 'rowNameRot')
        if(!is.null(tmp)){
            rowNameRot = tmp
            args[i] = NA
            next
        }
        if(arg == '-rowNotCluster'){
            rowNotCluster = TRUE
            args[i] = NA
            next
        }
        if(arg == '-rowNoDend'){
            rowNoDend = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowDendSide', 'rowDendSide')
        if(!is.null(tmp)){
            rowDendSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowDendWidth', 'rowDendWidth')
        if(!is.null(tmp)){
            rowDendWidth = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowClusterDis', 'rowClusterDis')
        if(!is.null(tmp)){
            rowClusterDis = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowDendCol', 'rowDendCol')
        if(!is.null(tmp)){
            rowDendCol = tmp
            args[i] = NA
            next
        }
        if(arg == '-rowDendNotReorder'){
            rowDendNotReorder = TRUE
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rowSplitKmeans', 'rowSplitKmeans')
        if(!is.null(tmp)){
            rowSplitKmeans = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rowSplitCutree', 'rowSplitCutree')
        if(!is.null(tmp)){
            rowSplitCutree = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rowSplitGap', 'rowSplitGap')
        if(!is.null(tmp)){
            rowSplitGap = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowBlock', 'rowBlock')
        if(!is.null(tmp)){
            rowBlock = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowBox', 'rowBox')
        if(!is.null(tmp)){
            rowBox = tmp
            args[i] = NA
            next
        }
        if(arg == '-rowBoxNoOutlier'){
            rowBoxNoOutlier = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowHist', 'rowHist')
        if(!is.null(tmp)){
            rowHist = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rowHistBreak', 'rowHistBreak')
        if(!is.null(tmp)){
            rowHistBreak = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowDensity', 'rowDensity')
        if(!is.null(tmp)){
            rowDensity = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowDensityType', 'rowDensityType')
        if(!is.null(tmp)){
            rowDensityType = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowJoy', 'rowJoy')
        if(!is.null(tmp)){
            rowJoy = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rowSimpleAnnoSize', 'rowSimpleAnnoSize')
        if(!is.null(tmp)){
            rowSimpleAnnoSize = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowMeanSimple', 'rowMeanSimple')
        if(!is.null(tmp)){
            rowMeanSimple = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rowMeanSimpleWidth', 'rowMeanSimpleWidth')
        if(!is.null(tmp)){
            rowMeanSimpleWidth = tmp
            args[i] = NA
            next
        }
        if(arg == '-rowMeanSimpleValue'){
            rowMeanSimpleValue = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowMeanPoint', 'rowMeanPoint')
        if(!is.null(tmp)){
            rowMeanPoint = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowMeanLine', 'rowMeanLine')
        if(!is.null(tmp)){
            rowMeanLine = tmp
            args[i] = NA
            next
        }
        if(arg == '-rowMeanLineSmooth'){
            rowMeanLineSmooth = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowMeanBar', 'rowMeanBar')
        if(!is.null(tmp)){
            rowMeanBar = tmp
            args[i] = NA
            next
        }
        if(arg == '-rowMeanText'){
            rowMeanText = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'htLegendTitle', 'htLegendTitle')
        if(!is.null(tmp)){
            htLegendTitle = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNums(arg, 'htLegendAt', 'htLegendAt')
        if(!is.null(tmp)){
            htLegendAt = tmp
            args[i] = NA
            next
        }
        tmp = parseArgStrs(arg, 'htLegendLabel', 'htLegendLabel')
        if(!is.null(tmp)){
            htLegendLabel = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'htLegendHeight', 'htLegendHeight')
        if(!is.null(tmp)){
            htLegendHeight = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'htLegendTitlePos', 'htLegendTitlePos')
        if(!is.null(tmp)){
            htLegendTitlePos = tmp
            args[i] = NA
            next
        }
        if(arg == '-htLegendColorBar'){
            htLegendColorBar = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'htLegendDir', 'htLegendDir')
        if(!is.null(tmp)){
            htLegendDir = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'htLegendSide', 'htLegendSide')
        if(!is.null(tmp)){
            htLegendSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'annoLegendSide', 'annoLegendSide')
        if(!is.null(tmp)){
            annoLegendSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'NAcol', 'NAcol')
        if(!is.null(tmp)){
            NAcol = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'border', 'border')
        if(!is.null(tmp)){
            border = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rectGp', 'rectGp')
        if(!is.null(tmp)){
            rectGp = tmp
            args[i] = NA
            next
        }
        if(arg == '-showValueInCell'){
            showValueInCell = TRUE
            args[i] = NA
            next
        }
        if(arg == '-densityHt'){
            densityHt = TRUE
            args[i] = NA
            next
        }
        tmp = parseArgNums(arg, 'ylim', 'ylim')
        if(!is.null(tmp)){
            ylim = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'ylab', 'ylab')
        if(!is.null(tmp)){
            ylab = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'mcCore', 'mcCore')
        if(!is.null(tmp)){
            mcCore = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'concatDirection', 'concatDirection')
        if(!is.null(tmp)){
            concatDirection = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'mainHeatmap', 'mainHeatmap')
        if(!is.null(tmp)){
            mainHeatmap = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'figureColTitle', 'figureColTitle')
        if(!is.null(tmp)){
            figureColTitle = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'figureRowTitle', 'figureRowTitle')
        if(!is.null(tmp)){
            figureRowTitle = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'heatmapGap', 'heatmapGap')
        if(!is.null(tmp)){
            heatmapGap = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'figureRowDendSide', 'figureRowDendSide')
        if(!is.null(tmp)){
            figureRowDendSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'figureRowSubTitleSide', 'figureRowSubTitleSide')
        if(!is.null(tmp)){
            figureRowTitle = tmp
            args[i] = NA
            next
        }
        if(arg == '-noAutoAdjust'){
            noAutoAdjust = TRUE
            args[i] = NA
            next
        }
    }
}
args = args[!is.na(args)]
if(length(args) == 0) stop('Please specify input file!')

cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:'))
cat('\npdf\t'); cat(myPdf)
cat('\nwidth\t'); if(exists('width')) cat(width)
cat('\nheight\t'); if(exists('height')) cat(height)
cat('\ncolTitle\t'); if(exists('colTitle')) cat(colTitle)
cat('\ncolTitleSide\t'); if(exists('colTitleSide')) cat(colTitleSide)
cat('\ncolTitleSize\t'); if(exists('colTitleSize')) cat(colTitleSize)
cat('\ncolTitleFace\t'); if(exists('colTitleFace')) cat(colTitleFace)
cat('\ncolTitleRot\t'); if(exists('colTitleRot')) cat(colTitleRot)
cat('\ncolTitleCol\t'); if(exists('colTitleCol')) cat(colTitleCol)
cat('\ncolTitleFill\t'); if(exists('colTitleFill')) cat(colTitleFill)
cat('\ncolTitleBorder\t'); if(exists('colTitleBorder')) cat(colTitleBorder)
cat('\ncolNoName\t'); if(exists('colNoName')) cat(colNoName)
cat('\ncolNameSide\t'); if(exists('colNameSide')) cat(colNameSide)
cat('\ncolNameSize\t'); if(exists('colNameSize')) cat(colNameSize)
cat('\ncolNameCol\t'); if(exists('colNameCol')) cat(colNameCol)
cat('\ncolNameCenter\t'); if(exists('colNameCenter')) cat(colNameCenter)
cat('\ncolNameRot\t'); if(exists('colNameRot')) cat(colNameRot)
cat('\ncolNotCluster\t'); cat(colNotCluster)
cat('\ncolNoDend\t'); if(exists('colNoDend')) cat(colNoDend)
cat('\ncolDendSide\t'); if(exists('colDendSide')) cat(colDendSide)
cat('\ncolDendHeight\t'); if(exists('colDendHeight')) cat(colDendHeight)
cat('\ncolClusterDis\t'); if(exists('colClusterDis')) cat(colClusterDis)
cat('\ncolDendCol\t'); if(exists('colDendCol')) cat(colDendCol)
cat('\ncolDendNotReorder\t'); if(exists('colDendNotReorder')) cat(colDendNotReorder)
cat('\ncolSplitKmeans\t'); if(exists('colSplitKmeans')) cat(colSplitKmeans)
cat('\ncolSplitCutree\t'); if(exists('colSplitCutree')) cat(colSplitCutree)
cat('\ncolSplitGap\t'); if(exists('colSplitGap')) cat(colSplitGap)
cat('\ncolBlock\t'); if(exists('colBlock')) cat(colBlock)
cat('\ncolBox\t'); if(exists('colBox')) cat(colBox)
cat('\ncolBoxNoOutlier\t'); if(exists('colBoxNoOutlier')) cat(colBoxNoOutlier)
cat('\ncolHist\t'); if(exists('colHist')) cat(colHist)
cat('\ncolHistBreak\t'); if(exists('colHistBreak')) cat(colHistBreak)
cat('\ncolDensity\t'); if(exists('colDensity')) cat(colDensity)
cat('\ncolDensityType\t'); if(exists('colDensityType')) cat(colDensityType)
cat('\ncolJoy\t'); if(exists('colJoy')) cat(colJoy)
cat('\ncolSimpleAnnoSize\t'); if(exists('colSimpleAnnoSize')) cat(colSimpleAnnoSize)
cat('\ncolAnnoNameSide\t'); if(exists('colAnnoNameSide')) cat(colAnnoNameSide)
cat('\ncolMeanSimple\t'); if(exists('colMeanSimple')) cat(colMeanSimple)
cat('\ncolMeanSimpleHeight\t'); if(exists('colMeanSimpleHeight')) cat(colMeanSimpleHeight)
cat('\ncolMeanSimpleLegendTitle\t'); if(exists('colMeanSimpleLegendTitle')) cat(colMeanSimpleLegendTitle)
cat('\ncolMeanSimpleLegendAt\t'); if(exists('colMeanSimpleLegendAt')) cat(colMeanSimpleLegendAt)
cat('\ncolMeanSimpleLegendLabel\t'); if(exists('colMeanSimpleLegendLabel')) cat(colMeanSimpleLegendLabel)
cat('\ncolMeanSimpleLegendDir\t'); if(exists('colMeanSimpleLegendDir')) cat(colMeanSimpleLegendDir)
cat('\ncolMeanPoint\t'); if(exists('colMeanPoint')) cat(colMeanPoint)
cat('\ncolMeanLine\t'); if(exists('colMeanLine')) cat(colMeanLine)
cat('\ncolMeanLineSmooth\t'); if(exists('colMeanLineSmooth')) cat(colMeanLineSmooth)
cat('\ncolMeanBar\t'); if(exists('colMeanBar')) cat(colMeanBar)
cat('\ncolMeanText\t'); if(exists('colMeanText')) cat(colMeanText)
cat('\nrowTitle\t'); if(exists('rowTitle')) cat(rowTitle)
cat('\nrowTitleSide\t'); if(exists('rowTitleSide')) cat(rowTitleSide)
cat('\nrowTitleSize\t'); if(exists('rowTitleSize')) cat(rowTitleSize)
cat('\nrowTitleFace\t'); if(exists('rowTitleFace')) cat(rowTitleFace)
cat('\nrowTitleRot\t'); if(exists('rowTitleRot')) cat(rowTitleRot)
cat('\nrowTitleCol\t'); if(exists('rowTitleCol')) cat(rowTitleCol)
cat('\nrowTitleFill\t'); if(exists('rowTitleFill')) cat(rowTitleFill)
cat('\nrowTitleBorder\t'); if(exists('rowTitleBorder')) cat(rowTitleBorder)
cat('\nrowNoName\t'); if(exists('rowNoName')) cat(rowNoName)
cat('\nrowNameSide\t'); if(exists('rowNameSide')) cat(rowNameSide)
cat('\nrowNameSize\t'); if(exists('rowNameSize')) cat(rowNameSize)
cat('\nrowNameCol\t'); if(exists('rowNameCol')) cat(rowNameCol)
cat('\nrowNameCenter\t'); if(exists('rowNameCenter')) cat(rowNameCenter)
cat('\nrowNameRot\t'); if(exists('rowNameRot')) cat(rowNameRot)
cat('\nrowNotCluster\t'); if(exists('rowNotCluster')) cat(rowNotCluster)
cat('\nrowNoDend\t'); if(exists('rowNoDend')) cat(rowNoDend)
cat('\nrowDendSide\t'); if(exists('rowDendSide')) cat(rowDendSide)
cat('\nrowDendWidth\t'); if(exists('rowDendWidth')) cat(rowDendWidth)
cat('\nrowClusterDis\t'); if(exists('rowClusterDis')) cat(rowClusterDis)
cat('\nrowDendCol\t'); if(exists('rowDendCol')) cat(rowDendCol)
cat('\nrowDendNotReorder\t'); if(exists('rowDendNotReorder')) cat(rowDendNotReorder)
cat('\nrowSplitKmeans\t'); if(exists('rowSplitKmeans')) cat(rowSplitKmeans)
cat('\nrowSplitCutree\t'); if(exists('rowSplitCutree')) cat(rowSplitCutree)
cat('\nrowSplitGap\t'); if(exists('rowSplitGap')) cat(rowSplitGap)
cat('\nrowBlock\t'); if(exists('rowBlock')) cat(rowBlock)
cat('\nrowBox\t'); if(exists('rowBox')) cat(rowBox)
cat('\nrowBoxNoOutlier\t'); if(exists('rowBoxNoOutlier')) cat(rowBoxNoOutlier)
cat('\nrowHist\t'); if(exists('rowHist')) cat(rowHist)
cat('\nrowHistBreak\t'); if(exists('rowHistBreak')) cat(rowHistBreak)
cat('\nrowDensity\t'); if(exists('rowDensity')) cat(rowDensity)
cat('\nrowDensityType\t'); if(exists('rowDensityType')) cat(rowDensityType)
cat('\nrowJoy\t'); if(exists('rowJoy')) cat(rowJoy)
cat('\nrowSimpleAnnoSize\t'); if(exists('rowSimpleAnnoSize')) cat(rowSimpleAnnoSize)
cat('\nrowAnnoNameSide\t'); if(exists('rowAnnoNameSide')) cat(rowAnnoNameSide)
cat('\nrowMeanSimple\t'); if(exists('rowMeanSimple')) cat(rowMeanSimple)
cat('\nrowMeanSimpleWidth\t'); if(exists('rowMeanSimpleWidth')) cat(rowMeanSimpleWidth)
cat('\nrowMeanPoint\t'); if(exists('rowMeanPoint')) cat(rowMeanPoint)
cat('\nrowMeanLine\t'); if(exists('rowMeanLine')) cat(rowMeanLine)
cat('\nrowMeanLineSmooth\t'); if(exists('rowMeanLineSmooth')) cat(rowMeanLineSmooth)
cat('\nrowMeanBar\t'); if(exists('rowMeanBar')) cat(rowMeanBar)
cat('\nrowMeanText\t'); if(exists('rowMeanText')) cat(rowMeanText)
cat('\nhtLegendName\t'); if(exists('htLegendName')) cat(htLegendName)
cat('\nhtLegendAt\t'); if(exists('htLegendAt')) cat(htLegendAt)
cat('\nhtLegendLabel\t'); if(exists('htLegendLabel')) cat(htLegendLabel)
cat('\nhtLegendHeight\t'); if(exists('htLegendHeight')) cat(htLegendHeight)
cat('\nhtLegendTitlePos\t'); if(exists('htLegendTitlePos')) cat(htLegendTitlePos)
cat('\nhtLegendColorBar\t'); if(exists('htLegendColorBar')) cat(htLegendColorBar)
cat('\nhtLegendDir\t'); if(exists('htLegendDir')) cat(htLegendDir)
cat('\nhtLegendSide\t'); if(exists('htLegendSide')) cat(htLegendSide)
cat('\nannoLegendSide\t'); if(exists('annoLegendSide')) cat(annoLegendSide)
cat('\nNAcol\t'); if(exists('NAcol')) cat(NAcol)
cat('\nborder\t'); if(exists('border')) cat(border)
cat('\nrectGp\t'); if(exists('rectGp')) cat(rectGp)
cat('\nshowValueInCell\t'); if(exists('showValueInCell')) cat(showValueInCell)
cat('\ndensityHt\t'); if(exists('densityHt')) cat(densityHt)
cat('\nylim\t'); if(exists('ylim')) cat(ylim)
cat('\nylab\t'); cat(ylab)
cat('\nmcCore\t'); if(exists('mcCore')) cat(mcCore)
cat('\nverticalConcat\t'); if(exists('verticalConcat')) cat(verticalConcat)
cat('\nmainHeatmap\t'); if(exists('mainHeatmap')) cat(mainHeatmap)
cat('\nfigureColTitle\t'); if(exists('figureColTitle')) cat(figureColTitle)
cat('\nfigureRowTitle\t'); if(exists('figureRowTitle')) cat(figureRowTitle)
cat('\nheatmapGap\t'); if(exists('heatmapGap')) cat(heatmapGap)
cat('\nfigureRowDendSide\t'); if(exists('figureRowDendSide')) cat(figureRowDendSide)
cat('\nfigureRowSubTitleSide\t'); if(exists('figureRowSubTitleSide')) cat(figureRowSubTitleSide)
cat('\nnoAutoAdjust\t'); if(exists('noAutoAdjust')) cat(noAutoAdjust)
cat('\n')

myCmd = 'pdf(myPdf'
if(exists('width')) myCmd = paste0(myCmd, ', width = width')
if(exists('height')) myCmd = paste0(myCmd, ', height = height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

data = as.matrix(read.delim(args[1]))

if(exists('densityHt')){
    myCmd = 'densityHeatmap(data, ylab = ylab, clustering_distance_columns = "ks"'
    if(exists('ylim')) myCmd = paste0(myCmd, ', ylim = ylim')
    if(exists('mcCore')) myCmd = paste0(myCmd, ', mc.cores = mcCore')
}else{
    myCmd = 'Heatmap(data'
}

# For column title
if(exists('colTitle')) myCmd = paste0(myCmd, ', column_title = colTitle')
if(exists('colTitleSide')) myCmd = paste0(myCmd, ', column_title_side = colTitleSide')
if(exists('colTitleRot')) myCmd = paste0(myCmd, ', col_title_rot = colTitleRot')
if(!exists('densityHt')){
    gpar = 'gpar(col = colTitleCol'
    if(exists('colTitleFace')) gpar = paste0(gpar, ', fontface = colTitleFace')
    if(exists('colTitleSize')) gpar = paste0(gpar, ', fontsize = colTitleSize')
    if(exists('colTitleFill')) gpar = paste0(gpar, ', fill = colTitleFill')
    if(exists('colTitleBorder')) gpar = paste0(gpar, ', border = colTitleBorder')
    gpar = paste0(gpar, ')')
    myCmd = paste0(myCmd, ', column_title_gp = ', gpar)
}

# For column name
if(exists('colNoName')) myCmd = paste0(myCmd, ', show_column_names  = FALSE')
if(exists('colNameSide')) myCmd = paste0(myCmd, ', column_names_side = colNameSide')
gpar = 'gpar(col = colNameCol'
if(exists('colNameSize')) gpar = paste0(gpar, ', fontsize = colNameSize')
gpar = paste0(gpar, ')')
myCmd = paste0(myCmd, ', column_names_gp = ', gpar)
if(exists('colNameCenter')) myCmd = paste0(myCmd, ', column_names_centered  = TRUE')
if(exists('colNameRot')) myCmd = paste0(myCmd, ', column_names_rot = colNameRot')

# For column cluster
myCmd = paste0(myCmd, ', cluster_columns = !colNotCluster')
if(exists('colNoDend')) myCmd = paste0(myCmd, ', show_column_dend = FALSE')
if(exists('colDendSide')) myCmd = paste0(myCmd, ', column_dend_side = colDendSide')
if(exists('colDendHeight')) myCmd = paste0(myCmd, ', column_dend_height  = unit(colDendHeight, "cm")')
if(exists('colClusterDis')) myCmd = paste0(myCmd, ', clustering_distance_columns = colClusterDis')
if(exists('colDendCol')) myCmd = paste0(myCmd, ', column_dend_gp = gpar(col = colDendCol)')
if(exists('colClusterDis')) myCmd = paste0(myCmd, ', clustering_distance_columns = colClusterDis')
if(exists('colDendNotReorder')) myCmd = paste0(myCmd, ', column_dend_reorder = FALSE')
if(exists('colSplitKmeans')) myCmd = paste0(myCmd, ', column_km  = colSplitKmeans, column_km_repeats = 100')
if(exists('colSplitCutree')) myCmd = paste0(myCmd, ', column_split  = colSplitCutree')
if(exists('colSplitGap')) myCmd = paste0(myCmd, ', column_gap  = unit(colSplitGap, "mm")')

# For column annotation
if( (exists('colBlock') && exists('colSplitKmeans')) || exists('colBox') || exists('colHist') || exists('colDensity') || exists('colJoy') || exists('colMeanSimple') || exists('colMeanPoint') || exists('colMeanLine') || exists('colMeanBar') || exists('colMeanText')){
    myCmd = paste0(myCmd, ', top_annotation = HeatmapAnnotation(border = FALSE')
    annotationLegendParam = list()
    if(exists('colBlock') && exists('colSplitKmeans')) myCmd = paste0(myCmd, ', "', colBlock, '" = anno_block(gp = gpar(fill = 1:colSplitKmeans+1))')
    if(exists('colBox')){
        myCmd = paste0(myCmd, ', "', colBox, '" = anno_boxplot(data')
        if(exists('colBoxNoOutlier')) myCmd = paste0(myCmd, ', outline = FALSE')
        myCmd = paste0(myCmd, ')')
    }
    if(exists('colHist')){
        myCmd = paste0(myCmd, ', "', colHist, '" = anno_histogram(data')
        if(exists('colHistBreak')) myCmd = paste0(myCmd, ', n_breaks = colHistBreak')
        myCmd = paste0(myCmd, ')')
    }
    if(exists('colDensity')){
        myCmd = paste0(myCmd, ', "', colDensity, '" = anno_density(data')
        if(exists('colDensityType')) myCmd = paste0(myCmd, ', type = colDensityType')
        myCmd = paste0(myCmd, ')')
    }
    if(exists('colJoy')){
        lt = apply(data, 2, function(x) data.frame(density(x)[c("x", "y")]))
        myCmd = paste0(myCmd, ', "', colJoy, '" = anno_joyplot(lt, transparency = 0.75)')
    }
    if(exists('colSimpleAnnoSize')) myCmd = paste0(myCmd, ', simple_anno_size = unit(colSimpleAnnoSize, "cm")')
    if(exists('colAnnoNameSide')) myCmd = paste0(myCmd, ', annotation_name_side = colAnnoNameSide')
    if(exists('colMeanSimple') || exists('colMeanPoint') || exists('colMeanLine') || exists('colMeanBar') || exists('colMeanText')){
        colMean = colMeans(data)
        if(exists('colMeanSimple')){
            myCmd = paste0(myCmd, ', "', colMeanSimple, '" = colMean')
            #if(exists('colMeanSimpleHeight')) myCmd = paste0(myCmd, ', height = unit(colMeanSimpleHeight, "cm")')
            ##if(exists('colMeanSimpleValue')) myCmd = paste0(myCmd, ', pch = colMean, pt_gp = gpar(fontsize = 5)')
            #myCmd = paste0(myCmd, ')')
            tmpList = list()
            if(exists('colMeanSimpleLegendTitle')) tmpList$title = colMeanSimpleLegendTitle
            if(exists('colMeanSimpleLegendAt')) tmpList$at = colMeanSimpleLegendAt
            if(exists('colMeanSimpleLegendLabel')) tmpList$labels = colMeanSimpleLegendLabel
            if(exists('colMeanSimpleLegendDir')) tmpList$direction = colMeanSimpleLegendDir
            annotationLegendParam[[colMeanSimple]] = tmpList
        }
        if(exists('colMeanPoint')) myCmd = paste0(myCmd, ', "', colMeanPoint, '" = anno_points(colMean)')
        if(exists('colMeanLine')){
            myCmd = paste0(myCmd, ', "', colMeanLine, '" = anno_lines(colMean, add_points = TRUE')
            if(exists('colMeanLineSmooth')) myCmd = paste0(myCmd, ', smooth = TRUE')
            myCmd = paste0(myCmd, ')')
        }
        if(exists('colMeanBar')) myCmd = paste0(myCmd, ', "', colMeanBar, '" = anno_barplot(colMean)')
        if(exists('colMeanText')) myCmd = paste0(myCmd, ', "Column Mean Text" = anno_text(colMean)')
    }
    myCmd = paste0(myCmd, ', annotation_legend_param = annotationLegendParam)')
}

if(!exists('densityHt')){
    # For row title
    if(exists('rowTitle')) myCmd = paste0(myCmd, ', row_title = rowTitle')
    if(exists('rowTitleSide')) myCmd = paste0(myCmd, ', row_title_side = rowTitleSide')
    if(exists('rowTitleRot')) myCmd = paste0(myCmd, ', row_title_rot = rowTitleRot')
    gpar = 'gpar(col = rowTitleCol'
    if(exists('rowTitleFace')) gpar = paste0(gpar, ', fontface = rowTitleFace')
    if(exists('rowTitleSize')) gpar = paste0(gpar, ', fontsize = rowTitleSize')
    if(exists('rowTitleFill')) gpar = paste0(gpar, ', fill = rowTitleFill')
    if(exists('rowTitleBorder')) gpar = paste0(gpar, ', border = rowTitleBorder')
    gpar = paste0(gpar, ')')
    myCmd = paste0(myCmd, ', row_title_gp = ', gpar)
    
    # For row name
    if(exists('rowNoName')) myCmd = paste0(myCmd, ', show_row_names  = FALSE')
    if(exists('rowNameSide')) myCmd = paste0(myCmd, ', row_names_side = rowNameSide')
    gpar = 'gpar(col = rowNameCol'
    if(exists('rowNameSize')) gpar = paste0(gpar, ', fontsize = rowNameSize')
    gpar = paste0(gpar, ')')
    myCmd = paste0(myCmd, ', row_names_gp = ', gpar)
    if(exists('rowNameCenter')) myCmd = paste0(myCmd, ', row_names_centered  = TRUE')
    if(exists('rowNameRot')) myCmd = paste0(myCmd, ', row_names_rot = rowNameRot')
}

# For row cluster
if(exists('rowNotCluster')) myCmd = paste0(myCmd, ', cluster_rows  = FALSE')
if(exists('rowNoDend')) myCmd = paste0(myCmd, ', show_row_dend = FALSE')
if(exists('rowDendSide')) myCmd = paste0(myCmd, ', row_dend_side = rowDendSide')
if(exists('rowDendWidth')) myCmd = paste0(myCmd, ', row_dend_width  = unit(rowDendWidth, "cm")')
if(exists('rowClusterDis')) myCmd = paste0(myCmd, ', clustering_distance_rows = rowClusterDis')
if(exists('rowDendCol')) myCmd = paste0(myCmd, ', row_dend_gp = gpar(col = rowDendCol)')
if(exists('rowClusterDis')) myCmd = paste0(myCmd, ', clustering_distance_rows = rowClusterDis')
if(exists('rowDendNotReorder')) myCmd = paste0(myCmd, ', row_dend_reorder = FALSE')
if(exists('rowSplitKmeans')) myCmd = paste0(myCmd, ', row_km  = rowSplitKmeans, row_km_repeats = 100')
if(exists('rowSplitCutree')) myCmd = paste0(myCmd, ', row_split  = rowSplitCutree')
if(exists('rowSplitGap')) myCmd = paste0(myCmd, ', row_gap  = unit(rowSplitGap, "mm")')

# For row annotation
if( (exists('rowBlock') && exists('rowSplitKmeans')) || exists('rowBox') || exists('rowHist') || exists('rowDensity') || exists('rowJoy') || exists('rowMeanSimple') || exists('rowMeanPoint') || exists('rowMeanLine') || exists('rowMeanBar') || exists('rowMeanText') ){
    myCmd = paste0(myCmd, ', right_annotation = rowAnnotation(border = FALSE')
    if(exists('rowBlock') && exists('rowSplitKmeans')) myCmd = paste0(myCmd, ', "', rowBlock, '" = anno_block(gp = gpar(fill = 1:rowSplitKmeans+1))')
    if(exists('rowBox')){
        myCmd = paste0(myCmd, ', "', rowBox, '" = anno_boxplot(data')
        if(exists('rowBoxNoOutlier')) myCmd = paste0(myCmd, ', outline = FALSE')
        myCmd = paste0(myCmd, ')')
    }
    if(exists('rowHist')){
        myCmd = paste0(myCmd, ', "', rowHist, '" = anno_histogram(data')
        if(exists('rowHistBreak')) myCmd = paste0(myCmd, ', n_breaks = rowHistBreak')
        myCmd = paste0(myCmd, ')')
    }
    if(exists('rowDensity')){
        myCmd = paste0(myCmd, ', "', rowDensity, '" = anno_density(data')
        if(exists('rowDensityType')) myCmd = paste0(myCmd, ', type = rowDensityType')
        myCmd = paste0(myCmd, ')')
    }
    if(exists('rowJoy')){
        lt = apply(data, 1, function(x) data.frame(density(x)[c("x", "y")]))
        myCmd = paste0(myCmd, ', "', rowJoy, '" = anno_joyplot(lt, transparency = 0.75)')
    }
    if(exists('rowSimpleAnnoSize')) myCmd = paste0(myCmd, ', simple_anno_size = unit(rowSimpleAnnoSize, "cm")')
    if(exists('rowAnnoNameSide')) myCmd = paste0(myCmd, ', annotation_name_side = rowAnnoNameSide')
    if(exists('rowMeanSimple') || exists('rowMeanPoint') || exists('rowMeanLine') || exists('rowMeanBar') || exists('rowMeanText')){
        rowMean = rowMeans(data)
        if(exists('rowMeanSimple')){
            myCmd = paste0(myCmd, ', "', rowMeanSimple, '" = rowMean')
            #if(exists('rowMeanSimpleWidth')) myCmd = paste0(myCmd, ', height = unit(rowMeanSimpleWidth, "cm")')
            ##if(exists('rowMeanSimpleValue')) myCmd = paste0(myCmd, ', pch = rowMean, pt_gp = gpar(fontsize = 5)')
            #myCmd = paste0(myCmd, ')')
        }
        if(exists('rowMeanPoint')) myCmd = paste0(myCmd, ', "', rowMeanPoint, '" = anno_points(rowMean)')
        if(exists('rowMeanLine')){
            myCmd = paste0(myCmd, ', "', rowMeanLine, '" = anno_lines(rowMean, add_points = TRUE')
            if(exists('rowMeanLineSmooth')) myCmd = paste0(myCmd, ', smooth = TRUE')
            myCmd = paste0(myCmd, ')')
        }
        if(exists('rowMeanBar')) myCmd = paste0(myCmd, ', "', rowMeanBar, '" = anno_barplot(rowMean)')
        if(exists('rowMeanText')) myCmd = paste0(myCmd, ', "Row Mean Text" = anno_text(rowMean)')
    }
    myCmd = paste0(myCmd, ')')
}

# For heatmap legend
htLegendParam = list()
if(exists('htLegendTitle')) htLegendParam$title = htLegendTitle
if(exists('htLegendAt')) htLegendParam$at = htLegendAt
if(exists('htLegendLabel')) htLegendParam$labels = htLegendLabel
if(exists('htLegendHeight')) htLegendParam$legend_height = htLegendHeight
if(exists('htLegendTitlePos')) htLegendParam$title_position = htLegendTitlePos
if(exists('htLegendColorBar')) htLegendParam$color_bar = htLegendColorBar
if(exists('htLegendDir')) htLegendParam$direction = htLegendDir
myCmd = paste0(myCmd, ', heatmap_legend_param = htLegendParam')

if(exists('NAcol')) myCmd = paste0(myCmd, ', na_col = NAcol')
if(exists('border')) myCmd = paste0(myCmd, ', border = border')
if(exists('rectGp')) myCmd = paste0(myCmd, ', rect_gp = gpar(col = rectGp)')

if(exists('showValueInCell')){
    showValueInCellFun = function(j, i, x, y, width, height, fill) {
        grid.text(pindex(data, i, j), x, y, gp = gpar(fontsize = 10))
    }
    myCmd = paste0(myCmd, ', layer_fun = showValueInCellFun')
}
myCmd = paste0(myCmd, ')')

print(paste0('Heatmap1: ', myCmd))

myCmd = paste0('ht1 = ', myCmd)
eval(parse(text = myCmd))

ht = ht1

if(length(args) == 2){

    set.seed(123)
    mat = matrix(rnorm(100), 10)
    rownames(mat) = paste0("R", 1:10)
    colnames(mat) = paste0("C", 1:10)
    
    data2 = mat
    #data2 = read.delim(args[2])
    ht2 = Heatmap(data2)
    if(exists('verticalConcat')){
        ht = ht %v% ht2
    }else{
        ht = ht + ht2
    }
}

myCmd = 'draw(ht'
if(exists('htLegendSide')) myCmd = paste0(myCmd, ', heatmap_legend_side = htLegendSide')
if(exists('annoLegendSide')) myCmd = paste0(myCmd, ', annotation_legend_side  = annoLegendSide')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))
