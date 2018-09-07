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
p = add_argument(p, "--horizontal", help = "[DOU] Draw a horizontal dash line at y=INT", short = '-ho', type = 'numeric')
p = add_argument(p, "--main", help = "[STR] The main title")
p = add_argument(p, "--xlab", help = "[STR] The xlab")
p = add_argument(p, "--ylab", help = "[STR] The ylab")
p = add_argument(p, "--xlog", help = "[INT] Transform the X scale to INT base log", type = 'numeric')
p = add_argument(p, "--ylog", help = "[INT] Transform the Y scale to INT base log", type = 'numeric')
p = add_argument(p, "--xLblS", help = "[DOU] The X-axis label size", type = 'numeric', default = 20)
p = add_argument(p, "--xTxtS", help = "[DOU] The X-axis text size", type = 'numeric', default = 18)
p = add_argument(p, "--xAngle", help = "[0,360] The angle of tick labels", type = 'numeric', default = 0)
p = add_argument(p, "--yTxtS", help = "[DOU] The y-axis text size", type = 'numeric', default = 18)
p = add_argument(p, "--vJust", help = "[0,1] V justify", type = 'numeric', default = 0.5)
p = add_argument(p, "--hJust", help = "[0,1] H justify", type = 'numeric', default = 0.5)
p = add_argument(p, "--noGgplot", help = "Draw figure in the style of R base rather than ggplot", flag = T, short = '-ng')
p = add_argument(p, "--scale", help = "[STR] Scale the violin by [area], count or width", default = "width")
p = add_argument(p, "--noJitter", help = "Do not draw jitter", flag = T)
p = add_argument(p, "--colorV", help = "[STR] The column name to apply color (V1, V3, V4,...)")
p = add_argument(p, "--colorC", help = "Continuous color mapping", flag = T)
p = add_argument(p, "--colorT", help = "[STR] The title of color legend[Color]", default = "Color")
p = add_argument(p, "--colorTP", help = "[top/right] The title position of color legend")
p = add_argument(p, "--colorLP", help = "[top/right] The label position of color legend")
p = add_argument(p, "--colorD", help = "[horizonta/vertical] The direction of color legend")
argv = parse_args(p)
cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:\n'))
str(argv)
cat('\n')
sink()


if(!is.na(argv$width)){
    pdf(argv$pdf, width = argv$width)
}else{
    pdf(argv$pdf)
}

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
    p = ggplot(data, aes(factor(V1, levels = unique(V1)), V2)) + geom_violin(draw_quantiles = c(0.25, 0.5, 0.75), scale = argv$scale, trim = T)
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
    if(!is.na(argv$xlog) || !is.na(argv$ylog)){
        library(scales)
        if(!is.na(argv$xlog)) p = p + scale_x_continuous(trans = log_trans(argv$xlog)) + annotation_logticks(sides = 'b')
        if(!is.na(argv$ylog)) p = p + scale_y_continuous(trans = log_trans(argv$ylog)) + annotation_logticks(sides = 'l')
    }
    if(!is.na(argv$main)) p = p + ggtitle(argv$main)
    if(!is.na(argv$xlab)) p = p + xlab(argv$xlab)
    p = p + theme(axis.title.x = element_text(size = argv$xLblS), 
                  axis.text.x = element_text(size = argv$xTxtS, angle = argv$xAngle, vjust = argv$vJust, hjust = argv$hJust)
            )
    if(!is.na(argv$ylab)) p = p + ylab(argv$ylab)
    p = p + theme(axis.title.y = element_text(size = argv$yTxtS))
    if(!is.na(argv$horizontal)) p = p + geom_hline(yintercept = argv$horizontal, linetype = "longdash", size = 0.3)
    if(!argv$noJitter) p = p + geom_jitter(alpha = 0.2, height = 0)
    p
}