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

use DBI;
#use warnings;
#use strict;

# rajoute des espaces à droite
sub myoutstr {
$_[0]=~s{DEFAULT}{};
my $out=substr($_[0], $_[1], $_[2]);
my $len=length($out);
my $cur=0;
while ($len+$cur < $_[2]) {
$out.=" ";
$cur++;
}
return $out;
}

# rajoute des 0 à droite
sub myoutstrnumr {
$_[0]=~s{DEFAULT}{};
my $out=substr($_[0], $_[1], $_[2]);
my $len=length($out);
my $cur=0;
while ($len+$cur < $_[2]) {
$out.="0";
$cur++;
}
return $out;
}

# rajoute des 0 à gauche
sub myoutstrnuml {
$_[0]=~s{DEFAULT}{};
my $out=substr($_[0], $_[1], $_[2]);
my $len=length($out);
my $cur=0;
while ($len+$cur < $_[2]) {
$out="0".$out;
$cur++;
}
return $out;
}

$dbh = DBI->connect("dbi:Pg:dbname=test;host=localhost;port=5433", 'postgres', 'postgres', {AutoCommit => 0}) or die ("Impossible de se connecter a la base de donnees!\n");

my $sth = $dbh->prepare(<<SQL);
   select code_sq_pk, version_groupage, cmd, ghm, filler, version_rss, code_retour, finess, version_rum, rss, iep, ddn, sexe, uf, uf_autorisation, lit_autorisation, reserve1, date_entree_uf, entree, provenance, date_sortie_uf, sortie, destination, cp_residence, poids_nne_entree, sceances_nbr, das_nbr, dad_nbr, actes_nbr, dp, dr, igs2, reserve2
   from rss_2007 
SQL

$sth->execute or die "Impossible de faire la requete sur transmis!";

my %calls;
while (my @row = $sth->fetchrow_array() ) {
# Boucle par RSS
   my ($code_sq_pk, $version_groupage, $cmd, $ghm, $filler, $version_rss, $code_retour, $finess, $version_rum, $rss, $iep, $ddn, $sexe, $uf, $uf_autorisation, $lit_autorisation, $reserve1, $date_entree_uf, $entree, $provenance, $date_sortie_uf, $sortie, $destination, $cp_residence, $poids_nne_entree, $sceances_nbr, $das_nbr, $dad_nbr, $actes_nbr, $dp, $dr, $igs2, $reserve2) = @row;

# Tous les diags_s déclarés
my $sth = $dbh->prepare(<<SQL);
   select das
   from rss_diags_2007 
   where code_sq_fk='$code_sq_pk'
SQL

$sth->execute or die "Impossible de faire la requete sur rss_diags pour das!";

$diags_das_nbr=0;
while (my @row=$sth->fetchrow_array() ) {
 $das[$diags_das_nbr]=$row[0];
 $diags_das_nbr++;
}

# Tous les diags_d déclarés
my $sth = $dbh->prepare(<<SQL);
   select dad
   from rss_diags_2007 
   where code_sq_fk='$code_sq_pk'
SQL

$sth->execute or die "Impossible de faire la requete sur rss_diags pour dad!";

$diags_dad_nbr=0;
while (my @row=$sth->fetchrow_array() ) {
 $dad[$diags_dad_nbr]=$row[0];
 $diags_dad_nbr++;
}

# Tous les actes déclarés
my $sth = $dbh->prepare(<<SQL);
   select date_acte as acte_date, code_ccam as acte_code_ccam, phase as acte_phase, activite as acte_activite, ext_doc as acte_ext_doc, modificateur as acte_modificateur, remb_exceptionnel as acte_remb_exceptionnel, assoc_nonprevue as acte_assoc_nonprevue, iteration as acte_iteration
   from rss_actes_2007 
   where code_sq_fk='$code_sq_pk'
SQL

$sth->execute or die "Impossible de faire la requete sur rss_actes";

$actes_nbr=0;
while (my @row = $sth->fetchrow_array() ) {
    $acte_date[$actes_nbr]=$row[0];
    $acte_code_ccam[$actes_nbr]=$row[1];
    $acte_phase[$actes_nbr]=$row[2];
    $acte_activite[$actes_nbr]=$row[3];
    $acte_ext_doc[$actes_nbr]=$row[4];
    $acte_modificateur[$actes_nbr]=$row[5];
    $acte_remb_exceptionnel[$actes_nbr]=$row[6];
    $acte_assoc_nonprevue[$actes_nbr]=$row[7];
    $acte_iteration[$actes_nbr]=$row[8];
    $actes_nbr++;
 }

# On rearrage les dates au format français
$date_entree_uf=~ s{(.{4})-(.{2})-(.{2})}{\3\2\1};
$date_sortie_uf=~ s{(.{4})-(.{2})-(.{2})}{\3\2\1};
$ddn=~ s{(.{4})-(.{2})-(.{2})}{\3\2\1};

# On génère maintenant un RSS version 111
print myoutstr($version_groupage, 0, 2);
print myoutstr($cmd, 0, 2);
print myoutstr($ghm, 0, 4);
print myoutstr($filler, 0, 1);
print myoutstr($version_rss, 0, 3);
print myoutstrnumr($code_retour, 0, 3);
print myoutstr($finess, 0, 9);
print myoutstrnuml($version_rum, 0, 3);
print myoutstrnuml($rss, 0, 7);
print myoutstr($iep, 0, 20);
print myoutstr($ddn, 0, 8);
print myoutstr($sexe, 0, 1);
print myoutstr($uf, 0, 4);
if ($uf_autorisation =~ /\d/) {
print myoutstrnuml($uf_autorisation, 0, 2);
} else {
print "  ";
}
print myoutstr($lit_autorisation, 0, 2);
print myoutstr($reserve1, 0, 1);
print myoutstr($date_entree_uf, 0, 8);
print myoutstr($entree, 0, 1);
print myoutstr($provenance, 0, 1);
print myoutstr($date_sortie_uf, 0, 8);
print myoutstr($sortie, 0, 1);
print myoutstr($destination, 0, 1);
print myoutstrnuml($cp_residence, 0, 5);
print myoutstrnuml($poids_nne_entree, 0, 4);
print myoutstrnuml($sceances_nbr, 0, 2);

# rajouter ceux concaténés : utiliser das_tot_nbr
print myoutstrnuml($das_nbr, 0, 2);
print myoutstrnuml($dad_nbr, 0, 2);
print myoutstrnuml($actes_nbr, 0, 2);


print myoutstr($dp, 0, 8);
print myoutstr($dr, 0, 8);
if ($igs2 =~ /\d/) {
print myoutstrnuml($igs2, 0, 3); 
} else {
print "   ";
}

print myoutstr($reserve2, 0, 15);

$diags_das_cur=0;
while ($diags_das_cur < $diags_das_nbr) {
if ($das[$diags_das_cur]) {
print myoutstr($das[$diags_das_cur], 0, 8);
}
$diags_das_cur++;
}

$diags_dad_cur=0;
while ($diags_dad_cur < $diags_dad_nbr) {
if ($dad[$diags_dad_cur]) {
print myoutstr($dad[$diags_dad_cur], 0, 8);
}
$diags_dad_cur++;
}

$actes_cur=0;
while ($actes_cur < $actes_nbr) {
# On rearrange les dates au format français
$acte_date[$actes_cur]=~ s{(.{4})-(.{2})-(.{2})}{\3\2\1};
print myoutstr($acte_date[$actes_cur], 0, 8);
print myoutstr($acte_code_ccam[$actes_cur], 0, 7);
print myoutstr($acte_phase[$actes_cur], 0, 1);
print myoutstr($acte_activite[$actes_cur], 0, 1);
print myoutstr($acte_ext_doc[$actes_cur], 0, 1);
print myoutstr($acte_modificateur[$actes_cur], 0, 4);
print myoutstr($acte_remb_exceptionnel[$actes_cur], 0, 1);
print myoutstr($acte_assoc_nonprevue[$actes_cur], 0, 1);
print myoutstrnuml($acte_iteration[$actes_cur], 0, 2);
$actes_cur++;
}

# Au format dos
print "\r\n";
} # boucle par RSS
