#!/usr/bin/perl
#
#    Copyright (C) 2008,2009,2010 Guylhem
#
#    This program is free software: you can redistribute it and/or
#    modify it under the terms of the GNU Affero General Public License
#    as published by the Free Software Foundation, either version 3 of
#    the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public
#    License along with this program.  If not, see
#    <http://www.gnu.org/licenses/>.

# Complain where ooperl routines are called from
use Carp qw(croak);
# Old School Debug
use Data::Dumper;
use Date::Calc qw(Delta_Days);
use warnings;
use strict;

# Metering
my $chrono=1;

sub mystripspace {
my $out=$_[0];
$out=~s{\s+}{}g;
return $out;
}

sub thetime {
    my @months = qw(Jan Fev Mar Avr Mai Jun Jul Aou Sep Oct Nov Dec);
    my @weekDays = qw(Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi Dimanche);
    (my $second, my $minute, my $hour, my $dayOfMonth, my $month, my
$yearOffset, my $dayOfWeek, my $day, my $daylightSavings) =
localtime(time);
    my $year = 1900 + $yearOffset;
    # $frtime = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth $year
    # @ $hour:$minute:$second";
    my $thetime = sprintf "%04d-%02d-%02d @ %02d:%02d:%02d _ %s", $year, $month, $dayOfMonth, $hour, $minute, $second, $weekDays[$dayOfWeek];
    return $thetime; 
}

sub calcvalo {
my $valo=0;
my $ghm=$_[0];
my $duree=$_[1];
my $bb=$_[2];
my $bh=$_[3];
my $base=$_[4];
my $fxb=$_[5];
my $exb=$_[6];
my $exh=$_[7];

if ($bh eq 'NULL') { $bh=999999; }
if ($bb eq 'NULL') { $bb=0; }

if ($duree>$bh) {
## Borne Haute
$valo=$base;
$valo+=($duree -$bh)*$exh;
} elsif ($duree < $bb) {
## Borne Basse = 3 cas
## FIXME: rajouter sortie9 (deces)
if ($fxb eq 'NULL') {
## Borne Basse EXB
$valo=$base - ($bb - $duree) * $exb;
} else {
## Borne Basse FXB
$valo=$base-$fxb;
} # FXB|EXB
} else {
## Entre les Bornes = Normal
$valo=$base;
} # BB|BH|normal
return $valo;
}

my $file_nbr=scalar @ARGV;
my @file=@ARGV;

unless ( $file_nbr > 0 ) {
    die "Usage:\n\t$0 tarifs.tsv fichier.rss\n";
}

my $tarifs_file=$file[0];
if ($chrono) {
 print thetime() . " : lecture de " .
$tarifs_file . "\n";
}

open( TARIFS_FD, "<" . $tarifs_file ) or croak( "Ne peut lire " .  $tarifs_file . " !\n");

my $tarifs_cur = 0;
my %tarifs;
while ( my $tarifs_read = <TARIFS_FD> ) {
 chomp ($tarifs_read);
 (my $ghs_val, my $ghm_val, my $ghmlib_val, my $bb_val, my $bh_val, my $base_val, my $fxb_val, my $exb_val, my $exh_val, my $annee_val, my $deb_val, my $fin_val, my $test_val) = split (/\t/, $tarifs_read);
 $deb_val=~s{ ..:..:..}{};
 $deb_val=~s{-}{}g;
 $fin_val=~s{ ..:..:..}{};
 $fin_val=~s{-}{}g;

 my %this_tarif =('ghs' => $ghs_val, 'lib'=> $ghmlib_val, 'bb'=> $bb_val, 'bh'=> $bh_val, 'base'=> $base_val, 'fxb'=> $fxb_val, 'exb'=> $exb_val, 'exh'=> $exh_val, 'deb'=> $deb_val, 'fin'=> $fin_val, 'test'=> $test_val);
 
$tarifs{$ghm_val}{$ghs_val} = { %this_tarif};


 $tarifs_cur++;
} # while tarifs

if ($chrono) {
 print thetime() . " : $tarifs_cur lignes lues\n";
}

my $rss_file=$file[1];
if ($chrono) {
 print thetime() . " : lecture de " .
$rss_file . "\n";
}

open( RSS_FD, "<" . $rss_file ) or croak( "Ne peut lire " .  $rss_file . " !\n");

my $rum_cur = 0;
my %rss;
while ( my $rum_read = <RSS_FD> ) {
 chomp ($rum_read);
# keep the full lines
 my $ghm_val=unpack ("x2 a6", $rum_read);
 my $iep_val=unpack ("x47 a20", $rum_read);
 my $deb_val=unpack ("x92 a8", $rum_read);
 $deb_val=~s{(.{2})(.{2})(.{4})}{$3$2$1};
 my $fin_val=unpack ("x102 a8", $rum_read);
 $fin_val=~s{(.{2})(.{2})(.{4})}{$3$2$1};
 my $das_nbr_val=unpack ("x125 a2", $rum_read);
 my $dad_nbr_val=unpack ("x127 a2", $rum_read);
 my $actes_nbr_val=unpack ("x129 a2", $rum_read);
 my $offset=165+(8*$das_nbr_val)+(8*$dad_nbr_val);
 my $length=0+(26*$actes_nbr_val);
 my $actes_val=unpack ("x$offset a$length", $rum_read);

# To build a tree, must strip spaces
 my $iep=mystripspace($iep_val);

if ($iep) {
# Now build using relevant parts only
 $rss{$iep}{iep}=$iep;
 $rss{$iep}{ghm}=$ghm_val;
 $rss{$iep}{actes}.=$actes_val;

 if ($rss{$iep}{entree}) {
  if ($rss{$iep}{entree}>$deb_val) {
    $rss{$iep}{entree}=$deb_val;
  } # if date >
 } else {
    $rss{$iep}{entree}=$deb_val;
 } # if entree

 if ($rss{$iep}{sortie}) {
  if ($rss{$iep}{sortie}<$fin_val) {
    $rss{$iep}{sortie}=$fin_val;
  } # if date <
 } else {
    $rss{$iep}{sortie}=$fin_val;
 } # if sortie
} # if iep

 $rum_cur++;
} # while rss

# Now start computing values for each iep

foreach my $given_iep (keys %rss) {
  $rss{$given_iep}{duree}=Delta_Days(
substr($rss{$given_iep}{entree},0,4),
substr($rss{$given_iep}{entree},4,2),
substr($rss{$given_iep}{entree},6,2),
substr($rss{$given_iep}{sortie},0,4),
substr($rss{$given_iep}{sortie},4,2),
substr($rss{$given_iep}{sortie},6,2));
# PMSI...
if ($rss{$given_iep}{duree} ==0) { 
 $rss{$given_iep}{duree}=1; 
}

# print Dumper($tarifs{$ghm});

# Now find the relevant ghs
my $iep=$rss{$given_iep}{iep};
my $ghm=$rss{$given_iep}{ghm};
my $duree=$rss{$given_iep}{duree};
my $sortie=$rss{$given_iep}{sortie};

my $given_ghs_nbr=keys %{ $tarifs{$ghm} };

if ($given_ghs_nbr>2) {
 print "$iep : $ghm : tester pour ghs ";
    foreach my $given_ghs ( keys %{ $tarifs{$ghm} } ) {
	print $tarifs{$ghm}{$given_ghs}{ghs} . ", ";
    }
    # FIXME : faire les tests de regexp et comparer sortie a date de validite tarif deb/fin
    print "\n";
} else {
     foreach my $given_ghs ( keys %{ $tarifs{$ghm} } ) {
	my $valo=calcvalo($ghm, $duree, $tarifs{$ghm}{$given_ghs}{bb}, $tarifs{$ghm}{$given_ghs}{bh}, $tarifs{$ghm}{$given_ghs}{base}, $tarifs{$ghm}{$given_ghs}{fxb},$tarifs{$ghm}{$given_ghs}{exb},$tarifs{$ghm}{$given_ghs}{exh});
        print "$iep : $ghm $duree j = $valo Eur\n";
     }
}


} # foreach iep


if ($chrono) {
 print thetime() . " : $rum_cur lignes lues\n";
}

