#!/usr/bin/env Rscript

args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
    sink(stderr())
    cat("Usage: scriptName.R -option=value <input.tsv
Option:
    -p|pdf    PDF  The KM figure[KM.pdf]
    -w|width  INT  The figure width
       height INT  The figure height
       header      With header
    -m|main   STR  The main title
    -x|xlab   STR  The xlab[Time]
    -y|ylab   STR  The ylab[Survival Probability]

    -h             Show help
Input (header isn't necessary):
  Example1:
    #time  event
    1      TRUE
    2      FALSE
    5      FALSE
    10     TRUE
  Example2:
    #time  event  group
    1      TRUE   male
    2      FALSE  male
    5      FALSE  female
    10     TRUE   female
")
    sink()
    q(save = 'no')
}

myPdf = 'KM.pdf'
header = FALSE
main = 'Kaplan-Meier Estimate'
xlab = 'Time'
ylab = 'Survival Probability'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        
        tmp = parseArg(arg, 'p(df)?', 'pdf'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) width = tmp
        tmp = parseArgNum(arg, 'height', 'height'); if(!is.null(tmp)) height = tmp
        if(arg == '-header') header = TRUE
        tmp = parseArg(arg, 'm(ain)?', 'main'); if(!is.null(tmp)) main = tmp
        tmp = parseArg(arg, 'x(lab)?', 'xlab'); if(!is.null(tmp)) xlab = tmp
        tmp = parseArg(arg, 'y(lab)?', 'ylab'); if(!is.null(tmp)) ylab = tmp
        
        if(arg == '-h') usage()
    }
}

sink(stderr())
cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:'))
cat('\npdf\t'); cat(myPdf)
cat('\nwidth\t'); if(exists('width')) cat(width)
cat('\nheight\t'); if(exists('height')) cat(height)
cat('\nheader\t'); cat(header)
cat('\nmain\t'); if(exists('main')) cat(main)
cat('\nxlab\t'); cat(xlab)
cat('\nylab\t'); cat(ylab)
cat('\n\n')
sink()

myCmd = 'pdf(myPdf'
if(exists('width')) myCmd = paste0(myCmd, ', width = width')
if(exists('height')) myCmd = paste0(myCmd, ', height = height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))


data = read.delim(file('stdin'), header = header)
if(ncol(data) <= 2){
    data = cbind(data, V3 = rep('dummy', nrow(data)))
}else{
    data = subset(data, !is.na(data[[3]]))
    data = data[order(data[[3]]), ]
}


if(header == TRUE){
    col1Name = colnames(data)[1]
    col2Name = colnames(data)[2]
    if(ncol(data) <= 2){
        col3Name = 'V3'
    }else{
        col3Name = colnames(data)[3]
    }
}else{
    col1Name = 'V1'
    col2Name = 'V2'
    col3Name = 'V3'
}

attach(data)
myCmd = paste0('commonFormula = Surv(', col1Name, ', ', col2Name, ') ~ ', col3Name); eval(parse(text = myCmd))

myGroup = unique(data[[3]])
groupN = length(myGroup)
if(groupN > 1){
    cat(paste0('[INFO] ', Sys.time(), ' SurDiff...\n'))
    suppressMessages(library(survival))
    myCmd = paste0('surDiff = survdiff(Surv(', col1Name, ', ', col2Name, ') ~ ', col3Name, ')'); eval(parse(text = myCmd))
    pValue = pchisq(surDiff$chisq, df = length(surDiff$n) - 1, lower.tail = FALSE)
    main = paste0(main, '\nP-value = ', pValue)
    surDiff
}


##### 1 Draw with rms
cat(paste0('[INFO] ', Sys.time(), ' Draw with rms...\n'))
suppressMessages(library(rms))
survRes = npsurv(commonFormula, data = data)
myCmd = "survplot(survRes, xlab = xlab, ylab = ylab, lty = 1, n.risk = TRUE, label.curves = list(method='arrow', col=1:groupN), levels.only = TRUE, col = 1:groupN, lwd = 1.5"
#if(groupN > 1) myCmd = paste0(myCmd, ", conf = 'diffbands'")
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

title(main = main, cex.main = 2)

if(groupN == 2){
    myCmd = "survdiffplot(survRes, n.risk = TRUE, xlab = xlab, col = 1:groupN, lwd = 1.5"
    myCmd = paste0(myCmd, ')')
    eval(parse(text = myCmd))
    title(main = paste0('Difference of Survival Probability\nP-value = ', pValue), cex.main = 2)
}


# ##### 2 Draw with survminer
# cat(paste0('[INFO] ', Sys.time(), ' Draw with survminer...\n'))
# suppressMessages(library(survminer))
# cat(paste0('[INFO] ', Sys.time(), ' survfit...\n'))
# survRes = survfit(commonFormula, data = data)
# cat(paste0('[INFO] ', Sys.time(), ' ggsurvplot...\n'))
# myCmd = paste0("ggsurvplot(survRes, conf.int = TRUE, pval = TRUE, xlab = xlab, ylab = ylab, legend.labs = myGroup, legend.title = '", col3Name, "', size = 0.8, font.main = c(20, 'bold', 'darkblue'), font.x = 16, font.y = 16, font.tickslab = 14, main = main")
# if(exists('linetype')) myCmd = paste0(myCmd, ", linetype = 'strata'")
# if(exists('riskTable')) myCmd = paste0(myCmd, ", risk.table = TRUE, risk.table.col = 'strata'")
# myCmd = paste0(myCmd, ')')
# eval(parse(text = myCmd))


##### 3 Draw with survival
cat(paste0('[INFO] ', Sys.time(), ' Draw with survival...\n'))
print(survRes, print.rmean = TRUE)
summary(survRes)
myCmd = "plot(survRes, main = main, cex.main = 2, cex.lab = 1.3, ylab = ylab, conf.int = TRUE, xlab = xlab, col = 1:groupN, lwd = 1.5"
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

if(groupN > 1) legend("topright", legend = myGroup, lwd = 1.5, col = 1:groupN)
