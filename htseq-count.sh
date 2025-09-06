#!/bin/bash

#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=8                 #optional: number of cpus, default is 1
#SBATCH --mail-type=ALL                   #optional: must set email first, what type of email you want
#SBATCH --job-name=htseq-count            #optional: job name
#SBATCH --output=htseq-count_%j.out       #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=vhtseq-count_%j.err        #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=0-4:00:00                  ### Wall clock time limit in Days-HH:MM:SS

conda activate QAA

/usr/bin/time -v htseq-count -f sam -s yes -i ID -m union CampyAligned_picard_10.out.sam campylomormyrus.gff > htseq-count_stranded_SRR25630310

/usr/bin/time -v htseq-count -f sam -s reverse -i ID -m union CampyAligned_picard_10.out.sam campylomormyrus.gff > htseq-count_reverse_SRR25630310
#renamed this file to Cco_com123_EO_6cm_2_htseqcounts_revstranded.txt

/usr/bin/time -v htseq-count -f sam -s yes -i ID -m union CampyAligned_picard_91.out.sam campylomormyrus.gff > htseq-count_stranded_SRR25630391

/usr/bin/time -v htseq-count -f sam -s reverse -i ID -m union CampyAligned_picard_91.out.sam campylomormyrus.gff > htseq-count_reverse_SRR25630391
#renamed this file to Crh_rhy116_EO_adult_1_htseqcounts_revstranded.txt