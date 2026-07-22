define input parameter p-db-num as integer no-undo .
define input parameter p-doc-id as integer no-undo .
define buffer buf_utd for ub.utd .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE e-comment AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 78 BY 7.14 NO-UNDO.
DEFINE VARIABLE t-ok-sts AS LOGICAL INITIAL no
     LABEL "Работа с документом завершена"
     VIEW-AS TOGGLE-BOX
     SIZE 59 BY .81 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.24 COL 2
     Btn_Cancel AT ROW 1.24 COL 17
     e-comment AT ROW 3.38 COL 2 NO-LABEL WIDGET-ID 4
     t-ok-sts AT ROW 10.81 COL 2 WIDGET-ID 6
     "Введите комментарий:" VIEW-AS TEXT
          SIZE 25 BY .62 AT ROW 2.67 COL 2 WIDGET-ID 2
     SPACE(53.59) SKIP(8.56)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Комментарий"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON choose OF Btn_OK IN FRAME Dialog-Frame
DO:
  assign
    e-comment
    t-ok-sts
  .
  e-comment = trim(e-comment) .
  if e-comment = ""
  then do :
    message "Комментарий не может быть пустым." view-as alert-box .
    return no-apply .
  end .
  do transaction :
    find current buf_utd exclusive-lock no-error .
    if not available buf_utd
    then do :
      message "Документ заблокирован" view-as alert-box .
      return no-apply .
    end .
    buf_utd.comment = e-comment .
    if t-ok-sts
    then do :
      if buf_utd.sts = 54
      or buf_utd.sts = 51
      then do :
        buf_utd.sts = 58 .
      end .
      if buf_utd.sts = 56
      then do :
        buf_utd.sts = 57 .
      end .
    end .
  end .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first buf_utd no-lock where buf_utd.db-num = p-db-num
                               and buf_utd.doc-id = p-doc-id
  .
  e-comment = buf_utd.comment .
  RUN enable_UI.
  if buf_utd.sts = 58
  or buf_utd.sts = 57
  then do :
    disable
      Btn_OK
      e-comment
    with FRAME Dialog-Frame.
    hide t-ok-sts in FRAME Dialog-Frame.
  end .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY e-comment t-ok-sts
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel e-comment t-ok-sts
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
