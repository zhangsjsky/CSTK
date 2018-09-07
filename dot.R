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
    Common:
    -p|pdf      FILE    The output figure in pdf[figure.pdf]
    -w|width    INT     The figure width
    -m|main     STR     The main title
    -mainS      DOU     The size of main title[20 for ggplot]
    -x|xlab     STR     The xlab[Binned Values]
    -y|ylab     STR     The ylab
    -xl|xlog    INT     Transform the X scale to INT base log
    -yl|ylog    INT     Transform the Y scale to INT base log
    -x1         INT     The xlim start
    -x2         INT     The xlim end
    -y1         INT     The ylim start
    -y2         INT     The ylim end
    -ng|noGgplot        Draw figure in the style of R base rather than ggplot
    -h|help             Show help

    ggplot specific:
    
    -binaxis        STR Which axis to bin along([x], y)
    -method         STR [dotdensity] for dot-density binning, histodot for fixed bin widths
    -b|binWidth     DOU The bin width[1/30 of the range of the data]
    -stackdir       STR Which direction to stack the dots([up], down, center, centerwhole)
    -stackratio     DOU How close to stack the dots[1]
    -dotsize        DOU The diameter of the dots relative to binwidth[1]
    -ve|vertical    DOU Draw a vertical line
    
    -a|alpha    DOU     The alpha of dot body
    -alphaV     STR     The column name to apply alpha (V3, V4, ...)
    -alphaT     STR     The title of alpha legend[Alpha]
    -alphaTP    POS     The title position of alpha legend[horizontal: top, vertical:right]
    -alphaLP    POS     The label position of alpha legend[horizontal: top, vertical:right]
    -alphaD     STR     The direction of alpha legend (horizontal, vertical)
    -c|color    STR     The color of dot boundary
    -colorV     STR     The column name to apply color (V3, V4,...)
    -colorC             Continuous color mapping
    -colorT     STR     The title of color legend[Color]
    -colorTP    POS     The title position of color legend[horizontal: top, vertical:right]
    -colorLP    POS     The label position of color legend[horizontal: top, vertical:right]
    -colorD     STR     The direction of color legend (horizontal, vertical)
    -f|fill     STR     The color of dot body
    -fillV      STR     The column name to apply fill (V3, V4,...)
    -fillT      STR     The title of fill legend[Fill]
    -fillTP     POS     The title position of fill legend[horizontal: top, vertical:right]
    -fillLP     POS     The label position of fill legend[horizontal: top, vertical:right]
    -fillD      STR     The direction of fill legend (horizontal, vertical)
                    
    -noGuide            Don't show the legend guide
    -lgPos      POS     The legend position[horizontal: top, vertical:right]
    -lgPosX     [0,1]   The legend relative postion on X
    -lgPosY     [0,1]   The legend relative postion on Y
    -lgTtlS     INT     The legend title size[15]
    -lgTxtS     INT     The legend text size[15]
    -lgBox      STR     The legend box style (horizontal, vertical)

    -fp|flip            Flip the Y axis to horizontal
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
    
Skill:
    Legend title of alpha, color, etc can be set as the same to merge their guides
")
    q(save = 'no')
}

alphaT = 'Alpha'
colorT = 'Color'
fillT = 'Fill'
lgTtlS = 15
lgTxtS = 15
showGuide = TRUE
myPdf = 'figure.pdf'
mainS = 20
xLab='Binned Values'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        
        tmp = parseArg(arg, 'binaxis', 'binaxis'); if(!is.null(tmp)) binaxis = tmp
        tmp = parseArg(arg, 'method', 'method'); if(!is.null(tmp)) method = tmp
        tmp = parseArgAsNum(arg, 'b(inWidth)?', 'b'); if(!is.null(tmp)) binWidth = tmp
        tmp = parseArg(arg, 'stackdir', 'stackdir'); if(!is.null(tmp)) stackdir = tmp
        tmp = parseArgAsNum(arg, 'stackratio', 'stackratio'); if(!is.null(tmp)) stackratio = tmp
        tmp = parseArgAsNum(arg, 'dotsize', 'dotsize'); if(!is.null(tmp)) dotsize = tmp
        tmp = parseArgAsNum(arg, 've(rtical)?', 've'); if(!is.null(tmp)) vertical = tmp
        
        tmp = parseArgAsNum(arg, 'a(lpha)?', 'a'); if(!is.null(tmp)) alpha = tmp
        tmp = parseArg(arg, 'alphaV', 'alphaV'); if(!is.null(tmp)) alphaV = tmp
        tmp = parseArg(arg, 'alphaT', 'alphaT'); if(!is.null(tmp)) alphaT = tmp
        tmp = parseArg(arg, 'alphaTP', 'alphaTP'); if(!is.null(tmp)) alphaTP = tmp
        tmp = parseArg(arg, 'alphaLP', 'alphaLP'); if(!is.null(tmp)) alphaLP = tmp
        tmp = parseArg(arg, 'alphaD', 'alphaD'); if(!is.null(tmp)) alphaD = tmp
        tmp = parseArg(arg, 'c(olor)?', 'c'); if(!is.null(tmp)) color = tmp
        tmp = parseArg(arg, 'colorV', 'colorV'); if(!is.null(tmp)) colorV = tmp
        if(arg == '-colorC') colorC = TRUE
        tmp = parseArg(arg, 'colorT', 'colorT'); if(!is.null(tmp)) colorT = tmp
        tmp = parseArg(arg, 'colorTP', 'colorTP'); if(!is.null(tmp)) colorTP = tmp
        tmp = parseArg(arg, 'colorLP', 'colorLP'); if(!is.null(tmp)) colorLP = tmp
        tmp = parseArg(arg, 'colorD', 'colorD'); if(!is.null(tmp)) colorD = tmp
        tmp = parseArgAsNum(arg, 'f(ill)?', 'l'); if(!is.null(tmp)) fill = tmp
        tmp = parseArg(arg, 'f(ill)?', 'f'); if(!is.null(tmp)) fill = tmp
        tmp = parseArg(arg, 'fillV', 'fillV'); if(!is.null(tmp)) fillV = tmp
        tmp = parseArg(arg, 'fillT', 'fillT'); if(!is.null(tmp)) fillT = tmp
        tmp = parseArg(arg, 'fillTP', 'fillTP'); if(!is.null(tmp)) fillTP = tmp
        tmp = parseArg(arg, 'fillLP', 'fillLP'); if(!is.null(tmp)) fillLP = tmp
        tmp = parseArg(arg, 'fillD', 'fillD'); if(!is.null(tmp)) fillD = tmp

        if(arg == '-noGuide') showGuide = FALSE
        tmp = parseArg(arg, 'lgPos', 'lgPos'); if(!is.null(tmp)) lgPos = tmp
        tmp = parseArgAsNum(arg, 'lgPosX', 'lgPosX'); if(!is.null(tmp)) lgPosX = tmp
        tmp = parseArgAsNum(arg, 'lgPosY', 'lgPosY'); if(!is.null(tmp)) lgPosY = tmp
        tmp = parseArgAsNum(arg, 'lgTtlS', 'lgTtlS'); if(!is.null(tmp)) lgTtlS = tmp
        tmp = parseArgAsNum(arg, 'lgTxtS', 'lgTxtS'); if(!is.null(tmp)) lgTxtS = tmp
        tmp = parseArg(arg, 'lgBox', 'lgBox'); if(!is.null(tmp)) lgBox = tmp
        
        if(arg == '-fp' || arg =='-flip') flip = TRUE
        tmp = parseArg(arg, 'facet', 'facet'); if(!is.null(tmp)) myFacet = tmp
        tmp = parseArg(arg, 'facetM', 'facetM'); if(!is.null(tmp)) facetM = tmp
        tmp = parseArg(arg, 'facetScl', 'facetScl'); if(!is.null(tmp)) facetScl = tmp
        if(arg == '-xPer') xPer = TRUE
        if(arg == '-yPer') yPer = TRUE
        if(arg == '-xComma') xComma = TRUE
        if(arg == '-yComma') yComma = TRUE
        tmp = parseArgAsNum(arg, 'axisRatio', 'axisRatio'); if(!is.null(tmp)) axisRatio = tmp
        tmp = parseArg(arg, 'annoTxt', 'annoTxt'); if(!is.null(tmp)) annoTxt = tmp
        tmp = parseArg(arg, 'annoTxtX', 'annoTxtX'); if(!is.null(tmp)) annoTxtX = tmp
        tmp = parseArg(arg, 'annoTxtY', 'annoTxtY'); if(!is.null(tmp)) annoTxtY = tmp
        
        if(arg == '-h' || arg == '-help') usage()
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgAsNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) width = tmp
        if(arg == '-ng' || arg == '-noGgplot') noGgplot = TRUE
        tmp = parseArgAsNum(arg, 'x1', 'x1'); if(!is.null(tmp)) x1 = tmp
        tmp = parseArgAsNum(arg, 'x2', 'x2'); if(!is.null(tmp)) x2 = tmp
        tmp = parseArgAsNum(arg, 'y1', 'y1'); if(!is.null(tmp)) y1 = tmp
        tmp = parseArgAsNum(arg, 'y2', 'y2'); if(!is.null(tmp)) y2 = tmp
        tmp = parseArgAsNum(arg, 'xl(og)?', 'xl'); if(!is.null(tmp)) xLog = tmp
        tmp = parseArgAsNum(arg, 'yl(og)?', 'yl'); if(!is.null(tmp)) yLog = tmp
        tmp = parseArg(arg, 'm(ain)?', 'm'); if(!is.null(tmp)) main = tmp
        tmp = parseArgAsNum(arg, 'mainS', 'mainS'); if(!is.null(tmp)) mainS = tmp
        tmp = parseArg(arg, 'x(lab)?', 'x'); if(!is.null(tmp)) xLab = tmp
        tmp = parseArg(arg, 'y(lab)?', 'y'); if(!is.null(tmp)) yLab = tmp
    }
}

if(exists('width')){
    pdf(myPdf, width = width)
}else{
    pdf(myPdf)
}

data = read.delim(file('stdin'), header = F)

if(exists('noGgplot')){

}else{
    library(ggplot2)
    p = ggplot(data, aes(x = V1))
    
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
    if(exists('fillV')){
        myCmd = paste0('p = p + aes(fill = ', fillV, ')'); eval(parse(text = myCmd))
        myCmd = 'p = p + guides(fill = guide_legend(fillT'
        if(exists('fillTP')) myCmd = paste0(myCmd, ', title.position = fillTP')
        if(exists('fillLP')) myCmd = paste0(myCmd, ', label.position = fillLP')
        if(exists('fillD')) myCmd = paste0(myCmd, ', direction = fillD')
        myCmd = paste0(myCmd, '))')
        eval(parse(text = myCmd))
    }
    
    myCmd = paste0('p = p + geom_dotplot(show_guide = showGuide, ')
    if(exists('alpha')) myCmd = paste0(myCmd, ', alpha = alpha')
    if(exists('color')) myCmd = paste0(myCmd, ', color = color')
    if(exists('fill')) myCmd = paste0(myCmd, ', fill = fill')
    if(exists('binaxis')) myCmd = paste0(myCmd, ', binaxis = binaxis')
    if(exists('method')) myCmd = paste0(myCmd, ', method = method')
    if(exists('binWidth')) myCmd = paste0(myCmd, ', binwidth = binWidth')
    if(exists('stackdir')) myCmd = paste0(myCmd, ', stackdir = stackdir')
    if(exists('stackratio')) myCmd = paste0(myCmd, ', stackratio = stackratio')
    if(exists('dotsize')) myCmd = paste0(myCmd, ', dotsize = dotsize')
    
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
        if(exists('xLog')) p = p + scale_x_continuous(trans = log_trans(xLog))
        if(exists('yLog')) p = p + scale_y_continuous(trans = log_trans(yLog))
        p = p + annotation_logticks() + theme(panel.grid.minor = element_blank())
    }
    if(exists('main')) p = p + ggtitle(main)
    p = p + theme(plot.title = element_text(size = mainS))
    p = p + xlab(xLab) + theme(axis.title.x = element_text(size = mainS*0.8), axis.text.x = element_text(size = mainS*0.7))
    if(exists('yLab')) p = p + ylab(yLab)
    p = p + theme(axis.title.y = element_text(size = mainS*0.8), axis.text.y = element_text(size = mainS*0.7))
    
    if(exists('vertical')) p = p + geom_vline(xintercept = vertical, linetype = "longdash", size = 0.3)
    p
}