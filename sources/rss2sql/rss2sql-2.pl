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
	for ($out) {
		s/\s+//;
	}
	if ($out == " ") { $out="DEFAULT"; }
	return $out;
}

unless (scalar @ARGV == 2){
   die "Usage:\n\t$0 RSS.grp annee\n";
}

$infile = $ARGV[0];
$annee = $ARGV[1];

open (IFD, "<$infile") or die ("Can't read input file " . $infile . " !\n"); 

$line_cur=0;
	while ($rss_line=<IFD>) {
	# commencer par lire la version de RSS pour parser différemment

	$version_groupage=mysubstr($rss_line, 0,2);
	$cmd=mysubstr($rss_line, 2, 2);
	$ghm=mysubstr($rss_line, 4, 4); 
	$filler=mysubstr($rss_line, 8, 1);
	$version_rss=mysubstr($rss_line, 9, 3); 

	if ($version_rss == 111) {
		$code_retour=mysubstr($rss_line, 12, 3);
		$finess=mysubstr($rss_line, 15, 9);
		$version_rum=mysubstr($rss_line, 24, 3);
		$rss=mysubstr($rss_line, 27, 7);
		$iep=mysubstr($rss_line, 34, 20);
		$ddn=mysubstr($rss_line, 54, 8);
		$sexe=mysubstr($rss_line, 62, 1);
		$uf=mysubstr($rss_line, 63, 4);
		$uf_autorisation=mysubstr($rss_line, 67, 2);
		$lit_autorisation=mysubstr($rss_line, 69, 2);
		$reserve1=mysubstr($rss_line, 71, 1);
		$date_entree_uf=mysubstr($rss_line, 72, 8);
		$entree=mysubstr($rss_line, 80, 1);
		$provenance=mysubstr($rss_line, 81, 1);
		$date_sortie_uf=mysubstr($rss_line, 82, 8);
		$sortie=mysubstr($rss_line, 90, 1);
		$destination=mysubstr($rss_line, 91, 1);
		$cp_residence=mysubstr($rss_line, 92, 5);
		$poids_nne_entree=mysubstr($rss_line, 97, 4);
		$sceances_nbr=mysubstr($rss_line, 101, 2);
		$das_nbr=mysubstr($rss_line, 103, 2);
		$dad_nbr=mysubstr($rss_line, 105, 2);
		$actes_nbr=mysubstr($rss_line, 107, 2);
		$dp=mysubstr($rss_line, 109, 8);
		$dr=mysubstr($rss_line, 117, 8);
		$igs2=mysubstr($rss_line, 125, 3);
		$reserve2=mysubstr($rss_line, 128, 15);
		$reste=substr($rss_line, 143);

	# Maintenant on parse le reste selon le nbr DAS/DAD/ACTES
		$offset=0;

		if ($das_nbr > 0) {
			$das_cur=0;
			while ($das_cur < $das_nbr) {
				$das[$das_cur]=mysubstr($reste, $offset, 8);
				$das_cur++;
				$offset=8*$das_cur;
			} # while das_cur
		} # das_nbr
		$offset_last=$offset;

		if ($dad_nbr > 0) {
			$dad_cur=0;
			while ($dad_cur < $dad_nbr) {
				$dad[$dad_cur]=mysubstr($reste, $offset, 8);
				$dad_cur++;
				$offset=$offset_last+8*$dad_cur;
			} # while dad_cur
		} # dad_nbr
		$offset_last=$offset;

		if ($actes_nbr > 0) {
			$actes_cur=0;
			while ($actes_cur < $dad_nbr) {
				$acte_date[$actes_cur]=mysubstr($reste, $offset, 8);
				$acte_code_ccam[$actes_cur]=mysubstr($reste, $offset, 7);
				$acte_phase[$actes_cur]=mysubstr($reste, $offset, 1);
				$acte_activite[$actes_cur]=mysubstr($reste, $offset, 1);
				$acte_ext_doc[$actes_cur]=mysubstr($reste, $offset, 1);
				$acte_modificateur[$actes_cur]=mysubstr($reste, $offset, 4);
				$acte_remb_exceptionnel[$actes_cur]=mysubstr($reste, $offset, 1);
				$acte_assoc_nonprevue[$actes_cur]=mysubstr($reste, $offset, 1);
				$acte_iteration[$actes_cur]=mysubstr($reste, $offset, 2);
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

        # On rearrage les dates au format iso
        $date_entree_uf=~ s{(.{2})(.{2})(.{4})}{'\3-\2-\1'};
        $date_sortie_uf=~ s{(.{2})(.{2})(.{4})}{'\3-\2-\1'};
        $ddn=~ s{(.{2})(.{2})(.{4})}{'\3-\2-\1'};

	# maintenant que la ligne est lue, faut l'insérrer dans la base
  	$dbh = DBI->connect("dbi:Pg:dbname=chu;host=localhost;port=5432", 'postgres', 'postgres', {AutoCommit => 0}) or die ("Can't connect to the database!\n");

	# set up some sample data, assume $#columns == $#values
	my @columns = qw/ annee version_groupage cmd ghm filler version_rss code_retour finess version_rum rss iep ddn sexe uf uf_autorisation lit_autorisation reserve1 date_entree_uf entree provenance date_sortie_uf sortie destination cp_residence poids_nne_entree sceances_nbr das_nbr dad_nbr actes_nbr dp dr igs2 reserve2 /;
	my @values = qw/ $annee $version_groupage $cmd $ghm $filler $version_rss $code_retour $finess $version_rum $rss $iep $ddn $sexe $uf $uf_autorisation $lit_autorisation $reserve1 $date_entree_uf $entree $provenance $date_sortie_uf $sortie $destination $cp_residence $poids_nne_entree $sceances_nbr $das_nbr $dad_nbr $actes_nbr $dp $dr $igs2 $reserve2 /;

print "annee : " . $annee . "\n"; print "version_groupage : " . $version_groupage . "\n";
print "cmd : " . $cmd . "\n";
print "ghm : " . $ghm . "\n";
print "filler : " . $filler . "\n";
print "version_rss : " . $version_rss . "\n";
print "code_retour : " . $code_retour . "\n";
print "finess : " . $finess . "\n";
print "version_rum : " . $version_rum . "\n";
print "rss : " . $rss . "\n";
print "iep : " . $iep . "\n";
print "ddn : " . $ddn . "\n";
print "sexe : " . $sexe . "\n";
print "uf : " . $uf . "\n";
print "uf_autorisation : " . $uf_autorisation . "\n";
print "lit_autorisation : " . $lit_autorisation . "\n";
print "reserve1 : " . $reserve1 . "\n";
print "date_entree_uf : " . $date_entree_uf . "\n";
print "entree : " . $entree . "\n";
print "provenance : " . $provenance . "\n";
print "date_sortie_uf : " . $date_sortie_uf . "\n";
print "sortie : " . $sortie . "\n";
print "destination : " . $destination . "\n";
print "cp_residence : " . $cp_residence . "\n";
print "poids_nne_entree : " . $poids_nne_entree . "\n";
print "sceances_nbr : " . $sceances_nbr . "\n";
print "das_nbr : " . $das_nbr . "\n";
print "dad_nbr : " . $dad_nbr . "\n";
print "actes_nbr : " . $actes_nbr . "\n";
print "dp : " . $dp . "\n";
print "dr : " . $dr . "\n";
print "igs2 : " . $igs2 . "\n";
print "reserve2 : " . $reserve2 . "\n";

# Dynamically build the SQL insert with place holders
	my $sql = "INSERT INTO transmis(" . join(',',@columns) . ") " .
	"VALUES (" . join(',', map {'?'} @columns) . ")";

	my $sth = $dbh->prepare($sql) or die "Couldn't prepare query";
	$sth->execute(@values);

	# On récupère code_sq_pk pour les fils ; on n'utilise pas INSERT
	# ...RETURNING car réservé aux versions récentes de postgresql
	$sql="select currval('rss_code_sq_pk_seq');";
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->bind_columns(\$code_sq);


	# On doit dérouler diagnostics & actes

	if ($das_nbr > 0) {
		$das_cur=0;
		while ($das_cur < $das_nbr) {
			$sql = "INSERT INTO rss_diags (code_sq_fk, rss, das) VALUES (?, ?, ?)";
			$sth = $dbh->prepare($sql);
			$sth ->execute($code_sq[0], $rss, $das[$das_cur]); 
			$das_cur++;
		} # while das_cur
	} # das_nbr

	if ($dad_nbr > 0) {
		$dad_cur=0;
		while ($dad_cur < $dad_nbr) {
			$sql = "INSERT INTO rss_diags (code_sq_fk, rss, dad) VALUES (?, ?, ?)";
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
