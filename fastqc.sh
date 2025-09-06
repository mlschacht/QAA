#!/bin/bash

#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=8                 #optional: number of cpus, default is 1
#SBATCH --mail-type=ALL                   #optional: must set email first, what type of email you want
#SBATCH --job-name=fastqc            #optional: job name
#SBATCH --output=fastqc_%j.out       #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=vfastqc_%j.err        #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=0-4:00:00                  ### Wall clock time limit in Days-HH:MM:SS

conda activate QAA

/usr/bin/time -v fastqc SRR25630310_1.fastq.gz