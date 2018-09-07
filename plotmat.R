#!/bin/env Rscript
args <- commandArgs(TRUE)

library(argparser, quietly = T)
library(diagram, quietly = T)


sink(stderr())
p = arg_parser("Draw diagram.
Input (got from STDIN) example:
     A  B  C  D
  A  0  0  0  0
  B  1  0  0  0
  C  2  0  0  0
  D  0  3  4  0
The col and row names above is just showed to present the meaning of col and row, they shouldn't be included in input file.
Used the above input, --name should be specified as 'A,B,C,D'. 
A few lines between A-B, A-C, B-D and C-D will be drawn with the specified values above each line.
")

p = add_argument(p, "--pdf", help = "[PDF] Output pdf", default = 'plotmat.pdf')
p = add_argument(p, "--width", help = "[INT] Pdf width", type = 'numeric')
p = add_argument(p, "--pos", help = "[STRs] Comma-separated positions of each node")
p = add_argument(p, "--name", help = "[STRs] Comma-separated names of each node")
p = add_argument(p, "--curve", help = "[DOU] Draw line as curve with the specified degreee (0-1)", type = 'numeric', default = 0.01)
p = add_argument(p, "--arrWidth", help = "[INT or MAT] The width of line. Can be a INT or a file with matrix", default = '2')
p = add_argument(p, "--arrType", help = "[STR] The arrow type (['curved'], 'triangle', 'circle', 'ellipse', 'T', 'simple')", default = 'curved')
p = add_argument(p, "--arrCol", help = "[STR/MATRIX] The arrow color. Can be a STR or a matrix", default = 'black')
p = add_argument(p, "--dText", help = "[DOU] Controls the position of arrow text relative to arrowhead", type = 'numeric', default = 0.3)
p = add_argument(p, "--cexTxt", help = "[DOU] Relative size of arrow text", type = 'numeric', default = 1)
p = add_argument(p, "--boxType", help = "[STR] The box type of each node (['circle'], 'square', 'diamond', ...)", default = 'circle')
p = add_argument(p, "--shadowSize", help = "[DOU] Shadow size of each node", type = 'numeric', default = 0.01)
p = add_argument(p, "--main", help = "[STR] Figure title")
argv = parse_args(p)
cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:\n'))
str(argv)
cat('\n')
sink()

names = strsplit(argv$name, ',', fixed = T)[[1]]
positions = as.numeric(strsplit(argv$pos, ',', fixed = T)[[1]])
if(file.exists(argv$arrWidth)){
    arrWidth = as.matrix(read.delim(argv$arrWidth, header = F))
    arrWidth= arrWidth/max(arrWidth)*3
}else{
    arrWidth = as.numeric(argv$arrWidth)
}
if(file.exists(argv$arrCol)){
    arrCol = as.matrix(read.delim(argv$arrCol, header = F))
}else{
    arrCol = argv$arrCol
}

if(!is.na(argv$width)){
    pdf(argv$pdf, width = argv$width)
}else{
    pdf(argv$pdf)
}

data = as.matrix(read.delim(file('stdin'), header = F))


myCmd = paste0('plotmat(data, pos = positions, name = names
        , arr.lwd = arrWidth, curve = argv$curve, arr.type = argv$arrType, arr.col = arrCol
        , dtext = argv$dText, cex.txt = argv$cexTxt
        , box.type = argv$boxType, shadow.size = argv$shadowSize
        , relsize = 1.05')
if(!is.na(argv$main)) myCmd = paste0(myCmd, ', main = argv$main')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))