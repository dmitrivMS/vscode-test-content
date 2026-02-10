package Text::Slugify;

use strict;
use warnings;
use Exporter 'import';
use Unicode::Normalize qw(NFD);

our @EXPORT_OK = qw(slugify);

sub slugify {
    my ($text, %opts) = @_;
    my $separator = $opts{separator} // '-';

    $text = lc NFD($text);
    $text =~ s/\pM//g;              # strip combining marks
    $text =~ s/[^\w\s-]//g;         # remove non-word chars
    $text =~ s/[\s_]+/$separator/g;  # collapse whitespace/underscores
    $text =~ s/^$separator|$separator$//g;  # trim edges

    return $text;
}

1;

__END__

=head1 NAME

Text::Slugify - Convert strings to URL-friendly slugs

=cut
