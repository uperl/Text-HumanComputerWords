# Text::HumanComputerWords ![linux](https://github.com/uperl/Text-HumanComputerWords/workflows/linux/badge.svg) ![windows](https://github.com/uperl/Text-HumanComputerWords/workflows/windows/badge.svg) ![macos](https://github.com/uperl/Text-HumanComputerWords/workflows/macos/badge.svg) ![cygwin](https://github.com/uperl/Text-HumanComputerWords/workflows/cygwin/badge.svg) ![msys2-mingw](https://github.com/uperl/Text-HumanComputerWords/workflows/msys2-mingw/badge.svg)

Split human and computer words in a naturalish manner

# SYNOPSIS

```perl
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
```

# DESCRIPTION

This module splits a line of text into words.  It attempts to identify certain computer "words" and classify them as such.
The split on white space first, identify certain computer words (like URLs and file and directory paths) and then to split
the remaining words on Unicode word boundaries which is usually pretty good at identifying human words.

The intent is to split a paragraph into human and computer words so that they can be checked all at once.  The URLs for example
could be checked for 404s or other brokenness while the human words could be checked for spelling.

# CONSTRUCTOR

## new

```perl
my $hcw = Text::HumanComputerWords->new(%options);
```

Creates a new instance of the splitter class.  The `%options` hash lets you override some of the logic for identifying
"computer" words.  All are optional and the defaults are reasonable:

- path\_name

    ```perl
    Text::HumanComputerWords->new(
      path_name => sub ($word) {
        # return true if $word looks like a filename path
      },
    );
    ```

    This is a code reference which should return true if the `$word` looks like a file or directory path.

- url\_link

    ```perl
    Text::HumanComputerWords->new(
      url_link => sub ($word) {
        # return true if $word looks like a URL
      },
    );
    ```

    This is a code reference which should return true if the `$word` looks like a URL.

- module

    ```perl
    Text::HumanComputerWords->new(
      module => sub ($word) {
        # return true if $word looks like a computer programming module
      },
    );
    ```

- skip

    ```perl
    Text::HumanComputerWords->new(
      skip => sub ($word) {
        # return true if $word should be skipped entirely
      },
    );
    ```

    This is a code reference which should return true, if the `$word` should be skipped entirely.  The default skip code reference
    always returns false.

# METHODS

## split

```perl
my @combos = $hcw->split($text);
```

This method splits the text into word combo pairs.  Each pair is returned as an array reference.  The first element is the type,
and the second is the word.  The legal types are:

- `word`

    For regular human type words.

- `path_name`

    For a Unix or Windows file or directory path.  VMS is not supported, sorry.

- `url_link`

    For a URL.

- `module`

    For a programming module.  The default is reasonable for Perl.

# CAVEATS

Doesn't recognize VMS paths!  Oh noes!

Computer "words" are identified with a regular expression which is somewhat reasonable, but probably has a number of false negatives, and
doesn't do any validation.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
