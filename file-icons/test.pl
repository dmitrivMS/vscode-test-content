#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use Digest::SHA qw(sha256_hex);

my %checksums;

sub process_file {
    return unless -f $_;
    open my $fh, '<:raw', $_ or do {
        warn "Cannot open $_: $!\n";
        return;
    };
    local $/;
    my $content = <$fh>;
    close $fh;

    my $hash = sha256_hex($content);
    push @{ $checksums{$hash} }, $File::Find::name;
}

my $dir = $ARGV[0] || '.';
find(\&process_file, $dir);

for my $hash (sort keys %checksums) {
    next unless @{ $checksums{$hash} } > 1;
    print "Duplicates (SHA-256: $hash):\n";
    print "  $_\n" for @{ $checksums{$hash} };
}
