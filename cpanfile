requires 'perl', '5.016';
requires 'Inline::CPP';
requires 'Lingua::Stem::Snowball';
requires 'Marpa::R2';

on test => sub
{
    requires 'Test::Most';
};
