#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.matrix >OUTPUT.tsv
    if INPUT.matrix isn't specified, input is from STDIN
Option:
    -h --help           Print this help information screen
HELP
    exit(-1);
}

GetOptions(
            'h|help'    => sub{&usage()}
         )||usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open file ($ARGV[0]): $!";

chomp(my $header = <IN>);
my @colNames = split "\t", $header;
shift @colNames;

while(<IN>){
    chomp;
    my ($rowName, @values) = split "\t";
    for(my $i = 0; $i < @values; $i++){
        say join "\t", ($colNames[$i], $rowName, $values[$i]);
    }
}
