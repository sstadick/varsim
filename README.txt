-----------------------------
Created by:
Seth Stadick
sstadick@personalgenome.com
-----------------------------
The purpose of this file is to document the structure and methods
that have been developed to test the function of varient callers
in conjunction with different reference genomes and aligners.

The goal is to generate paper worthy data and show strengths and
weaknesses of different methods.

Tools can be found in both /home/ubuntu/jrw_pgdx and /home/ubuntu/sstadick
directories (samtools, bamsurgeoon, etc.)

Ref Genome:
        rsync -avzP rsync://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/hg38.2bit /mnt/VAR_DATA/OFFICIAL_REFs/hg38
        Requires conversion using twoBitToFa found in /home/ubuntu/sstadick/bin_sstadick from http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/
        Index with:
                BWA: /mnt/VAR_DATA/OFFICAL_REFs/hg38# /home/ubuntu/jrw_pgdx/jwhite-bin/bwa index -a bwtsw hg38.fa
                Bowtie2: bowtie2-build -f hg38.fa hg38
                Novoalign: novoindex hg38.nix hg38.fa

Stage0: (Initial run through test see /mnt/VAR_DATA/SETS/1_SET)
  -- Generate .bed file to pull genes of interest from reference
        - located in /mnt/OFFICIAL_REFs/BEDs
        - use bedtools getFasta from: /home/ubuntu/jrw_pgdx/jwhite-bin/bedtools getfasta to pull from ref genome
        - root@ip-172-31-34-238:/mnt/VAR_DATA/SETS/1_SET# /home/ubuntu/jrw_pgdx/jwhite-bin/bedtools getfasta -fi ../../OFFICAL_REFs/hg38/hg38.fa -bed ../../OFFICAL_REFs/hg38/BEDS/set1_getFasta.bed -fo ./set_1.fa
  --
  -- Generate reads
        - Installed ART in /home/ubuntu/sstadick/bin-sstadick/ART
        - will run the illumina version
        - Command: /home/ubuntu/sstadick/bin_sstadick/ART/art_bin_ChocolateCherryCake/art_illumina -sam -i /mnt/VAR_DATA/SETS/1_SET/set_1.fa -p -l 100 -ss HS25 -f 100 -m 200 -s 10 -o set_1_reads
        - Profile:
          -sam -> Output a SAM alignment file
          -i -> File name of input file from which reads are made
          -p -> Run as paired end
          -l -> Lenght of reads to be simulated (100bp...Sam said so)
          -ss -> Name of sequencing platform (HS25 = HiSeq2500)
          -f -> fold coverage (100 seemed mid range for serious seq???)
          -m -> average size of fragments for paired end ness (200 was default in their example)
          -s -> std deviation of fragment size (10 was default)
          -o -> prefix of output files
  -- Convert set_1_reads.sam to set_1_reads.bam
        - /home/ubuntu/jrw_pgdx/jwhite-bin/samtools view -bT ../../OFFICAL_REFs/hg38/hg38.fa set_1_reads.sam > set_1_reads.bam
  ** The SAM files output by ART are actually aligned against the fasta file that is input, so they will not be correctly annotated for bamsurgeon. Method one is to just align using bwa-mem to get a good sam file. Method two is to modify ART.
  ** METHOD 1: Aligned with BWA-MEM /home/ubuntu/sstadick/bin_sstadick/bwa/bwa mem /mnt/VAR_DATA/OFFICAL_REFs/hg38/hg38.fa set_1_reads1.fq set_1_reads2.fq
        - This took about 40 minutes to complete.
  -- Sort the bam file:
        - /home/ubuntu/jrw_pgdx/jwhite-bin/samtools sort set_1_reads.bam set_1_reads_sorted
        - Used samtools because PICARD tools was not compiling nicely
  -- Index the bam file and the ref with samtools
        - /home/ubuntu/jrw_pgdx/jwhite-bin/samtools index set_1_reads_sorted.bam
        - /home/ubuntu/jrw_pgdx/jwhite-bin/samtools index /mnt/
  -- Generate .bed file spike mutations into created reads
        - python pullCosm.py -i ./test.bed -d /mnt/VAR_DATA/COSMIC/cosmic.vcf -o test1
        - the -o option doesn't work atm. outputs two bed files for use with bamsurgeon.
        - found /home/ubuntu/sstadick/scripts/
  -- Run Bamsurgeon addsnv.py
        - /home/ubuntu/jrw_pgdx/jwhite-lib/bamsurgeon/addsnv.py -v /mnt/VAR_DATA/SETS/1_SET/BAMSURGEON/set_1_snp.bed -f /mnt/VAR_DATA/SETS/1_SET/alignment1_sorted.bam -r /mnt/VAR_DATA/OFFICAL_REFs/hg38/hg38.fa -o alignment1_sorted_snp
  -- Run Bamsurgeon addindel.py
        -
  -- Sort the output BAM
        - java -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar SortSam INPUT=alignment1_sorted_snp_sorted.bam OUTPUT=aln1_snp_sorted.bam SORT_ORDER=coordinate
  -- Remove the duplicates
        - /mnt/VAR_DATA/SETS/1_SET# java -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar MarkDuplicates INPUT=aln1_snp_sorted.bam OUTPUT=aln1_snp_sorted_dedup.bam METRICS_FILE=metrics_aln1.txt

************************************
mutect_pipeline.py
************************************
* break down the methods further to make it more modular
* add in a suffix for each and an infile and outifle for each block
* add logging and better error handleing (aka breaks)


************************************
hg19 related material
************************************
References
        - Cosmic downloaded from: ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/cosmic.txt.gz
        - Genome from ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/hg19.2bit



************************************
VARSIM
************************************
Varsim is a simulation framework that generates reads using ART, as well as spikes in mutations
and provides a reporting framework and tumor normal comparisons.

Running simulation found: http://bioinform.github.io/varsim/ , my dir found /mnt/VAR_DATA/SETS/varsimtest
command:
python /home/ubuntu/sstadick/bin_sstadick/varsim/varsim.py --vc_in_vcf All_20150605.vcf.gz --sv_insert_seq insert_seq.txt \
--sv_dgv GRCh37_hg19_supportingvariants_2013-07-23.txt \
--reference hs37d5.fa --id simu --read_length 100 --vc_num_snp 3000000 --vc_num_ins 100000 \
--vc_num_del 100000 --vc_num_mnp 50000 --vc_num_complex 50000 --sv_num_ins 2000 \
--sv_num_del 2000 --sv_num_dup 200 --sv_num_inv 1000 --sv_percent_novel 0.01 \
--vc_percent_novel 0.01 --mean_fragment_size 350 --sd_fragment_size 50 \
--vc_min_length_lim 0 --vc_max_length_lim 49 --sv_min_length_lim 50 \
--sv_max_length_lim 1000000 --nlanes 5 --total_coverage 1 \
--simulator_executable /home/ubuntu/sstadick/bin_sstadick/ART/art_bin_ChocolateCherryCake/art_illumina --out_dir out --log_dir log --work_dir work \
--simulator a




************************************
TROUBLESHOOTING
************************************
-  If things aren't working, then try exporting the path! this gets me everytime!
-  
