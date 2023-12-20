*> Record checksum over raw EBCDIC bytes 1-109 (modulus 255 Fletcher form).
*> Because the modulus is 255, bytes 0x00 and 0xFF contribute the same. The sum
*> is s2*256+s1 with s1 <= 254, so a stored value whose low byte is 255 can
*> never equal a computed sum and is rejected by the caller's comparison.
IDENTIFICATION DIVISION.
PROGRAM-ID. FLETCH16.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-I PIC 9(3) COMP-5.
01 WS-B PIC 9(3) COMP-5.
01 WS-S1 PIC 9(5) COMP-5.
01 WS-S2 PIC 9(5) COMP-5.
LINKAGE SECTION.
01 LK-REC PIC X(109).
01 LK-SUM PIC 9(5).
01 LK-STATUS PIC 9.
PROCEDURE DIVISION USING LK-REC LK-SUM LK-STATUS.
MAIN-PARA.
    MOVE 0 TO WS-S1 WS-S2
    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 109
        COMPUTE WS-B = FUNCTION ORD(LK-REC(WS-I:1)) - 1
        COMPUTE WS-S1 = FUNCTION MOD(WS-S1 + WS-B, 255)
        COMPUTE WS-S2 = FUNCTION MOD(WS-S2 + WS-S1, 255)
    END-PERFORM
    COMPUTE LK-SUM = WS-S2 * 256 + WS-S1
    MOVE 0 TO LK-STATUS
    GOBACK.
