#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.010;
use warnings;
use strict;
use Getopt::Long;
use File::Basename;

my ($minTLOD, $minNLOD, $minFT, $maxFN, $minFR, $cosmic);

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName muTect2.vcf >flt.vcf 2>discarded.vcf
    If muTect2.vcf isn't specified, input from STDIN
Option:
        --minTLOD   DOU     The min TLOD
        --minNLOD   DOU     The min NLOD
        --minFT     [0,1]   The min variation frequency in tumor
        --maxFN     [0,1]   The max variation frequency in normal
        --minFR     [0,1]   The min ratio of FT/FN
        --cosmic            Be cosmic variation
    -h  --help              Print this help information
HELP
}

GetOptions(
            'minTLOD=s' => \$minTLOD,
            'minNLOD=s' => \$minNLOD,
            'minFT=s'   => \$minFT,
            'maxFN=s'   => \$maxFN,
            'minFR=s'   => \$minFR,
            'cosmic'    => \$cosmic,
            'h|help'    => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
while(<IN>){
    chomp;
    if(/^#/){
        say;
        say STDERR;
        next;
    }
    my @fields = split "\t";
    my ($info, $tumorFormat, $normalFormat) = @fields[7, 9, 10];
    my @info = split ";", $info;
    my %info;
    for my $info(@info){
        my ($key, $value) = split "=", $info;
        $value = '' unless defined $value;
        $info{$key} = $value;
    }
    
    if(defined $minTLOD && $info{TLOD} >= $minTLOD){
        say;
        next;
    }
    
    if(defined $minNLOD && $info{NLOD} >= $minNLOD){
        say;
        next;
    }
    
    if(defined $cosmic && ($info{cosmic70} ne '.' || $info{vcf} ne '.')){
        say;
        next;
    }
    
    if(defined $minFT){
        my $tumorFreq = (split ':', $tumorFormat)[2];
        if($tumorFreq >= $minFT){
            say;
            next;
        }
    }
    
    if(defined $maxFN){
        my $normalFreq = (split ':', $normalFormat)[2];
        if($normalFreq <= $maxFN){
            say;
            next;
        }
    }
    
    if(defined $minFR){
        my $tumorFreq = (split ':', $tumorFormat)[2];
        my $normalFreq = (split ':', $normalFormat)[2];
        if($normalFreq == 0 || $tumorFreq/$normalFreq >= $minFR){
            say;
            next;
        }
    }
    
    say STDERR;
}
