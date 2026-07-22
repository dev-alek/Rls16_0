define input  parameter parparentproc as handle    no-undo .
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-ok AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE f-chk-doc AS integer FORMAT ">>>>>>>>>9":U
     LABEL "Чеки"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-chk-doc-cur AS integer FORMAT ">>>>>>>>>9":U
     LABEL "(Текущее значение"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-fin-doc AS integer FORMAT ">>>>>>>>>9":U
     LABEL "Кассовые ордера"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-fin-doc-cur AS integer FORMAT ">>>>>>>>>9":U
     LABEL "(Текущее значение"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-trn-doc AS integer FORMAT ">>>>>>>>>9":U
     LABEL "Складские док-ты/Сверки"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-trn-doc-cur AS integer FORMAT ">>>>>>>>>9":U
     LABEL "(Текущее значение"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.24 COL 2
     b-cancel AT ROW 1.24 COL 17
     f-trn-doc AT ROW 3 COL 27 COLON-ALIGNED WIDGET-ID 2
     f-trn-doc-cur AT ROW 3 COL 64 COLON-ALIGNED WIDGET-ID 12
     f-chk-doc-cur AT ROW 4.5 COL 64 COLON-ALIGNED WIDGET-ID 16
     f-chk-doc AT ROW 4.5 COL 27 COLON-ALIGNED WIDGET-ID 6
     f-fin-doc AT ROW 6 COL 27 COLON-ALIGNED WIDGET-ID 8
     f-fin-doc-cur AT ROW 6 COL 64 COLON-ALIGNED WIDGET-ID 18
     ")" VIEW-AS TEXT
          SIZE 2.6 BY .62 AT ROW 6 COL 80 WIDGET-ID 30
     ")" VIEW-AS TEXT
          SIZE 2.6 BY .62 AT ROW 4.5 COL 80 WIDGET-ID 28
     ")" VIEW-AS TEXT
          SIZE 2.6 BY .62 AT ROW 3 COL 80 WIDGET-ID 26
     SPACE(1) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Синхронизация счетчиков документов"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel WIDGET-ID 100.
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
    f-trn-doc
    f-chk-doc
    f-fin-doc
  .
  if f-trn-doc > 0 then current-value(s-trn-doc)  = f-trn-doc .
  if f-chk-doc > 0 then current-value(s-chk)      = f-chk-doc .
  if f-fin-doc > 0 then current-value(s-fin-doc)  = f-fin-doc .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
    f-trn-doc-cur = current-value(s-trn-doc)
    f-chk-doc-cur = current-value(s-chk)
    f-fin-doc-cur = current-value(s-fin-doc)
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-trn-doc f-trn-doc-cur f-chk-doc-cur
          f-chk-doc f-fin-doc f-fin-doc-cur
      WITH FRAME Dialog-Frame.
  ENABLE b-ok b-cancel f-trn-doc
         f-chk-doc f-fin-doc
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
