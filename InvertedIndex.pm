use Inline CPP => config => ccflags => '-std=c++11 -Wall -Wextra -pedantic';
use Inline CPP => './InvertedIndex.cpp';


package Row
{

    use overload '@{}' => sub { shift->listref };

    sub build
    {
        my $self = shift->new;
        $self->add_id($_) for @_;
        $self
    }

}


1
