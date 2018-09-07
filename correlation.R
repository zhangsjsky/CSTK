#!/usr/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" [-p=correlation.pdf] <input.tsv >correlation+p-value.tsv
Option:
  Common:
    -p|-pdf        FILE             The output figure in pdf
    -w|-width      INT              The figure width
    -mainS         DOU              The size of main title[16 for ggplot]

    -m|-method     all/pearson      Which correlation coefficient to computed[all] 
                   spearman/kendall

    -xl|-xlog      INT              Transform the x axis to INT base log
    -yl|-ylog      INT              Transform the y axis to INT base log
    -x1            INT              The xlim start
    -x2            INT              The xlim end
    -y1            INT              The ylim start
    -y2            INT              The ylim end
    -x|-xlab       STR              The xlab
    -y|-ylab       STR              The ylab
    -xLblS         DOU              The X-axis label size[20 for ggplot]
    -xTxtS         DOU              The X-axis text size[18 for ggplot]
    -yLblS         DOU              The Y-axis label size[20 for ggplot]
    -yTxtS         DOU              The Y-axis text size[18 for ggplot]

    -a|alpha       DOU              The alpha of point body

    -ng|-noGgplot                   Draw figure in the style of R base rather than ggplot 
    -h                              Show help
")
    q(save='no')
}

mainS = 16
myMethod = 'all'
xLblS = 20
xTxtS = 18
yLblS = 20
yTxtS = 18
showGuide = TRUE

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        if(arg == '-h') usage()
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) width = tmp
        tmp = parseArgNum(arg, 'mainS', 'mainS'); if(!is.null(tmp)) mainS = tmp
        tmp = parseArg(arg, 'm(ethod)?', 'm'); if(!is.null(tmp)) myMethod = tmp
        tmp = parseArgNum(arg, 'xl(og)?', 'xl'); if(!is.null(tmp)) xLog = tmp
        tmp = parseArgNum(arg, 'yl(og)?', 'yl'); if(!is.null(tmp)) yLog = tmp
        tmp = parseArgNum(arg, 'x1', 'x1'); if(!is.null(tmp)) x1 = tmp
        tmp = parseArgNum(arg, 'x2', 'x2'); if(!is.null(tmp)) x2 = tmp
        tmp = parseArgNum(arg, 'y1', 'y1'); if(!is.null(tmp)) y1 = tmp
        tmp = parseArgNum(arg, 'y2', 'y2'); if(!is.null(tmp)) y2 = tmp
        tmp = parseArg(arg, 'x(lab)?', 'x'); if(!is.null(tmp)) xLab = tmp
        tmp = parseArg(arg, 'y(lab)?', 'y'); if(!is.null(tmp)) yLab = tmp
        tmp = parseArgNum(arg, 'xLblS', 'xLblS'); if(!is.null(tmp)) xLblS = tmp
        tmp = parseArgNum(arg, 'xTxtS', 'xTxtS'); if(!is.null(tmp)) xTxtS = tmp
        tmp = parseArgNum(arg, 'yLblS', 'yLblS'); if(!is.null(tmp)) yLblS = tmp
        tmp = parseArgNum(arg, 'yTxtS', 'yTxtS'); if(!is.null(tmp)) yTxtS = tmp
        
        tmp = parseArgNum(arg, 'a(lpha)?', 'a'); if(!is.null(tmp)) myAlpha = tmp
        
        if(arg == '-ng' || arg == '-noGgplot') noGgplot = TRUE
    }
}

sink(stderr())
cat('Check if the following variables are correct as expected:')
cat('\npdf\t'); if(exists('myPdf')) cat(myPdf)
cat('\nwidth\t'); if(exists('width')) cat(width)
cat('\nmainS\t'); cat(mainS)
cat('\nmethod\t'); cat(myMethod)
cat('\nxlog\t'); if(exists('xLog')) cat(xLog)
cat('\nylog\t'); if(exists('yLog')) cat(yLog)
cat('\nx1\t'); if(exists('x1')) cat(x1)
cat('\nx2\t'); if(exists('x2')) cat(x2)
cat('\ny1\t'); if(exists('y1')) cat(y1)
cat('\ny2\t'); if(exists('y2')) cat(y2)
cat('\nxlab\t'); if(exists('xLab')) cat(xLab)
cat('\nylab\t'); if(exists('yLab')) cat(yLab)
cat('\nxLblS\t'); if(exists('xLblS')) cat(xLblS)
cat('\nxTxtS\t'); if(exists('xTxtS')) cat(xTxtS)
cat('\nyLblS\t'); if(exists('yLblS')) cat(yLblS)
cat('\nyTxtS\t'); if(exists('yTxtS')) cat(yTxtS)
cat('\nalpha\t'); if(exists('myAlpha')) cat(myAlpha)
cat('\nnoGgplot\t'); if(exists('noGgplot')) cat(noGgplot)
cat('\n')
sink()

data = read.delim(file('stdin'), header = F)

attach(data)

#jitter = rnorm(nrow(data), sd = 1e-10)
if(myMethod == 'pearson'){
    testRes = cor.test(V1, V2, method = myMethod)
    pearsonR = round(testRes$estimate[[1]], 2)
    pearsonP = testRes$p.value
    main = paste0('PearsonR = ', pearsonR, ', p-value = ', pearsonP)
    Rs = data.frame('Pearson', pearsonR, pearsonP)
}

if(myMethod == 'spearman'){
    testRes = cor.test(V1 , V2 , method = myMethod)
    spearmanR = round(testRes$estimate[[1]], 2)
    spearmanP = testRes$p.value
    main = paste0('SpearmanR = ', spearmanR, ', p-value = ', spearmanP)
    Rs = data.frame('Spearman', spearmanR, spearmanP)
}

if(myMethod == 'kendall'){
    testRes = cor.test(V1, V2, method = myMethod)
    kendallR = round(testRes$estimate[[1]], 2)
    kendallP = testRes$p.value
    main = paste0('KendallR = ', kendallR, ', p-value = ', kendallP)
    Rs = data.frame('Kendall', kendallR, kendallP)
}

if(myMethod == 'all'){
    testRes = cor.test(V1, V2, method = 'pearson')
    pearsonR = round(testRes$estimate[[1]], 2)
    pearsonP = testRes$p.value
    testRes = cor.test(V1, V2, method = 'spearman')
    spearmanR = round(testRes$estimate[[1]], 2)
    spearmanP = testRes$p.value
    testRes = cor.test(V1, V2, method = 'kendall')
    kendallR = round(testRes$estimate[[1]], 2)
    kendallP = testRes$p.value
    main = paste0('PearsonR = ', pearsonR, ', p-value = ', pearsonP,  "\n",
                  'SpearmanR = ', spearmanR, ', p-value = ', spearmanP, "\n",
                  'KendallR = ', kendallR, ', p-value = ', kendallP)
    Rs = rbind(c('Pearson', pearsonR, pearsonP), 
               c('Spearman', spearmanR, spearmanP), 
               c('Kendall', kendallR, kendallP))
}

Rs = as.data.frame(Rs)
write.table(Rs, stdout(), row.names = F, col.names = F, sep = "\t", quote = F)

if(exists('myPdf')){
    if(exists('width')){
        pdf(myPdf, width = width)
    }else{
        pdf(myPdf)
    }
    
    z = lm(V2~V1)
    coefficients = z$coefficients
    intercept = round(coefficients[1], 2)
    slop = round(coefficients[2], 2)
    
    main = paste0(main, "\ny = ", slop, 'x', ' + ', intercept)
    
    if(exists('noGgplot')){
      myCmd = 'plot(V2~V1, main = main'
      logStr = ''
      if(exists('myXlog')) logStr = paste0(logStr, 'x')
      if(exists('myYlog')) logStr = paste0(logStr, 'y')
      if(logStr != '') myCmd = paste0(myCmd, ', log = logStr')
      myCmd = paste0(myCmd, ')')
    
      lines(V1, fitted(z))
      # or use abline(z)
    }else{
        library(ggplot2)
        p = ggplot(data, aes(V1, V2))
        myCmd = 'p = p + geom_abline(intercept = 0, slope = 1, linetype = "longdash", size = 0.3) + geom_point(show.legend = showGuide'
        if(exists('myAlpha')) myCmd = paste0(myCmd, ', alpha = myAlpha')
        myCmd = paste0(myCmd, ')')
        eval(parse(text = myCmd))
        
        p = p + geom_smooth(method = 'lm') +  ggtitle(main) + theme(plot.title = element_text(size = mainS, hjust = 0.5))
        if(exists('xLog') || exists('yLog')){
            library(scales)
            if(exists('xLog')) p = p + scale_x_continuous(trans = log_trans(xLog)) + annotation_logticks(sides = 'b')
            if(exists('yLog')) p = p + scale_y_continuous(trans = log_trans(yLog)) + annotation_logticks(sides = 'l')
            p = p + theme(panel.grid.minor = element_blank())
        }
        if(exists('x1') && exists('x2')) p = p + coord_cartesian(xlim = c(x1, x2))
        if(exists('y1') && exists('y2')) p = p + coord_cartesian(ylim = c(y1, y2))
        if(exists('xLab'))  p = p + xlab(xLab) + theme(axis.title.x = element_text(size = xLblS), axis.text.x = element_text(size = xTxtS))
        if(exists('yLab'))  p = p + ylab(yLab) + theme(axis.title.y = element_text(size = yLblS), axis.text.y = element_text(size = yTxtS))
        p
    }
}
