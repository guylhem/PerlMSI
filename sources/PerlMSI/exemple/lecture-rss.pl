#!/usr/bin/perl

## Perl Modules

#use DBI;			   # databases
#use Benchmark;			   # timethis (100, "somesub()");
use Data::Dumper;		   # For good old debugging
use Devel::Size qw(total_size);    # check memory use
use warnings;                      # warn about questionnable syntax
use strict;                        # because I'm new

## PerlMSI Modules

use lib qw{./lib};
use FILEREAD;
use FICHCOMP;
use VIDHOSP;
use RSS;
use RSA;

print "---- Lecture du fichier RSS\n";
my $E_rss_2009=RSS::readfrom("rss-2009.txt");
print $E_rss_2009->nbr . " lignes lues : " . total_size(\$E_rss_2009) . " bytes\n";
print $E_rss_2009->nbr_distinct_iep . " iep uniques " . $E_rss_2009->nbr_distinct_rss . " rss uniques\n";
#$E_rss_2009->tolist;

