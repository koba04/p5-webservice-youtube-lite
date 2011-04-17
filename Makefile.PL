use inc::Module::Install;
name 'WebService-YouTube-Lite';
all_from 'lib/WebService/YouTube/Lite.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
