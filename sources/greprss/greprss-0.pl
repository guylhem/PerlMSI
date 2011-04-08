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

unless ( scalar @ARGV ==  2) {
die "Usage:\n\t $0 2008_rss.rss  table_rss_conserver\n";
}

$rss_file = $ARGV[0];
$table = $ARGV[1];

$dbh = DBI->connect("dbi:Pg:dbname=test;host=localhost;port=5432", 'postgres', 'postgres', {AutoCommit => 0}) or die ("Impossible de se connecter a la base de donnees!\n");

my $sth = $dbh->prepare(<<SQL);
   select rss from $table
SQL
$sth->execute or die "Impossible de faire la requete sur table_rss_conserver !";

$rss_rss_nbr=0;
while (my @row=$sth->fetchrow_array() ) {
 $rss_rss[$rss_rss_nbr]=$row[0];
 $rss_rss_nbr++;
}


open( FD, "<$rss_file" ) or die( "1 - Can't read input file " . $rss_file . " !\n" );
while ( $line = <FD> ) {
my $rss_char= mysubstr( $line, 27,  20 );
$rss_num=$rss_char+0;
$rss_rss_cur=0;
while ($rss_rss_cur<$rss_rss_nbr) {
if ($rss_char==$rss_rss[$rss_rss_cur]) {
print $line;
} # if
$rss_rss_cur++;
} # while rss_rss_cur
} # while line
close (FD);
