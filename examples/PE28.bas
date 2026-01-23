PROGRAM PE28 

REM Project Euler Problem 28 

REM Find sum of diagonals for spiral matrix N=1001 

REM Jovan Trujillo 

REM 7/24/2023 

REM Solution in True BASIC 6 

REM 21 22 23 24 25 

REM 20  7  8  9 10 

REM 19  6  1  2 11 

REM 18  5  4  3 12 

REM 17 16 15 14 13 

REM 

REM 43 44 45 46 47 48 49 

REM 42 21 22 23 24 25 26 

REM 41 20  7  8  9 10 27 

REM 40 19  6  1  2 11 28 

REM 39 18  5  4  3 12 29 

REM 38 17 16 15 14 13 30 

REM 37 36 35 34 33 32 31 

REM 

REM Step count pattern is R1,D1,L1,L2,U1,U2,R1,R2,R3,D1,D2,D3,L1,L2,L3,L4,U1,U2,U3,U4,R1,R2,R3,R4 

REM So steps are R1,D1,L2,U2,R3,D3,L4,U4,R4 or 1,1,2,2,3,3,4,4,4 

REM  

REM And for N=7 the patttern would be 1,1,2,2,3,3,4,4,5,5,6,6,6 

REM For N=7 there are 7+7-1=13 legs 

REM For N=5 there are 5+5-1=9 legs.  

REM Last leg has same number of steps as previous.  

 

OPTION NOLET 

SET Zonewidth 5 !allows large matrices on screen 

N = 1001 

B = CEIL(N/2) 

NLEGS = N+N-1 

LEGLENGTH = 1 

LEGCNT = 1 

STEPIDX = 1 

SUM = 0 

DIM MTX(1,1) 

NSTEPS = N*N 

MAT MTX=ZER(N,N) 

REM Center of matrix will be 1, then it walks in a spiral to the right and down till it reaches the last element.  

X = CEIL(N/2) 

Y = CEIL(N/2) 

PRINT X,Y 

MVAL = 1 

REM DIR is step direction, 1 - Right, 2 - Down, 3 - Left, 4 - Up 

DIR = 1 

FOR I = 1 TO NSTEPS 

MTX(Y,X) = I 

IF ABS(X-B) = ABS(Y-B) THEN  

SUM = SUM + I 

END IF 

IF DIR = 1 THEN 

REM Move Right 

X = X + 1 

STEPIDX = STEPIDX+1 

IF STEPIDX > LEGLENGTH THEN 

REM Time to change direction. 

STEPIDX = 1 

LEGCNT = LEGCNT + 1 

NLEGS = NLEGS - 1 

DIR = 2 

END IF  

ELSEIF DIR = 2 THEN 

REM Move Down 

Y = Y + 1 

STEPIDX = STEPIDX+1 

IF STEPIDX > LEGLENGTH THEN 

REM Time to change direction 

STEPIDX = 1 

LEGCNT = LEGCNT + 1 

NLEGS = NLEGS - 1 

DIR = 3 

END IF 

ELSEIF DIR = 3 THEN 

REM Move Left 

X = X - 1 

STEPIDX = STEPIDX+1 

IF STEPIDX > LEGLENGTH THEN 

REM Time to change direction 

STEPIDX = 1 

LEGCNT = LEGCNT + 1 

NLEGS = NLEGS - 1 

DIR = 4 

END IF 

ELSE  

REM DIR = 4 

REM Move Up 

Y = Y - 1 

STEPIDX = STEPIDX+1 

IF STEPIDX > LEGLENGTH THEN 

REM Time to change direction 

STEPIDX = 1 

LEGCNT = LEGCNT + 1 

NLEGS = NLEGS - 1 

DIR = 1 

END IF 

END IF  

IF LEGCNT > 2 THEN 

IF NLEGS > 0 THEN 

LEGCNT = 1 

LEGLENGTH = LEGLENGTH + 1 

END IF 

END IF 

REM TEST MY LOGIC: PRINT I, X, Y, STEPIDX, LEGLENGTH, LEGCNT, DIR, NLEGS 

NEXT I 

 

REM Can't print huge matrices 

REM MAT PRINT MTX 

 

REM Now find the sum of the diagonals! 

PRINT "SUM: ", SUM 

GET KEY done 

END 

 