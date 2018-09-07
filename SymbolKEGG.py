#!/usr/bin/env python

import KEGGmapping.KGMLparser as KGMLparser
import KEGGmapping.KGMLpathway as KGMLpathway
import KEGGmapping.KGMLvisual as view
import os
import argparse
import KEGGmapping.IDconvert as IDconvert

parser = argparse.ArgumentParser(description = 'KEGG mapping (Gene Symbol list)')
help_desc = "Input Symbol list"
parser.add_argument("-i", help=help_desc, required=True)
help_desc = "KGML file folder"
parser.add_argument("-K", help=help_desc, required=True)
help_desc = "ID convert file(NCBI gene info)"
parser.add_argument("-C", help=help_desc, required=True)
help_desc = "Out path"
parser.add_argument("-o", help=help_desc, required=True)

args = parser.parse_args()

Symbolfile = args.i
KGMLfolder = args.K
convertfile = args.C
outpath = args.o

genelst = [x.strip() for x in open(Symbolfile)]

convertDict = IDconvert.ID2Symbol_dict(convertfile)

geneDict = {}
for gene in genelst:
        for geneID in convertDict:
            if gene in convertDict[geneID]:
        	geneDict['hsa:' + geneID] = gene


pwInfoDict = {}
with open(KGMLfolder+'/pathwayinfo.txt') as convert:
	for line in convert:
		line = line.strip().split('\t')
		pwInfoDict[line[0].split(':')[1]] = line[1].split(' - ')[0]


pathways = {}

for filename in os.listdir(KGMLfolder + '/KGML/'):
	if filename[-3:] == 'xml' and filename[:3] == 'hsa':
		pathways[filename] = {}
		pathway = KGMLparser.read(open(KGMLfolder + '/KGML/' + filename))
		pathway.image = KGMLfolder + '/Image/' + filename[:-4] + '.png'
		pathways[filename]['pathway'] = pathway
		pwgenelst = [gene for geneEntry in pathway.genes for gene in geneEntry._names]
		pathways[filename]['pwgenes'] = pwgenelst
		pathways[filename]['mapped'] = []
		pathways[filename]['name'] = pwInfoDict[filename[:-4]]

outfilenames = []
for gene in geneDict:
	for filename in pathways:
		if gene in pathways[filename]['pwgenes']:
			pathways[filename]['mapped'].append(geneDict[gene])
			print geneDict[gene]
			outfilenames.append(filename)
			pathway = pathways[filename]['pathway']
			for geneEntry in pathway.genes:
				if gene in geneEntry._names:
					for g in geneEntry.graphics:
						g.name = geneDict[gene]
						g._setbgcolor('#FF5454')
			pathways[filename]['pathway'] = pathway

#drawing pictures
outfilenames = set(outfilenames)
print "Drawing pathways"
if os.path.exists(outpath) is not True:
        os.makedirs(outpath)
for filename in outfilenames:
	if len(pathways[filename]['mapped']) <= 30:
		outfile = '_'.join(pathways[filename]['mapped']) + '-(' + pathways[filename]['name'].replace("/","-") + ')-' + filename[:-4]
	else:
		outfile = str(len(pathways[filename]['mapped'])) + 'Genes' + '-(' + pathways[filename]['name'].replace("/","-") + ')-' + filename[:-4]
	print outfile
	plot = view.KGMLCanvas(pathways[filename]['pathway'],import_imagemap=True)
	plot.draw(os.path.join(outpath, outfile))

