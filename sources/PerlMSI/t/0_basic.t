# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PerlMSI-RSS.t'

#########################

use Test::More 'no_plan';
#use Test::More tests=> 4; # To calculate a percentage

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
#
# Though everything is built on Test::Builder::ok(), other functions offer
# helpful shortcuts. use_ok() and require_ok load and optionally import
# the named file, reporting the success or error. These verify that a
# module can be found and compiled, and are often used for the first test
# in a suite. The can_ok() function attempts to resolve a class or an
# object method. isa_ok() checks inheritance:
#
#        use_ok( 'My::Module' );
#        require_ok( 'My::Module::Sequel' );
#        my $foo = My::Module->new();
#        can_ok( $foo->boo() );
#        isa_ok( $foo, 'My::Module' );
#
# Test if IceCreamBar inherits these methods from Popsicle
#   my $icb = IceCreamBar->new();
#   foreach my $method (qw( fall_off_stick freeze_tongue driponcarpet )) {
#    can_ok( $icb, $method, "IceCreamBar should be able to $method()" );
#   }


# ATTN: to test read a file from here, specify PATH: open FILE, "t/filename"


# Test 1
ok(1 + 1 == 2, 'Testing 1+1');

# Test 2
ok(2 + 2 == 4, 'Testing 2+2');

# Test 3
is(1, 1, '1==1 ?');

# Test 4
is(3, 2, '3==2 ?');

# Test 5
$self->eat('garden salad');
eval { $self->write_article() };
like( $@, qr/not enough sugar/ );

TODO: {
        local $TODO = 'objt not yet implemented';

        my $rss = PerlMSI::RSS->new;
        $rss->rssline('20201231Z');

        is( $rss->rssline, '20201231Z',   'Setting via rssline()' );
    }
