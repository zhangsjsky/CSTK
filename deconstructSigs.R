#!/compile/R/R-3.5.2/bin/Rscript

args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
library(deconstructSigs, quiet = T)

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf <input.tsv >weight.tsv
Option:
    -p|pdf            FILE  The output figure in pdf[deconstructSigs.pdf]
    -w|width          INT   The figure width
    -height           INT   The figure height
                      
    -isSig                  The input data is trinucleotide context data
    -libType          STR   The library type(exome, WGS)
    -sigRef           STR   Which signature set as reference([nature2013],cosmic)
    -contextFraction  TSV   Output fraction of trinucleotide context to file

    -h|help             Show help
Input data:
    If the input data are mutation data, it should includes columns for sample ID, chr, pos, ref, alt. Example:
        NA12878 chr1   905907   A   T
        NA12878 chr1  1192480   C   A
        NA12878 chr1  1854885   G   C
        NA12878 chr1  9713992   G   A
        NA12878 chr1 12908093   C   A
        NA12878 chr1 17257855   C   T
    If the input data are trinucleotide context data (-isSig is specified), 
    it should includes columns for sample ID and 96 trinucleotide context. Example:
        Dummy   A[C>A]A     A[C>A]C      A[C>A]G     A[C>A]T     C[C>A]A     C[C>A]C
        NA12878 0.001314202 0.001961651 9.687434e-05 0.002529105 0.005644115 0.003838037
")
    q(save = 'no')
}

myPdf = 'deconstructSigs.pdf'
sigRef = 'nature2013'

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        if(arg == '-h' || arg == '-help') usage()
        tmp = parseArg(arg, 'p(df)?', 'p'); if(!is.null(tmp)) myPdf = tmp
        tmp = parseArgNum(arg, 'w(idth)?', 'w'); if(!is.null(tmp)) width = tmp
        tmp = parseArgNum(arg, 'height', 'height'); if(!is.null(tmp)) height = tmp
        if(arg == '-isSig') isSig = TRUE
        tmp = parseArg(arg, 'libType', 'libType'); if(!is.null(tmp)) libType = tmp
        tmp = parseArg(arg, 'sigRef', 'sigRef'); if(!is.null(tmp)) sigRef = tmp
        tmp = parseArg(arg, 'contextFraction', 'contextFraction'); if(!is.null(tmp)) contextFraction = tmp
    }
}

sink(stderr())
cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:'))
cat('\npdf\t'); cat(myPdf)
cat('\nwidth\t'); if(exists('width')) cat(width)
cat('\nheight\t'); if(exists('height')) cat(height)
cat('\nisSig\t'); if(exists('isSig')) cat(isSig)
cat('\nlibType\t'); if(exists('libType')) cat(libType)
cat('\nsigRef\t'); if(exists('sigRef')) cat(sigRef)
cat('\ncontextFraction\t'); if(exists('contextFraction')) cat(contextFraction)
cat('\n')
sink()

myCmd = 'pdf(myPdf'
if(exists('width')) myCmd = paste0(myCmd, ', width = width')
if(exists('height')) myCmd = paste0(myCmd, ', height = height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

myCmd = paste0('sigs.output = whichSignatures(tumor.ref = sigs.input, signatures.ref = signatures.', sigRef)

if(exists('isSig')){
    sigs.input = read.delim(file('stdin'))
    rownames(sigs.input) = sigs.input[[1]]
    sigs.input[1] = NULL
    newName = sub('\\.', '[', colnames(sigs.input))
    newName = sub('\\.', '>', newName)
    newName = sub('\\.', ']', newName)
    colnames(sigs.input) = newName
}else{
    data = read.delim(file('stdin'), header = F)
    sigs.input = mut.to.sigs.input(mut.ref = data, 
                                sample.id = "V1", 
                                chr = "V2", 
                                pos = "V3", 
                                ref = "V4", 
                                alt = "V5")
		if(exists('libType')){
		    if(libType == 'WGS') libType = 'genome'
		    tri.counts.method = libType
		}else{
		    tri.counts.method  = 'default'
		}
    myCmd = paste0(myCmd, ', contexts.needed = TRUE, tri.counts.method = tri.counts.method')
}

sampleID = unique(rownames(sigs.input))

myCmd = paste0(myCmd, ', sample.id = sampleID)')
sink(stderr())
myCmd
sink()
eval(parse(text = myCmd))

plotSignatures(sigs.output, sub = 'Signature')

makePie(sigs.output, sub = 'Signature')


weigths = sigs.output$weights[,sigs.output$weights>0]
write.table(t(weigths), stdout(), quote = F, sep = "\t", col.names = F)

if(exists('contextFraction')){
    fractions = t(sigs.output$tumor)
    write.table(fractions, contextFraction, quote = F, sep = "\t", col.names = F)
}
