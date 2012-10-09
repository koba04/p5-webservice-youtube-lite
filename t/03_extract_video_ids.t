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

        my $res = $youtube->extract_video_ids("http://matome.naver.jp/odai/2132876130063084301");
        ok scalar grep { $_ eq '8VXCM5QUalU' } @{ $res->{ids} }, 'extract video id';
        is $res->{title}, '『邦楽ロックバンド 解散ライブの動画』まとめ - NAVER まとめ', 'title';

        $res = $youtube->extract_video_ids("http://google.com/");
        is scalar @{ $res->{ids} }, 0, 'no video id';

        $res = $youtube->extract_video_ids("http://www.youtube.com/results?search_query=radiohead");
        ok scalar @{ $res->{ids} }, 'extract video id (in youtube)';

    }

    dies_ok { $youtube->extract_video_ids } "no url parameter";
};

done_testing;
