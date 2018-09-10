#!/usr/bin/env python

import os
import argparse
import sys

parser = argparse.ArgumentParser(description = 'GO mapping (Gene Symbol list)')
help_desc = "Input Symbol list"
parser.add_argument("-i", help=help_desc, required=True)
help_desc = "GO file"
parser.add_argument("-G", help=help_desc, required=True)
help_desc = "ID convert file(NCBI gene info)"
parser.add_argument("-C", help=help_desc, required=True)

args = parser.parse_args()

Symbolfile = args.i
GOfile = args.G
convertfile = args.C

GOdict = {}
with open(GOfile) as data:
	field = data.next().strip().split('\t')
	for line in data:
		line = line.strip().split('\t')
		items = zip(field, line)
		item = {}
		for (name, value) in items:
			item[name] = value
		GeneID = item['GeneID']
		if GeneID in GOdict:
			if item['Category'] == 'Component':
				GOdict[GeneID]['Component'].add(item['GO_term'])
			elif item['Category'] == 'Process':
				GOdict[GeneID]['Process'].add(item['GO_term'])
			elif item['Category'] == 'Function':
				GOdict[GeneID]['Function'].add(item['GO_term'])
		else:
			GOdict[GeneID] = {}
			GOdict[GeneID]['Component'] = set()
			GOdict[GeneID]['Process'] = set()
			GOdict[GeneID]['Function'] = set()
			if item['Category'] == 'Component':
				GOdict[GeneID]['Component'].add(item['GO_term'])
			elif item['Category'] == 'Process':
				GOdict[GeneID]['Process'].add(item['GO_term'])
			elif item['Category'] == 'Function':
				GOdict[GeneID]['Function'].add(item['GO_term'])



convertDict = {}
with open(convertfile) as convert:
	convert.next()
	for line in convert:
		line = line.strip().split('\t')
		convertDict[line[1]] = set([line[2]]+line[4].split('|'))


genelst = [x.strip() for x in open(Symbolfile)]

geneDict = {}
for gene in genelst:
	for geneID in convertDict:
		if gene in convertDict[geneID]:
			geneDict[gene] = geneID

sys.stdout.write('\t'.join(['Gene','GO_Function','GO_Component','GO_Process'])+'\n')
for gene in genelst:
	if geneDict[gene] in GOdict:
		sys.stdout.write('\t'.join([gene, ';'.join(GOdict[geneDict[gene]]['Function']), ';'.join(GOdict[geneDict[gene]]['Component']), ';'.join(GOdict[geneDict[gene]]['Process'])])+'\n')
