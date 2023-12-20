*> Text cells for one output row. Dropped fields (surname, given name, note,
*> narrative) do not exist here, so no handler can emit them.
01 PAT-ROW.
   05 PR-COHORT PIC X(8).
   05 PR-PSEUDO PIC X(17).
   05 PR-BIRTHYEAR PIC X(4).
   05 PR-AGE PIC X(3).
   05 PR-SEX PIC X.
   05 PR-SITE PIC X(4).
   05 PR-ENROLL PIC X(10).
   05 PR-ARM PIC X(2).
   05 PR-WEIGHT PIC X(10).
   05 PR-HEIGHT PIC X(10).
   05 PR-CONSENT PIC X.
01 LAB-ROW.
   05 LR-VISIT PIC X(3).
   05 LR-DATE PIC X(10).
   05 LR-SLOT PIC 9.
   05 LR-CODE PIC X(6).
   05 LR-RESULT PIC X(14).
   05 LR-UNIT PIC X(6).
01 AE-ROW.
   05 AR-EVSEQ PIC X(3).
   05 AR-TERM PIC X(24).
   05 AR-SEV PIC X.
   05 AR-ONSET PIC X(10).
   05 AR-NARRLEN PIC 9(2).
   05 AR-HAD PIC X.
