! Simple Plot Program
! Creates a sine wave plot

PROGRAM SinePlot
    SET WINDOW 0, 6.28, -1.2, 1.2
    
    ! Plot sine wave
    FOR X = 0 TO 6.28 STEP 0.1
        PLOT X, SIN(X)
    NEXT X
    
    ! Add axes
    PLOT LINES: 0,0; 6.28,0  ! X-axis
    PLOT LINES: 0,-1.2; 0,1.2 ! Y-axis
    
    PRINT "Sine wave plot complete"
END