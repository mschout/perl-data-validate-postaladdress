# Postal Address Utilties Library

This library is a work in progress for postal address verification tools.

Because this is a work in progress the API should be considered unstable at
this point.  Even the module name might change.

## Examples

What can you do with this library?  Here are some examples:

```perl
use Data::Validate::PostalAddress;

# initialize library with a country code
my $dv = Data::Validate::PostalAddress->new('CA');

# does Canada use postal codes?
if ($dv->has_postal_code) {
    ...
}

# check if a postal code matches the syntax for Canada
unless ($pc =~ $dv->postal_code_regex) {
    ...
}

# or equivalently:
unless ($dv->is_valid_postal_code($pc)) {
    ...
}

# what are postal codes called in Canada?
print $dv->postal_code_name;

# show sample postal codes for Canada
print join ', ', $dv->postal_code_examples;

# HTML5 style pattern for postal codes in Canada
print $dv->postal_code_pattern;

# does Canada have states/provinces
unless ($dv->has_state) {
    ...
}

# what are states/provinces called in Canada?
print ucfirst $dv->state_name_type;

# what are the valid state/province names in Canada?
print join ', ', $dv->state_names;

# print localized state names (e.g.: for Canada/US this is the two letter
# abbreviations)
print join ', ', $dv->states;

# check if state name is valid for Canada
unless ($dv->is_valid_state_name($state)) {
    ...
}

# Check if state abbreviation is valid for Canada
unless ($dv->is_valid_state($state)) {
    ...
}
```

