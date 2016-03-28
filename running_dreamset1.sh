# bowtie2
/home/ubuntu/sstadick/scripts/varsim/run_pipeline.py -o /mnt2/DREAM/06683320-dbd9-464e-b6f2-143e715b2981/bowtieDream1 / -b /mnt2/DREAM/06683320-dbd9-464e-b6f2-143e715b2981/bowtieDream1/BEDS/ROI.bed -a bowtie2 -c mutect -s align -t bowtieDream1 -r real -e /mnt2/DREAM/06683320-dbd9-464e-b6f2-143e715b2981/synthetic.challenge.set1.tumor.v2.bam

#bwa
/home/ubuntu/sstadick/scripts/varsim/run_pipeline.py -o /mnt2/DREAM/06683320-dbd9-464e-b6f2-143e715b2981/bwaDream1 / -b /mnt2/DREAM/06683320-dbd9-464e-b6f2-143e715b2981/bwaDream1/BEDS/ROI.bed -a bwa -c mutect -s align -t bwaDream1 -r real -e /mnt2/DREAM/06683320-dbd9-464e-b6f2-143e715b2981/synthetic.challenge.set1.tumor.v2.bam

#novoalign
/home/ubuntu/sstadick/scripts/varsim/run_pipeline.py -o /mnt2/DREAM/06683320-dbd9-464e-b6f2-143e715b2981/novoDream1 / -b /mnt2/DREAM/06683320-dbd9-464e-b6f2-143e715b2981/novoDream1/BEDS/ROI.bed -a bwa -c mutect -s align -t novoDream1 -r real -e /mnt2/DREAM/06683320-dbd9-464e-b6f2-143e715b2981/synthetic.challenge.set1.tumor.v2.bam
