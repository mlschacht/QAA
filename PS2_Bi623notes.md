# PS2 Notes

I am assigned these SRR files:
SRR25630310     Makayla
SRR25630391     Makayla

The assignments can be found here: /projects/bgmp/shared/Bi623/PS2/QAA_data_Assignments.txt

SRR25630310
Campylomormyrus compressirostris - electric fish, also found in Africa
cDNA from mRNA isolation that is paired from Illumina HiSeq
Use the naming convention below for the "best" (file with the most records) for the final htseq count file for this organism:
Cco_com123_EO_6cm_2_htseqcounts_[forORrev]stranded.txt
Cco_com123_EO_6cm_2_htseqcounts_revstranded.txt

SRR25630391
Campylomormyrus rhynchophorus - double trunk elephant nose is an electric fish found endemic to Africa. 
Also cDNA from mRNA isolation that is paired from Illumina HiSeq
Use the naming convention below for the "best" (file with the most records) for the final htseq count file for this organism:
Crh_rhy116_EO_adult_1_htseqcounts_[forORrev]stranded.txt
Crh_rhy116_EO_adult_1_htseqcounts_revstranded.txt

## Downloading the SRR files/directories

```bash
srun -A bgmp -p bgmp --time=5:00:00 --pty bash
conda activate SRA #since I already installed SRA_toolkit in this environment
prefetch SRR25630310 --max-size 50G
prefetch SRR25630391
fasterq-dump --split-files SRR25630310/SRR25630310.sra
fasterq-dump --split-files SRR25630391/SRR25630391.sra
```
output from the first fasterq-dump for SRR25630310
spots read      : 35,140,212
reads read      : 70,280,424
reads written   : 70,280,424

output from fasterq-dump of SRR25630391
spots read      : 12,529,274
reads read      : 25,058,548
reads written   : 25,058,548

## Part 1 – Read quality score distributions
### Create QAA Environment
```bash
conda create -n QAA 
conda activate QAA
conda install bioconda::fastqc
conda install cutadapt
conda install bioconda::trimmomatic
fastqc --version
```
FastQC v0.12.1

### Make fastqc html files with graphs
```bash
fastqc SRR25630310_1.fastq.gz
fastqc SRR25630310_2.fastq.gz
fastqc SRR25630391_1.fastq.gz
fastqc SRR25630391_2.fastq.gz
```

The average quality score seems to dip towards the end of the 150 bp sequence read length. I expect that this is where the per-base N content would increase. However, the per-base N content stays consistently at 0 and does not increase towards the end of the read. 

#### Computer resources for one fastqc run
```bash
	Command being timed: "fastqc SRR25630310_1.fastq.gz"
	User time (seconds): 170.39
	System time (seconds): 9.02
	Percent of CPU this job got: 100%
	Elapsed (wall clock) time (h:mm:ss or m:ss): 2:58.53
	Exit status: 0
```

### Comparing Avg. Qscore Fastq Graph to personal qscore diff graph from the demultiplexing project
I altered my qscoreDiff python script to accomodate fastq files that were not zipped and file name, read length, and output graph file name inputs from the user.
The new version is called qscoreDiff_v2.

The quality scores per base pair look very similar to those generated using fastqc. All 4 files (the 2 SRR files that each have forward and reverse) seem to have an average quality around 36bp and then they drop off slowly in quality at the end of the read.
The read 2 files both dipped more in quality towards the end of the read than the corresponding read 1 files. 

Summary observations:
Across all 4 files: The per sequence quality scores are mostly ~36 out of 40 which shows really good quality and the sequence length distribution shows that all reads are 150bp long. However, we seem to have some adapters towards the end of each of the 4 reads. It seems to be the Illumina Universal Adapter and it registers upwards of 10% towards the 135bp position. These should be trimmed in order to avoid false reporting of sequences for our organism. Additionally there are over represented sequences in all 4 of our files. Many of these sequences seem to be 50bp long. Illumina universal adapters are known to be 58bp long. These could be the sequences that we need to trim if these overrepresented sequences are at the ends of our reads. Looking at the per base sequence content graphs, this seem to be showing an over representation of certain bases at the first 8 base pairs of the read. TCNAAATTT for the second read of SRR25630310 read 2? This also makes me believe that Adapters are also still on the beginning of the sequence and these should be removed/trimmed.

List of the corresponding bash script names that I used to run qscoreDiff_v2:
sBatch_qscoreDiff_SRR10_R1.sh
sBatch_qscoreDiff_SRR10_R2.sh
sBatch_qscoreDiff_SRR91_R1.sh
sBatch_qscoreDiff_SRR91_R2.sh

#### Computer resources for one of these runs
./sBatch_qscoreDiff_SRA.sh 
        Command being timed: "/projects/bgmp/mlscha/bioinfo/Bi622/Demultiplex/Assignment-the-first/qscoreDiff_v2.py -f SRR25630310_1.fastq -l 150 -o bpQscore_SRR25630310_R1.png"
        User time (seconds): 532.60
        System time (seconds): 5.00
        Percent of CPU this job got: 99%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 8:59.22
        Exit status: 0

The run time between fastqc (~3min) is much MUCH faster than my own script (~9min) to plot the quality distribution across each base pair. AND fastqc generates several other summary graphs. There must be some efficiency in fastqc while there is redundancy in my code for generating these same graphs. The percent CPU is about the same. 

The run time between these data files to produce the graphs vs. the data files we used for demultiplexing were MUCH faster. 
It took ~ 4 hours and 50% CPU to complete the pre-demultiplexing data graphs. Here it took ~3-9min for each graph for a total of ~25min. 
The read 1 and 2 files of the demiltiplexing project remained zipped and were 20G long. The files we are using here are (when unzipped) they are 15G long. 
The length of the file was likely the reason for the time difference. 


## Trim the adapters with cutadapt
trimmomatic -version
0.40
cutadapt --version
5.1
Checked with Hope and she said these should be fine for this assignment. :)

Cutadapt removes adapter sequences from high-throughput sequencing reads.
Used the commands below to trim the adapters:
```bash
cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o trimmed_SRR25630310_1.fastq -p trimmed_SRR25630310_2.fastq SRR25630310_1.fastq.gz SRR25630310_2.fastq.gz
/usr/bin/time -v cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o trimmed_SRR25630391_1.fastq -p trimmed_SRR25630391_2.fastq SRR25630391_1.fastq.gz SRR25630391_2.fastq.gz
```
Commands were run using sbatch scripts below

 What proportion of reads (both R1 and R2) were trimmed?
 ```bash

 ```
For SRR25630310 Read 1, ___________ were trimmed.
For SRR25630310 Read 2, ___________ were trimmed.
For SRR25630391 Read 1, ___________ were trimmed.
For SRR25630391 Read 2, ___________ were trimmed.


After cutadapt, do we still have these adapters?
First check for the entire adapter:
cat trimmed_SRR25630310_1.fastq | grep "AGATCGGAAGAGCACACGTCTGAACTCCAGTCA" | wc -l
output: 0
cat trimmed_SRR25630310_1.fastq | grep "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT" | wc -l #just checking, but this is the adapter for R2 so this shouldn't even be a possibility really.
output:0
cat trimmed_SRR25630310_2.fastq | grep "AGATCGGAAGAGCACACGTCTGAACTCCAGTCA" | wc -l
output:0
cat trimmed_SRR25630310_2.fastq | grep "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT" | wc -l
output:0
cat trimmed_SRR25630391_1.fastq | grep "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT" | wc -l
output:0
cat trimmed_SRR25630391_1.fastq | grep "AGATCGGAAGAGCACACGTCTGAACTCCAGTCA" | wc -l
output:0
cat trimmed_SRR25630391_2.fastq | grep "AGATCGGAAGAGCACACGTCTGAACTCCAGTCA" | wc -l
output:0
cat trimmed_SRR25630391_2.fastq | grep "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT" | wc -l
output:0

This makes it look like the adapters were trimmed...

Second: check the lengths
cat trimmed_SRR25630391_1.fastq | grep -A 1 ^"@" | grep -v ^"@" | grep -v ^"-" | awk '{print length, $0}' | head
146 CCCGTGGCCAGGTACACANCCATGTCAAAGTGGCACTTGTCTGAGTGCTGGTTGCAGTTGCATTTCTGGCAGGCGTTGGTGCTCCTGCCCTTGGCCGGCCTCCAGGGGACGTCGTTGTAGAAGTCGTCACACCTCTCACAGTTCAG
150 CGTAATAGTTCACGGGGTNTCCACTGTGGATCATCAATCCGTCGACAAACTTCATGGACTTGGCCCTCTGGCCCCTGAGCTTGCCAGACACGACCACCTCACAGCCCTTGGCTCCACTCTCCATGATGAAGCGGAGGACGCCATAGCAGG
150 CGCATAGCAAGAATAGCTAAACTTGTGGTGTTAGACTGCATTCCCGATCATCCACTCCATTATGGATGCTGCGAAGCTCCTGCCAACTGACACAGGACTGAGCCGAGGTGTCTTGATACGAACAGAGACTGGTTTAAGCTTTAATCTGTT
135 CATTTGTAGATGCCATCATTTCCCTGCCAAAAGCAGATCCCACAGTCAATGCCACAGTGGAACAGAGCACTAAAACCACAGACAGATCCATGTCTTCTGATAAAAAGTCTTTAAAATGAAGATCACAAAGCTCCC
150 CTTGAACTCTCTCTTCAAAGTTCTTTTCAACTTTCCCTTACGGTACTTGTTGACTATCGGTCTCGTGCCGGTATTTAGCCTTAGATGGAGTTTACCACCCGCTTTGGGCTGCATTCCCAAGCAACCCGACTCCGGGAAGACCGTGCCCCG
150 GTGTGTGTGCGCATTAGAAACCCAGGGGGTTGGGGGTCACGACTCCCCCGTTCTCCACCAGCGCTGCGGAGATGTTTTTGATGTTTCTGTAGATCTGTTTGCTGGAGCTGGACCTGAGCTCCTTCATGTTCTTCAGGATCCTGTCATGGG
111 CCCAACACAATCTTCTTTGTGGTCTTTGCCTTCTTTCGGAAAATAGGCTTCGTCTGGCCACCATAACCGCTCTGCTTACGGTCGTATCTCCTTTTACCCTGTGCATAAAGG
150 TAAAGAATGAAAACCGTTCACCACCAGTGCCTTAAAAAATATGCGTCATAGGTTTCAAATTGTGACCACCTTGAATTTGACTGTGAACACTGGCAACTGCAAAGTTAAGGCTTCCCTGTGATTGGTGGTCTGCCATGTGACAGGAAGTGT
150 CGAGTGATTTAGCACCCGGCTCCCGCGAACGTGAGTTTCGTGGCCGGGAGAGAGGCGGCCTTCGTCCTGCCGCGCTCCAGTCCCGTCACGAGTGGCTCTACGCACCGGCCTCCCCTCCGAGGAGAGGGGGCCGGCTATCGTGGCCCAACC
150 GTTTTATGTTGATGATTGTGGTGATAAAGTTAATTGAACCAAGGATGGAGGAGACTCCGGCCAGATGGAGGGAGAAAATAGCTAGGTCTACGGAGGCTCCAGCATGGGCAAGGTTGCCGGCTAGTGGTGGGTAAACGGTTCACCCCGTAC

Some of the lengths seem to still be 150 characters long, but some were dramatically reduced. Some were not trimmed at all.

Are partial adapter sequences still hanging around at the end of the sequences?

Removed ~ 8bp from the end. This seems like it should still be a very unique sequence that we should not see if these were trimmed.

cat trimmed_SRR25630391_2.fastq | grep "AGATCGGAAGAGCGTCGTGTAGGGA"

output:
CTTTCATCATCTTTTTACTAAGCTCAAAATGTAGATGAAAACATTTTTTTTTTAAAGTACACAATTATTATGGCTATGACTCATTCTACATTATATGATCTATATCAATCAAGG**AGATCGGAAGAGCGTCGTGTAGGGA**ATGGGGGGGGT
CGCCGTGTCTCCTCCTGGTGCATGAGGACAAACCCAGATAGCCAAGCCGTTCCACGGGGTCGCGTTCCAGTCCAGCTTCTGTGAAGCAGACATTCCTGCAGCTGTGGTCGGAGG**AGATCGGAAGAGCGTCGTGTAGGGA**AGGGGGGGTGG
CAACCTAATAACGAAAGCCGCACTGCTCTCCATTCTATTTTTATGGGTCCGCGCCTCGTACCCACGATTCCGATACGACCAACTAATGCACCTCGTGTGAAAAAACTTCCTACCAAT""AGATCGGAAGAGCGTCGTGTAGGGA""ATGTGGGG
CTGAACGGAGCATGTTGCAATTAGCAGTAGATTTTTGTTTTTTAATTTAAAAAAAAAAAAAAAAAATGGCTCACGTTAAAATGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
TCTAGCCAGAACAATCAGGCAAAGAGCCCTACAGTCTGACCCCCCGAAACTAAGTGAGCTACTCCAAGACAGCATATTAGAG""AGATCGGAAGAGCGTCGTGTAGGGA""ATGGGGGGGGGTGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
CTACAGTGGGCTTAAGAGCAGCCATCTGAACAGAAAGCGTTGAAGCTCGGGCAGAAACATAAACCAATTATTCTGATACAAACTCCAATTCCTC""AGATCGGAAGAGCGTCGTGTAGGGA""CAGGGGGGGGGGGGGGGGGGGGGGGGGGGGG

Yes, the partial adapter is still in many of the reads and is towards the end before repeats ("GGGGGG" etc.)

This might be a problem....

### Computer Resources
Command being timed: "cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o trimmed_SRR25630310_1.fastq -p trimmed_SRR25630310_2.fastq SRR25630310_1.fastq.gz SRR25630310_2.fastq.gz"
	User time (seconds): 229.34
	System time (seconds): 3.52
	Percent of CPU this job got: 98%
	Elapsed (wall clock) time (h:mm:ss or m:ss): 3:56.00
	Swaps: 0

## Trim more with Trimmomatic
The adapters that trimmomatic expects from Illumina data are not the same sequences of the Illumina adapters that is used in ours. Because cutadapt didn't trim those ~18bp that still seem to be par of the the adapter sequences toward/near the end of the sequences, I can see if trimmomatic can still handle these by making a quick fasta file with the adapters with the read 1 and read 2 adapters to see if trimmomatic can cut the ~4,000 reads with these down a little more. 
Example command:
```bash
trimmomatic PE trimmed_SRR25630310_1.fastq trimmed_SRR25630310_2.fastq trimmomatic_SRR25630310_R1_paired.fastq.gz trimmomatic_SRR25630310_R1_unpaired.fastq.gz trimmomatic_SRR25630310_R2_paired.fastq.gz trimmomatic_SRR25630310_R2_unpaired.fastq.gz ILLUMINACLIP:adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
```
Is that partial adapter sequence still there?
zcat trimmomatic_SRR25630310_R2_paired.fastq.gz | grep "AGATCGGAAGAGCGTCGTGTAGGGA" | wc -l
output: 0
### Computer resources
Command being timed: "trimmomatic PE trimmed_SRR25630310_1.fastq trimmed_SRR25630310_2.fastq trimmomatic_SRR25630310_R1_paired.fastq.gz trimmomatic_SRR25630310_R1_unpaired.fastq.gz trimmomatic_SRR25630310_R2_paired.fastq.gz trimmomatic_SRR25630310_R2_unpaired.fastq.gz ILLUMINACLIP:adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36"
	User time (seconds): 2936.16
	System time (seconds): 17.00
	Percent of CPU this job got: 435%
	Elapsed (wall clock) time (h:mm:ss or m:ss): 11:18.51
	Exit status: 0


## Plot read length distributions
1. get just the lengths per sequence in one column (histdata.sh)
zcat trimmomatic_SRR25630310_R1_paired.fastq.gz | grep -A 1 ^"@" | grep -v ^"@" | grep -v ^"-" | awk '{print length, $0}'| sed s'|\s|\t|'| cut -f1 > SRR25630310_R1_histData

zcat trimmomatic_SRR25630310_R2_paired.fastq.gz | grep -A 1 ^"@" | grep -v ^"@" | grep -v ^"-" | awk '{print length, $0}'| sed s'|\s|\t|'| cut -f1 > SRR25630310_R2_histData

zcat trimmomatic_SRR25630391_R1_paired.fastq.gz | grep -A 1 ^"@" | grep -v ^"@" | grep -v ^"-" | awk '{print length, $0}'| sed s'|\s|\t|'| cut -f1 > SRR25630391_R1_histData

zcat trimmomatic_SRR25630391_R2_paired.fastq.gz | grep -A 1 ^"@" | grep -v ^"@" | grep -v ^"-" | awk '{print length, $0}'| sed s'|\s|\t|'| cut -f1 > SRR25630391_R2_histData

See PS2-Report.html for results and PS2-histograms.Rmd for the code that generated the plots.

## Converting gff to GTF
```bash
conda install -c bioconda agat
agat_convert_sp_gff2gtf.pl --gff campylomormyrus.gff -o campylomormyrus.gtf
```
## Building the db with STAR
 Install additional software for alignment and counting of RNA-seq reads. In your QAA environment, use conda to install:
 ```bash
conda install bioconda::star
conda install bioconda::picard #wrong picard version
conda install picard=2.18
conda install samtools
conda install numpy
conda install matplotlib
conda install bioconda::htseq
```

running on StarBuild_DB.sh:
```bash
conda activate bgmp_star

/usr/bin/time -v STAR --runThreadN 8 --runMode genomeGenerate \
 --genomeDir /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/STAR_DB_Campy \
 --genomeFastaFiles /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/campylomormyrus.fasta \
 --sjdbGTFfile  /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/campylomormyrus.gtf
```
### Computer resources
!!!!! WARNING: --genomeSAindexNbases 14 is too large for the genome size=862592683, which may cause seg-fault at the mapping step. Re-run genome generation with recommended --genomeSAindexNbases 13
	Command being timed: "STAR --runThreadN 8 --runMode genomeGenerate --genomeDir /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/STAR_DB_Campy --genomeFastaFiles /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/campylomormyrus.fasta --sjdbGTFfile /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/campylomormyrus.gtf"
	User time (seconds): 1617.60
	System time (seconds): 26.00
	Percent of CPU this job got: 391%
	Elapsed (wall clock) time (h:mm:ss or m:ss): 6:59.38
	Exit status: 0

The warning may be something to consider running differently in the future.

## Aligning with STAR
```bash
conda activate bgmp_star

/usr/bin/time -v STAR --runThreadN 8 --runMode alignReads \
--outFilterMultimapNmax 3 \
--outSAMunmapped Within KeepPairs \
--alignIntronMax 1000000 --alignMatesGapMax 1000000 \
--readFilesCommand zcat \
--readFilesIn /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/trimmomatic_SRR25630310_R1_paired.fastq.gz \
 /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/trimmomatic_SRR25630310_R2_paired.fastq.gz \
--genomeDir /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/STAR_DB_Campy \
--outFileNamePrefix Campy
```
### Computer Resources
	Command being timed: "STAR --runThreadN 8 --runMode alignReads --outFilterMultimapNmax 3 --outSAMunmapped Within KeepPairs --alignIntronMax 1000000 --alignMatesGapMax 1000000 --readFilesCommand zcat --readFilesIn /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/trimmomatic_SRR25630310_R1_paired.fastq.gz /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/trimmomatic_SRR25630310_R2_paired.fastq.gz --genomeDir /projects/bgmp/mlscha/bioinfo/Bi623/PS/PS2/QAA/STAR_DB_Campy --outFileNamePrefix Campy"
	User time (seconds): 4951.77
	System time (seconds): 17.60
	Percent of CPU this job got: 770%
	Elapsed (wall clock) time (h:mm:ss or m:ss): 10:45.34
	Exit status: 0

## Remove PCR duplicates using Picard
[Picard MarkDuplicates](https://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates). You may need to sort your reads with `samtools` before running Picard. 
- Use the following for running picard: picard MarkDuplicates INPUT=[FILE] OUTPUT=[FILE] METRICS_FILE=[FILENAME].metrics REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT
 
 Use specific version of Picard from slack - Done! (See above for install instructions)
1. sort with samtools 
2. run picard - using bash script

Sort with samtools:
```bash
samtools sort CampyAligned.out.sam -o CampyAligned_sorted.out.sam
samtools sort Campy_91Aligned.out.sam -o CampyAligned_sorted_91.out.sam
```

Picard example: (also in picard.sh)
```bash
conda activate QAA

/usr/bin/time -v picard MarkDuplicates INPUT=CampyAligned_sorted.out.sam OUTPUT=CampyAligned_picard_10.out.sam METRICS_FILE=Campy_10.metrics REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT
```
### Computer resources Picard
```bash
	Command being timed: "picard MarkDuplicates INPUT=CampyAligned_sorted_91.out.sam OUTPUT=CampyAligned_picard_91.out.sam METRICS_FILE=Campy_91.metrics REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT"
	User time (seconds): 226.55
	System time (seconds): 12.78
	Percent of CPU this job got: 127%
	Elapsed (wall clock) time (h:mm:ss or m:ss): 3:08.20
	Exit status: 0
```

## Report mapped and unmapped reads
sBatch the following code in scripts: (parseSAM.py)
```bash
/projects/bgmp/mlscha/bioinfo/Bi621/PS/ps8-mlschacht/v2_parseSAM.py -f CampyAligned_picard_10.out.sam

/projects/bgmp/mlscha/bioinfo/Bi621/PS/ps8-mlschacht/v2_parseSAM.py -f CampyAligned_picard_91.out.sam
```
Results for SRR25630310:
The number of mapped reads is 28658286
The number of unmapped reads is 5195931

Results for SRR25630391:
The number of mapped reads is 14284429
The number of unmapped reads is 1022282

## Count Duplicated Reads using htseq-count
Used htseq-count.sh script
```bash
conda activate QAA

/usr/bin/time -v htseq-count -f sam -s yes -i ID -m union CampyAligned_picard_10.out.sam campylomormyrus.gff > htseq-count_stranded_SRR25630310

/usr/bin/time -v htseq-count -f sam -s reverse -i ID -m union CampyAligned_picard_10.out.sam campylomormyrus.gff > htseq-count_reverse_SRR25630310
#renamed this file to Cco_com123_EO_6cm_2_htseqcounts_revstranded.txt

/usr/bin/time -v htseq-count -f sam -s yes -i ID -m union CampyAligned_picard_91.out.sam campylomormyrus.gff > htseq-count_stranded_SRR25630391

/usr/bin/time -v htseq-count -f sam -s reverse -i ID -m union CampyAligned_picard_91.out.sam campylomormyrus.gff > htseq-count_reverse_SRR25630391
#renamed this file to Crh_rhy116_EO_adult_1_htseqcounts_revstranded.txt
```

### Computer Resources
Warning from htseq-count:
Warning: 12868464 reads with missing mate encountered.
14088484 alignment record pairs processed.

Reason: Missing mates are likely due to trimming. 

```bash
	Command being timed: "htseq-count -f sam -s yes -i ID -m union CampyAligned_picard_91.out.sam campylomormyrus.gff"
	User time (seconds): 497.57
	System time (seconds): 6.11
	Percent of CPU this job got: 99%
	Elapsed (wall clock) time (h:mm:ss or m:ss): 8:26.55
	Exit status: 0
```

Below is the number of mapped reads to a feature:
```bash
  cat htseq-count_stranded_SRR25630310 | grep -v "^__" | grep -E -v "\s0$" | awk '{sum+=$2} END {print sum}'
655427
(base) [mlscha@n0349 QAA]$ cat htseq-count_reverse_SRR25630310 | grep -v "^__" | grep -E -v "\s0$" | awk '{sum+=$2} END {print sum}'
9081694
(base) [mlscha@n0349 QAA]$ cat htseq-count_stranded_SRR25630391 | grep -v "^__" | grep -E -v "\s0$" | awk '{sum+=$2} END {print sum}'
374423
(base) [mlscha@n0349 QAA]$ cat htseq-count_reverse_SRR25630391 | grep -v "^__" | grep -E -v "\s0$" | awk '{sum+=$2} END {print sum}'
4819031
```
Below is the total number of reads:
```bash

cat htseq-count_stranded_SRR25630310| awk '{sum+=$2} END {print sum}'
29863369
(base) [mlscha@n0349 QAA]$ cat htseq-count_reverse_SRR25630310| awk '{sum+=$2} END {print sum}'
29863369
(base) [mlscha@n0349 QAA]$ cat htseq-count_stranded_SRR25630391 | awk '{sum+=$2} END {print sum}'
14088484
(base) [mlscha@n0349 QAA]$ cat htseq-count_reverse_SRR25630391 | awk '{sum+=$2} END {print sum}'
14088484
```
10_yes =655427/29863369
10_rev=9081694/29863369
91_yes=374423/14088484
91_rev= 4819031/14088484

Results are in html report.

## Stranded Description
The description left on the NCBI database for these RNA sequence reads from both organisms state that they are strand-specific RNA libraries were made. The kit also says that the resulting libraries are strand-specific. Specifically it describes that there is a step that incorporates dUTP during the second strand synthesis prep and this strand is not amplified, maintaining the original DNA strand orientation. In the htseq-count article, it states that these original strand (or first strand) amplification protocols require the "Reverse" option when using htseq-count. I tested both stranded options for the htseq-count command to confirm. The “Reverse_Present” describes the percentage of reads that were mapped to a feature given the expectation that the library prep was performed using the first strand amplification protocol. The “Yes_Percent” describes the percent of reads that were mapped to a feature given the library prep was performed using the second strand protocol. Given that there was a larger percent of reads mapping to a feature given the “reverse” option to htseq-count, we can confirm that this library prep was indeed performed using a first strand amplification protocol

