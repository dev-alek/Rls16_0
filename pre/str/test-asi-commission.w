define temp-table tt-commission no-undo
  field ii as integer
  field comp as character
  field FIO  as character
  field position_ as character
  index pi as primary unique
    ii
.
define input parameter p-rvs-code as character no-undo .
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Состав комиссии (проверка корректности работы АСИ)":U.
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable ii as integer no-undo .
define buffer buf_rvs-doc-attr for ub.rvs-doc-attr .
DEFINE BUTTON b-chg
     LABEL "Изменить"
     SIZE 15 BY 1.14.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "Выход"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
define query br-comm for tt-commission scrolling .
define browse br-comm query br-comm no-lock
display
  tt-commission.comp column-label "Состав комиссии" format "X(22)"
  tt-commission.FIO  column-label "ФИО" format "X(256)" width 30
  tt-commission.position_ column-label "Должность" format "X(256)" width 25
with size 80.25 by 6 separators.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1.5 COL 2
     b-chg AT ROW 1.5 COL 26 WIDGET-ID 2
     br-comm AT ROW 2.7 COL 2 WIDGET-ID 2
     SPACE(2) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Состав комиссии"
         DEFAULT-BUTTON B-exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  define variable v-FIO as character no-undo .
  define variable v-position as character no-undo .
  if available tt-commission
  then do :
    assign
      v-FIO = tt-commission.FIO
      v-position = tt-commission.position_
    .
    run str/test-asi-commission-chg.w (input-output v-FIO,
                                       input-output v-position)
                                       .
    assign
      tt-commission.FIO = v-FIO
      tt-commission.position_ = v-position
    .
  end .
  OPEN QUERY br-comm FOR EACH tt-commission .
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  for each tt-commission :
    if trim(tt-commission.FIO) > ""
    or trim(tt-commission.position_) > ""
    then do :
      find first buf_rvs-doc-attr exclusive-lock where buf_rvs-doc-attr.rvs-code = p-rvs-code
                                                   and buf_rvs-doc-attr.attr-code = ("test-asi-commission-" + string(tt-commission.ii))
                                                   no-error .
      if not available buf_rvs-doc-attr
      then do :
        create buf_rvs-doc-attr .
        assign
          buf_rvs-doc-attr.rvs-code = p-rvs-code
          buf_rvs-doc-attr.attr-code = ("test-asi-commission-" + string(tt-commission.ii))
        .
      end .
      assign buf_rvs-doc-attr.attr-value = tt-commission.FIO + chr(4) + tt-commission.position_ .
    end .
  end .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  do ii = 1 to 5 :
    create tt-commission .
    assign
      tt-commission.ii = ii
      tt-commission.comp = (if ii = 1 then "Председатель комиссии" else "Участник комиссии")
    .
    find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = p-rvs-code
                                          and buf_rvs-doc-attr.attr-code = ("test-asi-commission-" + string(ii))
                                          no-error .
    if available buf_rvs-doc-attr
    and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
    then do :
      assign
        tt-commission.FIO = entry(1, buf_rvs-doc-attr.attr-value, chr(4))
        tt-commission.position_ = entry(2, buf_rvs-doc-attr.attr-value, chr(4))
      .
    end .
  end .
  RUN enable_UI.
  if p-mode = 'ПРОСМОТР':U
  then do :
    disable b-chg with FRAME Dialog-Frame.
  end .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE B-exit b-chg br-comm
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-comm FOR EACH tt-commission .
END PROCEDURE.
