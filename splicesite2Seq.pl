#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.splicesite >OUTPUT.fa
    If INPUT isn't specified, input from STDIN
Option:
    -f  --fa         FILE   Fasta file with fai index
    -e  --exonDist   INT    Retrieve INT bases in direction to exon[0]
    -i  --intronDist INT    Retrieve INT bases in direction to intron[2]
    -c  --case              Keep case sensitive
        --no5               Don't fetch 5 prime
        --no3               Don't fetch 3 prime
    -h --help               Print this help information
HELP
    exit(-1);
}

my ($faFile, $case);
my ($exonDistance, $intronDistance, $no5Prime, $no3Prime) = (0, 2);
GetOptions(
            'f|fa=s'            => \$faFile,
            'e|exonDist=i'      => \$exonDistance,
            'i|intronDist=i'    => \$intronDistance,
            'c|case'            => \$case,
            'no5'               => \$no5Prime,
            'no3'               => \$no3Prime,
            'h|help'            => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
while(<IN>){
    chomp;
    my ($chr, $leftSite, $rightSite, $strand) = split "\t";
    my ($seqUpstream, $seqDnstream) = ('', '');
    if($strand eq '+'){
        unless(defined $no5Prime){
            open FA, "samtools faidx $faFile $chr:" . ($leftSite+1-$exonDistance) . "-" . ($leftSite+$intronDistance) . "|";
            <FA>;
            $seqUpstream = <FA>;
            chomp $seqUpstream;
        }
        unless(defined $no3Prime){
            open FA, "samtools faidx $faFile $chr:" . ($rightSite-$intronDistance+1) . "-" . ($rightSite+$exonDistance) ."|";
            <FA>;
            $seqDnstream = <FA>;
            chomp $seqDnstream;
        }
    }else{
        unless(defined $no5Prime){
            open FA, "samtools faidx $faFile $chr:" . ($rightSite-$intronDistance+1) . "-" . ($rightSite+$exonDistance) ."|";
            <FA>;
            $seqUpstream = <FA>;
            chomp $seqUpstream;
            $seqUpstream = &rc($seqUpstream);
        }
        unless(defined $no3Prime){
            open FA, "samtools faidx $faFile $chr:" . ($leftSite+1-$exonDistance) . "-" . ($leftSite+$intronDistance) . "|";
            <FA>;
            $seqDnstream = <FA>;
            chomp $seqDnstream;
            $seqDnstream = &rc($seqDnstream);
        }
    }

    my $seq = '';
    if(!defined $no5Prime && !defined $no3Prime){
        $seq = "$seqUpstream-$seqDnstream";
    }else{
        $seq = "$seqUpstream$seqDnstream";
    }
    $seq = uc $seq unless $case;
    say join "\t", ($_, $seq);
}

sub rc{
    my ($seq) = @_;
    $seq =~ tr/[ATCGatcg]/[TAGCtagc]/;
    $seq  = join "", (reverse (split "", $seq));
    return $seq;
}
