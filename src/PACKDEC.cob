*> Hand decode of COMP-3 bytes. Status 0 ok, 1 bad digit nibble (NUMCLASS), 2 bad sign (BADSIGN). The compiler's IS NUMERIC on packed data is
*> never relied on. Sign policy: C,F positive; D negative; A,E positive and
*> B negative with SGN flag in lenient mode, reject in strict mode; 0-9 reject.
IDENTIFICATION DIVISION.
PROGRAM-ID. PACKDEC.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-J PIC 9(2) COMP-5.
01 WS-B PIC 9(3) COMP-5.
01 WS-HI PIC 9(2) COMP-5.
01 WS-LO PIC 9(2) COMP-5.
01 WS-ACC PIC 9(15) COMP-5.
01 WS-NEG PIC 9 VALUE 0.
LINKAGE SECTION.
01 LK-RAW PIC X(7).
01 LK-NBYTES PIC 9.
01 LK-SCALE PIC 9.
01 LK-STRICT PIC X.
01 LK-VALUE PIC S9(11)V99.
01 LK-SGNFLAG PIC X.
01 LK-STATUS PIC 9.
PROCEDURE DIVISION USING LK-RAW LK-NBYTES LK-SCALE LK-STRICT
    LK-VALUE LK-SGNFLAG LK-STATUS.
MAIN-PARA.
    MOVE 0 TO LK-VALUE LK-STATUS WS-ACC WS-NEG
    MOVE "N" TO LK-SGNFLAG
    PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > LK-NBYTES
        COMPUTE WS-B = FUNCTION ORD(LK-RAW(WS-J:1)) - 1
        DIVIDE WS-B BY 16 GIVING WS-HI REMAINDER WS-LO
        IF WS-HI > 9
            MOVE 1 TO LK-STATUS
        ELSE
            COMPUTE WS-ACC = WS-ACC * 10 + WS-HI
        END-IF
        IF WS-J < LK-NBYTES
            IF WS-LO > 9
                MOVE 1 TO LK-STATUS
            ELSE
                COMPUTE WS-ACC = WS-ACC * 10 + WS-LO
            END-IF
        END-IF
    END-PERFORM
    IF LK-STATUS = 0
        PERFORM APPLY-SIGN
    END-IF
    IF LK-STATUS = 0
        COMPUTE LK-VALUE = WS-ACC / (10 ** LK-SCALE)
        IF WS-NEG = 1
            COMPUTE LK-VALUE = 0 - LK-VALUE
        END-IF
    END-IF
    GOBACK.

APPLY-SIGN.
    *> WS-LO still holds the low nibble of the last byte: the sign.
    EVALUATE WS-LO
        WHEN 12 WHEN 15
            CONTINUE
        WHEN 13
            MOVE 1 TO WS-NEG
        WHEN 10 WHEN 14
            IF LK-STRICT = "Y"
                MOVE 2 TO LK-STATUS
            ELSE
                MOVE "Y" TO LK-SGNFLAG
            END-IF
        WHEN 11
            IF LK-STRICT = "Y"
                MOVE 2 TO LK-STATUS
            ELSE
                MOVE "Y" TO LK-SGNFLAG
                MOVE 1 TO WS-NEG
            END-IF
        WHEN OTHER
            MOVE 2 TO LK-STATUS
    END-EVALUATE.
