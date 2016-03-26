#!/usr/bin/env python

# By Seth Stadick
# The purpose of this script is to use the genes in one bed file to find their 
# mutations in the cosmic all database based on the gene name. This info will 
# then be parsed into a new bed and or vcf file for use in mutation iput. 

import sys, getopt
import re

#PATH_TO_COSMDB = "/mnt/VAR_DATA/COSMIC/cosmic.vcf"
#PATH_TO_GENESBED = "/mnt/VAR_DATA/OFFICAL_REFs/hg38/BEDS/set1_getFasta.bed"

PATH_TO_COSMDB = "" 
PATH_TO_GENESBED = ""
OUTPATH = ""



def getGeneNames():
	names = []
	with open(PATH_TO_GENESBED, 'r') as bedIn:
		for line in bedIn:
			cols = line.split("\t")
			name = cols[3].rstrip()
			#print name
			names.append(name)
	return names

def getMutFromCosm(listOfNames):
	'''Gets the Cosmic entries for each gene name, returns dictionary'''
	cosm = {} #Gene name : list of cosm entries
	with open(PATH_TO_COSMDB, 'r') as cosmDBIn:
		for name in listOfNames:
			cosmDBIn.seek(0, 0)
			nameList = []
			for line in cosmDBIn:
				if name in line:
					nameList.append(line)
			cosm[name] = nameList
			#print nameList
	return cosm

def filterByCNT(dictOfGenes):
	'''This will pull out only the highest CNT for each gene'''
	filteredDict = {}
	for key in dictOfGenes:
		currentHighestValue = ""
		currentHighestCount = 0
		for value in dictOfGenes[key]:
			matchObj = re.search(r'(CNT=)(.+)', value)
			if matchObj:
				count =  int(matchObj.group(2))
				if count >=currentHighestCount:
					currentHighestCount = count
					currentHighestValue = value
		filteredDict[key] = currentHighestValue
	return filteredDict						 
#	for key, value in filteredDict.iteritems():
#		print key, value
	
def createBedFile(filteredDict):
	# could do something fancy with the count to get a cooler VAF
	# Chrom	start	stop	VAF	spec bases (For SNP's)
	# Chrom start	stop 	VAF	MutType	insertionstring
	for value in filteredDict.values():
		info = re.split(r'\t+', value)	
		if (len(info[3]) < 2) and (len(info[4]) < 2):
			print info
			chrom = info[0]
			start = info[1]
			end = info[1]
			vaf = ".4"
			into = info[4]
			line = "chr" + chrom + "\t" + start + "\t" + end + "\t" + vaf + "\t" + into + "\n"
			filename = OUTPATH + "_snp.bed"
			with open(filename, 'a') as snpFile:
				snpFile.write(line)
				
		else: #assume ins or del
			info = re.split(r'\t+', value)
                        chrom = info[0]
                        start = info[1]
                        #end
                        vaf = ".4"
			insert = ""

			if 'ins' in value:
				mutType = 'INS'
				insert = info[4]
				end = int(start) + 1
			else: #del
				mutType = 'DEL'
				lenDel = info[3]
				end = int(start) + len(lenDel)
			line = "chr" + chrom + "\t" + start + "\t" + str(end) + "\t" + vaf + "\t" + mutType + "\t" + insert + "\n"			
			filename = OUTPATH + "_indel.bed"
			with open(filename, 'a') as indelFile:
				indelFile.write(line)

		

def main(argv):
	try: 
		opts, args = getopt.getopt(argv, "i:d:o")
	except getopt.GetoptError:
		print "pullCosm.py -i <input bed> -d <cosm db> -o <Path to output + prefix>"
		sys.exit()
	for opt, arg  in opts:
		if opt == '-i':
			global PATH_TO_GENESBED
			PATH_TO_GENESBED = arg
		elif opt == '-d':
			global PATH_TO_COSMDB
			PATH_TO_COSMDB = arg
		elif opt == '-o':
			global OUTPATH
			OUTPATH = arg
	
	print PATH_TO_GENESBED + "\n"
	print PATH_TO_COSMDB
	print OUTPATH
	names = getGeneNames()
	dictOfGenes = getMutFromCosm(names)
	#print dictOfGenes
	filteredDict = filterByCNT(dictOfGenes)
	createBedFile(filteredDict)
if __name__ == "__main__":
	main(sys.argv[1:])
