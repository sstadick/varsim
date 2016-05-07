export PATH=$PATH:/home/ubuntu/jrw_pgdx/jwhite-bin/
#bash /mnt2/SIM/hg19_vaf_20/create_reads.sh > /mnt2/SIM/hg19_vaf_20/reads.log 2>1&
bash /mnt2/SIM/hg19_vaf_20/add_mutations.sh > /mnt2/SIM/hg19_vaf_20/muts.log 2>1&
bash /mnt2/SIM/hg19_vaf_20/vaf_aln.sh > /mnt2/SIM/hg19_vaf_20/aln.log 2>1&
