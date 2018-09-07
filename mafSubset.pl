#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.010;
use warnings;
use strict;
use Getopt::Long;
use File::Basename;

my @subFieldNames = qw/Hugo_Symbol
                       Chromosome
                       Start_position
                       End_position
                       Variant_Classification
                       Variant_Type
                       Reference_Allele
                       Tumor_Seq_Allele2
                       dbSNP_RS
                       Annotation_Transcript
                       Transcript_Strand
                       Transcript_Position
                       cDNA_Change
                       Codon_Change
                       Protein_Change
                       Refseq_mRNA_Id
                       Refseq_prot_Id
                       Description
                       GO_Biological_Process
                       GO_Cellular_Component
                       GO_Molecular_Function
                       t_ref_count
                       t_alt_count
                       1000gp3_AC
                       1000gp3_AF
                       1000gp3_AN
                       1000gp3_DP
                       HGNC_Chromosome
                       allele_count
                       allele_frequency
                       allelic_depth
                       dbNSFP_SIFT_score
                       depth_across_samples
                       gene_type
                       read_depth
                      /;
my $subFieldNames = join ',', @subFieldNames;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.maf >OUTPUT.tsv
    If INPUT isn't specified, input from STDIN
Option:
    -f  --fields    Comma-separated subset field names[$subFieldNames]
    -h  --help      Print this help information
HELP
    exit(-1);
}

GetOptions(
            'f|fields=s'    => \$subFieldNames,
            'h|help'        => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

my %header;
while(<IN>){
    chomp;
    next if /^#/;
    my @fields = split "\t";
    for(my $i = 0; $i <= $#fields; $i++){
        $header{$fields[$i]} = $i;
    }
    last;
}

@subFieldNames = split ',', $subFieldNames;
my @subFieldIndexes = map{$header{$_}}@subFieldNames;

say join "\t", @subFieldNames;
while (<IN>) {
    my @fields = split "\t";
    my @subFields;
    for my $index(@subFieldIndexes){
        if (defined $index) {
            push @subFields, $fields[$index];
        }else{
            push @subFields, "NoThisField";
        }
    }
    say join "\t", @subFields;
}


