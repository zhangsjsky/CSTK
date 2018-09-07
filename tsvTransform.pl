#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;


my ($add, $multiply, $divide, $log);
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.tsv >OUTPUT.tsv
    If INPUT.tsv isn't specified, input from STDIN
Option:
    -a --add       DOU  Add value
    -m --multiply  DOU  Multiply value
    -d --divide    DOU  Divide value
    -l --log       DOU  INT-based log transform
    -h --help           Print this help information
HELP
    exit(-1);
}

GetOptions(
            'a|add=s'       => \$add,
            'm|multiply=s'  => \$multiply,
            'd|divide=s'    => \$divide,
            'l|log=s'       => \$log,
            'h|help'        => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

while(<IN>){
    chomp;
    my @values = split "\t";
    my @transformedValues;
    for my $value(@values){
        if(defined $log){
            $value = log($value)/log($log);
        }
        if(defined $multiply){
            $value *= $multiply;
        }
        if(defined $divide){
            $value /= $divide;
        }
        if(defined $add){
            $value += $add;
        }
        push @transformedValues, $value;
    }
    say join "\t", @transformedValues;
}

