#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

GetOptions(
            'h|help' => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
my $line = <IN>;
chomp $line;
my ($chr, $start, $dep) = split "\t", $line;
my $end = $start;
$start--;
if($start != 0){
    say join "\t", ($chr, 0, $start, 0);
}
while($line = <IN>){
    last unless defined $line;
    chomp $line;
    my @fields = split "\t", $line;
    if($fields[0] eq $chr){
        if($fields[1] == $end + 1){
            if($fields[2] == $dep){
                $end = $fields[1];    
            }else{
                say join "\t", ($chr, $start, $fields[1] -1, $dep);
                $start = $fields[1] - 1;
                $dep = $fields[2];
                $end = $fields[1]; 
            }
        }else{
            say join "\t", ($chr, $start, $end, $dep);
            say join "\t", ($chr, $end, $fields[1] - 1, 0);
            $start = $fields[1] - 1;
            $dep = $fields[2];
            $end = $fields[1]; 
        }
        
    }else{
        say join "\t", ($chr, $start, $end, $dep);
        $chr  = $fields[0];
        $start = $fields[1] -1;
        $dep = $fields[2];
        $end = $fields[1];
        if($start != 0){
            say join "\t", ($chr, 0, $start, 0);
        }
    }
}
say join "\t", ($chr, $start, $end, $dep);

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    If INPUT isn't specified, input from STDIN
Option:
    -h --help       Print this help information
HELP
    exit(-1);
}