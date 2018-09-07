#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::samParser;
my ($unmapped, $split, $geneStrand, $maxInsertSize, $maxBestHitsN, $nm, $diff, $color, $help);
GetOptions(
            'u|unmapped'        => \$unmapped,
            's|split'           => \$split,
            'g|geneStrand=s'    => \$geneStrand,
            'i|maxInsertSize=i' => \$maxInsertSize,
            'b|bestHitsN=i'     => \$maxBestHitsN,
            'n|nm=i'            => \$nm,
            'd|diff=i'          => \$diff,
            'c|color'           => \$color,
            'h|help'            => \$help
        )||usage();
usage() if defined $help;

if(defined $ARGV[0]){
    if (-B $ARGV[0]){
        open IN, "samtools view -h $ARGV[0]|" or die "Can't open $ARGV[0]: $!";
    }else{
        open IN, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
    }
}else{
    open IN, "-";
}

if( defined $geneStrand ){
    die "Please specify the correct -g --geneStrand. It should be '+' or '-'.\n" if ($geneStrand ne '+' && $geneStrand ne '-');
}
my $read1;
while($read1 = <IN>){
    chomp $read1;
    if($read1 =~ /^@/){
        say $read1;
    }else{
        last;
    }
}

my ($totalN, $singletonN, $unmappedN, $passedN) = (0, 0, 0, 0);
while(defined $read1){
    chomp $read1;
    chomp( my $read2 = <IN>);
    my @fields1 = split "\t", $read1;
    my @fields2 = split "\t", $read2;
    if($fields1[0] ne $fields2[0]){
        die "Input isn't sorted by name" if $fields1[0] gt $fields2[0];
        say STDERR "Warning: $fields2[0] isn't paired with its previous one ($fields1[0]), skip the $fields1[0]";
        $read1 = $read2;
        $singletonN++;
        next;
    }
    $totalN++;
    if ($read1 !~ /XT:A:U/ && $read2 !~ /XT:A:U/){ # XT:A:M means Mate Smith-Waterman
        $read1 = <IN>;
        next;
    }
    if( &samParser::isUnmapped($fields1[1]) == 0 ){
        if( &samParser::isUnmapped($fields2[1]) == 0 ){            
            if( !defined $split && $fields1[2] ne $fields2[2]){    #whether map to the same reference
                $read1 = <IN>;
                next;
            }
            if( defined $geneStrand ){
                if( &samParser::determineCodingStrand('fr-firststrand',$fields1[1]) ne $geneStrand){
                    $read1 = <IN>;
                    next;
                }
            }
            my $read1BestHitsN = &samParser::getBestHitsN($read1);
            #next unless defined $read1BestHitsN; #no X0 (one read mapped but its mate unmapped)
            my $read2BestHitsN = &samParser::getBestHitsN($read2);
            #next unless defined $read2BestHitsN; #no X0 (one read mapped but its mate unmapped)    
            if(defined $maxInsertSize){
                if (abs($fields1[8]) > $maxInsertSize){
                    $read1 = <IN>;
                    next;
                }
            }
            if(defined $read1BestHitsN){
                if( defined $maxBestHitsN && $read1BestHitsN > $maxBestHitsN){
                    $read1 = <IN>;
                    next;
                }
                if($read1BestHitsN == 1 && defined $diff && &samParser::getSubHitsN($read1) > 0){
                    if ($read1 !~ /XA:Z/){ #BWA doesn't give XA when too many sub hits
                        $read1 = <IN>;
                        next;
                    }
                    if(defined $color){
                        $read1 =~ /CM:i:(\d+)/;
                        if( &samParser::getAltHitsMinNM($read1) - $1 < $diff){
                            $read1 = <IN>;
                            next;
                        }
                    }else{
                        $read1 =~ /NM:i:(\d+)/;
                        if(&samParser::getAltHitsMinNM($read1) - $1 < $diff){
                            $read1 = <IN>;
                            next;
                        }
                    }
                }
            }
            if(defined $read2BestHitsN){
                if( defined $maxBestHitsN && $read2BestHitsN > $maxBestHitsN){
                    $read1 = <IN>;
                    next;
                }
                if($read2BestHitsN == 1 && defined $diff && &samParser::getSubHitsN($read2) > 0){
                    if($read2 !~ /XA:Z/){ #BWA doesn't give XA when too many sub hits
                        $read1 = <IN>;
                        next;
                    }
                    if(defined $color){
                        $read2 =~ /CM:i:(\d+)/;
                        if( &samParser::getAltHitsMinNM($read2) - $1 < $diff){
                            $read1 = <IN>;
                            next;
                        }
                    }else{
                        $read2 =~ /NM:i:(\d+)/;
                        if( &samParser::getAltHitsMinNM($read2) - $1 < $diff){
                            $read1 = <IN>;
                            next;
                        }
                    }    
                }
            }
            if(defined $nm){
                if($read1 =~ /NM:i:(\d+)/ && $1 > $nm){
                    $read1 = <IN>;
                    next;
                }
                if($read2 =~ /NM:i:(\d+)/ && $1 > $nm){
                    $read1 = <IN>;
                    next;
                }
            }
        }else{#read1 mapped but read2 unmapped
            $unmappedN++;
            if (!defined $unmapped){
                $read1 = <IN>;
                next;
            }
        }        
    }else{#read1 is unmapped
        $unmappedN++;
        if(!defined $unmapped){
            $read1 = <IN>;
            next;
        }
    }
    say $read1;
    say $read2;
    $passedN++;
    $read1 = <IN>;
}
say STDERR "Total pairs = $totalN";
say STDERR "Passed pairs = $passedN (" . (sprintf "%.2f", $passedN/$totalN*100) . "%)";
say STDERR "Singleton = $singletonN";
say STDERR "Unmapped paris = $unmappedN";

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.sam/bam >OUTPUT.sam
    If INPUT.sam not specified, input from STDIN.
    Input must be sorted by read name.
    Passed pairs are output to STDOUT, unmapped pairs (when any read is unmapped) are discarded
    Summary information is output to STDERR
    
    -u --unmapped               Pair with both reads unmapped is passed
    -s --split                  Pair with two reads mapped to different reference is passed
    -g --geneStrand     CHAR    For strand-specific reads, only return the reads from the CHAR (+ or -) strand
    -i --maxInsertSize  INT     The maximal outer insert size for pair
    -b --maxBestHits    INT     Only return pairs with X0 of both reads <= INT. 1 is recommended
    -n --nm             INT     Only return pairs with NM of both reads <= INT
    -d --diff           INT     When X0=1, only return pairs with min(XA) - NM of both reads >= INT,
                                    where min(XA) is the minimal NM in the alternative hits.
    -c --color                  Color space reads

    -h --help                   Print this help information
HELP
    exit(-1);
}

=note
Examplar tags:
Read1:  XT:A:U  X0:i:1  X1:i:0
Read2:  XT:A:U  X0:i:1  X1:i:0

Read1:  XT:A:U  X0:i:2  X1:i:0  XA:Z:chr1,+242732134,101M,0;
Read2:  XT:A:U  X0:i:2  X1:i:0  XA:Z:chr1,-242732204,101M,1;

Read1:  XT:A:U  X0:i:1  X1:i:0
Read2:  XT:A:M

Read1:  XT:A:R  X0:i:2  X1:i:55
Read2:  XT:A:R  X0:i:19

Read1: (Unmapped)
Read2:  XT:A:R  X0:i:591
=cut