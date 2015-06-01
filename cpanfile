requires perl => '5.016';

requires   'Inline::CPP';
requires   'Lingua::Stem::Snowball';
requires   'Parse::RecDescent';
recommends 'Term::ReadLine::Gnu';

on test => sub
{
    requires 'Test::Most';
};
