
indelslist = []
import sys 
with open("indels.vcf", 'r') as indels:
    for line in indels:
        indelslist.append(line.split("\t"))

basepath = "/Users/pgdx-seth/Documents/irp_2016/DATA/reportsync/hg19_dream3T_data/"
paths = [basepath + "hg19_dream3T_bt2_varscan_callstats_indel.vcf", basepath + "hg19_dream3T_bwa_varscan_callstats_indel.vcf", basepath + "hg19_dream3T_novo_varscan_callstats_indel.vcf"]
for path in paths:
    datalist = []
    with open(path, 'r') as dat:
        for line in dat:
            if "#" not in line:
                datalist.append(line.split("\t"))
    count = 0
    for point in datalist:
        for mut in indelslist:
            if point[0] == mut[0]:
                if point[1] == mut[1]:
                    count = count + 1

    print path + " : " + str(count)
            
