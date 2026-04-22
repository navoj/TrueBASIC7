! Better sine wave plot
GRAPHICS WEB
WINDOW 0, 0, 10, 10

! Plot a simple pattern
FOR X = 0 TO 10 STEP 1
    PLOT X, X
NEXT X

SHOW PLOT
PRINT "Linear plot saved"
END