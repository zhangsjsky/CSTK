#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

my $zero;
GetOptions(
            'z|zero'    => \$zero,
            'h|help'    => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";

my $line = <IN>;
$line = <IN> if $line =~ /track/;
$line =~ /chrom=(\S+)/;
my $chr = $1;
chomp($line = <IN>);
my ($start, $score) = split "\t", $line;
my $end = $start;
$start--;
say join "\t", ($chr, 0, $start, 0) if defined $zero && $start != 0;

while($line = <IN>){
    next if $line =~ /^track/;
    chomp $line;
    if($line =~ /chrom=(\S+)/){
        say join "\t", ($chr, $start, $end, $score);
        $chr = $1;
        chomp($line = <IN>);
        ($start, $score) = split "\t", $line;
        $end = $start;
        $start--;
    }else{
        my @fields = split "\t", $line;
        if($fields[0] == $end + 1){
            if($fields[1] == $score){
                $end = $fields[0];
            }else{
                say join "\t", ($chr, $start, $end, $score);
                $start = $fields[0] -1;
                $end = $fields[0];
                $score = $fields[1];
            }
        }else{
            say join "\t", ($chr, $start, $end, $score);
            say join "\t", ($chr, $end, $fields[0] - 1, 0) if $zero;
            $start = $fields[0] - 1;
            $score = $fields[1];
            $end = $fields[0];
        }
    }
}
say join "\t", ($chr, $start, $end, $score);

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    If INPUT isn't specified, input from STDIN
Option:
    -z --zero   Whether to give region with score=0
    -h --help   Print this help information
HELP
    exit(-1);
}