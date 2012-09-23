use strict;
use warnings;
use Test::More;
use Test::Exception;
use t::Util;
use WebService::YouTube::Lite;

subtest 'basic' => sub {

    my $youtube = WebService::YouTube::Lite->new;

    SKIP: {
        skip "http connect error" if !t::Util::http_check;

        my $res = $youtube->search(q => "perfume");
        ok $res->[0]->{title}, "some title";
    }

    dies_ok { $youtube->search } "no q parameter";
};

done_testing;
