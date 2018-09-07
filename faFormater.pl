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
my ($tab, $ncbi, $noVersion, $fasta, $keyword, $piece);
my ($width)=(100);

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    if INPUT not specified, input from STDIN
    output from STDOUT

    -t --tab            Transform the fasta format to tab format (name, title, seq in each column)
    -n --ncbi           When --tab specified, set name as the RefSeq ID when title is ncbi style
    -v --noVersion      Remove version number of RefSeq ID if --ncbi specified
    -f --fasta          Transform the tab format to fasta format
    -w --width      INT Change the base number per line for fasta sequence,nonpositive integer for unlimited[100]
    -k --keyword    STR Extract sequence with title containing --keyword
    -p --piece      STR Extract sequence with --piece as sub-sequence
    -h --help           Print this help information
HELP
    exit(-1);
}

GetOptions(
            't|tab'         => \$tab,
            'n|ncbi'        => \$ncbi,
            'v|noVersion'   => \$noVersion,
            'f|fasta'       => \$fasta,
            'w|width=i'     => \$width,
            'k|keyword=s'   => \$keyword,
            'p|piece=s'     => \$piece,
            'h|help'        => sub{\&usage()}
        )||usage();

$ARGV[0]='-' unless defined $ARGV[0];
open IN,"$ARGV[0]" or die "Can't open $ARGV[0]: $!";

if(defined $tab){
    chomp(my $title=<IN>);
    $title =~ /^>\s*(.+)/;
    my $name = $1;
    $name = (split /\|/, $name)[3] if defined $ncbi;
    $name =~ s/\.\d+$// if defined $noVersion;
    my $seq;
    while(<IN>){
        chomp;
        if(/^>\s*(.+)/){
            my $toOutput = 1;
            my $newName = $1;
            $newName = (split /\|/, $newName)[3] if defined $ncbi;
            $newName =~ s/\.\d+$// if defined $noVersion;
            if (defined $keyword && $title !~ /$keyword/ || defined $piece && $seq!~/$piece/){
                $toOutput = 0;
            }
            say join "\t",($name, $title, $seq) if $toOutput == 1;
            ($title, $name, $seq) = ($_, $newName, "");
        }else{
            $seq .= $_;
        }
    }
    my $toOutput = 1;
    if (defined $keyword && $title !~ /$keyword/ || defined $piece && $seq !~ /$piece/){
        $toOutput = 0;
    }
    say join "\t",($name, $title, $seq) if $toOutput == 1; #output the last sequence
    exit;
}
if(defined $fasta){
    while(<IN>){
        chomp;
        my ($name, $title, $seq) = split "\t";
        my $toOutput = 1;
        if (defined $keyword && $title !~ /$keyword/ || defined $piece && $seq !~ /$piece/){
            $toOutput = 0;
        }
        if($toOutput == 1){
            say $title;
            say join "\n",&common::stringEquilongSplit($seq, $width);
        }
    }
    exit;
}

chomp(my $title = <IN>);
my $seq;
while(<IN>){
    chomp;
    if(/^>\s*.+/){#got to the new title
        my $toOutput = 1;
        $toOutput = 0 if defined $keyword && $title !~ /$keyword/ || defined $piece && $seq!~/$piece/;
        if($toOutput == 1){
            say $title;
            say join "\n", &common::stringEquilongSplit($seq, $width) 
        }
        $title = $_;
        $seq = "";
    }else{
        $seq .= $_; #append the sequence accumulatively
    }
}

my $toOutput = 1;
$toOutput = 0 if defined $keyword && $title!~/$keyword/ || defined $piece && $seq !~ /$piece/;

if ($toOutput == 1){ #output the last sequence
    say $title;
    say join "\n", &common::stringEquilongSplit($seq, $width);
}

