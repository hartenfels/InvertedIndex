use Test::Most;
use Query;
*p = *Query::parse;


dies_ok { p('') }      'empty query dies';
dies_ok { p(' ') }     'query with just whitespace dies';
dies_ok { p('a a') }   'double token dies';
dies_ok { p('a a a') } 'invalid operand dies';
dies_ok { p('a &') }   'missing operand dies';
dies_ok { p('((a)') }  'mismatched parens dies';
dies_ok { p('(') }     'single paren dies';
dies_ok { p('(())') }  'just parens dies';


is_deeply p('a'),      \'a',    'query with single token';
is_deeply p(' asdf '), \'asdf', 'whitespace is ignored';
is_deeply p('((a))'),  \'a',    'parens are stripped';


is_deeply p('a & b'), [and_with => \'a', \'b'], 'simple and';
is_deeply p('a | b'), [ or_with => \'a', \'b'], 'simple or';
is_deeply p('a - b'), [but_with => \'a', \'b'], 'simple but';

is_deeply p('a & b & c'), [and_with => \'a', \'b', \'c'], 'n-ary and';
is_deeply p('a | b | c'), [ or_with => \'a', \'b', \'c'], 'n-ary or';
is_deeply p('a - b - c'), [but_with => \'a', \'b', \'c'], 'n-ary but';

is_deeply p('& | -'), [or_with => \'&', \'-'], 'operators as tokens';


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