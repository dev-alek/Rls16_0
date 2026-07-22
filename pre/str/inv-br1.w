define temp-table tt-no-marking-gds no-undo
  field artic as character label "Артикул"
  field gds-name as character label "Имя"
  field qnty as character label "Кол-во"
.
define input parameter table for tt-no-marking-gds.
define output parameter p-not-accept as logical no-undo.
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Да"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_Cancel AUTO-GO
     LABEL "Нет"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Подтвердите количество немаркированной продукции"
     VIEW-AS FILL-IN
     SIZE 51 BY 1 NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
      tt-no-marking-gds SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 NO-LOCK DISPLAY
      tt-no-marking-gds.artic FORMAT "X(12)":U
      tt-no-marking-gds.gds-name FORMAT "X(60)":U
      tt-no-marking-gds.qnty FORMAT "X(8)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 82.63 BY 12.5 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 2.25
     Btn_Cancel AT ROW 1.25 COL 18 WIDGET-ID 2
     FILL-IN-1 AT ROW 1.29 COL 32 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     BROWSE-2 AT ROW 2.63 COL 2.38 WIDGET-ID 200
     SPACE(0.61) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Кол-во немаркированной продукции"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
on choose of Btn_Cancel in frame Dialog-Frame
DO:
  p-not-accept = true.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-IN-1
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel BROWSE-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH tt-no-marking-gds NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
