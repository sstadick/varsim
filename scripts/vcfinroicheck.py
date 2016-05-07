import os

roiranges = []
vcflocals = []
#muts = []
count = 0
mutcount = 0
snpcount = 0
indelcount = 0

with open("/Users/pgdx-seth/Documents/irp_2016/DATA/reportsync/hg19_dream3T_data/ROI19.bed", 'r') as roi:
    for line in roi:
        if "#" not in line:
            elements = line.split("\t")
            range = [elements[0], elements[1], elements[2]]
            roiranges.append(range)

with open("/Users/pgdx-seth/Documents/irp_2016/DATA/reportsync/hg19_dream3T_data/dreamtruth3T.vcf", 'r') as vcf:
    for line in vcf:
        if "#" not in line:
            elements = line.split("\t")
            vcflocals.append(elements)
            #local = [elements[0], elements[1]]
            #vcflocals.append(local)


for mut in vcflocals:
    for region in roiranges:
        if mut[0] == region[0]:
            if (int(mut[1]) >= int(region[1])) & (int(mut[1]) <= int(region[2])):
                count += 1
                print mut
                if (len(mut[3]) > 1 or len(mut[4]) > 1):
                    if "<" not in mut[3] and "<" not in mut[4]:
                        indelcount += 1
                    else:
                        snpcount += 1
                else:
                    snpcount += 1
print "Count of mutations in truth set found in roi: " + str(count)
print "Count of snps in truth set found in roi: " + str(snpcount)
print "Count of indels in truth set found in roi: " + str(indelcount)


for i in os.listdir("/Users/pgdx-seth/Documents/irp_2016/DATA/reportsync/hg19_dream3T_data/"):
    infilekeepcount = 0
    infilecount = 0
    inroicount = 0
    inroikeepcount = 0
    muts = []
    #if "mutect_callstats.vcf" in i:
        #with open(i, 'r') as bt2:
            #for line in bt2:
                #if "#" not in line:
                    #infilecount += 1
                    #elements = line.split("\t")
                    #call = [elements[0], elements[1], elements[len(elements)-1], line]
                    #muts.append(call)
                    #if elements[len(elements)-1] == "KEEP":
                        #infilekeepcount += 1



        #for call in muts:
            #for vcf in vcflocals:
                ##print call[0] + " : " + "chr" + vcf[0]
                #if call[0] == "chr" + vcf[0]:
                    ##print "\t" + call[1] + " : " + vcf[1]
                    #if call[1] == vcf[1]:
                        #inroicount += 1
                        ##print "\t\t" + call[2]
                        #if call[2] == "KEEP":
                            #inroikeepcount += 1

        #print "File: " + i
        #print "Mutations in file: " + str(infilecount)
        #print "Mutations in file and KEEP: " + str(infilekeepcount)
        #print "Mutations in file and roi: " + str(inroicount)
        #print "Mutations in file and roi and KEEP: " + str(inroikeepcount)

    if "varscan_callstats_snp.vcf" in i:
        with open("/Users/pgdx-seth/Documents/irp_2016/DATA/reportsync/hg19_dream3T_data/" + i, 'r') as varscan:
            for line in varscan:
                if "#" not in line:
                    infilecount += 1
                    elements = line.split("\t")
                    call = [elements[0], elements[1], elements[6]]
                    muts.append(call)
                    if (float(elements[6].replace("%", "") >= 5.00)):
                        infilekeepcount += 1

            for call in muts:
                for vcf in vcflocals:
                    if call[0] == "chr" + vcf[0]:
                        if call[1] == vcf[1]:
                            inroicount += 1
                            if float(call[2].replace("%", "")) >= 5.00:
                                inroikeepcount += 1
        print "File: " + i
        print "Mutations in file: " + str(infilecount)
        print "Mutations in file and KEEP: " + str(infilekeepcount)
        print "Mutations in file and roi: " + str(inroicount)
        print "Mutations in file and roi and KEEP: " + str(inroikeepcount)
