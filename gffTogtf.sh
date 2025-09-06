#!/bin/bash

#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=12                 #optional: number of cpus, default is 1
#SBATCH --job-name=gtf                 #optional: job name
#SBATCH --output=gtf_%j.out            #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=gtf_%j.err             #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=0-4:00:00                  ### Wall clock time limit in Days-HH:MM:SS

agat_convert_sp_gff2gtf.pl --gff campylomormyrus.gff -o campylomormyrus.gtf