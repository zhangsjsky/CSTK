#!/usr/bin/env Rscript

args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf <input.tsv >pValue
Option:
    -p|pdf          PDF  The output figure in pdf[mcPlot.pdf]
    -mainS          DOU  The size of main title[20]
    -x|xlab         STR  The xlab[Binned Values]
    -y|ylab         STR  The ylab
    -x1             INT  The xlim start
    -x2             INT  The xlim end

    -d|density           Draw Y axis in density
    -b|binWidth     INT  The bin width for hist plot[range/30]
    -o|observation  INT  The observation count
    -h|help              Show help
")
    q(save = 'no')
}

myPdf = 'mcPlot.pdf'
mainS = 20
xLab = 'Binned Values'
yLab = 'Monte Carlo Times'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        
        tmp = parseArg(arg, 'p(df)?', 'pdf'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgNum(arg, 'mainS', 'mainS'); if(!is.null(tmp)) mainS = tmp
        tmp = parseArg(arg, 'x(lab)?', 'x'); if(!is.null(tmp)) xLab = tmp
        tmp = parseArg(arg, 'y(lab)?', 'y'); if(!is.null(tmp)) yLab = tmp
        tmp = parseArg(arg, 'x1', 'x1'); if(!is.null(tmp)) x1 = tmp
        tmp = parseArg(arg, 'x2', 'x2'); if(!is.null(tmp)) x2 = tmp
        
        if(arg == '-d' || arg == '-density') drawDensity = TRUE
        tmp = parseArgNum(arg, 'b(inWidth)?', 'binWidth'); if(!is.null(tmp)) binWidth = tmp
        tmp = parseArgNum(arg, 'o(bservation)?', 'observation'); if(!is.null(tmp)) myObservation = tmp
        
        if(arg == '-h' || arg == '-help') usage()
    }
}

sink(stderr())
cat('Check if the following variables are correct as expected:')
cat('\npdf\t'); cat(myPdf)
cat('\nmainS\t'); cat(mainS)
cat('\nxlab\t'); cat(xLab)
cat('\nylab\t'); cat(yLab)
cat('\nx1\t'); if(exists('x1')) cat(x1)
cat('\nx2\t'); if(exists('x2')) cat(x2)
cat('\ndensity\t'); if(exists('drawDensity')) cat(drawDensity)
cat('\nbinWidth\t'); if(exists('binWidth')) cat(binWidth)
cat('\nobservation\t'); if(exists('observation')) cat(observation)
cat('\n')
sink()

library(ggplot2)

if(exists('width')){
    pdf(myPdf, width = width)
}else{
    pdf(myPdf)
}

data = read.delim(file('stdin'), header = F)

testTime = nrow(data)

gtObservation = length(data[data[1] > myObservation, 1])

pValue = gtObservation / testTime

main = paste0('p-value = ', gtObservation, '/', testTime, ' = ', pValue)

p = ggplot(data, aes(x = V1)) + ggtitle(main) + theme(plot.title = element_text(size = mainS, hjust = 0.5))
if(exists('drawDensity')) p = p + aes(y = ..density..)

myCmd = "p = p + geom_histogram(colour='darkgreen', fill = 'white'"
if(exists('binWidth')) myCmd = paste0(myCmd, ', binwidth = binWidth')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

myCmd = "p = p + geom_freqpoly(colour='darkgreen'"
if(exists('binWidth')) myCmd = paste0(myCmd, ', binwidth = binWidth')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

p = p + xlab(xLab) + theme(axis.title.x = element_text(size = mainS*0.8), axis.text.x = element_text(size = mainS*0.7))
if(exists('yLab')) p = p + ylab(yLab)
p = p + theme(axis.title.y = element_text(size = mainS*0.8), axis.text.y = element_text(size = mainS*0.7))
if(exists('x1') && exists('x2')) p = p + coord_cartesian(xlim = c(x1, x2))

p = p + geom_vline(xintercept = myObservation, linetype = "longdash")

p

cat(pValue, '\n')
