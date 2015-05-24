use Test::Most;
use utf8;
use feature qw(fc);
use Encode qw(decode);
use InvertedIndex;


my @DOCS = (
    'The quick brown fox jumped over the lazy dog.',
    'Fußball with the ß .',
    'the fussball with a double-s',
    'FUSSBALL WITH THE UPPER-CASE',
);


ok my $index = InvertedIndex->new, 'creating index works';
$index->index($_) for @DOCS;


for (0 .. $#DOCS)
{
    is decode('UTF-8', $index->get_document($_)), $DOCS[$_], "get_document($_)";
}

ok !defined $index->get_document(-1),           'small document ID gives undef';
ok !defined $index->get_document(scalar @DOCS), 'large document ID gives undef';


sub fetch_ok
{
    my ($token, $want, $name) = @_;
    my $row = $index->find($token);
    is_deeply \@$row, $want, $name;
}

fetch_ok 'nothing',  [],       'fetching empty row';
fetch_ok 'quick',    [0],      'fetching a single row exactly';
fetch_ok 'QuIcK',    [0],      'fetching a single row in wrong case';
fetch_ok 'the',      [0 .. 3], 'fetching all rows';

fetch_ok 'fußball',  [1 .. 3], 'fetching fußball folds case';
fetch_ok 'fussball', [1 .. 3], 'fetching fussball also works';
fetch_ok 'FUSSBALL', [1 .. 3], 'so does fetching FUSSBALL';

fetch_ok 'dog',      [],       'punctuation is not stripped';
fetch_ok 'dog.',     [0],      'fetching with punctuation works';
fetch_ok '.',        [1],      'fetching punctuation on its own works too';

fetch_ok 'foxes',    [0],      'stemmer works as expected';
fetch_ok 'FUßBAL',   [1 .. 3], 'stemming happens after case folding';


done_testing
