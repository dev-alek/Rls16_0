define input parameter fname           as character no-undo .
define input parameter mess            as character no-undo .
define input parameter btn-mess-start  as character no-undo .
define input parameter btn-mess-end    as character no-undo .
define input parameter p-waiting       as integer   no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Диалог ожидания удаления или появления файла".
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
    assign
      p-vss-parameters = substitute('&1|&2':u,fname,p-waiting)
    .
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
define stream dirstream .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE proc-read-dir :
DEFINE INPUT PARAMETER p-dir-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-fn-add-mask AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-elapsed-time AS INTEGER NO-UNDO.
DEFINE output PARAMETER p-appear AS logical NO-UNDO.
define variable v-start-time as int64   no-undo.
define variable file as character no-undo.
define variable path as character no-undo.
define variable atr  as character no-undo.
define variable v-ext-split as integer   no-undo .
define variable v-ext-split-mask as integer   no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext as character no-undo .
define variable v-mask-no-ext as character no-undo .
define variable v-mask-ext as character no-undo .
assign
v-start-time = etime.
input stream DirStream from os-dir (p-dir-name) .
REPEAT :
  import stream DirStream file path atr.
  if can-do( "f", atr )    then do:
    if file matches p-fn-add-mask then do:
      p-appear = yes.
      leave.
    end.
    assign
    v-ext-split = r-index(file, '.':u)
    v-ext-split-mask = r-index(p-fn-add-mask, '.':u)
    .
    if v-ext-split > 0 then do:
      assign
        v-file-name-no-ext = substring(file, 1, v-ext-split - 1)
        v-file-name-ext    = substring(file, v-ext-split + 1)
      .
    end.
    else do:
      assign
        v-file-name-no-ext = file
        v-file-name-ext    = ""
      .
    end.
    if v-ext-split-mask > 0 then do:
      assign
        v-mask-no-ext = substring(p-fn-add-mask, 1, v-ext-split-mask - 1)
        v-mask-ext    = substring(p-fn-add-mask, v-ext-split-mask + 1)
      .
    end.
    else do:
      assign
        v-mask-no-ext = p-fn-add-mask
        v-mask-ext    = ""
      .
    end.
    if v-file-name-no-ext matches v-mask-no-ext
    and v-file-name-ext matches v-mask-ext
    then do:
      p-appear = yes.
      leave.
    end.
  end.
END.
assign
p-elapsed-time = etime - v-start-time.
END PROCEDURE.
define variable v-file-name-del as character no-undo .
define variable v-dir-name as character no-undo .
define variable v-fn-add-mask as character no-undo .
define variable v-elapsed-time as integer no-undo .
define variable v-start-dir-watch-time as int64 no-undo .
define variable v-appear as logical no-undo .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "Прервать ожидание"
     SIZE 30 BY 1.5
     BGCOLOR 8 .
DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR
     SIZE 39 BY 4.67
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE FI-ExecTime AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 39 BY 1 NO-UNDO.
DEFINE FRAME DIALOG-1
     EDITOR-1 AT ROW 1.13 COL 2.13 NO-LABEL
     FI-ExecTime AT ROW 6.13 COL 2.13 NO-LABEL
     Btn_Cancel AT ROW 7.79 COL 6.63
     SPACE(5.61) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8
         TITLE BGCOLOR 8 ""
         CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.
ASSIGN
       Btn_Cancel:HIDDEN IN FRAME DIALOG-1           = TRUE.
ASSIGN
       EDITOR-1:READ-ONLY IN FRAME DIALOG-1        = TRUE.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DIALOG-1:PARENT eq ?
THEN FRAME DIALOG-1:PARENT = ACTIVE-WINDOW.
define variable v-exec-time as integer no-undo .
on window-close OF FRAME DIALOG-1 do:
  apply "end-error" to frame DIALOG-1.
end.
on "end-error":U of frame DIALOG-1 do:
  if v-exec-time < p-waiting then do:
    return no-apply .
  end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
    frame DIALOG-1 :title = mess
  .
  assign
  v-file-name-del = entry(1, fname, chr(4))
  v-dir-name      = (if num-entries(fname, chr(4)) = 3
                     and v-file-name-del = "":U
                     then entry(2, fname, chr(4))
                     else "":U)
  v-fn-add-mask = (if num-entries(fname, chr(4)) = 3
                   and v-file-name-del = "":U
                   then entry(3, fname, chr(4))
                   else "":U)
  v-fn-add-mask = (if v-dir-name <> "":U and v-fn-add-mask = "":U
                   then "*.*"
                   else v-fn-add-mask)
  .
  RUN MyEnable .
  define variable v-start-time as int64   no-undo .
  assign
    v-start-time = etime
  .
  do while true
  :
    assign
      v-exec-time = (etime - v-start-time) / 1000
    .
    assign
      fi-exectime :screen-value = substitute("Время ожидания &1", string(v-exec-time, "HH:MM:SS"))
    .
    if v-exec-time >= p-waiting then do:
      if v-file-name-del  <> ""
      or v-dir-name <> "":u
      then do:
        assign
          Editor-1 :screen-value = btn-mess-end
        .
        display btn_cancel with frame DIALOG-1.
        enable btn_cancel with frame DIALOG-1.
      end.
      if v-file-name-del  = "" then do:
        return .
      end.
    end.
    if v-file-name-del <> "" then do:
      if search(v-file-name-del) = ?
      then do:
        return .
      end.
    end.
    if v-dir-name <> "":U
    and v-exec-time > minimum(p-waiting / 4, 15)
    and (v-start-dir-watch-time = 0
         or
         (etime  - v-start-dir-watch-time) > v-elapsed-time * 10
        )
    then do:
      assign
      v-start-dir-watch-time = etime.
      run proc-read-dir in this-procedure (
                                           input v-dir-name
                                          ,input v-fn-add-mask
                                          ,output v-elapsed-time
                                          ,output v-appear
                                          ) no-error .
      if error-status:error then do:
      end.
      if v-appear then return.
    end.
    WAIT-FOR GO OF FRAME DIALOG-1 FOCUS Btn_cancel PAUSE 1 .
  end.
END.
RUN disable_UI.
return error .
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY EDITOR-1 FI-ExecTime
      WITH FRAME DIALOG-1.
  ENABLE EDITOR-1 FI-ExecTime
      WITH FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE MyEnable :
 Enable Editor-1
 With Frame DIALOG-1.
 DISPLAY
 Editor-1
 FI-ExecTime
 With Frame DIALOG-1.
 Editor-1:screen-value = btn-mess-start.
END PROCEDURE.
