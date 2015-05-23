use Test::Most;
use InvertedIndex;


sub and_rows
{
    my ($lhs, $rhs, $want, $name) = @_;
    my $row = Row->build(@$lhs);
    $row->and_with(Row->build(@$rhs));
    is_deeply \@$row, $want, $name;
}


and_rows [],        [],        [],        'ANDing empty rows';
and_rows [1, 2, 3], [],        [],        'ANDing full with empty row';
and_rows [],        [1, 2, 3], [],        'ANDing empty with full row';
and_rows [1, 2, 3], [1, 2, 3], [1, 2, 3], 'ANDing identical rows';


and_rows [7, 27, 28], [6, 14, 27], [27], 'ANDing stuff';
diag 'TODO: make more AND tests';


done_testing
