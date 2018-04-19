package Data::Validate::PostalAddress;

# ABSTRACT: Postal Address Validation Library

use strictures 2;
use Moo;
use Path::Tiny qw(path);
use Cpanel::JSON::XS qw(decode_json);
use List::Util qw(any);

=method country(): string

Get the country code.

=cut

has data_dir => (is => 'lazy');

has country => (is => 'ro');

has default_data => (is => 'lazy');

has data => (is => 'lazy');

around BUILDARGS => sub {
    my ($orig, $class) = splice @_, 0, 2;

    if (@_ == 1 and not ref $_[0]) {
        return $class->$orig(country => shift);
    }
    else {
        return $class->$orig(@_);
    }
};

=method has_field(string field): boolean

returns true if the country has the given field.  See L<FIELD NAMES>

=cut

sub has_field {
    my ($self, $field) = @_;

    if (any { $_ eq $field } @{ $self->data->{fields} }) {
        return 1;
    }
    else {
        return 0;
    }
}

=method required_fields(): list

get the list of required fields.  See L<FIELD NAMES> for the list of fields
that might be returned.

=cut

sub required_fields {
    my $self = shift;

    return @{ $self->data->{required_fields} };
}

=method has_postal_code(): boolean

returns true if this country has a postal code field.

=cut

sub has_postal_code {
    my $self = shift;

    return $self->has_field('zip');
}

=method postal_code_pattern(): string

returns the postal code pattern for this country.

=cut

sub postal_code_pattern {
    my $self = shift;

    return $self->data->{zip_pattern};
}

=method is_valid_postal_code(string postal_code): boolean

Returns true if the given string appears to be a valid postal code for the country.

=cut

sub is_valid_postal_code {
    my ($self, $code) = @_;

    unless (defined $code) {
        return 0;
    }

    my $regex = $self->postal_code_regex;

    if ($code =~ $regex) {
        return 1;
    }
    else {
        return 0;
    }
}

=method postal_code_regex(): string

Returns a Regexp object representing the C<postal_code_pattern>.

=cut

sub postal_code_regex {
    my $self = shift;

    my $pattern = $self->data->{zip_pattern} or return;

    my $regex = qr/^$pattern$/i;

    return $regex;
}

=method postal_code_name(): string

Get the name of the postal code.  Default is C<postal>.  Possible values are:

=for :list
* eircode
* pin
* postal
* zip

=cut

sub postal_code_name {
    my $self = shift;

    return $self->data->{zip_name_type};
}

=method postal_code_examples(): list

Get a list of postal code examples for this country.

=cut

sub postal_code_examples {
    my $self = shift;

    my $examples = $self->data->{zip_examples} or return;

    return @$examples;
}

=method has_state(): boolean

Returns true if this country is subdivided into states or provinces etc.

=cut

sub has_state {
    my $self = shift;

    return $self->has_field('state');
}

=method state_name_type(): string

Returns the name of the state type.  For example, in the US, this returns
C<state>.  For Canada, this returns C<province>.  For Taiwan, this returns
C<county>.  Possible values returned are:

=for :list
* area
* county
* department
* district
* do_si
* emirate
* island
* oblast
* parish
* prefecture
* province
* state

=cut

sub state_name_type {
    my $self = shift;

    return $self->data->{state_name_type};
}

=method state_names(): list

Return the state names.  For the US this is the list of full length state
names.  For other countries this is generally the latinized version of the
state names.

=cut

sub state_names {
    my $self = shift;

    my $states = $self->data->{states} or return;

    return sort values %$states;
}

=method states(): list

Return the localized state names.  For the US this is the two letter state codes for example.

=cut

sub states {
    my $self = shift;

    my $states = $self->data->{states} or return;

    return sort keys %$states;
}

=method is_valid_state(string state): boolean

Returns true if C<$state> is a valid state.  This compares against the values returned by L<states()>.

=cut

sub is_valid_state {
    my ($self, $state) = @_;

    my $states = $self->data->{states} or return 0;

    return defined $states->{$state} ? 1 : 0;
}

=method is_valid_state_name(string name): boolean

Returns true if C<$name> is a valdi state name.  This compares against the
values returned by L<state_names()>.

=cut

sub is_valid_state_name {
    my ($self, $name) = @_;

    my $states = $self->data->{states} or return 0;

    if (any { lc $_ eq lc $name } values %$states) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _load_country_file {
    my ($self, $country) = @_;

    my $path = path($self->data_dir, $country . '.json');

    # if we don't have any data for this country, return empty hash.  Default
    # data will be merged in.
    unless ($path->exists) {
        return {};
    }

    my $json = $path->slurp;

    return decode_json($json);
}

sub _build_default_data {
    my $self = shift;

    return $self->_load_country_file('default');
}

sub _build_data {
    my $self = shift;

    my $default_data = $self->default_data;

    my $country_data = $self->_load_country_file($self->country);

    while (my ($key, $value) = each %$default_data) {
        unless (defined $$country_data{$key}) {
            $$country_data{$key} = $value;
        }
    }

    return $country_data;
}

sub _build_data_dir {
    (my $mod = __PACKAGE__ . '.pm') =~ s|::|/|g;

    path($INC{$mod})
        ->absolute
        ->parent
        ->child('PostalAddress/data')
        ->stringify;
}

1;

__END__

=for Pod::Coverage BUILDARGS

=head1 SYNOPSIS

 # WARNING ALPHA RELEASE!!
 # API SUBJECT TO CHANGE!
 use Data::Validate::PostalAddress;

 my $dv = Data::Validate::PostalAddress->new('US');

 unless ($dv->is_valid_postal_code('49464')) {
     ...
 }

 unless ($dv->is_valid_state('MI')) {
     ...
 }

 unless ($dv->is_valid_state_name('Michigan')) {
     ...
 }

=head1 DESCRIPTION

B<WARNING! ALPHA RELEASE!>

This modules in considered Alpha quality at this time.  As such, the API may
change in a future release.

This module provides a way to validate fields of postal addresses.  This module
is based on a subset of the Google Chromium Address data, found at
L<https://chromium-i18n.appspot.com/ssl-address>.

=head2 FIELD NAMES

The country data for this module supports the following address field names by
methods such as L<has_field()>:

=for :list
* name
The addressee
* organization
The Addressee organization
* street_address
The Street address lines
* city
The city
* state
The state or province etc.
* zip
The zip or postal code

