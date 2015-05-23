use Test::Most;
use InvertedIndex;


is_deeply \@{Row->new},   [], 'Row->new is empty';
is_deeply \@{Row->build}, [], 'Row->build is empty';


my $ordered = Row->build(1, 2, 3);
is_deeply \@$ordered, [1, 2, 3], 'build ordered row with elements';

$ordered->add_id(4);
$ordered->add_id(5);
is_deeply \@$ordered, [1, 2, 3, 4, 5], 'adding ordered ids to row';

$ordered->add_id(5);
is_deeply \@$ordered, [1, 2, 3, 4, 5], 'adding same element again does nothing';


my $unordered = Row->build(15, 2, 4, 2);
is_deeply \@$unordered, [2, 4, 15], 'building unordered row sorts it';

$unordered->add_id(0);
is_deeply \@$unordered, [0, 2, 4, 15], 'add element at beginning';

$unordered->add_id(99);
is_deeply \@$unordered, [0, 2, 4, 15, 99], 'add element at end';

$unordered->add_id(12);
is_deeply \@$unordered, [0, 2, 4, 12, 15, 99], 'add element in middle';

$unordered->add_id(0);
is_deeply \@$unordered, [0, 2, 4, 12, 15, 99],
          'add existing element at beginning does nothing';

$unordered->add_id(99);
is_deeply \@$unordered, [0, 2, 4, 12, 15, 99],
          'add existing element at end does nothing';

$unordered->add_id(12);
is_deeply \@$unordered, [0, 2, 4, 12, 15, 99],
          'add existing element in middle does nothing';


done_testing
