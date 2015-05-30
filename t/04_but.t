use Test::Most;
use InvertedIndex;


sub but_rows
{
    my ($lhs, $rhs, $want, $name) = @_;
    my $row = Row->build(@$lhs);
    $row->but_with(Row->build(@$rhs));
    is_deeply \@$row, $want, $name;
}


but_rows [],        [],        [],        'BUTing empty rows';
but_rows [1, 2, 3], [],        [1, 2, 3], 'BUTing full with empty row';
but_rows [],        [1, 2, 3], [],        'BUTing empty with full row';
but_rows [1, 2, 3], [1, 2, 3], [],        'BUTing identical rows';


but_rows [7, 27, 28], [6, 14, 27], [7, 28], 'BUTing stuff';


done_testing
