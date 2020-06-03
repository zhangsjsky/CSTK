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

my ($fMinDP, $fMinAltDepth, $fMaxAltDepth);
my $indexes = 1;
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName multianno.vcf >flt.vcf
    If multianno.vcf isn't specified, input from STDIN
Option:
  FORMAT
        --fMinDP            INT     The minimal FORMAT/DP for a record to be kept.
        --fMinAltDepth      INT     The minimal alt allele depth (according to FORMAT/TIR)
        --fMaxAltDepth      INT     The maximal alt allele depth (according to FORMAT/TIR)
    -i  --sampleIndex       INTs    The comma-separated index numbers (1-start) of samples to be applied with FORMAT-related filter[1]
    -h  --help              Print this help information
HELP
}

GetOptions(
            'fMinDP=i'          => \$fMinDP,
            'fMinAltDepth=i'    => \$fMinAltDepth,
            'fMaxAltDepth=i'    => \$fMaxAltDepth,
            'i|sampleIndex=s'   => \$indexes,
            'h|help'            => sub{usage(); exit}
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
    my @indexes = split ',', $indexes;
    for my $index(@indexes){
        my @keys = split ':', $fields[8];
        my @values = split ':', $fields[8+$index];
        my %FORMATs;
        $FORMATs{$keys[$_]} = $values[$_] for (0..$#keys);
        
        if(defined $fMinDP && $FORMATs{DP} >= $fMinDP){
            say;
            next RECORD;
        }
        
        if(defined $fMinAltDepth){
            my $altDepth = (split ',', $FORMATs{TIR})[0];
            if($altDepth >= $fMinAltDepth){
                say;
                next RECORD;
            }
        }
        
        if(defined $fMaxAltDepth){
            my $altDepth = (split ',', $FORMATs{TIR})[0];
            if($altDepth <= $fMaxAltDepth){
                say;
                next RECORD;
            }
        }
    }
    say STDERR;
}
