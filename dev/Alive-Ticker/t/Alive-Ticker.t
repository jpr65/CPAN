# Perl 5
#
# Test for Alive::Ticker
#
# Ralf Peine, Sun Dec 20 16:45:29 2020
#
#------------------------------------------------------------------------------

# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Alive-Ticker.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use v5.10;

use Test::More;
use Alive::Ticker qw(:all);

sub _say { print join (' ', @_) . "\n"; }

tack; _say;

is (tacks, 1, "first tack");

print '# ';

Alive::Ticker::setup_tack(-name => '#');

foreach my $i (1..2000) {
    tack;
} _say;

is (tacks, 2000, "first 2001 tacks");

tick; _say;

is (ticks, 1, "first tick");

print '# ';

Alive::Ticker::setup(-name => '@');

foreach my $i (1..2000) {
    tick;
} _say;

is (ticks, 2000, "first 2001 ticks");

my $tick = tack;

$tick->();

is (tacks, 2002, "first tick");

my $tac = Alive::Ticker::get_tack_counter();
my $tic = Alive::Ticker::get_tick_counter();

is ($$tac, 2002, "get_tack_counter()");
is ($$tic, 2000, "get_tick_counter()");

tack;

is ($$tac, 2003, "tack_counter++");

my $tick_2_count = 0;

my $tick_2 = Alive::Ticker::create(-factor       => 2,
                           -name         => '@',
                           -smaller_char => '*',
                           -bigger_char  => '&',
                           -counter_ref  => \$tick_2_count,
                          );
print "@ 0 ";
foreach my $i (1..200) {
    tack;
    $tick_2->();
} _say;

is ($tick_2_count, 200, "own tick counter");

Alive::Ticker::silent();

foreach my $i (1..200) {
    tack;
    $tick_2->();
}

is ($tick_2_count, 400, "silent() but counting ticks");

Alive::Ticker::all_off();

foreach my $i (1..200) {
    tack;
    $tick_2->();
}

is ($tick_2_count, 400, "all_off() without counting ticks");

print "# ";

Alive::Ticker::on();

foreach my $i (1..200) {
    tack;
    $tick_2->();
} _say;

is ($tick_2_count, 600, "on() printing and counting ticks");

my $tick_auto = Alive::Ticker::create(-name            => 'Dyn',
				      -auto_regulation => 0.02
    );

my $val = 3.14;

foreach my $i (1..2000000) {
    $tick_auto->();
    $val = 0.5 + sin($val);
}

say "\n# --------------";

my $tick_dyn_count = 0;

$tick_auto = Alive::Ticker::create(-name            => 'Dyn*',
				   -auto_regulation => 1,
				   -counter_ref     => \$tick_dyn_count,
    );

$val = 3.14;

foreach my $i (1..2000000) {
    $tick_auto->();
    $val = 0.5 + sin($val);
}

say "\n# --------------";

is($tick_dyn_count, 2000000, "2 000 000 ticks");

Alive::Ticker::setup_tick(
    -name => '#',
    -auto_regulation => 1
    );

Alive::Ticker::setup_tack(
    -name => '#M',
    -smaller_char => '*',
    -bigger_char  => '&',
    -auto_regulation => 1,
    );

foreach my $i (1..1000000) {
    tick;
    if ($i % 783 == 0) {
	tack;
    }
} _say;

is (ticks, 1000000, "ticks");
is (tacks,    1277, "tacks");

done_testing();


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

