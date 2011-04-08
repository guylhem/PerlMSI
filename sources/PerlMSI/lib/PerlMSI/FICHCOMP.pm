{
    package PerlMSI::FICHCOMP;
    use 5.008008;

    our @ISA = qw(Exporter FILEREAD);
    our @EXPORT = qw(readfrom value value_iep distinct_iep distinct_ss distinct_nbr_iep distinct_nbr_ss);

    # Complain where ooperl routines are called from
    use Carp qw(croak);
    use warnings;
    use strict;

    my %formats_fichcomp = (
        92 + 2 => {
            format   => 'A9 A2 A20 A10 A8 A8 A15 A10 A10',
            variable => [qw( finess prestation iep rum date_debut date_fin code nombre montant_paye )],
	    pgsql => [qw( bigint smallint bigint bigint timestamp timestamp varchar bigint bigint)],
	    signification => [
        prestation  => { 01 => "medicament", 02 => "dispositif implantable", 03 => "prelevement", 04=> "prestation interetablissement", 99 => "enquete" },
		],
        },
        105 + 2 => {
            format   => 'A9 A2 A20 A8 A15 A10 A10 A1 x30',
            variable => [qw( finess prestation iep date_administration code nombre montant_paye validation)],
	    pgsql => [qw( bigint smallint bigint timestamp bigint varchar bigint bigint)],
	    signification => [
        prestation  => { 06 => "medicament onereux"},
	   ],
        },
    );


sub readfrom {
# Input file
 my $infile = shift;
# Counters
 my $line_cur;
 my %line_missing;
# Result : Hoa
 my %E_fichcomp;
# Result : object
 my %E_result;
# Calculations
 my %C_iep;
 my %C_val;

 open( IFD, "<" . $infile ) or croak( "Ne peut lire " . $infile . " !\n" );

   while (my $line_read = <IFD>) {
   # ATTENTION : we need to start at 0 to fill the arrays but $. starts at 1
   $line_cur=$. - 1;

    my $format = $formats_fichcomp { length $line_read };
    unless ($format) {
# Keep a hash of line read per incompatible formats
        $line_missing{2- length $line_read}++;
        next;
    }

    my @variable = @{ $format->{'variable'} };
    # ATTENTION : can't unpack directly into E_fichcomp because can't
    # make an array of lvalues from an array of scalar refs, so here a
    # temporary vаriable must be used
    my %fichcomp_line;
    @fichcomp_line{ @variable } = unpack($format->{'format'}, $line_read);

    for my $variable (keys %fichcomp_line) {
     $E_fichcomp{$variable}[$line_cur]=$fichcomp_line{$variable};
    } # for
 
    # Use the file unrolling opportunity to count amounts
    if ($fichcomp_line{iep}) {
    $C_iep{0+$fichcomp_line{iep}}++;
    }
    if ($fichcomp_line{montant_paye}) {
    $C_val{0+$fichcomp_line{iep}}+=$fichcomp_line{montant_paye};
    }
    $line_cur++;
 } # while

 my $line_missing_nbr=0;
 foreach my $missing_nbr (values %line_missing) {
 $line_missing_nbr+=$missing_nbr;
 }
 my $line_missing_formats;
 foreach my $missing_format (values %line_missing) {
 $line_missing_formats .= $missing_format;
 }

 if ($line_missing_nbr > 0) {
 printf STDERR "ERREUR : " . $line_missing_nbr . " lignes non lues, car formats" . $line_missing_formats .  "\n"
 } # if lines_missing

# Store metadata as direct hash keys
  $E_fichcomp{CALC_NBR}=$line_cur;
  $E_fichcomp{CALC_VAL}=\%C_val;
  $E_fichcomp{CALC_DISTINCT_IEP}= [ keys %C_iep ];
  $E_fichcomp{CALC_NBR_DISTINCT_IEP}=scalar keys %C_iep;

  my $E_result=\%E_fichcomp;
  bless ($E_result, "FICHCOMP");
  return ($E_result);
  }
# sub readfrom

################################################################################
    # In: FICHCOMP
    # Out: Financial value
sub value {
use List::Util qw(sum);
        my $E_self = shift;
	my $val_ref=$$E_self{CALC_VAL};
	my %val=%$val_ref;
	my @each_val=values %val;
	return sum (0, @each_val);
 } # value

# FIXME: utiliser des arrays et des hashes plutot que des refs

sub value_iep {
        my $E_self = shift;
	my $val_ref=$$E_self{CALC_VAL};
	my %val=%$val_ref;
	my $iep_ref = shift;
	my @iep=@$iep_ref;
	my $tot;

	foreach my $patient (@iep) {
	 if ( grep { $_ eq $patient } keys %val ) {
	   $tot+=$val{$patient};
	 }
	}
	return $tot;
 } # value_iep

sub distinct_iep  {
        my $E_self = shift;
 return $$E_self{CALC_DISTINCT_IEP};
 } # distinct_iep

sub nbr_distinct_iep  {
        my $E_self = shift;
 return $$E_self{CALC_NBR_DISTINCT_IEP};
 } # distinct_nbr_iep

} # FICHCOMP

