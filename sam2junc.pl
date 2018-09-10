#!/bin/env perl

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::samParser;

my ($juncNum, $mismatch, $mappedProperly, $maxOutterLen);
my ($libType) = ('fr-unstranded');

sub usage {
    my $scriptName = basename $0;
    print <<HELP;
Usage: perl $scriptName options input.SAM(BAM) >output.bed12 2>filtered.sam+
Example: perl $scriptName -j 3 -m 5 -s brain.SAM(BAM) >output.bed12 2>filtered.sam+
    If input.SAM(BAM) isn't specified, input is from STDIN
    Output to STDOUT in bed12, to STEDERR in sam with additional first column describing the reasion of filtering
    The script gets read length from the first read in the input and skips non-junction read (no N in flag).
Option:
    -l|libraryType      STR The library type, it can be
                            fr-unstranded: for Standard Illumina (default)
                            fr-firststrand: for dUTP, NSR, NNSR
                            fr-secondstrand: for Ligation, Standard SOLiD and Illumina Directional Protocol
    -j|--maxJuncNum     INT Max junction number for one read[2 for read with length >= 70, 1 for that < 70]
                            Read that supports junction number > INT isn't used for computing junction score
    -m|--maxMisMatch    INT Max allowed mismatch[1 mismatch per 15 bp]
    -p|--mappedProperly     For single-end, require mapped
                            For pair-end, require both reads are mapped properly (require proper outter distance if -o is specified)
    -o|--maxOuterLen    INT The max allowed outer distance for pair-end reads.
                            (NOTE: tophat1.2 doesn't offer the outer distance in the 9th column.
                             Use this option only for tophat2)
    -h|--help               Print this help information
HELP
    exit(-1);
}

GetOptions(
    "l|libraryType=s"   => \$libType,
    "j|maxJuncNum=i"    => \$juncNum,
    "m|maxMatch=i"      => \$mismatch,
    "p|mappedProperly"  => \$mappedProperly,
    "o|maxOuterLen=i"   => \$maxOutterLen,
    "h|help"            => sub{&usage()}
)||usage();

if(defined $ARGV[0]){
    if (-B $ARGV[0]){
        open IN, "samtools view $ARGV[0] |" or die "Can't open $ARGV[0]: $!";
    }else{
        open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
    }
}else{
    open IN, "-";
}

chomp(my $line = <IN>);
$line = <IN> while($line =~ /^@/);
die "Warnning: your input hasn't any entry\n" if !defined $line;
my @fields = split "\t", $line;
my $readLen = length $fields[9];
$juncNum = $readLen >= 70 ? 2 : 1 if !defined $juncNum;
$mismatch = int($readLen / 15) if !defined $mismatch;
$juncNum++;
my %juncHash;
while(defined $line){
    chomp $line;
    my @fields = split "\t", $line;
    my ($flag, $cigar) = @fields[1, 5];
    my $tags = join "\t", @fields[11..$#fields];
    if($cigar eq '*'){
        say STDERR join "\t", ("unmapped", $line);
        $line = <IN>;
        next;
    }
    if($cigar !~ /N/){
        $line = <IN>;
        next;
    }
    if($tags =~ /NM:i:(\d+)/ && $1 > $mismatch){
        say STDERR join "\t", ("highMismatch", $line);
        $line = <IN>;
        next;
    }
    if($cigar =~ /(\d+[^N0-9]\d+N){$juncNum,}/){
        say STDERR join "\t", ("overMaxJuncNum", $line);
        $line = <IN>;
        next;
    }
    if(defined $mappedProperly){
        if( samParser::isUnmapped($flag) == 1 || samParser::isMateUnmapped($flag) == 1){
            say STDERR join "\t", ("notMappedRead", $line);
            $line = <IN>;
            next;
        }
        if( samParser::isPaired($flag) == 1 && samParser::isProperPair($flag) == 0){ # pair isn't properly mapped
            my $outterLen = abs($fields[8]);
            if($outterLen != 0 && defined $maxOutterLen){
                if($outterLen > $maxOutterLen){
                    say STDERR join "\t", ("overMaxOutterDistance", $line);
                    $line = <IN>;
                    next;
                }
            }else{
                say STDERR join "\t", ("notProperlyMappedPair", $line);
                $line = <IN>;
                next;
            }
        }
    }
    
    my $codingStrand = samParser::determineCodingStrand($libType, $flag);
    if(!defined $codingStrand){
        die "Please specify correct library type by --libType\n";
    }elsif($codingStrand eq ''){
        say STDERR join "\t", ("mappedAgainstLibType", $line);
        $line = <IN>;
        next;
    }else{
        $tags =~ /XS:A:([+-])/;
        if($codingStrand eq '.'){# fr-unstranded
            $codingStrand = $1 if defined $1;
        }else{
            if(defined $1 && $codingStrand ne $1){
                say STDERR join "\t", ("strandContradict", $line);
                $line = <IN>;
                next;
            }
        }
    }
    
    my ($ref, $readStart) = @fields[2, 3];
    $readStart--; # 1-bases to 0-based
    for my $junction (samParser::cigar2eachJunction($readStart, $cigar)){
        my ($start, $juncStart, $juncEnd, $end) = @$junction;
        my $junction = "$juncStart-$juncEnd";
        $juncHash{$ref}{$codingStrand}{$junction}{readNo}++;
        my $oldStart = $juncHash{$ref}{$codingStrand}{$junction}{start};
        my $oldEnd = $juncHash{$ref}{$codingStrand}{$junction}{end};
        if(defined $oldStart){
            $juncHash{$ref}{$codingStrand}{$junction}{start} = $start if $start < $oldStart;
        }else{
            $juncHash{$ref}{$codingStrand}{$junction}{start} = $start;
        }
        if (defined $oldEnd){
            $juncHash{$ref}{$codingStrand}{$junction}{end} = $end if $end > $oldEnd;
        }else{
            $juncHash{$ref}{$codingStrand}{$junction}{end} = $end;
        }
    }
    $line = <IN>;
}
for my $ref (sort keys %juncHash){
    my $refV = $juncHash{$ref};
    for my $strand (sort keys %$refV){
        my $strandV = $refV->{$strand};
        for my $junc (keys %$strandV){
            my ($readNo, $start, $end) = @{$strandV->{$junc}}{qw/readNo start end/};
            my ($juncStart, $juncEnd) = split '-', $junc;
            say join  "\t", ($ref,
                             $start,
                             $end,
                             "$ref:$strand:$juncStart-$juncEnd:$readNo",
                             $readNo,
                             $strand,
                             $start,
                             $end,
                             "0,0,0",
                             2,
                             ($juncStart - $start) . ',' . ($end - $juncEnd),
                             '0,' . ($juncEnd - $start));
        }
    }
}

