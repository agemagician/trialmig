*> RFC 4180 cell formatting. TEXT: non-printable bytes become '?' (flag NP),
*> a leading = + - @ gets a quote prefix so spreadsheets do not run it as a
*> formula, then the cell is quoted if it holds a comma or quote. NUM: pass
*> through trimmed; numeric cells are formatted by the tool and never prefixed.
IDENTIFICATION DIVISION.
PROGRAM-ID. CSVFMT.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-I PIC 9(3) COMP-5.
01 WS-LEN PIC 9(3) COMP-5.
01 WS-BUF PIC X(80).
01 WS-NEEDQ PIC 9.
01 WS-O PIC 9(3) COMP-5.
01 WS-WORK PIC X(200).
01 WS-WLEN PIC 9(3) COMP-5.
LINKAGE SECTION.
01 LK-OP PIC X(4).
01 LK-IN PIC X(80).
01 LK-INLEN PIC 9(3).
01 LK-OUT PIC X(200).
01 LK-OUTLEN PIC 9(3).
01 LK-NPFLAG PIC X.
PROCEDURE DIVISION USING LK-OP LK-IN LK-INLEN LK-OUT LK-OUTLEN LK-NPFLAG.
MAIN-PARA.
    MOVE SPACES TO LK-OUT
    MOVE 0 TO LK-OUTLEN
    MOVE "N" TO LK-NPFLAG
    MOVE LK-INLEN TO WS-LEN
    PERFORM UNTIL WS-LEN = 0 OR LK-IN(WS-LEN:1) NOT = SPACE
        SUBTRACT 1 FROM WS-LEN
    END-PERFORM
    IF WS-LEN > 0
        IF LK-OP = "NUM "
            MOVE LK-IN(1:WS-LEN) TO LK-OUT
            MOVE WS-LEN TO LK-OUTLEN
        ELSE
            PERFORM FORMAT-TEXT
        END-IF
    END-IF
    GOBACK.

FORMAT-TEXT.
    MOVE LK-IN TO WS-BUF
    MOVE 0 TO WS-NEEDQ
    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LEN
        IF WS-BUF(WS-I:1) < SPACE OR WS-BUF(WS-I:1) > "~"
            MOVE "?" TO WS-BUF(WS-I:1)
            MOVE "Y" TO LK-NPFLAG
        END-IF
        IF WS-BUF(WS-I:1) = "," OR WS-BUF(WS-I:1) = QUOTE
            MOVE 1 TO WS-NEEDQ
        END-IF
    END-PERFORM
    MOVE SPACES TO WS-WORK
    MOVE 0 TO WS-WLEN
    IF WS-BUF(1:1) = "=" OR "+" OR "-" OR "@"
        MOVE "'" TO WS-WORK(1:1)
        MOVE 1 TO WS-WLEN
    END-IF
    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LEN
        ADD 1 TO WS-WLEN
        MOVE WS-BUF(WS-I:1) TO WS-WORK(WS-WLEN:1)
    END-PERFORM
    IF WS-NEEDQ = 0
        MOVE WS-WORK TO LK-OUT
        MOVE WS-WLEN TO LK-OUTLEN
    ELSE
        MOVE QUOTE TO LK-OUT(1:1)
        MOVE 1 TO WS-O
        PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-WLEN
            ADD 1 TO WS-O
            MOVE WS-WORK(WS-I:1) TO LK-OUT(WS-O:1)
            IF WS-WORK(WS-I:1) = QUOTE
                ADD 1 TO WS-O
                MOVE QUOTE TO LK-OUT(WS-O:1)
            END-IF
        END-PERFORM
        ADD 1 TO WS-O
        MOVE QUOTE TO LK-OUT(WS-O:1)
        MOVE WS-O TO LK-OUTLEN
    END-IF.
