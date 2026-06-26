### Example

Directory

`for i in $( ls *001.fastq.gz | perl -pe "s/_R(1|2).*//g" | uniq ); do echo $i ; done`
