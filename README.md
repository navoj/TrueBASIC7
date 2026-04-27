# TrueBASIC7

A feature-rich True BASIC interpreter written in Raku with real graphical output.

TrueBASIC7 runs True BASIC programs with full support for subroutines, matrix
operations, and four graphics backends — from native GTK windows to SVG export
and browser-based HTML5 Canvas plots.

## Quick Start

```bash
# Run a program
raku TrueBASIC.raku examples/simple.bas

# Run with a GTK plot window
raku TrueBASIC.raku --graphics=gtk examples/phase_diagram.bas

# Export a plot to SVG
raku TrueBASIC.raku --graphics=svg examples/chem_kinetics.tru

# Open a plot in your browser
raku TrueBASIC.raku --graphics=web examples/graphics_full_demo.bas

# ASCII plot in the terminal
raku TrueBASIC.raku --graphics=ascii examples/sine_plot.bas

# Interactive REPL
raku TrueBASIC.raku --interactive
```

## Command-Line Options

| Flag              | Description                                    |
|-------------------|------------------------------------------------|
| `<file>`          | BASIC program to run (`.bas` or `.tru`)        |
| `--graphics=MODE` | Graphics backend: `gtk`, `web`, `svg`, `ascii` |
| `--interactive`   | Start the interactive REPL                     |
| `--debug`         | Print parsed statements and execution trace    |
| `--show`          | Auto-show the plot window after execution      |

When `--graphics` is not specified, the interpreter auto-detects: it uses GTK
if a display and interactive terminal are available, and falls back to SVG
otherwise. This means piped or batch runs produce SVG files automatically.

## Graphics Modes

### GTK / Cairo (`--graphics=gtk`)

Opens a native window rendered with Cairo. Close the window to continue
execution. Requires `Gnome::Gtk3` and `Gnome::Cairo` (see
[GTK_INSTALLATION_GUIDE.md](GTK_INSTALLATION_GUIDE.md)).

### Web / HTML5 Canvas (`--graphics=web`)

Generates an HTML page with a `<canvas>` element and opens it in the
default browser via `xdg-open`. No GTK libraries needed.

### SVG (`--graphics=svg`)

Writes `plot.svg` (or the filename set with `SAVE`) to the current directory.
Useful for publication-quality figures and CI/batch pipelines.

### ASCII (`--graphics=ascii`)

Renders a character-based plot directly in the terminal. No dependencies.

## Language Features

### Variables and Types

```basic
LET x = 42              ! Numeric variable
name$ = "Alice"          ! String variable ($ suffix)
OPTION NOLET             ! Makes LET keyword optional everywhere
OPTION BASE 1            ! Arrays start at index 1
```

All keywords and variable names are **case-insensitive**.

### Control Flow

```basic
! Single-line IF
IF x > 0 THEN PRINT "positive" ELSE PRINT "non-positive"

! Multi-line IF block
IF score >= 90 THEN
    PRINT "A"
ELSEIF score >= 80 THEN
    PRINT "B"
ELSE
    PRINT "C"
END IF

! FOR loop (with optional STEP)
FOR i = 1 TO 10 STEP 2
    PRINT i
NEXT i

! DO / LOOP
DO WHILE x < 100
    x = x * 2
LOOP

DO
    x = x + 1
LOOP UNTIL x >= 100

! WHILE / WEND
WHILE n > 0
    n = n - 1
WEND

! EXIT from loops or subroutines
EXIT FOR
EXIT DO
EXIT SUB
EXIT FUNCTION

! SELECT CASE
SELECT CASE grade
CASE 1
    PRINT "Freshman"
CASE 2
    PRINT "Sophomore"
CASE ELSE
    PRINT "Other"
END SELECT

! GOTO with line numbers
GOTO 100
```

### Input / Output

```basic
PRINT "Hello, world!"
PRINT "x ="; x; "y ="; y          ! Semicolons suppress newlines
PRINT x, y                         ! Comma-separated columns

INPUT "Enter a value: "; n
INPUT PROMPT "Name: ": name$       ! True BASIC-style prompt
LINE INPUT PROMPT "Full line: ": text$

! Multiple statements on one line
a = 1 : b = 2 : c = a + b
```

### Arrays

```basic
DIM a(100)                   ! 1-D array
DIM grid(10, 10)             ! 2-D array
DIM names$(5)                ! String array

MAT REDIM a(200)             ! Resize preserving values
MAT REDIM a(n, n), b(n, n)   ! Resize multiple at once
```

### Matrix Operations

```basic
DIM a(3,3), b(3,3), c(3,3)

MAT c = a * b           ! Matrix multiply
MAT c = a + b           ! Element-wise add
MAT c = a - b           ! Element-wise subtract
MAT b = TRN(a)          ! Transpose
MAT b = INV(a)          ! Inverse (Gauss-Jordan with pivoting)
MAT a = IDN             ! Identity matrix
MAT a = ZER             ! Zero fill
MAT a = CON             ! Fill with ones
MAT a = ZER(4, 4)       ! Zero matrix with dimensions
MAT a = (k) * b         ! Scalar multiply
MAT b = a               ! Copy
MAT PRINT a             ! Print formatted (1-D or 2-D)
MAT READ a              ! Read from DATA statements
MAT INPUT a             ! Read from console

PRINT DET(a)            ! Determinant (LU decomposition)
PRINT UBOUND(a)         ! Upper bound of first dimension
PRINT LBOUND(a)         ! Lower bound (respects OPTION BASE)
PRINT SIZE(a)           ! Number of elements
```

### Subroutines and Functions

```basic
! Subroutine with parameters
SUB swap(a, b)
    LET t = a
    LET a = b
    LET b = t
END SUB

CALL swap(x, y)

! Array parameters by reference (1-D and 2-D)
SUB fill(arr(), n)
    FOR i = 1 TO n
        arr(i) = i * 10
    NEXT i
END SUB

CALL fill(data(), 5)

! Multi-line function
FUNCTION factorial(n)
    IF n <= 1 THEN
        factorial = 1
    ELSE
        factorial = n * factorial(n - 1)
    END IF
END FUNCTION

PRINT factorial(6)

! Single-line DEF function
DEF area(r) = PI * r^2
PRINT area(5)
```

### DATA / READ / RESTORE

```basic
DATA 10, 20, 30, "hello"
READ a, b, c, word$
RESTORE                 ! Reset data pointer
```

### Graphics

```basic
SET WINDOW -10, 10, -8, 8        ! Set coordinate system
SET COLOR 2                       ! 0=black,1=red,2=green,3=blue,4=cyan,...

! Plot points (semicolon continues the curve)
FOR t = 0 TO 6.28 STEP 0.05
    PLOT t, SIN(t);
NEXT t
PLOT                              ! End the curve

! Connected line segments
PLOT LINES: 0, 0; 5, 5; 10, 0

! Filled polygon
PLOT AREA: 0, 0; 5, 5; 10, 0

! Text labels
PLOT TEXT, AT 1, 7: "Title"

! Geometric primitives
LINE 0, 0, 10, 10
CIRCLE 5, 5, 3
BOX LINES 0, 0, 10, 10           ! Outlined rectangle
BOX AREA 2, 2, 8, 8              ! Filled rectangle

! Viewports (split-screen graphics)
OPEN #1: screen 0, 0.5, 0, 1     ! Left half
OPEN #2: screen 0.5, 1, 0, 1     ! Right half
WINDOW #1                         ! Draw to left viewport
SET WINDOW 0, 100, 0, 100

! Display and export
SHOW PLOT                         ! Force render
SAVE "output.svg"                 ! Export to file
```

### Built-in Functions

**Math:** `ABS`, `ATN`, `COS`, `SIN`, `TAN`, `EXP`, `LOG`, `LOG2`, `LOG10`,
`SQR`, `INT`, `ROUND`, `CEIL`, `TRUNCATE`, `REMAINDER`, `MOD`, `MAX`, `MIN`,
`SGN`, `PI`

**String:** `LEN`, `CHR$`, `STR$`, `VAL`, `ORD`, `POS`, `TRIM$`, `LTRIM$`,
`RTRIM$`, `UCASE$`, `LCASE$`, `REPEAT$`, `LEFT$`, `RIGHT$`, `MID$`, `SEG$`,
`TAB`

**Array:** `SIZE`, `UBOUND`, `LBOUND`, `DET`, `DOT`

**Other:** `RND`, `TIME`, `DATE$`, `GET KEY`

## Examples

The `examples/` directory contains **193 programs** — 30 `.bas` demos and
163 `.tru` scientific/engineering programs (chemistry, physics, numerical
methods, curve fitting, and more).

### Highlighted Examples

| File | Description |
|------|-------------|
| `simple.bas` | Basic arithmetic and PRINT |
| `loop.bas` | FOR/NEXT multiplication table |
| `doloop.bas` | DO/LOOP control flow |
| `sortrootswap.tru` | Bubble sort with SUB/CALL and array params |
| `cholesky_decompositionfinal.tru` | Cholesky decomposition with MAT ops |
| `chem_model1.tru` | RK4 ODE solver with multi-line FUNCTION |
| `sine_plot.bas` | Sine wave plot (works in all 4 graphics modes) |
| `phase_diagram.bas` | Van der Waals isotherms (multi-color curves) |
| `graphics_full_demo.bas` | Boxes, circles, curves, text — all features |
| `testmatrixinv.tru` | Matrix inverse and multiply verification |
| `paperlinlogxyfinal.tru` | Log-scale graph paper with BOX LINES |

### Running the Graphics Examples

```bash
# Interactive GTK window with phase diagram
raku TrueBASIC.raku --graphics=gtk examples/phase_diagram.bas

# Chemistry kinetics plot to SVG
raku TrueBASIC.raku --graphics=svg examples/chem_kinetics.tru

# All graphics features in the browser
raku TrueBASIC.raku --graphics=web examples/graphics_full_demo.bas

# Quick terminal sine wave
raku TrueBASIC.raku --graphics=ascii examples/sine_plot.bas
```

## Testing

### Test Suite

```bash
# Run the automated test suite (core + graphics + batch)
raku test/test-suite.raku
```

The test suite runs core language tests, verifies all four graphics modes, and
batch-tests all 163 `.tru` files. Current results: **120/163 (73.6%)** of
`.tru` files pass, with the remainder needing interactive input or external
library files.

### Manual Testing

```bash
raku TrueBASIC.raku examples/simple.bas
raku TrueBASIC.raku examples/loop.bas
raku TrueBASIC.raku examples/sortrootswap.tru
raku TrueBASIC.raku --graphics=svg examples/phase_diagram.bas
```

## Requirements

- **Raku** v6.d or later (`raku --version` to check)

### For GTK Graphics (optional)

- `Gnome::Gtk3` — `zef install Gnome::Gtk3`
- `Gnome::Cairo` — `zef install Gnome::Cairo`
- System packages: `libgtk-3-dev`, `libcairo2-dev`

See [GTK_INSTALLATION_GUIDE.md](GTK_INSTALLATION_GUIDE.md) for detailed
setup instructions. GTK is optional — the interpreter auto-detects its
availability and falls back to SVG or ASCII.

## Installation

```bash
# 1. Install Raku (if not already present)
#    See https://rakudo.org/downloads

# 2. Clone the repository
git clone https://github.com/your-username/TrueBASIC7.git
cd TrueBASIC7

# 3. (Optional) Install GTK graphics support
zef install Gnome::Gtk3 Gnome::Cairo

# 4. Run a program
raku TrueBASIC.raku examples/simple.bas
```

## Project Structure

```
TrueBASIC7/
├── TrueBASIC.raku              # The interpreter (grammar + actions + runtime + graphics)
├── README.md                   # This documentation
├── GTK_INSTALLATION_GUIDE.md   # GTK/Cairo setup instructions
├── examples/                   # 193 example programs
│   ├── *.bas                   #   30 demonstration programs
│   └── *.tru                   #   163 scientific/engineering programs
├── test/
│   ├── test-suite.raku         #   Automated test suite
│   └── ...                     #   Individual test scripts
├── archive/                    # Previous interpreter versions (reference)
├── lib/                        # Module library (from Decimal BASIC translation)
└── source/                     # Original Pascal source (reference)
```

## Architecture

TrueBASIC7 is a single-file interpreter with four stages:

1. **Grammar** — A Raku grammar with case-insensitive `:i` rules parses True
   BASIC syntax. A 3-second timeout falls back to line-by-line parsing for
   complex files.

2. **Actions** — Grammar matches produce a hash-based AST
   (e.g. `{ type => 'for', variable => 'I', start => {...}, end => {...} }`).

3. **Interpreter** — A tree-walking evaluator executes the AST. Variables and
   arrays are stored in hashes with uppercase-normalized names.

4. **Graphics** — A `PlotRenderer` class collects plot data during execution
   and renders through the selected backend (GTK/Cairo, HTML5 Canvas, SVG,
   or ASCII).

## Known Limitations

- **File I/O** (`OPEN #n: name`, `PRINT #n`, `INPUT #n`) is stubbed but not
  yet functional for file access.
- **PRINT USING** formatting is not implemented.
- Some programs referencing external `LIBRARY` files will report
  "SUB not found."
- Very large programs (600+ lines) may take a few seconds to parse.
- `GET KEY` returns 0 immediately (non-blocking stub) — interactive
  keyboard polling requires GTK event loop integration.

## License

This project is open source. Feel free to use, modify, and distribute.