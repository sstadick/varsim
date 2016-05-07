#####################
# PULL COSM
#####################
#/home/ubuntu/sstadick/scripts/varsim/pullCosm.py -i /mnt2/SIM/BED/ROI.bed -d /mnt/VAR_DATA/COSMIC/cosmic.vcf -o /mnt2/SIM/hg19_vaf_2/BAM/
#mv /mnt2/SIM/hg19_vaf_2/BAM/_indel.bed /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_indel.bed
#mv /mnt2/SIM/hg19_vaf_2/BAM/_snp.bed /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_snp.bed
perl -pi -e 's/\.2/\.02/g' /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_indel.bed
perl -pi -e 's/\.2/\.02/g' /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_snp.bed
#####################
# PICARD SORT
#####################
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar SortSam INPUT=/mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.bam OUTPUT=/mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted.bam SORT_ORDER=coordinate CREATE_INDEX=True
mv /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted.bai /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted.bam.bai

#####################
# ADD SNPS
#####################
/home/ubuntu/jrw_pgdx/jwhite-lib/bamsurgeon/addsnv.py -v /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_snp.bed -f /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted.bam -r /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -o /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted_snp.bam


#####################
# PICARD SORT
#####################
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar SortSam INPUT=/mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted_snp.bam OUTPUT=/mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted2_snp.bam SORT_ORDER=coordinate CREATE_INDEX=True
mv /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted2_snp.bai /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted2_snp.bam.bai


#####################
# ADD INDELS
#####################
/home/ubuntu/jrw_pgdx/jwhite-lib/bamsurgeon/addindel.py -v /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_indel.bed -f /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted2_snp.bam -r /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -o /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted2_indel.bam 

#####################
# PICARD SORT
#####################
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar SortSam INPUT=/mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted2_indel.bam OUTPUT=/mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted3_indel.bam SORT_ORDER=coordinate CREATE_INDEX=True
mv /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted3_indel.bai /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted3_indel.bam.bai
