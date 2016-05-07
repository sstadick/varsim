###################################
# BAMTOFASTQ
###################################
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar SortSam INPUT=/mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted3_indel.bam OUTPUT=/mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted3_indel_namesort.bam  SORT_ORDER=queryname CREATE_INDEX=True
/home/ubuntu/jrw_pgdx/jwhite-bin/bedtools bamtofastq -i /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2_sorted3_indel_namesort.bam -fq /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.1.fq -fq2 /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.2.fq
mkdir /mnt2/SIM/hg19_vaf_2/bt2
mkdir /mnt2/SIM/hg19_vaf_2/bwa
mkdir /mnt2/SIM/hg19_vaf_2/novo

###################################
# ALIGN FASTQ FILES
###################################
/home/ubuntu/jrw_pgdx/jwhite-bin/bowtie2 -p 16 -x /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19 -1 /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.1.fq -2 /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.2.fq -S /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln.sam
/home/ubuntu/sstadick/bin_sstadick/bwa/bwa mem -t 16 /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.1.fq /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.2.fq > /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln.sam
/home/ubuntu/jrw_pgdx/jwhite-lib/novocraft/novoalign -c 16 -d /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.nix -f /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.1.fq /mnt2/SIM/hg19_vaf_2/BAM/hg19_vaf_2.2.fq -i MP 4000,500 -o SAM > /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln.sam

###################################
# SAM TO BAM
###################################
/home/ubuntu/sstadick/bin_sstadick/samtools/samtools view -@ 16 -bT /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln.sam > /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln.bam
/home/ubuntu/sstadick/bin_sstadick/samtools/samtools view -@ 16 -bT /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln.sam > /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln.bam
/home/ubuntu/sstadick/bin_sstadick/samtools/samtools view -@ 16 -bT /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln.sam > /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln.bam

###################################
# PICARD SORT AND INDEX
###################################
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar SortSam INPUT=/mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln.bam OUTPUT=/mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln_sorted.bam SORT_ORDER=coordinate CREATE_INDEX=True
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar SortSam INPUT=/mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln.bam OUTPUT=/mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln_sorted.bam SORT_ORDER=coordinate CREATE_INDEX=True
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar SortSam INPUT=/mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln.bam OUTPUT=/mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln_sorted.bam SORT_ORDER=coordinate CREATE_INDEX=True

###################################
# MARK DUPLICATES
###################################
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar MarkDuplicates INPUT=/mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln_sorted.bam OUTPUT=/mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln_sorted_dedup.bam METRICS_FILE=/mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_metrics.txt CREATE_INDEX=True
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar MarkDuplicates INPUT=/mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln_sorted.bam OUTPUT=/mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln_sorted_dedup.bam METRICS_FILE=/mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_metrics.txt CREATE_INDEX=True
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar MarkDuplicates INPUT=/mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln_sorted.bam OUTPUT=/mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln_sorted_dedup.bam METRICS_FILE=/mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_metrics.txt CREATE_INDEX=True

###################################
# ADD / REPORT READ GROUPS
###################################
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar AddOrReplaceReadGroups I=/mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln_sorted_dedup.bam O=/mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln_sorted_rg.bam RGID=4 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=20 CREATE_INDEX=True
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar AddOrReplaceReadGroups I=/mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln_sorted_dedup.bam O=/mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln_sorted_rg.bam RGID=4 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=20 CREATE_INDEX=True
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/PICARD/picard-tools-1.141/picard.jar AddOrReplaceReadGroups I=/mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln_sorted_dedup.bam O=/mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln_sorted_rg.bam RGID=4 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=20 CREATE_INDEX=True
###################################
# REALIGN INDELS
###################################
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/GATK/GenomeAnalysisTK.jar -T RealignerTargetCreator -R /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -I /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln_sorted_rg.bam -o /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_realignment_target.list
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/GATK/GenomeAnalysisTK.jar -T RealignerTargetCreator -R /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -I /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln_sorted_rg.bam -o /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_realignment_target.list
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/GATK/GenomeAnalysisTK.jar -T RealignerTargetCreator -R /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -I /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln_sorted_rg.bam -o /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_realignment_target.list
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/GATK/GenomeAnalysisTK.jar -T IndelRealigner -R /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -I /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_aln_sorted_rg.bam -targetIntervals /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_realignment_target.list -o /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_realn.bam
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/GATK/GenomeAnalysisTK.jar -T IndelRealigner -R /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -I /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_aln_sorted_rg.bam -targetIntervals /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_realignment_target.list -o /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_realn.bam
java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/GATK/GenomeAnalysisTK.jar -T IndelRealigner -R /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -I /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_aln_sorted_rg.bam -targetIntervals /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_realignment_target.list -o /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_realn.bam

###################################
# BASE_RECALIBRATION
###################################
#java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/GATK/GenomeAnalysisTK.jar -T PrintReads -R /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -I /mnt2/SIM/fast/novo/novo_realn.bam -BQSR /mnt2/SIM/fast/novo/novo_recalibration_report.grp -o /mnt2/SIM/fast/novo/novo_recal.bam
#java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/GATK/GenomeAnalysisTK.jar -T PrintReads -R /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -I /mnt2/SIM/fast/bwa/bwa_realn.bam -BQSR /mnt2/SIM/fast/bwa/bwa_recalibration_report.grp -o /mnt2/SIM/fast/bwa/bwa_recal.bam
#java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/GATK/GenomeAnalysisTK.jar -T PrintReads -R /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa -I /mnt2/SIM/fast/bt2/bt2_realn.bam -BQSR /mnt2/SIM/fast/bt2/bt2_recalibration_report.grp -o /mnt2/SIM/fast/bt2/bt2_recal.bam
#/home/ubuntu/sstadick/bin_sstadick/samtools/samtools index /mnt2/SIM/fast/novo/novo_realn.bam
#/home/ubuntu/sstadick/bin_sstadick/samtools/samtools index /mnt2/SIM/fast/bwa/bwa_realn.bam
#/home/ubuntu/sstadick/bin_sstadick/samtools/samtools index /mnt2/SIM/fast/bt2/bt2_realn.bam

###################################
# MUTECT
###################################
mkdir /mnt2/SIM/hg19_vaf_2/novo/mutect
/usr/lib/jvm/java-6-openjdk-amd64/bin/java -Xmx24g -jar /home/ubuntu/jrw_pgdx/jwhite-lib/mutect-1.1.4/muTect-1.1.4.jar --analysis_type MuTect --reference_sequence /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa --input_file:tumor /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_realn.bam --out /mnt2/SIM/hg19_vaf_2/novo/mutect/hg19_vaf_2_novo_mutect_callstats.vcf --num_threads 16 
mkdir /mnt2/SIM/hg19_vaf_2/bwa/mutect
/usr/lib/jvm/java-6-openjdk-amd64/bin/java -Xmx24g -jar /home/ubuntu/jrw_pgdx/jwhite-lib/mutect-1.1.4/muTect-1.1.4.jar --analysis_type MuTect --reference_sequence /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa --input_file:tumor /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_realn.bam --out /mnt2/SIM/hg19_vaf_2/bwa/mutect/hg19_vaf_2_bwa_mutect_callstats.vcf --num_threads 16 
mkdir /mnt2/SIM/hg19_vaf_2/bt2/mutect
/usr/lib/jvm/java-6-openjdk-amd64/bin/java -Xmx24g -jar /home/ubuntu/jrw_pgdx/jwhite-lib/mutect-1.1.4/muTect-1.1.4.jar --analysis_type MuTect --reference_sequence /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa --input_file:tumor /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_realn.bam --out /mnt2/SIM/hg19_vaf_2/bt2/mutect/hg19_vaf_2_bt2_mutect_callstats.vcf --num_threads 16
###################################
# VARSCAN2
##################################
mkdir /mnt2/SIM/hg19_vaf_2/novo/varscan
/home/ubuntu/sstadick/bin_sstadick/samtools/samtools mpileup -B -f /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_realn.bam | java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/VarScan.v2.3.9.jar pileup2snp --output-vcf 1  > /mnt2/SIM/hg19_vaf_2/novo/varscan/hg19_vaf_2_novo_varscan_callstats_snp.vcf
/home/ubuntu/sstadick/bin_sstadick/samtools/samtools mpileup -B -f /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/novo/hg19_vaf_2_novo_realn.bam | java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/VarScan.v2.3.9.jar pileup2indel --output-vcf 1  > /mnt2/SIM/hg19_vaf_2/novo/varscan/hg19_vaf_2_novo_varscan_callstats_indel.vcf

mkdir /mnt2/SIM/hg19_vaf_2/bwa/varscan
/home/ubuntu/sstadick/bin_sstadick/samtools/samtools mpileup -B -f /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_realn.bam | java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/VarScan.v2.3.9.jar pileup2snp --output-vcf 1  > /mnt2/SIM/hg19_vaf_2/bwa/varscan/hg19_vaf_2_bwa_varscan_callstats_snp.vcf
/home/ubuntu/sstadick/bin_sstadick/samtools/samtools mpileup -B -f /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/bwa/hg19_vaf_2_bwa_realn.bam | java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/VarScan.v2.3.9.jar pileup2indel --output-vcf 1  > /mnt2/SIM/hg19_vaf_2/bwa/varscan/hg19_vaf_2_bwa_varscan_callstats_indel.vcf

mkdir /mnt2/SIM/hg19_vaf_2/bt2/varscan
/home/ubuntu/sstadick/bin_sstadick/samtools/samtools mpileup -B -f /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_realn.bam | java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/VarScan.v2.3.9.jar pileup2snp --output-vcf 1  > /mnt2/SIM/hg19_vaf_2/bt2/varscan/hg19_vaf_2_bt2_varscan_callstats_snp.vcf
/home/ubuntu/sstadick/bin_sstadick/samtools/samtools mpileup -B -f /mnt/VAR_DATA/OFFICAL_REFs/hg19/hg19.fa /mnt2/SIM/hg19_vaf_2/bt2/hg19_vaf_2_bt2_realn.bam | java -XX:ParallelGCThreads=16 -jar /home/ubuntu/sstadick/bin_sstadick/VarScan.v2.3.9.jar pileup2indel --output-vcf 1 > /mnt2/SIM/hg19_vaf_2/bt2/varscan/hg19_vaf_2_bt2_varscan_callstats_indel.vcf
