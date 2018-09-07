#!/bin/env perl


use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::samParser;

my ($chimeric, $strand, $maxInsertSize, $pairMapped);
my $libType = 'fr-firststrand';
GetOptions(
            'c|chimeric'        => \$chimeric,
            's|strand=s'        => \$strand,
            'l|libraryType=s'   => \$libType,
            'i|maxInsertSize=i' => \$maxInsertSize,
            'p|pairMapped'      => \$pairMapped,
            'h|help'            => sub{&usage()}
        )||usage();

if(defined $ARGV[0]){
    if (-B $ARGV[0]){
        open IN, "samtools view -h $ARGV[0] |" or die "Can't open $ARGV[0]: $!";
    }else{
        open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
    }
}else{
    open IN, "-";
}

die "Please specify the correct strand ('+' or '-') by -s or --strand.\n" if defined $strand && $strand ne '+' && $strand ne '-';

my (%total, %unmapped, %passed);
while(<IN>){
    chomp;
    if (/^@/){
        say;
        next;
    }
    
    my ($name, $flag, $mateRef, $insSize) = (split "\t")[0, 1, 6, 8];
    my $whichEnd = &samParser::isFirstMate($flag) == 1 ? 1 : 2;
    $total{"$name/$whichEnd"} = '';
    
    if(&samParser::isUnmapped($flag) == 0){ #current end mapped
        if(&samParser::isMateUnmapped($flag) == 0){ # current and mate both mapped
            next if defined $chimeric && $mateRef ne '='; #whether map to the same reference
            next if defined $strand && &samParser::determineCodingStrand($libType, $flag) ne $strand;
            next if defined $maxInsertSize && abs($insSize) > $maxInsertSize;
        }else{ #current end mapped but mate unmapped
            next if defined $pairMapped;
        }
    }else{ #current end unmapped
        $unmapped{"$name/$whichEnd"} = '';
        next;
    }
    
    say $_;
    $passed{"$name/$whichEnd"} = '';
}

my $totalN = scalar keys %total;
say STDERR "Total reads = $totalN";
my $passedN = scalar keys %passed;
say STDERR "Passed reads = $passedN (" . (sprintf "%.2f", $passedN/$totalN*100) . "%)";
say STDERR "Unmapped reads in the input = " . scalar keys %unmapped;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.sam/bam >OUTPUT.sam 2>report.txt
    If INPUT.sam not specified, input from STDIN
    Passed pairs are output to STDOUT, unmapped reads are discarded
    Summary information is output to STDERR

    -p --pairMapped             Only keep pair whose ends are both mapped
    -i --maxInsertSize  INT     The maximal outer insert size for pair
    -c --chimeric               Discard pair with ends mapped to different references
    -s --strand         CHAR    For strand-specific reads, only keep the reads from the CHAR (+ or -) strand
                                Library must be specified by -l
    -l --libraryType    STR     The strand-specific library type, it can be
                                    fr-firststrand: for dUTP, NSR, NNSR (default)
                                    fr-secondstrand: for Ligation, Standard SOLiD and Illumina Directional Protocol
    -h --help                   Print this help information
HELP
    exit(-1);
}