#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.010;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my ($inputTsv);

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName input.readcount >variant.tsv
    If input.readcount isn't specified, input is from STDIN
    Output to STDOUT
Option:
    -h --help               Print this help information
HELP
    exit(-1);
}

GetOptions(
            'h|help'            => sub{&usage()}
         )||usage();

$ARGV[0]='-' unless defined $ARGV[0];
open TSV,"$ARGV[0]" or die "Can't open $ARGV[0]:$!";

while(<TSV>){
    chomp;
    my ($chr, $pos, $ref, $totalDepth, undef, @fields) = split "\t";
    $ref = uc $ref;
    my $refDepth;
    for my $value (@fields){
        my ($base, $depth) = split ":", $value;
        if($base eq "$ref"){
            $refDepth = $depth;
            last;
        }
    }
    for my $value (@fields){
        my ($base, $depth) = split ":", $value;
        if($base ne $ref){
            if($base =~ /^\+/){
                say join "\t", ($chr, $pos, "-", substr($base,1), $totalDepth, $refDepth, $depth);
            }elsif($base =~ /^-/){
                say join "\t", ($chr, $pos, $ref, "-", $totalDepth, $refDepth, $depth);
            }else{
                say join "\t", ($chr, $pos, $ref, $base, $totalDepth, $refDepth, $depth);
            }
        }
    }
}
