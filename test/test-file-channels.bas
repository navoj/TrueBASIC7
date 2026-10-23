OPEN #1: name "channel-input.dat", access input, create old
INPUT #1: value
ASK #1: pointer position$
IF position$ <> "END" THEN
  PRINT "EOF check failed"
END IF
CLOSE #1
OPEN #2: name "channel-output.dat", create newold
PRINT #2: value
CLOSE #2
END
