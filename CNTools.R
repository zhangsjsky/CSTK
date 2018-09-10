#!/bin/env Rscript

library(argparser, quietly = T)


p = arg_parser("Comparae CN (Coyp Number) of any paired samples.
Input tsv:
ID                      chrom  loc.start  loc.end  seg.mean
TCGA-06-0126-01A-01     1      554267     639580   0.9002
The header is mandatory. The names of header are also mandatory. Order of columns is non-mandatory.
")
p = add_argument(p, "--pdf", help = "[PDF] Output cluster")
argv = parse_args(p)

sink(stderr())
cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:\n'))
str(argv)
cat('\n')

library(CNTools, quietly = T)

data = read.delim(file('stdin'), header = T, check.names = F)
cnseg <- CNSeg(data)
rdseg <- getRS(cnseg, by = "region", imput = FALSE, XY = FALSE, what = "median")
reducedseg <- rs(rdseg)

if(!is.na(argv$pdf)){
    pdf(argv$pdf)
    hc = hclust(getDist(rdseg, method = "euclidian"), method = "complete") 
    plot(hc, hang = -1, cex = 0.8, main = "", xlab = "", ylab = "", sub = "") 
}


sink()
write.table(reducedseg, stdout(), sep = "\t", quote = F, row.names = F)