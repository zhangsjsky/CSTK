#!/bin/env perl
use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::bgParser;

my $inter;
GetOptions(
            'i|inter'   => \$inter,
            'h|help'    => sub{usage()}
        )||usage();
$ARGV[0] = '-' unless defined $ARGV[0];
&bedgraphParser::outputBedGraph(&bedgraphParser::pileUp(@ARGV), $inter);
say STDERR "Finish all output";
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName input1.bg [input2.bg [input3.bg]...] >OUTPUT.bg 2>running.log
    If input1.bg isn't specified, input from STDIN
    Output to STDOUT
Option:
    -i --inter      Whether to output intermediate region that hasn't score value in all input bg files
                    Score of these regions will be assigned as -1
    -h --help       Print this help information
HELP
    exit(-1);
}