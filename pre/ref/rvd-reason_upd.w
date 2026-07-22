DEFINE TEMP-TABLE tt_ext-classif
  field Key#_Two    as integer
  field CharKey_One as character
  field CharKey_Two as character
  field CharKey_Three as character
  index pi CharKey_One
  .
define input        parameter parparentproc as widget-handle no-undo .
define input        parameter ref-mode      as character     no-undo .
define input-output parameter rid           as recid         no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма редактирования основания документа".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf2_ext-classif for ub.ext-classif .
define buffer buf_ext-classif1 for ub.ext-classif .
DEFINE BUTTON b-cancel AUTO-END-KEY
  LABEL "&Отмена"
  SIZE 10 BY 1.
DEFINE BUTTON b-OK AUTO-GO
  LABEL "&Ввод "
  SIZE 10 BY 1.
DEFINE FRAME d-rvd-reason
  b-OK AT ROW 1 COL 1
  b-cancel AT ROW 1 COL 11
  tt_ext-classif.CharKey_One AT ROW 3 COL 4 format "X(64)"
    LABEL "Код"
    VIEW-AS FILL-IN
    SIZE 10 BY 1
  tt_ext-classif.Key#_Two AT ROW 3 COL 21
    LABEL "Тип"
    view-as combo-box inner-lines 2
    list-item-pairs "РГС",0,"ТРК",1
    DROP-DOWN-LIST
    size 7 by 1
  tt_ext-classif.CharKey_Two AT ROW 4.1 COL 4 format "X(255)"
    LABEL "Основание/причина"
    VIEW-AS fill-in
    SIZE 50 BY 1
  tt_ext-classif.CharKey_Three AT ROW 5.1 COL 4 format "X(255)"
    LABEL "Описание"
    VIEW-AS fill-in
    SIZE 59 BY 1
  SPACE(1) SKIP(1)
  WITH VIEW-AS DIALOG-BOX
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Основание".
ASSIGN
  FRAME d-rvd-reason:SCROLLABLE = FALSE.
ON CHOOSE OF b-OK IN FRAME d-rvd-reason
DO:
  assign
    tt_ext-classif.Key#_Two
    tt_ext-classif.CharKey_One
    tt_ext-classif.CharKey_Two
    tt_ext-classif.CharKey_Three
  .
  if ref-mode = 'ДОБАВЛЕНИЕ':U
  then do :
    find first buf_ext-classif1 no-lock where buf_ext-classif1.CharKey_One = tt_ext-classif.CharKey_One
                                    and buf_ext-classif1.classif-subject = 'rvd-reason':U
                                    and buf_ext-classif1.classif-name = 'rvd-reason':U
                                    no-error .
    if available buf_ext-classif1 then
    do:
      message substitute( "Причина изменения режима ввода данных с кодом &1 уже существует!", tt_ext-classif.CharKey_One )
      view-as alert-box .
      return no-apply .
    end.
    create buf_ext-classif .
    assign
      buf_ext-classif.Key#_One        = 0
      buf_ext-classif.classif-subject = 'rvd-reason':U
      buf_ext-classif.classif-name    = 'rvd-reason':U
      buf_ext-classif.db-num          = 0
      buf_ext-classif.key#_three      = 0
      buf_ext-classif.nonunique       = 0
    .
  end .
  else do :
    find first buf_ext-classif1 no-lock where buf_ext-classif1.CharKey_One = tt_ext-classif.CharKey_One
                                    and buf_ext-classif1.classif-subject = 'rvd-reason':U
                                    and buf_ext-classif1.classif-name = 'rvd-reason':U
                                    and recid( buf_ext-classif1 ) <> rid
                                    no-error .
    if available buf_ext-classif1 then
    do:
      message substitute( "Причина изменения режима ввода данных с кодом &1 уже существует!", tt_ext-classif.CharKey_One )
      view-as alert-box .
      return no-apply .
    end.
    find first buf2_ext-classif exclusive-lock where recid( buf2_ext-classif ) = rid .
    create buf_ext-classif .
    buffer-copy buf2_ext-classif to buf_ext-classif
    assign buf_ext-classif.charkey_one = "-1" .
    delete buf2_ext-classif .
  end .
  assign
    buf_ext-classif.Key#_Two    = tt_ext-classif.Key#_Two
    buf_ext-classif.charkey_one = tt_ext-classif.CharKey_One
    buf_ext-classif.charkey_two = tt_ext-classif.CharKey_Two
    buf_ext-classif.charkey_three = tt_ext-classif.CharKey_Three
    buf_ext-classif.uniq-key-rec = 'rvd-reason':U + chr(3)
                                 + buf_ext-classif.charkey_one
  .
  rid = recid( buf_ext-classif ) .
  release buf_ext-classif .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-rvd-reason:PARENT eq ?
  THEN FRAME d-rvd-reason:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-rvd-reason
  APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY  UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON STOP     UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  empty temp-table tt_ext-classif .
  define variable v-code as integer no-undo .
  define variable v-max-code as integer no-undo .
  create tt_ext-classif.
  if ref-mode = 'ДОБАВЛЕНИЕ':U then
  do:
    assign
      rid = ?
    .
    v-max-code = 0 .
    for each buf_ext-classif no-lock where buf_ext-classif.classif-subject = 'rvd-reason':U
                                       and buf_ext-classif.classif-name = 'rvd-reason':U
                                       :
      v-code = integer(buf_ext-classif.CharKey_One) no-error .
      if not error-status:error
      then do :
        v-max-code = max(v-max-code, v-code) .
      end .
    end .
    v-max-code = v-max-code + 1 .
    assign
      tt_ext-classif.CharKey_One = string(v-max-code) .
    .
  end.
  else
  do:
    find first buf2_ext-classif exclusive-lock
      where recid( buf2_ext-classif ) = rid
      .
    assign
      tt_ext-classif.Key#_Two    = buf2_ext-classif.Key#_Two
      tt_ext-classif.CharKey_One = buf2_ext-classif.CharKey_One
      tt_ext-classif.CharKey_Two = buf2_ext-classif.CharKey_Two
      tt_ext-classif.CharKey_Three = buf2_ext-classif.CharKey_Three
    .
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME d-rvd-reason .
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-rvd-reason.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY
    tt_ext-classif.Key#_Two
    tt_ext-classif.CharKey_One
    tt_ext-classif.CharKey_Two
    tt_ext-classif.CharKey_Three
  WITH FRAME d-rvd-reason.
  ENABLE
    b-OK
    b-cancel
    tt_ext-classif.Key#_Two
    tt_ext-classif.CharKey_One
    tt_ext-classif.CharKey_Two
    tt_ext-classif.CharKey_Three
  WITH FRAME d-rvd-reason.
END PROCEDURE.
