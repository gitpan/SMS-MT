#!/usr/bin/perl -w

use strict;
use lib qw(lib);
use Test;

BEGIN {
 plan tests => 1;
}

eval {
 require SMS::MT;
};
if ($@) {
 ok(0);
}
else {
 ok(1);
}