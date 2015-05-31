package Query;
use strict;
use warnings;
use feature qw(fc);
use Parse::RecDescent;


my $parser = Parse::RecDescent->new(<<'END_GRAMMAR');

    query  : but /^\Z/               { $item[1]                }
    but    : <leftop: or   '-' or  > { Query::do_op(@item)     }
    or     : <leftop: and  '|' and > { Query::do_op(@item)     }
    and    : <leftop: atom '&' atom> { Query::do_op(@item)     }
    atom   : '(' but ')'             { $item[2]                }
           | /[^\s\(\)]+/            { Query::do_tok($item[1]) }

END_GRAMMAR

sub parse { $parser->query(@_) }


sub do_tok
{
    my ($token) = @_;
    bless \$token, 'Query::Token'
}

sub do_op
{
    my ($op, $args) = @_;
    return $args->[0] if @$args == 1;
    bless ["${op}_with", @$args] => 'Query::Op'
}


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
