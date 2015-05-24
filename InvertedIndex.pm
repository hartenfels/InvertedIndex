use strict;
use warnings;
use feature qw(fc);
use Lingua::Stem::Snowball;
use Inline CPP => config => ccflags => '-std=c++11 -Wall -Wextra -pedantic';
use Inline CPP => './InvertedIndex.cpp';


package InvertedIndex;

my $stemmer = Lingua::Stem::Snowball->new(lang => 'en');

sub index
{
    my ($self, $document) = @_;
    my $id    = $self->add_document($document);
    my @words = split ' ', fc $document;
    $stemmer->stem_in_place(\@words);
    $self->add_token($id, $_) for @words;
}

sub find
{
    my ($self, $token) = @_;

    my @words = (fc $token);
    $stemmer->stem_in_place(\@words);

    my $row = Row->new;
    $self->fetch($words[0], $row);
    $row
}


package Row;

use overload '@{}' => sub { shift->listref };

sub build
{
    my $self = shift->new;
    $self->add_id($_) for @_;
    $self
}


1
