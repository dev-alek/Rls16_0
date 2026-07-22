define input parameter parparentproc as widget-handle no-undo.
define input parameter p-code like ub.chk-doc.doc-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты чека".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
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
define  temp-table tt-chk-attr no-undo
field attr-type as char
field attr-code as char
field attr-value as char
field attr-num as integer.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE QUERY br-attr FOR
      tt-chk-attr SCROLLING.
DEFINE BROWSE br-attr
    QUERY br-attr DISPLAY
    tt-chk-attr.attr-num COLUMN-LABEL "Номер" width 5 FORMAT "999":U
    tt-chk-attr.attr-code COLUMN-LABEL "Код" width 10 FORMAT "X(20)":U
    tt-chk-attr.attr-value COLUMN-LABEL "Значение атрибута" WIDTH 70 FORMAT "X(220)":U
    tt-chk-attr.attr-type COLUMN-LABEL "Тип" FORMAT "X(20)":U
    WITH SEPARATORS SIZE 102.5 BY 15.5 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     br-attr AT ROW 2.75 COL 1 WIDGET-ID 200
     SPACE(0.74) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты чека"
         DEFAULT-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       br-attr:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  apply "go".
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  for each chk-gds-attr
        where chk-gds-attr.doc-code = p-code no-lock:
        create tt-chk-attr.
       assign
        tt-chk-attr.attr-value = chk-gds-attr.attr-value
        tt-chk-attr.attr-code = chk-gds-attr.attr-code
        tt-chk-attr.attr-num = chk-gds-attr.line-num
        tt-chk-attr.attr-type = "Товар".
   end.
            for each chk-pay-attr
                where chk-pay-attr.doc-code = p-code no-lock:
                create tt-chk-attr.
                assign
                tt-chk-attr.attr-value = chk-pay-attr.attr-value
                tt-chk-attr.attr-code = chk-pay-attr.attr-code
                tt-chk-attr.attr-num = chk-pay-attr.line-num
                tt-chk-attr.attr-type = "Оплата".
            end.
        for each chk-doc-attr
                where chk-doc-attr.doc-code = p-code no-lock:
        if chk-doc-attr.attr-code begins "corr-" then next.
                create tt-chk-attr.
                assign
                tt-chk-attr.attr-value = chk-doc-attr.attr-value
                tt-chk-attr.attr-code = chk-doc-attr.attr-code
                tt-chk-attr.attr-type = "Чек".
        end.
    for each chk-discnt-attr where chk-discnt-attr.doc-code = p-code no-lock:
    if chk-discnt-attr.attr-code = "promo-id" and chk-discnt-attr.line-num = 0 then next .
                create tt-chk-attr.
                assign
                tt-chk-attr.attr-value = chk-discnt-attr.attr-value
                tt-chk-attr.attr-code = chk-discnt-attr.attr-code
                tt-chk-attr.attr-num = chk-discnt-attr.line-num
                tt-chk-attr.attr-type = "Скидка".
      end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE cd-attr :
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-quit br-attr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-attr FOR EACH tt-chk-attr .
END PROCEDURE.
