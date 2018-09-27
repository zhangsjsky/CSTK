#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::bedParser;
use pm::samParser;

my ($bedFile);
my ($libType, $slop, $minRead) = ('fr-unstranded', 4, 2);
GetOptions(
            'b|bed=s'           => \$bedFile,
            'l|libraryType=s'   => \$libType,
            's|slop=i'          => \$slop,
            'r|minRead=i'       => \$minRead,
            'h|help'            => sub{usage()}
        ) || usage();

open BED, "$bedFile" or die "Can't open $bedFile: $!";
if(-f $ARGV[0]){
    unless (-B $ARGV[0]){
        die "It seems that you specify a plain text file(may be sam?), please offer it in bam format\n";
    }
}else{
    die "Please specify the bam file\n";
}

my %exonHash;
while(<BED>){
    chomp;
    my ($chr, $start, $end, $name, $strand, $exonCount, $exonSizes, $relStarts) = (split "\t")[0..3, 5, 9, 10, 11];
    my @exonSizes = split ',', $exonSizes;
    my @relStarts = split ',', $relStarts;
    my ($exonStarts, $exonEnds) = bedParser::getAbsLoc($start, \@exonSizes, \@relStarts);
    for(my $i = 1; $i < @$exonStarts - 1; $i++){ # ignore the 1st and last exons
        my ($exonStart, $exonEnd) = ($exonStarts->[$i], $exonEnds->[$i]);
        my $exonRank = $strand eq '+' ? ($i+1) : ($exonCount - $i);
        $exonHash{"$chr:$strand:$exonStart:$exonEnd"}{exon}{"$name.$exonRank"} = '';
        if(exists $exonHash{"$chr:$strand:$exonStart:$exonEnd"}{start}){
            $exonHash{"$chr:$strand:$exonStart:$exonEnd"}{start} = $start if $start < $exonHash{"$chr:$strand:$exonStart:$exonEnd"}{start};
        }else{
            $exonHash{"$chr:$strand:$exonStart:$exonEnd"}{start} = $start;
        }
        if(exists $exonHash{"$chr:$strand:$exonStart:$exonEnd"}{end}){
            $exonHash{"$chr:$strand:$exonStart:$exonEnd"}{end} = $end if $end > $exonHash{"$chr:$strand:$exonStart:$exonEnd"}{end};
        }else{
            $exonHash{"$chr:$strand:$exonStart:$exonEnd"}{end} = $end;
        }
    }
}
for my $key(keys %exonHash){
    my ($chr, $strand, $exonStart, $exonEnd) = split ':', $key;
    my $value = $exonHash{$key};
    my ($geneStart, $geneEnd) = @$value{qw/start end/};
    open READS, "samtools view $ARGV[0] $chr:" . ($exonStart+1) . "-$exonEnd|" or die "Can't open $ARGV[0]";
    my $incRead = 0;
    my %excJuncs;
    while(<READS>){
        chomp;
        my ($flag, $readStart, $cigar) = (split "\t")[1, 3, 5];
        my $codingStrand = samParser::determineCodingStrand($libType, $flag);
        die "Please specify correct library type by --libType\n" unless defined $codingStrand;
        next if $codingStrand ne '.' && $codingStrand ne '' && $codingStrand ne $strand;
        $readStart--; # 1-based to 0-based
        if($cigar =~ /N/){
            my @junctions = samParser::cigar2eachJunction($readStart, $cigar);
            my ($firstJuncBlockStart, $firstJuncStart, $lastJuncEnd, $lastJuncBlockEnd) = (@{$junctions[0]}[0, 1], @{$junctions[-1]}[2, 3]);
            if($firstJuncStart == $exonEnd && $firstJuncBlockStart >= $exonStart - $slop ||
               $lastJuncEnd == $exonStart && $lastJuncBlockEnd <= $exonEnd + $slop){
                $incRead++;
            }else{
                for(my $j = 1; $j <= $#junctions; $j++){
                    my ($juncBlockStart, $juncStart) = @{$junctions[$j]}[0, 1];
                    $incRead++ if $juncBlockStart == $exonStart && $juncStart == $exonEnd;
                }
            }
            for my $junction (@junctions){
                my ($juncBlockStart, $juncStart, $juncEnd, $juncBlockEnd) = @$junction;
                next if $juncStart < $geneStart && $juncEnd > $geneEnd;
                if($juncStart < $exonStart && $exonEnd < $juncEnd){
                    if(exists $excJuncs{"$juncStart-$juncEnd"}){
                        $excJuncs{"$juncStart-$juncEnd"}{read}++;
                        $excJuncs{"$juncStart-$juncEnd"}{start} = $juncBlockStart if $juncBlockStart < $excJuncs{"$juncStart-$juncEnd"}{start};
                        $excJuncs{"$juncStart-$juncEnd"}{end} = $juncBlockEnd if $juncBlockEnd > $excJuncs{"$juncStart-$juncEnd"}{end};
                    }else{
                        $excJuncs{"$juncStart-$juncEnd"} = {read => 1, start => $juncBlockStart, end => $juncBlockEnd};
                    }
                    last;
                }
            }
        }else{ # exonic reads
            my $readEnd = $readStart;
            $readEnd += $_ for($cigar =~ /(\d+)[MD=X]/g);
            $incRead++ if $exonStart - $slop <= $readStart && $readEnd <= $exonEnd + $slop;
        }
    } # while(<READS>)
    my $exonIDs = join ',', keys %{$value->{exon}};
    my $incRho = $incRead / ($exonEnd - $exonStart);
    my $excRho = 0;
    my (@excReads, @excSpans);
    for my $junc(keys %excJuncs){
        my $juncV = $excJuncs{$junc};
        my ($read, $start, $end) = @$juncV{qw/read start end/};
        next if $read < $minRead;
        my ($juncStart, $juncEnd) = split '-', $junc;
        my $span = $juncStart - $start + $end - $juncEnd;
        $excRho += $read / $span;
        push @excReads, $read;
        push @excSpans, $span;
    }
    if($incRead == 0 && @excReads == 0){
        say join "\t", ($chr, $exonStart, $exonEnd, $exonIDs, 'NA', $strand,
                        0,
                        $exonEnd - $exonStart,
                        'NA',
                        0,
                        0,
                        'NA');
        next;
    }
    my $excReads = @excReads == 0 ? '0' : join ',', @excReads;
    my $excSpans = @excSpans == 0 ? '0' : join ',', @excSpans;
    my $usage = sprintf "%d", $incRho / ($incRho + $excRho) * 1000;
    say join "\t", ($chr, $exonStart, $exonEnd, $exonIDs, $usage, $strand,
                    $incRead,
                    $exonEnd - $exonStart,
                    $incRho,
                    $excReads,
                    $excSpans,
                    $excRho);
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.bam >OUTPUT.bed6+
    If INPUT.bam isn't specified, input from STDIN
Option:
    -b --bed          FILE    Gene models in bed12 format
    -l|--libraryType  STR     The library type, it can be
                                  fr-unstranded: for Standard Illumina (default)
                                  fr-firststrand: for dUTP, NSR, NNSR
                                  fr-secondstrand: for Ligation, Standard SOLiD and Illumina Directional Protocol
    -s --slop         INT     Maximal slope length for a read to be considered as exonic read[4]
    -r --minRead      INT     Minimal supporting reads count for an exclusion junction[2]
    -h --help                 Print this help information
Output:
    The 4th column is the transcript name and the exon rank (in transcriptional direction) speparated by a dot.
    The 5th column in OUTPUT.bed6+ is the PSI normalized into 0-1000.
    Additional columns are as follow:
        inclusion read count
        inclusion region length
        inclusion read density
        exclusion read counts separated by comma
        exclusion region lengths separated by comma
        exclusion read density
HELP
    exit(-1);
}
