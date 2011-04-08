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

$chrono=1;

#use warnings;
#use strict;
#use Data::Dumper; #uncomment for debugging

sub mysubstr {
    my $out = substr( $_[0], $_[1], $_[2] );
    $out =~ s/ //g;
    if ( length($out) == 0 ) { $out = "DEFAULT"; }
    return $out;
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
    # $frtime = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth $year
    # @ $hour:$minute:$second";
    $thetime = sprintf "%04d-%02d-%02d @ %02d:%02d:%02d _ %s", $year, $month, $dayOfMonth, $hour, $minute, $second, $weekDays[$dayOfWeek];
    return $thetime; 
}

unless ( scalar @ARGV == 2 ) {
    die "Usage:\n\t$0 fichcomp-MON annee\n";
}

$dbh = DBI->connect("dbi:Pg:dbname=test;host=localhost;port=5432", 'postgres', 'postgres', {AutoCommit => 0})
or die ("Impossible de se connecter a la base de donnees:" .  $dbh->errstr);

$infile = $ARGV[0];
$annee  = $ARGV[1];

if ($chrono) {
 print thetime() . " - fin de chargement du fichier " . $difftxt . "\n";
}

open( IFD, "<$infile" ) or die( "Can't read input file " . $infile . " !\n" );

$line_cur = 0;
while ( $line = <IFD> ) {
 if (length($line) > 2 ) { 
    $finess = mysubstr( $line, 0, 10 );
    $iep    = mysubstr( $line, 24, 7 );
    $date   = mysubstr( $line, 41, 8 );
    $ucd    = mysubstr( $line, 57, 10 );
    $qte    = mysubstr( $line, 72, 10 );
    $prix   = mysubstr( $line, 82, 10 );
        if ( $schema_sql != 1 ) {
# Supprimer de suite la table si elle existe
$dbh->do("DROP TABLE IF EXISTS fichcomp_mon_$annee CASCADE; CREATE TABLE fichcomp_mon_$annee (ligne_sq SERIAL PRIMARY KEY, finess bigint, iep int, date timestamp, ucd int, qte int, prix int); select setval('fichcomp_mon_" . $annee . "_ligne_sq_seq', 1)") or die "Ne peut initialiser fichcomp_mon_$annee" . "_ligne_sq_seq!";
            $schema_sql = 1;
	    $dbh->commit;
        }

        # On rearrage les dates au format iso
        $date =~ s{(.{2})(.{2})(.{4})}{\3-\2-\1};

$sth = $dbh->prepare("INSERT INTO fichcomp_mon_$annee (finess, iep, date, ucd, qte, prix) VALUES (?, ?, ?, ?, ?, ?)");

$sth->execute($finess, $iep, $date, $ucd, $qte, $prix) or die "Impossible de rajouter $ligne_sq dans fichcomp_mon_$annee!";
$sth->finish();

 } # if length > 1
$line_cur++;
} # while line_cur

$dbh->commit;

if ($chrono) {
print thetime() . " - fin de chargement du fichier " . $difftxt . "\n";
}

$dbh->disconnect;

close (IFD);
