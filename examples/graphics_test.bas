! Graphics Test Program
! Test basic graphics functionality

PROGRAM GraphicsTest
    ! Test simple graphics operations
    SET WINDOW 0, 10, 0, 10
    
    ! Draw a simple pattern
    FOR I = 1 TO 5
        PLOT I, I
        PLOT I*2, I
    NEXT I
    
    ! Draw a line
    PLOT LINES: 1,1; 9,9
    
    ! Draw a rectangle
    PLOT LINES: 2,2; 8,2; 8,8; 2,8; 2,2
    
    PRINT "Graphics test complete"
END