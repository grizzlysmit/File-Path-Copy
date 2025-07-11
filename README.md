File::Path::Copy
================

Module File::Path::Copy
=======================

Table of Contents
-----------------

  * [NAME](#name)

  * [AUTHOR](#author)

  * [VERSION](#version)

  * [TITLE](#title)

  * [SUBTITLE](#subtitle)

  * [COPYRIGHT](#copyright)

  * [Introduction](#introduction)

    * [Motivation](#motivation)

  * [sub copypath(...) is export](#sub-copypath-is-export)

  * [sub prunepath(...) is export](#sub-prunepath-is-export)

  * [sub emptypath(...) is export](#sub-emptypath-is-export)

NAME
====

File::Path::Copy 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

v0.1.12

TITLE
=====

File::Path::Copy

SUBTITLE
========

A Raku module for recursively copying or deleting files.

COPYRIGHT
=========

GPL V3.0+ [LICENSE](https://github.com/grizzlysmit/File::Path::Copy/blob/main/LICENSE)

[Top of Document](#table-of-contents)

Introduction
============

This is a Raku module to recursively copy or delete files. 

Motivation
----------

None of the other modules I tried worked so here is mine. 

[Table of Contents](#table-of-contents)

sub copypath(...) is export
===========================

```raku
sub copypath(IO::Path $from, IO::Path $to,
                Bool:D :d(:$dontrecurse) = False, Bool:D :c(:$createonly) = False,
                Bool:D :n(:$no-to-check) = False, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export
```

Copy the `$from` path to the `$to` path recursively by default.

Where

  * `$from` The path to copy from.

  * `$to` The path to copy to.

  * `:d` `:$dontrecurse` Don't copy recursively, by default it will copy recursively.

  * `:c` `:$createonly` Makes it an Error to try to overwrite a file.

  * `:n` `:$no-to-check` Don't do the check on whether the to file is the same as the source.

    * i.e. normally will check if `$from.basename eq $to.basename` if so then will try to copy `$from/*` into `$to/*` note this includes `.` files; if this is true will not do this.

  * `:$backtrace` Show backtrace messages for any error messages.

  * `:$noErrorMessages` Don't show error messages.

[Table of Contents](#table-of-contents)

sub prunepath(...) is export
============================

```raku
sub prunepath(IO::Path $path, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export
```

Remove a path and everything under it.

Where

  * `$path` The path to prune.

  * `:$backtrace` If true then write backtrace to any error messages. item1 `:$noErrorMessages` Don't show error messages.

[Table of Contents](#table-of-contents)

sub emptypath(...) is export
============================

```raku
sub emptypath(IO::Path $path, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export
```

Remove everything under a path, but leave the path.

Where

  * `$path` The path to prune.

  * `:$backtrace` If true then write backtrace to any error messages. item1 `:$noErrorMessages` Don't show error messages.

[Table of Contents](#table-of-contents)

