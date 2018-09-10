#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;


my ($field, $separater, $split) = (1, ',');
sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.tsv >OUTPUT.tsv
    If INPUT.tsv isn't specified, input from STDIN
Option:
    -f --field     INT  Field to operate
    -s --separater STR  Separate for collapse/split[$separater]
       --split          Split one line to multiple lines
    -h --help           Print this help information
HELP
    exit(-1);
}

GetOptions(
            'f|field=i'     => \$field,
            's|separater=s' => \$separater,
            'split'         => \$split,
            'h|help'        => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";


if(defined $split){
    while(<IN>){
        my @fields = split "\t";
        my @subFields = split $separater, $fields[$field];
        for my $subField(@subFields){
            $fields[$field] = $subField;
            print join "\t", @fields;
        }
    }
}else{
    my %hash;
    while(<IN>){
        $_ .= "\n" if $_ !~ /\n$/;
        my @fields = split "\t";
        my $subField = $fields[$field];
        splice @fields, $field, 1;
        my $otherFields = join "\t", @fields;
        push @{$hash{"$otherFields"}}, $subField;
    }
    for my $key(keys %hash){
        my @subFields = @{$hash{$key}};
        my $joinedValue = join $separater, @subFields;
        my @fields = split "\t", $key;
        splice @fields, $field, 0, $joinedValue;
        print join "\t", @fields;
    }
}
