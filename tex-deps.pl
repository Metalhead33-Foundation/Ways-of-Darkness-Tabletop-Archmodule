#!/bin/env perl

use strict;

my $texfile = pop @ARGV;

open my $FH, '<', $texfile;

print "$texfile.part: $texfile";

my @exts = ("jpg", "jpeg","png");

while (<$FH>) {
    if(/\input{([^}]+)}/) {
        print " ${1}.part";
    }
    if(my @matches = m/\import{[^}]+}{([^}]+)}/g) {
        print " ".join(" ",@matches);
    }
    if(/\includegraphics{([^}]+)}/) {
        my $found = 0;
        foreach my $ext ( @exts ) {
            if ( -e "images/${1}.$ext" ) {
                print " images/${1}.${ext}";
                $found = 1;
            }
        }
        if(!$found) {
            print " images/${1}"
        }
    }
}

print "\n"
