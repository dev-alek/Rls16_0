define input parameter fname-out       as character no-undo .
define input parameter fname-in        as character no-undo .
define input parameter mess            as character no-undo .
define input parameter btn-mess-start  as character no-undo .
define input parameter btn-mess-end    as character no-undo .
define input parameter mess-continue-waiting as character no-undo .
define input parameter p-waiting       as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог ожидания удаления файла".
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
      p-vss-parameters = substitute('&1|&2':u,fname-out,p-waiting)
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
define variable v-continue-waiting as logical no-undo .
define variable v-can-access as logical no-undo .
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
    if v-continue-waiting then do:
        assign
          Editor-1 :screen-value = mess-continue-waiting
        .
    end.
    if v-exec-time >= p-waiting
    and not v-continue-waiting
    then do:
      if fname-out <> "" then do:
        assign
          Editor-1 :screen-value = btn-mess-end
        .
        display btn_cancel with frame DIALOG-1.
        enable btn_cancel with frame DIALOG-1.
      end.
      else do:
        return .
      end.
    end.
    if fname-out <> "" then do:
      if search(fname-out) = ?
      then do:
        return .
      end.
      else do:
        if search(fname-in) <> ? then do:
            assign
            v-continue-waiting = yes
            .
        end.
      end.
    end.
    WAIT-FOR GO OF FRAME DIALOG-1 FOCUS Btn_cancel PAUSE 1 .
  end.
END.
if true then do:
  return error .
end.
RUN disable_UI.
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
