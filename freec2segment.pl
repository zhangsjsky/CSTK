#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut


use 5.010;
use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::common;


sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName OPTION CNVs.tsv >segment.cbs 2>marker.tsv
    If CNVs.tsv isn't specified, input from STDIN
Option:
    -r  --ratio     TSV     The CNV ratio file
    -h  --help              Print this help information
NOTE: CNV.tsv and --ratio must be sort by chr, start and end
HELP
}


my ($ratio, $ROI, $sampleName);
GetOptions(
            'r|ratio=s'     => \$ratio,
            'h|help'        => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
open RATIO, "$ratio" or die "Can't read file ($ratio): $!";

say join "\t", ('Chromosome', 'Start', 'End', 'Num_Probes',  'Segment_Mean');
my $ratioLine  = <RATIO>;
$ratioLine = <RATIO> if $ratioLine =~ /^Chromosome/;
while(<IN>){
    chomp;
    my ($chr, $start, $end) = split "\t";
    next if $start eq "start";

    my %neutralMarker;
    my @chrs; # to store chromosomes in order as appearing in RATIO file
    while(defined $ratioLine){
        chomp $ratioLine;
        my ($markerChr, $markerStart, $ratio, $gene) = (split "\t", $ratioLine)[0..2,5];
        my $markerEnd = (split "-", $gene)[1];
        if($markerChr eq $chr && $start < $markerStart && $markerEnd <= $end){
            last;
        }else{
            push @chrs, $markerChr if !exists $neutralMarker{$markerChr};
            $neutralMarker{$markerChr}{start} = [] if !exists $neutralMarker{$markerChr}{start};
            push @{$neutralMarker{$markerChr}{start}}, $markerStart;
            $neutralMarker{$markerChr}{end} = [] if !exists $neutralMarker{$markerChr}{end};
            push @{$neutralMarker{$markerChr}{end}}, $markerEnd;
            $neutralMarker{$markerChr}{log2Ratio} = [] if !exists $neutralMarker{$markerChr}{log2Ratio};
            my $log2Ratio = $ratio == 0 ? -10 : log($ratio)/log(2);
            push @{$neutralMarker{$markerChr}{log2Ratio}}, $log2Ratio;
        }
        $ratioLine = <RATIO>;
    }
    for my $markerChr (@chrs){
        my @markerStarts = @{$neutralMarker{$markerChr}{start}};
        my @log2Ratios = @{$neutralMarker{$markerChr}{log2Ratio}};
        my ($segmentStart, $segmentEnd) = ($markerStarts[0], $neutralMarker{$markerChr}{end}->[-1]);
        say join "\t", ($markerChr
                      , $segmentStart
                      , $segmentEnd
                      , scalar @markerStarts
                      , &common::average(@log2Ratios)
        );
        for my $markerStart(@markerStarts[0..($#markerStarts-1)]){
            say STDERR join "\t", ("$markerChr:$markerStart", $markerChr, $markerStart)
        }
        say STDERR join "\t", ("$markerChr:$segmentEnd", $markerChr, $segmentEnd);
    }
    

    say STDERR join "\t", ("$chr:".($start+1), $chr, $start+1);
    my $markerCount = 1;
    my @log2Ratios;
    while(defined $ratioLine){
        chomp $ratioLine;
        my ($markerChr, $markerStart, $ratio, $gene) = (split "\t", $ratioLine)[0..2,5];
        my $markerEnd = (split "-", $gene)[1];
        if($markerChr eq $chr && $start < $markerStart && $markerEnd <= $end){
            my $log2Ratio = $ratio == 0 ? -10 : log($ratio)/log(2);
            push @log2Ratios, $log2Ratio;
            if($markerStart != $start+1 && $markerEnd != $end){
                say STDERR join "\t", ("$markerChr:$markerStart", $markerChr, $markerStart);
                $markerCount++;
            }
        }else{
            last;
        }
        $ratioLine = <RATIO>;
    }
    say STDERR join "\t", ("$chr:$end", $chr, $end);
    $markerCount++;
    
    my $segment_mean = &common::average(@log2Ratios);
    say join "\t", ($chr, $start+1, $end, $markerCount, $segment_mean);
}


my %neutralMarker;
my @chrs;
while(defined $ratioLine){
    chomp $ratioLine;
    my ($markerChr, $markerStart, $ratio, $gene) = (split "\t", $ratioLine)[0..2,5];
    my $markerEnd = (split "-", $gene)[1];

    push @chrs, $markerChr if !exists $neutralMarker{$markerChr};
    $neutralMarker{$markerChr}{start} = [] if !exists $neutralMarker{$markerChr}{start};
    push @{$neutralMarker{$markerChr}{start}}, $markerStart;
    $neutralMarker{$markerChr}{end} = [] if !exists $neutralMarker{$markerChr}{end};
    push @{$neutralMarker{$markerChr}{end}}, $markerEnd;
    $neutralMarker{$markerChr}{log2Ratio} = [] if !exists $neutralMarker{$markerChr}{log2Ratio};
    my $log2Ratio = $ratio == 0 ? -10 : log($ratio)/log(2);
    push @{$neutralMarker{$markerChr}{log2Ratio}}, $log2Ratio;
    
    $ratioLine = <RATIO>;
}
for my $markerChr (@chrs){
    my @markerStarts = @{$neutralMarker{$markerChr}{start}};
    my @log2Ratios = @{$neutralMarker{$markerChr}{log2Ratio}};
    my ($segmentStart, $segmentEnd) = ($markerStarts[0], $neutralMarker{$markerChr}{end}->[-1]);
    say join "\t", ($markerChr
                  , $segmentStart
                  , $segmentEnd
                  , scalar @markerStarts
                  , &common::average(@log2Ratios)
    );
    for my $markerStart(@markerStarts[0..($#markerStarts-1)]){
        say STDERR join "\t", ("$markerChr:$markerStart", $markerChr, $markerStart)
    }
    say STDERR join "\t", ("$markerChr:$segmentEnd", $markerChr, $segmentEnd);
}