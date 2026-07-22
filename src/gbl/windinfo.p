block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: windinfo.p $
$Archive: gbl/windinfo.p $

Список окон системы

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 08/07/03

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: windinfo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/windinfo.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }


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

&GLOBAL-DEFINE GCW_ATOM -32
&GLOBAL-DEFINE GW_HWNDNEXT 2

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
    ,input {&GCW_ATOM}
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
    ,input  {&GW_HWNDNEXT}
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