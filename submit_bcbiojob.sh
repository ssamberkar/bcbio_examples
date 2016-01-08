#!/bin/bash
#$ -pe openmp 16
#memory requests are per-core
#$ -l rmem=2G -l mem=4G
#Prefer the hidelab queue but spill over to over queues if it is full
#$ -P hidelab

module load apps/gcc/5.2/bcbio/0.9.6a
work_dir='/shared/hidelab2/user/md4zsa/Work/TDP_Omics_Study'

#Seq.Reads file directories
tdp43_r1_files=$work_dir/Data/R1
tdp43_r2_files=$work_dir/Data/R2

#Read in seq reads
tdp43_r1=($(find $tdp43_r1_files -type f -name "*.gz"|sort -n))
tdp43_r2=($(find $tdp43_r2_files -type f -name "*.gz"|sort -n))

#Download the best-practice template file for RNAseq experiment
bcbio_nextgen.py -w template illumina-rnaseq tdp43_project

#Initiate the main analysis
bcbio_nextgen.py -w template $work_dir/tdp43_project/config/tdp43_project-template.yaml $work_dir/tdp43_project ${tdp43_r1[@]} ${tdp43_r2[@]}
