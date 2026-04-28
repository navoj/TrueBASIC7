! Comprehensive Graphics Demo
! Tests all True BASIC graphics features
OPTION NOLET

SET WINDOW -10, 10, -10, 10

! Draw axes
SET COLOR 0
PLOT LINES: -10, 0; 10, 0
PLOT LINES: 0, -10; 0, 10

! Draw a filled box
SET COLOR 1
BOX AREA -9, -5, -9, -5

! Draw an outlined box  
SET COLOR 4
BOX LINES -4, 0, -9, -5

! Draw a circle
SET COLOR 2
CIRCLE 5, 5, 3

! Draw a sine wave using PLOT with continuation
SET COLOR 5
FOR x = -10 TO 10 STEP 0.1
    y = 3 * SIN(x)
    PLOT x, y;
NEXT x
PLOT

! Draw a parabola
SET COLOR 3
FOR x = -5 TO 5 STEP 0.1
    y = -0.5 * x^2 + 8
    PLOT x, y;
NEXT x
PLOT

! Add text labels
SET COLOR 0
PLOT TEXT, AT -8, 9: "Graphics Demo"
PLOT TEXT, AT -8, -8: "Box Area"
PLOT TEXT, AT -3, -8: "Box Lines"
PLOT TEXT, AT 3, 9: "Circle"
PLOT TEXT, AT -9, 4: "Sine"
PLOT TEXT, AT -2, 8.5: "Parabola"

PRINT "All graphics features rendered successfully!"
END
