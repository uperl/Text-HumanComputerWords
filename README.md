# Text::HumanComputerWords ![linux](https://github.com/uperl/Text-HumanComputerWords/workflows/linux/badge.svg) ![windows](https://github.com/uperl/Text-HumanComputerWords/workflows/windows/badge.svg) ![macos](https://github.com/uperl/Text-HumanComputerWords/workflows/macos/badge.svg) ![cygwin](https://github.com/uperl/Text-HumanComputerWords/workflows/cygwin/badge.svg) ![msys2-mingw](https://github.com/uperl/Text-HumanComputerWords/workflows/msys2-mingw/badge.svg)

Split human and computer words in a naturalish manner

# SYNOPSIS

```perl
use Text::HumanComputerWords;

my $hcw = Text::HumanComputerWords->new(
  Text::HumanComputerWords->default_perl,
);

my $text = "this is some text with a url: https://metacpan.org, "
         . "a unix path name: /usr/local/bin "
         . "and a windows path name: c:\\Windows";

foreach my $combo ($hcw->split($text))
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

This module extracts human and computer words from text.  This is useful for checking the validity of these words.  Human
words can be checked for spelling, while "computer" words like URLs can be validated by other means.  URLs for example
could be checked for 404s and module names could be checked against a module registry like CPAN.

The algorithm works like thus:

- 1. The text is split on whitespace into fragments `/\s/`

    fragments could be either a single computer word like a URL or a module, or it could be one or more human words.
    If a fragment doesn't contain any word characters then it is skipped entirely `/\w/`.

- 2. If the fragment is recognized as a computer word we are done.

    Computer words can be defined any way you want.  The `default_perl` method below is reasonable for Perl technical
    documentation.

- 3. Split the fragment into words using the Unicode word boundary `/\b{wb}/`

    After the split words are identified as those containing word characters `/\w/`.

# CONSTRUCTOR

## new

```perl
my $hcw = Text::HumanComputerWords->new(@cpu);
```

Creates a new instance of the splitter class.  The `@cpu` pairs lets you specify the logic for identifying
"computer" words.  The keys are the type names and the values are code references that identify those words.
These are special reserved types:

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

- substitute

    ```perl
    Text::HumanComputerWord->new(
      substitute => sub {
        # the value is passed in as $_ and can be modified
      },
    );
    ```

    This allows you to substitute the current word.  The main intent here is to allow supporting splitting CamelCase and snakeCase
    into separate words, so they can be checked as human words.  Example:

    ```perl
    Text::HumanComputerWords->new(
      substitute => sub {
        # this should split both CamelCase and snakeCase
        s/([A-Z]+)/ $1/g if /^[a-z]+$/i && lcfirst($_) ne lc $_;
      },
    ),
    ```

- word

    ```perl
    Text::HumanComputerWords->new(
      word => sub ($word) {},  # error
    );
    ```

    The `word` type is reserved for human words, and cannot be overridden.

The order of the pairs matters and a type can be specified more than once.  If a given computer word matches multiple
types it will only be reported as the first type matches.  Example:

```perl
Text::HumanComputerWords->new(
  foo_or_bar => sub ($word) { $word eq 'foo' },
  foo_or_bar => sub ($word) { $word eq 'bar' },
);
```

# METHODS

## default\_perl

```perl
my @cpu = Text::HumanComputerWords->default_perl;
```

Returns the computer word pairs reasonable for a technical Perl document.  These pairs should be
passed into ["new"](#new), optionally with extra pairs if you like, for example:

```perl
my $hcw = Text::HumanComputerWords->new(

  # this needs to come first so that platypus modules are recognized before
  # non-platypus modules in the default rule set
  platypus_module => sub ($word) { $word =~ /^FFI::Platypus(::[A-Za-z0-9_]+)*$/ },

  # the normal Perl rules.
  Text::HumanComputerWords->default_perl,

  # this can go anywhere, but we check for it last.
  plus_one => sub ($word) { $word eq '+1' },
);
```

By itself, this returns pairs that will recognize these types:

- path\_name

    A file system path.  Something that looks like a UNIX or Windows filename or directory path.

- url\_link

    A URL.  The regex to recognize a URL is naive so if the URLs need to be validated they should be done separately.

- module

    A Perl module name.  `Something::Like::This`.

## split

```perl
my @pairs = $hcw->split($text);
```

This method splits the text into word combo pairs.  Each pair is returned as an array reference.  The first element is the type,
and the second is the word.  The types are as defined when the `$hcw` object is created, plus the `word` type for human words.

# CAVEATS

Doesn't recognize VMS paths!  Oh noes!

The `default_perl` method provides computer "words" that are identified with a regular expression which is somewhat reasonable,
but probably has a few false positives or negatives, and doesn't do any validation for things like URLs or modules.  Modules
like [strict](https://metacpan.org/pod/strict) or [warnings](https://metacpan.org/pod/warnings) that do not have a `::` cannot be recognized.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
