! TrueBASIC7 Graphics Demo
! Demonstrates plotting, shapes, text, and color
PROGRAM GraphicsDemo

SET WINDOW -1, 11, -2, 2

! Draw axes
SET COLOR 7
PLOT LINES: 0,-2; 0,2
PLOT LINES: -1,0; 11,0

! Sine wave in red
SET COLOR 4
FOR X = 0 TO 10 STEP 0.05
    PLOT X, SIN(X);
NEXT X
PLOT X, SIN(X)

! Cosine wave in blue
SET COLOR 1
FOR X = 0 TO 10 STEP 0.05
    PLOT X, COS(X);
NEXT X
PLOT X, COS(X)

! Damped sine in green
SET COLOR 2
FOR X = 0 TO 10 STEP 0.05
    PLOT X, EXP(-X/5) * SIN(2*X);
NEXT X
PLOT X, EXP(-X/5) * SIN(2*X)

! Labels
SET COLOR 0
PLOT TEXT, AT 5, 1.8: "TrueBASIC7 Graphics Demo"
SET COLOR 4
PLOT TEXT, AT 8, 0.9: "sin(x)"
SET COLOR 1
PLOT TEXT, AT 8, -0.5: "cos(x)"
SET COLOR 2
PLOT TEXT, AT 8, 0.3: "damped"

! Box around the plot
SET COLOR 0
PLOT LINES: -1,-2; 11,-2
PLOT LINES: 11,-2; 11,2
PLOT LINES: 11,2; -1,2
PLOT LINES: -1,2; -1,-2

PRINT "Graphics demo complete - 3 waveforms plotted"
END
