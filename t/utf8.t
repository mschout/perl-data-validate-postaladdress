#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;
use Data::Validate::PostalAddress;

my $obj = new_ok 'Data::Validate::PostalAddress', ['BR'];

is $obj->data->{states}{SP}, "S\x{e3}o Paulo";

done_testing;
