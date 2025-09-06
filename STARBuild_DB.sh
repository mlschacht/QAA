#!/bin/bash

#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=8                 #optional: number of cpus, default is 1
#SBATCH --mail-user=mlscha@uoregon.edu     #optional: if you'd like email
#SBATCH --mail-type=ALL                   #optional: must set email first, what type of email you want
#SBATCH --job-name=STAR_builddb            #optional: job name
#SBATCH --output=STAR_builddb_%j.out       #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=vSTAR_builddb_%j.err        #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=0-4:00:00                  ### Wall clock time limit in Days-HH:MM:SS


conda activate bgmp_star

/usr/bin/time -v STAR --runThreadN 8 --runMode genomeGenerate \
 --genomeDir /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/STAR_DB_Campy \
 --genomeFastaFiles /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/campylomormyrus.fasta \
 --sjdbGTFfile  /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/campylomormyrus.gtf