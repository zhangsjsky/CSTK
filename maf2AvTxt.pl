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

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName OPTION INPUT.maf >OUTPUT_multianno.txt
    If INPUT.maf isn't specified, input from STDIN
Option:
    -h  --help                      Print this help information
HELP
}

GetOptions(
            'h|help'                => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

my %classification2exonicFunc = ( 'Frame_Shift_Del'          => 'frameshift_deletion',
                                  'Frame_Shift_Ins'          => 'frameshift_insertion',
                                  'In_Frame_Del'             => 'nonframeshift_deletion',
                                  'In_Frame_Ins'             => 'nonframeshift_insertion',
                                  'Missense_Mutation'        => 'nonsynonymous_SNV',
                                  'Nonsense_Mutation'        => 'stopgain',
                                  'Silent'                   => 'synonymous_SNV',
                                  'Nonstop_Mutation'         => 'stoploss',
                                  'Start_Codon_Del'          => 'startloss',
                                  'Start_Codon_Ins'          => 'startloss',
                                  'Start_Codon_SNP'          => 'startchanging',
                                  'Stop_Codon_Ins'           => 'stoploss',
                                  'Stop_Codon_Del'           => 'stoploss',
                                  'De_novo_Start_OutOfFrame' => 'startloss',
                                  'De_novo_Start_InFrame'    => 'startloss',
                                  'Unknown'                  => 'unknown',
                                  'Splice_Site'              => '.',
                                  'Intron'                   => '.',
                                  "5'Flank"                  => '.',
                                  "3'Flank"                  => '.',
                                  "5'UTR"                    => '.',
                                  "3'UTR"                    => '.',
                                  'RNA'                      => '.',
                                  'lincRNA'                  => ',',
                                  'IGR'                      => '.',
                                 );
my %classification2func = ( 'Frame_Shift_Del'          => 'exonic',
                            'Frame_Shift_Ins'          => 'exonic',
                            'In_Frame_Del'             => 'exonic',
                            'In_Frame_Ins'             => 'exonic',
                            'Missense_Mutation'        => 'exonic',
                            'Nonsense_Mutation'        => 'exonic',
                            'Silent'                   => 'exonic',
                            'Nonstop_Mutation'         => 'exonic',
                            'Start_Codon_Del'          => 'exonic',
                            'Start_Codon_Ins'          => 'exonic',
                            'Start_Codon_SNP'          => 'exonic',
                            'Stop_Codon_Ins'           => 'exonic',
                            'Stop_Codon_Del'           => 'exonic',
                            'De_novo_Start_OutOfFrame' => 'exonic',
                            'De_novo_Start_InFrame'    => 'exonic',
                            'Splice_Site'              => 'splicing',
                            'Intron'                   => 'intronic',
                            "5'UTR"                    => 'UTR5',
                            "3'UTR"                    => 'UTR3',
                            "5'Flank"                  => 'upstream',
                            "3'Flank"                  => 'downstream',
                            'IGR'                      => 'intergenic',
                            'RNA'                      => 'ncRNA|ncRNA_exonic',
                            'lincRNA'                  => 'ncRNA|ncRNA_exonic',
                            'Unknown'                  => 'unknown'
                           );

say join "\t", qw/Chr Start End Ref Alt Func.refGene Gene.refGene ExonicFunc.refGene AAChange.refGene Func.ensGene Gene.ensGene ExonicFunc.ensGene AAChange.ensGene/;

my %colName2Index;
while(<IN>){
    next if /^#/;
    if(/^Hugo_Symbol/){
        my @colNames = split "\t";
        for(my $i = 0; $i < @colNames; $i++){
            $colName2Index{"$colNames[$i]"} = $i;
        }
        next;
    }
    
    my @fields = split "\t";
    my $classification;
    if(exists $colName2Index{Variant_Classification}){
        $classification = $fields[$colName2Index{Variant_Classification}];
    }elsif(exists $colName2Index{i_Variant_Classification}){
        $classification = $fields[$colName2Index{i_Variant_Classification}];
    }
    
    my $geneRefGene = $fields[$colName2Index{Hugo_Symbol}];
    my $geneEnsGene;
    if(exists $colName2Index{"i_HGNC_Ensembl Gene ID"}){
        $geneEnsGene = $fields[$colName2Index{"i_HGNC_Ensembl Gene ID"}];
    }elsif(exists $colName2Index{"i_HGNC_Ensembl ID(supplied by Ensembl)"}){
        $geneEnsGene = $fields[$colName2Index{"i_HGNC_Ensembl ID(supplied by Ensembl)"}];
    }elsif(exists $colName2Index{i_dbNSFP_Ensembl_geneid}){
        $geneEnsGene = $fields[$colName2Index{i_dbNSFP_Ensembl_geneid}];
    }
    
    my $func = $classification2func{$classification};
    
    my $exonicFunc = $classification2exonicFunc{$classification};
    
    my ($aaChangeRefGene, $aaChangeEnsGene) = ('.', '.');
    if($classification ne 'RNA' && $classification ne 'Intron' && $classification ne 'IGR' && $classification ne "5'Flank" && $classification ne "3'Flank" && $classification ne 'Unknown'){
        my $refGeneRNAs;
        if(exists $colName2Index{Refseq_mRNA_Id} && $fields[$colName2Index{Refseq_mRNA_Id}] ne ''){
            $refGeneRNAs = $fields[$colName2Index{Refseq_mRNA_Id}];
        }elsif(exists $colName2Index{i_Refseq_mRNA_Id} && $fields[$colName2Index{i_Refseq_mRNA_Id}] ne ''){
            $refGeneRNAs = $fields[$colName2Index{i_Refseq_mRNA_Id}];
        }elsif(exists $colName2Index{"i_HGNC_RefSeq(supplied by NCBI)"} && $fields[$colName2Index{"i_HGNC_RefSeq(supplied by NCBI)"}] ne ''){
            $refGeneRNAs = $fields[$colName2Index{"i_HGNC_RefSeq(supplied by NCBI)"}];
        }else{
            $refGeneRNAs = $fields[$colName2Index{Annotation_Transcript}];
        }
        my @refGeneRNAs = split '\|', $refGeneRNAs;
        
        my $ensGeneRNAs;
        if(exists $colName2Index{i_annotation_transcript} && $fields[$colName2Index{i_annotation_transcript}] ne ''){
            $ensGeneRNAs = $fields[$colName2Index{i_annotation_transcript}];
        }elsif(exists $colName2Index{i_dbNSFP_Ensembl_transcriptid} && $fields[$colName2Index{i_dbNSFP_Ensembl_transcriptid}] ne ''){
            $ensGeneRNAs = $fields[$colName2Index{i_dbNSFP_Ensembl_transcriptid}];
        }else{
            $ensGeneRNAs = $fields[$colName2Index{Annotation_Transcript}];
        }
        my @ensGeneRNAs = split '\|', $ensGeneRNAs;
        
        my $exon;
        if(exists $colName2Index{Transcript_Exon}){
            $exon = $fields[$colName2Index{Transcript_Exon}];
        }elsif(exists $colName2Index{Exon_Number}){
            $exon = $fields[$colName2Index{Exon_Number}];
        }
        $exon .= '?';
        
        my $codingChange;
        my $proteinChange;
        if(exists $colName2Index{cDNA_Change} && $fields[$colName2Index{cDNA_Change}] ne ''){
            $codingChange = $fields[$colName2Index{cDNA_Change}];
        }elsif(exists $colName2Index{i_cDNA_Change}){
            $codingChange = $fields[$colName2Index{i_cDNA_Change}];
        }
        if(exists $colName2Index{Protein_Change}){
            $proteinChange = $fields[$colName2Index{Protein_Change}];
        }elsif(exists $colName2Index{i_Protein_Change}){
            $proteinChange = $fields[$colName2Index{i_Protein_Change}];
        }
        $aaChangeRefGene = join ',', map{$fields[$colName2Index{Hugo_Symbol}] . ":$_". ":exon$exon" . ":$codingChange?" . ":$proteinChange?"}(@refGeneRNAs);
        $aaChangeEnsGene = join ',', map{$geneEnsGene . ":$_". ":exon$exon" . ":$codingChange?" . ":$proteinChange?"}($ensGeneRNAs);
    }
    say join "\t", (@fields[$colName2Index{Chromosome}, $colName2Index{Start_position}, $colName2Index{End_position}, $colName2Index{Reference_Allele}, $colName2Index{Tumor_Seq_Allele2}], $func, $geneRefGene, $exonicFunc, $aaChangeRefGene, $func, $geneEnsGene, $exonicFunc, $aaChangeEnsGene);
}

