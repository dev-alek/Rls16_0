define input parameter p-mode as logical no-undo .
define input-output parameter p-Token as logical no-undo .
DEFINE BUTTON Btn_cancel AUTO-GO
  LABEL "Отмена"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
  LABEL "Сохранить"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE VARIABLE T-token AS LOGICAL INITIAL no
  LABEL "Отключить запрос Token"
  VIEW-AS TOGGLE-BOX
  SIZE 36 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
  Btn_OK AT ROW 1 COL 1
  Btn_cancel AT ROW 1 COL 11.13 WIDGET-ID 2
  T-token AT ROW 2.75 COL 5.5 WIDGET-ID 4
  SPACE(0.00) SKIP(1.12)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Token"
  DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.
ON VALUE-CHANGED OF T-token IN FRAME Dialog-Frame
  DO:
    assign t-token .
  END.
ON choose OF Btn_OK IN FRAME Dialog-Frame
  DO:
    p-Token = t-token .
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
  T-token = p-Token .
  DISPLAY T-token
    WITH FRAME Dialog-Frame.
  if p-mode = yes then
  do:
    enable T-token with frame Dialog-Frame .
  end.
  ENABLE Btn_OK Btn_cancel WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
