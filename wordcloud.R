#!/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
library(wordcloud, quietly = T)
library(tm, quietly = T)
library(tools, quietly = T)

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf input1.tsv inpu2.tsv [input3.tsv ...]
Option:
    Common:
    -p|pdf      FILE    The output figure in pdf[figure.pdf]
    -w|width    INT     The figure width
    -m|main     STR     The main title
    -mainS      DOU     The size of main title[2]

    -m|minFreq  INT     Words with frequency below this will not be plotted[1]
    -r|rmWords  STRs    Words won't be drawn [may,upon,will,yet]
    -cmpCloud           Draw comparison cloud
    -cmnCloud           Draw commonality cloud
    -rmPunc             Remove punctuation
    -f|font     STR     Set the font (serif, sans serif, serif symbol, sans serif symbol, script, gothic english)
    -fontStyle  STR     The font style ([plain], italic, bold)
    -h|help             Show help
")
  q(save='no')
}

if(length(args) == 0){
  usage()
}

myPdf = 'wordcloud.pdf'
mainS = 2
minFreq = 1
rmWords = c('may', 'upon', 'will', 'yet')
fontStyle = 'plain'

for(i in 1:length(args)){
    arg = args[i]
    
    tmp = parseArgAsNum(arg, 'm(inFreq)?', 'm')
    if(!is.null(tmp)){
        minFreq = tmp
        args[i] = NA
        next
    }
    tmp = parseArgStrs(arg, 'r(mWords)?', 'r')
    if(!is.null(tmp)){
        rmWords = tmp
        args[i] = NA
        next
    }
    if(arg == '-cmpCloud'){
        cmpCloud = TRUE
        args[i] = NA
        next
    }
    if(arg == '-cmnCloud'){
        cmnCloud = TRUE
        args[i] = NA
        next
    }
    if(arg == '-rmPunc'){
        rmPunc = TRUE
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'f(ont)?', 'f')
    if(!is.null(tmp)){
        font = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'fontStyle', 'fontStyle')
    if(!is.null(tmp)){
        fontStyle = tmp
        args[i] = NA
        next
    }
    
    if(arg == '-h' || arg == '-help') usage()
    tmp = parseArg(arg, 'p(df)?', 'p')
    if(!is.null(tmp)){
        myPdf = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'w(idth)?', 'w')
    if(!is.null(tmp)){
        width = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'm(ain)?', 'm')
    if(!is.null(tmp)){
        main = tmp
        args[i] = NA
        next
    }
    tmp = parseArgAsNum(arg, 'mainS', 'mainS')
    if(!is.null(tmp)){
        mainS = tmp
        args[i] = NA
        next
    }
}

args = args[!is.na(args)]
if(length(args) < 1) stop('Please specify input file(s)')

if(exists('width')){
    pdf(myPdf, width = width)
}else{
    pdf(myPdf)
}

docs = list()
for(i in 1:length(args)){
    newDoc = as.data.frame(scan(args[i], what = "", strip.white = TRUE, quiet = TRUE))
    docs = c(docs, newDoc)
}

rcorp = Corpus(VectorSource(docs))
if(exists('rmPunc')) rcorp = tm_map(rcorp, removePunctuation)
rcorp = tm_map(rcorp, stripWhitespace)
rmWords = c(stopwords(), rmWords)
rcorp = tm_map(rcorp, function(x) removeWords(x, rmWords))
rterms = TermDocumentMatrix(rcorp)
rterms = as.matrix(rterms)
colnames(rterms) = basename(file_path_sans_ext(args))

if(length(args) == 1){
    myCmd = "wordcloud(rcorp, colors = brewer.pal(6, 'Dark2'), min.freq = minFreq, random.order = FALSE"
    if(exists('font')) myCmd = paste0(myCmd, ', vfont = c(font, fontStyle)')
    myCmd = paste0(myCmd, ')')
    eval(parse(text = myCmd))
}else{
    if(exists('cmpCloud')){
        comparison.cloud(rterms, max.words = Inf)
    }
    if(exists('cmnCloud')){
        commonality.cloud(rterms, max.words= Inf, random.order = FALSE)
    }
}

if(exists('main')) title(main, cex.main = mainS)

rterms