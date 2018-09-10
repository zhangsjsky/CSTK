#!/bin/env Rscript
args <- commandArgs(TRUE)

usage = function(){
  cat('Usage: scriptName.R -p=output.pdf input1.data inpu2.data [input3.data ...]\n',file=stderr())
  cat('Option:\n',file=stderr())
  cat('\t-p|-pdf\t\tFILE\tThe output figure in pdf[violins.pdf]\n',file=stderr())
  cat('\t-w|-width\tINT\tThe figure width\n',file=stderr())
  cat('\t-s|-scale\tSTR\tScale the violin by [area], count or width\n',file=stderr())
  cat('\t-x1\t\tINT\t(Optional) The xlim start\n',file=stderr())
  cat('\t-x2\t\tINT\t(Optional) The xlim end\n',file=stderr())
  cat('\t-m|main\t\tSTR\t(Optional) The main title\n',file=stderr())
  cat('\t-x|xlab\t\tSTR\t(Optional) The xlab\n',file=stderr())
  cat('\t-y|ylab\t\tSTR\t(Optional) The ylab\n',file=stderr())
  cat('\t-ng|-noGgplot\t\tDraw figure in the style of R base rather than ggplot\n',file=stderr())
  cat('\t-h\t\t\tShow help\n',file=stderr())
  q(save='no')
}

if(length(args) == 0){
  usage()
}

myPdf = 'violins.pdf'
myScale = 'area'

for(i in 1:length(args)){
  arg=args[i]
  if(arg == '-h'){
    usage()
  }
  if(grepl('^-p(df)?=', arg)){
    arg.split = strsplit(arg, '=', fixed = T)[[1]]
    if(is.na(arg.split[2])){
      stop('Please specify the value of -p')
    }else{
      myPdf = arg.split[2]
    }
    args[i] = NA
  }
  if(grepl('^-w(idth)?=', arg)){
    arg.split = strsplit(arg, '=', fixed = T)[[1]]
    if(is.na(arg.split[2])){
      stop('Please specify the value of -w')
    }else{
      myWidth = as.numeric(arg.split[2])
    }
    args[i] = NA
  }
  if(grepl('^-s(cale)?=', arg)){
    arg.split = strsplit(arg, '=', fixed = T)[[1]]
    if(is.na(arg.split[2])){
      stop('Please specify the value of -s')
    }else{
      myScale = arg.split[2]
    }
    args[i] = NA
  }
  if(arg == '-ng' || arg == '-noGgplot'){
    noGgplot = TRUE
    args[i] = NA
  }
  if(grepl('^-x1=', arg)){
    arg.split = strsplit(arg, '=', fixed = T)[[1]]
    if(is.na(arg.split[2])){
      stop('Please specify the value of -x1')
    }else{
      x1 = as.numeric(arg.split[2])
    }
    args[i] = NA
  }
  if(grepl('^-x2=', arg)){
    arg.split = strsplit(arg, '=', fixed = T)[[1]]
    if(is.na(arg.split[2])){
      stop('Please specify the value of -x2')
    }else{
      x2 = as.numeric(arg.split[2])
    }
    args[i] = NA
  }
  if(grepl('^-m(ain)?=', arg)){
    arg.split = strsplit(arg, '=', fixed = T)[[1]]
    if(is.na(arg.split[2])){
      stop('Please specify the value of -m')
    }else{
      myMain = arg.split[2]
    }
    args[i] = NA
  }
  if(grepl('^-x(lab)?=', arg)){
    arg.split = strsplit(arg, '=', fixed = T)[[1]]
    if(is.na(arg.split[2])){
      stop('Please specify the value of -x')
    }else{
      myXlab = arg.split[2]
    }
    args[i] = NA
  }
  if(grepl('^-y(lab)?=', arg)){
    arg.split = strsplit(arg, '=', fixed = T)[[1]]
    if(is.na(arg.split[2])){
      stop('Please specify the value of -y')
    }else{
      myYlab = arg.split[2]
    }
    args[i] = NA
  }
}

args = args[!is.na(args)]
if(length(args) < 2){
  stop('Please specify two input files at least')
}
library(tools)
if(exists('myWidth')){
  pdf(myPdf, width = myWidth)
}else{
  pdf(myPdf)
}

fileNames = basename(file_path_sans_ext(args))

if(exists('noGgplot')){
  library(vioplot)
  myDataCmd = paste0('data', fileNames[1], ' = read.delim(args[1], header = F)')
  myCmd = paste0('vioplot(data', fileNames[1], '$V1')
  for(i in 2:length(args)){
    myDataCmd = paste0(myDataCmd, '; data', fileNames[i], ' = read.delim(args[', i, '], header = F)')
    myCmd = paste0(myCmd, ', data', fileNames[i], '$V1')
  }
  eval(parse(text = myDataCmd))
  if(exists('x1') && exists('x2')){
    myCmd = paste0(myCmd, ', xlim = c(x1, x2)')
  }
  if(exists('myMain')){
    myCmd = paste0(myCmd, ', main = myMain')
  }
  if(exists('myXlab')){
    myCmd = paste0(myCmd, ', xlab = myXlab')
  }
  if(exists('myYlab')){
    myCmd = paste0(myCmd, ', ylab = myYlab')
  }
  myCmd = paste0(myCmd, ')')
  eval(parse(text = myCmd))
}else{
  library(ggplot2)
  data = data.frame()
  for(i in 1:length(args)){
    file = args[i]
    newData = read.delim(file, header = F)
    names(newData)[1] = fileNames[i]
    data = rbind(data, stack(newData))
  }
  p = ggplot(data, aes(x = factor(ind), y = values)) + geom_violin(scale = myScale)
  if(exists('x1') && exists('x2')){
    p = p + xlim(x1, x2)
  }
  if(exists('myMain')){
    p = p + ggtitle(myMain)
  }
  if(exists('myXlab')){
    p = p + xlab(myXlab)
  }
  if(exists('myYlab')){
    p = p + ylab(myYlab)
  }
  p
}
