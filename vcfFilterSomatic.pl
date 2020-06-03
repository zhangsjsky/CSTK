#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.010;
use warnings;
use strict;
use Getopt::Long;
use File::Basename;

my ($_1000gAll, $_1000gEas, $ExAcAll, $ExAcEas, $annovarCosmic, $latestCosmic) = ('ALL.sites.2015_08', 'EAS.sites.2015_08', 'ExAC_ALL', 'ExAC_EAS', 'cosmic70');
my $maxFreq = 0.01;
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName input.vcf >flt.vcf 2>discarded.vcf
    If input.vcf isn't specified, input from STDIN
Option:
  INFO
        --1000gAll      STR INFO tag name of 1000G All site[$_1000gAll]
        --1000gEas      STR INFO tag name of 1000G EAS site[$_1000gEas]
        --ExAcAll       STR INFO tag name of ExAc All site[$ExAcAll]
        --ExAcEas       STR INFO tag name of ExAc EAS site[$ExAcEas]
        --annovarCosmic STR INFO tag name of cosmic v70[annovarCosmic]
        --latestCosmic  STR INFO tag name of the latest cosmic version
        --maxFrequency  DOU The max frequency for a mutation considered as rare in population[$maxFreq]
HELP
}

GetOptions(
            '1000gAll=s'      => \$_1000gAll,
            '1000gEas=s'      => \$_1000gEas,
            'ExAcAll=s'       => \$ExAcAll,
            'ExAcEas=s'       => \$ExAcEas,
            'annovarCosmic=s' => \$annovarCosmic,
            'latestCosmic=s'  => \$latestCosmic,
            'maxFrequency=s'  => \$maxFreq,
            'h|help'          => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

RECORD:
while(<IN>){
    chomp;
    if(/^#/){
        say;
        say STDERR;
        next;
    }
    
    my @fields = split "\t";
    my $INFOs = $fields[7];
    my @INFOs = split ';', $INFOs;
    my %INFOs;
    for my $INFO(@INFOs){
        my ($key, $value) = split '=', $INFO;
        $INFOs{$key} = $value;
    }
    
    if( ( (!exists $INFOs{$_1000gAll} || $INFOs{$_1000gAll} eq '.' || $INFOs{$_1000gAll} <= $maxFreq)
          && (!exists $INFOs{$_1000gEas} || $INFOs{$_1000gEas} eq '.' || $INFOs{$_1000gEas} <= $maxFreq)
          && (!exists $INFOs{$ExAcAll} || $INFOs{$ExAcAll} eq '.' || $INFOs{$ExAcAll} <= $maxFreq)
          && (!exists $INFOs{$ExAcEas} || $INFOs{$ExAcEas} eq '.' || $INFOs{$ExAcEas} <= $maxFreq)
        )
        || (exists $INFOs{$annovarCosmic} && $INFOs{$annovarCosmic} ne '.')
        || (defined $latestCosmic && exists $INFOs{$latestCosmic} && $INFOs{$latestCosmic} ne '.')
    ){
        say;
    }else{
        say STDERR;
    }
}
