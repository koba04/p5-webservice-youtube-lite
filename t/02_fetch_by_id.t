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

        my $res = $youtube->fetch_by_id("KsE9iXoXB6s");
        is $res->{title}, 'Underworld - Two Months Off', "title";

        $res = $youtube->fetch_by_id("NOSUCHVIDEOID");
        is $res, undef, 'no such video id';
    }

    dies_ok { $youtube->fetch_by_id } "no id parameter";
};

done_testing;
