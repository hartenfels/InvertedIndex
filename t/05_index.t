use Test::Most;
use utf8;
use feature qw(fc);
use Encode qw(decode);
use InvertedIndex;


my @DOCS = (
    'The quick brown fox jumped over the lazy x dog.',
    'Fußball with the ß . x',
    'the fussball with X a double-s',
    'FUSSBALL WITH THE X UPPER-CASE',
);


ok my $index = InvertedIndex->new, 'creating index works';
$index->index($_, $DOCS[$_]) for 0 .. $#DOCS;

sub fetch_ok
{
    my ($token, $want, $name) = @_;
    my $row = $index->find($token);
    is_deeply \@$row, $want, $name;
}

fetch_ok 'nothing',  [],       'fetching empty row';
fetch_ok 'quick',    [0],      'fetching a single row exactly';
fetch_ok 'QuIcK',    [0],      'fetching a single row in wrong case';
fetch_ok 'x',        [0 .. 3], 'fetching all rows';

fetch_ok 'fußball',  [1 .. 3], 'fetching fußball folds case';
fetch_ok 'fussball', [1 .. 3], 'fetching fussball also works';
fetch_ok 'FUSSBALL', [1 .. 3], 'so does fetching FUSSBALL';

fetch_ok 'dog',      [],       'punctuation is not stripped';
fetch_ok 'dog.',     [0],      'fetching with punctuation works';

fetch_ok 'foxes',    [0],      'stemmer works as expected';
fetch_ok 'FUßBAL',   [1 .. 3], 'stemming happens after case folding';


fetch_ok 'the',      [],       'stopwords are stripped';
fetch_ok '.',        [],       'punctuation on its own too';


done_testing
