use Test::Most;
use Query;
*p = *Query::parse;


ok !defined p(''),      'empty query fails';
ok !defined p(' '),     'query with just whitespace fails';
ok !defined p('a a'),   'double token fails';
ok !defined p('a a a'), 'invalid operand fails';
ok !defined p('a &'),   'missing operand fails';
ok !defined p('((a)'),  'mismatched parens fails';
ok !defined p('('),     'single paren fails';
ok !defined p('(())'),  'just parens fails';


is_deeply p('a'),      \'a',    'query with single token';
is_deeply p(' asdf '), \'asdf', 'whitespace is ignored';
is_deeply p('((a))'),  \'a',    'parens are stripped';


is_deeply p('a & b'), [and_with => \'a', \'b'], 'simple and with `&`';
is_deeply p('a | b'), [ or_with => \'a', \'b'], 'simple or with `|`';
is_deeply p('a - b'), [but_with => \'a', \'b'], 'simple but with `-`';

is_deeply p('a and b'), [and_with => \'a', \'b'], 'simple and with `and`';
is_deeply p('a or  b'), [ or_with => \'a', \'b'], 'simple or with `or`';
is_deeply p('a but b'), [but_with => \'a', \'b'], 'simple but with `but`';

is_deeply p('a & b & c'), [and_with => \'a', \'b', \'c'], 'n-ary and';
is_deeply p('a | b | c'), [ or_with => \'a', \'b', \'c'], 'n-ary or';
is_deeply p('a - b - c'), [but_with => \'a', \'b', \'c'], 'n-ary but';

is_deeply p(' &  |   - '), [or_with => \'&',   \'-'  ], '&/|/- as tokens';
is_deeply p('and or but'), [or_with => \'and', \'but'], 'and/or/but as tokens';

is_deeply p('a and b & c AND d'), [and_with => \'a', \'b', \'c', \'d'],
          'mixing operator symbols and words with different capitalization';


is_deeply p('a & b | c - d'),
          [but_with => [or_with => [and_with => \'a', \'b'], \'c'], \'d'],
          'operator precedence and > or > but';

is_deeply p('a - b | c & d'),
          [but_with => \'a', [or_with => \'b', [and_with => \'c', \'d']]],
          'operator precedence but < or < and';

is_deeply p('a & (b | (c - d))'),
          [and_with => \'a', [or_with => \'b', [but_with => \'c', \'d']]],
          'parens change precendence';


done_testing
