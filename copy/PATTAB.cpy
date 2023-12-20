*> Patient table: pseudonym and date shift computed once per accepted P record.
01 PATIENT-TABLE.
   05 PT-COUNT PIC 9(4) VALUE 0.
   05 PT-ENTRY OCCURS CAP-MAX-PATIENTS.
      10 PT-SRCID PIC X(10).
      10 PT-PSEUDO PIC X(17).
      10 PT-SHIFT PIC S9(4).
