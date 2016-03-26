#/usr/bin/bash

#######################################
# Seth Stadick
# 3/26/2016
# These runs are all on the data generated with ART in test4 using the bed file found in the script path
# Run directory's were preped in advance with the appropriate <basename>_indel.bam files and BED file
#######################################

# Generate Reads
/home/ubuntu/sstadick/scripts/varsim/run_pipeline.py -o /mnt/VAR_DATA/SETS/SYNTH/BAM/ -b /mnt/VAR_DATA/SETS/SYNTH/BEDS/ROI.bed -a bwa -c mutect -s create -t general -r synth

# Run bowtie2 with mutect on hg38
ln -s /mnt/VAR_DATA/SETS/SYNTH/BEDS/ /mnt/VAR_DATA/SETS/SYNTH/bowtieTest2/BEDS
ln -s /mnt/VAR_DATA/SETS/SYNTH/BAM/*  /mnt/VAR_DATA/SETS/SYNTH/bowtieTest2/bowtieTest2_indel.bam
/home/ubuntu/sstadick/scripts/run_pipeline.py -o /mnt/VAR_DATA/SETS/SYNTH/bowtieTest2/ -b /mnt/VAR_DATA/SETS/SYNTH/bowtieTest2/BEDS/ROI.bed -a bowtie2 -c mutect -s align -t bowtieTest -r synth

# Run novoalign with mutect on hg38
ln -s /mnt/VAR_DATA/SETS/SYNTH/BEDS/ /mnt/VAR_DATA/SETS/SYNTH/bowtieTest2/BEDS
ln -s /mnt/VAR_DATA/SETS/SYNTH/BAM/*  /mnt/VAR_DATA/SETS/SYNTH/bowtieTest2/bowtieTest2_indel.bam
/home/ubuntu/sstadick/scripts/varsim/run_pipeline.py -o /mnt/VAR_DATA/SETS/SYNTH/novoTest2/ -b /mnt/VAR_DATA/SETS/SYNTH/novoTest2/BEDS/ROI.bed -a novoalign -c mutect -s align -t novoTest -r synth

# Run bwa with mutect on hg38
ln -s /mnt/VAR_DATA/SETS/SYNTH/BEDS/ /mnt/VAR_DATA/SETS/SYNTH/bwaTest2/BEDS
ln -s /mnt/VAR_DATA/SETS/SYNTH/BAM/*  /mnt/VAR_DATA/SETS/SYNTH/bwaTest2/bwaTest2_indel.bam
/home/ubuntu/sstadick/scripts/varsim/run_pipeline.py -o /mnt/VAR_DATA/SETS/SYNTH/bwaTest2/ -b /mnt/VAR_DATA/SETS/SYNTH/bwaTest2/BEDS/ROI.bed -a bwa -c mutect -s align -t bwaTest -r synth
