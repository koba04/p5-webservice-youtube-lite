package WebService::YouTube::Lite;
use strict;
use warnings;
our $VERSION = '0.02';

use Carp;
use URI;
use Furl;
use JSON;
use List::MoreUtils qw/uniq/;

sub new {
    my ($class, %opt) = @_;

    # set default value
    my $self = {
        base_uri        => URI->new('http://gdata.youtube.com/feeds/api/videos'),
        ua              => Furl->new,
    };
    return bless $self, $class;
}

sub search {
    my $self = shift;
    my %param = @_;

    croak 'Please Set Parameter "q"' unless $param{q};

    my $base_param = {
        alt             => 'jsonc',
        restriction     => 'JP',
        v               => 2,
        max_results     => 10,
        format          => 5,
        orderby         => 'relevance',
    };

    my $merge_param = {
        %$base_param,
        %param,
    };
    my $response = $self->_http_request(param => $merge_param, format => 'json');
    my $result;
    if ( $response->{data} && $response->{data}->{items} ) {
        $result = $response->{data}->{items};
    }
    return $result;
}

sub fetch_by_id {
    my $self = shift;
    my ($id) = @_;
    croak 'need arguments "video id"' unless $id;

    my $res_json = $self->_http_request(
        uri     => URI->new('http://gdata.youtube.com/feeds/api/videos/' . $id),
        param   => { alt => 'json' },
        format  => 'json',
    );
    my $entry = $res_json->{entry};
    my $video_info = {
        id          => $id,
        author      => $entry->{author}->[0]->{name}->{'$t'},
        title       => $entry->{title}->{'$t'},
        category    => $entry->{category}->[1]->{label},
        comment     => $entry->{content}->{'$t'},
        duration    => $entry->{'media$group'}->{'media$content'}->[0]->{duration},
        published   => $entry->{published}->{'$t'},
        favorite    => $entry->{'yt$statistics'}->{favoriteCount},
        view        => $entry->{'yt$statistics'}->{viewCount},
        thumbnail   => {
            middle  => {
                width   => $entry->{'media$group'}->{'media$thumbnail'}->[0]->{width},
                height  => $entry->{'media$group'}->{'media$thumbnail'}->[0]->{height},
                url     => $entry->{'media$group'}->{'media$thumbnail'}->[0]->{url},
            },
            small   => {
                width   => $entry->{'media$group'}->{'media$thumbnail'}->[1]->{width},
                height  => $entry->{'media$group'}->{'media$thumbnail'}->[1]->{height},
                url     => $entry->{'media$group'}->{'media$thumbnail'}->[1]->{url},
            },
        }
    };
    return $video_info;
}

sub extract_video_ids {
    my $self = shift;
    my ($url) = @_;

    croak 'need arguments "url"' unless $url;

    my $content = $self->_http_request(uri => $url) || '';
    my @ids =  ($content =~ m{http://www\.youtube\.com/watch\?v=([a-zA-Z0-9\-_]+)(?:&|")?}sg);
    push @ids, ($content =~ m{http://www\.youtube\.com/v/([a-zA-Z0-9\-_]+)(?:&|")?}sg);
    push @ids, ($content =~ m{http://youtu\.be/([a-zA-Z0-9\-_]+)(?:&|")?}sg);

    return { ids => [ uniq @ids ] };
}

sub _http_request {
    my $self = shift;
    my (%args) = @_;

    my $uri = $args{uri} || $self->{base_uri};
    if ( $args{param} ) {
        $uri->query_form(%{ $args{param} });
    }
    my $res = $self->{ua}->get($uri);
    croak "http request error => [" . $uri->as_string . "][" . $res->status_line . "]" if !$res->is_success;
    my $content = $res->content;

    if ( $args{format} && $args{format} eq 'json' ) {
        $content = decode_json($content);
    }
    return $content;
}

1;
__END__

=head1 NAME

WebService::YouTube::Lite -

=head1 SYNOPSIS

  use WebService::YouTube::Lite;

=head1 DESCRIPTION

WebService::YouTube::Lite is

=head1 AUTHOR

koba04 E<lt>koba0004@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
