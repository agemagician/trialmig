*> Calendar helpers on YYYYMMDD. Valid years are 1900-2099. Day shift goes
*> through the proleptic Gregorian day number. A negative age clamps to 0.
IDENTIFICATION DIVISION.
PROGRAM-ID. DATEUTIL.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-D1.
   05 WS-Y1 PIC 9(4).
   05 WS-M1 PIC 9(2).
   05 WS-DD1 PIC 9(2).
01 WS-D2.
   05 WS-Y2 PIC 9(4).
   05 WS-M2 PIC 9(2).
   05 WS-DD2 PIC 9(2).
01 WS-MAXDAY PIC 9(2).
01 WS-INT PIC S9(9).
01 WS-YEARS PIC S9(4).
LINKAGE SECTION.
01 LK-OP PIC X(4).
01 LK-D1 PIC 9(8).
01 LK-D2 PIC 9(8).
01 LK-DAYS PIC S9(4).
01 LK-RESULT PIC 9(8).
01 LK-STATUS PIC 9.
PROCEDURE DIVISION USING LK-OP LK-D1 LK-D2 LK-DAYS LK-RESULT LK-STATUS.
MAIN-PARA.
    MOVE 0 TO LK-STATUS LK-RESULT
    MOVE LK-D1 TO WS-D1
    EVALUATE LK-OP
        WHEN "VALD" PERFORM CHECK-VALID
        WHEN "MISS"
            *> Result 1 means all-zero or all-nines: treated as a missing date.
            IF LK-D1 = 0 OR LK-D1 = 99999999
                MOVE 1 TO LK-RESULT
            END-IF
        WHEN "SHFT"
            COMPUTE WS-INT = FUNCTION INTEGER-OF-DATE(LK-D1) + LK-DAYS
            COMPUTE LK-RESULT = FUNCTION DATE-OF-INTEGER(WS-INT)
        WHEN "AGE "
            MOVE LK-D2 TO WS-D2
            COMPUTE WS-YEARS = WS-Y2 - WS-Y1
            IF WS-M2 < WS-M1 OR (WS-M2 = WS-M1 AND WS-DD2 < WS-DD1)
                SUBTRACT 1 FROM WS-YEARS
            END-IF
            IF WS-YEARS < 0
                MOVE 0 TO WS-YEARS
            END-IF
            MOVE WS-YEARS TO LK-RESULT
        WHEN OTHER
            MOVE 1 TO LK-STATUS
    END-EVALUATE
    GOBACK.

CHECK-VALID.
    IF WS-Y1 < 1900 OR WS-Y1 > 2099 OR WS-M1 < 1 OR WS-M1 > 12 OR WS-DD1 < 1
        MOVE 1 TO LK-STATUS
    ELSE
        EVALUATE WS-M1
            WHEN 4 WHEN 6 WHEN 9 WHEN 11 MOVE 30 TO WS-MAXDAY
            WHEN 2
                IF FUNCTION MOD(WS-Y1, 4) = 0
                    AND (FUNCTION MOD(WS-Y1, 100) NOT = 0
                         OR FUNCTION MOD(WS-Y1, 400) = 0)
                    MOVE 29 TO WS-MAXDAY
                ELSE
                    MOVE 28 TO WS-MAXDAY
                END-IF
            WHEN OTHER MOVE 31 TO WS-MAXDAY
        END-EVALUATE
        IF WS-DD1 > WS-MAXDAY
            MOVE 1 TO LK-STATUS
        END-IF
    END-IF.
