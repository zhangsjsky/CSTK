#!/usr/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;

my $threeEnd;
GetOptions(
            '3=i'       => \$threeEnd,
            'h|help'    => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
open IN, "$ARGV[0]" or die "Can't read file ($ARGV[0]): $!";

my ($title, $seq);
$title = <IN>;
while(<IN>){
    chomp;
    if(/^>/){
        &output($title, $seq);
        $title = $_;
        $seq = '';
    }else{
        $seq .= $_;
    }
}
&output($title, $seq);

sub output{
    my ($title, $seq) = @_;
    $title =~ /^>(.+)/;
    my $id = $1;
    print <<EOF;
SEQUENCE_ID=$id
SEQUENCE_TEMPLATE=$seq
EOF
    if(defined $threeEnd){
        my $seqLen = length $seq;
        my ($start, $length);
        if($threeEnd <= $seqLen){
            $start = $seqLen - $threeEnd;
            $length = $threeEnd;
        }else{
            $start = 0;
            $length = $seqLen;
        }
        say "SEQUENCE_INCLUDED_REGION=$start,$length";
    }
    say "=";
}

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT >OUTPUT
    If INPUT isn't specified, input from STDIN
Option:
    -3          INT Only search primer within the INT bp to the three prime of the sequence
    -h --help       Print this help information
HELP
    exit(-1);
}