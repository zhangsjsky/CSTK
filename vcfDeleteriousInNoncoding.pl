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

my $type;
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName input.vcf >deleterious.vcf 2>benign.vcf
    If input.vcf isn't specified, input from STDIN
Option:
    -h  --help      Print this help information
HELP
}

GetOptions(
            'h|help'    => sub{usage(); exit}
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
    my $info = $fields[7];
    my @info = split ";", $info;
    for my $info(@info){
        my ($key, $value) = split "=", $info;
        if($key eq "CADD_phred"){
            if($value ne '.' && $value < 10){
                say STDERR;
            }else{
                say;
            }
            next RECORD;
        }
    }
    die "No CADD annotation in input VCF\n";
}
