use v6;
use Test;

plan 3;

constant PATH = 't-S32-io-seek-t.tmp';
LEAVE unlink PATH;

sink my $fh = open PATH, :rw, :bin, :enc<ASCII>;
$fh.print: '1234567890abcdefghijABCDEFGHIJ';

#?rakudo.jvm skip "Method 'sink' not found for invocant of class 'BOOTIO'"
#?DOES 1
{
    subtest 'SeekFromBeginning' => {
        LEAVE $fh.seek: 0, SeekFromBeginning; $fh.seek: 0, SeekFromBeginning;

        $fh.seek: 0, SeekFromBeginning;
        is-deeply $fh.read(5).decode, '12345', 'seek 0';
        $fh.seek: 3, SeekFromBeginning;
        is-deeply $fh.read(5).decode, '45678', 'seek 3';

        $fh.seek: 10, SeekFromBeginning;
        $fh.seek: 20, SeekFromBeginning;
        is-deeply $fh.read(5).decode, 'ABCDE', 'two successive seeks';

        $fh.seek:  300, SeekFromBeginning;
        is $fh.tell, 300, 'seeking past end';

        throws-like { $fh.seek: -300, SeekFromBeginning }, Exception,
            'seeking past beginning throws';
    }
}

#?rakudo.jvm skip "Method 'sink' not found for invocant of class 'BOOTIO'"
#?DOES 1
{
    subtest 'SeekFromCurrent' => {
        LEAVE $fh.seek: 0, SeekFromBeginning; $fh.seek: 0, SeekFromBeginning;

        $fh.seek:  10, SeekFromCurrent;
        is-deeply $fh.read(5).decode, 'abcde', 'seek 10';
        $fh.seek:  5, SeekFromCurrent;
        is-deeply $fh.read(5).decode, 'ABCDE', 'read 5, then seek 5';
        $fh.seek: -20, SeekFromCurrent;
        is-deeply $fh.read(5).decode, '67890', 'negative seek 20';

        $fh.seek:   5, SeekFromCurrent;
        $fh.seek:  10, SeekFromCurrent;
        is-deeply $fh.read(5).decode, 'FGHIJ', 'two successive seeks (pos, pos)';

        $fh.seek: -15, SeekFromCurrent;
        $fh.seek:   5, SeekFromCurrent;
        is-deeply $fh.read(5).decode, 'ABCDE', 'two successive seeks (neg, pos)';

        $fh.seek:  -5, SeekFromCurrent;
        $fh.seek: -10, SeekFromCurrent;
        is-deeply $fh.read(5).decode, 'abcde', 'two successive seeks (neg, neg)';

        $fh.seek:    0, SeekFromBeginning;
        $fh.seek:  300, SeekFromCurrent;
        is $fh.tell, 300, 'seeking past end';

        throws-like { $fh.seek: -3000, SeekFromCurrent }, Exception,
            'seeking past beginning throws';
    }
}

#?rakudo.jvm skip "Method 'sink' not found for invocant of class 'BOOTIO'"
#?DOES 1
{
    subtest 'SeekFromEnd' => {
        LEAVE $fh.seek: 0, SeekFromBeginning; $fh.seek: 0, SeekFromBeginning;

        $fh.seek:  -5, SeekFromEnd;
        is-deeply $fh.read(5).decode, 'FGHIJ', 'seek -5';
        $fh.seek: -30, SeekFromEnd;
        is-deeply $fh.read(5).decode, '12345', 'seek -30';

        $fh.seek: -5, SeekFromEnd;
        $fh.seek: -10, SeekFromEnd;
        is-deeply $fh.read(5).decode, 'ABCDE', 'two successive seeks';

        $fh.seek:  300, SeekFromEnd;
        is $fh.tell, 330, 'seeking past end';

        throws-like { $fh.seek: -300, SeekFromEnd }, Exception,
            'seeking past beginning throws';
    }
}

# vim: ft=perl6
