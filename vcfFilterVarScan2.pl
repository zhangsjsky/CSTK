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

my ($maxSP, $maxFN, $minFR,$cosmic);

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName multianno.vcf >flt.vcf
    If multianno.vcf isn't specified, input from STDIN
Option:
        --maxSP     DOU     The max somatic p-value
        --maxFN     0-100   The max variation frequency (%) in normal
        --minFR     [0,1]   The min ratio of FT/FN
        --cosmic            Be cosmic variation
    -h  --help              Print this help information
HELP
}

GetOptions(
            'maxSP=s'   => \$maxSP,
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
    my ($info, $normalFormat, $tumorFormat) = @fields[7, 9, 10];
    my @info = split ";", $info;
    my %info;
    for my $info(@info){
        my ($key, $value) = split "=", $info;
        $value = '' unless defined $value;
        $info{$key} = $value;
    }
    
    if(defined $maxSP && $info{SPV} <= $maxSP){
        say;
        next;
    }
    
    if(defined $cosmic && ($info{cosmic70} ne '.' || $info{vcf} ne '.')){
        say;
        next;
    }
    
    if(defined $maxFN){
        my $normalFreq = (split ':', $normalFormat)[5];
        $normalFreq =~ s/%//;
        if($normalFreq <= $maxFN){
            say;
            next;
        }
    }
    
    if(defined $minFR){
        my $tumorFreq = (split ':', $tumorFormat)[5];
        $tumorFreq =~ s/%//;
        my $normalFreq = (split ':', $normalFormat)[5];
        $normalFreq =~ s/%//;
        if($normalFreq == 0 || $tumorFreq/$normalFreq >= $minFR){
            say;
            next;
        }
    }
    
    say STDERR;
}
