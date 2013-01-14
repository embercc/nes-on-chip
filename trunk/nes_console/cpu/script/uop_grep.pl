#!/usr/bin/perl

use strict;

my @lines;

chomp(@lines = <>);

##for my $num (0..9, qw /A a B b C c D d E e F f/){
##    for my $line (@lines){
##        if($line =~ m/^[0-9](${num}).+/){
##            print $line . "\n";
##        }
##    }
##    print "\n";
##}

for my $line (@lines){
    if($line =~ m/^0.+/){
        print $line . "\n";
    }
}
