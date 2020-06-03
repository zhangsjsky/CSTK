#!/usr/bin/env Rscript

args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
suppressMessages(library(ABSOLUTE))

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -s segment.tsv -m mutation.maf -d myDisease -sample mySample
Option:
    -s|segment     TSV     (Required) The segmentation file with Chromosome, Start, End, Num_Probes, Segment_Mean.
                           Header is mandatory.
    -m|maf         MAF     (Optional) A filename pointing to a mutation annotation format file
    
    -r|resultDir   DIR     A directory path to place results. If the directory doesn't already exist, it will be created.[.]
    
    -p|platform    STR     The chip type used, supported values are currently SNP_250K_STY, SNP_6.0 and [Illumina_WES]
    -d|disease     STR     Primary disease of the sample[DiseaseName]
       sample      STR     The name of the sample, included in output plots[SampleName]
")
    q(save = 'no')
}


sigma.p = 0
max.sigma.h = 0.02
min.ploidy = 0.95
max.ploidy = 10
primary.disease = 'DiseaseName'
sample.name = 'SampleName'
platform = 'Illumina_WES'
results.dir = '.'
max.as.seg.count = 1500
max.neg.genome = 0
max.non.clonal = 0
copy_num_type = "total"
min.mut.af = 0


if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        tmp = parseArg(arg, 's(egment)?', 's'); if(!is.null(tmp)) seg.dat.fn = tmp
        tmp = parseArg(arg, 'm(af)?', 'm'); if(!is.null(tmp)) maf.fn = tmp
        
        tmp = parseArg(arg, 'r(esultDir)?', 'r'); if(!is.null(tmp)) results.dir = tmp
        
        tmp = parseArg(arg, 'p(latform)?', 'p'); if(!is.null(tmp)) platform = tmp
        tmp = parseArg(arg, 'd(isease)?', 'd'); if(!is.null(tmp)) primary.disease = tmp
        tmp = parseArg(arg, 'sample', 'sample'); if(!is.null(tmp)) sample.name = tmp
    }
}else{
    usage()
}


cat(paste0('[DEBUG] ', Sys.time(), 'Check if the following variables are correct as expected:'))
cat('\nsegment\t'); if(exists('seg.dat.fn')) cat(seg.dat.fn)
cat('\nmaf\t'); if(exists('maf.fn')) cat(maf.fn)
cat('\nresultDir\t', results.dir)
cat('\nplatform\t', platform)
cat('\ndisease\t', primary.disease)
cat('\nsample\t', sample.name)
cat('\n')


cmd='RunAbsolute(seg.dat.fn, sigma.p, max.sigma.h, min.ploidy, max.ploidy, primary.disease, platform, sample.name, results.dir, max.as.seg.count, max.neg.genome, max.non.clonal, copy_num_type, verbose = TRUE'

if(exists('maf.fn')) cmd = paste0(cmd, ', maf.fn = maf.fn, min.mut.af = min.mut.af')
cmd = paste0(cmd, ')')

cat(paste0('[INFO] ', Sys.time(), ' Start RunAbsolute\n'))
cat(paste0('[CMD] ', Sys.time(), ' ', cmd, '\n'))
eval(parse(text = cmd))
cat(paste0('[INFO] ', Sys.time(), ' Finish RunAbsolute\n'))

obj.name = 'draws'
outdirForSummary = 'summary'
absolute.files = file.path(results.dir, paste0(sample.name, '.ABSOLUTE.RData'))
indv.results.dir = file.path(results.dir, outdirForSummary)
CreateReviewObject(obj.name, absolute.files, indv.results.dir, copy_num_type, verbose = TRUE)

#calls = file.path(results.dir, outdirForSummary, paste0(obj.name, '.PP-calls_tab.txt'))
#modes = file.path(results.dir, outdirForSummary, paste0(obj.name, '.PP-modes.data.RData'))
#output.path = file.path(results.dir, 'extract')
#ExtractReviewedResults(calls, 'myUserID', modes, output.path, obj.name, copy_num_type)
