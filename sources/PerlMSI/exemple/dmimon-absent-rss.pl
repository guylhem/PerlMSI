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
my $E_rss=RSS::readfrom("rss-2009.txt");
print $E_rss->nbr . " lignes lues : " . total_size(\$E_rss) . " bytes\n";
print $E_rss->nbr_distinct_iep . " iep uniques " . $E_rss->nbr_distinct_rss . " rss uniques\n";
#$E_rss->tolist;

print "---- Lecture du FICHCOMP MON\n";
my $E_fichcomp_mon = FICHCOMP::readfrom("fichcompmon-2009.txt");
print $E_fichcomp_mon->nbr . " lignes lues : " .  total_size(\$E_fichcomp_mon) . " bytes\n";
print $E_fichcomp_mon->nbr_distinct_iep . " iep uniques\n";
print "Valeur totale = " . $E_fichcomp_mon->FICHCOMP::value . "\n";
# FIXME :
# Use of uninitialized value in print at lib/FICHCOMP.pm line 113, <IFD>
# line 13583.
#$E_fichcomp_mon->FICHCOMP::tocsv;

# Comparaison IEP des MON et RSS
my $E_rss_distinct_iep_ref=$E_rss->distinct_iep;
my @E_rss_distinct_iep=@$E_rss_distinct_iep_ref;
my $E_fichcomp_mon_distinct_iep_ref=$E_fichcomp_mon->distinct_iep;
my @E_fichcomp_mon_distinct_iep=@$E_fichcomp_mon_distinct_iep_ref;

my ($union_ref_mon, $isec_ref_mon, $diff_ref_mon, $aonly_ref_mon, $bonly_ref_mon) = compare($E_rss_distinct_iep_ref, $E_fichcomp_mon_distinct_iep_ref);
my @mon_non_rss=@$bonly_ref_mon;
print $#mon_non_rss ." IEP du MON absent du RSS\n";
foreach (@mon_non_rss) { print $_ . ", "; }
print "\n";

my $perte_mon = $E_fichcomp_mon->value_iep($bonly_ref_mon);
print "Valeur correspondante perdue :" . $perte_mon . "\n";

# Lecture des DMI
print "---- Lecture du FICHCOMP DMI\n";
my $E_fichcomp_dmi = FICHCOMP::readfrom("fichcompdmi-2009.txt");
print $E_fichcomp_dmi->nbr . " lignes lues : " .  total_size(\$E_fichcomp_dmi) . " bytes\n";
print $E_fichcomp_dmi->nbr_distinct_iep . " iep uniques\n";
print "Valeur totale = " . $E_fichcomp_dmi->FICHCOMP::value . "\n";

# Comparaison IEP des DMI et RSS
my $E_fichcomp_dmi_distinct_iep_ref=$E_fichcomp_dmi->distinct_iep;
my @E_fichcomp_dmi_distinct_iep=@$E_fichcomp_dmi_distinct_iep_ref;

my ($union_ref_dmi, $isec_ref_dmi, $diff_ref_dmi, $aonly_ref_dmi, $bonly_ref_dmi) = compare($E_rss_distinct_iep_ref, $E_fichcomp_dmi_distinct_iep_ref);
my @dmi_non_rss=@$bonly_ref_dmi;
print $#dmi_non_rss ." IEP du DMI absent du RSS\n";
foreach (@dmi_non_rss) { print $_ . ", "; }
print "\n";

my $perte_dmi = $E_fichcomp_dmi->value_iep($bonly_ref_dmi);
print "Valeur correspondante perdue :" . $perte_dmi . "\n";
