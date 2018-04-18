#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;

use_ok 'Data::Validate::PostalAddress';

my $obj = new_ok 'Data::Validate::PostalAddress', ['US'];

is $obj->country, 'US';
ok $obj->has_postal_code, 'US has postal codes';
ok $obj->has_state;
is $obj->state_name_type, 'state';
is $obj->postal_code_pattern, '(\d{5})(?:[ \-](\d{4}))?';
ok $obj->is_valid_state('CA'), 'is_valid_state';
ok $obj->is_valid_state_name('California'), 'is_valid_state_name';

my $regex = $obj->postal_code_regex;
is ref $regex, 'Regexp';

ok '75229' =~ $regex, 'valid postal code';
ok 'ABC12' !~ $regex, 'bad postal code format';
ok '75229-1234' =~ $regex, 'zip+4';

ok $obj->is_valid_postal_code('75229');
ok $obj->is_valid_postal_code('75229-1234');
ok ! $obj->is_valid_postal_code('752299');
ok ! $obj->is_valid_postal_code('ABC123');

done_testing;
