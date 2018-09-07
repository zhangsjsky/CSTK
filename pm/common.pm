package common;

use strict;
use 5.010;
use List::Util;
require Exporter;

1;


##### Statistics
sub average{
    my $sum = List::Util::sum(@_);
    $sum / @_;
}

sub mean{
    &average(@_);
}


##### Array Operation
sub arraySplice{
    my ($arrayI, $splices) = @_;
    my @indexs;
    for my $splice(split ",", $splices){
        if($splice =~ /\D+/){ #-f 1- or -7 or 1-4 or -f 4-1 or -f1-1
            if( $splice =~ /\D+$/){#-f 1-
                my $from = (split /\D+/, $splice)[0];
                die "'$splice' in the fields your specify ($splices) isn't in correct form" unless defined $from;
                push @indexs,$_ for($from-1..$#$arrayI);
            }elsif( $splice =~ /^\D+/ ){#-f -7
                die "'$splice' in the fields your specify ($splices) isn't in correct form" if split /\D+/, $splice != 2;
                my $from = (split /\D+/, $splice)[1];
                push @indexs,$_ for reverse($from-1..$#$arrayI);
            }else{ #-f 1-4 or -f 4-1 or -f 1-1
                my ($from, $to) = split /\D+/, $splice;
                if($from < $to){ #-f 1-4
                   if ($to > @$arrayI){
                        say STDERR "Warnning: no $to columns in: ".join "\t",@$arrayI;
                        $to = @$arrayI;
                    }
                    push @indexs,$_ for( ($from-1)..($to-1) );
                }else{ #-f 4-1 or -f 1-1
                    ($from, $to) = ($to, $from);
                   if ($to > @$arrayI){
                        say STDERR "Warnning: no $to columns in: ".join "\t",@$arrayI;
                        $to = $#$arrayI;
                    }
                    push @indexs, $_ for reverse( ($from-1)..($to-1) );
                }
            }
        }else{ #-f 1
            if ($splice > @$arrayI){
                say STDERR "Warnning: no $splice columns in: ".join "\t",@$arrayI;
            }else{
                push @indexs, ($splice - 1);
            }            
        }
    }
    my @arraySpliced = map{$arrayI->[$_]}@indexs;
    return {
            "index" => \@indexs,
            "array" => \@arraySpliced
    };
}

sub uniqArray{
    my ($array) = @_;
    my %uniqArray;
    my @uniqArray;
    for my $value (@$array){
        if(!exists $uniqArray{$value}){
            push @uniqArray, $value;
            $uniqArray{$value} = '';
        }
    }
    return @uniqArray;
}

sub stringEquilongSplit{
    my ($string,$length)=@_;
    return ($string) if ($length<1);
    my @pieces;
    my $index=0;
    for (; $index+ $length < length $string; $index+=$length){
        push @pieces,substr $string,$index,$length;
    }
    push @pieces,substr( $string,$index,length($string)-$index );
    @pieces;
}

sub getColumnNumber{
    my ($file) = @_;
    my $maxColumnNO = 0;
    while(<$file>){
       chomp;
       my @fields = split "\t";
       $maxColumnNO = @fields if( @fields >$maxColumnNO );
    }
    return $maxColumnNO;
}

sub getFormatedTime{
    my @times = localtime;
    sprintf("[%d-%02d-%02d %02d:%02d:%02d]",
            $times[5] + 1900,
            $times[4] + 1,
            $times[3],
            $times[2],
            $times[1],
            $times[0]);
}

sub dictionaryGrow{
    my ($babyWords, $letters, $wordLen) = @_;
    my @grownWords;
    return @$babyWords if $wordLen == 1;
    for my $babyWord (@$babyWords){
        for my $letter(@$letters){
            push @grownWords, "$babyWord$letter";
        }
    }
    if(length $grownWords[0] < $wordLen){
        return dictionaryGrow(\@grownWords, $letters, $wordLen);
    }else{
        return @grownWords;
    }
}

sub dictionaryGenerater{
    my ($wordLen, $letters) = @_;
    return if $wordLen == 0;
    dictionaryGrow($letters, $letters, $wordLen);
}

sub getAbbr{
    my ($fullName, $separater) = @_;
    $separater = ' ' unless defined $separater;
    my $abbr;
    my @words = split "$separater", $fullName;
    if(@words == 1){
        $abbr = substr $fullName, 0, 2;
    }else{
        $abbr = join "", map{substr $_, 0, 1}@words;
        $abbr = "\U$abbr";
    }
}

sub maxArray{
    my ($array) = @_;
    my @sorted = sort @$array;
    my @out;
    my $i;
    for($i = $#sorted; $i > 0; $i--){
        push @out, $sorted[$i];
        if($sorted[$i] > $sorted[$i-1]){
            last;
        }
    }
    if($i == 0){
        push @out, $sorted[$i];
    }
}

sub removeUndefElement{
    my ($array) = @_;
    my @array = @$array;
    my @returnArray;
    for(my $i = 0; $i <= $#array; $i++){
        push @returnArray, $array[$i] if defined $array[$i];
    }
    return @returnArray;
}

sub dichotomy{
    my ($qPos, $tPoss, $toSortRegion) = @_; # pos is in 1-based
    my @tPoss = @$tPoss;
    return ('n') if @tPoss == 0;
    if(defined $toSortRegion && $toSortRegion == 1){
        @tPoss = sort {$a <=> $b}@tPoss;
    }
    return ('l') if $qPos < $tPoss[0];
    return ('r') if $qPos > $tPoss[-1];
    
    my ($l, $r) = (0, $#tPoss);
    while($r - $l > 1){
        my $m = int (($l + $r)/2);
        if($qPos < $tPoss[$m]){
            $r = $m;
        }elsif($qPos > $tPoss[$m]){
            $l = $m;
        }else{
            my @indexes;
            for(my $i = $m; $i >= 0 && $tPoss[$i] == $qPos; $i--){
                push @indexes, $i;
            }
            @indexes = reverse @indexes;
            for(my $j = $m + 1; $j <= $#tPoss && $tPoss[$j] == $qPos ; $j++){
                push @indexes, $j;
            }
            return ('e', @indexes);
        }
    }
    if($tPoss[$l] == $qPos){
        return ('e', $l);
    }elsif($tPoss[$r] == $qPos){
        return ('e', $r);
    }else{
        return ('b', $l, $r);
    }
}

sub getOvlRegs{
    my ($qStart, $qEnd, $tRegions, $toSortRegion) = @_;
    return if !defined $tRegions;
    my @tRegions = @$tRegions;
    return if @tRegions == 0;
    if(defined $toSortRegion && $toSortRegion == 1){
        @tRegions = sort {$a->[0] <=> $b->[0] || $a->[1] <=> $b->[1]}@tRegions;
    }
    my @targetStarts = map{$tRegions[$_]->[0]}0..$#tRegions;
    my ($status, @indexes) = &dichotomy($qEnd, \@targetStarts);
    my $rightIndex;
    if($status eq 'e'){ # e: equal
        $rightIndex = $indexes[0] - 1;
    }elsif($status eq 'b'){ # b: between
        $rightIndex = $indexes[0];
    }elsif($status eq 'r'){ # r: right
        $rightIndex = $#tRegions;
    }else{
        return;
    }
    my @ovlRegions;
    my $qLen = $qEnd - $qStart;
    for(my $i = 0; $i <= $rightIndex; $i++){
        my ($tStart, $tEnd) = @{$tRegions[$i]};
        if($qStart < $tEnd && $qEnd > $tStart){
            my $ovlLen = ($qEnd < $tEnd ? $qEnd : $tEnd) - ($qStart > $tStart ? $qStart : $tStart);
            my $ovlRatioInQuery = $ovlLen / $qLen;
            my $ovlRatioInTarget = $ovlLen / ($tEnd - $tStart);
            push @ovlRegions, [$tRegions[$i], $ovlLen, $ovlRatioInQuery, $ovlRatioInTarget];
        }
    }
    return @ovlRegions;
}

sub reverseComplement{
    my ($seq) =@_;
    $seq = join '', reverse (split '', $seq);
    $seq =~ tr/ATCGRYKMBVDH/TAGCYRMKVBHD/;
    $seq =~ tr/atcgrykmbvdh/tagcyrmkvbhd/;
    $seq;
}
