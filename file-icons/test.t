#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 8;

BEGIN { use_ok('Math::Calculator') }

my $calc = Math::Calculator->new();
isa_ok($calc, 'Math::Calculator');

is($calc->add(2, 3), 5, 'addition works correctly');
is($calc->subtract(10, 4), 6, 'subtraction works correctly');
is($calc->multiply(3, 7), 21, 'multiplication works correctly');
is($calc->divide(15, 3), 5, 'division works correctly');

eval { $calc->divide(1, 0) };
like($@, qr/division by zero/i, 'division by zero throws error');

ok($calc->can('sqrt'), 'calculator has sqrt method');

done_testing();
