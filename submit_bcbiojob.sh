#!/bin/bash
#$ -pe openmp 16
#memory requests are per-core
#$ -l rmem=2G -l mem=4G
#Prefer the hidelab queue but spill over to over queues if it is full
#$ -P hidelab

module load apps/gcc/5.2/bcbio/0.9.6a
work_dir='/fastdata/fe1mpc/sandeep/TDP_Omics_Study'

#Seq.Reads file directories
tdp43_r1_files=$work_dir/Data/R1
tdp43_r2_files=$work_dir/Data/R2

#Read in seq reads
tdp43_r1=($(find $tdp43_r1_files -type f -name "*.gz"|sort -n))
tdp43_r2=($(find $tdp43_r2_files -type f -name "*.gz"|sort -n))

#Download the best-practice template file for RNAseq experiment
echo "DOWNLOADING TEMPLATE"
bcbio_nextgen.py -w template illumina-rnaseq tdp43_project

#Edit the template
echo "EDITTING TEMPLATE"
#Switch to the GRCh37 over hg38 genome for STAR
sed -i 's/hg38/GRCh37/g' $work_dir/tdp43_project/config/tdp43_project-template.yaml
#Switch to using star over tophat2 for performance and hisat2 as hisat2 indices fail to load
sed -i 's/tophat2/star/g' $work_dir/tdp43_project/config/tdp43_project-template.yaml

#Initialise the main analysis
# tdp43_project.csv is a metadata file. It should be of the form (more details - https://bcbio-nextgen.readthedocs.org/en/latest/);
# samplename,description,phenotype,batch
# sample_1,Test,V717L,1
# sample_2,Control,Neg,1
echo "INITIALISING ANALYSIS"
bcbio_nextgen.py -w template $work_dir/tdp43_project/config/tdp43_project-template.yaml $work_dir/tdp43_project.csv ${tdp43_r1[@]} ${tdp43_r2[@]}

#Perform the analysis
echo "PERFOMING ANALYSIS"
cd $work_dir/tdp43_project/work
# -n parameter states the number or cores available for bcbio
bcbio_nextgen.py -n 16 ../config/tdp43_project.yaml
