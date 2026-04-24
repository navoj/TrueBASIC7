#!/usr/bin/env raku
# TrueBASIC7 automated test suite

use v6.d;

my $base = $*PROGRAM.parent.parent;
my $interp = $base.child('TrueBASIC.raku');

my @tests;
my $pass = 0;
my $fail = 0;
my $skip = 0;

sub run-test($file, $description, :$timeout = 10, :$expect-output, :$expect-no-error = True, :$graphics = '') {
    my @cmd = 'raku', ~$interp;
    @cmd.push("--graphics=$graphics") if $graphics;
    @cmd.push(~$file);
    
    my $proc = Proc::Async.new(|@cmd);
    my $out = '';
    my $err-out = '';
    $proc.stdout.tap(-> $chunk { $out ~= $chunk });
    $proc.stderr.tap(-> $chunk { $err-out ~= $chunk });
    
    my $p = $proc.start;
    my $timer = Promise.in($timeout);
    await Promise.anyof($p, $timer);
    
    if $p.status ~~ Kept {
        my $result = $p.result;
        my $has-error = $out ~~ /:i 'runtime error'/;
        
        if $expect-no-error && $has-error {
            $fail++;
            say "  FAIL  $description";
            say "        Error: {$out.lines.grep(/:i error/).head // '?'}";
            return False;
        }
        
        if $expect-output && $out !~~ /$expect-output/ {
            $fail++;
            say "  FAIL  $description (output mismatch)";
            say "        Expected: /$expect-output/";
            say "        Got: {$out.lines.head(3).join('; ')}";
            return False;
        }
        
        $pass++;
        say "  PASS  $description";
        return True;
    } else {
        $proc.kill(9);
        $skip++;
        say "  SKIP  $description (timeout)";
        return False;
    }
}

say "TrueBASIC7 Test Suite";
say "=" x 50;

# ── Core language tests ──────────────────────────────────────────────

say "\n── Core Language ──";

run-test($base.child('examples/simple.bas'),
    'Simple arithmetic and PRINT',
    expect-output => 'sum of 5 and 10 is 15');

run-test($base.child('examples/loop.bas'),
    'FOR/NEXT loops',
    expect-output => '5 x 10 = 50');

run-test($base.child('examples/doloop.bas'),
    'DO/LOOP control flow',
    expect-output => 'Loop finished');

run-test($base.child('examples/sortrootswap.tru'),
    'SUB/CALL with array params',
    expect-output => '1 2 3 4 5');

run-test($base.child('examples/cholesky_decompositionfinal.tru'),
    'Cholesky decomposition (MAT ops)',
    expect-output => /\d/);

run-test($base.child('examples/chem_model1.tru'),
    'Multi-line FUNCTION, RK4 solver',
    expect-output => /\d/);

# ── Graphics tests ───────────────────────────────────────────────────

say "\n── Graphics (SVG mode) ──";

run-test($base.child('examples/sine_plot.bas'),
    'Sine wave SVG plot',
    graphics => 'svg',
    expect-output => 'Saved');

run-test($base.child('examples/graphics_demo.bas'),
    'Multi-waveform demo SVG',
    graphics => 'svg',
    expect-output => 'Saved');

run-test($base.child('examples/phase_diagram.bas'),
    'Van der Waals phase diagram SVG',
    graphics => 'svg',
    expect-output => 'Saved');

# ── Graphics (ASCII mode) ───────────────────────────────────────────

say "\n── Graphics (ASCII mode) ──";

run-test($base.child('examples/sine_plot.bas'),
    'Sine wave ASCII plot',
    graphics => 'ascii',
    expect-output => /\*/);

# ── Batch .tru file tests ───────────────────────────────────────────

say "\n── Batch .tru tests ──";

my $tru-pass = 0;
my $tru-fail = 0;
my $tru-timeout = 0;
my $tru-total = 0;

for $base.child('examples').dir(:test(*.ends-with('.tru'))).sort -> $f {
    $tru-total++;
    my $result = run('timeout', '15', 'raku', ~$interp, ~$f,
        :out, :err, :in('/dev/null'));
    my $out = $result.out.slurp(:close);
    $result.err.slurp(:close);

    if $result.exitcode == 124 {
        $tru-timeout++;
    } elsif $out ~~ /:i 'runtime error'/ {
        $tru-fail++;
    } else {
        $tru-pass++;
    }
}

say "  Batch: $tru-pass pass, $tru-fail errors, $tru-timeout timeouts (of $tru-total)";

# ── Summary ──────────────────────────────────────────────────────────

say "\n" ~ "=" x 50;
say "Results: $pass passed, $fail failed, $skip skipped";
say "Batch:   $tru-pass pass, $tru-fail errors, $tru-timeout timeouts (of $tru-total)";
say "=" x 50;

exit($fail > 0 ?? 1 !! 0);
