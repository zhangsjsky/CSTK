#!/usr/bin/env Rscript

input = read.delim(file = file('stdin'), header=F)
raw = input[[1]]
count = length(raw)

equallyTiedRankFun = function(x){
    length(unique(raw[raw<=x]))
}

percentileRankFun = function(x){
  length(raw[raw<x])/count + length(raw[raw==x])*0.5/count
}

rank = rank(raw, ties.method = 'first')
rev.rank = rank(max(raw) - raw, ties.method = 'first')
equallyTiedRank = sapply(raw, equallyTiedRankFun)
rev.equallyTiedRank = max(equallyTiedRank) - equallyTiedRank + 1
percentileRank = 100 * apply(input, 1, percentileRankFun)
rev.percentileRank = 100 - percentileRank

outputDF = data.frame(Raw=raw, 
                      Rank=rank, revRank=rev.rank, 
                      equallyTiedRank=equallyTiedRank, revEquallyTiedRank=rev.equallyTiedRank, 
                      percentileRank=percentileRank, revPercentileRank=rev.percentileRank)

write.table(outputDF, stdout(), row.names = F, quote = F, sep = "\t")