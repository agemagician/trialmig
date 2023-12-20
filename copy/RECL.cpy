*> L body: five panel slots. Declared OCCURS 5, count checked before indexing.
05 RB-L REDEFINES RF-BODY.
   10 RF-L-SRCID PIC X(10).
   10 RF-L-VISIT PIC X(3).
   10 RF-L-DATE PIC X(8).
   10 RF-L-PANELCNT PIC X.
   10 RF-L-SLOT OCCURS 5.
      15 RF-L-SLOT-CODE PIC X(6).
      15 RF-L-SLOT-RES PIC X(4).
   10 RF-L-TEST PIC X(6).
   10 RF-L-RESULT PIC X(5).
   10 RF-L-UNIT PIC X(6).
   10 RF-L-FILLER PIC X(10).
