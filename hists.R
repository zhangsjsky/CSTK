#!/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
library(tools)

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf input1.data inpu2.data [input3.data ...]
Option:
    Common:
    -p|pdf          FILE    The output figure in pdf[figure.pdf]
    -w|width        INT     The figure width
    -m|main         STR     The main title
    -mainS          DOU     The size of main title[22 for ggplot]
    -x|xlab         STR     The xlab[Binned Values]
    -y|ylab         STR     The ylab
    -xl|xlog        INT     Transform the X scale to INT base log
    -yl|ylog        INT     Transform the Y scale to INT base log
    -x1             INT     The xlim start
    -x2             INT     The xlim end
    -y1             INT     The ylim start
    -y2             INT     The ylim end
    -xLblS          DOU     The X-axis label size[20 for ggplot]
    -xTxtS          DOU     The X-axis text size[18 for ggplot]
    -xAngle         [0,360] The angle of tick labels[0]
    -vJust          [0,1]   The vertical justification of tick labels[0.5]
    -yLblS          DOU     The Y-axis label size[20 for ggplot]
    -yTxtS          DOU     The Y-axis text size[18 for ggplot]
    -ng|noGgplot            Draw figure in the style of R base rather than ggplot
    -h|help                 Show help

    ggplot specific:
    -v|vertical     DOU     Draw a vertical line
    -b|binWidth     DOU     The bin width[1/30 of the range of the data]
    -d|density              Draw Y axis in density

    -a|alpha        DOU     The alpha of hist body
    -alphaV         STR     The column name to apply alpha (V3, V4, ...)
    -alphaT         STR     The title of alpha legend[Alpha]
    -alphaTP        POS     The title position of alpha legend[horizontal: top, vertical:right]
    -alphaLP        POS     The label position of alpha legend[horizontal: top, vertical:right]
    -alphaD         STR     The direction of alpha legend (horizontal, vertical)
    -c|color        STR     The color of hist boundary
    -colorV         STR     The column name to apply color (V3, V4,...)
    -colorC                 Continuous color mapping
    -colorT         STR     The title of color legend[Color]
    -colorTP        POS     The title position of color legend[horizontal: top, vertical:right]
    -colorLP        POS     The label position of color legend[horizontal: top, vertical:right]
    -colorD         STR     The direction of color legend (horizontal, vertical)
    -l|linetype     INT     The line type
    -linetypeV      STR     The column name to apply linetype (V3, V4,...)
    -linetypeT      STR     The title of linetype legend[Line Type]
    -linetypeTP     POS     The title position of linetype legend[horizontal: top, vertical:right]
    -linetypeLP     POS     The label position of linetype legend[horizontal: top, vertical:right]
    -linetypeD      STR     The direction of linetype legend (horizontal, vertical)
    -s|size         DOU     The size of hist body
    -sizeV          STR     The column name to apply size (V3, V4,...)
    -sizeT          STR     The title of size legend[Size]
    -sizeTP         POS     The title position of size legend[horizontal: top, vertical:right]
    -sizeLP         POS     The label position of size legend[horizontal: top, vertical:right]
    -sizeD          STR     The direction of size legend (horizontal, vertical)
    -weight         DOU     The weight of hist
    -weightV        STR     The column name to apply weight (V3, V4,...)
    -weightT        STR     The title of weight legend[weight]
    -weightTP       POS     The title position of weight legend[horizontal: top, vertical:right]
    -weightLP       POS     The label position of weight legend[horizontal: top, vertical:right]
    -weightD        STR     The direction of weight legend (horizontal, vertical)
                    
    -noGuide                Don't show the legend guide
    -lgPos          POS     The legend position[horizontal: top, vertical:right]
    -lgPosX         [0,1]   The legend relative postion on X
    -lgPosY         [0,1]   The legend relative postion on Y
    -lgTtlS         INT     The legend title size[22]
    -lgTxtS         INT     The legend text size[20]
    -lgBox          STR     The legend box style (horizontal, vertical)

    -fp|flip                Flip the Y axis to horizontal
    -facet          STR     The facet type (facet_wrap, facet_grid)
    -facetM         STR     The facet model (eg: '. ~ V3', 'V3 ~ .', 'V3 ~ V4', '. ~ V3 + V4', ...)
    -facetScl       STR     The axis scale in each facet ([fixed], free, free_x or free_y)

    -xPer                   Show X label in percentage
    -yPer                   Show Y label in percentage
    -xComma                 Show X label number with comma seperator
    -yComma                 Show Y label number with comma seperator
    -axisRatio      DOU     The fixed aspect ratio between y and x units

    -annoTxt        STRs    The comma-seperated texts to be annotated
    -annoTxtX       INTs    The comma-seperated X positions of text
    -annoTxtY       INTs    The comma-seperated Y positions of text

Skill:
    Legend title of alpha, color, etc can be set as the same to merge their guides
")
    q(save = 'no')
}

alphaT = 'Alpha'
colorT = 'Color'
fillT = 'Fill'
linetypeT = 'Line Type'
sizeT = 'Size'
weightT = 'Weight'
lgTtlS = 22
lgTxtS = 20
showGuide = TRUE
myPdf = 'figure.pdf'
mainS = 22
xLblS = 20
xTxtS = 18
xAngle = 0
vJust = 0.5
yLblS = 20
yTxtS = 18
xLab='Binned Values'


if(length(args) == 0) usage()

for(i in 1:length(args)){
    arg = args[i]
    tmp = parseArgAsNum(arg, 'v(ertical)?', 'v')
    if(!is.null(tmp)){
        vertical = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'b(inWidth)?', 'b')
    if(!is.null(tmp)){
        binWidth = tmp
        args[i] = NA
        next
    }
    if(arg == '-d' || arg == '-density'){
        drawDensity = TRUE
        args[i] = NA
        next
    }
    
    tmp = parseArgAsNum(arg, 'a(lpha)?', 'a')
    if(!is.null(tmp)){
        alpha = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'alphaV', 'alphaV')
    if(!is.null(tmp)){
        alphaV = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'alphaT', 'alphaT')
    if(!is.null(tmp)){
        alphaT = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'alphaTP', 'alphaTP')
    if(!is.null(tmp)){
        alphaTP = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'alphaLP', 'alphaLP')
    if(!is.null(tmp)){
        alphaLP = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'alphaD', 'alphaD')
    if(!is.null(tmp)){
        alphaD = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'c(olor)?', 'c')
    if(!is.null(tmp)){
        color = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'colorV', 'colorV')
    if(!is.null(tmp)){
        colorV = tmp
        args[i] = NA
        next
    }
    if(arg == '-colorC'){
        colorC = TRUE
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'colorT', 'colorT')
    if(!is.null(tmp)){
        colorT = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'colorTP', 'colorTP')
    if(!is.null(tmp)){
        colorTP = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'colorLP', 'colorLP')
    if(!is.null(tmp)){
        colorLP = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'colorD', 'colorD')
    if(!is.null(tmp)){
        colorD = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'l(inetype)?', 'l')
    if(!is.null(tmp)){
        linetype = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'linetypeV', 'linetypeV')
    if(!is.null(tmp)){
        linetypeV = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'linetypeT', 'linetypeT')
    if(!is.null(tmp)){
        linetypeT = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'linetypeTP', 'linetypeTP')
    if(!is.null(tmp)){
        linetypeTP = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'linetypeLP', 'linetypeLP')
    if(!is.null(tmp)){
        linetypeLP = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'linetypeD', 'linetypeD')
    if(!is.null(tmp)){
        linetypeD = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 's(ize)?', 's')
    if(!is.null(tmp)){
        size = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'sizeV', 'sizeV')
    if(!is.null(tmp)){
        sizeV = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'sizeT', 'sizeT')
    if(!is.null(tmp)){
        sizeT = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'sizeTP', 'sizeTP')
    if(!is.null(tmp)){
        sizeTP = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'sizeLP', 'sizeLP')
    if(!is.null(tmp)){
        sizeLP = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'sizeD', 'sizeD')
    if(!is.null(tmp)){
        sizeD = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'weight', 'weight')
    if(!is.null(tmp)){
        weight = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'weightV', 'weightV')
    if(!is.null(tmp)){
        weightV = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'weightT', 'weightT')
    if(!is.null(tmp)){
        weightT = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'weightTP', 'weightTP')
    if(!is.null(tmp)){
        weightTP = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'weightLP', 'weightLP')
    if(!is.null(tmp)){
        weightLP = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'weightD', 'weightD')
    if(!is.null(tmp)){
        weightD = tmp
        args[i] = NA
        next
    }
    
    if(arg == '-noGuide'){
        showGuide = FALSE
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'lgPos', 'lgPos')
    if(!is.null(tmp)){
        lgPos = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'lgPosX', 'lgPosX')
    if(!is.null(tmp)){
        lgPosX = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'lgPosY', 'lgPosY')
    if(!is.null(tmp)){
        lgPosY = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'lgTtlS', 'lgTtlS')
    if(!is.null(tmp)){
        lgTtlS = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'lgTxtS', 'lgTxtS')
    if(!is.null(tmp)){
        lgTxtS = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'lgBox', 'lgBox')
    if(!is.null(tmp)){
        lgBox = tmp
        args[i] = NA
        next
    }
    
    if(arg == '-fp' || arg =='-flip'){
        flip = TRUE
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'facet', 'facet')
    if(!is.null(tmp)){
        myFacet = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'facetM', 'facetM')
    if(!is.null(tmp)){
        facetM = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'facetScl', 'facetScl')
    if(!is.null(tmp)){
        facetScl = tmp
        args[i] = NA
        next
    }
    if(arg == '-xPer'){
        xPer = TRUE
        args[i] = NA
        next
    }
    if(arg == '-yPer'){
        yPer = TRUE
        args[i] = NA
        next
    }
    if(arg == '-xComma'){
        xComma = TRUE
        args[i] = NA
        next
    }
    if(arg == '-yComma'){
        yComma = TRUE
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'axisRatio', 'axisRatio')
    if(!is.null(tmp)){
        axisRatio = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'annoTxt', 'annoTxt')
    if(!is.null(tmp)){
        annoTxt = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'annoTxtX', 'annoTxtX')
    if(!is.null(tmp)){
        annoTxtX = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'annoTxtY', 'annoTxtY')
    if(!is.null(tmp)){
        annoTxtY = tmp
        args[i] = NA
        next
    }
    
    if(arg == '-h' || arg == '-help') usage()
    tmp = parseArg(arg, 'p(df)?', 'p')
    if(!is.null(tmp)){
        myPdf = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'w(idth)?', 'w')
    if(!is.null(tmp)){
        width = tmp
        args[i] = NA
        next
    }
    if(arg == '-ng' || arg == '-noGgplot'){
        noGgplot = TRUE
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'x1', 'x1')
    if(!is.null(tmp)){
        x1 = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'x2', 'x2')
    if(!is.null(tmp)){
        x2 = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'y1', 'y1')
    if(!is.null(tmp)){
        y1 = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'y2', 'y2')
    if(!is.null(tmp)){
        y2 = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'xl(og)?', 'xl')
    if(!is.null(tmp)){
        xLog = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'yl(og)?', 'yl')
    if(!is.null(tmp)){
        yLog = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'm(ain)?', 'm')
    if(!is.null(tmp)){
        main = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'mainS', 'mainS')
    if(!is.null(tmp)){
        mainS = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'x(lab)?', 'x')
    if(!is.null(tmp)){
        xLab = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'y(lab)?', 'y')
    if(!is.null(tmp)){
        yLab = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'xAngle', 'xAngle')
    if(!is.null(tmp)){
        xAngle = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'vJust', 'vJust')
    if(!is.null(tmp)){
        vJust = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'xLblS', 'xLblS')
    if(!is.null(tmp)){
        xLblS = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'xTxtS', 'xTxtS')
    if(!is.null(tmp)){
        xTxtS = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'yLblS', 'yLblS')
    if(!is.null(tmp)){
        yLblS = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'yTxtS', 'yTxtS')
    if(!is.null(tmp)){
        yTxtS = tmp
        args[i] = NA
        next
    }
}

args = args[!is.na(args)]
if(length(args) < 2) stop('Please specify two input files at least')

if(exists('width')){
    pdf(myPdf, width = width)
}else{
    pdf(myPdf)
}

fileNames = basename(file_path_sans_ext(args))
if(exists('noGgplot')){
    
}else{
    library(ggplot2)
    
    data = cbind(read.delim(args[1], header = F), Series = fileNames[1])
    for(i in 2:length(args)){
        file = args[i]
        fileName = fileNames[i]
        newData = cbind(read.delim(file, header = F), Series = fileName)
        data = rbind(data, newData)
    }
    
    p = ggplot(data, aes(x = V1, fill = Series)) 
    if(exists('drawDensity')) p = p + aes(y = ..density..) + ylab('Density')
    
    if(exists('alphaV')){
        p = p + aes_string(alpha = alphaV)
        myCmd = 'p = p + guides(alpha = guide_legend(alphaT'
        if(exists('alphaTP')) myCmd = paste0(myCmd, ', title.position = alphaTP')
        if(exists('alphaLP')) myCmd = paste0(myCmd, ', label.position = alphaLP')
        if(exists('alphaD')) myCmd = paste0(myCmd, ', direction = alphaD')
        myCmd = paste0(myCmd, '))')
        eval(parse(text = myCmd))
    }
    if(exists('colorV')){
        if(exists('colorC')){
            p = p + aes_string(color = colorV)
        }else{
            myCmd = paste0('p = p + aes(color = factor(', colorV, '))'); eval(parse(text = myCmd))
        }
        myCmd = 'p = p + guides(color = guide_legend(colorT'
        if(exists('colorTP')) myCmd = paste0(myCmd, ', title.position = colorTP')
        if(exists('colorLP')) myCmd = paste0(myCmd, ', label.position = colorLP')
        if(exists('colorD')) myCmd = paste0(myCmd, ', direction = colorD')
        myCmd = paste0(myCmd, '))')
        eval(parse(text = myCmd))
    }
    if(exists('linetypeV')){
        myCmd = paste0('p = p + aes(linetype = factor(', linetypeV, '))'); eval(parse(text = myCmd))
        myCmd = 'p = p + guides(linetype = guide_legend(linetypeT'
        if(exists('linetypeTP')) myCmd = paste0(myCmd, ', title.position = linetypeTP')
        if(exists('linetypeLP')) myCmd = paste0(myCmd, ', label.position = linetypeLP')
        if(exists('linetypeD')) myCmd = paste0(myCmd, ', direction = linetypeD')
        myCmd = paste0(myCmd, '))')
        eval(parse(text = myCmd))
    }
    if(exists('sizeV')){
        p = p + aes_string(size = sizeV)
        myCmd = 'p = p + guides(size = guide_legend(sizeT'
        if(exists('sizeTP')) myCmd = paste0(myCmd, ', title.position = sizeTP')
        if(exists('sizeLP')) myCmd = paste0(myCmd, ', label.position = sizeLP')
        if(exists('sizeD')) myCmd = paste0(myCmd, ', direction = sizeD')
        myCmd = paste0(myCmd, '))')
        eval(parse(text = myCmd))
    }
    if(exists('weightV')){
        p = p + aes_string(weight = weightV)
        myCmd = 'p = p + guides(weight = guide_legend(weightT'
        if(exists('weightTP')) myCmd = paste0(myCmd, ', title.position = weightTP')
        if(exists('weightLP')) myCmd = paste0(myCmd, ', label.position = weightLP')
        if(exists('weightD')) myCmd = paste0(myCmd, ', direction = weightD')
        myCmd = paste0(myCmd, '))')
        eval(parse(text = myCmd))
    }
    
    myCmd = paste0('p = p + geom_bar(show_guide = showGuide, position="dodge", ')
    if(exists('alpha')) myCmd = paste0(myCmd, ', alpha = alpha')
    if(exists('color')) myCmd = paste0(myCmd, ', color = color')
    if(exists('fill')) myCmd = paste0(myCmd, ', fill = fill')
    if(exists('size')) myCmd = paste0(myCmd, ', size = size')
    if(exists('binWidth')) myCmd = paste0(myCmd, ', binwidth = binWidth')
    myCmd = paste0(myCmd, ')')
    if(exists('myFacet')){
        myCmd = paste0(myCmd, ' + ', myFacet, '("' + facetM + '"')
        if(exists('facetScl')) myCmd = paste0(myCmd, ', scale = facetScl')
        myCmd = paste0(myCmd, ')')
    }
    eval(parse(text = myCmd))
    
    if(exists('lgPos')) p = p + theme(legend.position = lgPos)
    if(exists('lgPosX') && exists('lgPosY')) p = p + theme(legend.position = c(lgPosX, lgPosY))
    p = p + theme(legend.title = element_text(size = lgTtlS), legend.text = element_text(size = lgTxtS))
    if(exists('lgBox')) p = p + theme(legend.box = lgBox)
    if(exists('xPer')) p = p + scale_x_continuous(labels = percent)
    if(exists('yPer')) p = p + scale_y_continuous(labels = percent)
    if(exists('xComma')) p = p + scale_x_continuous(labels = comma)
    if(exists('yComma')) p = p + scale_y_continuous(labels = comma)
    if(exists('axisRatio')) p = p + coord_fixed(ratio = axisRatio)
    if(exists('annoTxt')) p = p + annotate('text', x = as.numeric(strsplit(annoTxtX, ',', fixed = T)),
                                           y = as.numeric(strsplit(annoTxtY, ',', fixed = T)),
                                           label = strsplit(annoTxt, ',', fixed = T))
    
    if(exists('x1') && exists('x2')) p = p + coord_cartesian(xlim = c(x1, x2))
    if(exists('y1') && exists('y2')) p = p + coord_cartesian(ylim = c(y1, y2))
    if(exists('x1') && exists('x2') && exists('y1') && exists('y2')) p = p + coord_cartesian(xlim = c(x1, x2), ylim = c(y1, y2))
    if(exists('xLog') || exists('yLog')){
        library(scales)
        if(exists('xLog')) p = p + scale_x_continuous(trans = log_trans(xLog)) + annotation_logticks(sides = 'b')
        if(exists('yLog')) p = p + scale_y_continuous(trans = log_trans(yLog)) + annotation_logticks(sides = 'l')
        p = p + theme(panel.grid.minor = element_blank())
    }
    if(exists('main')) p = p + ggtitle(main)
    p = p + theme(plot.title = element_text(size = mainS))
    p = p + xlab(xLab) + theme(axis.title.x = element_text(size = xLblS), 
                               axis.text.x = element_text(size = xTxtS, angle = xAngle, vjust = vJust))
    if(exists('yLab')) p = p + ylab(yLab)
    p = p + theme(axis.title.y = element_text(size = yLblS), axis.text.y = element_text(size = yTxtS))
    if(exists('vertical')) p = p + geom_vline(xintercept = vertical, linetype = "longdash", size = 0.3)
    p
}

