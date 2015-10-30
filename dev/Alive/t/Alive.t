# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Alive.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More;
use Alive qw(:all);

sub _say { print join (' ', @_) . "\n"; }

tack; _say;

is (tacks, 1, "first tack");

print '# ';

Alive::setup(-name => '#');

foreach my $i (1..2000) {
    tack;
} _say;

is (tacks, 2001, "first 2001 tacks");

my $tick = tack;

$tick->();

is (tacks, 2003, "first tick");

my $tc = Alive::get_tack_counter();

is ($$tc, 2003, "get_tack_counter()");

tack;

is ($$tc, 2004, "tack_counter++");

my $tick_2_count = 0;

my $tick_2 = Alive::create(-factor       => 2,
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

Alive::silent();

foreach my $i (1..200) {
    tack;
    $tick_2->();
}

is ($tick_2_count, 400, "silent() but counting ticks");

Alive::all_off();

foreach my $i (1..200) {
    tack;
    $tick_2->();
}

is ($tick_2_count, 400, "all_off() without counting ticks");

print "# ";

Alive::on();

foreach my $i (1..200) {
    tack;
    $tick_2->();
} _say;

is ($tick_2_count, 600, "on() printing and counting ticks");

done_testing();


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

