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

unless (scalar @ARGV == 2){
   die "Usage:\n\t$0 RSS.grp annee\n";
}

$infile = $ARGV[0];
$annee = $ARGV[1];

open (IFD, "<$infile") or die ("Can't read input file " . $infile . " !\n"); 

$line_cur=0;
	while ($rss_line=<IFD>) {
	# commencer par lire la version de RSS pour parser différemment

	$version_groupage=substr($rss_line, 0,2);
	$cmd=substr($rss_line, 2, 2);
	$ghm=substr($rss_line, 4, 4); 
	$filler=substr($rss_line, 8, 1);
	$version_rss=substr($rss_line, 9, 3); 

	if ($version_rss == 111) {
		$code_retour=substr($rss_line, 12, 3);
		$finess=substr($rss_line, 15, 9);
		$version_rum=substr($rss_line, 24, 3);
		$rss=substr($rss_line, 27, 7);
		$iep=substr($rss_line, 34, 20);
		$ddn=substr($rss_line, 54, 8);
		$sexe=substr($rss_line, 62, 1);
		$uf=substr($rss_line, 63, 4);
		$uf_autorisation=substr($rss_line, 67, 7);
		$lit_autorisation=substr($rss_line, 69, 2);
		$reserve1=substr($rss_line, 71, 1);
		$date_entree_uf=substr($rss_line, 72, 8);
		$entree=substr($rss_line, 80, 1);
		$provenance=substr($rss_line, 81, 1);
		$date_sortie_uf=substr($rss_line, 82, 8);
		$sortie=substr($rss_line, 90, 1);
		$destination=substr($rss_line, 91, 1);
		$cp_residence=substr($rss_line, 92, 5);
		$poids_nne_entree=substr($rss_line, 97, 4);
		$sceances_nbr=substr($rss_line, 101, 2);
		$das_nbr=substr($rss_line, 103, 2);
		$dad_nbr=substr($rss_line, 105, 2);
		$actes_nbr=substr($rss_line, 107, 2);
		$dp=substr($rss_line, 109, 8);
		$dr=substr($rss_line, 117, 8);
		$igs2=substr($rss_line, 125, 3);
		$reserve2=substr($rss_line, 128, 15);
		$reste=substr($rss_line, 143);

	# Maintenant on parse le reste selon le nbr DAS/DAD/ACTES
		$offset=0;

		if ($das_nbr > 0) {
			$das_cur=0;
			while ($das_cur < $das_nbr) {
				$das[$das_cur]=substr($reste, $offset, 8);
				$das_cur++;
				$offset=8*$das_cur;
			} # while das_cur
		} # das_nbr
		$offset_last=$offset;

		if ($dad_nbr > 0) {
			$dad_cur=0;
			while ($dad_cur < $dad_nbr) {
				$dad[$dad_cur]=substr($reste, $offset, 8);
				$dad_cur++;
				$offset=$offset_last+8*$dad_cur;
			} # while dad_cur
		} # dad_nbr
		$offset_last=$offset;

		if ($actes_nbr > 0) {
			$actes_cur=0;
			while ($actes_cur < $dad_nbr) {
				$acte_date[$actes_cur]=substr($reste, $offset, 8);
				$acte_code_ccam[$actes_cur]=substr($reste, $offset, 7);
				$acte_phase[$actes_cur]=substr($reste, $offset, 1);
				$acte_activite[$actes_cur]=substr($reste, $offset, 1);
				$acte_ext_doc[$actes_cur]=substr($reste, $offset, 1);
				$acte_modificateur[$actes_cur]=substr($reste, $offset, 4);
				$acte_remb_exceptionnel[$actes_cur]=substr($reste, $offset, 1);
				$acte_assoc_nonprevue[$actes_cur]=substr($reste, $offset, 1);
				$acte_iteration[$actes_cur]=substr($reste, $offset, 2);
				$actes_cur++;
				$offset=$offset_last+26*$actes_cur;
			} # while actes_cur
		} # actes_nbr

	# on est normalement à la fin du fichier
		$offset_last=$offset;

	} else {
		print "Version de RSS " .  $version_rss . " non gérée !";
		exit (-1);
	}

	# maintenant que la ligne est lue, faut l'insérrer dans la base
  	$dbh = DBI->connect("dbi:Pg:dbname=chu;host=localhost;port=5432", 'postgres', 'postgres', {AutoCommit => 0}) or die ("Can't connect to the database!\n");

	# prepare and execute query
	$sql = "INSERT into transmis (annee, version_groupage, cmd, ghm, filler, version_rss, code_retour, finess, version_rum, rss, iep, ddn, sexe, uf, uf_autorisation, lit_autorisation, reserve1, date_entree_uf, entree, provenance, date_sortie_uf, sortie, destination, cp_residence, poids_nne_entree, sceances_nbr, das_nbr, dad_nbr, actes_nbr, dp, dr, igs2, reserve2) values ($annee, $version_groupage, $cmd, $ghm, $filler, $version_rss, $code_retour, $finess, $version_rum, $rss, $iep, $ddn, $sexe, $uf, $uf_autorisation, $lit_autorisation, $reserve1, $date_entree_uf, $entree, $provenance, $date_sortie_uf, $sortie, $destination, $cp_residence, $poids_nne_entree, $sceances_nbr, $das_nbr, $dad_nbr, $actes_nbr, $dp, $dr, $igs2, $reserve2)";
print $sql;

	$sth = $dbh->prepare($sql);
	$sth->execute();

	# On récupère code_sq_pk pour les fils ; on n'utilise pas INSERT
	# ...RETURNING car réservé aux versions récentes de postgresql
	$sql="select currval('transmis_code_sq_pk_seq');";
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->bind_columns(\$code_sq);


	# On doit dérouler diagnostics & actes

	if ($das_nbr > 0) {
		$das_cur=0;
		while ($das_cur < $das_nbr) {
			$sql = "INSERT INTO transmis_diags (code_sq_fk, rss, das) VALUES (?, ?, ?)";
			$sth = $dbh->prepare($sql);
			$sth ->execute($code_sq[0], $rss, $das[$das_cur]); 
			$das_cur++;
		} # while das_cur
	} # das_nbr

	if ($dad_nbr > 0) {
		$dad_cur=0;
		while ($dad_cur < $dad_nbr) {
			$sql = "INSERT INTO transmis_diags (code_sq_fk, rss, dad) VALUES (?, ?, ?)";
			$sth = $dbh->prepare($sql);
			$sth ->execute($code_sq[0], $rss, $dad[$dad_cur]); 
			$dad_cur++;
		} # while dad_cur
	} # dad_nbr

# Maintenant les actes
	if ($actes_nbr > 0) {
		$actes_cur=0;
		while ($actes_cur < $dad_nbr) {
#			my @fields=qw( $acte_date[$actes_cur] $acte_code_ccam[$actes_cur] $acte_phase[$actes_cur] $acte_activite[$actes_cur] $acte_ext_doc[$actes_cur] $acte_modificateur[$actes_cur] $acte_remb_exceptionnel[$actes_cur] $acte_assoc_nonprevue[$actes_cur] $acte_iteration[$actes_cur] );
#	        	my $fields = "code_sq_fk" . join(', ', @fields);
#	        	my $values = $code_sq[0] . join(', ', map { $dbh->quote($_) } @formdata{@fields});
#	        	$sql = "INSERT into transmis ($fields) values ($values)";
#	        	$sth = $dbh->prepare($sql);
#	        	$sth->execute();
			$actes_cur++;
		} # while actes_cur
	} # actes_nbr
	

	# to count lines
	$line_cur++;
	} # while line_rss=IFD 
$sth->finish();

print $line_cur . " lignes lues\n";
close (IFD); 
