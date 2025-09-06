#!/bin/bash

#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=8                 #optional: number of cpus, default is 1
#SBATCH --mail-user=mlscha@uoregon.edu     #optional: if you'd like email
#SBATCH --mail-type=ALL                   #optional: must set email first, what type of email you want
#SBATCH --job-name=picard            #optional: job name
#SBATCH --output=picard_%j.out       #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=vpicard_%j.err        #optional: file to store stderr from job, %j adds the assigned jobID
#SBATCH --time=0-4:00:00                  ### Wall clock time limit in Days-HH:MM:SS

conda activate QAA

/usr/bin/time -v picard MarkDuplicates INPUT=CampyAligned_sorted.out.sam OUTPUT=CampyAligned_picard_10.out.sam METRICS_FILE=Campy_10.metrics REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT

#for #91 after you sort 91
/usr/bin/time -v picard MarkDuplicates INPUT=CampyAligned_sorted_91.out.sam OUTPUT=CampyAligned_picard_91.out.sam METRICS_FILE=Campy_91.metrics REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT