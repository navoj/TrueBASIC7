# True BASIC Interpreter

A Raku implementation of a True BASIC programming language interpreter.

## Features

The interpreter supports the following True BASIC language features:

### Variables and Data Types
- Numeric variables (integers and floating-point)
- String variables (ending with $)
- Automatic type conversion

### Control Flow
- `IF...THEN...ELSE` conditional statements
- `FOR...NEXT` loops with optional STEP
- `DO...LOOP` with WHILE/UNTIL conditions
- `GOTO` and line numbers
- `GOSUB...RETURN` subroutines

### Built-in Commands
- `PRINT` - Output text and values
- `INPUT` - Get user input
- `LET` - Variable assignment (optional)
- `DIM` - Declare arrays
- `END`/`STOP` - Terminate program
- `CLS` - Clear screen

### Built-in Functions
- `ABS(x)` - Absolute value
- `ATN(x)` - Arctangent
- `COS(x)` - Cosine
- `SIN(x)` - Sine
- `TAN(x)` - Tangent
- `EXP(x)` - Exponential
- `LOG(x)` - Natural logarithm
- `SQR(x)` - Square root
- `INT(x)` - Integer part
- `RND(x)` - Random number
- `LEN(s$)` - String length
- `CHR$(n)` - Character from ASCII
- `STR$(n)` - Convert number to string
- `VAL(s$)` - Convert string to number

### Arrays
- One and multi-dimensional arrays
- Dynamic allocation with DIM statement

## Usage

### Command Line
```bash
# Run a BASIC program file
raku TrueBASIC.raku program.bas

# Run with debug mode
raku TrueBASIC.raku --debug program.bas
```

### Interactive Mode
```bash
# Start interactive interpreter
raku TrueBASIC.raku

# Interactive commands:
help     - Show available commands
list     - List all variables and their values
clear    - Clear all variables
debug    - Toggle debug mode
quit     - Exit the interpreter
```

## Examples

### Simple Program
```basic
10 LET A = 5
20 LET B = 10
30 PRINT "Sum:", A + B
40 END
```

### Loop Example
```basic
10 FOR I = 1 TO 5
20   PRINT "Number:", I
30 NEXT I
40 END
```

### Conditional Example
```basic
10 INPUT "Enter a number: "; N
20 IF N > 0 THEN PRINT "Positive"
30 IF N < 0 THEN PRINT "Negative"
40 IF N = 0 THEN PRINT "Zero"
50 END
```

### Subroutine Example
```basic
10 GOSUB 100
20 PRINT "Main program"
30 END
100 PRINT "This is a subroutine"
110 RETURN
```

## File Structure

```
TrueBASIC7/
├── TrueBASIC.raku          # Main interpreter
├── README.md               # This documentation
└── examples/               # Example programs
    ├── simple.bas          # Basic arithmetic
    ├── loop.bas            # FOR/NEXT loops
    ├── guess.bas           # Guessing game
    ├── subroutine.bas      # GOSUB/RETURN
    ├── arrays.bas          # Array handling
    └── doloop.bas          # DO/LOOP constructs
```

## Language Syntax

### Line Numbers
Programs can use line numbers (optional in modern True BASIC):
```basic
10 PRINT "Hello"
20 END
```

### Variables
```basic
LET X = 5           ! Numeric variable
LET NAME$ = "John"  ! String variable ($ suffix)
X = 10              ! LET is optional
```

### Expressions
```basic
LET Y = X + 5 * 2   ! Arithmetic operators: +, -, *, /
LET B = (A > 5)     ! Comparison operators: =, <>, <, >, <=, >=
```

### Arrays
```basic
DIM A(10)           ! One-dimensional array
DIM B(5, 5)         ! Two-dimensional array
LET A(1) = 42       ! Array assignment
```

### Comments
```basic
REM This is a comment
! This is also a comment
' This is a comment too
```

## Requirements

- Raku programming language (version 6.d or later)
- Terminal/console for input/output

## Installation

1. Ensure Raku is installed on your system
2. Download or clone this repository
3. Make the script executable:
   ```bash
   chmod +x TrueBASIC.raku
   ```
4. Run the interpreter as shown in the Usage section

## Testing

Test the interpreter with the provided examples:

```bash
cd TrueBASIC7
raku TrueBASIC.raku examples/simple.bas
raku TrueBASIC.raku examples/loop.bas
raku TrueBASIC.raku examples/guess.bas
```

## Limitations

This is a basic implementation and may not support all True BASIC features:
- Limited graphics capabilities
- No file I/O operations
- No advanced mathematical functions
- No structured exception handling
- Limited string manipulation functions

## Contributing

Feel free to extend the interpreter by adding more True BASIC features:
- Additional built-in functions
- File I/O operations
- Graphics commands
- Advanced control structures
- Error handling improvements

## License

This project is open source. Feel free to use, modify, and distribute as needed.