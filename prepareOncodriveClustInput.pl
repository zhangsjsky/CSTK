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
use pm::gpeParser;

my ($gpe, $bin, $geneTransCdsLength);
my $geneAnno = 'refGene';
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName OPTION INPUT.vcf >non-syn.tsv 2>syn.tsv
    If INPUT.vcf isn't specified, input from STDIN
Option:
    -g  --gpe                   GPE     The gpe file
    -b  --bin                           With bin column in --gpe
        --geneAnno              STR     The gene annotation used in ANNOVAR[refGene]
    -o  --geneTransCdsLength    FILE    The file to which gene symbol, transcript name, CDS length are output
    -h  --help                          Print this help information
HELP
}

GetOptions(
            'g|gpe=s'                   => \$gpe,
            'b|bin'                     => \$bin,
            'geneAnno=s'                => \$geneAnno,
            'o|geneTransCdsLength=s'    => \$geneTransCdsLength,
            'h|help'                    => sub{usage(); exit}
) || usage();

open GPE, "$gpe" or die "Can't read file ($gpe): $!";
open OUTPUT, ">$geneTransCdsLength" or die "Can't write file ($geneTransCdsLength): $!";
$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

my %gene2CdsLength;
while(<GPE>){
    chomp;
    my @fields = split "\t";
    shift @fields if defined $bin;
    my ($name, $chr, $strand, $start, $end, $cdsStart, $cdsEnd, $exonStarts, $exonEnds, $gene) = @fields[0..6, 8, 9, 11];
    my @exonStarts = split ',', $exonStarts;
    my @exonEnds = split ',', $exonEnds;
    my $cdsLength = &gpeParser::getCDSLength($cdsStart, $cdsEnd, \@exonStarts, \@exonEnds);
    next if $cdsLength == 0;
    if (exists $gene2CdsLength{$gene}) {
        if ($cdsLength > $gene2CdsLength{$gene}{length}) {
            $gene2CdsLength{$gene}{trans} = ();
            $gene2CdsLength{$gene}{trans}{$name} = '';
            $gene2CdsLength{$gene}{length} = $cdsLength;
        #}elsif($cdsLength == $gene2CdsLength{$gene}{length}){
        #    $gene2CdsLength{$gene}{trans}{$name} = '';
        }
    }else{
        $gene2CdsLength{$gene}{trans}{$name} = '';
        $gene2CdsLength{$gene}{length} = $cdsLength;
    }
}

for my $gene(keys %gene2CdsLength){
    my @trans = keys %{$gene2CdsLength{$gene}{trans}};
    my $cdsLength = $gene2CdsLength{$gene}{length};
    for my $trans(@trans){
        say OUTPUT join "\t", ($gene, $trans, $cdsLength);
    }
}

my @sampleNames;
while(<IN>){
    if(/^#CHROM/){
        chomp;
        my @fields = split "\t";
        @sampleNames = @fields[9..$#fields];
        next;
    }
    next if /^#/;
    chomp;
    my @fields = split "\t";
    my ($chr, $genomePos, $INFOs, @FORMATs) = @fields[0, 1, 7, 9..$#fields];
    my @INFOs = split ';', $INFOs;
    my %INFOs;
    my ($exonicFunc, $aaChanges);
    for my $INFO(@INFOs){
        my ($key, $value) = split '=', $INFO;
        $exonicFunc = $value if $key eq "ExonicFunc.$geneAnno";
        $aaChanges = $value if $key eq "AAChange.$geneAnno";
    }
    # PLEKHN1:NM_001160184:exon6:c.498A>C:p.A166A,PLEKHN1:NM_032129:exon6:c.498A>C:p.A166A
    if($exonicFunc eq 'synonymous_SNV'){
        my @aaChanges = split ',', $aaChanges;
        for my $aaChange(@aaChanges){
            next if $aaChanges =~ /wholegene/;
            my ($gene, $trans, $exon, $cdsChange, $proteinChange) = split ':', $aaChange;
            next unless exists $gene2CdsLength{$gene}{trans}{$trans};
            my ($pos) = $cdsChange =~ /c\.(\d+)[ATCG]>/;
            for my $i(0..$#sampleNames){
                next if $FORMATs[$i] =~ /^0\/0:/;
                my $sampleName = $sampleNames[$i];
                say STDERR join "\t", ($gene, $trans, $chr, $genomePos, $sampleName, $exon, $exonicFunc, $pos);
            }
        }
    }elsif($exonicFunc eq 'nonsynonymous_SNV' || $exonicFunc eq 'stopgain' || $exonicFunc eq 'stoploss' || $exonicFunc eq 'frameshift_deletion' || $exonicFunc eq 'frameshift_insertion'){
        my @aaChanges = split ',', $aaChanges;
        for my $aaChange(@aaChanges){
            next if $aaChanges =~ /wholegene/;
            my ($gene, $trans, $exon, $cdsChange, $proteinChange) = split ':', $aaChange;
            next unless exists $gene2CdsLength{$gene}{trans}{$trans};
            my ($pos) = $cdsChange =~ /^c\.(\d+)\D/;
            for my $i(0..$#sampleNames){
                next if $FORMATs[$i] =~ /^0\/0:/;
                my $sampleName = $sampleNames[$i];
                say join "\t", ($gene, $trans, $chr, $genomePos, $sampleName, $exon, $exonicFunc, $pos);
            }
        }
    }
}

