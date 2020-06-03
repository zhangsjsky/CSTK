#!/bin/env Rscript

library(argparser, quietly = T)

sink(stderr())
p = arg_parser("Draw violin diagram. Input example:
    For ggplot2:
        Group1    1
        Group1    2
        Group2    2
        Group2    4
        Group2    3
    For R base:
        Group1    Group2
        1         2
        2         4
        4         3
Input will be got from STDIN
")

p = add_argument(p, "--pdf", help = "[PDF] The output figure in pdf[violin.pdf]", default = 'violin.pdf')
p = add_argument(p, "--width", help = "[INT] The figure width", type = 'numeric')
p = add_argument(p, "--height", help = "[INT] The figure height", type = 'numeric')
p = add_argument(p, "--horizontal", help = "[DOU] Draw a horizontal dash line at y=INT", short = '-ho', type = 'numeric')
p = add_argument(p, "--main", help = "[STR] The main title")
p = add_argument(p, "--xlab", help = "[STR] The xlab")
p = add_argument(p, "--ylab", help = "[STR] The ylab")
p = add_argument(p, "--xlog", help = "[INT] Transform the X scale to INT base log", type = 'numeric')
p = add_argument(p, "--ylog", help = "[INT] Transform the Y scale to INT base log", type = 'numeric')
p = add_argument(p, "--y1", help = "[DOU] The ylim start", type = 'numeric')
p = add_argument(p, "--y2", help = "[DOU] The ylim end", type = 'numeric')
p = add_argument(p, "--xTitS", help = "[DOU] The X-axis title size", type = 'numeric', default = 20)
p = add_argument(p, "--xTxtS", help = "[DOU] The X-axis text size", type = 'numeric', default = 18)
p = add_argument(p, "--xAngle", help = "[0,360] The angle of tick labels", type = 'numeric', default = 0)
p = add_argument(p, "--yTitS", help = "[DOU] The Y-axis title size", type = 'numeric', default = 20)
p = add_argument(p, "--yTxtS", help = "[DOU] The Y-axis text size", type = 'numeric', default = 18)
p = add_argument(p, "--vJust", help = "[0,1] V justify", type = 'numeric', default = 0.5)
p = add_argument(p, "--hJust", help = "[0,1] H justify", type = 'numeric', default = 0.5)
p = add_argument(p, "--noGgplot", help = "Draw figure in the style of R base rather than ggplot", flag = T, short = '-ng')
p = add_argument(p, "--scale", help = "[STR] Scale the violin by area, count or [width]", default = "width")
p = add_argument(p, "--noJitter", help = "Do not draw jitter", flag = T)
p = add_argument(p, "--colorV", help = "[STR] The column name to apply color (V1, V3, V4,...)")
p = add_argument(p, "--colorC", help = "Continuous color mapping", flag = T)
p = add_argument(p, "--colorT", help = "[STR] The title of color legend[Color]", default = "Color")
p = add_argument(p, "--colorTP", help = "[top/right] The title position of color legend")
p = add_argument(p, "--colorLP", help = "[top/right] The label position of color legend")
p = add_argument(p, "--colorD", help = "[horizonta/vertical] The direction of color legend")
p = add_argument(p, "--fillV", help = "[STR] The column name to apply fill (V1, V3, V4,...)")
p = add_argument(p, "--fillC", help = "Continuous fill mapping", flag = T)
p = add_argument(p, "--scaleFillIdentity", help = "Use the color identity to fill", flag = T)
p = add_argument(p, "--fillT", help = "[STR] The title of fill legend[Fill]", default = "Fill")
p = add_argument(p, "--fillTP", help = "[top/right] The title position of fill legend")
p = add_argument(p, "--fillLP", help = "[top/right] The label position of fill legend")
p = add_argument(p, "--fillD", help = "[horizonta/vertical] The direction of fill legend")
p = add_argument(p, "--xPer", help = "Show X label in percentage", flag = T)
p = add_argument(p, "--yPer", help = "Show Y label in percentage", flag = T)
p = add_argument(p, "--lgPos" , help = "[POS]The legend position[horizontal: top, vertical:right]")
p = add_argument(p, "--lgPosX", help = "[INT] The legend relative postion on X")
p = add_argument(p, "--lgPosY", help = "[INT] The legend relative postion on Y")
p = add_argument(p, "--lgTtlS", help = "[INT]The legend title size[15]", default = 15)
p = add_argument(p, "--lgTxtS", help = "[INT]The legend text size[15]", default = 15)
p = add_argument(p, "--lgBox", help = "[horizontal, vertical] The legend box style")

argv = parse_args(p)
cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:\n'))
str(argv)
cat('\n')
sink()


myCmd = 'pdf(argv$pdf'
if(!is.na(argv$width)) myCmd = paste0(myCmd, ', width = argv$width')
if(!is.na(argv$height)) myCmd = paste0(myCmd, ', height = argv$height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

data = read.delim(file('stdin'), header = F)

if(argv$noGgplot){
    library(vioplot)
    myCmd = 'vioplot(data[[1]]'
    if(ncol(data) >= 2){
        for(i in 2:ncol(data)){
            myCmd = paste0(myCmd, ', data[[', i, ']]')
        }
    }
    if(argv$main) myCmd = paste0(myCmd, ', main = argv$main')
    if(argv$xlab) myCmd = paste0(myCmd, ', xlab = argv$xlab')
    if(argv$ylab) myCmd = paste0(myCmd, ', ylab = argv$ylab')
    myCmd = paste0(myCmd, ')')
    eval(parse(text = myCmd))
    if(argv$horizontal) abline(h = argv$horizontal, lty = 2)
}else{
    library('ggplot2')
    library(scales) # for xPer, yPer
    p = ggplot(data, aes(factor(V1, levels = unique(V1)), V2)) + geom_violin(draw_quantiles = c(0.25, 0.5, 0.75), scale = argv$scale)
    if(!is.na(argv$colorV)){
        if(argv$colorC){
            p = p + aes_string(color = argv$colorV)
        }else{
            myCmd = paste0('p = p + aes(color = factor(', argv$colorV, '))'); eval(parse(text = myCmd))
        }
        myCmd = 'p = p + guides(color = guide_legend(argv$colorT'
        if(argv$colorTP) myCmd = paste0(myCmd, ', title.position = argv$colorTP')
        if(argv$colorLP) myCmd = paste0(myCmd, ', label.position = argv$colorLP')
        if(argv$colorD) myCmd = paste0(myCmd, ', direction = argv$colorD')
        myCmd = paste0(myCmd, '))')
        eval(parse(text = myCmd))
    }
    if(!is.na(argv$fillV)){
        if(argv$fillC){
            p = p + aes_string(fill = argv$fillV)
        }else{
            myCmd = paste0('p = p + aes(fill = factor(', argv$fillV, '))'); eval(parse(text = myCmd))
            if(argv$scaleFillIdentity) p = p + scale_fill_identity()
        }
        myCmd = 'p = p + guides(fill = guide_legend(argv$fillT'
        if(!is.na(argv$fillTP)) myCmd = paste0(myCmd, ', title.position = argv$fillTP')
        if(!is.na(argv$fillLP)) myCmd = paste0(myCmd, ', label.position = argv$fillLP')
        if(!is.na(argv$fillD)) myCmd = paste0(myCmd, ', direction = argv$fillD')
        myCmd = paste0(myCmd, '))')
        eval(parse(text = myCmd))
    }
    if(!is.na(argv$lgPos)) p = p + theme(legend.position = argv$lgPos)
    if(!is.na(argv$lgPosX) && !is.na(argv$lgPosY)) p = p + theme(legend.position = c(argv$lgPosX, argv$lgPosY))
    p = p + theme(legend.title = element_text(size = argv$lgTtlS), legend.text = element_text(size = argv$lgTxtS))
    if(!is.na(argv$lgBox)) p = p + theme(legend.box = argv$lgBox)

    if(argv$xPer) p = p + scale_x_continuous(labels = percent)
    if(argv$yPer) p = p + scale_y_continuous(labels = percent)

    if(!is.na(argv$y1) && !is.na(argv$y2)) p = p + coord_cartesian(ylim = c(argv$y1, argv$y2))
    if(!is.na(argv$xlog) || !is.na(argv$ylog)){
        library(scales)
        if(!is.na(argv$xlog)) p = p + scale_x_continuous(trans = log_trans(argv$xlog)) + annotation_logticks(sides = 'b')
        if(!is.na(argv$ylog)) p = p + scale_y_continuous(trans = log_trans(argv$ylog)) + annotation_logticks(sides = 'l')
    }
    if(!is.na(argv$main)) p = p + ggtitle(argv$main)
    if(!is.na(argv$xlab)) p = p + xlab(argv$xlab)
    p = p + theme(axis.title.x = element_text(size = argv$xTitS), 
                  axis.text.x = element_text(size = argv$xTxtS, angle = argv$xAngle, vjust = argv$vJust, hjust = argv$hJust)
            )
    if(!is.na(argv$ylab)) p = p + ylab(argv$ylab)
    p = p + theme(axis.title.y = element_text(size = argv$yTitS), axis.text.y = element_text(size = argv$yTxtS))
    if(!is.na(argv$horizontal)) p = p + geom_hline(yintercept = argv$horizontal, linetype = "longdash", size = 0.3)
    if(!argv$noJitter) p = p + geom_jitter(alpha = 0.2, height = 0)
    p
}
