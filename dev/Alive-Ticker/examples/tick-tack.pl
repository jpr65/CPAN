use strict;
use warnings;
$| = 1;

use v5.10;

use Alive::Ticker qw(tick tack tacks);

foreach my $i (1..10000) {
    tick;
    if ($i % 73 == 0) {
	tack;
    }
}

say '';
say tacks . " matches found.";
