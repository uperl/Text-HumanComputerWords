package Text::HumanComputerWords;

use strict;
use warnings;
use 5.022;
use experimental qw( signatures );

# ABSTRACT: Split human and computer words in a naturalish manner
# VERSION

=head1 SYNOPSIS

 use Text::HumanComputerWords;

 my $hcw = Text::HumanComputerWords->new;

 foreach my $combo ($hcw->split("this is some text with a url: https://metacpan.org, a unix path name: /usr/local/bin and a windows path name: c:\\Windows"))
 {
   my($type, $word) = @$combo;
   if($type eq 'word')
   {
     # $word is a regular human word
     # this, is, some, etc.
   }
   elsif($type eq 'module')
   {
     # $word looks like a module
   }
   elsif($type eq 'url_link')
   {
     # $word looks like a URL
     # https://metacpan.org,
   }
   elsif($type eq 'path_name')
   {
     # $word looks like a windows or unix filename
     # /usr/local/bin
     # c:\\Windows
   }
 }

=head1 DESCRIPTION

This module splits a line of text into words.  It attempts to identify certain computer "words" and classify them as such.
The split on white space first, identify certain computer words (like URLs and file and directory paths) and then to split
the remaining words on Unicode word boundaries which is usually pretty good at identifying human words.

The intent is to split a paragraph into human and computer words so that they can be checked all at once.  The URLs for example
could be checked for 404s or other brokenness while the human words could be checked for spelling.

=head1 CONSTRUCTOR

=head2 new

 my $hcw = Text::HumanComputerWords->new(%options);

Creates a new instance of the splitter class.  The C<%options> hash lets you override some of the logic for identifying
"computer" words.  All are optional and the defaults are reasonable:

=over 4

=item path_name

 Text::HumanComputerWords->new(
   path_name => sub ($word) {
     # return true if $word looks like a filename path
   },
 );

This is a code reference which should return true if the C<$word> looks like a file or directory path.

=item url_link

 Text::HumanComputerWords->new(
   url_link => sub ($word) {
     # return true if $word looks like a URL
   },
 );

This is a code reference which should return true if the C<$word> looks like a URL.

=item module

 Text::HumanComputerWords->new(
   module => sub ($word) {
     # return true if $word looks like a computer programming module
   },
 );

=item skip

 Text::HumanComputerWords->new(
   skip => sub ($word) {
     # return true if $word should be skipped entirely
   },
 );

This is a code reference which should return true, if the C<$word> should be skipped entirely.  The default skip code reference
always returns false.

=back

=cut

sub new ($class, %args)
{
  bless {
    path_name => $args{path_name} // sub ($text) {
         $text =~ m{^/(bin|boot|dev|etc|home|lib|lib32|lib64|mnt|opt|proc|root|sbin|tmp|usr|var)(/|$)}
      || $text =~ m{^[a-z]:[\\/]}i
    },
    url_link => $args{url_name} // sub ($text) {
         $text =~ /^[a-z]+:\/\//i
      || $text =~ /^(file|ftps?|gopher|https?|ldapi|ldaps|mailto|mms|news|nntp|nntps|pop|rlogin|rtsp|sftp|snew|ssh|telnet|tn3270|urn|wss?):\S/i
    },
    module => $args{module} // sub ($text) {
         $text =~ /^[a-z]+::([a-z]+(::[a-z]+)*('s)?)$/i
    },
    skip => $args{skip} // sub ($text) { 0 },
  }, $class;
}

=head1 METHODS

=head2 split

 my @combos = $hcw->split($text);

This method splits the text into word combo pairs.  Each pair is returned as an array reference.  The first element is the type,
and the second is the word.  The legal types are:

=over 4

=item C<word>

For regular human type words.

=item C<path_name>

For a Unix or Windows file or directory path.  VMS is not supported, sorry.

=item C<url_link>

For a URL.

=item C<module>

For a programming module.  The default is reasonable for Perl.

=back

=cut

sub split ($self, $text)
{
  my @result;

  foreach my $frag (CORE::split /\s+/, $text)
  {
    next unless $frag =~ /\w/;
    next if$self->{skip}->($frag);

    if($self->{path_name}->($frag))
    {
      push @result, [ 'path_name', $frag ];
    }
    elsif($self->{url_link}->($frag))
    {
      push @result, [ 'url_link', $frag ];
    }
    elsif($self->{module}->($frag))
    {
      push @result, [ 'module', $frag ];
    }
    else
    {
      foreach my $word (CORE::split /\b{wb}/, $frag)
      {
        next unless $word =~ /\w/;
        push @result, [ 'word', $word ];
      }
    }
  }

  @result;
}

1;

=head1 CAVEATS

Doesn't recognize VMS paths!  Oh noes!

Computer "words" are identified with a regular expression which is somewhat reasonable, but probably has a number of false negatives, and
doesn't do any validation.

=cut
