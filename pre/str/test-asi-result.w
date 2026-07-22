define input parameter p-title as character no-undo .
define input parameter p-labels as character no-undo .
define input parameter p-values as character no-undo .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "OK"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-1 AS DECIMAL FORMAT "->>>>9.9999":U INITIAL 0
     LABEL "Fill 1"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS DECIMAL FORMAT "->>>>9.9999":U INITIAL 0
     LABEL "Fill 1"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-3 AS DECIMAL FORMAT "->>>>9.9999":U INITIAL 0
     LABEL "Fill 1"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS DECIMAL FORMAT "->>>>9.99":U INITIAL 0
     LABEL "Fill 1"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 85 BY 7.5.
DEFINE FRAME Dialog-Frame
     FILL-IN-1 AT ROW 2 COL 70 COLON-ALIGNED WIDGET-ID 2
     FILL-IN-2 AT ROW 3.5 COL 70 COLON-ALIGNED WIDGET-ID 4
     FILL-IN-3 AT ROW 5 COL 70 COLON-ALIGNED WIDGET-ID 6
     FILL-IN-4 AT ROW 6.5 COL 70 COLON-ALIGNED WIDGET-ID 6
     Btn_OK AT ROW 9 COL 65
     RECT-1 AT ROW 1 COL 2 WIDGET-ID 8
     SPACE(1) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       FILL-IN-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       FILL-IN-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       FILL-IN-3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       FILL-IN-4:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  Frame Dialog-Frame:title = p-title .
  FILL-IN-1 = decimal(entry(1, p-values)) no-error .
  FILL-IN-1:label = entry(1, p-labels, "|") no-error .
  FILL-IN-2 = decimal(entry(2, p-values)) no-error .
  FILL-IN-2:label = entry(2, p-labels, "|") no-error .
  FILL-IN-3 = decimal(entry(3, p-values)) no-error .
  FILL-IN-3:label = entry(3, p-labels, "|") no-error .
  FILL-IN-4 = decimal(entry(4, p-values)) no-error .
  FILL-IN-4:label = entry(4, p-labels, "|") no-error .
  if p-title = "Результат расчета проверки корректности работы АСИ по массе НП"
  then do :
    FILL-IN-1:format = "->>>>>>>>>>9.9" .
    FILL-IN-2:format = "->>>>>>>>>>9.9" .
    FILL-IN-3:format = "->>>>>>>>>>9.9" .
  end .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-IN-1 FILL-IN-2 FILL-IN-3 FILL-IN-4
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 Btn_OK
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
