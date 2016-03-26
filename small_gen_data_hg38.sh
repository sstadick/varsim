#/usr/bin/bash

#######################################
# Seth Stadick
# 3/20/2016
# These runs are all on the data generated with ART in test4 using the bed file found in the script path
# Run directory's were preped in advance with the appropriate <basename>_indel.bam files and BED file
#######################################

# Generate Reads
/home/ubuntu/sstadick/scripts/varsim/run_pipeline.py -o /mnt/VAR_DATA/SETS/SYNTH/BAM/ -b /mnt/VAR_DATA/SETS/SYNTH/BEDS/ROI.bed -a bwa -c mutect -s create -t general

# Run bowtie2 with mutect on hg38
ln -s /mnt/VAR_DATA/SETS/SYNTH/BEDS/ /mnt/VAR_DATA/SETS/SYNTH/bowtieTest2/BEDS
ln -s /mnt/VAR_DATA/SETS/SYNTH/BAM/*  /mnt/VAR_DATA/SETS/SYNTH/bowtieTest2/bowtieTest2_indel.bam
/home/ubuntu/sstadick/scripts/run_pipeline.py -o /mnt/VAR_DATA/SETS/bowtieTest/ -b /mnt/VAR_DATA/SETS/bowtieTest/BEDS/ROI.bed -a bowtie2 -c mutect -s align -t bowtieTest

# Run novoalign with mutect on hg38
/home/ubuntu/sstadick/scripts/run_pipeline.py -o /mnt/VAR_DATA/SETS/novoTest/ -b /mnt/VAR_DATA/SETS/novoTest/BEDS/ROI.bed -a novoalign -c mutect -s align -t novoTest

# Run bwa with mutect on hg38
/home/ubuntu/sstadick/scripts/run_pipeline.py -o /mnt/VAR_DATA/SETS/bwaTest/ -b /mnt/VAR_DATA/SETS/bwaTest/BEDS/ROI.bed -a bwa -c mutect -s align -t bwaTest

# Run bowtie2 with vardict on hg38
#/home/ubuntu/sstadick/scripts/run_pipeline.py -o /mnt/VAR_DATA/SETS/bowtie2_test/ -b ./BEDS/ROI.bed -a bowtie2 -c mutect -s align -t bowtie2Test

# Run bwa with vardict on hg38
#/home/ubuntu/sstadick/scripts/run_pipeline.py -o /mnt/VAR_DATA/SETS/bowtie2_test/ -b ./BEDS/ROI.bed -a bowtie2 -c mutect -s align -t bowtie2Test

# Run novoalign with vardict on hg38
#/home/ubuntu/sstadick/scripts/run_pipeline.py -o /mnt/VAR_DATA/SETS/bowtie2_test/ -b ./BEDS/ROI.bed -a bowtie2 -c mutect -s align -t bowtie2Test