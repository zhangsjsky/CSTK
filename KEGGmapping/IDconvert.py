def Symbol2ID_dict(convertfile):
	convertDict = {}
	with open(convertfile) as convert:
		convert.next()
		for line in convert:
			line = line.strip().split('\t')
			convertDict[line[2]] = line[1]
	return convertDict

def ID2Symbol_dict(convertfile):
	convertDict = {}
	with open(convertfile) as convert:
		convert.next()
		for line in convert:
			line = line.strip().split('\t')
			convertDict[line[1]] = set([line[2]]+line[4].split('|'))
	return convertDict
