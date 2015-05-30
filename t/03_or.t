use Test::Most;
use InvertedIndex;


sub or_rows
{
    my ($lhs, $rhs, $want, $name) = @_;
    my $row = Row->build(@$lhs);
    $row->or_with(Row->build(@$rhs));
    is_deeply \@$row, $want, $name;
}


or_rows [],        [],        [],        'ORing empty rows';
or_rows [1, 2, 3], [],        [1, 2, 3], 'ORing full with empty row';
or_rows [],        [1, 2, 3], [1, 2, 3], 'ORing empty with full row';
or_rows [1, 2, 3], [1, 2, 3], [1, 2, 3], 'ORing identical rows';


or_rows [7, 27, 28], [6, 14, 27], [6, 7, 14, 27, 28], 'ORing stuff';


done_testing
