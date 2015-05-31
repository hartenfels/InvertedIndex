package Query;
use strict;
use warnings;
use feature qw(fc);
use Marpa::R2;

my $separator = 'proper => 1 separator';
my $grammar   = <<END;

    lexeme default = latm => 1

    Query    ::= But                      action => ::first
    But      ::= Or+   $separator => but  action => do_but
    Or       ::= And+  $separator => or   action => do_or
    And      ::= Atom+ $separator => and  action => do_and
    Atom     ::= '(' But ')'              action => do_par
               |    Token                 action => do_tok

    Token      ~ text
    :discard   ~ whitespace

    text       ~ [^\\s()]+
    and        ~ '&'
    or         ~ '|'
    but        ~ '-'
    whitespace ~ [\\s]+

END


my $parser = Marpa::R2::Scanless::G->new({source => \$grammar});

sub parse { ${$parser->parse(\shift, 'Query')} }


sub do_tok
{
    my (undef, $token) = @_;
    bless \$token => 'Query::Token'
}

sub do_op
{
    my ($op, undef, @args) = @_;
    return $args[0] if @args == 1;
    bless [$op, @args] => 'Query::Op'
}

sub do_but { do_op(but_with => @_) }
sub do_or  { do_op( or_with => @_) }
sub do_and { do_op(and_with => @_) }
sub do_par { $_[2] }


sub Query::Token::run
{
    my ($self, $index) = @_;
    $index->find($$self)
}

sub Query::Op::run
{
    my ($self, $index)    = @_;
    my ($op, $lhs, @args) = @$self;

    my $row = $lhs->run($index);
    $row->$op($_->run($index)) for @args;

    $row
}
