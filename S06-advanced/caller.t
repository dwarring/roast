use v6;

use Test;

plan 22;

# L<S06/The C<callframe> and C<caller> functions>

# caller.subname
sub a_sub { b_sub() }
sub b_sub { try { caller.subname } }
#?niecza todo "try interferes with caller counting"
is ~a_sub(), "a_sub", "caller.sub works";

# caller.file
ok index(~(try { caller.file }), "caller") >= 0, "caller.file works";

# caller.line (XXX: make sure to edit the expected line number!)
sub call_line { caller.line };
is call_line(), 23, "caller.line works";

# insure we don't need explicit ()'s when using autogenerated accessors
sub try_it {
    my ($code, $expected, $desc) = @_;
    is($code(), $expected, $desc);
}
sub try_it_caller { try_it(@_) }                                # (line 33.)
class A { method try_it_caller_A { &Main::try_it_caller(@_) } }
sub try_it_caller_caller { A.try_it_caller_A(@_) }
class B { method try_it_caller_B { &Main::try_it_caller_caller(@_) } }

#?DOES 1
sub chain { B.try_it_caller_B(@_) }

# basic tests of caller object
#?niecza skip "NYI"
{
    chain({ WHAT(caller()).gist }, "Control::Caller()", "caller object type");
    chain({ caller().package }, "Main", "caller package");
    chain({ caller().file },    $?FILE, "caller filename");
    chain({ caller().line },    "32", "caller line");
    chain({ caller().subname }, "&Main::try_it_caller", "caller subname");
    chain({ caller().subtype }, "SubRoutine", "caller subtype"); # specme
    chain({ caller().sub },     &try_it_caller, "caller sub (code)");
}

# select by code type
#?niecza skip "NYI"
{
    chain({ caller(Any).subname },    "&Main::try_it_caller", "code type - Any");
    chain({ caller("Any").subname },  "&Main::try_it_caller", "code type - Any (string)");
    chain({ caller(Method).subname }, "&A::try_it_caller_A", "code type - Method");
    chain({ caller("Moose") },         Mu, "code type - not found");
    chain({ caller(:skip<1>).subname }, "&A::try_it_caller_A", ":skip<1>");
    chain({ caller(:skip<128>) },       Mu, ":skip<128> - not found");
    chain({ caller(Sub, :skip<1>).subname }, "&Main::try_it_caller_caller", "Sub, :skip<1>");
    chain({ caller(Sub, :skip<2>).subname }, "&Main::chain", "Sub, :skip<2>");
    chain({ caller(Method, :skip<1>).subname }, "&B::try_it_caller_B", "Method, :skip<1>");
}

# WRITEME: label tests

# vim: ft=perl6
