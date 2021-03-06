use strict;
use warnings;
use feature qw(fc);
use Lingua::Stem::Snowball;
use Inline CPP => config => ccflags => '-std=c++11 -Wall -Wextra -pedantic';
use Inline CPP => './InvertedIndex.cpp';


package InvertedIndex;

my $stemmer = Lingua::Stem::Snowball->new(lang => 'en');
# http://www.textfixer.com/resources/common-english-words.txt
my %stopwords = map { $_ => undef } split ' ', <<HERE;
a able about across after all almost also am among an and any are as at be
because been but by can cannot could dear did do does either else ever every
for from get got had has have he her hers him his how however i if in into is
it its just least let like likely may me might most must my neither no nor not
of off often on only or other our own rather said say says she should since so
some than that the their them then there these they this tis to too twas us
wants was we were what when where which while who whom why will with would yet
you your . , ' " -
HERE


sub index
{
    my ($self, $id, $document) = @_;
    my @words = grep { not exists $stopwords{$_} } split ' ', fc $document;
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
