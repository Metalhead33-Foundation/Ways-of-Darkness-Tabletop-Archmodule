#!/bin/env perl

use strict;

my $output = shift @ARGV;
my $depsTxt = "";

sub escape_space {
    $_ = shift;
    s/ /\\ /g;
    return $_;
}

while ( @ARGV > 0 ) {
    my $texfile = shift @ARGV;

    open my $FH, '<', $texfile;

    $depsTxt = $depsTxt."$texfile.part: $texfile";

    my @exts = ("jpg", "jpeg","png");
    
    while (<$FH>) {
        if(/\input\{([^}]+)\}/) {
            my $inclusion = "${1}.part";
            $inclusion =~ s/ /\\ /g;
            $depsTxt = "$depsTxt $inclusion";
            
        }
        if(my @matches = m/\import\{[^}]+}{([^}]+)\}/g) {
            @matches = map { escape_space $_ } @matches;
            $depsTxt = $depsTxt." ".join(" ",@matches);
        }
        if(/\includegraphics\{([^}]+)\}/) {
            my $found = 0;
            foreach my $ext ( @exts ) {
                my $graphic = "images/$1.$ext";
                $graphic =~ s/ /\\ /g;
                if ( -e $graphic ) {
                    $depsTxt = "$depsTxt $graphic";
                    $found = 1;
                }
            }
            if(!$found) {
                $depsTxt = $depsTxt." \"images/${1}\""
            }
        }
    }
    
    close($FH);

#     print qq{\n\t\@echo "Analyzing \$(subst .part,,\$\@)"\t\@cat \$<\n\t\@echo \$^\n\t\@touch \$\@\n};
    $depsTxt = $depsTxt."\n";
}

if (! -e $output) {
    open my $depH, '>', $output;
    close $depH;
}

open my $depH, '<', $output;
read $depH, my $origTxt, -s $depH;
close $depH;

if ( $origTxt ne $depsTxt ) {
    print "Updating dependencies\n";
    open my $depH, '>', $output;
    print $depH $depsTxt;
    close $depH;
}
