define output parameter p-comment as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закрытие документа".
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Нет"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Да"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE COMBO-BOX-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Причина"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Товар отсутствует","Марка не читается","Марка отсутствует в документе","Ошибки, выявленные на уровне офиса"
     DROP-DOWN-LIST
     SIZE 43 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 60 BY 7.75.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 2.25 COL 7.5
     Btn_Cancel AT ROW 2.25 COL 45.5
     COMBO-BOX-1 AT ROW 7.25 COL 16 COLON-ALIGNED WIDGET-ID 12
     "Вы уверены, что хотите завершить проверку документа" VIEW-AS TEXT
          SIZE 53 BY 1.25 AT ROW 3.58 COL 7.38 WIDGET-ID 6
     "с недопоставкой?" VIEW-AS TEXT
          SIZE 53 BY 1.25 AT ROW 5.04 COL 7.38 WIDGET-ID 10
     RECT-1 AT ROW 2 COL 3 WIDGET-ID 2
     SPACE(2.12) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Причина закрытия"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame
DO:
  p-comment = "" .
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
  if COMBO-BOX-1:screen-value = ? then do:
    message "Укажите причину"
    view-as alert-box.
    return no-apply .
  end.
  p-comment = "Причина: " + combo-box-1:screen-value .
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
  DISPLAY COMBO-BOX-1
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 Btn_OK Btn_Cancel COMBO-BOX-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
