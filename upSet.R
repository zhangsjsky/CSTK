#!/bin/env Rscript

args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
suppressMessages(library(ComplexHeatmap))
library(tools)

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf input.lst[ input2.lst ...]
Option:
    -p|pdf    FILE  The output figure in pdf[upSet.pdf]
    -w|width  INT   The figure width
    -height   INT   The figure height
    
    -combMode        STR  Combination mode([distinct],intersect,union)
    -minSetSize      INT  The minimal size for the sets
    -topNSet         INT  The number of top sets with largest sizes
    -complementSize  INT  The known complement size
    -minCombSize     INT  The minimal combination set sizes
    -minCombDegree   INT  The minimal combination set degree(the number of sets that are selected)
    
    -trans                Transpose the combination matrix
    
    -sortCombBySize       Sort the combination sets by size. Default by degree.
    
    -dotSize       DOU    Dot size
    -lineWidth     DOU    Line width
    -combColor     STRs   Combination color
                          If only one color specified, all combinatin sets are colored in this color,
                          otherwise all combination sets are colored in each color from low to high degree, respectively
    -bgColor       STR    Background color for odd row
    -bgColor2      STR    Background color for even row(effective only -bgColor specified)
    -bgPointColor  STR    Background point color
    -noRowName            Don't show row names
    -rowNameSide   STR    Put row names on which side([left],right)
    
    -topAxisSide       STR   Put top axis on which side([left],right)
    -topAxisAt         DOUs  Top axis tick values
    -topAxisLabel      STRs  Top axis tick labels(effective only -topAxisAt specified)
    -topBarplotHeight  DOU   The height of top barplot
    -topBarWidth       DOU   The bar width of top barplot(0-1)
    -topYlim           DOUs  The Y limit of top axis
    -topAnnoNameRot    DOU   Rotate the top annotation name
    -topAnnoNameSide   STR   Put top annotation name on which side(left,[right])
    
    -rightAxisSide      STR   Put right axis on which side(top,[bottom])
    -rightAxisAt        DOUs  Right axis tick values
    -rightAxisLabel     STRs  Right axis tick labels
    -rightBarplotWidth  DOU   The width of right barplot
    -rightBarWidth      DOU   The bar width of right barplot(0-1)
    -rightYlim          DOUs  The Y limit of right axis
    -rightAnnoNameRot   DOU   Rotate the right annotation name
    -rightAnnoNameSide  STR   Put right annotation name on which side(top,[bottom])
                              
    -h|help  Show help
")
    q(save = 'no')
}

myPdf = 'upSet.pdf'

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
        tmp = parseArg(arg, 'combMode', 'combMode')
        if(!is.null(tmp)){
            combMode  = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'minSetSize', 'minSetSize')
        if(!is.null(tmp)){
            minSetSize = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'topNSet', 'topNSet')
        if(!is.null(tmp)){
            topNSet = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'complementSize', 'complementSize')
        if(!is.null(tmp)){
            complementSize = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'minCombSize', 'minCombSize')
        if(!is.null(tmp)){
            minCombSize = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'minCombDegree', 'minCombDegree')
        if(!is.null(tmp)){
            minCombDegree = tmp
            args[i] = NA
            next
        }
        if(arg == '-trans'){
            trans = TRUE
            args[i] = NA
            next
        }
        if(arg == '-sortCombBySize'){
            sortCombBySize = TRUE
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'dotSize', 'dotSize')
        if(!is.null(tmp)){
            dotSize = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'lineWidth', 'lineWidth')
        if(!is.null(tmp)){
            lineWidth = tmp
            args[i] = NA
            next
        }
        tmp = parseArgStrs(arg, 'combColor', 'combColor')
        if(!is.null(tmp)){
            combColor = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'bgColor', 'bgColor')
        if(!is.null(tmp)){
            bgColor = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'bgColor2', 'bgColor2')
        if(!is.null(tmp)){
            bgColor2 = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'bgPointColor', 'bgPointColor')
        if(!is.null(tmp)){
            bgPointColor = tmp
            args[i] = NA
            next
        }
        if(arg == '-noRowName'){
            noRowName = TRUE
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rowNameSide', 'rowNameSide')
        if(!is.null(tmp)){
            rowNameSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'topAxisSide', 'topAxisSide')
        if(!is.null(tmp)){
            topAxisSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNums(arg, 'topAxisAt', 'topAxisAt')
        if(!is.null(tmp)){
            topAxisAt = tmp
            args[i] = NA
            next
        }
        tmp = parseArgStrs(arg, 'topAxisLabel', 'topAxisLabel')
        if(!is.null(tmp)){
            topAxisLabel = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'topBarplotHeight', 'topBarplotHeight')
        if(!is.null(tmp)){
            topBarplotHeight = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'topBarWidth', 'topBarWidth')
        if(!is.null(tmp)){
            topBarWidth = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNums(arg, 'topYlim', 'topYlim')
        if(!is.null(tmp)){
            topYlim = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'topAnnoNameRot', 'topAnnoNameRot')
        if(!is.null(tmp)){
            topAnnoNameRot = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'topAnnoNameSide', 'topAnnoNameSide')
        if(!is.null(tmp)){
            topAnnoNameSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rightAxisSide', 'rightAxisSide')
        if(!is.null(tmp)){
            rightAxisSide = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNums(arg, 'rightAxisAt', 'rightAxisAt')
        if(!is.null(tmp)){
            rightAxisAt = tmp
            args[i] = NA
            next
        }
        tmp = parseArgStrs(arg, 'rightAxisLabel', 'rightAxisLabel')
        if(!is.null(tmp)){
            rightAxisLabel = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rightBarplotWidth', 'rightBarplotWidth')
        if(!is.null(tmp)){
            rightBarplotWidth = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rightBarWidth', 'rightBarWidth')
        if(!is.null(tmp)){
            rightBarWidth = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNums(arg, 'rightYlim', 'rightYlim')
        if(!is.null(tmp)){
            rightYlim = tmp
            args[i] = NA
            next
        }
        tmp = parseArgNum(arg, 'rightAnnoNameRot', 'rightAnnoNameRot')
        if(!is.null(tmp)){
            rightAnnoNameRot = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'rightAnnoNameSide', 'rightAnnoNameSide')
        if(!is.null(tmp)){
            rightAnnoNameSide = tmp
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
cat('\ncombMode\t'); if(exists('combMode')) cat(combMode)
cat('\nminSetSize\t'); if(exists('minSetSize')) cat(minSetSize)
cat('\ntopNSet\t'); if(exists('topNSet')) cat(topNSet)
cat('\ncomplementSize\t'); if(exists('complementSize')) cat(complementSize)
cat('\nminCombSize\t'); if(exists('minCombSize')) cat(minCombSize)
cat('\nminCombDegree\t'); if(exists('minCombDegree')) cat(minCombDegree)
cat('\ntrans\t'); if(exists('trans')) cat(trans)
cat('\nsortCombBySize\t'); if(exists('sortCombBySize')) cat(sortCombBySize)
cat('\ndotSize\t'); if(exists('dotSize')) cat(dotSize)
cat('\nlineWidth\t'); if(exists('lineWidth')) cat(lineWidth)
cat('\ncombColor\t'); if(exists('combColor')) cat(combColor)
cat('\nbgColor\t'); if(exists('bgColor')) cat(bgColor)
cat('\nbgColor2\t'); if(exists('bgColor2')) cat(bgColor2)
cat('\nbgPointColor\t'); if(exists('bgPointColor')) cat(bgPointColor)
cat('\nnoRowName\t'); if(exists('noRowName')) cat(noRowName)
cat('\nrowNameSide\t'); if(exists('rowNameSide')) cat(rowNameSide)
cat('\ntopAxisSide\t'); if(exists('topAxisSide')) cat(topAxisSide)
cat('\ntopAxisAt\t'); if(exists('topAxisAt')) cat(topAxisAt)
cat('\ntopAxisLabel\t'); if(exists('topAxisLabel')) cat(topAxisLabel)
cat('\ntopBarplotHeight\t'); if(exists('topBarplotHeight')) cat(topBarplotHeight)
cat('\ntopBarWidth\t'); if(exists('topBarWidth')) cat(topBarWidth)
cat('\ntopYlim\t'); if(exists('topYlim')) cat(topYlim)
cat('\ntopAnnoNameRot\t'); if(exists('topAnnoNameRot')) cat(topAnnoNameRot)
cat('\ntopAnnoNameSide\t'); if(exists('topAnnoNameSide')) cat(topAnnoNameSide)
cat('\nrightAxisSide\t'); if(exists('rightAxisSide')) cat(rightAxisSide)
cat('\nrightAxisAt\t'); if(exists('rightAxisAt')) cat(rightAxisAt)
cat('\nrightAxisLabel\t'); if(exists('rightAxisLabel')) cat(rightAxisLabel)
cat('\nrightBarplotWidth\t'); if(exists('rightBarplotWidth')) cat(rightBarplotWidth)
cat('\nrightBarWidth\t'); if(exists('rightBarWidth')) cat(rightBarWidth)
cat('\nrightYlim\t'); if(exists('rightYlim')) cat(rightYlim)
cat('\nrightAnnoNameRot\t'); if(exists('rightAnnoNameRot')) cat(rightAnnoNameRot)
cat('\nrightAnnoNameSide\t'); if(exists('rightAnnoNameSide')) cat(rightAnnoNameSide)
cat('\n')

myCmd = 'pdf(myPdf'
if(exists('width')) myCmd = paste0(myCmd, ', width = width')
if(exists('height')) myCmd = paste0(myCmd, ', height = height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

# Prepare set list
setList = lapply(args, function(file){
    data = scan(file, what = 'c', quiet = T)
})
names(setList) = basename(file_path_sans_ext(args))

# Prepare combination matrix
myCmd = 'combMat = make_comb_mat(setList'
if(exists('combMode')) myCmd = paste0(myCmd, ', mode = combMode')
if(exists('minSetSize')) myCmd = paste0(myCmd, ', min_set_size = minSetSize')
if(exists('topNSet')) myCmd = paste0(myCmd, ', top_n_sets = topNSet')
if(exists('complementSize')) myCmd = paste0(myCmd, ', complement_size = complementSize')
myCmd = paste0(myCmd, ')')
print(paste0('Run: ', myCmd))
eval(parse(text = myCmd))

# Filter combination matrix
if(exists('minCombSize')) combMat = combMat[comb_size(combMat) >= minCombSize]
if(exists('minCombDegree')) combMat = combMat[comb_degree(combMat) >= minCombDegree]

if(exists('trans')){
    combMat = t(combMat)
    topBarData = set_size(combMat)
    topBarName = 'Set\nsize'
    rightBarData = comb_size(combMat)
    rightBarName = 'Intersection size'
}else{
    topBarData = comb_size(combMat)
    topBarName = 'Intersection\nsize'
    rightBarData = set_size(combMat)
    rightBarName = 'Set size'
}

myCmd = 'UpSet(combMat'
if(exists('sortCombBySize')) myCmd = paste0(myCmd, ', comb_order = order(comb_size(combMat))')
if(exists('dotSize')) myCmd = paste0(myCmd, ', pt_size = unit(dotSize,"mm")')
if(exists('lineWidth')) myCmd = paste0(myCmd, ', lwd = lineWidth')
if(exists('combColor')){
    combDegree = comb_degree(combMat)
    if(length(combColor) >1){
        if(any(combDegree == 0)) combDegree = combDegree + 1
        combColor = combColor[combDegree]
    }
    myCmd = paste0(myCmd, ', comb_col  = combColor')
}
if(exists('bgColor')){
    bgColor = c(bgColor)
    if(exists('bgColor2')) bgColor = c(bgColor, bgColor2)
    myCmd = paste0(myCmd, ', bg_col = bgColor')
}
if(exists('bgPointColor')) myCmd = paste0(myCmd, ', bg_pt_col = bgPointColor')
if(exists('noRowName')) myCmd = paste0(myCmd, ', show_row_names = F')
if(exists('rowNameSide')) myCmd = paste0(myCmd, ', row_names_side = rowNameSide')

# Prepare top barplot
axisParam = list()
if(exists('topAxisSide')) axisParam$side = topAxisSide
if(exists('topAxisAt')) axisParam$at = topAxisAt
if(exists('topAxisLabel')) axisParam$labels = topAxisLabel
myTmpCmd = 'topBarplot = anno_barplot(topBarData, border = F, axis_param = axisParam'
if(exists('topBarplotHeight')) myTmpCmd = paste0(myTmpCmd, ', height = unit(topBarplotHeight, "cm")')
if(exists('topBarWidth')) myTmpCmd = paste0(myTmpCmd, ', bar_width = topBarWidth')
if(exists('topYlim')) myTmpCmd = paste0(myTmpCmd, ', ylim = topYlim')
myTmpCmd = paste0(myTmpCmd, ')')
print(paste0('Run: ', myTmpCmd))
eval(parse(text = myTmpCmd))

# Add top annotation
myCmd = paste0(myCmd, ', top_annotation = HeatmapAnnotation("', topBarName, '" = topBarplot')
if(exists('topAnnoNameRot')) myCmd = paste0(myCmd, ', annotation_name_rot = topAnnoNameRot')
if(exists('topAnnoNameSide')) myCmd = paste0(myCmd, ', annotation_name_side = topAnnoNameSide')
myCmd = paste0(myCmd, ')')

# Prepare right barplot
axisParam = list()
if(exists('rightAxisSide')) axisParam$side = rightAxisSide
if(exists('rightAxisAt')) axisParam$at = rightAxisAt
if(exists('rightAxisLabel')) axisParam$labels = rightAxisLabel
myTmpCmd = 'rightBarplot = anno_barplot(rightBarData, which = "row", border = F, axis_param = axisParam'
if(exists('rightBarplotWidth')) myTmpCmd = paste0(myTmpCmd, ', width = unit(rightBarplotWidth, "cm")')
if(exists('rightBarWidth')) myTmpCmd = paste0(myTmpCmd, ', bar_width = rightBarWidth')
if(exists('rightYlim')) myTmpCmd = paste0(myTmpCmd, ', ylim = rightYlim')
myTmpCmd = paste0(myTmpCmd, ')')
print(paste0('Run: ', myTmpCmd))
eval(parse(text = myTmpCmd))

# Add right annotation
myCmd = paste0(myCmd, ', right_annotation = rowAnnotation("', rightBarName, '" = rightBarplot')
if(exists('rightAnnoNameRot')) myCmd = paste0(myCmd, ', annotation_name_rot = rightAnnoNameRot')
if(exists('rightAnnoNameSide')) myCmd = paste0(myCmd, ', annotation_name_side = rightAnnoNameSide')
myCmd = paste0(myCmd, ')')

myCmd = paste0(myCmd, ')')
print(paste0("Run: ", myCmd))
eval(parse(text = myCmd))
