#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use strict;
use 5.010;
use Getopt::Long;
use File::Basename;

my ($outputNoChildrenEntry, $title, $plus);
my $rgbItem='0,0,0';
GetOptions(
            'c|children'    => \$outputNoChildrenEntry,
            'r|rbg=s'       => \$rgbItem,
            't|title'       => \$title,
            'p|plus'        => \$plus,
            'h|help'        => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open GFF, "$ARGV[0]" or die "Can't open $ARGV[0]: $!";
my (%hash, %idRepeatEntry);
my @noIDEntries;
my @titleKeys;
while(<GFF>){
    chomp;
    next if /^#/;
    my @fields = split "\t";
    $fields[3] = $fields[3] - 1;    #1-based to 0-based
    $fields[5] = 0 if $fields[5] eq '.';
    my $attrs = pop @fields;
    my @attrs = split ";", $attrs;
    my (@attrNames, @attrVals);
    my ($ID, $parent);
    for my $attr (@attrs){
        my ($attrName, $attrVal) = split "=", $attr;
        given ($attrName){
            when (/^ID$/i) {$ID = $attrVal};
            when (/^Parent$/i){$parent = $attrVal};
            default {
                push @attrNames, $attrName;
                $attrVal =~ s/^"//; $attrVal =~ s/"$//;
                push @attrVals, $attrVal
            };
        }
        @titleKeys = @attrNames if @attrNames > @titleKeys;
    }
    if(defined $ID){
        if(exists $hash{"$ID"} || exists $idRepeatEntry{$ID}){    # ID repeat (eg. output of GMAP), should drop them since ambiguous
            $idRepeatEntry{"$ID"} = '';
            delete $hash{"$ID"};
        }else{
            @{$hash{"$ID"}}{qw/seqid source type start end score strand phase/} = @fields;
            $hash{"$ID"}{vals} = \@attrVals if @attrVals;
            $hash{"$ID"}{parent} = $parent if(defined $parent);
        }
    }else{
        push @noIDEntries, [\@fields, \@attrVals];
    }
}

if(defined $title){
    print join "\t", ('#chr', qw/start end name score strand thickStart thickEnd itemRgb
                blockCount blockSizes blockStarts/);
    if(defined $plus){
        print "\t";
        print join "\t", (qw/source type phase/, @titleKeys);        
    }
    print "\n";
}

for my $entry(@noIDEntries){
    my @fields = @{$entry->[0]};
    print join "\t", ( @fields[0, 3, 4],
                       '',   #name
                       @fields[5, 6, 3, 4],
                       $rgbItem,
                       1,
                       $fields[4] - $fields[3],
                       0
                      );
    if(defined $plus){
        my @attrVals = @{$entry->[1]};
        print "\t";
        print join "\t", @attrVals;
        if(@attrVals < @titleKeys){
            print "\t" for (1..@titleKeys - @attrVals);
        }
    }
    print "\n";
}

for my $ID(keys %hash){
    my ($start, $end, $parentID) = @{$hash{$ID}}{qw/start end parent/};
    if(defined $parentID){
        my $parentV = $hash{$parentID};
        if(exists $parentV->{children}->{$start}{$end}){
            push @{$parentV->{children}->{$start}{$end}}, $ID;
        }else{
            $parentV->{children}->{$start}{$end} = [$ID];
        }
    }
}

for my $ID(keys %hash){
    my $IDV = $hash{$ID};
    my $children = $IDV->{children};
    my $isChildrenOverlap;
    my (@blockStarts, @blockEnds, @blockSizes);
    if(defined $children){        
        for my $childrenStart (sort{$a<=>$b} keys %$children){
            my $childrenStartV = $children->{$childrenStart};
            for my $childrenEnd (sort{$a<=>$b} keys %$childrenStartV){
                my $childrenV = $childrenStartV->{$childrenEnd};
                $isChildrenOverlap = 'yes' if @$childrenV > 1;
                push @blockStarts, $childrenStart;
                push @blockEnds, $childrenEnd;
                push @blockSizes, $childrenEnd - $childrenStart;
            }
        }
        for (my $i = 0; $i < $#blockStarts; $i++){            
            my $blockEnd = $blockEnds[$i];
            my $nextBlockStart = $blockStarts[$i+1];
            $isChildrenOverlap = 'yes' if $blockEnd > $nextBlockStart;
        }
        if(defined $isChildrenOverlap){    #children is overlapping, output parent block instead of children's blocks
            @blockStarts = ($IDV->{start});
            @blockEnds = ($IDV->{end});
            @blockSizes = ($IDV->{end} - $IDV->{start});            
        }        
    }elsif(defined $outputNoChildrenEntry){
        @blockStarts = ($IDV->{start});
        @blockEnds = ($IDV->{end});
        @blockSizes = ($IDV->{end} - $IDV->{start}); 
    }
    next if @blockStarts == 0;
    my $blockRelStarts = join ",", map{$blockStarts[$_] - $blockStarts[0]}0..$#blockStarts;
    print join "\t", ($IDV->{seqid}, $blockStarts[0], $blockEnds[-1], $ID,
                @{$IDV}{qw/score strand/}, $blockStarts[0], $blockEnds[-1], $rgbItem,
                $#blockStarts + 1,   #blockCount
                (join ",", @blockSizes),  #blockSize
                $blockRelStarts #blockRelStarts
                );
    if(defined $plus){
        print "\t";
        print join "\t", (  @{$IDV}{qw/source type phase/} );
        if(exists $IDV->{vals}){
            print "\t";
            print join "\t", @{$IDV->{vals}};
            if(@{$IDV->{vals}} < @titleKeys){
                print "\t" for (1..@titleKeys - @{$IDV->{vals}});
            }
        }else{
            print "\t" x @titleKeys;
        }
    }    
    print "\n";
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.gff3 >OUTPUT.gpe
    if INPUT.gff3 isn't specified, input from STDIN
    output to STDOUT
    The output column is the standard bed12 columns plus (if necessary) additional columns from gff3
     (soure type phase and each attribute value) 

    -c --children       Output entry without children entries
    -r --rgb        STR RGB item value[0,0,0]
    -t --title          Output head title line
    -p --plus           Output bed12+ additional columns
    -h --help           Print this help information
HELP
    exit(-1);
}