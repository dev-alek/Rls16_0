define input-output parameter p-FIO as character no-undo .
define input-output parameter p-position as character no-undo .
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON B-OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE f-FIO AS CHARACTER FORMAT "X(120)":U
     VIEW-AS FILL-IN
     SIZE 88 BY 1 NO-UNDO.
DEFINE VARIABLE f-position AS CHARACTER FORMAT "X(120)":U
     VIEW-AS FILL-IN
     SIZE 88 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     f-FIO AT ROW 2 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     f-position AT ROW 4 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     B-OK AT ROW 5.1 COL 2.8
     B-Cancel AT ROW 5.1 COL 17.8
     "ФИО" VIEW-AS TEXT
          SIZE 8 BY .62 AT ROW 1.2 COL 3 WIDGET-ID 2
     "Должность" VIEW-AS TEXT
          SIZE 12.2 BY .62 AT ROW 3.2 COL 3 WIDGET-ID 8
     SPACE(77.79) SKIP(2.48)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE " "
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-OK IN FRAME Dialog-Frame
DO:
  assign
    f-FIO
    f-position
    p-FIO = f-FIO
    p-position = f-position
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
    f-FIO = p-FIO
    f-position = p-position
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-FIO f-position
      WITH FRAME Dialog-Frame.
  ENABLE f-FIO f-position B-OK B-Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
