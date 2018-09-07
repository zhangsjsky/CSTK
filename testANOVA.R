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
    -p|pdf        PDF  The result figure[result.pdf]
    -w|width      INT  The figure width
       height     INT  The figure height

    -l|las        INT  The direction of tick label ([0]: parallel to axis; 1: horizontal; 2: perpendicular to axis; 3: vertical)
    -c|cexAxis    INT  The size of tick label
       horizontal      Draw boxplot in horizontal

    -f|formula    STR  (Required) The formula of ANOVA

    -h|help            Show help
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
    }
}

sink(stderr())
cat('Check if the following variables are correct as expected:')
cat('\npdf\t'); cat(myPdf)
cat('\nwidth\t'); if(exists('width')) cat(width)
cat('\nheight\t'); if(exists('height')) cat(height)
cat('\nlas\t'); if(exists('las')) cat(las)
cat('\ncexAxis\t'); if(exists('cexAxis')) cat(cexAxis)
cat('\nhorizontal\t'); cat(horizontal)
cat('\nformula\t'); cat(formula)
cat('\n')
sink()

myCmd = 'pdf(myPdf'
if(exists('width')) myCmd = paste0(myCmd, ', width = width')
if(exists('height')) myCmd = paste0(myCmd, ', height = height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

data = read.delim(file('stdin'), header = TRUE)

myCmd = paste0('boxplot(', formula, ', data = data, cex.main = 1.8, outline = FALSE, horizontal = horizontal, main = ', formula)
if(exists('las')) myCmd = paste0(myCmd, ', las = las')
if(exists('cexAxis')) myCmd = paste0(myCmd, ', cex.axis = cexAxis')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

myCmd = paste0('aovRes = aov(', formula, ', data = data)')
eval(parse(text = myCmd))

cat('##### Summary of ANOVA #####\n')
summary(aovRes)

cat('\n\n##### Mean #####\n')
print(model.tables(aovRes, 'means'), digits = 3)
