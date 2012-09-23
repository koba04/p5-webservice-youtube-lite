package t::Util;

use strict;
use warnings;
use Furl;

sub http_check {

    my $res = Furl->new->get("http://google.com");
    return $res->is_success;
}

1;
