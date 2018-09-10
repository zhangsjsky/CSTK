#!/bin/env Rscript
library(tools)
args <- commandArgs(TRUE)

usage = function(){
  cat('Usage: scriptName.R -p=output.pdf <input.data\n',file=stderr())
  cat('Option:\n',file=stderr())
  cat('\t-p|-pdf\t\tFILE\tThe output figure in pdf[plot.pdf]\n',file=stderr())
  cat('\t-t|-type\tSTR\t\tThe plot type: [p] for point, l for line, b for both point and line, etc...\n',file=stderr())
  cat('\t-c|-cex\t\tINT\t\tThe point size[1]\n',file=stderr())
  cat('\t-x1\t\t\t\t\tINT\t\t(Optional) The xlim start\n',file=stderr())
  cat('\t-x2\t\t\t\t\tINT\t\t(Optional) The xlim end\n',file=stderr())
  cat('\t-y1\t\t\t\t\tINT\t\t(Optional) The ylim start\n',file=stderr())
  cat('\t-y2\t\t\t\t\tINT\t\t(Optional) The ylim end\n',file=stderr())
  cat('\t-f\t\t\t\t\t\t\t\t\t\t\tDraw the Y axis in fraction rather than count\n',file=stderr())
  cat('\t-h -help\t\t\t\t\t\tShow the help\n',file=stderr())
  q(save='no')
}

myPdf='plot.pdf'
myPlotType='p'
myCex=1

if(length(args) >=1){
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
        myPdf=arg.split[2]
      }
    }
    if(grepl('^-t(ype)?=', arg)){
      arg.split = strsplit(arg, '=', fixed = T)[[1]]
      if(is.na(arg.split[2])){
        stop('Please specify the value of -t')
      }else{
        myPlotType=arg.split[2]
      }
    }
    if(grepl('^-c(ex)?=', arg)){
      arg.split = strsplit(arg, '=', fixed = T)[[1]]
      if(is.na(arg.split[2])){
        stop('Please specify the value of -c')
      }else{
        myCex=as.numeric(arg.split[2])
      }
    }
    if(grepl('^-x1=', arg)){
      arg.split = strsplit(arg, '=', fixed = T)[[1]]
      if(is.na(arg.split[2])){
        stop('Please specify the value of -x1')
      }else{
        x1=as.numeric(arg.split[2])
      }
    }
    if(grepl('^-x2=', arg)){
      arg.split = strsplit(arg, '=', fixed = T)[[1]]
      if(is.na(arg.split[2])){
        stop('Please specify the value of -x2')
      }else{
        x2=as.numeric(arg.split[2])
      }
    }
    if(grepl('^-y1=', arg)){
      arg.split = strsplit(arg, '=', fixed = T)[[1]]
      if(is.na(arg.split[2])){
        stop('Please specify the value of -y1')
      }else{
        y1=as.numeric(arg.split[2])
      }
    }
    if(grepl('^-y2=', arg)){
      arg.split = strsplit(arg, '=', fixed = T)[[1]]
      if(is.na(arg.split[2])){
        stop('Please specify the value of -y2')
      }else{
        y2=as.numeric(arg.split[2])
      }
    }
    if(arg == '-f'){
      fraction=TRUE
    }
  }
}

pdf(myPdf)

data = read.delim(file('stdin'), header=F)

if(exists('fraction')){
  data[2] = data[[2]]/sum(data[2])
}

if(exists('x1') && exists('x2')){
  if(exists('y1') && exists('y2')){
    plot(data[[1]], data[[2]], type=myPlotType, cex=myCex, xlab='X', ylab='Y', xlim=c(x1,x2), ylim=c(y1,y2))
  }else{
    plot(data[[1]], data[[2]], type=myPlotType, cex=myCex, xlab='X', ylab='Y', xlim=c(x1,x2))
  }
}else{
  if (exists('y1') && exists('y2')){
    plot(data[[1]], data[[2]], type=myPlotType, cex=myCex, xlab='X', ylab='Y', ylim=c(y1,y2))
  }else{
    plot(data[[1]], data[[2]], type=myPlotType, cex=myCex, xlab='X', ylab='Y')
  }
}
