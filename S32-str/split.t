use v6;

use Test;

# L<S32::Str/Str/"=item split">

# XXX - this needs to be updated when Str.split(Str) works again
# this test really wants is_deeply()
#  and got it, except for a couple of cases that fail because of Match objects
#  being returned -- Aankhen
plan 29;

# split on an empty string

my %ords = (
  1 => 'first',
  2 => 'second',
  3 => 'third',
  4 => 'fourth',
  5 => 'fifth',
  6 => 'sixth',
  7 => 'seventh',
  8 => 'eighth',
  9 => 'ninth',
);

sub split_test(@splitted, @expected, Str $desc) {
  is +@splitted, +@expected,
     "split created the correct value amount for: $desc";
  is @splitted[$_], @expected[$_],
     "the %ords{$_ + 1} value matched for: $desc"
     for 0 .. @splitted.end;
  is_deeply [~<< @splitted], [~<< @expected], "values match";
}

is_deeply split(:input("fiSMBoC => fREW is Station's Most Bodacious Creation"), " "),
           qw/fiSMBoC => fREW is Station's Most Bodacious Creation/,
           q{split(:input(Str), " "};

is_deeply split(:input("UNIFICATIONS => Unions Normally Identified From Initial Characters; Aesthetically Tailored to Infer Other Notions Subconsciously"), /\s+/),
           qw/UNIFICATIONS => Unions Normally Identified From Initial Characters; Aesthetically Tailored to Infer Other Notions Subconsciously/,
           q{split(:input(Str), /\s+/};

is_deeply split("", "forty-two"),
           qw/f o r t y - t w o/,
           q{split "", Str};

# split on a space
is_deeply split(' ', 'split this string'),
           qw/split this string/,
           q{split ' ', Str};

# split on a single character delimiter
is_deeply split('$', 'try$this$string'),
           qw/try this string/,
           q{split '$', Str};

# split on a multi-character delimiter
is_deeply split(', ', "comma, separated, values"),
           qw/comma separated values/,
           q{split ', ', Str};

# split on a variable delimiter

my $delimiter = '::';
is_deeply split($delimiter, "Perl6::Pugs::Test"),
           qw/Perl6 Pugs Test/,
           q{split $delimiter, Str};

# split with a reg-exp
is_deeply split(rx:Perl5 {,}, "split,me"),
           qw/split me/,
           q/split rx:Perl5 {,}, Str/;

# split on multiple space characters
is_deeply split(rx:Perl5 {\s+}, "Hello World    Goodbye   Mars"),
           qw/Hello World Goodbye Mars/,
           q/split rx:Perl5 {\s+}, Str/;

is_deeply split(rx:Perl5 {(\s+)}, "Hello test"),
           ('Hello', ("Hello test" ~~ rx:Perl5 {(\s+)}), 'test'),
           q/split rx:Perl5 {(\s+)}, Str/;

is_deeply "to be || ! to be".split(' '),
           qw/to be || ! to be/,
           q/Str.split(' ')/;

is_deeply "this will be split".split(rx:Perl5 { }),
           qw/this will be split/,
           q/Str.split(rx:Perl5 { })/;

# split on multiple space characters
diag "here";
is_deeply split(rx:Perl5 {\s+}, "Hello World    Goodbye   Mars", 3),
           ( qw/Hello World/, "Goodbye   Mars" ),
           q/split rx:Perl5 {\s+}, Str, limit/;

is_deeply split(" ", "Hello World    Goodbye   Mars", 3),
           ( qw/Hello World/, "   Goodbye   Mars" ),
           q/split " ", Str, limit/;

is_deeply  "Hello World    Goodbye   Mars".split(rx:Perl5 {\s+}, 3),
           ( qw/Hello World/, "Goodbye   Mars" ),
           q/Str.split(rx:Perl5 {\s+}, limit)/;

is_deeply  "Hello World    Goodbye   Mars".split(" ", 3),
           ( qw/Hello World/, "   Goodbye   Mars" ),
           q/Str.split(" ", limit)/;

is_deeply  "Word".split("", 3), qw/W o rd/,
           q/Str.split("", limit)/;

# XXX: Here Pugs emulates p5 default awk field splitting behaviour.
is_deeply  "  abc  def  ".split(), qw/abc def/,
           q/Str.split()/;
# ... yet how do you do this with p6 function form of split?
# Note that split(' ', $x) special casing of ' ' pattern (a la p5)
# is not implemented in Pugs. Should it be?

# This one returns an empty list
is_deeply  "".split(), (),
           q/"".split()/;

# ... yet this one does not (different to p5).
# blessed by $Larry at Message-ID: <20060118191046.GB32562@wall.org>
split_test  "".split(':'), (""),
           q/"".split(':')/;

# using /.../
is_deeply "a.b".split(/\./), <a b>,
           q{"a.b".split(/\./)};

is_deeply "abcd".split(/<null>/), <a b c d>,
           q{"abcd".split(/<null>/)};

{
  ' ' ~~ /(\s)/;

  if $0 eq ' ' {
    is_deeply "foo bar baz".split(/<prior>/), <foo bar baz>,
             q{"foo bar baz".split(/<prior>/)};
  } else {
    skip q{' ' ~~ /\s/ did not result in ' '};
  }
}
