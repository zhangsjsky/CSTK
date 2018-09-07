#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::fqParser;

my ($maxAmbiFrac, $ambiBase) = (0.05, 'N');
my ($maxLowQualBaseFrac, $minQual) = (0.5, 20);
my ($trimN, $minLength, $minAveQual, $tail, $output1File, $output2File);
my ($platform) = ('Sanger');

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName --o1 output1.fq[.gz] --o2 output2.fq[.gz] input1.fq[.gz] input2.fq[.gz] 2>report.log
      Statistic report is outputted to STDERR

    Trim filter
        -n|--trimN                          Trim tail N bases
        
    Sequence filter
        -f|--maxAmbiFrac        DOU         The maximal fraction of ambiguous bases in a read for it to be kept[$maxAmbiFrac]
        -b|--ambiBase           CHAR        The ambiguous base[$ambiBase]
        -l|--minLength          INT         The minimal for a read to be kept

    Quality filter
        -q|--maxLowQualBaseFrac DOU         The maximal fraction of low-quality bases in a read for it to be kept[$maxLowQualBaseFrac]
        -c|--minQual            INT         The minimal quality score for a base to be considered as high quality base[$minQual]
        -a|--minAveQual         DOU         The minimal average quality score of bases in a read for it to be kept
        -t|--tail               INT1,INT2   Pair is discarded if any base quality in tail INT1 bases of either read < INT2
                                            E.g.: '2,5' means discarding pair if any base quality of tail 2 bases in either read is less than 5
        -p|--platform           CHAR|STR    The quality scoring platform. It can be
                                                [S|Sanger] (Phred+33, 0~40),
                                                X|Solexa (Solexa+64, -5~40),
                                                I|Illumina1.3+ (Phred+64, 0~40),
                                                J|Illumina1.5+ (Phred+64, 3~40),
                                                L|Illumina1.8+ (Phred+33, 0~41)
    Output files
        -1|--output1            FILE        The fastq file with the filtered 1st read
        -2|--output2            FILE        The fastq file with the filtered 2nd read
        -h|--help                           This help information
HELP
    exit(-1);
}

GetOptions(
            'n|trimN'                   => \$trimN,
            'f|maxAmbiFrac=s'           => \$maxAmbiFrac,
            'b|ambiBase=s'              => \$ambiBase,
            'l|minLength=i'             => \$minLength,
            'q|maxLowQualBaseFrac=s'    => \$maxLowQualBaseFrac,
            'c|minQual=i'               => \$minQual,
            'a|aveQual=s'               => \$minAveQual,
            't|tail=s'                  => \$tail,
            'p|platform=s'              => \$platform,
            'o1=s'                      => \$output1File,
            'o2=s'                      => \$output2File,
            'h|help'                    => sub{usage()}
) || usage();

my ($input1File, $input2File) = @ARGV;

if(`file -L $input1File` =~ /gzip/){
    open IN1, "gzip -dc $input1File |" or die "Can't open $input1File: $!";
}else{
    open IN1, "$input1File" or die "Can't open $input1File: $!";
}
if(`file -L $input2File` =~ /gzip/){
    open IN2, "gzip -dc $input2File |" or die "Can't open $input2File: $!";
}else{
    open IN2, "$input2File" or die "Can't open $input2File: $!";
}
if($output1File =~ /\.gz$/){
    open OUT1, "| gzip >$output1File" or die "Can't write $output1File: $!";
}else{
    open OUT1, ">$output1File" or die "Can't write $output1File: $!";
}
if($output2File =~ /\.gz$/){
    open OUT2, "| gzip >$output2File" or die "Can't write $output2File: $!";
}else{
    open OUT2, ">$output2File" or die "Can't write $output2File: $!";
}

my $read1Name;
my ($passedPeN, $badTailN, $totalPeN) = (0, 0, 0);

while($read1Name = <IN1>){
    chomp(my $seq1 = <IN1>);
    my $plus1 = <IN1>;
    chomp(my $qualSeq1 = <IN1>);
    my $read2Name = <IN2>;
    chomp(my $seq2 = <IN2>);
    my $plus2 = <IN2>;
    chomp(my $qualSeq2 = <IN2>);
    $totalPeN++;
    if(defined $trimN){
        if($seq1 =~ s/^(N+)//){
            $qualSeq1 = substr $qualSeq1, length $1;
        }
        if($seq1 =~ s/(N+)$//){
            $qualSeq1 = substr $qualSeq1, 0, (length $qualSeq1 - length $1);
        }
        if($seq2 =~ s/^(N+)//){
            $qualSeq2 = substr $qualSeq2, length $1;
        }
        if($seq2 =~ s/(N+)$//){
            $qualSeq2 = substr $qualSeq2, 0, (length $qualSeq2 - length $1);
        }
    }
    if(defined $tail){
        if( &fqParser::isBadTail($tail, $qualSeq1, $platform) ||
            &fqParser::isBadTail($tail, $qualSeq2, $platform)){
               $badTailN++;
               next
       }
    }
    if(defined $minLength){
        next if length $seq1 < $minLength || length $seq2 < $minLength;
    }
    if($maxAmbiFrac > 0){
        next if &fqParser::getBaseFraction($seq1, $ambiBase) > $maxAmbiFrac ||
                &fqParser::getBaseFraction($seq2, $ambiBase) > $maxAmbiFrac;
    }
    if($minQual > 0 && $maxLowQualBaseFrac < 1){
        next if( &fqParser::getLowQualBaseFraction($qualSeq1, $platform, $minQual) > $maxLowQualBaseFrac ||
                 &fqParser::getLowQualBaseFraction($qualSeq2, $platform, $minQual) > $maxLowQualBaseFrac)
    }
    if(defined $minAveQual){
        next if ( &fqParser::countAveQual($qualSeq1, $platform) < $minAveQual ||
                  &fqParser::countAveQual($qualSeq2, $platform) < $minAveQual)
    }
    print OUT1 $read1Name;
    say OUT1 $seq1;
    print OUT1 $plus1;
    say OUT1 $qualSeq1;
    print OUT2 $read2Name;
    say OUT2 $seq2;
    print OUT2 $plus2;
    say OUT2 $qualSeq2;
    $passedPeN++;
}
say STDERR join "\t", ("Total pairs", $totalPeN, "100");
say STDERR join "\t", ("Passed pairs", $passedPeN, sprintf "%.2f", $passedPeN/$totalPeN*100);
say STDERR join "\t", ("Bad tail pairs", $badTailN, sprintf "%.2f", $badTailN/$totalPeN*100) if defined $tail;
