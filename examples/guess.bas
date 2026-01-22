! Example 3: Conditional statements and input
10 PRINT "Guess the number game!"
20 LET SECRET = 42
30 INPUT "Enter your guess: "; GUESS
40 IF GUESS = SECRET THEN PRINT "Correct! You win!"
50 IF GUESS < SECRET THEN PRINT "Too low!"
60 IF GUESS > SECRET THEN PRINT "Too high!"
70 END