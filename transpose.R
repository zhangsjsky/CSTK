#!/usr/bin/env Rscript
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

data = read.delim(file('stdin'), header = F, check.names = F, colClasses = 'character')

data = t(data)

write.table(data, stdout(), sep="\t", quote = F, col.names = F, row.names = F)