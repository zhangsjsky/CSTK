# Table of Contents
    I. Introduction
    II. Prerequisites
    III. Download and Install
    IV. Tutorial
      4.1 Common Rules
      4.2 Example
    V. Get Help

# I. Introduction
C & S's ToolKit (CSTK) is a package composed of perl, R, python and shell scripts. Using the specific script in the package or combination of scripts in the package as pipeline, may meet the general requirement of bioinfomatics analysis and complete miscellaneous tasks. Functions of CSTK pose but not limited in:

A. File format converting
B. Processing of standard file format
C. Table manipulation
D. Statistical testing
E. Survival analysis
F. Data visualization
G. Parser of third-party tool result
H. Gene expression quantification
I. Alternative splicing identification and quantification

# II. Prerequisites

CSTK mainly requires the following software/packages:

|Software/Package|Version|Description|
|:---|:---|:---|
|Perl|>=5.010|The Perl language program.|
|BioPerl|Not limited|Needed only by fqConverter.pl and mafLiftOver.pl in current version.|
|R|>=3.3.2|The R language program, mainly used for statistical analysis and data visualization.|
|ggplot2|2.x|A R package for data visualization.|
|Python|=2.7|The Python language program.|
|SAMTools|>=1.5|The toolkit to manipulate BAM files.|

The given version is just to suggest you to use this version, but not to prohibit you from using older version, although we haven’t tested the older ones. More required software/packages are script-specific. If specific script in CSTK requires specific software/packages, please install it/them.

# III. Download and Install

Please download the CSTK from the release page or clone it with git.

It's extremely easy to install CSTK, because all the source codes are written with script languages and no compilation needed. After installing the software/packages required in the "Prerequisites" section, CSTK is ready to use.

Before using CSTK, firstly add the path of CSTK into the environment variable $PATH, in order to use scripts in CSTK with command directly. Assuming CSTK is decompressed and put at `/home/<yourUserName/bin>/CSTK`, run the following command:

``` bash
PATH=/home/<yourUserName>/bin/CSTK:$PATH
```

You can add the command into your configuration file of environment (In general, it's `/home/<yourUserName>/.bashrc`), in order to use CSTK immediately after you login every time:

``` bash
cat <EOF >>/home/<yourUserName>/.bashrc
PATH=/home/<yourUserName>/CSTK:$PATH
EOF
```

# IV. Tutorial

## 4.1 Common Rules

The following rules are commonly applied in CSTK:

A) For script with only one input file, the input is fetched from STDIN (Standard Input), except that the input file is specified with argument; For script with only one output file, the output is printed to STDOUT (Standard Output), meanwhile the STDERR (Standard Error) may be used for log output; For script with 2 output files, the output may be printed to STDOUT and STDERR, respectively, and also may be printed to STDOUT and file specified with option parameter, respectively. Using STDOUT and STDERR preferentially to option is convenient to pipe the analysis steps into pipeline. Pipeline can also speed up the analysis, meanwhile avoid the immediate files reading and writing hard disk.

B) Help information of almost all scripts can be viewed with -h, -help or --help options.

C) For options with value, option and value of Perl and Shell scripts is separated by a space character (*e.g.* -option value), while that of R is separated by an equal mark (*e.g*. -option=value).

## 4.2 Example

Only one or two scripts in each function of CSTK are illustrated in these examples, illustration for more scripts will be appended according to the feedback of our users.

### 4.2.1 File Format Converting

- fqConverter.pl

``` bash
fqConverter.pl -h
```

> Usage: perl fqConverter.pl input.fq >output.fq
> 
> &ensp;&ensp;&ensp;&ensp;If INPUT isn't specified, input from STDIN
> 
> &ensp;&ensp;&ensp;&ensp;-s --source&ensp;&ensp;STR&ensp;&ensp;The quality format of your source fastq file ([fastq-illumina], fastq-solexa, fastq)
> 
> &ensp;&ensp;&ensp;&ensp;-t --target&ensp;&ensp;&ensp;STR&ensp;&ensp;The quality format of your target fastq file (fastq-illumina, fastq-solexa, [fastq])
> 
> &ensp;&ensp;&ensp;&ensp;-h --help&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;This help information screen

Since Fastq is the common file format for bioinformatics, the content of input file is not illustrated here. For details of Fastq format, please visit [wiki](https://en.wikipedia.org/wiki/FASTQ_format).

Running example:

``` bash
zcat myReads.fq.gz | fqConverter.pl >myReads.sanger.fq
```

The command converts the fastq in illumina format (default of -s option) to the famous sanger format (default of -t option).

Pipeline is applied in the command to illustrated the advantage of piping the CSTK. You can also further improved it as:

``` bash
zcat myReads.fq.gz | fqConverter.pl | gzip -c >myReads.sanger.fq.gz
```

In this way, the output fastq is stored as compressed gz file. In this analysis procedures, the CSTK script act only as the adapter in the pipeline, that is to fetch input from the output of the previous step and print output to the next step as its input.

- gpe2bed.pl


``` bash
gpe2bed.pl -h
```

> Usage: perl gpe2bed.pl INPUT.gpe >OUTPUT.bed
>
> &ensp;&ensp;&ensp;&ensp;If INPUT.gpe isn't specified, input from STDIN
>
> &ensp;&ensp;&ensp;&ensp;Output to STDOUT
>
> Option:
>
> &ensp;&ensp;&ensp;&ensp;-b --bin&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;With bin column
>
> &ensp;&ensp;&ensp;&ensp;-t --bedType&ensp;&ensp;INT&ensp;&ensp;Bed type. It can be 3, 6, 9 or 12[12]
>
> &ensp;&ensp;&ensp;&ensp;-i --itemRgb&ensp;&ensp;STR&ensp;&ensp;RGB color[0,0,0]
>
> &ensp;&ensp;&ensp;&ensp;-g --gene&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Output 'gene name' in INPUT.gpe as bed plus column
>
> &ensp;&ensp;&ensp;&ensp;-p --plus&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Output bed plus when there are additional columns in gpe
>
> &ensp;&ensp;&ensp;&ensp;-h --help&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Print this help information

Assuming there is an input file (example.gpe) with the following contents:

|||||||||||||||||
| :--: | ------------ | :---: | :--: | -------- | -------- | -------- | -------- | :--: | ------------------------------------------------------------ | ------------------------------------------------------------ | ---- | :---: | :--: | ---- | ------------------------------------------------------------ |
|76|NM_015113|chr17|-|3907738|4046253|3910183|4046189|55|3907738,3912176,3912897,3916742,3917383,3917640,3919616,3920664,3921129,3922962,3924422,3926002,3928212,3935419,3936121,3937308,3945722,3947517,3953001,3954074,3955264,3957350,3959509,3961287,3962464,3966046,3967654,3969740,3970456,3973977,3975901,3977443,3978390,3978556,3979930,3980161,3981176,3984669,3985730,3988963,3989779,3990727,3991971,3994012,3999124,3999902,4005610,4007926,4008986,4012946,4015902,4017592,4020265,4027200,4045835,|3910264,3912248,3913051,3916908,3917482,3917809,3919760,3921024,3921265,3923063,3924614,3926122,3928412,3935552,3936296,3937586,3945862,3947668,3953153,3954337,3955430,3957489,3959639,3961449,3962584,3966211,3968123,3969834,3970536,3974218,3976050,3977645,3978472,3978723,3980053,3980283,3981336,3984784,3985798,3989097,3989949,3990828,3992187,3994124,3999273,3999994,4005709,4008105,4009103,4013157,4016102,4017764,4020460,4027345,4046253,|0|ZZEF1|cmpl|cmpl|0,0,2,1,1,0,0,0,2,0,0,0,1,0,2,0,1,0,1,2,1,0,2,2,2,2,1,0,1,0,1,0,2,0,0,1,0,2,0,1,2,0,0,2,0,1,1,2,2,1,2,1,1,0,0,|
|147|NM_001308237|chr1|-|78028100|78149112|78031324|78105156|14|78028100,78031765,78034016,78041752,78044458,78045211,78046682,78047460,78047663,78050201,78105133,78107068,78107206,78148946,|78031469,78031866,78034151,78041905,78044554,78045313,78046754,78047576,78047811,78050340,78105287,78107131,78107340,78149112,|0|ZZZ3|cmpl|cmpl|2,0,0,0,0,0,0,1,0,2,0,-1,-1,-1,|
|147|NM_015534|chr1|-|78028100|78148343|78031324|78099039|15|78028100,78031765,78034016,78041752,78044458,78045211,78046682,78047460,78047663,78050201,78097534,78105133,78107068,78107206,78148269,|78031469,78031866,78034151,78041905,78044554,78045313,78046754,78047576,78047811,78050340,78099090,78105287,78107131,78107340,78148343,|0|ZZZ3|cmpl|cmpl|2,0,0,0,0,0,0,1,0,2,0,-1,-1,-1,-1,|

As shown, there is a bin column (the first column) in the gpe file, so the -b option should be specified. For the description of gpe file, please visit UCSC, http://genome.ucsc.edu/FAQ/FAQformat.html#format9.

Run the script:

``` bash
gpe2bed.pl -b example.gpe >example.bed
```

The content of the output bed file:

|||||||||||||
| ------------ | ---- | -------- | ---- | ------------------------------------------------------------ | ----- | ---------------- | -------- | -------- | -------- | -------- | ---- |
| chr17 | 3907738| 4046253| NM_015113| 0| -| 3910183| 4046189| 0,0,0 | 55 | 2526,72,154,166,99,169,144,360,136,101,192,120,200,133,175,278,140,151,152,263,166,139,130,162,120,165,469,94,80,241,149,202,82,167,123,122,160,115,68,134,170,101,216,112,149,92,99,179,117,211,200,172,195,145,418 | 0,4438,5159,9004,9645,9902,11878,12926,13391,15224,16684,18264,20474,27681,28383,29570,37984,39779,45263,46336,47526,49612,51771,53549,54726,58308,59916,62002,62718,66239,68163,69705,70652,70818,72192,72423,73438,76931,77992,81225,82041,82989,84233,86274,91386,92164,97872,100188,101248,105208,108164,109854,112527,119462,138097 |
| chr1| 78028100 | 78149112 | NM_001308237 | 0| -| 78031324 | 78105156 | 0,0,0 | 14 | 3369,101,135,153,96,102,72,116,148,139,154,63,134,166| 0,3665,5916,13652,16358,17111,18582,19360,19563,22101,77033,78968,79106,120846 |
| chr1| 78028100 | 78148343 | NM_015534| 0| -| 78031324 | 78099039 | 0,0,0 | 15 | 3369,101,135,153,96,102,72,116,148,139,1556,154,63,134,74| 0,3665,5916,13652,16358,17111,18582,19360,19563,22101,69434,77033,78968,79106,120169 |

The -t is 12 in default, so the output bed file is bed12 format. You can also try the -g or -p option to modify or add columns of output.

### 4.2.2 Processing of Standard File Format

- gpeMerge.pl

``` bash
gpeMerge.pl -h
```

> Usage: perl gpeMerge.pl input.gpe >output.gpe
> 
> &ensp;&ensp;&ensp;&ensp;If input.gpe not specified, input from STDIN
> 
> &ensp;&ensp;&ensp;&ensp;Output to STDOUT
> 
> &ensp;&ensp;&ensp;&ensp;-b --bin&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Have bin column
> 
> &ensp;&ensp;&ensp;&ensp;-l --locus&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Merge with locus (default: merge gene)
> 
> &ensp;&ensp;&ensp;&ensp;-t --longTranscript&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Overlap is against long transcript (default against short transcript)
> 
> &ensp;&ensp;&ensp;&ensp;-n --name&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Set the "gene name" column as "transcript name(s)" when the corresponding gene name unavailable
> 
> &ensp;&ensp;&ensp;&ensp;-p --percent&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;DOU&ensp;&ensp;Minimal overlap percent to merge transcript (default: 0)
> 
> &ensp;&ensp;&ensp;&ensp;-h --help&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Print this help information

The function of this script is to merge different transcripts of the same gene (or the same locus if the -l option specified). The merging criterion is: for each site of a gene, if in any transcript the site is located in exon, the site is treated as exonic site in the merged result, otherwise treated as intronic site.

A diagram to intuitively illustrate the merging:

![Merging_Illustration](https://github.com/zhangsjsky/CSTK/blob/master/Merging_Illustration.jpeg)

&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;From C.





In the figure, the first and second lines are the two transcripts of the same gene, the third line is the result after merging.

Use the example.gpe file in the previous section as input to run this script:

``` bash
gpeMerge.pl -b example.gpe >merged.gpe
```

The content of the output:

|||||||||||||||||
| ---- | ---------------------- | ----- | ---- | -------- | -------- | -------- | -------- | ---- | ------------------------------------------------------------ | ------------------------------------------------------------ | ---- | ----- | ---- | ---- | ------------------------------------------------------------ |
| 6| NM_015113| chr17 | -| 3907738| 4046253| 3910183| 4046189| 55 | 3907738,3912176,3912897,3916742,3917383,3917640,3919616,3920664,3921129,3922962,3924422,3926002,3928212,3935419,3936121,3937308,3945722,3947517,3953001,3954074,3955264,3957350,3959509,3961287,3962464,3966046,3967654,3969740,3970456,3973977,3975901,3977443,3978390,3978556,3979930,3980161,3981176,3984669,3985730,3988963,3989779,3990727,3991971,3994012,3999124,3999902,4005610,4007926,4008986,4012946,4015902,4017592,4020265,4027200,4045835, | 3910264,3912248,3913051,3916908,3917482,3917809,3919760,3921024,3921265,3923063,3924614,3926122,3928412,3935552,3936296,3937586,3945862,3947668,3953153,3954337,3955430,3957489,3959639,3961449,3962584,3966211,3968123,3969834,3970536,3974218,3976050,3977645,3978472,3978723,3980053,3980283,3981336,3984784,3985798,3989097,3989949,3990828,3992187,3994124,3999273,3999994,4005709,4008105,4009103,4013157,4016102,4017764,4020460,4027345,4046253, | 0| ZZEF1 | cmpl | cmpl | 0,0,2,1,1,0,0,0,2,0,0,0,1,0,2,0,1,0,1,2,1,0,2,2,2,2,1,0,1,0,1,0,2,0,0,1,0,2,0,1,2,0,0,2,0,1,1,2,2,1,2,1,1,0,0, |
| 147| NM_001308237,NM_015534 | chr1| -| 78028100 | 78149112 | 78028100 | 78149112 | 16 | 78028100,78031765,78034016,78041752,78044458,78045211,78046682,78047460,78047663,78050201,78097534,78105133,78107068,78107206,78148269,78148946 | 78031469,78031866,78034151,78041905,78044554,78045313,78046754,78047576,78047811,78050340,78099090,78105287,78107131,78107340,78148343,78149112 | 0| ZZZ3| unk| unk| -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, |

As you can see, the two records of the transcripts of the *ZZZ3* gene have been merged into one record. The start and end of exons are updated as the coordinates after merging and the other information associated with coordinate is also updated according to the coordinates after merging. The column of transcript name is also updated as comma-separated transcript list.

- gpeFeature.pl

``` bash
gpeFeature.pl -h
```

> Usage: perl gpeFeature.pl OPTION INPUT.gpe >OUTPUT.bed
>
> &ensp;&ensp;&ensp;&ensp;If INPUT.gpe isn't specified, input from STDIN
>
> &ensp;&ensp;&ensp;&ensp;Example: perl gpeFeature.pl -b -g hg19.size --upstream 1000 hg19.refGene.gpe >hg19.refGene.bed
>
> Option:
>
> &ensp;&ensp;&ensp;&ensp;-b --bin&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;With bin column
>
> &ensp;&ensp;&ensp;&ensp;-i --intron&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Fetch introns in each transcript
>
> &ensp;&ensp;&ensp;&ensp;-e --exon&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Fetch exons in each transcript
>
> &ensp;&ensp;&ensp;&ensp;-c --cds&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Fetch CDS in each transcript
>
> &ensp;&ensp;&ensp;&ensp;-u --utr&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Fetch UTRs in each transcript, 5'UTR then 3'UTR (or 3' first)
>
> &ensp;&ensp;&ensp;&ensp;-p --prime&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;INT&ensp;&ensp;&ensp;5 for 5'UTR, 3 for 3'UTR(force -u)
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;--complete&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Only fetch UTR for completed transcripts
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;--upstream&ensp;&ensp;&ensp;&ensp;&ensp;INT&ensp;&ensp;Fetch upstream INT intergenic regions(force -g)
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;--downstream&ensp;&ensp;INT&ensp;&ensp;Fetch downstream INT intergenice regions(force -g)
>
> &ensp;&ensp;&ensp;&ensp;-g  --chrSize&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;FILE&ensp;&ensp;Tab-separated file with two columns: chr name and its length
>
> &ensp;&ensp;&ensp;&ensp;-s   --single&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Bundle all features into single line for each transcript
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;--addIndex&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Add exon/intron/CDS/UTR index as suffix of name in the 4th column
>
> &ensp;&ensp;&ensp;&ensp;-h  --help&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Print this help information

This script is used to extract specific feature from the gpe file and output in bed format.

For example, to extract exons:

``` bash
gpeFeature.pl -b example.gpe -e >exon.bed6+
```

||||||||||
| ----- | ------- | ------- | --------- | ---- | ---- | --------- | ---- | ----- |
| chr17 | 3907738 | 3910264 | NM_015113 | 0| -| NM_015113 | 2526 | ZZEF1 |
| chr17 | 3912176 | 3912248 | NM_015113 | 0| -| NM_015113 | 72 | ZZEF1 |
| chr17 | 3912897 | 3913051 | NM_015113 | 0| -| NM_015113 | 154| ZZEF1 |

More records of the output are omitted. The result is in bed6+ format with each line represent an exon. The last two columns present the exon length and gene name.

### 4.2.3 Table Manipulation

- tsvFilter.pl

``` bash
tsvFilter.pl -h
```

> Usage: perl tsvFilter.pl -o originFile.tsv -1 1,4 -m i|include targetFile.tsv >filtered.tsv
>
> &ensp;&ensp;&ensp;&ensp;If targetFile.tsv isn't specified, input is from STDIN
>
> &ensp;&ensp;&ensp;&ensp;Output to STDOUT
>
> Option:
>
> &ensp;&ensp;&ensp;&ensp;-o --originFile&ensp;&ensp;&ensp;&ensp;TSV&ensp;&ensp;The original file containing fields (specified by --originFields) used to include or exclude lines in targetFile.tab
>
> &ensp;&ensp;&ensp;&ensp;-1 --originFields&ensp;&ensp;STR&ensp;&ensp;Comma-separated field list specifying which fileds in the originFile.tab to be used to include or exclude, 1-based start [1]
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;The element of the list can be a single column number or a range with nonnumeric char as separator
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;To specify the last column left the range right margin blank
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;If continuous range specified like '1-3-6', the first range '1-3' will be output
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;*e.g.*:
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;-1 1,4     &ensp;&ensp;&ensp;output columns 1,4
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;-1 1-4,6..8&ensp;output columns 1,2,3,4,6,7,8
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;-1 1,4,6- &ensp;&ensp;output columns 1,4,6,7,... last column
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;-1 1-3-6 &ensp;&ensp;output columns 1,2,3
>
> &ensp;&ensp;&ensp;&ensp;-2 --targetFields&ensp;&ensp;STR&ensp;&ensp;Comma-separated field list specifying which fileds in the targetFile.tab are used to include or exclude lines, 1-based start [1]
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;More description about --targetFields, see --originFields
>
> &ensp;&ensp;&ensp;&ensp;-m --mode&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;To include or exclude lines in targetFile.tab, it can be i|include or e|exclude[e]
>
> &ensp;&ensp;&ensp;&ensp;-s --separator&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;(Optional)A separator to join the fields specified, if necessary[Empty string]
>
> &ensp;&ensp;&ensp;&ensp;-h --help&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Print this help information

This script is often used in table manipulation. It's function is to filter the target table according to one column or some columns (i.g. the target columns) with one or some columns (i.g. the source column) of another table (i.g. source table). The mode it's based is whether target columns include (or exclude) the source columns.

Assuming the first column of the source table (source.tsv) is gene name, the second column is up- or down- regulation mark. It's content is:

|       |      |
| ----- | ---- |
| Gene1 | Up   |
| Gene2 | Down |
| Gene3 | Up   |

The first column of the target table (target.tsv) is gene name, the second column is up- or down- regulation fold-change. It's content is:

|       |      |
| ----- | ---- |
| Gene1 | 5    |
| Gene2 | 10   |
| Gene3 | 2    |

If you want to know the fold-change of the up-regulated genes, run the following command:

``` bash
tsvFilter.pl -o <(awk '$2=="Up"' source.tsv) -m i target.tsv
```

The output is:

|       |      |
| ----- | ---- |
| Gene1 | 5    |
| Gene3 | 2    |

The command fetches up-regulated genes with awk firstly, and then feeds it to the -o option as input to filter the target.tsv file. -m option specifies the filtering mode as "include". Because both the source column and target column are the first column, -1 and -2 options are specified as 1 in default.

- tsvJoin.sh

``` bash
tsvJoin.sh
```
> Usage: tsvJoin.sh OPTIONS [-1 field1\]\[-2 fields2\] input1.tsv [input2.tsv]
>
> Note: input2.tsv can be omitted or be a "-" to input the data from STDIN.
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;when input1.tsv is a "-" (i.e. from STDIN), input2.tsv must be specified.
>
> Options:
>
> -1|field1&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;The field in input1.tsv used when joining[1]
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Refer to the -1 option of linux join command
>
> -2 field2&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;The field in input2.tsv used when joining[1]
>
> -i|inputDelimiter&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;The delimiter of your input file[\t]
>
> -j|joinDelimiter&ensp;&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;The delimiter used by linux join commond (i.e. the -t option of join command)[|]
>
> -o|outputDelimiter&ensp;&ensp;STR&ensp;&ensp;The delimiter of the output[\t]
>
> -a|unpairedFile&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;INT&ensp;&ensp;Also print unpairable lines from file INT (1, 2)
>
>
>
> Please specify at least one file

This script is also often used in table manipulation. It's function is to join two table according to whether the values of one column or some columns are the same. Different from the join command built in Linux, this script can use the tab character as separated character.

Take the previous source.tsv and target.tsv as examples, join them according to gene name:

``` bash
tsvJoin.sh source.tsv target.tsv >join.tsv 2>/dev/null
```

The output join.tsv is:

|       |      |      |
| ----- | ---- | ---- |
| Gene1 | Up   | 5    |
| Gene2 | Down | 10   |
| Gene3 | Up   | 2    |

In the command, '2>/dev/null' means discarding the STDERR (for output running information). Because the columns used to joining in the two input table are both the first column, -1 and -2 options are specified as 1 in default.

In the above output, the column used to join (i.g. the gene name column) is set as the first column and is followed by the other columns in the first and the second files, except for the column used to join.

### 4.2.4 Statistical Testing

- testT.R
``` bash
testT.R -h
```
> Usage: testT.R -option=value <input.lst|<input1.lst input2.lst|input1.lst input2.lst >pValue
> 
> Option:
> 
> &ensp;&ensp;&ensp;&ensp;-p|pair&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Pair
> 
> &ensp;&ensp;&ensp;&ensp;-a|alt&ensp;&ensp;STR&ensp;&ensp;The alternative hypothesis: [two.sided], greatr or less
> 
> &ensp;&ensp;&ensp;&ensp;-h&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Show help

This script is used to conduct T-test testing. '<input.lst|<input1.lst input2.lst|input1.lst input2.lst' means there are a few input manners: A) Input one file from STDIN; B) Input from STDIN and option file, respectively; C) Input from two option files, respectively. The commonly used manner is the third one:

Assuming the content of the first file (value1.lst) is:

1

2

3

4

5

And that of the second file is:

3

4

5

6

7

8

``` bash
testT.R value1.lst value2.lst
```

> 0.0398030820241363

The output p-value indicates there is significant difference between the two list of values.

- testWilcoxon.R

``` bash
testWilcoxon.R -h
```
> Usage: testWilcoxon.R -option=value <input.lst|input.lst|input1.lst input2.lst >pValue
> 
> Options
> 
> &ensp;&ensp;&ensp;&ensp;-a|alt&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;The alternative hypothesis ([two.sided], greater, less)
> 
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;You can specify just the initial letter
> 
> &ensp;&ensp;&ensp;&ensp;-m|mu&ensp;&ensp;DOU&ensp;&ensp;A parameter used to form the null hypothesis for one-sample test[0]
> 
> &ensp;&ensp;&ensp;&ensp;-h|help&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Show help

```` bash
testWilcoxon.R value1.lst value2.lst 2>/dev/null
````

> 0.06601543

The output p-value indicates there isn't significant difference between the two list of values. The conclusion is different from the T-test.

### 4.2.5 Survival Analysis

- survival.R

``` bash
survival.R -h
```
> Usage: survival.R -option=value <input.tsv
> 
> Option:
> 
> &ensp;&ensp;&ensp;&ensp;-p|pdf&ensp;&ensp;&ensp;&ensp;&ensp;PDF&ensp;&ensp;The KM figure[KM.pdf]
> 
> &ensp;&ensp;&ensp;&ensp;-w|width&ensp;&ensp;&ensp;INT&ensp;&ensp;The figure width
> 
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;height&ensp;&ensp;INT&ensp;&ensp;The figure height
> 
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;header&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;With header
> 
> &ensp;&ensp;&ensp;&ensp;-m|main&ensp;&ensp;&ensp;STR&ensp;&ensp;The main title
> 
> &ensp;&ensp;&ensp;&ensp;-x|xlab&ensp;&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;The xlab[Time]
> 
> &ensp;&ensp;&ensp;&ensp;-y|ylab&ensp;&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;The ylab[Survival Probability]
> 
> &ensp;&ensp;&ensp;&ensp;-h&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Show help
> 
> Input (header isn't necessary):
> 
> &ensp;&ensp;Example1:
> 
> &ensp;&ensp;&ensp;&ensp;\#time&ensp;event
> 
> &ensp;&ensp;&ensp;&ensp;1&ensp;&ensp;&ensp;&ensp;&ensp;TRUE
> 
> &ensp;&ensp;&ensp;&ensp;2&ensp;&ensp;&ensp;&ensp;&ensp;TRUE
> 
> &ensp;&ensp;&ensp;&ensp;2&ensp;&ensp;&ensp;&ensp;&ensp;TRUE
> 
> &ensp;&ensp;&ensp;&ensp;8&ensp;&ensp;&ensp;&ensp;&ensp;FALSE
> 
> &ensp;&ensp;&ensp;&ensp;5&ensp;&ensp;&ensp;&ensp;&ensp;TRUE
> 
> &ensp;&ensp;&ensp;&ensp;10&ensp;&ensp;&ensp;&ensp;FALSE
> 
> &ensp;&ensp;Example2:
> 
> &ensp;&ensp;&ensp;&ensp;\#time&ensp;event  &ensp;group
> 
> &ensp;&ensp;&ensp;&ensp;1&ensp;&ensp;&ensp;&ensp;&ensp;TRUE&ensp;&ensp;male
> 
> &ensp;&ensp;&ensp;&ensp;2&ensp;&ensp;&ensp;&ensp;&ensp;TRUE&ensp;&ensp;male
> 
> &ensp;&ensp;&ensp;&ensp;2&ensp;&ensp;&ensp;&ensp;&ensp;TRUE&ensp;&ensp;male
> 
> &ensp;&ensp;&ensp;&ensp;8&ensp;&ensp;&ensp;&ensp;&ensp;FALSE&ensp;male
> 
> &ensp;&ensp;&ensp;&ensp;5&ensp;&ensp;&ensp;&ensp;&ensp;TRUE&ensp;&ensp;female
> 
> &ensp;&ensp;&ensp;&ensp;10&ensp;&ensp;&ensp;&ensp;FALSE&ensp;female

As the help information presents, creating an input file as the Example2 (survival.tsv). Feed it to the script as input and specify the output pdf file:

``` bash
survival.R -p=survival.pdf <survival.tsv >survival.log 2>survival.err
```

Survival curve (i.g. Kaplan-Meier curve) and the log-rank p-value are stored in the pdf. Statistical measurements are stored in survival.log.

### 4.2.6 Data Visualization

- bar.R


``` bash
bar.R -h
```

> Usage: bar.R -p=outputName.pdf <input.tsv
> 
> Option:
> 
> Common:
> 
> &ensp;&ensp;&ensp;&ensp;-p|pdf&ensp;&ensp;&ensp;&ensp;FILE&ensp;&ensp;The output figure in pdf[figure.pdf]
> 
> &ensp;&ensp;&ensp;&ensp;-w|width&ensp;&ensp;INT&ensp;&ensp;The figure width
> 
> &ensp;&ensp;&ensp;&ensp;-height&ensp;&ensp;&ensp;INT&ensp;&ensp;The figure height
> 
> &ensp;&ensp;&ensp;&ensp;-m|main&ensp;&ensp;STR&ensp;&ensp;The main title
> 
> Contents omitted…
> 
> &ensp;&ensp;&ensp;&ensp;-annoTxt&ensp;&ensp;&ensp;STRs&ensp;&ensp;The comma-separated texts to be annotated
> 
> &ensp;&ensp;&ensp;&ensp;-annoTxtX&ensp;&ensp;INTs&ensp;&ensp;The comma-separated X positions of text
> 
> &ensp;&ensp;&ensp;&ensp;-annoTxtY&ensp;&ensp;INTs&ensp;&ensp;The comma-separated Y positions of text
> 
> &ensp;&ensp;&ensp;&ensp;-annoTxtS&ensp;&ensp;DOU&ensp;&ensp;The annotated text size[5]
> 
> Skill:
> 
> &ensp;&ensp;&ensp;&ensp;Legend title of alpha, color, *etc* can be set as the same to merge their guides

This script is used to draw bar chart. Take the survival.tsv in the previous section as input to draw:

``` bash
awk 'BEGIN{OFS="\t"}{print NR,$1,$3}' survival.tsv | bar.R -p=bar.pdf -fillV=V3 -x='Patient ID' -y=Time -fillT=Gender
```

In the command, awk is used to process the input before passing the data to bar.R. The processed results are:

||||
| ---- | ---- | ------ |
| 1| 1| male |
| 2| 2| male |
| 3| 4| male |
| 4| 8| male |
| 5| 5| female |
| 6| 10 | female |

The extra patient ID information is added as the first column and will be presented at X axis. The second column is survival time and will be presented at Y axis. The third column is gender and will be used to fill bar with different color. If the third column isn't presented, the bars are filled in black in default.

In the parameters of bar.R, -fillV=V3 tells it to use the third column (column name: V3) to color bars. Don't specify this option if no third column. -x and -y specify the label of X and Y axis, respectively. -fillT specify the title of the fill-legend.

- hist.R

``` bash
hist.R -h
```

> Usage: hist.R -p=outputName.pdf <input.tsv
> 
> Option:
> 
> &ensp;&ensp;&ensp;&ensp;Common:
> 
> &ensp;&ensp;&ensp;&ensp;-p|pdf&ensp;&ensp;&ensp;&ensp;FILE&ensp;&ensp;&ensp;The output figure in pdf[figure.pdf]
> 
> &ensp;&ensp;&ensp;&ensp;-w|width&ensp;&ensp;INT&ensp;&ensp;&ensp;The figure width
> 
> &ensp;&ensp;&ensp;&ensp;-m|main&ensp;&ensp;STR&ensp;&ensp;&ensp;The main title
> 
> &ensp;&ensp;&ensp;&ensp;-mainS&ensp;&ensp;&ensp;DOU&ensp;&ensp;The size of main title[22 for ggplot]
> 
> &ensp;&ensp;&ensp;&ensp;-x|xlab&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;&ensp;The xlab[Binned Values]
> 
> &ensp;&ensp;&ensp;&ensp;-y|ylab&ensp;&ensp;&ensp;&ensp;STR&ensp;&ensp;&ensp;The ylab
> 
> Contents omitted…
> 
> &ensp;&ensp;&ensp;&ensp;-annoTxt&ensp;&ensp;&ensp;STRs&ensp;&ensp;The comma-separated texts to be annotated
> 
> &ensp;&ensp;&ensp;&ensp;-annoTxtX&ensp;&ensp;INTs&ensp;&ensp;The comma-separated X positions of text
> 
> &ensp;&ensp;&ensp;&ensp;-annoTxtY&ensp;&ensp;INTs&ensp;&ensp;The comma-separated Y positions of text
> 
> Skill:
> 
> &ensp;&ensp;&ensp;&ensp;Legend title of alpha, color, *etc* can be set as the same to merge their guides

This script is used to draw histogram.

``` bash
hist.R -p=hist.pdf -x=Time -y='Patient Count' <survival.tsv
```

Only one column of values is needed to draw a histogram, so feeds survival.tsv as input then the first column will be used default to draw histogram.

### 4.2.7 Parser of Third-party Tool Result

- coverageBedParser.pl

``` bash
coverageBedParser.pl -h
```

> Usage: perl coverageBedParser.pl coverageBedOutput.tsv >OUTPUT.tsv
> 
> &ensp;&ensp;&ensp;&ensp;If coverageBedOutput.tsv isn't specified, input from STDIN
> 
> Option:
> 
> &ensp;&ensp;&ensp;&ensp;-b  -bedFormat&ensp;&ensp;INT&ensp;&ensp;Bed format ([3], 6)
> 
> &ensp;&ensp;&ensp;&ensp;-h  --help&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Print this help information


This script is used to parse the output result of 'bedtools coverage', calculate the mean depth and covered fraction of each region.

``` bash
coverageBedParser.pl coverage.bed >coverageParsed.bed
```

- fastqcParser.pl

``` bash
fastqcParser.pl -h
```

> Usage: perl fastqcParser.pl OPTION fastqc_data.txt >OUTPUT.tsv
> 
> &ensp;&ensp;&ensp;&ensp;If INPUT isn't specified, input from STDIN
> 
> Options:
> 
> &ensp;&ensp;&ensp;&ensp;-h  --help&ensp;&ensp;Print this help information

This script is used to parse the result (in general, the fastqc_data.txt) of FastQC, extract read-count, GC content and mean quality *etc*. and output as a table.

``` bash
fastqcParser.pl fastqc_data.txt >fastqcDataParsed.tsv
```

### 4.2.8 Gene Expression Quantification

geneRPKM.pl

``` bash
geneRPKM.pl -h
```

> Usage: perl geneRPKM.pl -g gene_structure.gpe -s 4 INPUT.BAM >RPKM.bed6+ 2>running.log
> 
> &ensp;&ensp;&ensp;&ensp;If INPUT.BAM isn't specified, input is from STDIN
> 
> &ensp;&ensp;&ensp;&ensp;Output to STDOUT in bed6 (gene in name column, RPKM in score column) plus longest transcript, readNO and transcript length
> 
> &ensp;&ensp;&ensp;&ensp;This script chooses the LONGEST transcript of each gene as reference transcript to measure RPKM
> 
> Option:
> 
> &ensp;&ensp;&ensp;&ensp;-g --gpe&ensp;&ensp;&ensp;&ensp;&ensp;FILE&ensp;&ensp;A gpe file with comment or track line allowed
> 
> &ensp;&ensp;&ensp;&ensp;-b --bin&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;With bin column
> 
> &ensp;&ensp;&ensp;&ensp;-l --libType&ensp;&ensp;STR&ensp;&ensp;The library type, it can be
> 
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;fr-unstranded: for Standard Illumina (default)
> 
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;fr-firststrand: for dUTP, NSR, NNSR
> 
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;fr-secondstrand: for Ligation, Standard SOLiD and Illumina Directional Protocol
> 
> &ensp;&ensp;&ensp;&ensp;-s --slop&ensp;&ensp;&ensp;&ensp;&ensp;INT&ensp;&ensp;Specify the slopping length from the exon-intron joint to intron[0]
> 
> &ensp;&ensp;&ensp;&ensp;-u --uniq&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Only use uniquely-mapped reads (NH=1)to compute RPKM
> 
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;--log&ensp;&ensp;&ensp;&ensp;&ensp;FILE&ensp;&ensp;Record running log into FILE
> 
> &ensp;&ensp;&ensp;&ensp;-h --help&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Print this help information

As the help information describes, this script chooses the longest transcript of each gene as the reference to quantify the expression of each gene with RPKM. The output result is stored in bed6+. An running example:

``` bash
geneRPKM.pl -g refGene.gpe -b -s 4 final.bam >RPKM.bed6+ 2>geneRPKM.log
```

In the command, -s option specifies the length in which reads can extend from exon into intron. This option is devised to handle the situation that reads may be incapable of spanning an intron to be aligned to the adjacent exon with a few base-pair.

This script may consume too much memory (depend on the size of the input bam file). If the memory isn't enough on the machine, the script geneRPKM_mem.pl, which consumes little memory but runs slowly, may be a alternative choice.

- regionRPKM.pl

``` bash
regionRPKM.pl -h
```

> Usage: perl regionRPKM.pl -b region.bed INPUT.bam >RPKM.bed 2>running.log
> 
> &ensp;&ensp;&ensp;&ensp;If INPUT.bam isn't specified, input from STDIN
> 
> &ensp;&ensp;&ensp;&ensp;Output to STDOUT with bed columns plus reads count in region and its RPKM
> 
> Note: INPUT.bam should be indexed with samtools index
> 
> &ensp;&ensp;&ensp;&ensp;This script is for handling bam file in normal size that can be entirely cached into memory.
> 
> &ensp;&ensp;&ensp;&ensp;It's MEMORY-CONSUMED but low TIME-CONSUMED compared to its equivalent regionRPKM_mem.pl.
> 
> &ensp;&ensp;&ensp;&ensp;Spliced reads are handled now. Those that include the whole region within intron aren't counted.
> 
> Option:
> 
> &ensp;&ensp;&ensp;&ensp;-b|bedFile&ensp;&ensp;FILE&ensp;&ensp;Region file in bed4 or bed6 format. bed plus is allowed.
> 
> &ensp;&ensp;&ensp;&ensp;-l|libType&ensp;&ensp;&ensp;STR&ensp;&ensp;The library type, it can be
> 
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;fr-unstranded: for Standard Illumina (default)
> 
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;fr-firststrand: for dUTP, NSR, NNSR
> 
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;fr-secondstrand: for Ligation, Standard SOLiD and Illumina Directional Protocol
> 
> &ensp;&ensp;&ensp;&ensp;-h --help&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Print this help information

This script calculates the RPKM of specific regions (specified by --bedFile option). An running example:

``` bash
regionRPKM.pl --bedFile exon.bed final.bam >RPKM.bed 2>regionRPKM.log
```

Similarly, if the memory isn't enough, use regionRPKM_mem.pl as alternative.

### 4.2.9 Alternative Splicing Identification and Quantification

On identification and quantification of SE (Skipping Exon) event is implemented in current version.

- psiSE.pl

``` bash
psiSE.pl -h
```

> Usage: perl psiSE.pl INPUT.bam >OUTPUT.bed6+
>
> &ensp;&ensp;&ensp;&ensp;If INPUT.bam isn't specified, input from STDIN
>
> Option:
>
> &ensp;&ensp;&ensp;&ensp;-b --bed&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;FILE&ensp;&ensp;Gene models in bed12 format
>
> &ensp;&ensp;&ensp;&ensp;-l --libraryType&ensp;&ensp;STR&ensp;&ensp;The library type, it can be
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;fr-unstranded: for Standard Illumina (default)
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;fr-firststrand: for dUTP, NSR, NNSR
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;fr-secondstrand: for Ligation, Standard SOLiD and Illumina Directional Protocol
>
> &ensp;&ensp;&ensp;&ensp;-s --slop&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;INT&ensp;&ensp;Maximal slope length for a read to be considered as exonic read[4]
>
> &ensp;&ensp;&ensp;&ensp;-r --minRead&ensp;&ensp;&ensp;&ensp;INT&ensp;&ensp;Minimal supporting reads count for an exclusion junction[2]
>
> &ensp;&ensp;&ensp;&ensp;-h --help&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;Print this help information
>
> Output:
>
> &ensp;&ensp;&ensp;&ensp;The 4th column is the transcript name and the exon rank (in transcriptional direction) separated by a dot.
>
> &ensp;&ensp;&ensp;&ensp;The 5th column in OUTPUT.bed6+ is the PSI normalized into 0-1000.
>
> &ensp;&ensp;&ensp;&ensp;Additional columns are as follow:
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;inclusion read count
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;inclusion region length
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;inclusion read density
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;exclusion read counts separated by comma
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;exclusion region lengths separated by comma
>
> &ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;exclusion read density

This script is used to identify and quantify the PSI of SE event from the alignments. An using example:

``` bash
psiSE.pl final.bam >SE.bed6+
```

Refer to the help information for the format of the output result.

# V. Get Help

You can send the author [Sky](mailto:zhangsjsky@foxmail.com) any information about this toolkit, like bug reporting and performance improvement suggestion.
