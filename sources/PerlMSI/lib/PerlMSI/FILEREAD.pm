{
    package PerlMSI::FILEREAD;
    use 5.008008;
 
    our @ISA = qw(Exporter);
    our @EXPORT = qw(compare dumper nbr stripzero stripspace tosql tocsv list ssclef checkformat);

    # Complain where ooperl routines are called from
    use Carp qw(croak);
    use warnings;
    use strict;

sub compare {
# reference to input array A
my $a_ref = shift;
# input array A
my @a = @$a_ref;
# reference to input array B
my $b_ref = shift;
# input array B
my @b = @$b_ref;

# lookup table
#my @Aseen{@a} = ();
my %Aseen = map { $_ => 1 } @a;
#my @Bseen{@b} = ();
my %Bseen = map { $_ => 1 } @b;

# count hash 
my %count;
my $e;

my @isec = ();
my @diff = ();
my @union = ();
my @aonly = ();
my @bonly = ();

# put all items in hash table
foreach $e (@a, @b) { $count{$e}++ }

# interate over each key of hash table
foreach $e (keys %count) {
# keys of hash table = union
push(@union, $e);
if ($count{$e} == 2) {
# seen more than once = intersection
push @isec, $e;
} else {
# seen once = difference
push @diff, $e;
# seen once + from A = Aonly
push(@aonly, $e) unless exists $Bseen{$e};
# seen once + from B = Bonly
push(@bonly, $e) unless exists $Aseen{$e};
}
}
# return referecnes to computed arrays
return (\@union, \@isec, \@diff, \@aonly, \@bonly);
}

    sub dumper {
        use Data::Dumper;
        Data::Dumper->new( [ $_[0] ] )->Useqq(1)->Terse(1)->Indent(1)->Deepcopy(1)->Dump;
    }    # sub dumper

    sub nbr {
        my $E_self = shift;
        return $$E_self{CALC_NBR};
    } # sub nbr

    sub nonundef {
        my $scalar = shift;
	$scalar = '' unless defined $scalar;
        return $scalar;
    } # sub nonundef

    sub stripzero {
        my $scalar = shift;
	$scalar = '' unless defined $scalar;
        if ( $scalar =~ /^[+-]?\d+$/ ) {
            $scalar =~ s{^\([+-]?\)\(0+\)}{$1};
            $scalar = $scalar + 0;
        }    # if +-number
        return $scalar;
    }    # sub stripzero

# FIXME:  marche pas
    sub stripspace {
        my $scalar = shift;
	$scalar = '' unless defined $scalar;
        if ( $scalar =~ /^\s*$/ ) {
            $scalar =~ s{^\(\s*\)\(.*\)}{$1};
            $scalar = $scalar + 0;
        }    # if leadingspaces
        return $scalar;
    }    # sub stripzero

# FIXME: a tester
    sub tosql {
        my %E_self   = shift;
        my $outfile  = shift;
        my $line_nbr = $E_self{CALC_NBR};
        my $line_cur = 0;

        print $E_self{CALC_NBR};
        print $outfile;

        my @sqlcolumns;    #=keys($E_self);
        my $sqlcolumns_nbr = scalar(@sqlcolumns);
        my $sqlcolumns_cur = 0;

        while ( $sqlcolumns_cur < $sqlcolumns_nbr ) {
            print $sqlcolumns[$sqlcolumns_cur];
        }                  # while sqlcolumns

    } # sub tosql


    sub tocsv {
        my $E_self = shift;
        my $line_nbr;
        my $line_cur;

        $line_nbr = $$E_self{CALC_NBR};
        $line_cur = 0;

        while ( $line_cur < $line_nbr ) {
            for my $variable ( keys %{$E_self} ) {
                # Exclude direct hash keys
                unless ( $variable =~ /^CALC_.*/) {
                    print "'" . $variable . "=',";
                    print $$E_self{$variable}[ $line_cur + 0 ] . ", ";
                }    # unless
            }    # for
            print "\n";
	$line_cur++;

        }    # while
    }    # tocsv

    sub tolist {
        my $E_self    = shift;
        my $requested = shift;
        my @requested_range;

        if ($requested) {
            @requested_range = @$requested;
        }
        else {
            @requested_range = ( 0 .. $$E_self{CALC_NBR}-1 );
        }

        foreach my $line_cur (@requested_range) {
            print "#" . $line_cur . " :";
            for my $variable ( keys %{$E_self} ) {

               # Exclude direct hash keys : read values are lowercase only =~ m{[a-z]}
                unless ( $variable =~ /^CALC_.*/) {
                print $variable . "=";
		if ($variable =~ /^iep$/ || $variable =~ /^rss$/ || $variable =~ /^rsa$/) {
                      print stripzero( $$E_self{$variable}[$line_cur]) . ", ";
                } else {
                      print nonundef($$E_self{$variable}[$line_cur]) . ", ";
                }    # if
               }    # unless
            }    # for
            print "\n";
        }    #foreach

    }    #sub

    sub ssclef {
        my $ss = shift;
        $ss =~ tr/[A-Z]/12345678912345678923456789/;
        my $clef = 97 - $ss % 97;
        return ($clef);
    }    # sub ssclef

    sub checkformat {
        my $formatreference = shift;

            my @rsa_variable = @{ $formatreference->{'rsa_variable'} };
my @rsa_variable_lenght = split (" ", $formatreference->{'rsa_format'});
my @rsa_variable_sql = split (" ", $formatreference->{'rsa_sql'});
for (my $i=0; $i < $#rsa_variable ; $i++) {
print $rsa_variable[$i] . " = " . $rsa_variable_lenght[$i] . " / " . $rsa_variable_sql[$i] . "\n";
}

   } # sub checkformat

    1;
} # Package FILEREAD
