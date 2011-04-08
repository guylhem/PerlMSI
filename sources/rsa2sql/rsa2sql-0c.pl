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
#use Data::Dumper; #uncomment for debugging

sub mysubstr {
my $out=substr($_[0], $_[1], $_[2]);
$out=~s/ //g;
if (length ($out)== 0) { $out="DEFAULT"; }
return $out;
}

unless (scalar @ARGV == 2){
   die "Usage:\n\t$0 RSA.grp annee\n";
}

$infile = $ARGV[0];
$annee = $ARGV[1];

open (IFD, "<$infile") or die ("Can't read input file " . $infile . " !\n"); 

$line_cur=0;
	while ($rsa_line=<IFD>) {
	# commencer par lire la version de RSS pour parser différemment

	$finess=mysubstr($rsa_line, 0, 9);
	$version_rsa=mysubstr($rsa_line, 9,3);

	if ($version_rsa == 214) {
		if ($schema_sql != 1) {
print "drop table rsa_$annee cascade;
drop table rsa_diags_$annee cascade;
drop table rsa_actes_$annee cascade;
drop table rsa_rum_$annee cascade;

create table rsa_$annee (
 code_sq_pk SERIAL PRIMARY KEY,
 annee smallint,
 version_rsa smallint,
 rsa bigint,
 version_rss smallint,
 sequence_tarif smallint,
 version_lu smallint,
 ghm_lu char(6),
 retour_lu smallint,
 version_mis smallint,
 ghm_mis char(6),
 retour_mis smallint,
 nb_rum smallint,
 age_annee smallint,
 age_jour smallint,
 sexe smallint,
 entree smallint,
 provenance smallint,
 annee_sortie smallint,
 mois_sortie smallint,
 sortie smallint,
 destination smallint,
 type smallint,
 duree smallint,
 cp_residence smallint,
 poids_nne_entree smallint,
 nbr_sceances smallint,
 igs2 smallint,
 ghs int,
 depassement_bornehaute int,
 inferieur_bornebasse smallint,
 ghs_forfait_dialyse int,
 supplement_hemodialyse_hs smallint,
 supplement_entraitement_dialyseperit_auto_hs smallint,
 supplement_entraitement_dialyseperit_ambu_hs smallint,
 supplement_entraitement_hemodialyse_hs smallint,
 sceances_avant_sros smallint,
 nbr_actes_ghm_24Z05Z_ou_28Z11Z smallint,
 nbr_actes_ghm_24Z06Z_ou_28Z12Z smallint,
 nbr_actes_ghm_24Z07Z_ou_28Z13Z smallint,
 supplement_caisson_hyperbare smallint,
 type_prelevement_organe smallint,
 supplement_sra smallint,
 supplement_rea smallint,
 supplement_si_de_rea smallint,
 supplement_stf smallint,
 supplement_ssc smallint,
 supplement_src smallint,
 supplement_nn1 smallint,
 supplement_nn2 smallint,
 supplement_nn3 smallint,
 supplement_rep smallint,
 lit_dedie_palliatif smallint,
 dp char(7),
 dr char(7),
 nb_diags smallint,
 nb_actes smallint
);

create table rsa_rum_$annee (
 code_sq_fk INT,
 rsa_f bigint,
 type_rum smallint,
 duree_uf smallint,
 valorisation_rea smallint, 
 valorisation_partielle smallint,
 position_dp char(2),
 FOREIGN KEY (code_sq_fk) REFERENCES rsa_$annee (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table rsa_diags_$annee (
 code_sq_fk INT,
 rsa_f bigint,
 das char(9),
 FOREIGN KEY (code_sq_fk) REFERENCES rsa_$annee (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);

create table rsa_actes_$annee (
 code_sq_fk INT,
 rsa_f bigint,
 delai smallint,
 code_ccam char(8),
 phase smallint,
 activite smallint,
 ext_doc smallint,
 modificateur char(9),
 remb_exceptionnel char(9),
 assoc_nonprevue smallint,
 iteration smallint,
 FOREIGN KEY (code_sq_fk) REFERENCES rsa_$annee (code_sq_pk) ON DELETE CASCADE ON UPDATE CASCADE
);
";
$schema_sql=1;
}
		$rsa=mysubstr($rsa_line, 12, 10);
		$version_rss=mysubstr($rsa_line, 22, 3);
		$sequence_tarif=mysubstr($rsa_line, 25, 3);
		$version_lu=mysubstr($rsa_line, 28, 2);
		$ghm_lu=mysubstr($rsa_line, 30, 6);
		$retour_lu=mysubstr($rsa_line, 36, 3);
		$version_mis=mysubstr($rsa_line, 39, 2);
		$ghm_mis=mysubstr($rsa_line, 41, 6);
		$retour_mis=mysubstr($rsa_line, 47, 3);
		$nb_rum=mysubstr($rsa_line, 50, 2);
		$age_annee=mysubstr($rsa_line, 52, 3);
		$age_jour=mysubstr($rsa_line, 55, 3);
		$sexe=mysubstr($rsa_line, 58, 1);
		$entree=mysubstr($rsa_line, 59, 1);
		$provenance=mysubstr($rsa_line, 60, 1);
		$mois_sortie=mysubstr($rsa_line, 61, 2);
		$annee_sortie=mysubstr($rsa_line, 63, 4);
		$sortie=mysubstr($rsa_line, 67, 1);
		$destination=mysubstr($rsa_line, 68, 1);
		$type=mysubstr($rsa_line, 69, 1);
		$duree=mysubstr($rsa_line, 70, 4);
		$cp_residence=mysubstr($rsa_line, 74, 5);
		$poids_nne_entree=mysubstr($rsa_line, 79, 4);
		$nbr_sceances=mysubstr($rsa_line, 83, 2);
		$igs2=mysubstr($rsa_line, 85, 3);
		$ghs=mysubstr($rsa_line, 88, 4);
		$depassement_bornehaute=mysubstr($rsa_line, 92, 4);
		$inferieur_bornebasse=mysubstr($rsa_line, 96, 1);
		$ghs_forfait_dialyse=mysubstr($rsa_line, 97, 4);
		$supplement_hemodialyse_hs=mysubstr($rsa_line, 101, 3);
		$supplement_entraitement_dialyseperit_auto_hs=mysubstr($rsa_line, 104, 3);
		$supplement_entraitement_dialyseperit_ambu_hs=mysubstr($rsa_line, 107, 3);
		$supplement_entraitement_hemodialyse_hs=mysubstr($rsa_line, 110, 3);
		$sceances_avant_sros=mysubstr($rsa_line, 113, 2);
		$nbr_actes_ghm_24Z05Z_ou_28Z11Z=mysubstr($rsa_line, 115, 3);
 		$nbr_actes_ghm_24Z06Z_ou_28Z12Z=mysubstr($rsa_line, 118, 3);
 		$nbr_actes_ghm_24Z07Z_ou_28Z13Z=mysubstr($rsa_line, 121, 3);
 		$supplement_caisson_hyperbare=mysubstr($rsa_line, 124, 3);
 		$type_prelevement_organe=mysubstr($rsa_line, 127, 1);
 		$supplement_sra=mysubstr($rsa_line, 128, 3);
 		$supplement_rea=mysubstr($rsa_line, 131, 3);
 		$supplement_si_de_rea=mysubstr($rsa_line, 134, 3);
 		$supplement_stf=mysubstr($rsa_line, 137, 3);
 		$supplement_ssc=mysubstr($rsa_line, 140, 3);
 		$supplement_src=mysubstr($rsa_line, 143, 3);
 		$supplement_nn1=mysubstr($rsa_line, 146, 3);
 		$supplement_nn2=mysubstr($rsa_line, 149, 3);
 		$supplement_nn3=mysubstr($rsa_line, 152, 3);
 		$supplement_rep=mysubstr($rsa_line, 155, 3);
 		$lit_dedie_palliatif=mysubstr($rsa_line, 158, 1);
 		$dp=mysubstr($rsa_line, 159, 6);
 		$dr=mysubstr($rsa_line, 165, 6);
		$nb_diags=mysubstr($rsa_line, 171, 2);
		$nb_actes=mysubstr($rsa_line, 173, 4);

	# Maintenant on parse le rsa_line selon le nbr DAS/DAD/ACTES
		$offset=177;
$rum_nbr=$nb_rum;
$das_nbr=$nb_diags;
$actes_nbr=$nb_actes;

		if ($rum_nbr > 0) {
			$rum_cur=0;
			while ($rum_cur < $rum_nbr) {
				$rum_type_rum[$rum_cur]=mysubstr($rsa_line, $offset, 2);
				$rum_duree_uf[$rum_cur]=mysubstr($rsa_line, $offset+ 2, 3);
				$rum_valorisation_rea[$rum_cur]=mysubstr($rsa_line, $offset + 2 + 3, 1);
				$rum_valorisation_partielle[$rum_cur]=mysubstr($rsa_line, $offset + 2 + 3 + 1, 1);
				$rum_position_dp[$rum_cur]=mysubstr($rsa_line, $offset + 2 + 3 + 1 + 1, 2);
				$offset=$offset + 2 + 3 + 1 + 1 + 2;
				$rum_cur++;
			} # while rum_cur
		} # rum_nbr
		if ($das_nbr > 0) {
			$das_cur=0;
			while ($das_cur < $das_nbr) {
				$das[$das_cur]=mysubstr($rsa_line, $offset, 6);
				$offset=$offset+6;
				$das_cur++;
			} # while das_cur
		} # das_nbr

		if ($actes_nbr > 0) {
			$actes_cur=0;
			while ($actes_cur < $actes_nbr) {
				$acte_delai[$actes_cur]=mysubstr($rsa_line, $offset, 3);
				$acte_code_ccam[$actes_cur]=mysubstr($rsa_line, $offset+3, 7);
				$acte_phase[$actes_cur]=mysubstr($rsa_line, $offset+3+7, 1);
				$acte_activite[$actes_cur]=mysubstr($rsa_line, $offset+3+7+1, 1);
				$acte_ext_doc[$actes_cur]=mysubstr($rsa_line, $offset+3+7+1+1, 1);
				$acte_modificateur[$actes_cur]=mysubstr($rsa_line, $offset+3+7+1+1+1, 4);
				$acte_remb_exceptionnel[$actes_cur]=mysubstr($rsa_line, $offset+3+7+1+1+1+4, 1);
				$acte_assoc_nonprevue[$actes_cur]=mysubstr($rsa_line, $offset+3+7+1+1+1+4+1, 1);
				$acte_iteration[$actes_cur]=mysubstr($rsa_line, $offset+3+7+1+1+1+4+1+1, 2);

				$offset=$offset+3+7+1+1+1+4+1+1+2;
				$actes_cur++;
			} # while actes_cur
		} # actes_nbr

	# on est normalement à la fin de la ligne

	} else {
		print "Version de RSA " .  $version_rsa . " non gérée !";
		exit (-1);
	}

	# maintenant que la ligne est lue, faut l'insérrer dans la base
#  	$dbh = DBI->connect("dbi:Pg:dbname=test;host=localhost;port=5432", 'postgres', 'postgres', {AutoCommit => 0}) or die ("Can't connect to the database!\n");

	# prepare and execute query
	# pas de placeholder car perl est weakly-typed, ce qui pose des problèmes de reconnaissance des types de values
	$sql="INSERT into rsa_$annee (annee, version_rsa, rsa, version_rss, sequence_tarif, version_lu, ghm_lu, retour_lu, version_mis, ghm_mis, retour_mis, nb_rum, age_annee, age_jour, sexe, entree, provenance, annee_sortie, mois_sortie, sortie, destination, type, duree, cp_residence, poids_nne_entree, nbr_sceances, igs2, ghs, depassement_bornehaute, inferieur_bornebasse, ghs_forfait_dialyse, supplement_hemodialyse_hs, supplement_entraitement_dialyseperit_auto_hs, supplement_entraitement_dialyseperit_ambu_hs, supplement_entraitement_hemodialyse_hs, sceances_avant_sros, nbr_actes_ghm_24Z05Z_ou_28Z11Z, nbr_actes_ghm_24Z06Z_ou_28Z12Z, nbr_actes_ghm_24Z07Z_ou_28Z13Z, supplement_caisson_hyperbare, type_prelevement_organe, supplement_sra, supplement_rea, supplement_si_de_rea, supplement_stf, supplement_ssc, supplement_src, supplement_nn1, supplement_nn2, supplement_nn3, supplement_rep, lit_dedie_palliatif, dp, dr, nb_diags, nb_actes) values (
$annee, $version_rsa, $rsa, $version_rss, $sequence_tarif, $version_lu, '$ghm_lu', $retour_lu, $version_mis, '$ghm_mis', $retour_mis, $rum_nbr, $age_annee, $age_jour, $sexe, $entree, $provenance, $annee_sortie, $mois_sortie, $sortie, $destination, $type, $duree, $cp_residence, $poids_nne_entree, $nbr_sceances, $igs2, $ghs, $depassement_bornehaute, $inferieur_bornebasse, $ghs_forfait_dialyse, $supplement_hemodialyse_hs, $supplement_entraitement_dialyseperit_auto_hs, $supplement_entraitement_dialyseperit_ambu_hs, $supplement_entraitement_hemodialyse_hs, $sceances_avant_sros, $nbr_actes_ghm_24Z05Z_ou_28Z11Z, $nbr_actes_ghm_24Z06Z_ou_28Z12Z, $nbr_actes_ghm_24Z07Z_ou_28Z13Z, $supplement_caisson_hyperbare, $type_prelevement_organe, $supplement_sra, $supplement_rea, $supplement_si_de_rea, $supplement_stf, $supplement_ssc, $supplement_src, $supplement_nn1, $supplement_nn2, $supplement_nn3, $supplement_rep, $lit_dedie_palliatif, '$dp', '$dr', $nb_diags, $nb_actes);";
	print $sql . "\n";

$sql="select currval('rsa_" . $annee . "_code_sq_pk_seq') as transmis;";
print $sql . "\n";

	if ($rum_nbr > 0) {
		$rum_cur=0;
		while ($rum_cur < $rum_nbr) {
			$sql = "INSERT INTO rsa_rum_$annee (code_sq_fk, rsa_f, type_rum, duree_uf, valorisation_rea, valorisation_partielle, position_dp) VALUES (currval('rsa_" . $annee . "_code_sq_pk_seq'), $rsa, $rum_type_rum[$rum_cur], $rum_duree_uf[$rum_cur], $rum_valorisation_rea[$rum_cur], $rum_valorisation_partielle[$rum_cur], '$rum_position_dp[$rum_cur]');"; 
print $sql . "\n";
$sql="select currval('rsa_" . $annee . "_code_sq_pk_seq') as rsa_rum;";
print $sql . "\n";
			$rum_cur++;
		} # while rum_cur
	} # rum_nbr

	if ($das_nbr > 0) {
		$das_cur=0;
		while ($das_cur < $das_nbr) {
			$sql = "INSERT INTO rsa_diags_$annee (code_sq_fk, rsa_f, das) VALUES (currval('rsa_" . $annee . "_code_sq_pk_seq'), $rsa, '$das[$das_cur]');"; 
print $sql . "\n";
$sql="select currval('rsa_" . $annee . "_code_sq_pk_seq') as rsa_diags;";
print $sql . "\n";
			$das_cur++;
		} # while das_cur
	} # das_nbr

# Maintenant les actes
	if ($actes_nbr > 0) {
		$actes_cur=0;
		while ($actes_cur < $actes_nbr) {
# On rearrange sa date aussi
$sql= "INSERT INTO rsa_actes_$annee ( code_sq_fk, rsa_f, delai, code_ccam, phase, activite, ext_doc, modificateur, remb_exceptionnel, assoc_nonprevue, iteration) VALUES ( currval('rsa_" . $annee . "_code_sq_pk_seq'), $rsa, $acte_delai[$actes_cur], '$acte_code_ccam[$actes_cur]', $acte_phase[$actes_cur], $acte_activite[$actes_cur], $acte_ext_doc[$actes_cur], '$acte_modificateur[$actes_cur]', '$acte_remb_exceptionnel[$actes_cur]', $acte_assoc_nonprevue[$actes_cur], $acte_iteration[$actes_cur]);";
print $sql . "\n";
$sql="select currval('rsa_" . $annee . "_code_sq_pk_seq') as rsa_acte;";
print $sql . "\n";

			$actes_cur++;
		} # while actes_cur
	} # actes_nbr
	

	# to count lines
	$line_cur++;
	} # while line_rsa=IFD 
#$sth->finish();

print $line_cur . " lignes lues\n";
close (IFD); 
