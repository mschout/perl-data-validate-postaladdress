#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;
use Data::Validate::PostalAddress;

my $obj = new_ok 'Data::Validate::PostalAddress', ['XX'];

is_deeply $obj->data, $obj->default_data;

done_testing;
