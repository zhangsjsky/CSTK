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
use lib dirname $0;
use pm::common;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName OPTION fastqc_data.txt >OUTPUT.tsv
    If fastqc_data.txt isn't specified, input from STDIN
Option:

    -h  --help                      Print this help information
HELP
}

GetOptions(

            'h|help'                => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

my $line = <IN>;

my ($totalSeq, $seqLength, $gcContent, $meanQual);
while(defined $line){
    chomp $line;
    if($line =~ /^Total Sequence\s+(\d+)$/){
        $totalSeq = $1;
        $line = <IN>;
        next;
    }
    if($line =~ /^Sequence length\s+(\d+)$/){
        $seqLength = $1;
        $line = <IN>;
        next;
    }
    if($line =~ /^%GC\s+(\d+)$/){
        $gcContent = $1;    
        $line = <IN>;
        next;
    }
    if($line =~ /^>>Per base sequence quality/){
        if($seqLength -~ /-/){
            $meanQual = "Not available when read lengths aren't uniform";
        }else{
            <IN>;
            my $totalQual = 0;
            while($line = <IN>){
                last if $line eq '>>END_MODULE';
                my ($pos, $mean) = split "\t", $line;
                my ($from, $to) = split '-', $pos;
                if(defined $to){
                    $totalQual += ($to-$from+1) * $mean;
                }else{
                    $totalQual += $mean;
                }
            }
            $meanQual = $totalQual / $seqLength;
        }
    }
    $line = <IN>;
}
say join "\t", ("Reads", $totalSeq);
say join "\t", ("Read Length", $seqLength);
say join "\t", ("GC Content", $gcContent);
say join "\t", ("Mean Quality", $meanQual);
