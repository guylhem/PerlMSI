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

use warnings;
use strict;
#use Data::Dumper; #uncomment for debugging
unless (scalar @ARGV == 1){
   die "Usage:\n\t$0 RSS.grp\n";
}

my $infile = $ARGV[0];

open IFD, $infile or die "Can't read input file"; 
while (<IFD>) 
{ 
# commencer par lire la version de RSS pour parser différemment selon
# les besoins

/(.{2})(.{2})(.{4})(.{1})(.{3})(.*)/;
my $version_groupage=$1;
my $cmd=$2;
my $ghm=$3;
my $filler=$4;
my $version_rss=$5;
my $reste1=$6;

if ($version_rss == 111) {
$reste1=/(.{3})(.{9})(.{3})(.{7})(.{20})(.{8})(.{1})(.{4})(.{2})(.{2})(.{1})(.{8})(.{1})(.{1})(.{8})(.{1})(.{1})(.{5})(.{4})(.{2})(.{2})(.{2})(.{2})(.{8})(.{8})(.{3})(.{15})(.*)/; 
my $retour=$1;
my $finess=$2;
my $rss=$3;
my $iep=$4;
my $ddn=$5;
my $sexe=$6;
my $uf=$7;
my $uf_type=$8;
my $lit_autorisation=$9;
my $zone=$10;
my $date_entree_uf=$11;
my $entree=$12;
my $sortie=$13;
my $destination=$14;
my $cp_residence=$15;
my $poids_nne_entree=$16;
my $sceances_nbr=$17;
my $das_nbr=$18;
my $dad_nbr=$19;
my $actes_nbr=$20;
my $dp=$21;
my $dr=$22;
my $igs2=$23;
my $reserve=$24;
my $reste=$25;
# Maintenant on parse le reste selon le nbr DAS/DAD/ACTES
# fixme : mal aligné
print "IEP: " . $iep . ", CMD=". $cmd . ", GHM=" . $ghm . ", cP=" .  $cp_residence . "\n";
} else {
print "Version de RSS non gérée !";
exit (-1);
}


#($var, $i)=split /\d{3}/, $7; 
#$var=".".$i; 
#printf "floating number $7 is $var\n"; 
} 
close IFD; 
