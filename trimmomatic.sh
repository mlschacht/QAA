#!/bin/bash

#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=8                 #optional: number of cpus, default is 1
#SBATCH --job-name=trimmomatic                 #optional: job name
#SBATCH --output=trimmomatic_%j.out            #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=trimmomatic_%j.err             #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=10:00:00                  ### Wall clock time limit in Days-HH:MM:SS

/usr/bin/time -v trimmomatic PE trimmed_SRR25630310_1.fastq trimmed_SRR25630310_2.fastq \
 trimmomatic_SRR25630310_R1_paired.fastq.gz trimmomatic_SRR25630310_R1_unpaired.fastq.gz \
  trimmomatic_SRR25630310_R2_paired.fastq.gz trimmomatic_SRR25630310_R2_unpaired.fastq.gz \
  ILLUMINACLIP:adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36