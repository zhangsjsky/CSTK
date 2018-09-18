#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::samParser;
use pm::gpeParser;

my ($bedFile);
my ($libType) = ('fr-unstranded');
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName -b region.bed INPUT.bam >RPKM.bed 2>running.log
	If INPUT.bam isn't specified, input from STDIN
	Output to STDOUT with bed columns plus reads count in region and its RPKM
Note: INPUT.bam should be indexed with samtools index
      This script is for handling bam file in normal size that can be entirely cached into memory.
      It's MEMORY-CONSUMED but low TIME-CONSUMED compared to its equivalent regionRPKM_mem.pl.
      Splited reads are handled now. Those that include the whole region within intron aren't counted.
Option:
    -b|bedFile  FILE    Region file in bed4 or bed6 format. bed plus is allowed.
    -l|libType  STR	The library type, it can be
			    fr-unstranded: for Standard Illumina (default)
			    fr-firststrand: for dUTP, NSR, NNSR
			    fr-secondstrand: for Ligation, Standard SOLiD and Illumina Directional Protocol	
    -h --help           Print this help information
HELP
    exit(-1);
}

GetOptions(
            'b|bed=s'           => \$bedFile,
            'l|libType=s'	=> \$libType,
            'h|help'            => sub{usage()}
	  ) || usage();

open BED, "$bedFile" or die "Can't open $bedFile: $!";
if(-f $ARGV[0]){
    if(-B $ARGV[0]){
        open regionReads, "samtools view $ARGV[0]|" or die "Cant open $ARGV[0]: $!\n";
    }else{
        die "Please offer the reads in BAM FORMAT\n";
    }
}else{
    die "Please offer the reads\n";
}
`samtools index $ARGV[0]` unless -e "$ARGV[0].bai";

my ($totalReads, $lineCount) = (0, 0);
my %readName2codingStrand;
while(<regionReads>){
    chomp;
    $lineCount++;
    say STDERR "$lineCount reads have been processed" if $lineCount % 1e6 == 0;
    my ($name, $flag) = split;
    my $codingStrand = samParser::determineCodingStrand($libType, $flag);
    if(!defined $codingStrand){
        die "Please specify correct library type by --libType\n";
    }elsif($codingStrand eq ''){
        say STDERR "Read ($name) is unmapped or contradictory with specified --libType";
        next;
    }
    $readName2codingStrand{$name} = $codingStrand;
    $totalReads++;
}
die "No any properly-mapped reads\n" if $totalReads == 0;
say "#Total input reads=$lineCount";
say "#Properly-mapped reads=$totalReads";

while(<BED>){
    chomp;
    my $line = $_;
    my ($chr, $start, $end, $name, $score, $strand) = split "\t";
    $start++;
    open regionReads, "samtools view $ARGV[0] $chr:$start-$end |";
    my $properReads = 0;
    while(<regionReads>){
        chomp;
        my ($name, $flag, $readStart, $cigar) = (split "\t")[0, 1, 3, 5];
	$readStart--;
        my $codingStrand = $readName2codingStrand{$name};
        my ($blockStarts, $blockEnds) = &samParser::cigar2Blocks($readStart, $cigar);
	if($codingStrand ne '.'){
            next if defined $strand && $codingStrand ne $strand;
	}
	next if gpeParser::isEmbeddedInIntron($start, $end, $blockStarts, $blockEnds);
        $properReads++;
    }
    close regionReads;
    my $rpkm = $properReads / (($end - $start + 1)/1e3) / ($totalReads/1e6);
    say join "\t", ($line, $properReads, $rpkm);
}
