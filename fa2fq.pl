#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

my ($faFile, $qualFile, $help);
my $score = 40;
GetOptions(
            'f|fa=s'    => \$faFile,
            'q|qual=s'  => \$qualFile,
            's|score=i' => \$score,
            'h|help'    => \$help
        ) || usage();
usage() if defined $help;

open FA,   "$faFile"   or die "Can't open $faFile:$!";
if(defined $qualFile){
    open QUAL, "$qualFile" or die "Can't open $qualFile:$!";
}

my $qualLine;
if(defined $qualFile){
    while($qualLine = <QUAL>){
        chomp $qualLine;
        next if $qualLine =~ /^#/;
        last if $qualLine =~ /^>/;
    }
}

my ($title, $seq);
while(<FA>){
    chomp;
    next if /^#/;
    if(/^>/){
        if($seq ne ''){            
            my $qualSeq = '';
            if(defined $qualFile){                
                die "unmatched read name: '$qualLine' != $title\n" if $qualLine ne $title;
                while($qualLine = <QUAL>){
                    chomp $qualLine;
                    last if $qualLine =~ /^>/;
                    $qualSeq .= $qualLine;
                }
            }            
            $title =~ s/^>//;            
            say '@'. "$title\n$seq\n+";
            if(defined $qualFile){
                say $qualSeq;
            }else{
                say chr($score + 33) x length $seq;
            }            
            $title = $_;
            $seq = '';
        }else{#first line of FA
            $title = $_;
        }
    }else{
        $seq .= $_;
    }
}
$title =~ s/^>//;
my $qualSeq;
if(defined $qualFile){
    while($qualLine = <QUAL>){
        chomp $qualLine;
        $qualSeq .= $qualLine;
    }
}
say '@'. "$title\n$seq\n+";
if(defined $qualFile){
    say $qualSeq;
}else{
    say chr($score + 33) x length $seq;
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName -f INPUT.fa -q INPUT.qual >OUTPUT.fq
    output to STDOUT
    
    -f|--fa     FILE    Fasta file
    -q|--qual   FILE    Quality file
    -s|--score  INT     Fake read quality score, ineffective when -q specified[40]
    
    -h|--help           Print this help information
HELP
    exit(-1);
}