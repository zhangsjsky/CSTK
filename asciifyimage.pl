#!/bin/env perl

=hey
Author: Shijian Sky Zhang
E-mail: zhangsjsky@pku.edu.cn
=cut

use 5.012;
use warnings;
use Getopt::Long;
use File::Basename;

sub usage{
    my $scriptName = basename $0;
print <<HELP;
Usage: perl $scriptName INPUT.png >log
    If INPUT isn't specified, input from STDIN
Option:
    -o --out        STR     Prefix of output image[ascii]
       --conf       FILE    The name of the generated conf[ascii.conf]
    -f --font       STR     The font ([gotham], couriernew, dosis, hero, lato,
                                        novecento, hneue, modern, proggy)
    -c --char       STR     The character set name ([full], letters, fslash, bslash, dot,
                                                    star, plus, digitals, lines, perlsigils,
                                                    punctuation1, punctuation2, punctuation3, everything, etc)
       --spaceH     STR     The horizontal spacing for space[0]
       --charH      STR     The horizontal spacing for char[0]
       --charV      STR     The vertical spacing for char[0]
    -t --transform  STR     The transform name ([default_and_space], default)
       --size       INT     The layer size[16]
       --opacity    0-1     The opacity[1]
    -r --rotates    STRs    The rotate degree for each layer
    -s --scheme     STR     The score scheme ([lato], lato.sensitive, courier)
    -h --help               Print this help information
HELP
    exit(-1);
}

my ($inFile, $rotates);
my ($outPrefix, $conf) = ('ascii', 'ascii.conf');
my ($font, $char) = ('gotham', 'full');
my ($spaceH, $charH, $charV, $size, $opacity, $transform) = (0, 0, 0, 16, 1, 'default_and_space');
my ($scheme) = ('lato');
GetOptions(
            'o|out=s'       => \$outPrefix,
            'conf=s'        => \$conf,
            'f|font=s'      => \$font,
            'c|char=s'      => \$char,
            'spaceH=s'      => \$spaceH,
            'charH=s'       => \$charH,
            'charV=s'       => \$charV,
            't|transform=s' => \$transform,
            'size=i'        => \$size,
            'opacity=s'     => \$opacity,
            'r|rotates=s'   => \$rotates,
            's|scheme=s'    => \$scheme,
            'h|help'        => sub{usage()}
        ) || usage();

$ARGV[0] = '-' unless defined $ARGV[0];
unless(-f $conf){
    open CONF, ">$conf" or die "Can't write to $conf: $!";
    print CONF <<EOF;
<input>
    fg = 000000
    bg = ffffff
    fontdir = font/$font
    
    # Regular expressions (CSV list ok) used to pass and/or fail
    #fontrx_pass = Book
    #fontrx_fail = Ita
    #maxw = 200
    #maxh = 200
</input>

<output>
    svg = yes
    #input_overlay_opacity = 0
    #individual_layers = no
    
    # create images of individual characters in glyphdir directory
    #write_glyphs = no
    #glyphdir = glyphs
</output>
    
# Sets of characters from which the ASCII form will be created
<charactersets>
EOF
    if($char eq "perlsigils"){
        print CONF <<EOF;
    <characterset perlsigils>
        eval = (qw(\$ @ % *))
    </characterset>
EOF
    }elsif($char =~ /,/){
        my @chars = split ',', $char;
        print CONF <<EOF;
    <characterset custom>
        eval = (qw(@chars))
    </characterset>
EOF
    $char = 'custom'
    }elsif(-f $char){
        print CONF <<EOF;
    <characterset $char>
        file = $char
        contiguous = yes
        contiguous_in_font = no
    </characterset>
EOF
    }
    print CONF <<EOF;
    # some default character sets (letters, digits, punctuation, etc)
    <<include etc/character.sets.conf>>
</characters>
    
# Transformations applied to the character sets.
<transforms>
    <<include etc/transforms.conf>>
</transforms>
    
# An image can be rendered in multiple layers of ASCII, each with its own character set, transform, size and color.
<layers>
    char_h_spacing  = $charH
    char_v_spacing  = $charV
    space_h_spacing = $spaceH
    #fg = 000000
    #fga = 255
    characterset_name = $char
    transform_name = $transform
    size = $size
    opacity = $opacity
EOF
    if(defined $rotates){
        my @rotates = split ',', $rotates;
        for(my $i = 0; $i <= $#rotates; $i++){
            print CONF <<EOF;
    <layer>
        rotate = $rotates[$i]
    </layer>
EOF
        }
    }else{
        print CONF <<EOF;
    <layer>
    </layer>
EOF
    }
    print CONF <<EOF;
</layers>
    
################################################################
# Parameters that define how a character is scored when matched against a section of the image.
<score>
    scheme_name = $scheme
    
    # image and glyph signal s=[0,1] is modified by s^t, where t is the tone curve parameter
    #image_tone_curve = 1
    #glyph_tone_curve = 1

    # when image and glyph are compared, signal lower than cutoff is considered to be zero
    #image_signal_cutoff  = 0
    #glyph_signal_cutoff  = 0

    <<include etc/cutoffs.conf>>
    <<include etc/schemes.conf>>
</score>

<<include etc/housekeeping.conf>>
EOF
}
`asciifyimage -conf $conf -in $ARGV[0] -out $outPrefix >asciifyimage.log 2>asciifyimage.err`;
