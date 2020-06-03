#!/usr/env/bin Rscript

args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
library(EnhancedVolcano, quiet = T)

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf <input.tsv
Option:
    -p|pdf    FILE  The output figure in pdf[volcano.pdf]
    -w|width  INT   The figure width
    -height   INT   The figure height
      
    -m|main           STR   The main title
    -x1               DOU   Left limit of the x-axis
    -x2               DOU   Right limit of the x-axis
    -xlab             STR   Label for x-axis
    -ylab             STR   Label for y-axis
    -col              STRs  Colour shading for plotted points, corresponding to
                            < abs(FCcutoff) && > pCutoff,
                            > abs(FCcutoff),
                            < pCutoff,
                            > abs(FCcutoff) && < pCutoff
    -colAlpha         DOU   Alpha for purposes of controlling colour transparency of transcript points
    -cutoffLineType   STR   Line type for FCcutoff and pCutoff (blank,solid,dashed,dotted,dotdash,[longdash],twodash)
    -cutoffLineCol    STR   Line colour for FCcutoff and pCutoff[black]
    -cutoffLineWidth  DOU   Line width for FCcutoff and pCutoff[0.4]
    -noGridlinesMajor       Don't draw major gridlines
    -noGridlinesMinor       Don't draw minor gridlines
    -legend           STRs  Plot legend text
    -legendPosition   STR   Position of legend ([top],bottom,left,right)
    -legendLabSize    DOU   Size of plot legend text[10]
    -legendIconSize   DOU   Size of plot legend icons / symbols[3]
    -selectLab        STRs  A vector containing a subset of lab
    -border           STR   Add a border for just the x and y axes (['partial']) or the entire plot grid ('full')
    -borderWidth      DOU   Width of the border on the x and y axes[0.8]
    -borderColour     STR   Colour of the border on the x and y axes[black]

    -pCutoff   DOU  Cut-off for statistical significance[0.05]
    -FCcutoff  DOU  Cut-off for absolute log2 fold-change[2]

    -h|help             Show help
")
    q(save = 'no')
}

myPdf = 'volcano.pdf'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        if(arg == '-h' || arg == '-help') usage()
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) width = tmp
        tmp = parseArgNum(arg, 'height', 'height'); if(!is.null(tmp)) height = tmp
        
        tmp = parseArg(arg, 'm(ain)?', 'm'); if(!is.null(tmp)) main = tmp
        tmp = parseArg(arg, 'subtitle', 'subtitle'); if(!is.null(tmp)) subtitle = tmp
        tmp = parseArg(arg, 'caption', 'caption'); if(!is.null(tmp)) caption = tmp
        tmp = parseArgNum(arg, 'x1', 'x1'); if(!is.null(tmp)) x1 = tmp
        tmp = parseArgNum(arg, 'x2', 'x2'); if(!is.null(tmp)) x2 = tmp
        tmp = parseArgNum(arg, 'pointSize', 'pointSize'); if(!is.null(tmp)) pointSize = tmp
        tmp = parseArgNum(arg, 'labSize', 'labSize'); if(!is.null(tmp)) labSize = tmp
        tmp = parseArgStrs(arg, 'col', 'col'); if(!is.null(tmp)) pointColor = tmp
        tmp = parseArgNum(arg, 'colAlpha', 'colAlpha'); if(!is.null(tmp)) colAlpha = tmp
        tmp = parseArgNums(arg, 'shape', 'shape'); if(!is.null(tmp)) shape = tmp
        tmp = parseArg(arg, 'cutoffLineType', 'cutoffLineType'); if(!is.null(tmp)) cutoffLineType = tmp
        tmp = parseArg(arg, 'cutoffLineCol', 'cutoffLineCol'); if(!is.null(tmp)) cutoffLineCol = tmp
        tmp = parseArgNum(arg, 'cutoffLineWidth', 'cutoffLineWidth'); if(!is.null(tmp)) cutoffLineWidth = tmp
        tmp = parseArgNums(arg, 'hline', 'hline'); if(!is.null(tmp)) hline = tmp
        tmp = parseArgStrs(arg, 'hlineCol', 'hlineCol'); if(!is.null(tmp)) hlineCol = tmp
        tmp = parseArg(arg, 'hlineType', 'hlineType'); if(!is.null(tmp)) hlineType = tmp
        tmp = parseArgNum(arg, 'hlineWidth', 'hlineWidth'); if(!is.null(tmp)) hlineWidth = tmp
        if(arg == '-noGridlinesMajor') noGridlinesMajor = TRUE
        if(arg == '-noGridlinesMinor') noGridlinesMinor = TRUE
        tmp = parseArgStrs(arg, 'legend', 'legend'); if(!is.null(tmp)) legendText = tmp
        tmp = parseArg(arg, 'legendPosition', 'legendPosition'); if(!is.null(tmp)) legendPosition = tmp
        tmp = parseArgNum(arg, 'legendLabSize', 'legendLabSize'); if(!is.null(tmp)) legendLabSize = tmp
        tmp = parseArgNum(arg, 'legendIconSize', 'legendIconSize'); if(!is.null(tmp)) legendIconSize = tmp
        if(arg == '-noLegend') noLegend = TRUE
        if(arg == '-drawConnectors') drawConnectors = TRUE
        tmp = parseArgNum(arg, 'widthConnectors', 'widthConnectors'); if(!is.null(tmp)) widthConnectors = tmp
        tmp = parseArg(arg, 'colConnectors', 'colConnectors'); if(!is.null(tmp)) colConnectors = tmp
        tmp = parseArgStrs(arg, 'selectLab', 'selectLab'); if(!is.null(tmp)) selectLab = tmp
        tmp = parseArgNum(arg, 'labSize', 'labSize'); if(!is.null(tmp)) labSize = tmp
        tmp = parseArg(arg, 'labCol', 'labCol'); if(!is.null(tmp)) labCol = tmp
        tmp = parseArg(arg, 'labFace', 'labFace'); if(!is.null(tmp)) labFace = tmp
        if(arg == '-boxedLabels') boxedLabels = TRUE
        tmp = parseArgStrs(arg, 'shade', 'shade'); if(!is.null(tmp)) shade = tmp
        tmp = parseArg(arg, 'shadeLabel', 'shadeLabel'); if(!is.null(tmp)) shadeLabel = tmp
        tmp = parseArgNum(arg, 'shadeAlpha', 'shadeAlpha'); if(!is.null(tmp)) shadeAlpha = tmp
        tmp = parseArg(arg, 'shadeFill', 'shadeFill'); if(!is.null(tmp)) shadeFill = tmp
        tmp = parseArgNum(arg, 'shadeSize', 'shadeSize'); if(!is.null(tmp)) shadeSize = tmp
        tmp = parseArgNum(arg, 'shadeBins', 'shadeBins'); if(!is.null(tmp)) shadeBins = tmp
        tmp = parseArg(arg, 'border', 'border'); if(!is.null(tmp)) border = tmp
        tmp = parseArgNum(arg, 'borderWidth', 'borderWidth'); if(!is.null(tmp)) borderWidth = tmp
        tmp = parseArg(arg, 'borderColour', 'borderColour'); if(!is.null(tmp)) borderColour = tmp

        tmp = parseArgNum(arg, 'pCutoff', 'pCutoff'); if(!is.null(tmp)) pCutoff = tmp
        tmp = parseArgNum(arg, 'FCcutoff', 'FCcutoff'); if(!is.null(tmp)) FCcutoff = tmp
    }
}

cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:'))
cat('\npdf\t'); cat(myPdf)
cat('\nwidth\t'); if(exists('width')) cat(width)
cat('\nheight\t'); if(exists('height')) cat(height)
cat('\nmain\t'); if(exists('main')) cat(main)
cat('\nsubtitle\t'); if(exists('subtitle')) cat(subtitle)
cat('\ncaption\t'); if(exists('caption')) cat(caption)
cat('\nx1\t'); if(exists('x1')) cat(x1)
cat('\nx2\t'); if(exists('x2')) cat(x2)
#cat('\npointSize\t'); if(exists('pointSize')) cat(pointSize)
#cat('\nlabSize\t'); if(exists('labSize')) cat(labSize)
cat('\ncolAlpha\t'); if(exists('colAlpha')) cat(colAlpha)
#cat('\nshape\t'); if(exists('shape')) cat(shape)
cat('\ncutoffLineType\t'); if(exists('cutoffLineType')) cat(cutoffLineType)
cat('\ncutoffLineCol\t'); if(exists('cutoffLineCol')) cat(cutoffLineCol)
cat('\ncutoffLineWidth\t'); if(exists('cutoffLineWidth')) cat(cutoffLineWidth)
#cat('\nhlineType\t'); if(exists('hlineType')) cat(hlineType)
#cat('\nhlineWidth\t'); if(exists('hlineWidth')) cat(hlineWidth)
cat('\nnoGridlinesMajor\t'); if(exists('noGridlinesMajor')) cat(noGridlinesMajor)
cat('\nnoGridlinesMinor\t'); if(exists('noGridlinesMinor')) cat(noGridlinesMinor)
cat('\nlegendPosition\t'); if(exists('legendPosition')) cat(legendPosition)
cat('\nlegendLabSize\t'); if(exists('legendLabSize')) cat(legendLabSize)
cat('\nlegendIconSize\t'); if(exists('legendIconSize')) cat(legendIconSize)
#cat('\nnoLegend\t'); if(exists('noLegend')) cat(noLegend)
#cat('\ndrawConnectors\t'); if(exists('drawConnectors')) cat(drawConnectors)
#cat('\nwidthConnectors\t'); if(exists('widthConnectors')) cat(widthConnectors)
#cat('\ncolConnectors\t'); if(exists('colConnectors')) cat(colConnectors)
cat('\nselectLab\t'); if(exists('selectLab')) cat(selectLab)
#cat('\nlabSize\t'); if(exists('labSize')) cat(labSize)
#cat('\nlabCol\t'); if(exists('labCol')) cat(labCol)
#cat('\nlabFace\t'); if(exists('labFace')) cat(labFace)
#cat('\nboxedLabels\t'); if(exists('boxedLabels')) cat(boxedLabels)
cat('\nshadeLabel\t'); if(exists('shadeLabel')) cat(shadeLabel)
cat('\nshadeAlpha\t'); if(exists('shadeAlpha')) cat(shadeAlpha)
cat('\nshadeFill\t'); if(exists('shadeFill')) cat(shadeFill)
cat('\nshadeSize\t'); if(exists('shadeSize')) cat(shadeSize)
cat('\nshadeBins\t'); if(exists('shadeBins')) cat(shadeBins)
cat('\nborder\t'); if(exists('border')) cat(border)
cat('\nborderWidth\t'); if(exists('borderWidth')) cat(borderWidth)
cat('\nborderColour\t'); if(exists('borderColour')) cat(borderColour)
cat('\npCutoff\t'); if(exists('pCutoff')) cat(pCutoff)
cat('\nFCcutoff\t'); if(exists('FCcutoff')) cat(FCcutoff)
cat('\n')

myCmd = 'pdf(myPdf'
if(exists('width')) myCmd = paste0(myCmd, ', width = width')
if(exists('height')) myCmd = paste0(myCmd, ', height = height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

data = read.delim(file('stdin'))
rownames(data) = data$Gene
data$Gene=NULL

myCmd = "EnhancedVolcano(data, lab = rownames(data), x = 'log2FoldChange', y = 'pvalue'"

if(exists('x1') && exists('x2')) myCmd = paste0(myCmd, ', xlim = c(x1, x2)')
if(exists('main')) myCmd = paste0(myCmd, ', title = main')
if(exists('pointSize')) myCmd = paste0(myCmd, ', pointSize = pointSize')
if(exists('labSize')) myCmd = paste0(myCmd, ', labSize = labSize')
if(exists('pointColor')) myCmd = paste0(myCmd, ', col = pointColor')
if(exists('colAlpha')) myCmd = paste0(myCmd, ', colAlpha = colAlpha')
if(exists('shape')) myCmd = paste0(myCmd, ', shape = shape')
if(exists('cutoffLineType')) myCmd = paste0(myCmd, ', cutoffLineType = cutoffLineType')
if(exists('cutoffLineCol')) myCmd = paste0(myCmd, ', cutoffLineCol = cutoffLineCol')
if(exists('cutoffLineWidth')) myCmd = paste0(myCmd, ', cutoffLineWidth = cutoffLineWidth')
if(exists('hline')) myCmd = paste0(myCmd, ', hline = hline')
if(exists('hlineCol')) myCmd = paste0(myCmd, ', hlineCol = hlineCol')
if(exists('hlineType')) myCmd = paste0(myCmd, ', hlineType = hlineType')
if(exists('hlineWidth')) myCmd = paste0(myCmd, ', hlineWidth = hlineWidth')
if(exists('noGridlinesMajor')) myCmd = paste0(myCmd, ', gridlines.major = FALSE')
if(exists('noGridlinesMinor')) myCmd = paste0(myCmd, ', gridlines.minor = FALSE')
if(exists('legendText')) myCmd = paste0(myCmd, ', legend = legendText')
if(exists('legendPosition')) myCmd = paste0(myCmd, ', legendPosition = legendPosition')
if(exists('legendLabSize')) myCmd = paste0(myCmd, ', legendLabSize = legendLabSize')
if(exists('legendIconSize')) myCmd = paste0(myCmd, ', legendIconSize = legendIconSize')
if(exists('noLegend')) myCmd = paste0(myCmd, ', legendVisible = FALSE')
if(exists('drawConnectors')) myCmd = paste0(myCmd, ', drawConnectors = TRUE')
if(exists('widthConnectors')) myCmd = paste0(myCmd, ', widthConnectors = widthConnectors')
if(exists('colConnectors')) myCmd = paste0(myCmd, ', colConnectors = colConnectors')
if(exists('selectLab')) myCmd = paste0(myCmd, ', selectLab = selectLab')
if(exists('labSize')) myCmd = paste0(myCmd, ', labSize = labSize')
if(exists('labCol')) myCmd = paste0(myCmd, ', labCol = labCol')
if(exists('labFace')) myCmd = paste0(myCmd, ', labFace = labFace')
if(exists('boxedLabels')) myCmd = paste0(myCmd, ', boxedLabels = TRUE')
if(exists('shade')) myCmd = paste0(myCmd, ', shade = shade')
if(exists('shadeLabel')) myCmd = paste0(myCmd, ', shadeLabel = shadeLabel')
if(exists('shadeAlpha')) myCmd = paste0(myCmd, ', shadeAlpha = shadeAlpha')
if(exists('shadeFill')) myCmd = paste0(myCmd, ', shadeFill = shadeFill')
if(exists('shadeSize')) myCmd = paste0(myCmd, ', shadeSize = shadeSize')
if(exists('shadeBins')) myCmd = paste0(myCmd, ', shadeBins = shadeBins')
if(exists('border')) myCmd = paste0(myCmd, ', border = border')
if(exists('borderWidth')) myCmd = paste0(myCmd, ', borderWidth = borderWidth')
if(exists('borderColour')) myCmd = paste0(myCmd, ', borderColour = borderColour')
if(exists('pCutoff')) myCmd = paste0(myCmd, ', pCutoff = pCutoff')
if(exists('FCcutoff')) myCmd = paste0(myCmd, ', FCcutoff = FCcutoff')

myCmd = paste0(myCmd, ')')
myCmd
eval(parse(text = myCmd))
