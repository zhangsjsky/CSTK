#!/bin/env perl
use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::samParser;
my ($unmapped, $maxBestHitsN, $diff, $nm, $color);
GetOptions(
            'u|unmapped'        => \$unmapped,
            'b|bestHitsN=i'     => \$maxBestHitsN,
            'd|diff=i'          => \$diff,
            'n|nm=i'            => \$nm,
            'c|color'           => \$color,
            'h|help'            => sub{&usage()}
        )||usage();

if(defined $ARGV[0]){
    if (-B $ARGV[0]){
        open SAM, "samtools view -h $ARGV[0]|" or die "Can't open $ARGV[0]: $!";
    }else{
        open SAM, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
    }
}else{
    open SAM, "-";
}

my ($totalN, $unmappedN, $passedN) = (0, 0, 0);
while(<SAM>){
    chomp;
    if (/^@/){
        say;
        next;
    }
    $totalN++;
    my @fields = split "\t";
    if(&samParser::isUnmapped($fields[1]) == 0){
        my $bestHitsN = &samParser::getBestHitsN($_);
        next unless defined $bestHitsN;
        next if defined $maxBestHitsN && &samParser::getBestHitsN($_) > $maxBestHitsN;
        if(defined $diff && $bestHitsN == 1 && &samParser::getSubHitsN($_) > 0){
            my $altHitsMinNM = &samParser::getAltHitsMinNM($_);
            next unless defined $altHitsMinNM;
            if(defined $color){
                next if /CM:i:(\d+)/ && $altHitsMinNM - $1 < $diff;
            }else{
                next if /NM:i:(\d+)/ && $altHitsMinNM - $1 < $diff;
            }
        }
        next if defined $nm && /NM:i:(\d+)/ && $1 > $nm;
    }else{ #read is unmapped
        $unmappedN++;
        next unless defined $unmapped;
    }
    say $_;
    $passedN++;
}
say STDERR "Total reads = $totalN";
say STDERR "Passed reads = $passedN (" . (sprintf "%.2f", $passedN/$totalN*100) . "%)";
say STDERR "Unmapped reads = $unmappedN";

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.sam/bam >OUTPUT.sam
    If INPUT.sam not specified, input from STDIN
    Passed reads are output to STDOUT, unmapped reads are discarded
    Summary information is output to STDERR
Option:    
    -u --unmapped           Return unmapped reads
    
  BWA-specific:
    -b --maxBestHits  INT   Only return reads with X0 <= INT. 1 is recommended.
    -d --diff         INT   Only return reads with min(XA) - NM >= INT, when X0=1, where min(XA) is the minimal NM in the alternative hits
    -n --nm           INT   Only return reads with NM <= INT
    -c --color              Color space reads
    
    -h --help               Print this help information
HELP
    exit(-1);
}