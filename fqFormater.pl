#!/bin/env perl
=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib (fileparse($0))[1];
use pm::common;
my ($tab, $fastq, $keyword, $piece);
my ($width)=(100);

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName -t INPUT.fq(.gz) >OUTPUT.tsv
       perl $scriptName -f INPUT.tsv >OUTPUT.fq
    if INPUT not specified, input from STDIN

    -t --tab            Transform the fasta format to tab format (name, title, seq in each column)
    -f --fastq          Transform the tab format to fastq format
    -k --keyword    STR Extract sequence with title containing --keyword
    -p --piece      STR Extract sequence with --piece as sub-sequence
    -h --help           Print this help information
HELP
    exit(-1);
}

GetOptions(
            't|tab'         => \$tab,
            'f|fastq'       => \$fastq,
            'k|keyword=s'   => \$keyword,
            'p|piece=s'     => \$piece,
            'h|help'        => sub{\&usage()}
        )||usage();

if(defined $ARGV[0]){
    if(`file -L $ARGV[0]` =~ /gzip/){
        open IN,"gzip -dc $ARGV[0]|" or die "Can't open $ARGV[0]: $!";
    }else{
        open IN,"$ARGV[0]" or die "Can't open $ARGV[0]: $!";
    }
}else{
    open IN, "-";
}

if(defined $tab){
    while(<IN>){
        chomp;
        my $title = $_;
        chomp(my $seq = <IN>);
        <IN>;
        chomp(my $qual = <IN>);
        if (defined $keyword && $title !~ /$keyword/ || defined $piece && $seq !~ /$piece/){
            next;
        }
        my $name = $title;
        $name =~ s/^@//;
        say join "\t",($name, $title, $seq, $qual);
    }
}
if(defined $fastq){
    while(<IN>){
        chomp;
        my ($name, $title, $seq, $qual) = split "\t";
        if (defined $keyword && $title !~ /$keyword/ || defined $piece && $seq !~ /$piece/){
            next;
        }
        say $title;
        say $seq;
        say "+";
        say $qual;
    }
}
