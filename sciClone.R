#!/usr/bin/env Rscript

args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
maximumClusters=10
minimumDepth=100

usage = function(){
    cat(paste0("Usage: ", scriptName))
    cat(" -c=CNV1.tsv[,CNV2.tsv[,CNV3.tsv]] VAF1.tsv[ VAF2.tsv[ VAF3.tsv]]
       VAF is a tsv file with columns: chr, pos, ref_reads, var_reads, vaf.
       The vaf column is the variant allele frequency ranging from 0-100.
Option:
    -c|cnvFile            TSVs    (Optional) The comma-separated files of segmented copy number with columns:chr, start, stop, segment_mean 
    -s|sample             STRs    (Optional) The comma-separated sample names
    -p|prefix             STR     The prefix for output files[cluster]
       maximumClusters    INT     The max number of clusters to consider when choosing the component fit to the data[8]
       minimumDepth       INT     Threshold used for excluding low-depth variants[100]
    -h|help                       Show help
")
    q(save = 'no')
}

sampleNum = 1
prefix = 'cluster'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        tmp = parseArgStrs(arg, 'c(nvFile)?', 'c')
        if(!is.null(tmp)){
            cnvFiles = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 's(ample)?', 's')
        if(!is.null(tmp)){
            sampleNames = tmp
            args[i] = NA
            next
        }
        tmp = parseArg(arg, 'p(refix)?', 'p')
        if(!is.null(tmp)){
            prefix = tmp
            args[i] = NA
            next
        }
        tmp = parseArgAsNum(arg, 'maximumClusters', 'maximumClusters')
        if(!is.null(tmp)){
            maximumClusters = tmp
            args[i] = NA
            next
        }
        tmp = parseArgAsNum(arg, 'minimumDepth', 'minimumDepth')
        if(!is.null(tmp)){
            minimumDepth = tmp
            args[i] = NA
            next
        }
        if(arg == '-h' || arg == '-help') usage()
    }
    args = args[!is.na(args)]
}else{
    usage()
}

options(rgl.useNULL = TRUE)
suppressMessages(library('sciClone'))

myCmd = 'sc = sciClone(sampleNames = sampleNames, maximumClusters = maximumClusters, minimumDepth = minimumDepth'

if(length(args) == 1){
    if(exists('cnvFiles')){
        cn1 = read.table(cnvFiles[1])
        myCmd = paste0(myCmd, ', copyNumberCalls = cn1')
    }
    if(!exists('sampleNames')) sampleNames = c("Sample1")
    vaf1 = read.table(args[1], header = F)
    myCmd = paste0(myCmd, ', vafs = vaf1)')
    eval(parse(text = myCmd))
}else if(length(args) == 2){
    if(exists('cnvFiles')){
        cn1 = read.table(cnvFiles[1])
        cn2 = read.table(cnvFiles[2])
        myCmd = paste0(myCmd, ', copyNumberCalls = list(cn1, cn2)')
    }
    if(!exists(sampleNames)) sampleNames = c("Sample1", "Sample2")
    vaf1 = read.table(args[1])
    vaf2 = read.table(args[2])
    myCmd = paste0(myCmd, ', vafs = list(vaf1, vaf2))')
    eval(parse(text = myCmd))
    sc.plot2d(sc, paste0(prefix, ".2d.pdf"))
}else{
    if(exists('cnvFiles')){
        cn1 = read.table(cnvFiles[1])
        cn2 = read.table(cnvFiles[2])
        cn3 = read.table(cnvFiles[3])
        myCmd = paste0(myCmd, ', copyNumberCalls = list(cn1, cn2, cn3)')
    }
    if(!exists(sampleNames)) sampleNames = c("Sample1", "Sample2", "Sample3")
    vaf1 = read.table(args[1])
    vaf2 = read.table(args[2])
    vaf3 = read.table(args[3])
    myCmd = paste0(myCmd, ', vafs = list(vaf1, vaf2, vaf3))')
    eval(parse(text = myCmd))
    sc.plot2d(sc, paste0(prefix, ".2d.pdf"))
    sc.plot3d(sc, sc@sampleNames, size = 700, outputFile = paste0(prefix, ".3d.gif"))
}
writeClusterTable(sc, prefix)
sc.plot1d(sc, paste0(prefix, ".1d.pdf"))