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

sub euro {
$_[0]=~ s/\d{1,3}(?=(\d{3})+(?!\d))/$&'/g;
return $_[0] . " Eur";
}

sub q0 {
$sth=$dbh->prepare($_[0]) or die "Probleme: " . $dbh->errstr . "\n";
$sth->execute or die "Probleme: " . $dbh->errstr . "\n";
$result=$sth->fetchrow_arrayref;
$sth->finish;
if ($debug) {
print $result->[0] . "\n";
}
return ($result->[0]);
}

sub thetime {
    @months = qw(Jan Fev Mar Avr Mai Jun Jul Aou Sep Oct Nov Dec);
    @weekDays = qw(Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi Dimanche);
    ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $day, $daylightSavings) = localtime(time);
    $year = 1900 + $yearOffset;
    # $frtime = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth $year @ $hour:$minute:$second";
    $thetime = sprintf "%04d-%02d-%02d @ %02d:%02d:%02d _ %s", $year, $month, $dayOfMonth, $hour, $minute, $second, $weekDays[$dayOfWeek];
    return $thetime; 
}

sub mysubstr {
    my $out = substr( $_[0], $_[1], $_[2] );
    $out =~ s/ //g;
    if ( length($out) == 0 ) { $out = undef; }
    return $out;
}

unless ( scalar @ARGV ==  6) {
# Soit on charge le rsa, soit on laisse ce soin a parse-rsa ; mieux vaudrait utiliser le fichier .tra et le diff
    print "Il faut 1 suffixe et 5 fichiers en arguments.\nUsage:\n\t$0 fichier_comp_log fichier_dif_txt fichier_tra_txt fichier_ctl_mt2a_detail.log fichier_rsa suffixe\n";
    die "\nExemple:\n\t $0 *comp.log.txt *dif.txt *tra.txt ctl_mt2a.detail* *rsa essai2\n"
}

if ($chrono) {
print thetime() . " - debut du traitement\n";
}

# Sert a identifier quels MON, DMI et PO3 ont un pb informatique (longueur incorrecte) ou administratif (date, iep absent...)
$complog = $ARGV[0];
# Sert a resumer quels RSS ont change de GHM
$difftxt = $ARGV[1];
# Sert a relier numero sequentiel de RSA, RSS, code_sq_pk, IEP date_sortie GHM
$tratxt = $ARGV[2];
# Sert a identifier quels RSS/IEP/GHM sont rejetes et pourquoi (chainage, erreur codage, non pris en charge CPAM)
$mt2adt = $ARGV[3];
# Sert pour avoir les GHS, durée, mode de sortie et dates de fin de sejour pour la valorisation
$ghsrsa = $ARGV[4];
# Pour creer les tables
$suffixe= $ARGV[5];

# On va retourner des stats (kEur, nb iep/ipp regrp, nb cmd 90, nb das) et les mettre dans la base de donnee

$dbh = DBI->connect("dbi:Pg:dbname=test;host=localhost;port=5432", 'postgres', 'postgres', {AutoCommit => 0})
or die ("Impossible de se connecter a la base de donnees:" . $dbh->errstr);

###################### LE FICHIER DIFF
if ($chrono) {
print thetime() . " - lecture du fichier " . $difftxt . "\n";
}


# Supprimer de suite la table si elle existe
$dbh->do("DROP TABLE IF EXISTS evaluation_diff_$suffixe CASCADE");
$dbh->commit;
# Puis creer normalement la table
$sql="CREATE TABLE evaluation_diff_$suffixe (rss bigint, ghm_in char(7), code_in char(4), ghm_out char(7), code_out char(4))";
$sth=$dbh->prepare($sql);
$sth->execute or die "Ne peut creer la table evaluation_diff_$suffixe!";
$sth->finish;

open( DFD, "<$difftxt" ) or die( "Ne peut lire " . $difftxt . " !\n" );

$diff_line_nbr = 0;
$sth = $dbh->prepare("INSERT INTO evaluation_diff_$suffixe (rss, ghm_in, code_in, ghm_out, code_out) VALUES (?, ?, ?, ?, ?)");

while ( $diff_line = <DFD> ) {
$diff_rss      = mysubstr( $diff_line, 0, 7);
$diff_ghm_in   = mysubstr( $diff_line, 7, 6);
$diff_code_in  = mysubstr( $diff_line, 13, 3);
$diff_ghm_out  = mysubstr( $diff_line, 16, 6);
$diff_code_out = mysubstr( $diff_line, 22, 3);

if ($debug) {
print "$diff_rss, '$diff_ghm_in', $diff_code_in, '$diff_ghm_out', $diff_code_out\n";
}

$sth->execute($diff_rss, $diff_ghm_in, $diff_code_in, $diff_ghm_out, $diff_code_out) or die "Impossible de rajouter $diff_rss dans evaluation_diff_$suffixe !";
$sth->finish();

$diff_line_nbr++;
} # while diff_line

if ($chrono) {
print thetime() . " - chargement du fichier " . $difftxt . "\n";
}

$dbh->commit;
$dbh->do("CREATE INDEX evaluation_diff_" . $suffixe . "_rss_idx on evaluation_diff_$suffixe(rss)");
if ($chrono) {
print thetime() . " - fermeture du fichier " . $difftxt . "\n";
}

close (DFD);

################### LE FICHIER TRA 
if ($chrono) {
print thetime() . " - lecture du fichier " . $tratxt . "\n";
}


# Supprimer de suite la table si elle existe
$dbh->do("DROP TABLE IF EXISTS evaluation_tra_$suffixe CASCADE");
$dbh->commit;
# Puis creer normalement la table
$sql="CREATE TABLE evaluation_tra_$suffixe (rsa_sq bigint, rss bigint, code_sq bigint, iep int, date_debut_hospit timestamp, ghm_mis char(7))";
$sth=$dbh->prepare($sql);
$sth->execute or die "Ne peut creer la table evaluation_tra_$suffixe!";
$sth->finish;

open( TFD, "<$tratxt" ) or die( "Ne peut lire " . $tratxt . " !\n" );

$tra_line_nbr = 0;
$sth = $dbh->prepare("INSERT INTO evaluation_tra_$suffixe (rsa_sq, rss, code_sq, iep, date_debut_hospit, ghm_mis) VALUES (?, ?, ?, ?, ?, ?)");

while ( $tra_line = <TFD> ) {
$tra_rsa_sq   = mysubstr( $tra_line, 0, 10);
$tra_rss      = mysubstr( $tra_line, 10, 7);
$tra_code_sq  = mysubstr( $tra_line, 17, 10);
$tra_iep      = mysubstr( $tra_line, 27, 7);
$tra_debut    = mysubstr( $tra_line, 47, 8);
$tra_ghm_mis  = mysubstr( $tra_line, 55, 6);

# On rearrage la date
$tra_debut =~ s{(.{2})(.{2})(.{4})}{\3\2\1};

if ($debug) {
print "$tra_rsa_sq, $tra_rss, $tra_code_sq, $tra_iep, $tra_debut, $tra_ghm_mis\n";
}

$sth->execute($tra_rsa_sq, $tra_rss, $tra_code_sq, $tra_iep, $tra_debut, $tra_ghm_mis) or die "Impossible de rajouter $tra_rss dans evaluation_diff_$suffixe !";
$sth->finish();

$tra_line_nbr++;
} # while tra_line

if ($chrono) {
print thetime() . " - chargement du fichier " . $tratxt . "\n";
}

$dbh->commit;
#$dbh->do("CREATE INDEX evaluation_tra_" . $suffixe . "_ghm_idx on evaluation_tra_$suffixe(ghm_mis)");
if ($chrono) {
print thetime() . " - fermeture du fichier " . $tratxt . "\n";
}

close (TFD);

###################### LE FICHIER MT2A
if ($chrono) {
print thetime() . " - lecture du fichier " . $mt2adt . "\n";
}


# Supprimer de suite la table si elle existe
$dbh->do("DROP TABLE IF EXISTS evaluation_mt2a_$suffixe CASCADE");
$dbh->commit;
# Puis creer normalement la table
$sql="CREATE TABLE evaluation_mt2a_$suffixe (erreur smallint, rss bigint, iep bigint, ghm_potentiel char(7))";
$sth=$dbh->prepare($sql);
$sth->execute or die "Ne peut creer la table evaluation_mt2a_$suffixe!";
$sth->finish;

open( MFD, "<$mt2adt" ) or die( "Ne peut lire " . $mt2adt . " !\n" );

$mt2a_line_nbr = 0;
$sth = $dbh->prepare("INSERT INTO evaluation_mt2a_$suffixe (erreur, rss, iep, ghm_potentiel) VALUES (?, ?, ?, ?)");

# On saute la premiere ligne;
$mt2a_line = <MFD>;

while ( $mt2a_line = <MFD> ) {
 @parts=split(";", $mt2a_line);
 $mt2a_erreur=$parts[0];
 $mt2a_rss=$parts[1];
 $mt2a_iep=$parts[2];
 $mt2a_ghm_potentiel=$parts[3];
 $mt2a_erreur=~ s{"}{}g;
 $mt2a_rss=~ s{"}{}g;
 $mt2a_iep=~ s{"}{}g;
 $mt2a_ghm_potentiel=~ s{"}{}g;
 $mt2a_ghm_potentiel=~ s{\r}{}g;
 $mt2a_ghm_potentiel=~ s{\n}{}g;

if ($debug) {
print "$mt2a_erreur, $mt2a_rss, $mt2a_iep, $mt2a_ghm_potentiel\n";
}

$sth->execute($mt2a_erreur, $mt2a_rss, $mt2a_iep, $mt2a_ghm_potentiel) or die "Impossible de rajouter $mt2a_rss dans evaluation_mt2a_$suffixe !";
$sth->finish;

$mt2a_line_nbr++;
} # while mt2a_line

if ($chrono) {
print thetime() . " - chargement du fichier " . $mt2adt . "\n";
}

$dbh->commit;
$dbh->do("CREATE INDEX evaluation_mt2a_" . $suffixe . "_rss_idx on evaluation_mt2a_$suffixe(rss)");
if ($chrono) {
print thetime() . " - fermeture du fichier " . $mt2adt . "\n";
}

close (MFD);


###################### LE FICHIER RSA
if ($chrono) {
print thetime() . " - lecture du fichier " . $ghsrsa . "\n";
}


# Supprimer de suite la table si elle existe
$dbh->do("DROP TABLE IF EXISTS evaluation_ghsrsa_$suffixe CASCADE");
$dbh->commit;
# Puis creer normalement la table
$sql="CREATE TABLE evaluation_ghsrsa_$suffixe (rsa bigint, ghm_in char(7), ghm_out char(7), ghs int, mode_sortie smallint, annee_sortie smallint, mois_sortie smallint, duree smallint, nbdas smallint)";
$sth=$dbh->prepare($sql);
$sth->execute or die "Ne peut creer la table evaluation_ghsrsa_$suffixe!";
$sth->finish;

open( RFD, "<$ghsrsa" ) or die( "Ne peut lire " . $ghsrsa . " !\n" );

$ghsrsa_line_nbr = 0;
$sth = $dbh->prepare("INSERT INTO evaluation_ghsrsa_$suffixe (rsa, ghm_in, ghm_out, ghs, mode_sortie, annee_sortie, mois_sortie, duree, nbdas) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");

# On saute la premiere ligne;
$ghsrsa_line = <RFD>;

while ( $ghsrsa_line = <RFD> ) {
$ghsrsa_rsa=mysubstr( $ghsrsa_line, 12,  10 );
$ghsrsa_ghm_in=mysubstr( $ghsrsa_line, 30,  6 );
$ghsrsa_ghm_out=mysubstr( $ghsrsa_line, 41,  6 );
$ghsrsa_ghs=mysubstr( $ghsrsa_line, 88,  4 );
$ghsrsa_mode_sortie=mysubstr( $ghsrsa_line, 67,  1 );
$ghsrsa_annee_sortie=mysubstr( $ghsrsa_line, 63,  4 );
$ghsrsa_mois_sortie=mysubstr( $ghsrsa_line, 61,  2 );
$ghsrsa_duree=mysubstr( $ghsrsa_line, 70,  4 );
# Uniquement si rsa version 214
$ghsrsa_nbdas=mysubstr( $ghsrsa_line, 171, 2 );
if ($debug) {
print "$ghsrsa_rsa, $ghsrsa_ghm_in, $ghsrsa_ghm_out, $ghsrsa_ghs, $ghsrsa_mode_sortie, $ghsrsa_annee_sortie, $ghsrsa_mois_sortie, $ghsrsa_duree, $ghsrsa_nbdas\n";
}

$sth->execute($ghsrsa_rsa, $ghsrsa_ghm_in, $ghsrsa_ghm_out, $ghsrsa_ghs, $ghsrsa_mode_sortie, $ghsrsa_annee_sortie, $ghsrsa_mois_sortie, $ghsrsa_duree, $ghsrsa_nbdas) or die "Impossible de rajouter $ghsrsa_rsa dans evaluation_ghsrsa_$suffixe !";
$sth->finish;

$ghsrsa_line_nbr++;
} # while ghsrsa_line

if ($chrono) {
print thetime() . " - chargement du fichier " . $ghsrsa . "\n";
}

$dbh->commit;
$dbh->do("CREATE INDEX evaluation_ghsrsa_" . $suffixe . "_rsa_idx on evaluation_ghsrsa_$suffixe(rsa)");
$dbh->do("CREATE INDEX evaluation_ghsrsa_" . $suffixe . "_ghs_idx on evaluation_ghsrsa_$suffixe(ghs)");
if ($chrono) {
print thetime() . " - fermeture du fichier " . $ghsrsa . "\n";
}

close (RFD);


################### Maintenant on fait les calculs

if ($chrono) {
print thetime() . " - debut des calculs\n";
}

$diff_regroupes=q0("select count (*) as regroupes from evaluation_diff_$suffixe");
$diff_cmd90=q0("select count (ghm_out) as cmd90 from evaluation_diff_$suffixe where ghm_out like '%90%'");
$diff_noncmd90=q0("select count (ghm_out) as noncmd90 from evaluation_diff_$suffixe where ghm_out not like '%90%'");

$diff_ipp=q0("select count (distinct ipp) as ipp from evaluation_diff_$suffixe, evaluation_tra_$suffixe, a_ipp_iep where evaluation_tra_$suffixe.rss=evaluation_diff_$suffixe.rss and a_ipp_iep.iep=evaluation_tra_$suffixe.iep");
$tra_ghms=q0("select count (distinct ghm_mis) from evaluation_tra_$suffixe");
$tra_iep=q0("select count (distinct iep) from evaluation_tra_$suffixe");
$tra_ipp=q0("select count (distinct ipp) as ipp from evaluation_tra_$suffixe, a_ipp_iep where evaluation_tra_$suffixe.iep=a_ipp_iep.iep");
$mt2a_nbr=q0("select count (distinct rss) from evaluation_mt2a_$suffixe");
$mt2a_ipp=q0("select count (distinct ipp) as ipp from evaluation_mt2a_$suffixe, a_ipp_iep where evaluation_mt2a_$suffixe.iep=a_ipp_iep.iep");
# FIXME : A modifier pour utiliser le GHS pour etre plus precis
$mt2a_chainage=q0("select count (distinct rss) from evaluation_mt2a_$suffixe where erreur=1");
$mt2a_chainage_perte=q0("select sum(tarifghs) from evaluation_mt2a_$suffixe, evaluation_tra_$suffixe, a_tarif_jo where ghm=ghm_potentiel and evaluation_tra_$suffixe.rss=public.evaluation_mt2a_$suffixe.rss and date_debut_hospit>datedebut and date_debut_hospit<datefin  and erreur=1");
$mt2a_codage=q0("select count (distinct rss) from evaluation_mt2a_$suffixe where erreur=2");
$mt2a_codage_perte=q0("select sum(tarifghs) from evaluation_mt2a_$suffixe, evaluation_tra_$suffixe, a_tarif_jo where ghm=ghm_potentiel and evaluation_tra_$suffixe.rss=public.evaluation_mt2a_$suffixe.rss and date_debut_hospit>datedebut and date_debut_hospit<datefin  and erreur=2");
$mt2a_cpam=q0("select count (distinct rss) from evaluation_mt2a_$suffixe where erreur=3");
$mt2a_cpam_perte=q0("select sum(tarifghs) from evaluation_mt2a_$suffixe, evaluation_tra_$suffixe, a_tarif_jo where ghm=ghm_potentiel and evaluation_tra_$suffixe.rss=public.evaluation_mt2a_$suffixe.rss and date_debut_hospit>datedebut and date_debut_hospit<datefin  and erreur=3");

if ($chrono) {
print thetime() . " - fin des calculs\n";
}


print "\n\n ------------------------------ Resultats ----------------------------- \n\n";
print "Fichier diff : $diff_line_nbr lignes lues\n";
print "\t$diff_regroupes regroupements effectues sur $diff_ipp patients uniques\n";
print "\t\tdont $diff_cmd90 en CMD90\n";
print "\t\tdont $diff_noncmd90 hors CMD90\n";
print "\n";
print "Fichier tra : $tra_line_nbr lignes lues\n";
print "\t$tra_iep sejours valorises sur $tra_ipp patients uniques\n";
print "\n";
print "Fichier mt2a : $mt2a_line_nbr lignes lues\n";
print "\t$mt2a_nbr sejours non valorises sur $mt2a_ipp patients uniques\n";
print "\t\tdont $mt2a_chainage sejours par erreur de chainage, perte estimee: -" . euro($mt2a_chainage_perte) . "\n";
print "\t\tdont $mt2a_codage sejours par erreur de codage, perte estimee: -". euro($mt2a_codage_perte) . "\n";
print "\t\tdont $mt2a_cpam sejours par non prise en charge cpam, perte estime: -" . euro($mt2a_cpam_perte) . "\n";

print "\n\n ------------------------------ Valorisation ----------------------------- \n\n";

print "Calcul en utilisant le GHS, l'EXH, les bornes et les tarifs publies au JO en vigueur lors de la sortie du patient.";

# Supprimer de suite la table si elle existe
$dbh->do("DROP TABLE IF EXISTS evaluation_valo_$suffixe CASCADE");
$dbh->commit;
# Puis creer normalement la table
$sql="CREATE TABLE evaluation_valo_$suffixe as
 select rsa, ghm_out, g1.ghs_lib as ghm_out_libelle, ghm_in, t1.libelle as ghm_in_libelle, evaluation_ghsrsa_$suffixe.ghs, tarif_ghs,
case when duree < bornebasse and mode_sortie = 9 then tarif_ghs*1.2 end as totdcd,
case when duree < bornebasse and mode_sortie != 9 then (tarif_ghs/2)*1.2 end as totmin,
case when duree < bornehaute and duree > bornebasse then tarif_ghs*1.2 end as totnorm,
case when duree > bornehaute then (tarif_ghs+tarif_exh*(duree-bornehaute))*1.2 end as totmax,
duree
from evaluation_ghsrsa_$suffixe, a_tarif_jo t1, ab_ghm10c g1
where not ghm_in=ghm_out and ghm_in=g1.ghm and t1.ghs=evaluation_ghsrsa_$suffixe.ghs and t1.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and t1.datedebut<date(annee_sortie||' '||mois_sortie|| ' 01')";

$sth=$dbh->prepare($sql);
$sth->execute or die "Ne peut creer la table evaluation_valo_$suffixe!";
$sth->finish;

$dbh->do("DROP TABLE IF EXISTS evaluation_valoghms_$suffixe CASCADE");
$dbh->commit;
$sql="CREATE TABLE evaluation_valoghms_$suffixe as select ghm_out, ghm_out_libelle, ghm_in, ghm_in_libelle, ghs, tarif_ghs, totnorm, totdcd, totmin, totmax, count(*) as nbr
from evaluation_valo_$suffixe
group by ghm_out, ghm_out_libelle, ghm_in, ghm_in_libelle, ghs, tarif_ghs, totnorm, totdcd, totmin, totmax";
$sth=$dbh->prepare($sql);
$sth->execute or die "Ne peut creer la table evaluation_valoghms_$suffixe!";
$sth->finish;
$dbh->commit;

$totnorm=q0("select cast (sum (totnorm) as int) from evaluation_valo_$suffixe");
$totdcd=q0("select cast (sum (totdcd) as int) from evaluation_valo_$suffixe");
$totmin=q0("select cast (sum (totmin) as int) from evaluation_valo_$suffixe");
$totmax=q0("select cast (sum (totmax) as int) from evaluation_valo_$suffixe");

print "\n\n";
print "Valorisation totale: " . euro($totnorm+$totdcd+$totmin+$totmax) . "\n";
print "\t dont sejours entre les bornes: " . euro($totnorm) . "\n";
print "\t dont sejours en deca de la borne basse: " . euro($totmin) . "\n";
print "\t dont sejours au dela de la borne haute: " . euro($totmax) . "\n";
print "\t dont sejours de patients decedes: " . euro($totdcd) . "\n";

$dbh->disconnect();
if ($chrono) {
print thetime() . " - Fin du traitement\n";
}

