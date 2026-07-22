define temp-table tt-goods no-undo
  field gds-code as integer
  field artic as character
  field gds-name as character
  index pi
    as primary unique
    gds-code
.
define input parameter p-gds-list as character no-undo .
define output parameter p-gds-code as integer no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-ok AUTO-GO
     LABEL "Выбор"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
define query br-goods for tt-goods .
define browse br-goods query br-goods no-lock
  display
    tt-goods.gds-code  label "Код" format ">>>>>>>>>9"
    tt-goods.artic     label "Артикул" format "X(12)"
    tt-goods.gds-name  label "Наименование" format "X(25)"
  with size 51 by 10 separators
.
DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.24 COL 2
     b-cancel AT ROW 1.24 COL 17
     br-goods at row 2.5 col 1
     SPACE(0.1) SKIP(0.1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выберите топливо для приёмки"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
on choose of b-ok in frame Dialog-Frame
do :
  if available tt-goods
  then do :
    p-gds-code = tt-goods.gds-code .
  end .
  else do :
    return no-apply .
  end .
end .
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run fill-tt .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
procedure fill-tt :
  define variable ii as integer no-undo .
  define buffer buf_goods for ub.goods .
  do ii = 1 to num-entries(p-gds-list) :
    for first buf_goods no-lock where buf_goods.gds-code = integer(entry(ii, p-gds-list)) :
      find first tt-goods where tt-goods.gds-code = buf_goods.gds-code no-error .
      if not available tt-goods
      then do :
        create tt-goods .
        assign
          tt-goods.gds-code = buf_goods.gds-code
          tt-goods.artic = buf_goods.artic
          tt-goods.gds-name = buf_goods.gds-name
        .
      end .
    end .
  end .
end procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-ok b-cancel br-goods
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  open query br-goods for each tt-goods .
END PROCEDURE.
