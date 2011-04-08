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

sub mysubstr {
    my $out = substr( $_[0], $_[1], $_[2] );
    $out =~ s/ //g;
    if ( length($out) == 0 ) { $out = undef; }
    return $out;
}

# $debug=1;

$dbh = DBI->connect("dbi:Pg:dbname=chu;host=localhost;port=5432", 'postgres', 'postgres', {AutoCommit => 0}) or die ("Impossible de se connecter a la base de donnees:" .
$dbh->errstr);

unless ( scalar @ARGV ==  2) {
    print "Il faut preciser en argument l'année et le fichier tra à importer\n";
    print "Ce fichier se trouve dans votre out.zip a prendre de GenRSA\n";
    die "\nExemple:\n\t $0 2009 970202271.2009.6.tra.txt\n"
}

$suffixe=$ARGV[0];
$tratxt=$ARGV[1];

# Supprimer de suite la table si elle existe
$dbh->do("DROP TABLE IF EXISTS rssrsa_$suffixe CASCADE");
$dbh->commit;
# Puis creer normalement la table
$sql="CREATE TABLE rssrsa_$suffixe (rsa bigint, rss bigint, rss_code_sq_fk bigint,
iep int, date_debut_hospit timestamp, ghm_mis char(7))";
$sth=$dbh->prepare($sql);
$sth->execute or die "Ne peut creer la table evaluation_tra_$suffixe!";
$sth->finish;

open( TFD, "< $tratxt" ) or die( "Ne peut lire " . $tratxt . " !\n" );

$tra_line_nbr = 0;
$sth = $dbh->prepare("INSERT INTO rssrsa_$suffixe (rsa, rss, rss_code_sq_fk, iep,
date_debut_hospit, ghm_mis) VALUES (?, ?, ?, ?, ?, ?)");


while ( $tra_line = <TFD> ) {
# attention : chiffres prefixes par 0 ou paddes par spaces

if ($suffixe== 2009) {
# Format 2009 / RSA 216
$tra_rsa      = mysubstr( $tra_line, 0, 10);
$tra_rss      = mysubstr( $tra_line, 10, 20);
$tra_rss_code_sq  = mysubstr( $tra_line, 30, 10);
$tra_iep      = mysubstr( $tra_line, 40, 20);
$tra_debut    = mysubstr( $tra_line, 60, 8);
$tra_ghm_mis  = mysubstr( $tra_line, 68, 6);
} elsif ($suffixe=2008) {
$tra_rsa      = mysubstr( $tra_line, 0, 10);
$tra_rss      = mysubstr( $tra_line, 10, 20);
$tra_rss_code_sq  = mysubstr( $tra_line, 30, 10);
$tra_iep      = mysubstr( $tra_line, 40, 20);
$tra_debut    = mysubstr( $tra_line, 60, 8);
$tra_ghm_mis  = mysubstr( $tra_line, 68, 6);
} elsif ($suffixe=2007) {
$tra_rsa      = mysubstr( $tra_line, 0, 10);
$tra_rss      = mysubstr( $tra_line, 10, 7);
$tra_rss_code_sq  = mysubstr( $tra_line, 17, 10);
$tra_iep      = mysubstr( $tra_line, 27, 7);
$tra_debut    = mysubstr( $tra_line, 47, 8);
$tra_ghm_mis  = mysubstr( $tra_line, 55, 6);
}

# On rearrage la date
$tra_debut =~ s{(.{2})(.{2})(.{4})}{\3\2\1};

if ($debug) {
print "$tra_rsa, $tra_rss, $tra_rss_code_sq, $tra_iep, $tra_debut, $tra_ghm_mis\n";
}

if ($debug) {
print "Aucune ecriture en base\n";
} else {
$sth->execute($tra_rsa, $tra_rss, $tra_rss_code_sq, $tra_iep, $tra_debut, $tra_ghm_mis) or die "Impossible de rajouter $tra_rss dans rssrsa_$suffixe !";
$sth->finish();
}

$tra_line_nbr++;
} # while tra_line

if ($debug) {
print "\n\nAucun index de cree\n";
} else {
$dbh->commit;
$dbh->do("CREATE INDEX rssrsa_" . $suffixe . "_iep_idx on rssrsa_$suffixe(iep)");
$dbh->do("CREATE INDEX rssrsa_" . $suffixe . "_rss_idx on rssrsa_$suffixe(rss)");
$dbh->do("CREATE INDEX rssrsa_" . $suffixe . "_rsasq_idx on rssrsa_$suffixe(rsa)");
$dbh->do("CREATE INDEX rssrsa_" . $suffixe . "_codesq_idx on rssrsa_$suffixe(rss_code_sq_fk)");
}

close (TFD);
