use strict;
use Test::More 0.98;
use Test::Base::Less;

use JSON5;
use JSON5::Parser;

filters {
    expected => [qw/eval/],
};

my $parser = JSON5::Parser->new->allow_nonref->utf8;
for my $block (blocks) {
    my $parsed = eval { $parser->parse($block->input) };
    is_deeply $parsed, $block->expected, $block->get_section('name')
        or diag $block->input;
    diag $@ if $@;
}

done_testing;

__DATA__
===
--- name: empty object
--- input
{}
--- expected
{}

===
--- name: object keys
--- input
{
  $1:  "$1",
  _1:  '_1',
  a1:  'a1',
  aA:  'aA',
  '':  '',
  "1": '1',
}
--- expected
{'$1' => '$1', '_1' => '_1', a1 => 'a1', aA => 'aA', '' => '', 1 => '1'}

===
--- name: object values
--- input
{
  $1: [
    {$2: [3, 4.5, {$6: {$7: 8, $9: "10"}}, "1-1"]},
    {$2: [3, 4.5, {$6: {$7: 8, $9: "10"}}, "1-2"]},
  ],
  $2: [
    {$1: [3, 4.5, {$6: {$7: 8, $9: "10"}}, "2-1"]},
    {$1: [3, 4.5, {$6: {$7: 8, $9: "10"}}, "2-2"]},
  ],
}
--- expected
{
  '$1' => [
    {'$2' => [3, 4.5, {'$6' => {'$7' => 8, '$9' => "10"}}, "1-1"]},
    {'$2' => [3, 4.5, {'$6' => {'$7' => 8, '$9' => "10"}}, "1-2"]},
  ],
  '$2' => [
    {'$1' => [3, 4.5, {'$6' => {'$7' => 8, '$9' => "10"}}, "2-1"]},
    {'$1' => [3, 4.5, {'$6' => {'$7' => 8, '$9' => "10"}}, "2-2"]},
  ],
}

===
--- name: empty array
--- input
[]
--- expected
[]

===
--- name: array values
--- input
[null, true, false, NaN, Infinity, -Infinity, -1, 0, 1, -1.1, 0.1, 1.1, -.1, .1, 0x12AB, 0xcd34, 'str1', "str2", [], {},]
--- expected
[undef, JSON5::true, JSON5::false, 0+'NaN', 0+'Inf', 0+'-Inf', -1, 0, 1, -1.1, 0.1, 1.1, -0.1, 0.1, 4779, 52532, 'str1', "str2", [], {},]

===
--- name: nested object values
--- input
[
  {
    $1: [
      {$2: [3, 4.5, {$6: {$7: 8, $9: "10"}}, "1-1"]},
      {$2: [3, 4.5, {$6: {$7: 8, $9: "10"}}, "1-2"]},
    ],
    $2: [
      {$1: [3, 4.5, {$6: {$7: 8, $9: "10"}}, "2-1"]},
      {$1: [3, 4.5, {$6: {$7: 8, $9: "10"}}, "2-2"]},
    ],
  }
]
--- expected
[
  {
    '$1' => [
      {'$2' => [3, 4.5, {'$6' => {'$7' => 8, '$9' => "10"}}, "1-1"]},
      {'$2' => [3, 4.5, {'$6' => {'$7' => 8, '$9' => "10"}}, "1-2"]},
    ],
    '$2' => [
      {'$1' => [3, 4.5, {'$6' => {'$7' => 8, '$9' => "10"}}, "2-1"]},
      {'$1' => [3, 4.5, {'$6' => {'$7' => 8, '$9' => "10"}}, "2-2"]},
    ],
  }
]