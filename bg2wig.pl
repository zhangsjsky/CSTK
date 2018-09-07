#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;

my $variable;
GetOptions(
            'v|variable'    => \$variable,
            'h|help'        => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";

my $chrPos = '';
while(<IN>){
    next if /^#/;
    chomp;
    my ($chr, $start, $end, $score) = split "\t";
    if(defined $variable){
        
    }else{
        $start++;
        say "fixedStep chrom=$chr start=$start step=1" if "$chr:$start" ne $chrPos;
        say $score for $start..$end;
        $chrPos = "$chr:" . ++$end;
    }
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    If INPUT isn't specified, input from STDIN
Option:
    -v --variable   Variable step wig
    -h --help       Print this help information
HELP
    exit(-1);
}