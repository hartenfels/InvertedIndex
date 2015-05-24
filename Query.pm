package Query;
use strict;
use warnings;
use feature qw(fc);
use InvertedIndex;
use Marpa::R2;

my $grammar = <<'END';

    lexeme default = latm => 1

    Query    ::= But                     action => ::first
    But      ::= Or+   separator => but  action => do_but
    Or       ::= And+  separator => or   action => do_or
    And      ::= Atom+ separator => and  action => do_and
    Atom     ::= '(' But ')'             action => do_par
               |    Token                action => do_tok

    Token      ~ text
    :discard   ~ whitespace

    text       ~ [\S]+
    and        ~ '&'
    or         ~ '|'
    but        ~ '-'
    whitespace ~ [\s]+

END


my $parser = Marpa::R2::Scanless::G->new({source => \$grammar});

sub parse { ${$parser->parse(\shift, 'Query')} }


sub Query::do_tok
{
    my (undef, $token) = @_;
    bless [fc $token] => 'Query::Token'
}

sub Query::do_op
{
    my ($op, undef, @args) = @_;
    return $args[0] if @args == 1;
    bless [$op, @args] => 'Query::Op'
}

sub Query::do_but { Query::do_op(but_with => @_) }
sub Query::do_or  { Query::do_op( or_with => @_) }
sub Query::do_and { Query::do_op(and_with => @_) }
sub Query::do_par { $_[2] }


sub Query::Token::run
{
    my ($self, $index) = @_;

    $InvertedIndex::stemmer->stem_in_place($self);

    my $row = Row->new;
    $index->fetch($self->[0], $row);
    $row
}

sub Query::Op::run
{
    my ($self, $index)    = @_;
    my ($op, $lhs, @args) = @$self;

    my $row = $lhs->run($index);
    $row->$op($_->run($index)) for @args;

    $row
}
