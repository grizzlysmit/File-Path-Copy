unit module File::Path::Copy:ver<0.1.0>:auth<Francis Grizzly Smit (grizzly@smit.id.au)>;

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


=NAME File::Path::Copy 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION v0.1.0
=TITLE File::Path::Copy
=SUBTITLE A Raku module for recursively copying files.

=COPYRIGHT
GPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/File::Path::Copy/blob/main/LICENSE>

L<Top of Document|#table-of-contents>

=head1 Introduction

This is a Raku module to recursively copy files. 

=head2 Motivation

None of the other modules I tried worked so here is mine. 

L<Table of Contents|#table-of-contents>

=head1 sub copypath(...) is export

=begin code :lang<raku>

sub copypath(IO::Path $from, IO::Path $to,
                Bool:D :d(:$dontrecurse) = False,
                Bool:D :c(:$createonly) = False, Bool:D :n(:$no-to-check) = False --> Bool:D) is export

=end code

Copy the C«$from» path to the C«$to» path recursively by default.

Where
=item1 C«$from»                  The path to copy from.
=item1 C«$to»                    The path to copy to.
=item1 C«:d»  C«:$dontrecurse»   Don't copy recursively, by default it will copy recursively.
=item1 C«:c»  C«:$createonly»    Makes it an Error to try to overwrite a file.
=item1 C«:n»  C«:$no-to-check»   Don't do the check on whether the to file is the same as the source.
=item2 i.e. normally will check if C«$from.basename eq $to.basename» if so then will try to copy C«$from/*» into C«$to/*» note this includes C«.» files; if this is true will not do this.

L<Table of Contents|#table-of-contents>

=end pod

sub copypath(IO::Path $from, IO::Path $to,
                Bool:D :d(:$dontrecurse) = False,
                Bool:D :c(:$createonly) = False, Bool:D :n(:$no-to-check) = False --> Bool:D) is export {
    my $result = True;
    if $from ~~ :d {
        if $to ~~ :d {
            my $target = $from.basename;
            if $target eq $to.basename && !$no-to-check {
                for $from.dir() -> $file {
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
                    for $from.dir() -> $file {
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
}
