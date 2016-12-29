use strict;
use Test::More 0.98;

use JSON5;
use JSON5::Parser;

my $parser = JSON5::Parser->new->allow_nonref;

is $parser->parse(q!"\\\b\t\n\f\r\"\'\/"!), "\x5C\x08\x09\x0A\x0C\x0D\x22\x27\x2F", 'value: '.q!"\\\\\b\t\n\f\r\"\'\/"!;
is $parser->parse(qq!"a\\\n  b\\\nc"!), "a  bc", 'value: '.q!"a\\\n  b\\\nc"!;

eval { $parser->parse(qq!"a\n  b\nc"!) };
like $@, qr/^Syntax Error: line:1/, 'value: '.q!"a\n  b\nc"!.' should be syntax error';

done_testing;
