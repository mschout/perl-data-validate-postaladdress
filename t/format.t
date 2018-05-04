#!/usr/bin/env perl

use utf8;
use strict;
use warnings;
use Test::More;
use Test::Warnings;
use Test::LongString;
use Text::Template 'fill_in_string';
use Data::Validate::PostalAddress;

# Hopefully these aren't real addresses.
# Generated with a Fake Name Generator
my @tests = (
    # full US address
    test_case(US => {
            name           => 'Randal Jackson',
            organization   => 'Gas Depot',
            street_address => '366 Wayside Lane',
            city           => 'Concord',
            state          => 'CA',
            zip            => '94520'
        },
        '{{$name}}%n{{$organization}}%n{{$street_address}}%n{{$city}}, {{$state}} {{$zip}}'
    ),

    # US address no organization field
    test_case(US => {
            name           => 'Randal Jackson',
            street_address => '366 Wayside Lane',
            city           => 'Concord',
            state          => 'CA',
            zip            => '94520'
        },
        '{{$name}}%n{{$street_address}}%n{{$city}}, {{$state}} {{$zip}}'
    ),

    # CA address, full
    test_case(CA => {
            name           => 'Tracy Hanson',
            organization   => 'Magik Grey',
            street_address => '1691 Avenue Royale',
            city           => 'Quebec',
            state          => 'QC',
            zip            => 'G1E 2L3'
        },
        '{{$name}}%n{{$organization}}%n{{$street_address}}%n{{$city}} {{$state}} {{$zip}}'
    ),

    # CA address, minimal
    test_case(CA => {
            street_address => '1691 Avenue Royale',
            city           => 'Quebec',
            state          => 'QC',
            zip            => 'G1E 2L3'
        },
        '{{$street_address}}%n{{$city}} {{$state}} {{$zip}}'
    ),

    test_case(TN => {
            name           => 'Kim Phelps',
            street_address => '20 Rue de fes',
            city           => 'El Moutbasta',
            zip            => '3111'
        },
        '{{$name}}%n{{$street_address}}%n{{$zip}} {{$city}}'
    ),

    test_case(DE => {
            name           => 'Phyllis Baggs',
            street_address => 'Grønvangen 50',
            city           => 'Vejle',
            zip            => '7110'
        },
        '{{$name}}%n{{$street_address}}%n{{$zip}} {{$city}}'
    ),

    # multi-line street address
    test_case(US => {
            name           => 'Randal Jackson',
            organization   => 'Gas Depot',
            street_address => ['366 Wayside Lane', 'Apt #123'],
            city           => 'Concord',
            state          => 'CA',
            zip            => '94520'
        },
        # can't use a template here due to the arrayref
        join($/,
            'Randal Jackson',
            'Gas Depot',
            '366 Wayside Lane',
            'Apt #123',
            'Concord, CA 94520'
        )
    )
);

for my $test (@tests) {
    my ($country, $args, $expected) = @$test;
    my $obj = new_ok 'Data::Validate::PostalAddress', [$country];

    # test as both a hash and a hashref
    is_string $obj->format(%$args), $expected;
    is_string $obj->format($args), $expected;
}

done_testing;

# generate a test case
sub test_case {
    my ($country, $data, $template) = @_;

    $template =~ s/\%n/\n/g;

    return [$country, $data, fill_in_string($template, hash => $data)];
}
