#!/usr/bin/env Rscript
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
    Common:
    -p|pdf      FILE    The output figure in pdf[figure.pdf]
    -w|width    INT     The figure width
    -m|main     STR     The main title
    -mainS      DOU     The size of main title[20 for ggplot]
    -x|xlab     STR     The xlab
    -y|ylab     STR     The ylab
    -xl|xlog    INT     Transform the X scale to INT base log
    -yl|ylog    INT     Transform the Y scale to INT base log
    -x1         INT     The xlim start
    -x2         INT     The xlim end
    -y1         INT     The ylim start
    -y2         INT     The ylim end
    -xAngle     [0,360] The angle of tick labels[0]
    -vJust      [0,1]   The vertical justification of tick labels[0.5]
    -ng|noGgplot        Draw figure in the style of R base rather than ggplot
    -l|low      STR     Low color of scale color bar[white]
    -high       STR     High color of scale color bar[red]
    -textV      STR     Add text in the column on to each tile (V3, V4, ...)
    -h|help             Show help

    -a|alpha    DOU     The alpha of tile body
    -alphaV     STR     The column name to apply alpha (V3, V4, ...)
    -alphaT     STR     The title of alpha legend[Alpha]
    -alphaTP    POS     The title position of alpha legend[horizontal: top, vertical:right]
    -alphaLP    POS     The label position of alpha legend[horizontal: top, vertical:right]
    -alphaD     STR     The direction of alpha legend (horizontal, vertical)
    -c|color    STR     The color of tile boundary
    -colorV     STR     The column name to apply color (V3, V4, ...)
    -colorT     STR     The title of color legend[Color]
    -colorTP    POS     The title position of color legend[horizontal: top, vertical:right]
    -colorLP    POS     The label position of color legend[horizontal: top, vertical:right]
    -colorD     STR     The direction of color legend (horizontal, vertical)
    -f|fill     STR     The color of tile body
    -fillV      STR     The column name to apply fill ([V3], V4, ...)
    -fillC              Continuous fill mapping
    -fillT      STR     The title of fill legend[Fill]
    -fillTP     POS     The title position of fill legend[horizontal: top, vertical:right]
    -fillLP     POS     The label position of fill legend[horizontal: top, vertical:right]
    -fillD      STR     The direction of fill legend (horizontal, vertical)
    -scaleFillGradient2           Scale fill with gradient2
    -scaleFillGradient2MidPoint   The midpoint (in data value) of the diverging scale[0]
    -scaleFillGradient2Low   STR  Fill color for low end of the gradient
    -scaleFillGradient2High  STR  Fill color for high end of the gradient
    -l|linetype INT     The line type
    -linetypeV  STR     The column name to apply linetype (V3, V4, ...)
    -linetypeT  STR     The title of linetype legend[Line Type]
    -linetypeTP POS     The title position of linetype legend[horizontal: top, vertical:right]
    -linetypeLP POS     The label position of linetype legend[horizontal: top, vertical:right]
    -linetypeD  STR     The direction of linetype legend (horizontal, vertical)
    -s|size     DOU     The size of tile body
    -sizeV      STR     The column name to apply size (V3, V4, ...)
    -sizeT      STR     The title of size legend[Size]
    -sizeTP     POS     The title position of size legend[horizontal: top, vertical:right]
    -sizeLP     POS     The label position of size legend[horizontal: top, vertical:right]
    -sizeD      STR     The direction of size legend (horizontal, vertical)

    -noGuide            Don't show the legend guide
    -lgPos      POS     The legend position[horizontal: top, vertical:right]
    -lgPosX     [0,1]   The legend relative postion on X
    -lgPosY     [0,1]   The legend relative postion on Y
    -lgTtlS     INT     The legend title size[15]
    -lgTxtS     INT     The legend text size[15]
    -lgBox      STR     The legend box style (horizontal, vertical)

    -facet      STR     The facet type (facet_wrap, facet_grid)
    -facetM     STR     The facet model (eg: '. ~ V3', 'V3 ~ .', 'V3 ~ V4', '. ~ V3 + V4', ...)
    -facetScl   STR     The axis scale in each facet ([fixed], free, free_x or free_y)

    -xPer               Show X label in percentage
    -yPer               Show Y label in percentage
    -xComma             Show X label number with comma seperator
    -yComma             Show Y label number with comma seperator
    -axisRatio  DOU     The fixed aspect ratio between y and x units

    -annoTxt    STRs    The comma-seperated texts to be annotated
    -annoTxtX   INTs    The comma-seperated X positions of text
    -annoTxtY   INTs    The comma-seperated Y positions of text
   
    -panelBackgroundFill  STR  The fill color of panel background
    -panelGridMajorBlank       Set the panel major grid as blank
    -panelGridMajorColor  STR  The line color of panel major grid
    -panelGridMinorBlank       Set the panel minor grid as blank
    -panelGridMinorColor  STR  The line color of panel minor grid
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
lgTtlS = 15
lgTxtS = 15
showGuide = TRUE
xAngle = 0
vJust = 0.5
myPdf = 'figure.pdf'
mainS = 20
fillV = 'V3'
low = 'white'
high = 'red'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        
        tmp = parseArgNum(arg, 'a(lpha)?', 'a'); if(!is.null(tmp)) myAlpha = tmp
        tmp = parseArg(arg, 'alphaV', 'alphaV'); if(!is.null(tmp)) alphaV = tmp
        tmp = parseArg(arg, 'alphaT', 'alphaT'); if(!is.null(tmp)) alphaT = tmp
        tmp = parseArg(arg, 'alphaTP', 'alphaTP'); if(!is.null(tmp)) alphaTP = tmp
        tmp = parseArg(arg, 'alphaLP', 'alphaLP'); if(!is.null(tmp)) alphaLP = tmp
        tmp = parseArg(arg, 'alphaD', 'alphaD'); if(!is.null(tmp)) alphaD = tmp
        tmp = parseArg(arg, 'c(olor)?', 'c'); if(!is.null(tmp)) color = tmp
        tmp = parseArg(arg, 'colorV', 'colorV'); if(!is.null(tmp)) colorV = tmp
        tmp = parseArg(arg, 'colorT', 'colorT'); if(!is.null(tmp)) colorT = tmp
        tmp = parseArg(arg, 'colorTP', 'colorTP'); if(!is.null(tmp)) colorTP = tmp
        tmp = parseArg(arg, 'colorLP', 'colorLP'); if(!is.null(tmp)) colorLP = tmp
        tmp = parseArg(arg, 'colorD', 'colorD'); if(!is.null(tmp)) colorD = tmp
        tmp = parseArg(arg, 'f(ill)?', 'f'); if(!is.null(tmp)) fill = tmp
        tmp = parseArg(arg, 'fillV', 'fillV'); if(!is.null(tmp)) fillV = tmp
        if(arg == '-fillC') fillC = TRUE
        if(arg == '-scaleFillGradient2') scaleFillGradient2 = TRUE
        tmp = parseArgNum(arg, 'scaleFillGradient2MidPoint', 'scaleFillGradient2MidPoint'); if(!is.null(tmp)) scaleFillGradient2MidPoint = tmp
        tmp = parseArg(arg, 'scaleFillGradient2Low', 'scaleFillGradient2Low'); if(!is.null(tmp)) scaleFillGradient2Low = tmp
        tmp = parseArg(arg, 'scaleFillGradient2High', 'scaleFillGradient2High'); if(!is.null(tmp)) scaleFillGradient2High = tmp
        tmp = parseArg(arg, 'fillT', 'fillT'); if(!is.null(tmp)) fillT = tmp
        tmp = parseArg(arg, 'fillTP', 'fillTP'); if(!is.null(tmp)) fillTP = tmp
        tmp = parseArg(arg, 'fillLP', 'fillLP'); if(!is.null(tmp)) fillLP = tmp
        tmp = parseArg(arg, 'fillD', 'fillD'); if(!is.null(tmp)) fillD = tmp
        tmp = parseArgNum(arg, 'l(inetype)?', 'l'); if(!is.null(tmp)) linetype = tmp
        tmp = parseArg(arg, 'linetypeV', 'linetypeV'); if(!is.null(tmp)) linetypeV = tmp
        tmp = parseArg(arg, 'linetypeT', 'linetypeT'); if(!is.null(tmp)) linetypeT = tmp
        tmp = parseArg(arg, 'linetypeTP', 'linetypeTP'); if(!is.null(tmp)) linetypeTP = tmp
        tmp = parseArg(arg, 'linetypeLP', 'linetypeLP'); if(!is.null(tmp)) linetypeLP = tmp
        tmp = parseArg(arg, 'linetypeD', 'linetypeD'); if(!is.null(tmp)) linetypeD = tmp
        tmp = parseArgNum(arg, 's(ize)?', 's'); if(!is.null(tmp)) size = tmp
        tmp = parseArg(arg, 'sizeV', 'sizeV'); if(!is.null(tmp)) sizeV = tmp
        tmp = parseArg(arg, 'sizeT', 'sizeT'); if(!is.null(tmp)) sizeT = tmp
        tmp = parseArg(arg, 'sizeTP', 'sizeTP'); if(!is.null(tmp)) sizeTP = tmp
        tmp = parseArg(arg, 'sizeLP', 'sizeLP'); if(!is.null(tmp)) sizeLP = tmp
        tmp = parseArg(arg, 'sizeD', 'sizeD'); if(!is.null(tmp)) sizeD = tmp
        
        if(arg == '-noGuide') showGuide = FALSE
        tmp = parseArg(arg, 'lgPos', 'lgPos'); if(!is.null(tmp)) lgPos = tmp
        tmp = parseArgNum(arg, 'lgPosX', 'lgPosX'); if(!is.null(tmp)) lgPosX = tmp
        tmp = parseArgNum(arg, 'lgPosY', 'lgPosY'); if(!is.null(tmp)) lgPosY = tmp
        tmp = parseArgNum(arg, 'lgTtlS', 'lgTtlS'); if(!is.null(tmp)) lgTtlS = tmp
        tmp = parseArgNum(arg, 'lgTxtS', 'lgTxtS'); if(!is.null(tmp)) lgTxtS = tmp
        tmp = parseArg(arg, 'lgBox', 'lgBox'); if(!is.null(tmp)) lgBox = tmp
        tmp = parseArg(arg, 'facet', 'facet'); if(!is.null(tmp)) myFacet = tmp
        tmp = parseArg(arg, 'facetM', 'facetM'); if(!is.null(tmp)) facetM = tmp
        tmp = parseArg(arg, 'facetScl', 'facetScl'); if(!is.null(tmp)) facetScl = tmp
        if(arg == '-xPer') xPer = TRUE
        if(arg == '-yPer') yPer = TRUE
        if(arg == '-xComma') xComma = TRUE
        if(arg == '-yComma') yComma = TRUE
        tmp = parseArgNum(arg, 'axisRatio', 'axisRatio'); if(!is.null(tmp)) axisRatio = tmp
        tmp = parseArg(arg, 'annoTxt', 'annoTxt'); if(!is.null(tmp)) annoTxt = tmp
        tmp = parseArg(arg, 'annoTxtX', 'annoTxtX'); if(!is.null(tmp)) annoTxtX = tmp
        tmp = parseArg(arg, 'annoTxtY', 'annoTxtY'); if(!is.null(tmp)) annoTxtY = tmp
        tmp = parseArg(arg, 'panelBackgroundFill', 'panelBackgroundFill'); if(!is.null(tmp)) panelBackgroundFill = tmp
        if(arg == '-panelGridMajorBlank') panelGridMajorBlank = TRUE
        tmp = parseArg(arg, 'panelGridMajorColor', 'panelGridMajorColor'); if(!is.null(tmp)) panelGridMajorColor = tmp
        if(arg == '-panelGridMinorBlank') panelGridMinorBlank = TRUE
        tmp = parseArg(arg, 'panelGridMinorColor', 'panelGridMinorColor'); if(!is.null(tmp)) panelGridMinorColor = tmp
        
        if(arg == '-h' || arg == '-help') usage()
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) width = tmp
        if(arg == '-ng' || arg == '-noGgplot') noGgplot = TRUE
        tmp = parseArg(arg, 'l(ow)?', 'l'); if(!is.null(tmp)) low = tmp
        tmp = parseArg(arg, 'high', 'high'); if(!is.null(tmp)) high = tmp
        tmp = parseArgNum(arg, 'x1', 'x1'); if(!is.null(tmp)) x1 = tmp
        tmp = parseArgNum(arg, 'x2', 'x2'); if(!is.null(tmp)) x2 = tmp
        tmp = parseArgNum(arg, 'y1', 'y1'); if(!is.null(tmp)) y1 = tmp
        tmp = parseArgNum(arg, 'y2', 'y2'); if(!is.null(tmp)) y2 = tmp
        tmp = parseArgNum(arg, 'xl(og)?', 'xl'); if(!is.null(tmp)) xLog = tmp
        tmp = parseArgNum(arg, 'yl(og)?', 'yl'); if(!is.null(tmp)) yLog = tmp
        tmp = parseArg(arg, 'm(ain)?', 'm'); if(!is.null(tmp)) main = tmp
        tmp = parseArgNum(arg, 'mainS', 'mainS'); if(!is.null(tmp)) mainS = tmp
        tmp = parseArg(arg, 'x(lab)?', 'x'); if(!is.null(tmp)) xLab = tmp
        tmp = parseArg(arg, 'y(lab)?', 'y'); if(!is.null(tmp)) yLab = tmp
        tmp = parseArgAsNum(arg, 'xAngle', 'xAngle'); if(!is.null(tmp)) xAngle = tmp
        tmp = parseArgAsNum(arg, 'vJust', 'vJust'); if(!is.null(tmp)) vJust = tmp
        tmp = parseArg(arg, 'textV', 'textV'); if(!is.null(tmp)) textV = tmp
    }
}

if(exists('width')){
    pdf(myPdf, width = width)
}else{
    pdf(myPdf)
}

data = read.delim(file('stdin'), header = F)

if(exists('noGgplot')){
    suppressPackageStartupMessages(library(gplots))
    attach(data)
    uV1 = unique(V1); luV1 = length(uV1)
    uV2 = rev(unique(V2)); luV2 = length(uV2)
    z = matrix(nrow = luV1, ncol = luV2)
    rownames(z) = uV1
    colnames(z) = uV2
    text = z
    if(!exists('textV')) textV = 'V3'
    for(i in 1:nrow(data)){
        z[as.character(data[i, 1]), as.character(data[i, 2])] = data[i, 3]
        myCmd = paste0('text[as.character(data[i, 1]), as.character(data[i, 2])] = as.character(data$', textV, '[i])')
        eval(parse(text = myCmd))
    }
    colorN = max(max(V3)-min(V3), length(V3))
    myCmd = 'image(x = 1:luV1, y = 1:luV2, z = z, axes = FALSE, col = colorpanel(colorN, low, high), useRaster = T'
    if(exists('xLab')) myCmd = paste0(myCmd, ', xlab = xLab')
    if(exists('yLab')) myCmd = paste0(myCmd, ', ylab = yLab')
    myCmd = paste0(myCmd, ')')
    if(exists('main')){
        myCmd = paste0(myCmd, '; title(main')
        if(exists('mainS')) myCmd = paste0(myCmd, ', cex.main = mainS/10')
        myCmd = paste0(myCmd, ')')
    }
    eval(parse(text = myCmd))
    
    axis(1, at = 1:luV1, labels = uV1)
    axis(2, at = 1:luV2, labels = uV2)
    for(r in 1:nrow(z)){
        for(c in 1:ncol(z)){
            text(x = r, y = c, labels = text[r, c])
        }
    }
}else{
    library(ggplot2)
    p = ggplot(data, aes(factor(V1, levels = unique(V1)), factor(V2, levels = unique(V2))))
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
        myCmd = paste0('p = p + aes(color = factor(', colorV, '))'); eval(parse(text = myCmd))
        myCmd = 'p = p + guides(color = guide_legend(colorT'
        if(exists('colorTP')) myCmd = paste0(myCmd, ', title.position = colorTP')
        if(exists('colorLP')) myCmd = paste0(myCmd, ', label.position = colorLP')
        if(exists('colorD')) myCmd = paste0(myCmd, ', direction = colorD')
        myCmd = paste0(myCmd, '))')
        eval(parse(text = myCmd))
    }
    if(exists('fillC')){
        p = p + aes_string(fill = fillV) + scale_fill_continuous(name = fillT, low = low, high = high)
    }else{
        if(exists('scaleFillGradient2')){
            myCmd = "p = p + aes_string(fill = fillV) + scale_fill_gradient2(name = fillT, mid = 'white'"
            if(exists('scaleFillGradient2MidPoint')) myCmd = paste0(myCmd, ', midpoint = scaleFillGradient2MidPoint')
            if(exists('scaleFillGradient2Low')) myCmd = paste0(myCmd, ', low = scaleFillGradient2Low')
            if(exists('scaleFillGradient2High')) myCmd = paste0(myCmd, ', high = scaleFillGradient2High')
            myCmd = paste0(myCmd, ')')
        }else{
            myCmd = paste0('p = p + aes(fill = factor(', fillV, ')) + guides(fill = guide_legend(fillT')
            if(exists('fillTP')) myCmd = paste0(myCmd, ', title.position = fillTP')
            if(exists('fillLP')) myCmd = paste0(myCmd, ', label.position = fillLP')
            if(exists('fillD')) myCmd = paste0(myCmd, ', direction = fillD')
            myCmd = paste0(myCmd, '))')
        }
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
    
    myCmd = paste0('p = p + geom_tile(show.legend = showGuide')
    if(exists('myAlpha')) myCmd = paste0(myCmd, ', alpha = myAlpha')
    if(exists('color')) myCmd = paste0(myCmd, ', color = color')
    if(exists('fill')) myCmd = paste0(myCmd, ', fill = fill')
    if(exists('linetype')) myCmd = paste0(myCmd, ', linetype = linetype')
    if(exists('size')) myCmd = paste0(myCmd, ', size = size')
    myCmd = paste0(myCmd, ')')
    
    if(exists('myFacet')){
        myCmd = paste0(myCmd, ' + ', myFacet, '("' + facetM + '"')
        if(exists('facetScl')) myCmd = paste0(myCmd, ', scale = facetScl')
        myCmd = paste0(myCmd, ')')
    }
    eval(parse(text = myCmd))
    
    if(exists('textV')) p = p + geom_text(aes_string(label = textV))
    
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
    if(exists('panelBackgroundFill')) p = p + theme(panel.background = element_rect(fill = panelBackgroundFill))
    if(exists('panelGridMajorBlank')) p = p + theme(panel.grid.major = element_blank())
    if(exists('panelGridMajorColor')) p = p + theme(panel.grid.major = element_line(color = panelGridMajorColor))
    if(exists('panelGridMinorBlank')) p = p + theme(panel.grid.minor = element_blank())
    if(exists('panelGridMinorColor')) p = p + theme(panel.grid.minor = element_line(color = panelGridMinorColor))
    
    if(exists('x1') && exists('x2')) p = p + coord_cartesian(xlim = c(x1, x2))
    if(exists('y1') && exists('y2')) p = p + coord_cartesian(ylim = c(y1, y2))
    if(exists('x1') && exists('x2') && exists('y1') && exists('y2')) p = p + coord_cartesian(xlim = c(x1, x2), ylim = c(y1, y2))
    if(exists('xLog') || exists('yLog')){
        library(scales)
        if(exists('xLog')) p = p + scale_x_continuous(trans = log_trans(xLog))
        if(exists('yLog')) p = p + scale_y_continuous(trans = log_trans(yLog))
        p = p + annotation_logticks() + theme(panel.grid.minor = element_blank())
    }
    if(exists('main')) p = p + ggtitle(main)
    p = p + theme(plot.title = element_text(size = mainS, hjust = 0.5))
    if(exists('xLab')) p = p + xlab(xLab) + theme(
                                                  axis.title.x = element_text(size = mainS*0.8)
                                                , axis.text.x = element_text(size = mainS*0.7, angle = xAngle, vjust = vJust)
                                                )
    if(exists('yLab')) p = p + ylab(yLab) + theme(axis.title.y = element_text(size = mainS*0.8)
                                                , axis.text.y = element_text(size = mainS*0.7)
                                                )
    p
}
