#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;

GetOptions(
            'h|help' => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
while(<IN>){
    chomp;
    my @fields = split "\t";
    print join "\t", (@fields[0..5], @fields[1, 2], '0,0,0', 1, $fields[2] - $fields[1], 0);
    if(@fields > 6){
        print "\t";
        say join "\t", (@fields[6..$#fields]);
    }else{
        print "\n";
    }
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.bed6 >OUTPUT.bed12
    If INPUT isn't specified, input from STDIN
Option:
    -h --help       Print this help information
HELP
    exit(-1);
}