#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.010;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use lib dirname $0;
use pm::common;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    if INPUT isn't specified, input is from STDIN
Option:
    -n --NA     STR     The value for cell without value[NA]
    -r --rect           Get rectange matrix. All values of Col1 and Col2 in INPUT will be paired.
                        Self-paired will be set as --self if not be specified in INPUT.
    -s --self   STR     Set self-paired as[1]
    -h --help           Print this help information screen
HELP
    exit(-1);
}

my ($NA, $self) = ('NA', 1);
my $rectange;
GetOptions(
            'n|NA=s'     => \$NA,
            'r|rectange' => \$rectange,
            's|self=s'   => \$self,
            'h|help'     => sub{&usage()}
         )||usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't open file ($ARGV[0]): $!";

my %value;
my (@Xs, @Ys);
while(<IN>){
    chomp;
    my ($X, $Y, $value) = split "\t";
    push @Xs, $X;
    push @Ys, $Y;
    $value{$X}{$Y} = $value;
}

my (@tmpXs, @tmpYs);
if(defined $rectange){
    @tmpXs = (@Xs, @Ys);
    @tmpYs = @tmpXs;
}else{
    @tmpXs = @Xs;
    @tmpYs = @Ys;
}
@Xs = &common::uniqArray(\@tmpXs);
@Ys = &common::uniqArray(\@tmpYs);

say join "\t", ('Y\X', @Xs);
for my $Y(@Ys){
    print "$Y";
    for my $X(@Xs){
        print "\t";
        if(exists $value{$X}{$Y}){
            print $value{$X}{$Y}
        }elsif($X eq $Y){
            print $self;
        }else{
            print $NA;
        }
    }
    print "\n";
}