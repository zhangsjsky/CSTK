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
    -ng|noGgplot        Draw figure in the style of R base rather than ggplot
    -i|index            Use values in the first column as the index on X axis
    -f|-freq            Cumulate frequency rather sum
    -frac               Draw the Y axis in fraction
    -h|help             Show help
    
    ggplot specific:
    -v|vertical     DOUs    The comma-separated X values at which vertical lines are drawn
    -ho|horizontal  DOU     The comma-separated Y values at which horizontal lines are drawn
    -a|alpha        DOU     The alpha of point body
    -c|color        STR     The color of point body
    -l|linetype     INT     The line type
    -s|size         DOU     The size of point body
    
    -noGuide                Don't show the legend guide
    
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
  q(save='no')
}

myPdf = 'figure.pdf'
mainS = 20

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        
        if(arg == '-i' || arg == '-index') withIndex = TRUE
        if(arg == '-f' || arg == '-freq') freq = TRUE
        if(arg == '-frac') fraction = TRUE
        
        tmp = parseArgNums(arg, 'v(ertical)?', 'vertical'); if(!is.null(tmp)) verticals = tmp
        tmp = parseArgNums(arg, 'h(orizontal)?', 'horizontal'); if(!is.null(tmp)) horizontals = tmp
        tmp = parseArgNum(arg, 'a(lpha)?', 'a'); if(!is.null(tmp)) myAlpha = tmp
        tmp = parseArg(arg, 'c(olor)?', 'c'); if(!is.null(tmp)) color = tmp
        tmp = parseArgNum(arg, 'l(inetype)?', 'l'); if(!is.null(tmp)) linetype = tmp
        tmp = parseArgNum(arg, 's(ize)?', 's'); if(!is.null(tmp)) size = tmp
        
        if(arg == '-xPer') xPer = TRUE
        if(arg == '-yPer') yPer = TRUE
        if(arg == '-xComma') xComma = TRUE
        if(arg == '-yComma') yComma = TRUE
        tmp = parseArgNum(arg, 'axisRatio', 'axisRatio'); if(!is.null(tmp)) axisRatio = tmp
        tmp = parseArgStrs(arg, 'annoTxt', 'annoTxt'); if(!is.null(tmp)) annoTxt = tmp
        tmp = parseArgNums(arg, 'annoTxtX', 'annoTxtX'); if(!is.null(tmp)) annoTxtX = tmp
        tmp = parseArgNums(arg, 'annoTxtY', 'annoTxtY'); if(!is.null(tmp)) annoTxtY = tmp
        
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
if(exists('withIndex')){
    index = data$V1
    if(exists('freq')){
        cum = cumsum(table(data$V2))/nrow(data)
    }else{
        cum = cumsum(data$V2)
    }
}else{
    index = 1:nrow(data)
    if(exists('freq')){
        cum = cumsum(table(data$V1))/nrow(data)
    }else{
        cum = cumsum(data$V1)
    }
}
data = data.frame(V1 = index, V2 = cum)
if(exists('fraction')) data$V2 = data$V2/sum(data$V2)
write.table(data, stdout(), row.names = F, col.names = F, sep = "\t", quote = F)

if(exists('noGgplot')){
    myCmd = 'plot(data, type = "l"'
    if(exists('x1') && exists('x2')) myCmd = paste0(myCmd, ', xlim = c(x1, x2)')
    if(exists('main')) myCmd = paste0(myCmd, ', main = main')
    if(exists('xLab')) myCmd = paste0(myCmd, ', xlab = xLab')
    if(exists('yLab')) myCmd = paste0(myCmd, ', ylab = yLab')
    myCmd = paste0(myCmd, ')')
    eval(parse(text = myCmd))
}else{
    library(ggplot2)
    p = ggplot(data)

    myCmd = paste0('p = p + geom_line(aes(V1, V2)')
    if(exists('myAlpha')) myCmd = paste0(myCmd, ', alpha = myAlpha')
    if(exists('color')) myCmd = paste0(myCmd, ', color = color')
    if(exists('linetype')) myCmd = paste0(myCmd, ', linetype = linetype')
    if(exists('size')) myCmd = paste0(myCmd, ', size = size')
    myCmd = paste0(myCmd, ')')
    eval(parse(text = myCmd))
    
    if(exists('xPer')) p = p + scale_x_continuous(labels = percent)
    if(exists('yPer')) p = p + scale_y_continuous(labels = percent)
    if(exists('xComma')) p = p + scale_x_continuous(labels = comma)
    if(exists('yComma')) p = p + scale_y_continuous(labels = comma)
    if(exists('axisRatio')) p = p + coord_fixed(ratio = axisRatio)
    if(exists('annoTxt')) p = p + annotate('text', x = annoTxtX, y = annoTxtY, label = annoTxt)
    
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
    if(exists('xLab')) p = p + xlab(xLab) + theme(axis.title.x = element_text(size = mainS*0.8), axis.text.x = element_text(size = mainS*0.7))
    if(exists('yLab')) p = p + ylab(yLab) + theme(axis.title.y = element_text(size = mainS*0.8), axis.text.y = element_text(size = mainS*0.7))
    
    if(exists('verticals')) p = p + geom_vline(xintercept = verticals, linetype = "longdash", size = 0.3)
    if(exists('horizontals')) p = p + geom_hline(yintercept = horizontals, linetype = "longdash", size = 0.3)
    p
}
