#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

my ($help);
GetOptions(

            'h|help' => \$help
        ) || usage();
usage() if defined $help;
$ARGV[0] = '-' unless defined $ARGV[0];
open HIST, "$ARGV[0]" or die "Can't open $ARGV[0]:$!";
my %depthH;
while(<HIST>){
    chomp;
    my @fields = split "\t";
    my ($depth, $baseN) = @fields[3, 4];
    $depthH{$depth} += $baseN;
}
for my $depth (sort {$a <=> $b} keys %depthH){
    say join "\t", ($depth, $depthH{$depth});
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName bedtoolHist.tsv >depth.tsv
    If INPUT isn't specified, input from STDIN. It's the output of 'bedtool coverage -hist' in bed format    
    Output to STDOUT

    -h --help       Print this help information
HELP
    exit(-1);
}
