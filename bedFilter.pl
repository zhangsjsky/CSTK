#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use List::Util qw[sum];
my ($ratio);

GetOptions(
            'r|ratio=s' => \$ratio,
            'h|help'    => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]:$!";
while(<IN>){
    chomp;
    my @fields = split "\t";
    my ($start, $end, $blockSizes, $blockStarts) = @fields[6, 7, 10, 11];
    my @blockSizes = split ",", $blockSizes;
    my $exonsLen = sum(@blockSizes);
    my $intronsLen = $end - $start - $exonsLen;
    if(defined $ratio){
        next if($intronsLen !=0 && $exonsLen/$intronsLen < $ratio);
    }
    say;
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT
    if INPUT isn't specified, input from STDIN
    output to STDOUT
    
    -r --ratio  INT/DOU Only entry with length(exon)/length(intron)>=DOU passed
    -h --help           Print this help information
HELP
    exit(-1);
}