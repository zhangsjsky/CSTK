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

my ($snpVer, $cosmicVer, $_1000GVer, $maxFreqIn1000G) = ('avsnp147', 'cosmic70', 'ALL.sites.2015_08', 0.01);
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.vcf >pass.vcf 2>discarded.vcf
    If INPUT.vcf isn't specified, input from STDIN
Option:
    -s  --snpVer            STR The dbSNP version[$snpVer]
    -c  --cosmicVer         STR The COSMIC version[$cosmicVer]
    -g  --1000GVer          STR The 1000 Genome version[$_1000GVer]
    -x  --maxFreqIn1000G    DOU The max frequency in 1000G[$maxFreqIn1000G]
    -h  --help                  Print this help information
Note: Any of the filter criteria defined in input and met, the record will be passed.
HELP
}

GetOptions(
            's|snpVer=s'            => \$snpVer,
            'c|cosmicVer=s'         => \$cosmicVer,
            'g|1000GVer=s'          => \$_1000GVer,
            'x|maxFreqIn1000G=s'    => \$maxFreqIn1000G,
            'h|help'                => sub{usage(); exit}
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
    my $INFOs = $fields[7];
    my @INFOs = split ';', $INFOs;
    my %INFOs;
    for my $INFO(@INFOs){
        my ($key, $value) = split '=', $INFO;
        $INFOs{$key} = $value;
    }
    if(exists $INFOs{$snpVer} && $INFOs{$snpVer} eq '.' ||
       exists $INFOs{$cosmicVer} && $INFOs{$cosmicVer} ne '.' ||
       exists $INFOs{$_1000GVer} && ($INFOs{$_1000GVer} eq '.' || $INFOs{$_1000GVer} <= $maxFreqIn1000G)
    ){
        say;
    }else{
        say STDERR;
    }
}

