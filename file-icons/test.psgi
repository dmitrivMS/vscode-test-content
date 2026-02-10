#!/usr/bin/env perl
use strict;
use warnings;
use Plack::Builder;
use JSON::MaybeXS qw(encode_json);
use Time::HiRes qw(gettimeofday tv_interval);

my $app = sub {
    my $env = shift;
    my $path = $env->{PATH_INFO};

    if ($path eq '/health') {
        return [200, ['Content-Type' => 'application/json'],
            [encode_json({ status => 'ok', uptime => time() - $^T })]];
    }

    if ($path eq '/') {
        return [200, ['Content-Type' => 'text/plain'], ['Welcome to the API']];
    }

    return [404, ['Content-Type' => 'text/plain'], ['Not Found']];
};

builder {
    enable 'AccessLog', format => 'combined';
    enable 'ContentLength';
    $app;
};
