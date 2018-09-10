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
    -x|xlab     STR     The xlab
    -y|ylab     STR     The ylab
    -xl|xlog    INT     Transform the X scale to INT base log
    -yl|ylog    INT     Transform the Y scale to INT base log
    -x1         INT     The xlim start
    -x2         INT     The xlim end
    -y1         INT     The ylim start
    -y2         INT     The ylim end
    -h|help             Show help

    -lEnd       STR     Line end style (round, butt, square)
    -lJoin      STR     Line join style (round, mitre, bevel)
    -lMitre     DOU     Line mitre limit (DOU>1)
    -arrow              Draw an arrow at the end of the line
    -arrowAG    INT     The arrow angle[30]
    -arrowED    INT     The arrow end ([last], first, both)
    -arrowTP    INT     The arrow type ([open], closed)
    -a|alpha    DOU     The alpha of line body
    -alphaV     STR     The column name to apply alpha (V3, V4, ...)
    -alphaT     STR     The title of alpha legend[Alpha]
    -alphaTP    POS     The title position of alpha legend[horizontal: top, vertical:right]
    -alphaLP    POS     The label position of alpha legend[horizontal: top, vertical:right]
    -alphaD     STR     The direction of alpha legend (horizontal, vertical)
    -c|color    STR     The color of line body
    -colorV     STR     The column name to apply color (V3, V4,...)
    -colorC             Continuous color mapping
    -colorT     STR     The title of color legend[Color]
    -colorTP    POS     The title position of color legend[horizontal: top, vertical:right]
    -colorLP    POS     The label position of color legend[horizontal: top, vertical:right]
    -colorD     STR     The direction of color legend (horizontal, vertical)
    -b|batch    STR     The column name to apply group (V3, V4,...)
    -batchT     STR     The title of group legend[Group]
    -batchTP    POS     The title position of group legend[horizontal: top, vertical:right]
    -batchLP    POS     The label position of group legend[horizontal: top, vertical:right]
    -batchD     STR     The direction of group legend (horizontal, vertical)
    -l|linetype INT     The line type
    -linetypeV  STR     The column name to apply linetype (V3, V4,...)
    -linetypeT  STR     The title of linetype legend[Line Type]
    -linetypeTP POS     The title position of linetype legend[horizontal: top, vertical:right]
    -linetypeLP POS     The label position of linetype legend[horizontal: top, vertical:right]
    -linetypeD  STR     The direction of linetype legend (horizontal, vertical)
    -s|size     DOU     The size of line body
    -sizeV      STR     The column name to apply size (V3, V4,...)
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
    
Skill:
    Legend title of alpha, color, etc can be set as the same to merge their guides
")
    q(save = 'no')
}

alphaT = 'Alpha'
colorT = 'Color'
batchT = 'Group'
linetypeT = 'Line Type'
sizeT = 'Size'
lgTtlS = 15
lgTxtS = 15
showGuide = TRUE
myPdf = 'figure.pdf'
mainS = 20

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        
        tmp = parseArg(arg, 'lEnd', 'lEnd'); if(!is.null(tmp)) lEnd = tmp
        tmp = parseArg(arg, 'lJoin', 'lJoin'); if(!is.null(tmp)) lJoin = tmp
        tmp = parseArg(arg, 'lMitre', 'lMitre'); if(!is.null(tmp)) lMitre = tmp
        
        if(arg == '-arrow') arrow = TRUE
        tmp = parseArgAsNum(arg, 'arrowAG', 'arrowAG'); if(!is.null(tmp)) arrowAG = tmp
        tmp = parseArg(arg, 'arrowED', 'arrowED'); if(!is.null(tmp)) arrowED = tmp
        tmp = parseArg(arg, 'arrowTP', 'arrowTP'); if(!is.null(tmp)) arrowTP = tmp
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
        tmp = parseArg(arg, 'b(atch)?', 'b'); if(!is.null(tmp)) batch = tmp
        tmp = parseArg(arg, 'batchT', 'batchT'); if(!is.null(tmp)) batchT = tmp
        tmp = parseArg(arg, 'batchTP', 'batchTP'); if(!is.null(tmp)) batchTP = tmp
        tmp = parseArg(arg, 'batchLP', 'batchLP'); if(!is.null(tmp)) batchLP = tmp
        tmp = parseArg(arg, 'batchD', 'batchD'); if(!is.null(tmp)) batchD = tmp
        tmp = parseArgAsNum(arg, 'l(inetype)?', 'l'); if(!is.null(tmp)) linetype = tmp
        tmp = parseArg(arg, 'linetypeV', 'linetypeV'); if(!is.null(tmp)) linetypeV = tmp
        tmp = parseArg(arg, 'linetypeT', 'linetypeT'); if(!is.null(tmp)) linetypeT = tmp
        tmp = parseArg(arg, 'linetypeTP', 'linetypeTP'); if(!is.null(tmp)) linetypeTP = tmp
        tmp = parseArg(arg, 'linetypeLP', 'linetypeLP'); if(!is.null(tmp)) linetypeLP = tmp
        tmp = parseArg(arg, 'linetypeD', 'linetypeD'); if(!is.null(tmp)) linetypeD = tmp
        tmp = parseArgAsNum(arg, 's(ize)?', 's'); if(!is.null(tmp)) size = tmp
        tmp = parseArg(arg, 'sizeV', 'sizeV'); if(!is.null(tmp)) sizeV = tmp
        tmp = parseArg(arg, 'sizeT', 'sizeT'); if(!is.null(tmp)) sizeT = tmp
        tmp = parseArg(arg, 'sizeTP', 'sizeTP'); if(!is.null(tmp)) sizeTP = tmp
        tmp = parseArg(arg, 'sizeLP', 'sizeLP'); if(!is.null(tmp)) sizeLP = tmp
        tmp = parseArg(arg, 'sizeD', 'sizeD'); if(!is.null(tmp)) sizeD = tmp
        
        if(arg == '-noGuide') showGuide = FALSE
        tmp = parseArg(arg, 'lgPos', 'lgPos'); if(!is.null(tmp)) lgPos = tmp
        tmp = parseArgAsNum(arg, 'lgPosX', 'lgPosX'); if(!is.null(tmp)) lgPosX = tmp
        tmp = parseArgAsNum(arg, 'lgPosY', 'lgPosY'); if(!is.null(tmp)) lgPosY = tmp
        tmp = parseArgAsNum(arg, 'lgTtlS', 'lgTtlS'); if(!is.null(tmp)) lgTtlS = tmp
        tmp = parseArgAsNum(arg, 'lgTxtS', 'lgTxtS'); if(!is.null(tmp)) lgTxtS = tmp
        tmp = parseArg(arg, 'lgBox', 'lgBox'); if(!is.null(tmp)) lgBox = tmp
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
    p = ggplot(data)
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
    if(exists('batch')){
        p = p + aes_string(group = batch)
        myCmd = 'p = p + guides(group = guide_legend(batchT'
        if(exists('batchTP')) myCmd = paste0(myCmd, ', title.position = batchTP')
        if(exists('batchLP')) myCmd = paste0(myCmd, ', label.position = batchLP')
        if(exists('batchD')) myCmd = paste0(myCmd, ', direction = batchD')
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
    
    myCmd = paste0('p = p + geom_path(aes(V1, V2), show_guide = showGuide')
    if(exists('lEnd')) myCmd = paste0(myCmd, ', lineend = lEnd')
    if(exists('lJoin')) myCmd = paste0(myCmd, ', linejoin = lJoin')
    if(exists('lMitre')) myCmd = paste0(myCmd, ', lineMitre = lMitre')
    if(exists('alpha')) myCmd = paste0(myCmd, ', alpha = alpha')
    if(exists('color')) myCmd = paste0(myCmd, ', color = color')
    if(exists('linetype')) myCmd = paste0(myCmd, ', linetype = linetype')
    if(exists('size')) myCmd = paste0(myCmd, ', size = size')
    if(exists('arrow')){
        library(grid)
        myCmd = paste0(myCmd, ', arrow = arrow(')
        if(exists('arrowAG')) myCmd = paste0(myCmd, 'angle = arrowAG')
        if(exists('arrowED')) myCmd = paste0(myCmd, ', ends = arrowED')
        if(exists('arrowTP')) myCmd = paste0(myCmd, ', type = arrowTP')
        myCmd = paste0(myCmd, ')')
    }
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
    if(exists('xLab')) p = p + xlab(xLab) + theme(axis.title.x = element_text(size = mainS*0.8), axis.text.x = element_text(size = mainS*0.7))
    if(exists('yLab')) p = p + ylab(yLab) + theme(axis.title.y = element_text(size = mainS*0.8), axis.text.y = element_text(size = mainS*0.7))
    p
}