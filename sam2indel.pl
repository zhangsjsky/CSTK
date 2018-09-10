#!/bin/env perl

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::samParser;

my ($libType) = ('fr-unstranded');
my $genome;

sub usage {
    my $scriptName = basename $0;
    print <<HELP;
Usage: perl $scriptName options input.SAM/BAM >output.bed6+ 2>filtered.sam+
Option:
    -l --libraryType  STR     The library type, it can be
                                fr-unstranded: for Standard Illumina (default)
                                fr-firststrand: for dUTP, NSR, NNSR
                                fr-secondstrand: for Ligation, Standard SOLiD and Illumina Directional Protocol
    -g --genome       FASTA   Genome fasta with fai index
    -h --help                 Print this help information
HELP
    exit(-1);
}

GetOptions(
            "l|libraryType=s"   => \$libType,
            'g|genome=s'        => \$genome,
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
my %output;
while(defined $line){
    chomp $line;
    my @fields = split "\t", $line;
    my ($name, $flag, $cigar) = @fields[0, 1, 5];
    my $tags = join "\t", @fields[11..$#fields];
    
    if($cigar eq '*'){
        say STDERR join "\t", ("unmapped", $line);
        $line = <IN>;
        next;
    }
    if($cigar !~ /[DIN]/){
        $line = <IN>;
        next;
    }
    
    my $codingStrand = samParser::determineCodingStrand($libType, $flag);
    $tags =~ /XS:A:([+-])/;
    if(!defined $codingStrand){
        die "Please specify correct library type by --libType\n";
    }elsif($codingStrand eq '.'){# fr-unstranded
        $codingStrand = '.';
    }elsif($codingStrand eq ''){
        say STDERR join "\t", ("mappedAgainstLibType", $line);
        $line = <IN>;
        next;
    }elsif(defined $1 && $codingStrand ne $1){
        say STDERR join "\t", ("strandContradict", $line);
        $line = <IN>;
        next;
    }
    
    my ($ref, $currentStart) = @fields[2, 3];
    $currentStart--;
    
    $cigar =~ s/^\d+S//;
    $cigar =~ s/\d+S$//;
    
    while($cigar =~ s/(\d+)(\w)//){
        next if !defined $1;
        if($2 eq "M"){
            $currentStart += $1;
        }elsif($2 eq "D"){
            push @{$output{"Deletion:$ref:$currentStart:" . ($currentStart+$1) . ":$codingStrand"}}, "$name:$flag";
            $currentStart += $1;
        }elsif($2 eq "I"){
            push @{$output{"Insertion:$ref:$currentStart:" . ($currentStart+$1) . ":$codingStrand"}}, "$name:$flag";
        }elsif($2 eq "N"){
            push @{$output{"Intron:$ref:$currentStart:" . ($currentStart+$1) . ":$codingStrand"}}, "$name:$flag";
            $currentStart += $1;
        }
    }
    $line = <IN>;
}

say join "\t", ("#Chr", "Start", "End", "Name", "Score", "Strand", "ReferenceSequence", "ReadName1:Flag1,ReadName1:Flag2,ReadName2:Flag1...");
for my $ID(keys %output){
    my ($type, $ref, $start, $end, $strand) = split ":", $ID;
    my @reads = @{$output{$ID}};
    my $reads = join ",", @reads;
    my $refSeq = "NA";
    if($type eq "Deletion"){
        $refSeq = "";
        open FA, "samtools faidx $genome $ref:" . ($start+1) . "-$end |";
        while(<FA>){
            next if /^>/;
            chomp;
            $refSeq .= $_;
        }
    }
    say join "\t", ($ref, $start, $end, $type, scalar @reads, $strand, $refSeq, $reads);
}

