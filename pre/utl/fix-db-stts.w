define input parameter parparentproc as widget-handle no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-ok AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE f-db AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 31 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     f-db AT ROW 1.95 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     b-ok AT ROW 3.38 COL 5
     b-cancel AT ROW 3.38 COL 21
     SPACE(3.99) SKIP(0.76)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите номер БД"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON choose OF b-ok IN FRAME Dialog-Frame
do :
  find first ub.db exclusive-lock where ub.db.db-num = integer(f-db) no-error.
  if not available ub.db
  then do :
    Message "База Данных с номером " f-db " не найдена" view-as alert-box.
    return no-apply.
  end.
  else do :
    ub.db.stts = 0 .
    Message "Готово" view-as alert-box.
  end.
end .
ON leave OF f-db IN FRAME Dialog-Frame
do :
  assign frame Dialog-Frame f-db .
  integer(f-db) no-error .
  if error-status:error
  then do :
    message "Номер БД введен не верно!" view-as alert-box .
    apply "entry" to f-db in frame Dialog-Frame .
    return no-apply .
  end .
end .
ON return OF f-db IN FRAME Dialog-Frame
do :
  assign frame Dialog-Frame f-db .
  integer(f-db) no-error .
  if error-status:error
  then do :
    message "Номер БД введен не верно!" view-as alert-box .
    apply "entry" to f-db in frame Dialog-Frame .
    return no-apply .
  end .
  apply "choose" to b-ok in frame Dialog-Frame .
end .
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
  DISPLAY f-db
      WITH FRAME Dialog-Frame.
  ENABLE f-db b-ok b-cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
