#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.tsv >OUTPUT.tsv
    If INPUT isn't specified, input from STDIN
Option:
    -h --help       Print this help information
HELP
    exit(-1);
}

GetOptions(
            'h|help' => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

my @titles;
my $line;
while($line = <IN>){
    chomp $line;
    last unless $line =~ /^#/;
    $line =~ s/^#//;
    @titles = split "\t", $line;
}

if((join '', @titles) eq ''){
    @titles = map{"Col$_"}1..1000; # assume 1000 columns
}

my $lineN = 1;
while(defined $line){
    chomp $line;
    my @fields = split "\t", $line;
    for(my $i = 0; $i <= $#fields; $i++){
        say "$titles[$i]: $fields[$i]";
    }
    say "EOF Line $lineN" . ('=' x 80);
    $line = <IN>;
    $lineN++;
}

