! Chemistry Plot Demo
! Phase diagram using True BASIC graphics
OPTION NOLET

PRINT "Generating Van der Waals phase diagram..."
PRINT

! Constants for CO2
a = 3.592
b = 0.04267
R_gas = 0.08206

! Set up the plot window  
SET WINDOW 0, 1.5, 0, 100

! Draw several isotherms
SET COLOR 4
T = 250
FOR V = 0.05 TO 1.5 STEP 0.01
    P = R_gas * T / (V - b) - a / V^2
    IF P > 0 AND P < 100 THEN
        PLOT V, P;
    END IF
NEXT V
PLOT V, P

SET COLOR 1
T = 300
FOR V = 0.05 TO 1.5 STEP 0.01
    P = R_gas * T / (V - b) - a / V^2
    IF P > 0 AND P < 100 THEN
        PLOT V, P;
    END IF
NEXT V
PLOT V, P

SET COLOR 2
T = 350
FOR V = 0.05 TO 1.5 STEP 0.01
    P = R_gas * T / (V - b) - a / V^2
    IF P > 0 AND P < 100 THEN
        PLOT V, P;
    END IF
NEXT V
PLOT V, P

SET COLOR 5
T = 400
FOR V = 0.05 TO 1.5 STEP 0.01
    P = R_gas * T / (V - b) - a / V^2
    IF P > 0 AND P < 100 THEN
        PLOT V, P;
    END IF
NEXT V
PLOT V, P

! Labels
SET COLOR 0
PLOT TEXT, AT 0.6, 95: "Van der Waals Isotherms (CO2)"
SET COLOR 4
PLOT TEXT, AT 1.1, 50: "250 K"
SET COLOR 1
PLOT TEXT, AT 1.1, 62: "300 K"
SET COLOR 2
PLOT TEXT, AT 1.1, 74: "350 K"
SET COLOR 5
PLOT TEXT, AT 1.1, 86: "400 K"

! Axis labels
SET COLOR 0
PLOT TEXT, AT 0.6, -5: "Volume (L/mol)"

PRINT "Phase diagram complete"
END
