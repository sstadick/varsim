# $1 = old name
# $2 = new name
# $3 = old ref
# $4 = new ref

#############################
# SET BASE NAME
#############################
perl -pi -e 's/$1/$2/g' ./vaf_aln.sh
perl -pi -e 's/$1/$2/g' ./add_mutations.sh
perl -pi -e 's/$1/$2/g' ./create_reads.sh

#############################
# SET REFERENCE
#############################
perl -pi -e 's/$3/$4/g' ./vaf_aln.sh
perl -pi -e 's/$3/$4/g' ./add_mutations.sh
perl -pi -e 's/$3/$4/g' ./create_reads.sh













