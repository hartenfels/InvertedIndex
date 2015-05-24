use strict;
use warnings;
use feature qw(fc);
use Inline CPP => config => ccflags => '-std=c++11 -Wall -Wextra -pedantic';
use Inline CPP => './InvertedIndex.cpp';


package InvertedIndex
{

    sub index
    {
        my ($self, $document) = @_;
        my $id = $self->add_document($document);
        $self->add_token($id, $_) for split ' ', fc $document;
    }

}


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
