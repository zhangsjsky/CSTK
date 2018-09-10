#!/usr/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))


usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=result.pdf <input.tsv >result.tsv
Option:
    -p|pdf             PDF  The result figure[result.pdf]
    -w|width           INT  The figure width
       height          INT  The figure height
     
    -l|las             INT  The direction of tick label ([0]: parallel to axis; 1: horizontal; 2: perpendicular to axis; 3: vertical)
    -c|cexAxis         INT  The size of tick label
       horizontal           Draw boxplot in horizontal

    -f|formula         STR  (Required) The formula for lm
       boxplotFormula  STR  The formula to plot boxplot[-formula]
    -s|step                 Do step for lm

    -h|help                 Show help
")
    q(save = 'no')
}

myPdf = 'result.pdf'
horizontal = FALSE

if(length(args) >= 1){
    for(i in 1:length(args)){
        
        arg = args[i]
        
        if(arg == '-h' || arg == '-help') usage()
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) width = tmp
        tmp = parseArgNum(arg, 'height', 'height'); if(!is.null(tmp)) height = tmp
        
        tmp = parseArgNum(arg, 'l(as)?', 'las'); if(!is.null(tmp)) las = tmp
        tmp = parseArgNum(arg, 'c(exAxis)?', 'cexAxis'); if(!is.null(tmp)) cexAxis = tmp
        if(arg == '-horizontal') horizontal = TRUE
        
        tmp = parseArg(arg, 'f(ormula)?', 'formula'); if(!is.null(tmp)) formula = tmp
        tmp = parseArg(arg, 'boxplotFormula', 'boxplotFormula'); if(!is.null(tmp)) boxplotFormula = tmp
        if(arg == '-s' || arg == '-step') myStep = TRUE
    }
}
if(!exists('boxplotFormula')) boxplotFormula = formula

sink(stderr())
cat('Check if the following variables are correct as expected:')
cat('\npdf\t'); cat(myPdf)
cat('\nwidth\t'); if(exists('width')) cat(width)
cat('\nheight\t'); if(exists('height')) cat(height)
cat('\nlas\t'); if(exists('las')) cat(las)
cat('\ncexAxis\t'); if(exists('cexAxis')) cat(cexAxis)
cat('\nhorizontal\t'); cat(horizontal)
cat('\nformula\t'); cat(formula)
cat('\nboxplotFormula\t'); cat(boxplotFormula)
cat('\nstep\t'); if(exists('myStep')) cat(myStep)
cat('\n')
sink()

myCmd = 'pdf(myPdf'
if(exists('width')) myCmd = paste0(myCmd, ', width = width')
if(exists('height')) myCmd = paste0(myCmd, ', height = height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

data = read.delim(file('stdin'), header = TRUE)

myCmd = paste0('boxplot(', boxplotFormula, ', data = data, cex.main = 1.8, outline = FALSE, horizontal = horizontal, main = ', formula)
if(exists('las')) myCmd = paste0(myCmd, ', las = las')
if(exists('cexAxis')) myCmd = paste0(myCmd, ', cex.axis = cexAxis')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

myCmd = paste0('lmRes = lm(', formula, ', data = data)')
eval(parse(text = myCmd))

if(exists('myStep')){
    cat('\n\n##### Step of lm #####\n')
    lmStep = step(lmRes)
}

cat('\n\n##### Summary of lm #####\n')
summary(lmRes)

opar <- par(mfrow = c(2,2), oma = c(0, 0, 1.1, 0))
plot(lmRes, las = 1)

beta.int<-function(fm,alpha = 0.05){
    A = summary(fm)$coefficients
    df = fm$df.residual
    left = A[,1]-A[,2]*qt(1-alpha/2, df)
    right = A[,1]+A[,2]*qt(1-alpha/2, df)
    rowname = dimnames(A)[[1]]
    colname = c("Estimate", "Left", "Right")
    matrix(c(A[,1], left, right), ncol = 3, dimnames =list(rowname, colname))
}
cat('\n\n##### Beta #####\n')
beta.int(lmRes)

cat('\n\n##### Prediction #####\n')
prediction = cbind(data, predict(lmRes, data, interval = "prediction", level = 0.95))
write.table(prediction, file = stdout(), sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)
