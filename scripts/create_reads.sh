#####################
# ART
#####################
#mkdir /mnt2/SIM/hg19_vaf_2/BAM
/home/ubuntu/jrw_pgdx/jwhite-bin/bedtools getfasta -fi /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -bed /mnt2/SIM/BED/ROI19.bed -fo /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.fa
/home/ubuntu/sstadick/bin_sstadick/ART/art_bin_ChocolateCherryCake/art_illumina -i /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.fa -p -l 100 -ss HS25 -f 100 -m 200 -s 10 -o /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_reads
bowtie2 -p 16 -x /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19 -1 /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_reads1.fq -2 /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_reads2.fq -S /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.sam
/home/ubuntu/sstadick/bin_sstadick/samtools/samtools view -bT /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.sam > /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.bam

#####################
# BAMSURGEON
#####################

