! True BASIC Graphics Test
! Tests SET WINDOW, SET COLOR, PLOT, LINE, CIRCLE, BOX

SET WINDOW -10, 10, -10, 10

! Draw coordinate axes
SET COLOR 1
PLOT LINES: -10, 0; 10, 0
PLOT LINES: 0, -10; 0, 10

! Draw a red sine wave
SET COLOR 2
FOR x = -10 TO 10 STEP 0.1
    LET y = 3 * SIN(x)
    PLOT x, y;
NEXT x
PLOT

! Draw a green circle
SET COLOR 3
CIRCLE 0, 0, 5

! Draw a blue box
SET COLOR 4
BOX LINES -7, -7, 7, 7

! Draw some colored points
SET COLOR 5
FOR i = 1 TO 20
    LET angle = i * 3.14159 / 10
    LET px = 8 * COS(angle)
    LET py = 8 * SIN(angle)
    PLOT px, py
NEXT i

! Label
PLOT TEXT, AT -3, 9: "Graphics Test"

PRINT "Graphics test complete"
END
