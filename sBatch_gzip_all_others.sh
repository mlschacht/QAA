#!/bin/bash

#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=1                 #optional: number of cpus, default is 1
#SBATCH --job-name=demult                 #optional: job name
#SBATCH --output=demult_%j.out            #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=demult_%j.err             #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=0-4:00:00                  ### Wall clock time limit in Days-HH:MM:SS

/usr/bin/time -v gzip SRR25630310_2.fastq

/usr/bin/time -v gzip SRR25630391_1.fastq

/usr/bin/time -v gzip SRR25630391_2.fastq



