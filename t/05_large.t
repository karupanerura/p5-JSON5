use strict;
use warnings;
use Test::More;
use JSON5;

# Regression test for GitHub issue #2:
# objects/arrays with more than 100 entries used to trigger
# "Deep recursion" warnings because _parse_object_kv and
# _parse_array_value recursed once per entry.

my @warnings;
local $SIG{__WARN__} = sub { push @warnings, @_ };

subtest 'large object (1000 pairs)' => sub {
    my $doc = '{' . join(',', map { sprintf "k%04d: 'v%04d'", $_, $_ } 1 .. 1000) . '}';
    my $data = decode_json5($doc);
    is scalar(keys %$data), 1000, 'all pairs parsed';
    is $data->{k0001}, 'v0001', 'first pair';
    is $data->{k1000}, 'v1000', 'last pair';
};

subtest 'large array (1000 elements)' => sub {
    my $doc = '[' . join(',', 1 .. 1000) . ']';
    my $data = decode_json5($doc);
    is scalar(@$data), 1000, 'all elements parsed';
    is $data->[0], 1, 'first element';
    is $data->[999], 1000, 'last element';
};

subtest 'trailing comma still allowed' => sub {
    is_deeply decode_json5(q{{a: 1, b: 2,}}), { a => 1, b => 2 }, 'object';
    is_deeply decode_json5(q{[1, 2,]}), [1, 2], 'array';
};

subtest 'nested structure still works' => sub {
    is_deeply decode_json5(q{{a: [1, {b: 2}], c: {d: [3]}}}),
        { a => [1, { b => 2 }], c => { d => [3] } }, 'nested';
};

subtest 'invalid input still fails' => sub {
    ok !eval { decode_json5(q{{a:}}); 1 }, 'missing value';
    ok !eval { decode_json5(q{[1 2]}); 1 }, 'missing comma';
};

ok !grep({ /Deep recursion/ } @warnings), 'no Deep recursion warnings'
    or diag join '', @warnings;

done_testing;
