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

my ($geneInfo);
my ($geneAnno, $version, $center,               $ncbiBuild, $strand, $dbSNP) =
   ('refGene', '2.4.1', 'Precision Scientific', '37',       '+',     'avsnp147');
my ($index, $seqSource, $validationMethod, $sequencer) = (1, 'WXS', 'none', 'Illumina HiSeq');
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName OPTION INPUT.vcf >OUTPUT.maf
    If INPUT.vcf isn't specified, input from STDIN
Option:
    -g  --geneInfo          TSV     Columns: Entrez ID, Gene symbol, Description, Gene_type.
                                    The information can be downloaded from ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/GENE_INFO
    -a  --geneAnno          STR     The gene annotation used by ANNOVAR[$geneAnno]
    -v  --version           STR     The maf version[$version]
    -s  --dbsnpVer          STR     The version of dbSNP in INFO[$dbSNP]
    -i  --index             INT     The index of normal sample (1-based, counted after FORMAT column)[$index]
        --seqSource         STR     Molecular assay type used to produce the analytes used for sequencing.
                                    Allowed values are a subset of the SRA 1.5 library_strategy field values.
                                    This subset matches those used at CGHub.
                                    E.g.: WGS, [WXS], RNA-Seq, miRNA-Seq, Bisulfite-Seq, AMPLICON, etc.
    -m  --validationMethod  STRs    The assay platforms used for the validation call.
                                    E.g.: [none], Sanger_PCR_WGA, Sanger_PCR_gDNA, 454_PCR_WGA, 454_PCR_gDNA.
                                    Separate multiple entries using semicolons.
        --sequencer         STRs    Instrument used to produce primary data.
                                    Separate multiple entries using semicolons.
                                    E.g.: Illumina GAIIx, [Illumina HiSeq], PacBio RS, Illumina MiSeq, Illumina HiSeq 2500
    -h  --help                      Print this help information
HELP
}

GetOptions(
            'g|geneInfo=s'          => \$geneInfo,
            'a|geneAnno=s'          => \$geneAnno,
            'v|version=s'           => \$version,
            'c|center=s'            => \$center,
            'b|ncbiBuild=s'         => \$ncbiBuild,
            's|dbsnpVer=s'          => \$dbSNP,
            'i|index=i'             => \$index,
            'seqSource=s'           => \$seqSource,
            'm|validationMethod=s'  => \$validationMethod,
            'sequencer=s'           => \$sequencer,
            'h|help'                => sub{usage(); exit}
) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";
open GENEINFO, "$geneInfo" or die "Can't read file ($geneInfo): $!";

my %geneInfo;
while(<GENEINFO>){
    next if /^#/;
    chomp;
    my ($entrezID, $symbol, $description, $geneType) = split "\t";
    $geneInfo{$symbol} = [$entrezID, $description, $geneType];
}
my %exonicFunc2classification = ( 'frameshift_deletion'       => 'Frame_Shift_Del',
                                  'frameshift_insertion'      => 'Frame_Shift_Ins',
                                  'nonframeshift_deletion'    => 'In_Frame_Del',
                                  'nonframeshift_insertion'   => 'In_Frame_Ins',
                                  'nonsynonymous_SNV'         => 'Missense_Mutation',
                                  'stopgain'                  => 'Nonsense_Mutation',
                                  'synonymous_SNV'            => 'Silent',
                                  'stoploss'                  => 'Nonstop_Mutation',
                                  'unknown'                   => 'Unknown'
                                );
my %func2classification = ( 'exonic'                => 'Exonic', # Not in Variant_Classification
                            'splicing'              => 'Splice_Site',
                            'exonic;splicing'       => 'Splice_Site',
                            'ncRNA_splicing'        => 'Splice_Site',
                            'ncRNA_exonic;splicing' => 'Splice_Site',
                            'UTR5'                  => "5'UTR",
                            'UTR3'                  => "3'UTR",
                            'upstream'              => "5'Flank",
                            'downstream'            => "3'Flank",
                            'intergenic'            => 'IGR',
                            'intronic'              => 'Intron',
                            'ncRNA_intronic'        => 'Intron',
                            'ncRNA'                 => 'RNA',
                            'ncRNA_exonic'          => 'RNA',
                          );

my @sampleNames;

say "##version $version";

my $line;
while($line = <IN>){
    chomp $line;
    if($line =~ /^#/){
        if($line =~ /^#CHROM/){
            my @fields = split "\t", $line;
            @sampleNames = @fields[9..$#fields];
            last;
        }else{
            next;
        }
    }else{
        die "No #CHROM line?\n";
    }
}
my $normalBarcode = $sampleNames[$index-1];

say join "\t", qw/Hugo_Symbol Entrez_Gene_Id Center NCBI_Build Chromosome
                  Start_Position End_Position Strand Variant_Classification Variant_Type
                  Reference_Allele Tumor_Seq_Allele1 Tumor_Seq_Allele2 dbSNP_RS dbSNP_Val_Status
                  Tumor_Sample_Barcode Matched_Norm_Sample_Barcode Match_Norm_Seq_Allele1 Match_Norm_Seq_Allele2 Tumor_Validation_Allele1
                  Tumor_Validation_Allele2 Match_Norm_Validation_Allele1 Match_Norm_Validation_Allele2 Verification_Status Validation_Status
                  Mutation_Status Sequencing_Phase Sequence_Source Validation_Method Score
                  BAM_File Sequencer Tumor_Sample_UUID Matched_Norm_Sample_UUID Genome_Change
                  Annotation_Transcript Transcript_Exon cDNA_Change Protein_Change Other_Transcripts
                  Refseq_mRNA_Id Description gene_type t_ref_count t_alt_count
                  n_ref_count n_alt_count t_AF/;
                  
while($line = <IN>){
    chomp $line;
    my ($chr, $start, $ID, $ref, $alts, undef, undef, $INFOs, $formatKeys, @formats) = split "\t", $line;
    
    my $chrDigital = $chr;
    $chrDigital =~ s/^chr//;
    
    my %INFOs;
    for my $INFO(split ';', $INFOs){
        my ($key, $value) = split '=', $INFO;
        if(defined $value){
            $value =~ s/\\x3b/;/;
            $value =~ s/\\x3d/=/;
        }else{
            $value = '';
        }
        $INFOs{$key} = $value;
    }
    
    my @formatKeys = split ':', $formatKeys;
    
    my $normalFormat = $formats[$index-1];
    my @normalFormatValues = split ':', $normalFormat;
    my %normalFormats;
    $normalFormats{$formatKeys[$_]} = $normalFormatValues[$_] for 0..$#formatKeys;
    
    my $normalGT = $normalFormats{GT};
    
    if($ID eq '.'){
        if(exists $INFOs{$dbSNP}){
            $ID = $INFOs{$dbSNP} eq '.' ? 'novel' : $INFOs{$dbSNP};
        }else{
            die "No dbSNP annotation in INFO\n";
        }
    }
    
    for(my $formatI = 0; $formatI <= $#formats; $formatI++){
        next if $formatI == $index-1;
        
        my $tumorFormat = $formats[$formatI];
        my %tumorFormats;
        my @tumorFormatValues = split ':', $tumorFormat;
        $tumorFormats{$formatKeys[$_]} = $tumorFormatValues[$_] for 0..$#formatKeys;
        
        my $symbol = $INFOs{"Gene.$geneAnno"};
        #$symbol = "Unknown" if $symbol =~ /,/;
        my ($entrezID, $description, $geneType) = (0, '', '');
        ($entrezID, $description, $geneType) = @{$geneInfo{$symbol}} if exists $geneInfo{$symbol};
        
        my @exonicFunc = split ',', $INFOs{"ExonicFunc.$geneAnno"};
        
        my @func = split ',', $INFOs{"Func.$geneAnno"};
        
        my $tumorBarcode = $sampleNames[$formatI];
        
        my @alts = split ',', $alts;
        for(my $i = 0; $i <= $#alts; $i++){
            my $alt = $alts[$i];
            
            my $end = $start + (length $alt) - 1;
            
            my $exonicFun = $exonicFunc[$i];
            my $func = $func[$i];
            
            my $classification;
            if(exists $exonicFunc2classification{$exonicFun}){
                $classification = $exonicFunc2classification{$exonicFun};
            }elsif(exists $func2classification{$func}){
                $classification = $func2classification{$func};
            }else{
                $classification = '.';
            }
            
            my $variantType;
            if($ref =~ /^[ATCG]$/i){
                if(length $alt == 1){
                    if($alt ne '-'){
                        $variantType = 'SNP';
                    }else{
                        $variantType = 'DEL';
                    }
                }else{
                    $variantType = 'INS';
                }
            }elsif($ref eq '-'){
                $variantType = 'INS';
            }else{
                if(length $alt == 1){
                    $variantType = 'DEL';
                }
            }
            
            my ($normalAllele1, $normalAllele2);
            if($normalGT eq '0/0'){
                $normalAllele1 = $normalAllele2 = $ref;
            }elsif($normalGT eq '0/1'){
                $normalAllele1 = $ref;
                $normalAllele2 = $alt;
            }elsif($normalGT eq '1/1'){
                $normalAllele1 = $normalAllele2 = $alt;
            }else{
                die "Other GT: $normalGT\n";
            }
            
            my ($tumorAllele1, $tumorAllele2);
            my $tumorGT = $tumorFormats{GT};
            if($tumorGT eq '0/0'){
                $tumorAllele1 = $tumorAllele2 = $ref;
            }elsif($tumorGT eq '0/1'){
                $tumorAllele1 = $ref;
                $tumorAllele2 = $alt;
            }elsif($tumorGT eq '1/1'){
                $tumorAllele1 = $tumorAllele2 = $alt;
            }else{
                die "Other GT: $tumorGT\n";
            }
            
            my $mutationStatus = 'None';
            if($tumorGT eq $normalGT){
                $mutationStatus = 'Germline';
            }elsif($normalGT eq '0/0' || $normalGT eq '1/1'){
                $mutationStatus = 'Somatic';
            }elsif($normalGT eq '0/1'){
                $mutationStatus = 'LOH';
            }
            
            my @AAChanges = split ',', $INFOs{"AAChange.$geneAnno"};
            my ($transcript, $exon, $cDNAChange, $proteinChange) = ('', '', '', '');
            my @otherAAChanges;
            if($INFOs{"AAChange.$geneAnno"} ne '.' && $INFOs{"AAChange.$geneAnno"} ne 'UNKNOWN') {
                if($INFOs{"AAChange.$geneAnno"} =~ /wholegene/){
                    $transcript = (split ':', $AAChanges[0])[1];
                }else{
                    (undef, $transcript, $exon, $cDNAChange, $proteinChange) = split ':', $AAChanges[0];
                    $exon =~ s/exon//;
                    for my $AAChange(@AAChanges[1..$#AAChanges]){
                        my @AAChange = split ':', $AAChange;
                        push @otherAAChanges, "$AAChange[0]_$AAChange[1]_${classification}_$AAChange[4]";
                    }
                }
            }
            
            my ($t_alt_count, $n_alt_count, $t_ref_count, $n_ref_count);
            if(exists $tumorFormats{AD}){
                if($tumorFormats{AD} eq '.'){# For some mutation of MuTect2
                    ($t_ref_count, $t_alt_count) = ('.', '.');
                }else{
                    my @ADs = split ',', $tumorFormats{AD};
                    if(@ADs > 1){ # For MuTect2
                        ($t_ref_count, $t_alt_count) = @ADs;
                    }else{ # For VarScan
                        $t_alt_count = $tumorFormats{AD};
                    }
                }
                if($normalFormats{AD} eq '.'){
                    ($n_ref_count, $n_alt_count) = ('.', '.');
                }else{
                    my @ADs = split ',', $normalFormats{AD};
                    if(@ADs > 1){ # For MuTect2
                        ($n_ref_count, $n_alt_count) = @ADs;
                    }else{ # For VarScan
                        $n_alt_count = $normalFormats{AD};
                    }
                }
            }elsif(exists $tumorFormats{TIR}){ # For VarScan Indel?
                $t_alt_count = (split ',', $tumorFormats{TIR})[0];
                $n_alt_count = (split ',', $normalFormats{TIR})[0];
            }
            if(exists $tumorFormats{RD}){ # For VarScan
                ($t_ref_count, $n_ref_count) = ($tumorFormats{RD}, $normalFormats{RD});
            }elsif(!defined $t_ref_count){ # For MuTect2
                ($t_ref_count, $n_ref_count) = ($tumorFormats{DP} - $t_alt_count, $normalFormats{DP} - $n_alt_count);
            }
            my $t_AF;
            if(exists $tumorFormats{AF}){
                $t_AF = $tumorFormats{AF};
            }else{
                $t_AF = $t_alt_count / ($t_ref_count + $t_alt_count);
            }
            
            # MAF format specification requires the "Chromosome" should be number without "chr" prefix
            say join "\t", ($symbol, $entrezID, $center, $ncbiBuild, $chrDigital,
                            $start, $end, $strand, $classification, $variantType,
                            $ref, $tumorAllele1, $tumorAllele2, $ID, 'Unknown',
                            $tumorBarcode, $normalBarcode, $normalAllele1, $normalAllele2, $tumorAllele1,
                            $tumorAllele2, $normalAllele1, $normalAllele2, 'Unknown', 'Untested',
                            $mutationStatus, '', $seqSource, $validationMethod, '',
                            '', $sequencer, $tumorBarcode, $normalBarcode, "g.$chr:$start$ref>$alt",
                            $transcript, $exon, $cDNAChange, $proteinChange, (join "|", @otherAAChanges),
                            $transcript, $description, $geneType, $t_ref_count, $t_alt_count, $n_ref_count,
                            $n_alt_count, $t_AF);
        }
    } # for
} # while

