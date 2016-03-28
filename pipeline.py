# **************************
# Author Seth Stadick
# sstadick@gmail.com
# This module will contain all of the IO methods needed to run various pipelines
# **************************


# Each method will have cleary defined inputs and outputs
import sys
import subprocess as sp
import shlex


class pipeline:

    def __init__(self, outputdirectory, prefix, pathtorefgenome, pathtocosmic, pathtogatk, pathtopicard,
                 pathtobwa, pathtobamsurgeondir, pathtoart, pathtobedtools, pathtosamtools, pathtopullcosm="",
                 pathtomutect="", pathtobowtie2="", pathtonovoalign="", bedfile=""):
        """This method initializes a pipeline and takes in the three needed arguments of
        :param outputdirectory: the output directory for the pipeline
        :param prefix: the prefix of all names for the pipeline"""
        self.outdir = outputdirectory
        self.basename = prefix
        self.bedfile = bedfile

        # Paths-to
        self.refgenome = pathtorefgenome
        self.cosmic = pathtocosmic

        # Software
        self.picard = pathtopicard
        self.gatk = pathtogatk
        self.bwa = pathtobwa
        self.bamsurgeon_dir = pathtobamsurgeondir
        self.artillumina = pathtoart
        self.bedtools = pathtobedtools
        self.samtools = pathtosamtools
        self.pullcosm = pathtopullcosm
        self.mutect = pathtomutect
        self.bowtie2 = pathtobowtie2
        self.novoalign = pathtonovoalign


    def bedtools_getfasta(self):
        """ runs bedtools getfasta
        INPUTS: refgenome, befile with genes in it
        OUTPUTs: .fa file with sequences from bed file
        """
        print "--> Running BEDTOOLS getfasta"
        cmdStr = self.bedtools + " getfasta -fi " + self.refgenome + " -bed " + self.bedfile + " -fo " \
                 + self.outdir + "/" + self.basename + ".fa"

        print cmdStr

        self.run_cmd(cmdStr)

    def artilluminagen(self):
        """ Runs art_illumin.py script
        INPUTS: a fasta file
        OUTPUTS: two fastq files of reads
        """
        print "--> Running ART Illumina"
        cmdStr = self.artillumina + " -i " + self.outdir + "/" + self.basename \
                 + ".fa -p -l 100 -ss HS25 -f 100 -m 200 -s 10 -o " + self.outdir + "/" + self.basename + "_reads"
        self.run_cmd(cmdStr)

    def bwa_mem(self, in_suffix, out_suffix, in2_suffix=""):
        """ Runs BWA-MEM, uses -M and -R for ead group info
        INPUTS
        OUTPUTS
        """
        print "--> Running BWA MEM"
        cmdStr = self.bwa + " mem " + self.refgenome + " " + self.basename + in_suffix + " " + self.basename \
                 + in2_suffix + " > " + self.outdir + "/" + self.basename + out_suffix
        self.run_cmd_call(cmdStr)

    def run_bowtie2(self, in_suffix, out_suffix, in2_suffix=""):
        print "--> Running Bowtie2"
        bowtieref = self.refgenome.split(".")[0] # gives the path to the basename
        cmdStr = self.bowtie2 + " -x " + bowtieref + " -1 " + self.outdir + "/" + self.basename + in_suffix + " -2 " \
                 + self.outdir + "/" + self.basename + in2_suffix + " -S " + self.outdir + "/" + self.basename + out_suffix
        self.run_cmd(cmdStr)

    def run_novoalign(self, in_suffix, out_suffix, in2_suffix):
        print "--> Running Novoalign"
        novoref = self.refgenome.split(".")[0] + ".nix"
        cmdStr = self.novoalign + "-c 24 -d " + novoref + " -f " + self.outdir + "/" + self.basename + in_suffix + " " \
                 + self.outdir + "/" + self.basename + in2_suffix + " -i MP 4000,500 -o SAM >" + self.outdir + "/" \
                 + self.basename + out_suffix
        self.run_cmd_call(cmdStr)

    def samtobam(self, in_suffix, out_suffix):
        print "--> Running SAMTOOLS view"
        cmdStr = self.samtools + " view -bT " + self.refgenome + " " + self.outdir + "/" + self.basename + in_suffix + " > " \
                 + self.outdir + "/" + self.basename + out_suffix
        try:
            self.run_cmd(cmdStr)
        except:
            print "I have no idea why this won't run"
        finally:
            self.run_cmd_call(cmdStr)

    def pull_cosm(self):
            print "--> Running " + self.pullcosm
            cmdStr = self.pullcosm + " -i " + self.bedfile + " -d " + self.cosmic + "/cosmic.vcf -o " \
                     + self.outdir + "/" + self.outdir
            self.run_cmd(cmdStr)
            self.move(self.outdir + "/_indel.bed", self.outdir + "/" + self.basename + "_indel.bed")
            self.move(self.outdir + "/_snp.bed", self.outdir + "/" + self.basename + "_snp.bed")

    def sort_with_picard(self, in_suffix, out_suffix):
        # Suggeste: full suffix after basename
        # ex for in: _reads.bam
        # ex for out: _reads_sorted.bam"
        print "--> Running " + self.picard
        cmdStr = "java -jar " +  self.picard + " SortSam INPUT=" + self.outdir + "/" + self.basename + in_suffix + " OUTPUT=" \
                 + self.outdir + "/" + self.basename + out_suffix +" SORT_ORDER=coordinate CREATE_INDEX=True"
        self.run_cmd(cmdStr)
        self.move(self.outdir + "/" + self.basename + out_suffix.split('.')[0] + ".bai", self.outdir + "/"
                  + self.basename + out_suffix + ".bai")

    def addsnps(self):
        print "--> Running " + self.bamsurgeon_dir
        cmdStr = self.bamsurgeon_dir + "addsnv.py -v " + self.outdir + "/" + self.basename + "_snp.bed -f " \
                 + self.outdir + "/" + self.basename + "_reads_sorted.bam -r " + self.refgenome + " -o " + self.outdir \
                 + "/" + self.basename + "_snp.bam"
        self.run_cmd(cmdStr)

    def addindels(self):
            print "--> Running " + self.bamsurgeon_dir
            cmdStr = self.bamsurgeon_dir + "addindel.py -v " + self.outdir + "/" + self.basename \
                     + "_indel.bed -f " + self.outdir + "/" + self.basename + "_snp_sort.bam -r " \
                     + self.refgenome + " -o " + self.outdir + "/" + self.basename + "_indel.bam"
            self.run_cmd(cmdStr)

    def convertbamtofastq(self):
        print "--> Running " + self.picard
        cmdStr = "java -jar " + self.picard + " SamToFastq I=" + self.outdir + "/" + self.basename + "_indel.bam FASTQ=" \
                 + self.outdir + "/" + self.basename + "_new1.fq SECOND_END_FASTQ=" + self.outdir + "/" \
                 + self.basename + "_new2.fq"
        self.run_cmd(cmdStr)

    def markduplicates(self):
        print "--> Running " + self.picard + " MarkDuplicates"
        cmdStr = "java -jar " + self.picard + " MarkDuplicates INPUT=" + self.outdir + "/" + self.basename \
                 + "_indel_sort.bam OUTPUT=" + self.outdir + "/" + self.basename + "_dedup.bam METRICS_FILE=" \
                 + self.outdir + "/" + "metrics_" + self.basename + ".txt CREATE_INDEX=True"
        self.run_cmd(cmdStr)

    def add_replace_readgroups(self):
        print "--> Running " + self.picard + " AddOrReplaceReadGroups"
        cmdStr = "java -jar " + self.picard + " AddOrReplaceReadGroups I=" + self.outdir + "/" + self.basename + "_dedup.bam O=" \
                 + self.outdir + "/" + self.basename + "_dedup_rg.bam RGID=4 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=20 CREATE_INDEX=True"
        self.run_cmd(cmdStr)
    
    def baserecal(self):
        print "--> Running " + self.gatk + " BQSR"
        cmdStr = "java -jar " + self.gatk + " -T PrintReads -R " + self.refgenome + " -I "  + self.outdir + "/" + self.basename \
            + "_realigned.bam -BQSR recalibration_report.grp -o " + self.outdir + "/" + self.basename + "_recal.bam"
        self.run_cmd(cmdStr)

    def createRealignTargets(self):
        print "--> Running " + self.gatk + "RealignerTargetCreator"
        cmdStr = "java -jar " + self.gatk + " -T RealignerTargetCreator -R " + self.refgenome + " -I " + self.outdir \
                 + "/" + self.basename + "_dedup_rg.bam -o " + self.outdir + "/realignment_target.list"
        self.run_cmd(cmdStr)

    def realignindels(self):
        print "--> Running " + self.gatk + "IndelRealigner"
        cmdStr = "java -jar " + self.gatk + " -T IndelRealigner -R " + self.refgenome + " -I " + self.outdir + "/" \
                 + self.basename + "_dedup_rg.bam -targetIntervals realignment_target.list -o " + self.outdir \
                 + "/" + self.basename + "_realigned.bam"
        self.run_cmd(cmdStr)

    def samtoolsindex(self):
        print "--> Running samtools index"
        cmdStr = "samtools index " + self.outdir + "/" + self.basename + "_realigned.bam"
        self.run_cmd(cmdStr)

    def run_mutect(self):
        print "--> Running Mutect"
        cmdStr = "/usr/lib/jvm/java-6-openjdk-amd64/bin/java -Xmx24g -jar " + self.mutect \
                 + " --analysis_type MuTect --reference_sequence " \
                 + self.refgenome + " --input_file:tumor " + self.outdir + "/" + self.basename \
                 + "_realigned.bam --out ./mutect_callstats.txt --coverage_file ./mutect_coverage.txt " \
                   "--vcf ./mutect.vcf --num_threads 8"
        self.run_cmd(cmdStr)

    def run_vardict(self):
        print "--> Running VarDict"
        pass


    def move(self, start, end):
        cmdStr = "mv " + start + " " + end
        self.run_cmd(cmdStr)

    def run_cmd(self, cmdStr):
        print "--> [CMD] " + cmdStr
        cmd = shlex.split(cmdStr)
        try:
            sp.check_call(cmd)
        except sp.CalledProcessError as err:
            print "-->Error with: " + cmdStr
            print str(err)
            sys.exit(1)

    def run_cmd_call(self, cmdStr):
        print "--> [CMD] " + cmdStr
        #cmd = shlex.split(cmdStr)
        try:
            #Using sp.call blocks the return on these piped commands, it looks much cleaner
            #sp.Popen(cmdStr, shell=True)
            sp.call(cmdStr, shell=True)
            return
        except sp.CalledProcessError:
            print "Error with: " + cmdStr
            sys.exit(1)