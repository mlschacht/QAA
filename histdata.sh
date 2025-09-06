#!/bin/bash

#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=1                 #optional: number of cpus, default is 1
#SBATCH --job-name=hist                 #optional: job name
#SBATCH --output=hist_%j.out            #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=hist_%j.err             #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=0-4:00:00                  ### Wall clock time limit in Days-HH:MM:SS


zcat trimmomatic_SRR25630310_R1_paired.fastq.gz | grep -A 1 ^"@" | grep -v ^"@" | grep -v ^"-" | awk '{print length, $0}'| sed s'|\s|\t|'| cut -f1 > SRR25630310_R1_histData

zcat trimmomatic_SRR25630310_R2_paired.fastq.gz | grep -A 1 ^"@" | grep -v ^"@" | grep -v ^"-" | awk '{print length, $0}'| sed s'|\s|\t|'| cut -f1 > SRR25630310_R2_histData

zcat trimmomatic_SRR25630391_R1_paired.fastq.gz | grep -A 1 ^"@" | grep -v ^"@" | grep -v ^"-" | awk '{print length, $0}'| sed s'|\s|\t|'| cut -f1 > SRR25630391_R1_histData

zcat trimmomatic_SRR25630391_R2_paired.fastq.gz | grep -A 1 ^"@" | grep -v ^"@" | grep -v ^"-" | awk '{print length, $0}'| sed s'|\s|\t|'| cut -f1 > SRR25630391_R2_histData