*> Common 120-byte record frame. Copy under a group; all fields are raw X so
*> packed bytes survive. Body layouts are REDEFINES of RF-BODY (RECP..RECT).
05 RF-TYPE PIC X.
05 RF-COHORT PIC X(8).
05 RF-REV PIC X.
05 RF-BODY PIC X(99).
COPY RECP.
COPY RECL.
COPY RECA.
COPY RECH.
COPY RECT.
05 RF-CKSUM PIC X(5).
05 RF-RESV PIC X(6).
