# TrueBASIC7 Copilot Instructions

## Overview

TrueBASIC7 is a comprehensive True BASIC interpreter written in Raku. It's a translation of the Pascal-based Decimal BASIC implementation, preserving the original architecture while leveraging Raku's modern language features.

The project consists of two main interpreter versions:
- **TrueBASIC.raku** - Simpler, original interpreter
- **TrueBASICDecimal.raku** - Full-featured interpreter with decimal precision, graphics, and advanced features

## Build and Execution

### Running BASIC Programs

```bash
# Execute a BASIC program file
raku TrueBASICDecimal.raku examples/simple.bas

# Run with debug output
raku TrueBASICDecimal.raku --debug examples/simple.bas

# Run in interactive REPL mode
raku TrueBASICDecimal.raku --interactive
```

### Testing and Development

```bash
# Run a single test file
raku test/test-simple.raku

# Run translation verification
raku test/test-translation.raku

# Test I/O system functionality
raku test/test-io-system.raku

# Test graphics functionality
raku test/test_graphics.raku
```

## Project Architecture

### Core Module Hierarchy

The `lib/` directory contains the translated modules from Pascal's Decimal BASIC:

1. **Base.rakumod**
   - Fundamental types, enums, and utility functions
   - Precision modes: Normal, High, Native, Complex, Rational
   - Global configuration variables
   - Exception framework

2. **Variable.rakumod**
   - Variable system and identifier management
   - Roles: Principal (evaluation), Variable (assignment), PointingVariable (references)
   - Variable types: NVari (numeric), FVari (float), CVari (complex), SVari (string)
   - Array support: NAVari, FAVari, CAVari, SAVari

3. **Expression.rakumod**
   - Mathematical and logical expression parsing/evaluation
   - Matrix class for matrix operations
   - Subscripted array access (1D-4D arrays)
   - Comparison and logical operations

4. **Statement.rakumod**
   - BASIC language statement representation and execution
   - Control flow: LetStatement, IfStatement, ForStatement, WhileStatement, DoLoopStatement
   - I/O: PrintStatement, InputStatement
   - Program structure: DimStatement, GotoStatement

5. **Compiler.rakumod**
   - Main compilation engine with two-pass compilation
   - Routine class for subroutines and functions
   - ProgramUnit for modular program organization
   - BasicCompiler as the central execution controller

6. **Graphics.rakumod** and related (SVGGraphics.rakumod, GnomeGraphics.rakumod, etc.)
   - Graphics rendering system with multiple backends
   - Supports both screen and file-based output

7. **IO.rakumod and TextFile.rakumod**
   - I/O device abstraction (Console, TextFile, CSVFile, DataSequence)
   - READ/INPUT/PRINT statement handling
   - Multi-device architecture with buffering

8. **Math2.rakumod, Math3.rakumod, SuppliedFunctions.rakumod**
   - Built-in mathematical functions
   - Trigonometric, logarithmic, and statistical functions

### Supporting Modules

- **Float.rakumod** - High-precision floating-point arithmetic
- **Rational.rakumod** - Exact rational number support
- **Module.rakumod** - Module system for program organization
- **Routine.rakumod** - Function/subroutine definitions
- **ProgramUnit.rakumod** - Program unit management
- **Using.rakumod** - External library imports
- **Format.rakumod** - Output formatting
- **TextHandler.rakumod** - String handling utilities
- **SimpleGraphics.rakumod** - ASCII-based graphics

## Key Conventions

### File Organization

- **Main files**: TrueBASIC.raku, TrueBASICDecimal.raku are the primary entry points
- **Modules**: All reusable components in `lib/` as `.rakumod` files
- **Tests**: In `test/` directory, use explicit naming (test-*.raku, test_*.raku)
- **Examples**: BASIC programs in `examples/` with `.bas` extension
- **Source**: Original Pascal source files in `source/` for reference

### Module Imports

All modules use `use v6.d` and export classes/roles with `is export`:

```raku
use v6.d;
use Base;        # Required for base types
use Variable;    # For variable management
use Expression;  # For expression evaluation
use Compiler;    # For compilation engine
```

### Class and Role Structure

- Use **roles** for interfaces and mixins (Principal, Variable, PointingVariable)
- Use **classes** for concrete types with `is` inheritance
- Implement exception classes as `class X::ErrorType is Exception`

### Variable Types

The system uses kind-based typing with suffixes:
- **N** = Numeric (integer-like, stored as decimal)
- **F** = Float (binary floating-point)
- **S** = String (text data)
- **C** = Complex (real + imaginary)
- **R** = Rational (exact fractions)

Arrays are prefixed with array name: NAVari (numeric array), SAVari (string array), etc.

### Exception Handling

- Exceptions inherit from `Exception` with `X::` prefix for control flow
- Common control exceptions: `X::ReturnException`, `X::GotoException`, `X::ExitLoopException`
- I/O exceptions: `IOError`, `EndOfDataException`, `InputMismatchException`

### Two-Pass Compilation Strategy

The compiler in Compiler.rakumod uses a two-pass approach:

1. **First Pass**: Parse program structure, collect routine definitions, build symbol tables
2. **Second Pass**: Resolve references, validate types, complete compilation

This is critical when modifying the compiler - changes that affect symbol resolution must update both passes.

### Precision Modes

Global precision is controlled via `%PrecisionText` hash and modes:
- `PrecisionNormal` - Standard decimal arithmetic
- `PrecisionHigh` - 1000+ digit precision
- `PrecisionNative` - Binary floating-point
- `PrecisionComplex` - Complex number arithmetic
- `PrecisionRational` - Exact rational arithmetic

Configuration set in `initialize-environment()` method of TrueBASICDecimalInterpreter.

## Running Tests

### Manual Testing

Test individual features by running BASIC programs:

```bash
# Arithmetic and variables
raku TrueBASICDecimal.raku examples/simple.bas

# Control flow
raku TrueBASICDecimal.raku examples/loop.bas
raku TrueBASICDecimal.raku examples/doloop.bas

# Arrays
raku TrueBASICDecimal.raku examples/arrays.bas

# Graphics (if GTK/graphics available)
raku TrueBASICDecimal.raku examples/graphics_test.bas
```

### Unit Tests

Test specific modules:

```bash
# Test translation integrity
raku test/test-translation.raku

# Test I/O system
raku test/test-io-system.raku

# Test simplified version
raku test/test-simple.raku
```

### Graphics Testing

The graphics system has multiple backends - test with available ones:

```bash
# SVG-based graphics (always available)
raku test/test_graphics.raku

# GTK-based graphics (if GTK installed)
raku test/test-gtk.raku

# Headless GNOME testing
raku test/test_gnome_headless.raku
```

## Debugging Flags

Use command-line options for the interpreter:

```bash
# Enable debug output (shows compilation/execution steps)
raku TrueBASICDecimal.raku --debug program.bas

# Set precision mode
raku TrueBASICDecimal.raku --precision=complex program.bas

# Interactive mode allows step-by-step execution
raku TrueBASICDecimal.raku --interactive
```

Within code, set `$!debug = True` in TrueBASICDecimalInterpreter for additional output.

## Common Modification Points

### Adding New Built-in Functions

1. Add function definition in **SuppliedFunctions.rakumod**
2. Register in ProcedureTable in **Compiler.rakumod**
3. Add evaluation logic in **Expression.rakumod** if needed
4. Test with a BASIC program calling the new function

### Adding New Statements

1. Create statement class in **Statement.rakumod** (inherit from Statement base class)
2. Add parsing logic to `parse-statement()` in **Compiler.rakumod**
3. Implement `execute()` method for execution
4. Test in `test-simple.raku` or create new test file

### Adding Graphics Features

1. Extend appropriate graphics module (Graphics.rakumod, SVGGraphics.rakumod, GnomeGraphics.rakumod)
2. Add to graphics command set (PLOT, DRAW, etc.)
3. Update graphics initialization if needed
4. Test with graphics_test.bas or create new example

### Extending Precision Support

1. Add precision mode constant to **Base.rakumod**
2. Implement arithmetic operations in appropriate module (Float.rakumod, Rational.rakumod)
3. Update Variable.rakumod to support new variable kind
4. Extend Compiler.rakumod type handling
5. Test with examples using the new precision mode

## Known Limitations

- Graphics features depend on GTK/Gnome availability (fallback to text mode)
- Some advanced Pascal features not yet fully translated (see TRANSLATION_SUMMARY.md)
- File I/O works but may have platform-specific considerations
- Complex number support is functional but not all operations optimized

## Documentation Reference

- **README.md** - Feature overview and usage examples
- **TRANSLATION_SUMMARY.md** - Detailed Pascal-to-Raku translation notes
- **IO_TRANSLATION_SUMMARY.md** - I/O system architecture details
- **GTK_INSTALLATION_GUIDE.md** - Graphics system setup
- **source/** - Original Pascal implementation for reference

## Quick Reference: Entry Points

| File | Purpose | Run With |
|------|---------|----------|
| TrueBASICDecimal.raku | Full-featured interpreter | `raku TrueBASICDecimal.raku program.bas` |
| TrueBASIC.raku | Simpler original interpreter | `raku TrueBASIC.raku program.bas` |
| test-simple.raku | Basic functionality test | `raku test/test-simple.raku` |
| test-translation.raku | Module integration test | `raku test/test-translation.raku` |

## Raku Version

This project requires **Raku v6.d** or later. Verify with:

```bash
raku --version
```
