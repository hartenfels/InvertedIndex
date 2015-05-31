requires 'perl', '5.016';
requires 'Inline::CPP';
requires 'Lingua::Stem::Snowball';
requires 'Parse::RecDescent';

on test => sub
{
    requires 'Test::Most';
};
