#!/usr/bin/python
#*********************************************************
# mutect_pipeline.py
# author:	Seth Stadick
# Email: 	sstadick@gmail.com
# Created:	3/18/16
#*********************************************************
# This script performs will generate reads as fastq files that resemeble
# Illumina reads. There will also be an option for starting with a bam file
#*********************************************************


import getopt
import sys
import os
from pipeline import pipeline

outDir = ""
bedFile = ""
baseName = ""
mutBedFile = ""

# SOFTWARE
PICARD = "/home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar"
GATK = "/home/ubuntu/sstadick/bin_sstadick/GATK/GenomeAnalysisTK.jar"
BWA = "/home/ubuntu/sstadick/bin_sstadick/bwa/bwa"
BAMSURGEON_DIR = "/home/ubuntu/jrw_pgdx/jwhite-lib/bamsurgeon/"
ART_ILLUMINA = "/home/ubuntu/sstadick/bin_sstadick/ART/art_bin_ChocolateCherryCake/art_illumina"
BEDTOOLS = "/home/ubuntu/jrw_pgdx/jwhite-bin/bedtools"
SAMTOOLS = "/home/ubuntu/jrw_pgdx/jwhite-bin/samtools"
PULLCOSM = "/home/ubuntu/sstadick/scripts/pullCosm.py"
MUTECT = "/home/ubuntu/jrw_pgdx/jwhite-lib/mutect-1.1.4/muTect-1.1.4.jar"

# REFS
REF_GENOME_HG38 = "/mnt/VAR_DATA/OFFICAL_REFs/hg38/hg38.fa"
COSMIC = "/mnt/VAR_DATA/COSMIC"

# DATA CREATION
def create_reads(pl):
    """This method will take the provided bed file and:
    1. use bedtools getfasta to pull the fasta seq from the genome
    2. run art illumina to generate reads'
    3. run BWA MEM on reads to output a correct sam file; use -M and -R options to get read group info
    4. convert this output to bam using picard tools"""

    # 1
    if (not os.path.isfile(outDir + "/" + baseName + ".fa")):
        pl.bedtools_getfasta()
    else:
        print "--> BEDTOOLS getfasta has already been run."

    # 2
    if (not os.path.isfile(outDir + "/" + baseName + "_reads1.fq")):
        pl.artilluminagen()
    else:
        print "--> ART Illumina read generation has already been run"

    # 3
    if (not os.path.isfile(outDir + "/" + baseName + "_reads_corrected.sam")):
        pl.bwa_mem("_reads1.fq", "_reads2.fq", "_reads_corrected.sam")
    else:
        print "--> BWA MEM on ART SAM has already been run"

    if (not os.path.isfile(outDir + "/" + baseName + "_reads.bam")):
        pl.samtobam("_reads_corrected.sam", "_reads.bam")
    else:
        print "--> SAMTOOLS View conversion from SAM to BAM has already been run"

    print "--> Reads created at: " + outDir + "/" + baseName + "_reads.bam"

# MUTATION SPIKING
def addMuts(pl):
    """This method will take the bam output from create() and add in mutations:
    1. Takes the mutations bed file and feeds in into /home/ubuntu/sstadick/scripts/pullCosm.py
    -i <input bed file> -d <database ex. /mnt/VAR_DATA/COSMIC/cosmic.vcf> -o <output>
    2. Sort bam file using Picard
    3. Run bamsurgeon for snp's
    4. Index the output with samtols
    5. Run bamsurgeon for indels
    6. Convert the bam to fastq
    7. align the fastq with bwa
    8. Index the output with samtools"""

    # 1
    # Note, the mut bed file here contains the details about the mutations in order to extract more details out fo the cosmic database and format two new bed files
    # one for snp's and one for indels, that will run with bamsurgeon.
    # I also now realize I could have just imported the code for this....
    if (not os.path.isfile(outDir + "/" + baseName + "_snp.bed")) or (not os.path.isfile(outDir + "/" + baseName + "_indel.bed")):
        pl.pull_cosm()
    else:
        print "--> PullCosm.py bed file generation has already been run"

    #2
    if (not os.path.isfile(outDir + "/" + baseName + "_reads_sorted.bam")):
        pl.sort_with_picard("_reads.bam", "_reads_sorted.bam")
    else:
        print "--> " + baseName + "_reads.bam has alread been sorted by PICARD"

    #3
    if (not os.path.isfile(outDir + "/" + baseName + "_snp.bam")):
        pl.addsnps()
    else:
        print "--> Bamsurgeon snp has alread run"

    #4
    if (not os.path.isfile(outDir + "/" + baseName + "_snp_sort.bam.bai")):
        pl.sort_with_picard("_snp.bam", "_snp_sort.bam")
    else:
        print "--> " + baseName + "_snp.bam has alread been sorted by PICARD"

    #5
    if (not os.path.isfile(outDir + "/" + baseName + "_indel.bam")):
        pl.addindels()
    else:
        print "--> Bamsurgeon indel has alread run"

    #6
    if (not os.path.isfile(outDir + "/" + baseName + "_new1.fq")):
        pl.addindels()
    else:
        print "--> Picard samtofastq has alread run"

    #7
    if (not os.path.isfile(outDir + "/" + baseName + "_indel.sam")):
        pl.bwa_mem("_new1.fq", "_new2.fq", "_indel.sam")
    else:
        print "--> BWA MEM on ART SAM has already been run"

    #7.5 sam to bam
    if (not os.path.isfile(outDir + "/" + baseName + "_indel.bam")):
        pl.samtobam("_indel.sam", "_indel.bam")
    else:
        print "--> SAMTOOLS View conversion from SAM to BAM has already been run"

    #8
    if (not os.path.isfile(outDir + "/" + baseName + "_indel_sort.bam.bai")):
        pl.sort_with_picard("_indel.bam", "_indel_sort.bam")
    else:
            print "--> " + baseName + "_indel.bam has alread been sorted by PICARD"


    print "--> Mutations added. Final BAM is " + outDir + baseName + "/" + "_indel_sort.bam"

# DATA PROCESSING
def pre_processing(pl):
    """ This method will take a bam file and run in through gatk pre-processing:
    1. Sorth the BAM with PICARD tools
    2. Mark Duplcate Reads
    3. Realign Indels (usinging ???)
    4. Skip Base Recalibration """
    #1
    if (not os.path.isfile(outDir + "/" + baseName + "_indel_sort.bam")):
        pl.sort_with_picard("_indel.bam", "_indel_sort.bam")
    else:
        print "--> " + baseName + "_indel.bam has alread been sorted by PICARD"

    #2
    if (not os.path.isfile(outDir + "/" + baseName + "_dedup.bam")):
        pl.markduplicates()
    else:
        print "--> PICARD MarkDuplicates alread done"

##TODO: add read group processing, add -M and -R options to BWA MEM too the info???
    #2.1
    if (not os.path.isfile(outDir + "/" + baseName + "_dedup_rg.bam")):
        pl.add_replace_readgroups()
    else:
        print "--> PICARD AddOrReplaceReadGroups already run"

    #3
    if (not os.path.isfile(outDir + "/realignment_target.list")):
        pl.createRealignTargets()
    else:
        print "--> realignment_target.list already created"

    #4
    if (not os.path.isfile(outDir + "/" + baseName + "_realigned.bam")):
        pl.realignindels()
    else:
        print "--> Indels already realigned"

    #4.5
    if (not os.path.isfile(outDir + "/" + baseName + "_realigned.bam.bai")):
        pl.samtoolsindex()
    else:
        print "--> Samtools index on " + outDir + "/" + baseName + "_realigned.bam already done"

    print "--> End of PRE-PROCESSING: " + outDir + "/" + baseName + " _realigned.bam"

# VARIANT DETECTION
def detect_variants(pl):
    if (not os.path.isfile(outDir + "/mutect_callstats.txt")):
        pl.run_mutect()
    else:
        print "--> Mutect has already run"

    print "--> VARIENT CALLING COMPLETE"



def controller():
    pl = pipeline(outputdirectory=outDir, prefix=baseName, pathtorefgenome=REF_GENOME_HG38, pathtocosmic=COSMIC,
          pathtogatk=GATK, pathtopicard=PICARD, pathtobwa=BWA, pathtobamsurgeondir=BAMSURGEON_DIR,
          pathtoart=ART_ILLUMINA, pathtobedtools=BEDTOOLS, pathtosamtools=SAMTOOLS, pathtopullcosm=PULLCOSM, pathtomutect=MUTECT,
          bedfile=bedFile)
    create_reads(pl)
    addMuts(pl)
    pre_processing(pl)
    detect_variants(pl)


def main():

    out = ""


    try:
        #opts, args = getopt.getopt(sys.argv[1:], "i:r:o:b:t:m:")
        opts, args = getopt.getopt(sys.argv[1:], "o:b:t:m:")
    except getopt.GetoptError as err:
        print str(err)
## TODO: Note that the -b and -m bed files are actaully the same one! Otherwise you will get a truncated and
        # possibly different set:
        print "/home/ubuntu/sstadick/scripts/mutect_pipeline.py -o /mnt/VAR_DATA/SETS/script_test2/ -b " + \
              "/mnt/VAR_DATA/SETS/script_test2/BEDS/ROI.bed -m /mnt/VAR_DATA/SETS/script_test2/BEDS/ROI.bed -t fullTest"

        sys.exit(2)
    for o, a in opts:
        #if o == "-i":
        #	in1 = a
        #elif o == "-r":
        #	in2 = a
        if o == "-o":
            out = a
        elif o == "-b":
            bed = a
        elif o == "-t":
            name = a
        elif o == "-m":
            muts= a
        else:
            assert False, "unhandled optoin"

    # Set Environmet Path correctly
    cmdStr = "bash -c \"export PATH=$PATH:/home/ubuntu/jrw_pgdx/jwhite-bin/\""
    #pl.run_cmd(cmdStr)

    global outDir
    global bedFile
    global baseName
    global mutBedFile
    outDir = os.path.abspath(out)
    print "Output Directory: " + outDir
    bedFile = os.path.abspath(bed)
    print "Bed file path is: " +  bedFile
    baseName = name
    print "Base name is: " + baseName
    mutBedFile = os.path.abspath(muts)
    print "Path to mutations bed file is: " + mutBedFile


    controller()

if __name__ == "__main__":
    main()