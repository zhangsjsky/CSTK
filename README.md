# Table of Contents
    I Introduction
    II Prerequisites
    III Download and Install
    IV Tutorial

## I Introduction
C & S's ToolKit (CSTK) is a package composed of perl, R, python and shell scripts. Using the specific tool in the package or combination of tools in the package as pipeline, may meet the general requirement of bioinfomatics analysis and complete miscellaneous tasks. Functions of CSTK pose but not limited in:

1. File format converting
2. Processing of standard file format
3. Table manipulation
4. Statistical testing
5. Survival analysis
6. Data visualization
7. Third-party tool result parser
8. Gene expression quantification
9. Alternative splicing identification and quantification

## II Prerequisites

​    CSTK mainly requires the following software/packages:

|Software/Package|Version|Description|
|:---|:---|:---|
|Perl|>=5.010|The Perl language program.|
|BioPerl|Not limited|Needed only by fqConverter.pl and mafLiftOver.pl in current version.|
|R|>=3.3.2|The R language program, mainly used for statistical analysis and data visualization.|
|ggplot2|2.x|A R package for data visualization.|
|Python|=2.7|The Python language program.|
|SAMTools|>=1.5|The toolkit to manipulate BAM files.|

​    The given version is just to suggest you to use this version, but not to prohibit you from using older version, although we haven’t tested the older ones. More required software/packages are tool-specific. If specific tool in CSTK requires specific software/packages, please install it/them.

# III Download and Install

​    Please download the CSTK from the release page or clone it with git.

​    It's extremely easy to install CSTK, because all the source codes are written with script languages and no compilation needed. After installing the software/packages required in the "Prerequisites" section, CSTK is ready to use.

Before using CSTK, firstly add the path of CSTK into the environment variable $PATH, in order to use tools in CSTK with command directly. Assuming CSTK is decompressed and put at `/home/<yourUserName/bin>/CSTK`, run the following command:

``` bash
PATH=/home/<yourUserName>/bin/CSTK:$PATH
```

​    You can add the command into your configuration file of environment (In general, it's `/home/<yourUserName>/.bashrc`), in order to use CSTK immediately after you login every time:

``` bash
cat <EOF >>/home/<yourUserName>/.bashrc
PATH=/home/<yourUserName>/CSTK:$PATH
EOF
```

# IV Tutorial

## 4.1 Common Rules

​    The following rules are commonly applied in CSTK:

A) For tool with only one input file, the input is fetched from STDIN (Standard Input), except that the input file is specified with argument; For tool with only one output file, the output is printed to STDOUT (Standard Output), meanwhile the STDERR (Standard Error) may be used for log output; For tool with 2 output files, the output may be printed to STDOUT and STDERR, respectively, and also may be printed to STDOUT and file specified with option parameter, respectively. Using STDOUT and STDERR preferentially to option is convenient to pipe the analysis steps into pipeline. Pipeline can also speed up the analysis, meanwhile avoid the immediate files reading and writing hard disk.

B) Help information of almost all tools can be viewed with -h, -help or --help options.

C) For options with value, option and value of Perl and Shell scripts is separated by a space character (e.g. -option value), while that of R is separated by a equal mark (e.g. -option=value).

## 4.2 Example

​    Only one or two tools in each function of CSTK are illustrated in these examples, illustration for more tools will be appended according to the feedback of our users.

### 4.2.1 File Format Converting

- fqConverter.pl

``` bash
fqConverter.pl -h
```

> Usage: perl fqConverter.pl input.fq >output.fq
>
> ​    If INPUT isn't specified, input from STDIN
>
> ​    -s  --source  STR   The quality format of your source fastq file ([fastq-illumina], fastq-solexa, fastq)
>
> ​    -t  --target    STR   The quality format of your target fastq file (fastq-illumina, fastq-solexa, [fastq])
>
> ​    -h  --help                This help information screen

​    Since Fastq is the common file format for bioinformatics, the content of input file is not illustrated here. For details of Fastq format, please visit wiki [https://en.wikipedia.org/wiki/FASTQ_format].

​    Running example:

``` bash
zcat myReads.fq.gz | fqConverter.pl >myReads.sanger.fq
```

​    The command converts the fastq in illumina format (default of -s option) to the famous sanger format (default of -t option).

​    Pipeline is applied in the command to illustrated the advantage of piping the CSTK. You can also further improved it as:

``` bash
zcat myReads.fq.gz | fqConverter.pl | gzip -c >myReads.sanger.fq.gz
```

​    In this way, the output fastq is stored as compressed gz file. In this analysis procedures, the CSTK tool act only as  the adapter in the pipeline, that is to fetch input from the output of the previous step and print output to the next step as its input.



- gpe2bed.pl


``` bash
gpe2bed.pl -h
```

> Usage: perl gpe2bed.pl INPUT.gpe >OUTPUT.bed
>
> ​    If INPUT.gpe isn't specified, input from STDIN
>
> ​    Output to STDOUT
>
> Option:
>
> ​    -b --bin                      With bin column
>
> ​    -t --bedType    INT   Bed type. It can be 3, 6, 9 or 12[12]
>
> ​    -i --itemRgb    STR   RGB color[0,0,0]
>
> ​    -g --gene                  Output 'gene name' in INPUT.gpe as bed plus column
>
> ​    -p --plus                   Output bed plus when there are additional columns in gpe
>
> ​    -h --help                   Print this help information

​    Assuming there is an input file (example.gpe) with the following contents:

|      |              |       |      |          |          |          |          |      |                                                              |                                                              |      |       |      |      |                                                              |
| :--: | ------------ | :---: | :--: | -------- | -------- | -------- | -------- | :--: | ------------------------------------------------------------ | ------------------------------------------------------------ | ---- | :---: | :--: | ---- | ------------------------------------------------------------ |
|76|NM_015113|chr17|-|3907738|4046253|3910183|4046189|55|3907738,3912176,3912897,3916742,3917383,3917640,3919616,3920664,3921129,3922962,3924422,3926002,3928212,3935419,3936121,3937308,3945722,3947517,3953001,3954074,3955264,3957350,3959509,3961287,3962464,3966046,3967654,3969740,3970456,3973977,3975901,3977443,3978390,3978556,3979930,3980161,3981176,3984669,3985730,3988963,3989779,3990727,3991971,3994012,3999124,3999902,4005610,4007926,4008986,4012946,4015902,4017592,4020265,4027200,4045835,|3910264,3912248,3913051,3916908,3917482,3917809,3919760,3921024,3921265,3923063,3924614,3926122,3928412,3935552,3936296,3937586,3945862,3947668,3953153,3954337,3955430,3957489,3959639,3961449,3962584,3966211,3968123,3969834,3970536,3974218,3976050,3977645,3978472,3978723,3980053,3980283,3981336,3984784,3985798,3989097,3989949,3990828,3992187,3994124,3999273,3999994,4005709,4008105,4009103,4013157,4016102,4017764,4020460,4027345,4046253,|0|ZZEF1|cmpl|cmpl|0,0,2,1,1,0,0,0,2,0,0,0,1,0,2,0,1,0,1,2,1,0,2,2,2,2,1,0,1,0,1,0,2,0,0,1,0,2,0,1,2,0,0,2,0,1,1,2,2,1,2,1,1,0,0,|
|147|NM_001308237|chr1|-|78028100|78149112|78031324|78105156|14|78028100,78031765,78034016,78041752,78044458,78045211,78046682,78047460,78047663,78050201,78105133,78107068,78107206,78148946,|78031469,78031866,78034151,78041905,78044554,78045313,78046754,78047576,78047811,78050340,78105287,78107131,78107340,78149112,|0|ZZZ3|cmpl|cmpl|2,0,0,0,0,0,0,1,0,2,0,-1,-1,-1,|
|147|NM_015534|chr1|-|78028100|78148343|78031324|78099039|15|78028100,78031765,78034016,78041752,78044458,78045211,78046682,78047460,78047663,78050201,78097534,78105133,78107068,78107206,78148269,|78031469,78031866,78034151,78041905,78044554,78045313,78046754,78047576,78047811,78050340,78099090,78105287,78107131,78107340,78148343,|0|ZZZ3|cmpl|cmpl|2,0,0,0,0,0,0,1,0,2,0,-1,-1,-1,-1,|

​    As shown, there is a bin column (the first column) in the gpe file, so the -b option should be specified. For the description of gpe file, please visit http://genome.ucsc.edu/FAQ/FAQformat.html#format9.

Run the script:

``` bash
gpe2bed.pl -b example.gpe >example.bed
```

​    The content of the output bed file:

|              |      |          |      |                                                              |       |                  |          |          |          |          |      |
| ------------ | ---- | -------- | ---- | ------------------------------------------------------------ | ----- | ---------------- | -------- | -------- | -------- | -------- | ---- |
| chr17 | 3907738| 4046253| NM_015113| 0| -| 3910183| 4046189| 0,0,0 | 55 | 2526,72,154,166,99,169,144,360,136,101,192,120,200,133,175,278,140,151,152,263,166,139,130,162,120,165,469,94,80,241,149,202,82,167,123,122,160,115,68,134,170,101,216,112,149,92,99,179,117,211,200,172,195,145,418 | 0,4438,5159,9004,9645,9902,11878,12926,13391,15224,16684,18264,20474,27681,28383,29570,37984,39779,45263,46336,47526,49612,51771,53549,54726,58308,59916,62002,62718,66239,68163,69705,70652,70818,72192,72423,73438,76931,77992,81225,82041,82989,84233,86274,91386,92164,97872,100188,101248,105208,108164,109854,112527,119462,138097 |
| chr1| 78028100 | 78149112 | NM_001308237 | 0| -| 78031324 | 78105156 | 0,0,0 | 14 | 3369,101,135,153,96,102,72,116,148,139,154,63,134,166| 0,3665,5916,13652,16358,17111,18582,19360,19563,22101,77033,78968,79106,120846 |
| chr1| 78028100 | 78148343 | NM_015534| 0| -| 78031324 | 78099039 | 0,0,0 | 15 | 3369,101,135,153,96,102,72,116,148,139,1556,154,63,134,74| 0,3665,5916,13652,16358,17111,18582,19360,19563,22101,69434,77033,78968,79106,120169 |

​    The -t is 12 in default, so the output bed file is bed12 format. You can also try the -g or -p option to modify or add columns of output.

### 4.2.2 Processing of standard file format

- gpeMerge.pl

``` bash
gpeMerge.pl -h
```

> Usage: perl gpeMerge.pl input.gpe >output.gpe
>
> ​    If input.gpe not specified, input from STDIN
>
> ​    Output to STDOUT
>
> ​    -b --bin                     Have bin column
>
> ​    -l --locus                   Merge with locus (default: merge gene)
>
> ​    -t --longTranscript  Overlap is against long transcript (default against short transcript)
>
> ​    -n --name                 Set the "gene name" column as "transcript name(s)" when the corresponding gene name unavailable 
>
> ​    -p --percent             Minimal overlap percent to merge tracscript (default: 0)
>
> ​    -h --help                   Print this help information

​    The function of this tool is to merge different transcripts of the same gene (or the same locus if the -l option specified). The merging criterion is: for each site of a gene, if in any transcript the site is located in exon, the site is treated as exonic site in the merged result, otherwise treated as intronic site.

​    A diagram to intuitively illustrate the merging:

![WechatIMG586](D:\我的坚果云\CSTK\WechatIMG586.jpeg)

[^From C(hristina)]: From C(hristina)

​    In the figure, the first and second lines are the two transcripts of the same gene, the third line is the result after merging.

​    Use the example.gpe file in the previous section as input to run this tool:

``` bash
gpeMerge.pl -b example.gpe >merged.gpe
```

​    The content of the output:

|      |                        |       |      |          |          |          |          |      |                                                              |                                                              |      |       |      |      |                                                              |
| ---- | ---------------------- | ----- | ---- | -------- | -------- | -------- | -------- | ---- | ------------------------------------------------------------ | ------------------------------------------------------------ | ---- | ----- | ---- | ---- | ------------------------------------------------------------ |
| 6| NM_015113| chr17 | -| 3907738| 4046253| 3910183| 4046189| 55 | 3907738,3912176,3912897,3916742,3917383,3917640,3919616,3920664,3921129,3922962,3924422,3926002,3928212,3935419,3936121,3937308,3945722,3947517,3953001,3954074,3955264,3957350,3959509,3961287,3962464,3966046,3967654,3969740,3970456,3973977,3975901,3977443,3978390,3978556,3979930,3980161,3981176,3984669,3985730,3988963,3989779,3990727,3991971,3994012,3999124,3999902,4005610,4007926,4008986,4012946,4015902,4017592,4020265,4027200,4045835, | 3910264,3912248,3913051,3916908,3917482,3917809,3919760,3921024,3921265,3923063,3924614,3926122,3928412,3935552,3936296,3937586,3945862,3947668,3953153,3954337,3955430,3957489,3959639,3961449,3962584,3966211,3968123,3969834,3970536,3974218,3976050,3977645,3978472,3978723,3980053,3980283,3981336,3984784,3985798,3989097,3989949,3990828,3992187,3994124,3999273,3999994,4005709,4008105,4009103,4013157,4016102,4017764,4020460,4027345,4046253, | 0| ZZEF1 | cmpl | cmpl | 0,0,2,1,1,0,0,0,2,0,0,0,1,0,2,0,1,0,1,2,1,0,2,2,2,2,1,0,1,0,1,0,2,0,0,1,0,2,0,1,2,0,0,2,0,1,1,2,2,1,2,1,1,0,0, |
| 147| NM_001308237,NM_015534 | chr1| -| 78028100 | 78149112 | 78028100 | 78149112 | 16 | 78028100,78031765,78034016,78041752,78044458,78045211,78046682,78047460,78047663,78050201,78097534,78105133,78107068,78107206,78148269,78148946 | 78031469,78031866,78034151,78041905,78044554,78045313,78046754,78047576,78047811,78050340,78099090,78105287,78107131,78107340,78148343,78149112 | 0| ZZZ3| unk| unk| -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, |

​    As you can see, the two records of the transcripts of the ZZZ3 gene have been merged into one record. The start and end of exons are updated as the coordinates after merging and the other information associated with coordinate is also updated according to the coordinates after merging. The column of transcript name is also updated as comma-separated transcript list.



- gpeFeature.pl

``` bash
gpeFeature.pl -h
```

> Usage: perl gpeFeature.pl OPTION INPUT.gpe >OUTPUT.bed
>
> ​    If INPUT.gpe isn't specified, input from STDIN
>
> Example: perl gpeFeature.pl -b -g hg19.size --upstream 1000 hg19.refGene.gpe >hg19.refGene.bed
>
> Option:
>
> ​    -b --bin                           With bin column
>
> ​    -i --intron                        Fetch introns in each transcript
>
> ​    -e --exon                         Fetch exons in each transcript
>
> ​    -c --cds                            Fetch CDS in each transcript
>
> ​    -u --utr                            Fetch UTRs in each transcript, 5'UTR then 3'UTR (or 3' first)
>
> ​    -p --prime            INT     5 for 5'UTR, 3 for 3'UTR(force -u)
>
> ​         --complete                 Only fetch UTR for completed transcripts
>
> ​         --upstream      INT     Fetch upstream INT intergenic regions(force -g)
>
> ​         --downstream INT     Fetch downstream INT intergenice regions(force -g)
>
> ​    -g  --chrSize           FILE   Tab-separated file with two columns: chr name and its length
>
> ​    -s   --single                       Bundle all features into single line for each transcript
>
> ​          --addIndex                 Add exon/intron/CDS/UTR index as suffix of name in the 4th column
>
> ​    -h  --help                          Print this help information

​    This tool is used to extract specific feature from the gpe file and output in bed format.

​    For example, to extract exons:

``` bash
gpeFeature.pl -b example.gpe -e >exon.bed6+
```

| | | | ||| || |
| ----- | ------- | ------- | --------- | ---- | ---- | --------- | ---- | ----- |
| chr17 | 3907738 | 3910264 | NM_015113 | 0| -| NM_015113 | 2526 | ZZEF1 |
| chr17 | 3912176 | 3912248 | NM_015113 | 0| -| NM_015113 | 72 | ZZEF1 |
| chr17 | 3912897 | 3913051 | NM_015113 | 0| -| NM_015113 | 154| ZZEF1 |

​    More records of the output are omitted. The result is in bed6+ format with each line represent an exon. The last two columns present the exon length and gene name.

### 4.2.3 Table manipulation

- tsvFilter.pl

``` bash
tsvFilter.pl -h
```

> Usage: perl tsvFilter.pl -o originFile.tsv -1 1,4 -m i|include targetFile.tsv >filtered.tsv
>
> ​    If targetFile.tsv isn't specified, input is from STDIN
>
> ​    Output to STDOUT
>
> Option:
>
> ​    -o --originFile      TSV    The original file containing fields (specified by --originFields) used to include or exclude lines in targetFile.tab
>
> ​    -1 --originFields  STR    Comma-separated field list specifying which fileds in the originFile.tab to be used to include or exclude, 1-based start [1]
>
> ​                                            The element of the list can be a single column number or a range with nonnumeric char as separator
>
> ​                                            To specify the last column left the range right margin blank
>
> ​                                            If continuous range specified like '1-3-6', the first range '1-3' will be output
>
> ​                                            e.g.:
>
> ​                                            -1 1,4          output columns 1,4
>
> ​                                            -1 1-4,6..8   output columns 1,2,3,4,6,7,8
>
> ​                                            -1 1,4,6-       output columns 1,4,6,7,... last column
>
> ​                                            -1 1-3-6        output columns 1,2,3
>
> ​    -2 --targetFields   STR   Comma-separated field list specifying which fileds in the targetFile.tab are used to include or exclude lines, 1-based start [1]
>
> ​                                             More description about --targetFields, see --originFields
>
> ​    -m --mode             STR  To include or exclude lines in targetFile.tab, it can be i|include or e|exclude[e]
>
> ​    -s --separator        STR   (Optional)A separator to join the fields specified, if necessary[Empty string]
>
> ​    -h --help                           Print this help information















