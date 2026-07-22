block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: windinfo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/windinfo.p $":U .
define variable vss-description as character no-undo init "".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define temp-table temp-window no-undo
   field window-handle       as integer   label "Handle"
   field window-visible      as logical   label "Visible"
   field window-text         as character label "Text"     format "x(20)"
   field window-class-atom   as integer   label "Class Atom"
   field window-class-name   as character label "Class Name"
   field window-message      as logical
   field window-message-text as character label "Message"  format "x(60)"
   field window-process-id   as integer   label "Process"
   field window-thread-id    as integer   label "Thread"
.
define output parameter table for temp-window .
define variable v-return-value as integer no-undo .
define variable lpProcessId as memptr    no-undo .
define variable lpString    as memptr    no-undo .
define variable hWnd        as integer   no-undo .
assign
  set-size(lpProcessId) = 4
  set-size(lpstring) = 10000
.
define variable v-desktop-window as integer   no-undo .
run GetDesktopWindow
  (output v-desktop-window
  ) .
define variable v-current-window as integer   no-undo .
define variable v-next-window    as integer   no-undo .
run GetTopWindow
  (input  v-desktop-window
  ,output v-current-window
  ) .
do while v-current-window <> 0
:
  assign
    hWnd = v-current-window
  .
  create temp-window .
  assign
    temp-window.window-handle = hwnd
  .
  run IsWindowVisible
    (input  hwnd
    ,output v-return-value
    ).
  if v-return-value <> 0
  then do:
    assign
      temp-window.window-visible = true
    .
  end.
  else do:
    assign
      temp-window.window-visible = false
    .
  end.
  define variable v-thread-id as integer   no-undo .
  run GetWindowThreadProcessId
    (input hwnd
    ,input  get-pointer-value(lpProcessId)
    ,output v-thread-id
    ).
  assign
    temp-window.window-process-id = get-long(lpProcessId, 1)
    temp-window.window-thread-id  = v-thread-id
  .
  run GetWindowTextA
    (input  hwnd
    ,input  get-pointer-value(lpString)
    ,input  get-size(lpString)
    ,output v-return-value
    ).
  if v-return-value <> 0
  then do:
    assign
      temp-window.window-text = get-string(lpString, 1)
    .
  end.
  run GetClassLongA
    (input hwnd
    ,input -32
    ,output v-return-value
    ) .
  if v-return-value <> 0
  then do:
    assign
      temp-window.window-class-atom = v-return-value
    .
  end.
  if temp-window.window-class-atom <> 0
  then do:
    run GlobalGetAtomNameA
      (input temp-window.window-class-atom
      ,input get-pointer-value(lpString)
      ,input get-size(lpString)
      ,output v-return-value
      ) .
    if v-return-value <> 0
    then do:
      assign
        temp-window.window-class-name = get-string(lpString, 1)
      .
    end.
  end.
  if temp-window.window-class-name = "#32770"
  then do:
    assign
      temp-window.window-message = true
    .
    run GetDlgItemTextA
      (input temp-window.window-handle
      ,input 65535
      ,input get-pointer-value(lpString)
      ,input get-size(lpString)
      ,output v-return-value
      ) .
    if v-return-value <> 0
    then do:
      assign
        temp-window.window-message-text = get-string(lpString, 1)
      .
    end.
  end.
  else do:
    assign
      temp-window.window-message = false
    .
  end.
  run GetWindow
    (input  v-current-window
    ,input  2
    ,output v-next-window
    ) .
  assign
    v-current-window = v-next-window
  .
end.
assign
  set-size(lpProcessId) = 0
  set-size(lpString) = 0
.
PROCEDURE IsWindowVisible EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd   AS LONG.
  DEFINE RETURN PARAMETER retval AS LONG.
END PROCEDURE.
PROCEDURE GetWindowTextA EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hWnd      AS LONG.
  DEFINE INPUT  PARAMETER lpString  AS LONG.
  DEFINE INPUT  PARAMETER nMaxCount AS LONG.
  DEFINE RETURN PARAMETER retval    AS LONG.
END PROCEDURE.
PROCEDURE GetClassLongA EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hWnd   AS LONG.
  DEFINE INPUT  PARAMETER nIndex AS LONG.
  DEFINE RETURN PARAMETER retval AS LONG.
END PROCEDURE.
PROCEDURE GlobalGetAtomNameA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER nAtom    AS LONG.
  DEFINE INPUT  PARAMETER lpBuffer AS LONG.
  DEFINE INPUT  PARAMETER nSize    AS LONG.
  DEFINE RETURN PARAMETER retval   AS LONG.
END PROCEDURE.
PROCEDURE GetDlgItemTextA EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hDlg       AS LONG.
  DEFINE INPUT  PARAMETER nIDDlgItem AS LONG.
  DEFINE INPUT  PARAMETER lpString   AS LONG.
  DEFINE INPUT  PARAMETER nMaxCount  AS LONG.
  DEFINE RETURN PARAMETER retval     AS LONG.
END PROCEDURE.
PROCEDURE  GetDesktopWindow EXTERNAL "user32" :
  DEFINE RETURN PARAMETER retval AS LONG.
END PROCEDURE.
PROCEDURE  GetTopWindow EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd   AS LONG.
  DEFINE RETURN PARAMETER retval AS LONG.
END PROCEDURE.
PROCEDURE  GetWindow EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd   AS LONG.
  DEFINE INPUT  PARAMETER wCmd   AS LONG.
  DEFINE RETURN PARAMETER retval AS LONG.
END PROCEDURE.
PROCEDURE GetWindowThreadProcessId EXTERNAL "user32" :
  DEFINE INPUT  PARAMETER hwnd          AS LONG.
  DEFINE INPUT  PARAMETER lpdwProcessId AS LONG.
  DEFINE RETURN PARAMETER retval        AS LONG.
END PROCEDURE.
