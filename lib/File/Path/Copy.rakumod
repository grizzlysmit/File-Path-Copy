unit module File::Path::Copy:ver<0.1.9>:auth<Francis Grizzly Smit (grizzly@smit.id.au)>;

=begin pod

=head1 File::Path::Copy
=head1 Module File::Path::Copy

=begin head2

Table of Contents

=end head2

=item1 L<NAME|#name>
=item1 L<AUTHOR|#author>
=item1 L<VERSION|#version>
=item1 L<TITLE|#title>
=item1 L<SUBTITLE|#subtitle>
=item1 L<COPYRIGHT|#copyright>
=item1 L<Introduction|#introduction>
=item2 L<Motivation|#motivation>
=item1 L<sub copypath(...) is export|#sub-copypath-is-export>
=item1 L<sub prunepath(...) is export|#sub-prunepath-is-export>
=item1 L<sub emptypath(...) is export|#sub-emptypath-is-export>


=NAME File::Path::Copy 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION v0.1.9
=TITLE File::Path::Copy
=SUBTITLE A Raku module for recursively copying or deleting files.

=COPYRIGHT
GPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/File::Path::Copy/blob/main/LICENSE>

L<Top of Document|#table-of-contents>

=head1 Introduction

This is a Raku module to recursively copy or delete files. 

=head2 Motivation

None of the other modules I tried worked so here is mine. 

L<Table of Contents|#table-of-contents>

=head1 sub copypath(...) is export

=begin code :lang<raku>

sub copypath(IO::Path $from, IO::Path $to,
                Bool:D :d(:$dontrecurse) = False, Bool:D :c(:$createonly) = False,
                Bool:D :n(:$no-to-check) = False, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export 

=end code

Copy the C«$from» path to the C«$to» path recursively by default.

Where
=item1 C«$from»                  The path to copy from.
=item1 C«$to»                    The path to copy to.
=item1 C«:d»  C«:$dontrecurse»   Don't copy recursively, by default it will copy recursively.
=item1 C«:c»  C«:$createonly»    Makes it an Error to try to overwrite a file.
=item1 C«:n»  C«:$no-to-check»   Don't do the check on whether the to file is the same as the source.
=item2 i.e. normally will check if C«$from.basename eq $to.basename» if so then will try to copy C«$from/*» into C«$to/*» note this includes C«.» files; if this is true will not do this.
=item1 C«:$backtrace»            Show backtrace messages for any error messages.
=item1 C«:$noErrorMessages»      Don't show error messages.

L<Table of Contents|#table-of-contents>

=end pod

sub copypath(IO::Path $from, IO::Path $to,
                Bool:D :d(:$dontrecurse) = False, Bool:D :c(:$createonly) = False,
                Bool:D :n(:$no-to-check) = False, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export {
    CATCH {
        when X::IO::Copy, X::IO::Unlink, X::IO::Mkdir, X::IO::DoesNotExist {
            if !$noErrorMessages {
                $*ERR.say: .message;
                if $backtrace {
                    for .backtrace.reverse {
                        next if .file.starts-with('SETTING::');
                        next unless .subname;
                        $*ERR.say: "  in block {.subname} at {.file} line {.line}";
                    } # for .backtrace.reverse #
                } # if $backtrace #
            }
            return False;
        }
    }
    my $result = True;
    if $from ~~ :d {
        if $to ~~ :d {
            my Str:D $target = $from.basename;
            if $target eq $to.basename && !$no-to-check {
                my @children = $from.dir();
                for @children -> $file {
                    if !$dontrecurse {
                        $result &&= copypath($file, $to, :$dontrecurse, :$createonly, :no-to-check);
                    } else {
                        $result &&= $file.copy($to, :$createonly);
                    }
                }
                return $result;
            } else {
                my $path = "{$to.path}/$target";
                if $path.IO.mkdir {
                    my @children = $from.dir();
                    for @children -> $file {
                        if !$dontrecurse {
                            $result &&= copypath($file, $path.IO, :$dontrecurse, :$createonly, :no-to-check);
                        } else {
                            $result &&= $file.copy($path.IO, :$createonly);
                        }
                    }
                    return $result;
                } else {
                    return False;
                }
            }
        } elsif $to ~~ :f {
            return False if $createonly;
            if $to.unlink {
                if !$dontrecurse {
                    $result &&= copypath($from, $to, :$dontrecurse, :$createonly, :no-to-check);
                } else {
                    $result &&= $from.copy($to, :$createonly);
                }
            }
            return $result;
        } elsif $to ~~ :l {
            return False if $createonly;
            if $to.unlink {
                return copypath($from, $to, :$dontrecurse, :$createonly, :no-to-check);
            }
        } elsif $to.dirname ~~ :d {
            if $to.mkdir {
                return copypath($from, $to, :$dontrecurse, :$createonly, :no-to-check);
            } else {
                return False;
            }
        } else {
            die "bad value \$to: $to";
        }
    } elsif $from ~~ :f {
        my $target = $from.basename;
        if $to ~~ :d {
            return $from.copy("{$to.path}/$target".IO, :$createonly);
        } elsif $to ~~ :f {
            return False if $createonly;
            $to.unlink;
            return $from.copy($to, :$createonly);
        } elsif $to ~~ :l {
            return False if $createonly;
            $to.unlink;
            return $from.copy($to, :$createonly);
        } elsif $to.dirname ~~ :d {
            return $from.copy($to, :$createonly);
        } else {
            return False;
        }
    } elsif $from ~~ :l {
        my $target = $from.basename;
        if $to ~~ :d {
            return $from.copy("{$to.path}/$target".IO, :$createonly);
        } elsif $to ~~ :f {
            return False if $createonly;
            $to.unlink;
            return $from.copy($to, :$createonly);
        } elsif $to ~~ :l {
            return False if $createonly;
            $to.unlink;
            return $from.copy($to, :$createonly);
        }
    }
    return False;
} #`«« sub copypath(IO::Path $from, IO::Path $to,
                Bool:D :d(:$dontrecurse) = False, Bool:D :c(:$createonly) = False,
                Bool:D :n(:$no-to-check) = False, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export »»

=begin pod

=head1 sub prunepath(...) is export

=begin code :lang<raku>

sub prunepath(IO::Path $path, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export

=end code

Remove a path and everything under it.

Where
=item1 C«$path»                  The path to prune.
=item1 C«:$backtrace»            If true then write backtrace to any error messages.
item1 C«:$noErrorMessages»      Don't show error messages.

L<Table of Contents|#table-of-contents>

=end pod

sub prunepath(IO::Path $path, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export {
    if $path ~~ :d {
        CATCH {
            when X::IO::Rmdir, X::IO::DoesNotExist {
                if !$noErrorMessages {
                    $*ERR.say: .message;
                    if $backtrace {
                        for .backtrace.reverse {
                            next if .file.starts-with('SETTING::');
                            next unless .subname;
                            $*ERR.say: "  in block {.subname} at {.file} line {.line}";
                        } # for .backtrace.reverse #
                    } # if $backtrace #
                } # if !$noErrorMessages #
                return False;
            } # when X::IO::Rmdir #
        } # CATCH #
        my Bool:D $result = True;
        my @children = $path.dir();
        for @children -> $file {
            $result &&= prunepath($file, :$backtrace);
        } # for $path.dir() -> $file #
        $result &&= $path.rmdir;
        return $result;
    } else {
        CATCH {
            when X::IO::Unlink {
                if !$noErrorMessages {
                    $*ERR.say: .message;
                    if $backtrace {
                        for .backtrace.reverse {
                            next if .file.starts-with('SETTING::');
                            next unless .subname;
                            $*ERR.say: "  in block {.subname} at {.file} line {.line}";
                        } # for .backtrace.reverse #
                    } # if $backtrace #
                } # if !$noErrorMessages #
                return False;
            } # when X::IO::Unlink #
        } # CATCH #
        return $path.unlink;
    }
} #`«« sub prunepath(IO::Path $path, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export »»

=begin pod

=head1 sub emptypath(...) is export

=begin code :lang<raku>

sub emptypath(IO::Path $path, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export

=end code

Remove everything under a path,  but leave the path.

Where
=item1 C«$path»                  The path to prune.
=item1 C«:$backtrace»            If true then write backtrace to any error messages.
item1 C«:$noErrorMessages»      Don't show error messages.

L<Table of Contents|#table-of-contents>

=end pod

sub emptypath(IO::Path $path, Bool:D :$backtrace = False,
                Bool:D :$noErrorMessages = False --> Bool:D) is export {
    CATCH {
        when X::IO::Unlink, X::IO::DoesNotExist {
            if !$noErrorMessages {
                $*ERR.say: .message;
                if $backtrace {
                    for .backtrace.reverse {
                        next if .file.starts-with('SETTING::');
                        next unless .subname;
                        $*ERR.say: "  in block {.subname} at {.file} line {.line}";
                    } # for .backtrace.reverse #
                } # if $backtrace #
            } # if !$noErrorMessages #
            return False;
        } # when X::IO::Unlink #
    } # CATCH #
    if $path ~~ :d {
        my Bool:D $result = True;
        my @children = $path.dir();
        for @children -> $file {
            $result &&= prunepath($file, :$backtrace);
        } # for $path.dir() -> $file #
        return $result;
    } else {
        return $path.unlink;
    }
} # sub emptypath(IO::Path $path, Bool:D :$backtrace = False --> Bool:D) is export #
