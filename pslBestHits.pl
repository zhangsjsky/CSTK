#!/bin/env perl
use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

my ($measure,$bestHitsN,$help)=('score',1);
GetOptions(
            'm|measure=s'       => \$measure,
            'b|bestHits=i'      => \$bestHitsN,
            'h|help'            => \$help
        )||usage();
usage() if defined $help;
$ARGV[0]='-' unless defined $ARGV[0];
open PSL,"$ARGV[0]" or die "Can't open $ARGV[0]:$!";
if(defined $measure){
    my %query;
    chomp(my $line=<PSL>);
    my @fields=split "\t", $line;
    my $queryName=$fields[9];
    my $measureValue;
    if($measure eq 'coverage'){
        $measureValue=($fields[12]-$fields[11]-$fields[5])/$fields[10];
        $query{$measureValue}=$line;
        while(<PSL>){
            chomp;
            my @fields=split "\t";
            my $measureValue=($fields[12]-$fields[11]-$fields[5])/$fields[10];
            if ($fields[9] eq $queryName){
                $query{$measureValue}=$_;
            }else{
                my @measures=sort {$b<=>$a} keys %query;
                for (my $i=0; $i < @measures && $i < $bestHitsN; $i++){
                    say $query{$measures[$i]};
                }
                %query=();
                $query{$measureValue}=$_;
                $queryName=$fields[9];
            }
        }
        my @measures=sort {$b<=>$a} keys %query;
        for (my $i=0; $i < @measures && $i < $bestHitsN; $i++){
            say $query{$measures[$i]};
        }
    }elsif($measure eq 'score'){
        $measureValue=$fields[0]-$fields[1];
        $query{$measureValue}=$line;
        while(<PSL>){
            chomp;
            my @fields=split "\t";
            my $measureValue=$fields[0]-$fields[1];
            if ($fields[9] eq $queryName){
                $query{$measureValue}=$_;
            }else{
                my @measures=sort {$b<=>$a} keys %query;
                for (my $i=0; $i<@measures && $i < $bestHitsN; $i++){
                    say $query{$measures[$i]};
                }
                %query=();
                $query{$measureValue}=$_;
                $queryName=$fields[9];
            }
        }
        my @measures=sort {$b<=>$a} keys %query;
        for (my $i=0; $i < @measures && $i < $bestHitsN; $i++){
            say $query{$measures[$i]};
        }
    }else{
        die "Please specify the correct --measure. It can be coverage or score.\n";
    }
}

sub usage{
    my $scriptName=(fileparse($0))[0];
print <<HELP;
Usage: perl $scriptName INPUT OUTPUT
    if INPUT isn't specified, input from STDIN
    output to STDOUT
    
    -m --measure        Measure for determining whether a hit is best. It can be coverage or score.[score]
    -b --bestHits=N     Output the top N best hits for each query. Available when --measure specified.[1]
    -h --help           Print this help information screen
HELP
    exit(-1);
}