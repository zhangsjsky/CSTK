#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib (dirname $0);
use pm::mafParser;
use pm::gpeParser;
use Bio::Seq;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName -r interesting.bed -q rheMac2 -o rheMac2.bed -t DB.maf >OUTPUT.tsv
    The tool lift over the interesting regions on target species to specified query species. 'i', 'e' and 'q' lines are skipped.
    If DB.maf isn't specified, input from STDIN
    Output to STDOUT, which contains the following columns:
        C1-6:   6 columns of interesting region (chr, start, end, name, score, strand),
        C7:     comma-separated target regions where query can be aligned,
        C8:     comma-separated query regions that can be aligned to target, (double dash-line regions aren't kept)
        C9:     comma-separated target sequences for each target region
        C10:    comma-separated query sequences for each query region
        C11:    query regions status flag: 
                    1: when query regions on different chromosome and strand, that means the query regions are splited
                    -1: when query regions on the same chromosome or strand
                    0: when no query regions
        C12-?:  other columns if any, like theta (according to the options you specify)
                theta: the degree of divergence between target and query sequence estimated by 1 - match bases/target region length
                    1: when no query regions
    
    -r --region FILE    File with interesting regions in the first 4 columns: chr, start, end and name
    -f --format STR     Format of --region. It can be bed4 or bed6[bed6]
    -q --query  STR     Query name of the species in DB.maf
    -o --output FILE    Output the lifted regions in bed6 format plus additional columns:
                            splited NO/splited total
                            comma-separated target regions where query can be aligned
                           
    -t --theta          Calculate theta for each regions between target and query sequence. theta is 1 when region is unlifted
    -h --help           Print this help information
HELP
    exit(-1);
}

my ($regionFile, $query, $output, $toCalTheta);
my ($format) =("bed6");
GetOptions(
            'r|region=s'    => \$regionFile,
            'f|format=s'    => \$format,
            'q|query=s'     => \$query,
            'o|output=s'    => \$output,
            't|theta'       => \$toCalTheta,
            'h|help'        => sub{usage()}
        ) || usage();
open REGION, "$regionFile" or die "Can't open $regionFile: $!";
$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
if(defined $output){
    open OUTPUT, ">$output" or die "Can't create $output:$!";
}
#build up the hash structure of DB.maf
my %hash;
my ($targetChr, $targetStart, $targetLength, $targetStrand, $targetSeq, $targetEnd);
my $targetLine = "";
while(<IN>){
    chomp;
    next if /^#/;
    next if /^[aieq] /;
    if (/^$/){
        $targetLine = "";
        next;
    }
    if(/^s /){
        if($targetLine eq ""){
            $targetLine = $_;
            ($targetChr, $targetStart, $targetLength, $targetStrand, $targetSeq)
                            = /s\s+.+\.(\S+)                #targetChr
                                \s+(\d+)                    #targetStart
                                \s+(\d+)                    #targetLength
                                \s+([+-])                   #targetStrand
                                \s+\d+\s+([ATCGatcgNn-]+)   #targetSeq
                              /x;
            $targetEnd = $targetStart + $targetLength;
        }else{
            my ($queryName, $queryChr, $queryStart, $queryLength, $queryStrand, $querySrcSize, $querySeq)
                        = /s\s+(\S+?)               #queryName
                            \.(\S+)                 #queryChr
                            \s+(\d+)                #queryStart
                            \s+(\d+)                #queryLength
                            \s+([+-])               #queryStrand
                            \s+(\d+)                #querySrcSize
                            \s+([ATCGatcgNn-]+)     #querySeq
                          /x; 
            if($queryName eq $query){
                $queryStart = $querySrcSize - ($queryStart+$queryLength) if $queryStrand eq '-';
                my $queryEnd = $queryStart + $queryLength;
                $hash{"$targetChr:$targetStrand"}{"$targetStart-$targetEnd"} = {    targetSeq   => $targetSeq,
                                                                                    queryChr    => $queryChr,
                                                                                    queryStart  => $queryStart,
                                                                                    queryEnd    => $queryEnd,
                                                                                    queryStrand => $queryStrand,
                                                                                    querySeq    => $querySeq
            }                                                                  };
        }
    }
}

die "There's no query region aligned to target. Are you sure you type the correct query name by --query?\n" if keys %hash == 0;
#read interesting regions and lift
REGION:
while(<REGION>){
    chomp;

    my ($regionChr, $regionStart, $regionEnd, $name, $score, $regionStrand)= (split "\t")[0..5];
    if($format eq "bed4"){
        $score = 1000;
        $regionStrand = "+";
    }
    my %queryTiles;
    for my $regionK (keys %{$hash{"$regionChr:+"}}){
        my $regionV = $hash{"$regionChr:+"}{$regionK};
        my ($targetStart, $targetEnd) = split "-", $regionK;
        if ($targetStart < $regionEnd && $targetEnd > $regionStart){    #region overlaps with current target region
            my ($queryChr, $queryStrand, $queryStart, $queryEnd,  $querySeq, $targetSeq)
                        = @{$regionV}{qw/queryChr queryStrand queryStart queryEnd querySeq targetSeq/};
            if($targetStart < $regionStart){
                my $diffLength = $regionStart - $targetStart;
                $targetStart = $regionStart;
                my $leftTrimLen = &mafParser::getLeftBaseTrimLength($targetSeq, $diffLength);
                $targetSeq = substr $targetSeq, $leftTrimLen;
                my @queryTrimedBases = (substr $querySeq, 0, $leftTrimLen) =~ /([^-])/g;
                $querySeq =  substr $querySeq, $leftTrimLen;
                if($queryStrand eq '+'){
                    $queryStart += @queryTrimedBases;
                }else{
                    $queryEnd -= @queryTrimedBases;
                }
            }
            if($targetEnd > $regionEnd){
                my $diffLength = $targetEnd - $regionEnd;
                $targetEnd = $regionEnd;
                my $rightTrimLen = &mafParser::getRightBaseTrimLength($targetSeq, $diffLength);
                $targetSeq = substr $targetSeq, 0, (length ($targetSeq) - $rightTrimLen);
                my @queryTrimedBases = (substr $querySeq, (length ($querySeq) - $rightTrimLen) ) =~ /([^-])/g;
                $querySeq =  substr $querySeq, 0, (length ($querySeq) - $rightTrimLen);
                if($queryStrand eq '+'){
                    $queryEnd -= @queryTrimedBases;
                }else{
                    $queryStart += @queryTrimedBases;
                }
            }
            if($queryStart == $queryEnd){#no bases remain because of triming
                my $theta = defined $toCalTheta ? 1 : "NA";
                say join "\t", ($regionChr, $regionStart, $regionEnd, $name, $score, $regionStrand, "NA", "NA", "NA", "NA", 0, $theta);
                next REGION;
            }
            if($regionStrand eq '-'){
                $queryStrand = $queryStrand eq '+' ? '-' : '+';
                $targetSeq = Bio::Seq->new(-seq => $targetSeq)->revcom->seq;
                $querySeq = Bio::Seq->new(-seq => $querySeq)->revcom->seq;
            }
            $queryTiles{"$queryChr:$queryStrand"}{$queryStart} = {queryEnd    => $queryEnd,
                                                                  querySeq    => $querySeq,
                                                                  targetChr   => $regionChr,
                                                                  targetStart => $targetStart,
                                                                  targetEnd   => $targetEnd,
                                                                  targetSeq   => $targetSeq
                                                                };
        }
    }#for my $regionK (keys %{$hash{"$regionChr:+"}}){
    my @chrStrandKs = sort keys %queryTiles;
    if(@chrStrandKs == 0){
        my $theta = defined $toCalTheta ? 1 : "NA";
        say join "\t", ($regionChr, $regionStart, $regionEnd, $name, $score, $regionStrand, "NA", "NA", "NA", "NA", 0, $theta);
        next;
    }else{
        my (@targetRegions, @queryRegions, @targetSeqs, @querySeqs);
        my $nameIncre = 0;
        for my $chrStrandK (@chrStrandKs){
            my @splitedTargetRegions;
            $nameIncre++;
            my $chrStrandV = $queryTiles{$chrStrandK};
            my ($queryChr, $queryStrand) = split ":", $chrStrandK;
            my @sortedQueryStarts = sort {$a <=> $b} keys %$chrStrandV;
            my (@queryStarts, @queryEnds);
            for my $sortedQueryStart (@sortedQueryStarts){
                my ($queryEnd, $querySeq, $targetChr, $targetStart, $targetEnd, $targetSeq)
                        = @{$chrStrandV->{$sortedQueryStart}}{qw/queryEnd querySeq targetChr targetStart targetEnd targetSeq/};                
                push @splitedTargetRegions, "$targetChr:$regionStrand:$targetStart-$targetEnd";
                push @targetRegions, "$targetChr:$regionStrand:$targetStart-$targetEnd";                    
                push @queryRegions, "$queryChr:$queryStrand:$sortedQueryStart-$queryEnd";
                push @targetSeqs, $targetSeq;
                push @querySeqs, $querySeq;
                push @queryStarts, $sortedQueryStart;
                push @queryEnds, $queryEnd;
            }
            if(defined $output){
                my ($mergedQueryStarts, $mergedQueryEnds) = &gpeParser::getSewedExon(\@queryStarts, \@queryEnds);
                my @mergedBlockSizes = map {$mergedQueryEnds->[$_] - $mergedQueryStarts->[$_]} 0..@$mergedQueryStarts - 1;
                my @mergedBlockStarts = map {$mergedQueryStarts->[$_] - $mergedQueryStarts->[0]} 0..@$mergedQueryStarts - 1;
                say OUTPUT join "\t", ( $queryChr, $mergedQueryStarts->[0], $mergedQueryEnds->[-1],
                                        $name,
                                        $score, $queryStrand,
                                        $mergedQueryStarts->[0], $mergedQueryEnds->[-1], '0,0,0', scalar @$mergedQueryStarts,
                                        (join ",", @mergedBlockSizes),
                                        (join ",", @mergedBlockStarts),
                                        "$nameIncre/" . scalar(@chrStrandKs),  #splited NO/splited Total
                                        (join ",", @splitedTargetRegions)      #splitedTargetRegions
                                        );
            }
        }#for my $chrStrandK (@chrStrandKs)
        my $theta;
        if(defined $toCalTheta){
            $theta = sprintf "%0.3f", &mafParser::calTheta( (join "", @targetSeqs), (join "", @querySeqs), $regionEnd - $regionStart );
        }else{
            $theta = 'NA';
        }
        say join "\t", ($regionChr, $regionStart, $regionEnd, $name, $score, $regionStrand,
                        (join ",", @targetRegions),
                        (join ",", @queryRegions),
                        (join ",", @targetSeqs),
                        (join ",", @querySeqs),
                        @chrStrandKs >1? 1: -1, #map status
                        $theta
                        );
    }
}
