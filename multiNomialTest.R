#!/bin/env Rscript

library(EMT)
args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))

usage = function(){
      cat(paste0("Usage: ", scriptName))
      cat(" <input.tsv >mnTest.log 2>mnTest.tsv
Input: probabilities seperated by comma, observations seperated by comma
Option:
    -m|mc           Use Monte Carlo
    -n|nt   INT     The ntrial parameter used by Monte Carlo[100000]
")
	q(save = 'no')
}

useMC = FALSE
ntrial = 100000

if(length(args) >= 1){
    for(i in 1:length(args)){
        arg = args[i]
        if(arg == '-h' || arg == '-help') usage()
        if(arg == '-m' || arg == '-mc') useMC = TRUE
        tmp = parseArgAsNum(arg, 'n(t)?', 'n'); if(!is.null(tmp)) ntrial = tmp
    }
}

data = read.delim(file('stdin'), header = F)

multiNomial = function(x) {
    prob = as.numeric(strsplit(x[1], ',', fixed = T)[[1]])
    obs = as.numeric(strsplit(x[2], ',', fixed = T)[[1]])
    dist = sqrt(sum((obs/sum(obs) - prob)^2))
    mntP = multinomial.test(obs, prob, MonteCarlo = useMC, ntrial = ntrial)$p.value
    testRes = cor.test(prob, obs, method = 'spearman')
    spearmanR = round(testRes$estimate[[1]], 2)
    spearmanP = testRes$p.value
    c(dist, spearmanR, spearmanP, mntP)
}

res = t(apply(data, 1, multiNomial))
qValues = p.adjust(res[,4])

write.table(cbind(res, qValues), stderr(), row.names = F, col.names = F, sep="\t")