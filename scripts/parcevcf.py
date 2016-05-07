
indellist = []
snplist = []
roilist = []

#with open("ROI19.bed", 'r') as roi:
#    for line in roi:
#        roilist.append(line.split("\t"))


with open("dreamtruth3T.vcf", 'r') as vcf:
    for line in vcf:
        if "#" not in line:
            entry = line.split("\t")
            #for gene in roilist:
                #if ((int(entry[0]) == int(gene[0])) & (int(entry[1]) > int(gene[1])) & (int(entry[1]) < int(gene[2]))):
            entry[2] = entry[1]
            "chr".join(entry[0])
            if (((len(entry[3]) > 1) | (len(entry[4]) > 1))):
                indellist.append(entry)
            else:
                snplist.append(entry)

print "Done processing vcf file"

print "Writing new vcf files"

with open("Real_dreamsnps.vcf", 'w') as snps:
    for entry in snplist:
        snps.write("\t".join(entry))

with open("Real_dreamindels.vcf", 'w') as indels:
    for entry in indellist:
        indels.write("\t".join(entry))

print "Done writing files"
