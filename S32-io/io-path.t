use v6;
use lib <t/spec/packages/>;
use Test;
use Test::Util;

plan 27;

# L<S32::IO/IO::Path>

my $path = '/foo/bar.txt'.IO;
isa-ok $path, IO::Path, "Str.IO returns an IO::Path";
is IO::Path.new('/foo/bar.txt'), $path,
   "Constructor works without named arguments";

is IO::Path.new(:basename<bar.txt>), IO::Path.new('bar.txt'),
    "Can use either :basename or positional argument";

is IO::Path.new(:dirname</foo>, :basename<bar.txt>).cleanup, $path.cleanup,
    "Can construct path from :dirname and :basename";

# This assumes slash-separated paths, so it will break on, say, VMS

is $path.volume,          '', 'volume';
is $path.dirname,     '/foo', 'dirname';
is $path.basename, 'bar.txt', 'basename';
is $path.parent,    '/foo',    'parent';
is $path.parent.parent, '/',   'parent of parent';
is $path.is-absolute, True,    'is-absolute';
is $path.is-relative, False,   'is-relative';

isa-ok $path.path, Str,      'IO::Path.path returns Str';
isa-ok $path.IO,   IO::Path, 'IO::Path.IO returns IO::Path';

# Try to guess from context that the correct backend is loaded:
#?DOES 2
{
  if $*DISTRO.name eq any <win32 mswin32 os2 dos symbian netware> {
      ok "c:\\".IO.is-absolute, "Win32ish OS loaded (volume)";
      is "/".IO.cleanup, "\\", "Win32ish OS loaded (back slash)"
  }
  elsif $*DISTRO.name eq 'cygwin' {
      ok "c:\\".IO.is-absolute, "Cygwin OS loaded (volume)";
      is "/".IO.cleanup, "/", "Cygwin OS loaded (forward slash)"
  }
  else { # assume POSIX
      nok "c:\\".IO.is-absolute, "POSIX OS loaded (no volume)";
      is "/".IO.cleanup, "/", "POSIX OS loaded (forward slash)"
  }
}

# RT #126935
{
    my $perl = "/foo|\\bar".IO.perl;
    is $perl.EVAL.perl, $perl, "does $perl roundtrip?";
    my $nul = "/foo\0bar".IO.perl;
    is $nul.EVAL.perl, $nul, "does $nul roundtrip?";
}

# RT #127989
throws-like { IO::Path.new: 'foo', 'bar' }, X::Multi::NoMatch,
    'IO::Path.new with wrong args must not claim it only takes named ones';

# RT #128097
{
    is IO::Handle.new(:path('-')).path.gist, '"-".IO', '"-" as the path of an IO::Handle gists correctly';
    is '-'.IO.gist, '"-".IO', '"-".IO gists correctly';
}

# RT #130889
{
    my $file = ("S32-io-path-RT-130889-test" ~ rand);
    LEAVE $file.IO.unlink;

    my $p1 = $file.IO;
    is-deeply $p1.e, False, 'temporary test file does not exist';

    my $p2 = $file.IO.spurt: "test";
    is-deeply $p1.e, True,
        '.e detects change on filesystem and returns True now';
}

subtest 'IO::Path.ACCEPTS' => { # coverage 2017-03-31 (IO grant)
    my @true = "foo"     => "foo".IO.absolute, "/foo" => "/../foo",
               "////foo" => "////.././/foo",        4 => 4;
    .append: .map: {[.key] => [.value] } with @true; # Make some more Cools

    my @false = "a" => "b", "/a" => "/b", 4 => 5,
                "non-existent-blarg/../foo" => "foo";
    .append: .map: { [.key] => [.value] } with @false; # Make some more Cools
    plan 4 * (@true + @false);

    for @true -> \t {
        is-deeply t.key      ~~ t.value.IO, True,  "{t.key  }    ~~ {t.value}.IO";
        is-deeply t.value    ~~ t.key  .IO, True,  "{t.value}    ~~ {t.key  }.IO";
        is-deeply t.key.IO   ~~ t.value.IO, True,  "{t.key  }.IO ~~ {t.value}.IO";
        is-deeply t.value.IO ~~ t.key  .IO, True,  "{t.value}.IO ~~ {t.key  }.IO";
    }

    for @false -> \t {
        is-deeply t.key      ~~ t.value.IO, False, "{t.key  }    ~~ {t.value}.IO";
        is-deeply t.value    ~~ t.key  .IO, False, "{t.value}    ~~ {t.key  }.IO";
        is-deeply t.key.IO   ~~ t.value.IO, False, "{t.key  }.IO ~~ {t.value}.IO";
        is-deeply t.value.IO ~~ t.key  .IO, False, "{t.value}.IO ~~ {t.key  }.IO";
    }
}

{ # .Str tests
    is-deeply '.'.IO.Str, '.', 'Str does not include CWD [relative path]';
    is-deeply '/'.IO.Str, '/', 'Str does not include CWD [absolute path]';
    is-deeply IO::Path.new(
        :volume<foo:>, :dirname<bar>, :basename<ber>, :SPEC(IO::Spec::Win32.new)
    ).Str, 'foo:\bar\ber', 'Str does not include CWD [mulit-part .new()]'
}

subtest '.concat-with' => {
    plan 4 * my @tests = gather for 'bar', '../bar', '../../bar', '.', '..' {
        take %(:orig</foo/>, :with($_), :res("/foo/$_"));
        take %(:orig<foo/>,  :with($_), :res("foo/$_"));
    }

    sub is-path ($got, $expected, $desc) {
        cmp-ok $got.resolve, '~~', $expected.resolve, $desc
    }

    for @tests -> (:$orig, :$with, :$res) {
        for IO::Path::Unix, IO::Path::Win32, IO::Path::Cygwin, IO::Path::QNX {
            is-path .new($orig).concat-with($with), .new($res),
                "$orig concat-with $with => $res {.gist}";
        }
    }
}
