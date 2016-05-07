import os

snplookup = []
indellookup = []
mutlookup = {}

for i in os.listdir(os.getcwd()):
    # make snp lookup
    if i.endswith("snp.bed"):
        with open(i, 'r') as snp:
            for line in snp:
                if ("#" not in line) & (line.startswith("chr")):
                    entry = line.split("\t")
                    subentry = []
                    subentry.append(entry[0])
                    subentry.append(entry[1])
                    snplookup.append(":".join(subentry))
    if i.endswith("indel.bed"):
        with open(i, 'r') as indel:
            for line in indel:
                if ("#" not in line) & (line.startswith("chr")):
                    entry = line.split("\t")
                    subentry = []
                    subentry.append(entry[0])
                    subentry.append(entry[1])
                    indellookup.append(":".join(subentry))

# Count with KEEP or without KEEP
for i in os.listdir(os.getcwd()):
    # MUTECT
    snpcountkeep = 0
    snpcounttotal = 0
    indelcountkeep = 0
    indelcounttotal = 0
    indelcountraw = 0
    snpcountraw = 0
    keepers = 0
    if "mutect_callstats.vcf" in i:
        with open(i, 'r') as mut:
            for line in mut:
                if ("#" not in line): #& (line.startswith("chr")):
                    entry = line.split("\t")
                    subentry = []
                    subentry.append(entry[0])
                    subentry.append(entry[1])
                    mutlookup[":".join(subentry)] = entry[len(entry) -1]
                    snpcounttotal = snpcounttotal + 1

        for key, value in mutlookup.iteritems():
            if key in snplookup: #and "KEEP" in str(value):
                snpcountkeep = snpcountkeep + 1
            if key in snplookup:
                snpcountraw = snpcountraw + 1
            if "KEEP" in str(value):
                keepers += 1
        print "###################################"
        print i
        print "\tTotal filtered found: " + str(snpcountkeep)
        print "\tTotal unfiltered found: " + str(snpcountraw)
        print "\tTotal reads: " + str(snpcounttotal)
        print "\tTotal that meet caller pass: " + str(keepers)
        name = i.split("_")
        truepositive = str(snpcountkeep)
        totalfound = str(keepers)
        falsepositive = str(keepers - snpcountkeep)
        print name[0] + "_" + name[2] + "\t" + name[3] + "_" + name[4] + "\t" + truepositive + "\t" + falsepositive + "\t" + totalfound

#     if ("varscan_callstats_snp.vcf" in i) | ("varscan2_callstats_snp.vcf" in i) :
#         # VARSCAN snp
#         vaf = i.split("_")[2]
#         with open(i, 'r') as mut:
#             for line in mut:
#                 if ("#" not in line) & (line.startswith("chr")):
#                     entry = line.split("\t")
#                     subentry = [entry[0], entry[1]]
#                     mutlookup[":".join(subentry)] = float(entry[6].replace("%", ""))
#                     snpcounttotal += 1
#         for key, value in mutlookup.iteritems():
#             if key in snplookup and value >= float(vaf):
#                 snpcountkeep += 1
#             if key in snplookup:
#                 snpcountraw += 1
#             if value >= float(vaf):
#                 keepers += 1
#         print "###################################"
#         print i
#         print "\tTotal filtered found: " + str(snpcountkeep)
#         print "\tTotal unfiltered found: " + str(snpcountraw)
#         print "\tTotal reads: " + str(snpcounttotal)
#         print "\tTotal that meet caller pass: " + str(keepers)
#         name = i.split("_")
#         truepositive = str(snpcountkeep)
#         totalfound = str(keepers)
#         falsepositive = str(keepers - snpcountkeep)
#         print name[0] + "_" + name[2] + "\t" + name[3] + "_" + name[4] + "\t" + truepositive + "\t" + falsepositive + "\t" + totalfound
    # if "varscan_callstats_indel.vcf" in i:
    #     # VARSCAN indel
    #     vaf = i.split("_")[2]
    #     with open(i, 'r') as mut:
    #         for line in mut:
    #             if ("#" not in line) & (line.startswith("chr")):
    #                 entry = line.split("\t")
    #                 subentry = []
    #                 subentry.append(entry[0])
    #                 subentry.append(entry[1])
    #                 mutlookup[":".join(subentry)] = float(entry[6].replace("%", ""))
    #                 indelcounttotal = indelcounttotal + 1
    #     for key, value in mutlookup.iteritems():
    #
    #         if key in indellookup and value >= float(vaf):
    #             indelcountkeep += 1
    #         elif key in indellookup:
    #             indelcountraw += 1
    #     print "###################################"
    #     print i
    #     print "\tKEEP: " + str(indelcountkeep)
    #     print "\tRAW: " + str(indelcountraw)
    #     print "\tTOTAL: " + str(indelcounttotal)





