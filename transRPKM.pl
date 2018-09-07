#!/bin/env perl
use 5.010;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::samParser;
use pm::gpeParser;

my ($gpeFile, $bin, $logFile, $uniq);
my ($slop, $libType) = (0, 'fr-unstranded');
GetOptions(
           'g|gpe=s'        => \$gpeFile,
           'b|bin'          => \$bin,
           'l|libType=s'    => \$libType,
           's|slop=i'       => \$slop,
           'u|uniq'         => \$uniq,
           'log=s'          => \$logFile,
           'h|help'         => sub{usage()}
            )||usage();
open GPE, "$gpeFile" or die "Can't open gpe file ($gpeFile): $!";
open LOG, ">$logFile" or die "Can't write to log file ($logFile): $!" if defined $logFile;
if(-f $ARGV[0]){
    if(-B $ARGV[0]){
        open BAM, "samtools view $ARGV[0]|" or die "Cant open $ARGV[0]: $!\n";
    }else{
        die "Please offer the reads in BAM FORMAT\n";
    }
}else{
    die "Please offer the reads\n";
}
`samtools index $ARGV[0]` unless -e "$ARGV[0].bai";

my ($totalProperReads, $totalInputReads) = (0, 0);
my %readName2codingStrand;
while(<BAM>){
    chomp;
    $totalInputReads++;
    say LOG "$totalInputReads reads have been processed" if defined $logFile && $totalInputReads % 1e6 == 0;
    my ($name, $flag) = (split)[0, 1];
    next if defined $uniq && &samParser::getTagValue($_, "NH") != 1;
    my $codingStrand = samParser::determineCodingStrand($libType, $flag);
    $readName2codingStrand{$name} = $codingStrand;
    if(!defined $codingStrand){
        die "Please specify correct library type by --libType\n";
    }elsif($codingStrand eq ''){
        say STDERR "Read ($name) is unmapped or contradictory with specified --libType";
        next;
    }
    $totalProperReads++;
}
die "No any properly-mapped reads\n" if $totalProperReads == 0;
say "#Total input reads=$totalInputReads";
say "#Properly-mapped reads=$totalProperReads";
say join "\t",("#chr", "start", "end", "transID", "RPKM", "strand", "geneID", "readNO", "transLength");

while(<GPE>){
    next if /^#/;
    chomp;
    my @fields = split "\t";
    shift @fields if defined $bin;
    my ($RNA, $chr, $strand, $start, $end, $gene) = @fields[0..4, 11];
    my @exonStarts = split ",", $fields[8];
    my @exonEnds = split ",", $fields[9];
    my $transLen = &gpeParser::getExonsLength(\@exonStarts, \@exonEnds);
    open transReads, "samtools view $ARGV[0] $chr:" . ($start+1) . "-$end |";
    my $reads = 0;
    while(<transReads>){
        chomp;
        my @fields = split "\t";
        my ($name, $flag, $readS, $cigar) = @fields[0, 1, 3, 5];
        my $tags = join "\t", @fields[11..$#fields];
        next if defined $uniq && &samParser::getTagValue($_, "NH") != 1;
        $readS--; # 1-based to 0-based
        my $readE = $readS;
        $readE += $_ for($cigar =~ /(\d+)[MDN=X]/g);
        my $codingStrand = $readName2codingStrand{$name};
        if($codingStrand ne ''){
            $codingStrand = $1 if $codingStrand eq '.' && $tags =~ /XS:A:([+-])/;
            next if $codingStrand ne '.' && $codingStrand ne $strand;
            if( $exonStarts[0] <= $readS && $readE <= $exonEnds[-1]){#read embeded in transcript
                $reads++ if gpeParser::isTransRead($readS, $readE, \@exonStarts, \@exonEnds, $slop) == 1;
            }
        }
    }
    my $RPKM = $reads /($transLen / 1000) / ($totalProperReads / 1e6);
    say join "\t", ($chr, $start, $end, $RNA, $RPKM, $strand, $gene, $reads, $transLen);
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName -g gene_structure.gpe -s 4 INPUT.BAM >RPKM.bed6+ 2>running.log
    If INPUT.BAM isn't specified, input is from STDIN
    INPUT.BAM should be indexed with samtools index
    Output to STDOUT in bed6 (transcript ID in name column, RPKM in score column) plus gene, readNO and transcript length
Option:
    -g --gpe        FILE    A gpe file with comment or track line allowed
    -b --bin                With bin column
    -l --libType    STR     The library type, it can be
                                fr-unstranded: for Standard Illumina (default)
                                fr-firststrand: for dUTP, NSR, NNSR
                                fr-secondstrand: for Ligation, Standard SOLiD and Illumina Directional Protocol
    -s --slop       INT     Specify the slopping length from the exon-intron joint to intron[0]
    -u --uniq               Only use uniquely-mapped reads (NH=1)to compute RPKM
       --log        FILE    Record running log into FILE
    -h --help               Print this help information
HELP
    exit(-1);
}
