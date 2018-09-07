#!/usr/bin/env perl
use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::gpeParser;

my($bin,$locus,$longTranscript,$name,$percent,$shortTranscript,$help);
$percent=0;
GetOptions(
	    'b|bin'	=>	\$bin,
        'l|locus'    =>      \$locus,
	    't|longTranscript' =>	\$longTranscript,
	    'n|name'	=>	\$name,
	    'p|percent=f' =>	\$percent,
	    'h|help'	=>	\$help
	    )||usage(); 
usage () if defined $help;

$ARGV[0]='-' unless defined $ARGV[0];
open GPE,"$ARGV[0]" or die "Can't open $ARGV[0]:$!";
my %hash_same;
while (<GPE>){
    chomp;
    my @GPE_input=split "\t",$_;
    my $bin_gpe=shift @GPE_input if defined $bin;
    my $keyValue;
    if(defined $locus){
        $keyValue=join "_",($GPE_input[1],$GPE_input[2]);
    }else{
        $keyValue=join "_",($GPE_input[11],$GPE_input[1],$GPE_input[2]);
    }
    if(exists $hash_same{$keyValue}){
		my $string;
		if(defined $bin){
			$string=join "\t",($bin_gpe,@GPE_input[0..14]);
		}else{
			$string=join "\t",(@GPE_input[0..14]);
		}
		$hash_same{$keyValue}=join "@",($hash_same{$keyValue},$string);
	}else{
		my $string;
		if(defined $bin){
			$string=join "\t",($bin_gpe,@GPE_input[0..14]);
		}else{
			$string=join "\t",(@GPE_input[0..14]);
		}
		$hash_same{$keyValue}=$string;
    }
}
foreach (keys %hash_same){
    my (%hash_T,$transcription_2,@transcription_2,$bin_TP2);
    my @same_data=split "@",$hash_same{$_};
    my $i=scalar @same_data;
    if($i==1){
		my @transcprion=split "\t",$same_data[0];
		my $bin_output=shift @transcprion if defined $bin;
		my $string_output;
		if(defined $name){
			if($transcprion[11] eq ""){
				$transcprion[11]=$transcprion[0];
			}
		}
		if(defined $bin){
			$string_output=join "\t",($bin_output,@transcprion[0..14]);
		}else{
			$string_output=join "\t",(@transcprion[0..14]);
		}
		say $string_output;
		next;
    }
    foreach (@same_data){
		my @transcription=split "\t",$_;
		shift @transcription if defined $bin;
		$hash_T{$_}=[$transcription[3],$transcription[0]];
    }
    @same_data=sort {$hash_T{$a}[0] <=> $hash_T{$b}[0] or $hash_T{$a}[1] cmp $hash_T{$b}[1]} keys %hash_T;
    my $k=0;
    my $new_TP;
    my @locus_merge;
    my $reference_e;
    while (@same_data){
	    my $transcript_temp = shift @same_data;
	    my @transcript_temp=split "\t",$transcript_temp;
	    my $bin_temp=shift @transcript_temp if defined $bin;
	    my $transcript_temp_s=$transcript_temp[3];
	    my $transcript_temp_e=$transcript_temp[4];
	    if($k==0){
			$reference_e=$transcript_temp_e;
			$k=1;
			push @locus_merge,$transcript_temp;
	    }else{
			if($transcript_temp_s > $reference_e){
				$reference_e = $transcript_temp_e;
				&merge(\@locus_merge);
				@locus_merge=();
				push @locus_merge,$transcript_temp;
			}else{
				$reference_e = $transcript_temp_e if $transcript_temp_e > $reference_e;
				push @locus_merge,$transcript_temp;
			}
	    }
    }
    &merge(\@locus_merge);
}

sub merge{
    my @temp=@_;
    my @locus_merge = @{$temp[0]};
    my $locus_number_B=0;
    my $locus_number_L=1;
    my $number=scalar @locus_merge;
    until($locus_number_B == $locus_number_L){
		$locus_number_B=0;
		foreach my $temp (@locus_merge){
			$locus_number_B++ if $temp ne 0;
		}
		for(my $i=0; $i<$number-1; $i++){
			next if $locus_merge[$i] eq 0;
			my $transcription_1=$locus_merge[$i];
			my @transcription_1=split "\t", $transcription_1;
			my $bin_TP1=shift @transcription_1 if defined $bin;
			$transcription_1[11]=$transcription_1[0] if defined $name && $transcription_1[11] eq "";
			my $name_TP1=$transcription_1[0];
			my $gene_name_TP1=$transcription_1[11];
			my $new_TP;
			for(my $j=$i+1; $j<$number; $j++){
				next if $locus_merge[$j] eq 0;
				my $transcription_2=$locus_merge[$j];
				my @transcription_2=split "\t",$transcription_2;
				my $bin_TP2=shift @transcription_2 if defined $bin;
				my @starts_TP1 = split ",",$transcription_1[8];
				my @ends_TP1 = split ",",$transcription_1[9];
				my @starts_TP2 = split ",",$transcription_2[8];
				my @ends_TP2 = split ",",$transcription_2[9];
				my $overlapLength = &gpeParser::getOverlapLength(\@starts_TP1,\@ends_TP1,\@starts_TP2,\@ends_TP2);
				my $exonLength_TP1 = &gpeParser::getExonsLength(\@starts_TP1,\@ends_TP1);
				my $exonLength_TP2 = &gpeParser::getExonsLength(\@starts_TP2,\@ends_TP2);
				my ($overlapPercent,$longExon_length,$shortExon_length);
				if($exonLength_TP1 > $exonLength_TP2){
					$longExon_length = $exonLength_TP1;
					$shortExon_length = $exonLength_TP2;
				}else{
					$longExon_length = $exonLength_TP2;
					$shortExon_length = $exonLength_TP1;
				}
				if(defined $longTranscript){
					$overlapPercent = sprintf("%.6f",$overlapLength/$longExon_length);
				}else{
					$overlapPercent = sprintf("%.6f",$overlapLength/$shortExon_length);
				}
				if($overlapPercent >= $percent){  
					$locus_merge[$i]=0;
					$locus_merge[$j]=0;
					$transcription_2[11]=$transcription_2[0] if defined $name && $transcription_2[11] eq "";
					my $name_TP2=$transcription_2[0];
					my $gene_name_TP2=$transcription_2[11];
					my @transcription_1_starts=split ",",$transcription_1[8];
					my @transcription_1_ends=split ",",$transcription_1[9];
					my @transcription_2_starts=split ",",$transcription_2[8];
					my @transcription_2_ends=split ",",$transcription_2[9];
					my @array_new_TP= &gpeParser::getMergedTrans(\@transcription_1_starts,\@transcription_1_ends,\@transcription_2_starts,\@transcription_2_ends);
					my $bin_new_TP=&stringJoin($bin_TP1,$bin_TP2);
					my $name_new_TP=join ",",($name_TP1,$name_TP2);
					my @tmp_3=@{$array_new_TP[0]};
					my @tmp_4=@{$array_new_TP[1]};
					my $exon_count=scalar @tmp_3;
					my $start_new_TP=$tmp_3[0];
					my $end_new_TP=$tmp_4[$exon_count-1];
					my $starts_new_TP=join ",",@tmp_3;
					my $ends_new_TP=join ",",@tmp_4;
					my $gene_name_new_TP=&stringJoin($gene_name_TP1,$gene_name_TP2);
					my $exonFrames;
					for(1..$exon_count){
						$exonFrames=join ",",(-1,$exonFrames);
					}
					if(defined $bin){
						$new_TP=join "\t",($bin_new_TP,$name_new_TP,$transcription_2[1],$transcription_2[2],$start_new_TP,$end_new_TP,$start_new_TP,$end_new_TP,$exon_count,$starts_new_TP,$ends_new_TP,0,$gene_name_new_TP,"unk","unk","$exonFrames");
					}else{
						$new_TP=join "\t",($name_new_TP,$transcription_2[1],$transcription_2[2],$start_new_TP,$end_new_TP,$start_new_TP,$end_new_TP,$exon_count,$starts_new_TP,$ends_new_TP,0,$gene_name_new_TP,"unk","unk","$exonFrames");
					}
					$transcription_1=$new_TP;
					$locus_merge[$i]=$new_TP;
					@transcription_1=split "\t", $transcription_1;
					$bin_TP1=shift @transcription_1 if defined $bin;
					$transcription_1[11]=$transcription_1[0] if defined $name && $transcription_1[11] eq "";
					$name_TP1=$transcription_1[0];
					$gene_name_TP1=$transcription_1[11];
				}
			}
		}
		$locus_number_L=0;
		foreach my $temp (@locus_merge){
			$locus_number_L++ if $temp ne 0;
		}
    }
    my %outputHash;
    foreach (my $i=0; $i < scalar @locus_merge; $i++){
		next if $locus_merge[$i] eq 0;
		my @tempArray = split "\t",$locus_merge[$i];
		if(defined $name){
			if(defined $bin){
				$tempArray[12]=$tempArray[1] if $tempArray[12] eq "";	
			}else{
				$tempArray[11]=$tempArray[0] if $tempArray[11] eq "";
			}
		}
		my $temp=join "\t",@tempArray;
		$outputHash{$temp}= [$tempArray[3],$tempArray[0]];
    }
    my @output=sort {$outputHash{$a}[0] <=> $outputHash{$b}[0] or $outputHash{$a}[1] cmp $outputHash{$b}[1]} keys %outputHash;
    foreach my $output(@output){
		say $output;
    }
}

sub stringJoin{
    my @inputData=@_;
    my %string;
    my $finalString;
    my @string1=split ",",$inputData[0];
    my @string2=split ",",$inputData[1];
    for(my $i=0; $i<scalar @string1; $i++){
        next if $string1[$i] eq "";
        $string{$string1[$i]}=0 if !exists $string{$string1[$i]};
    }
    for(my $i=0; $i<scalar @string2; $i++){
        next if $string2[$i] eq "";
        $string{$string2[$i]}=0 if !exists $string{$string2[$i]};
    }
    foreach my $key (sort keys %string){
        if($finalString eq ""){
            $finalString=$key;
        }else{
            $finalString.=",".$key;
        }
    }
    return $finalString;
}

sub usage{
    my $scriptName=basename $0;
print <<HELP;
    Usage: perl $scriptName Input_gpe.file >output_merge_gpe.file
	If Input_gpe.file not specified, input from STDIN
	Output to STDOUT

	-b --bin		Have bin column
        -l --locus              Merge with locus (default: merge gene)
	-t --longTranscript	Overlap is against long transcript (default against short transcript)
	-n --name 		Set the "gene name" column as "transcript name(s)" when the corresponding gene name unavailable
	-p --percent		Minimal overlap percent to merge tracscript (default: 0)
	-h --help		Print this help information
HELP
	exit(-1);
}