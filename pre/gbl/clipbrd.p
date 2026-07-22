block-level on error undo, throw.
define input  parameter p-text as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clipbrd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/clipbrd.p $":U .
define variable vss-description as character no-undo init "Записать строку в буфер обмена (clipboard)".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW GLOBAL SHARED VARIABLE hpWinFunc AS HANDLE NO-UNDO.
  IF NOT VALID-HANDLE(hpWinFunc) THEN run gbl/winfunc.p PERSISTENT SET hpWinFunc.
FUNCTION GetLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION GetParent
         RETURNS INTEGER
         (input hwnd as INTEGER)
         IN hpWinFunc.
FUNCTION ShowLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION CreateProcess
         RETURNS INTEGER
         (input CommandLine as CHAR,
          input CurrentDir  as CHAR,
          input wShowWindow as INTEGER)
         in hpWinFunc.
define variable v-return-value as integer   no-undo .
do
on error undo, return error return-value
:
  run OpenClipboard
    (input  0
    ,output v-return-value
    ) .
  if v-return-value = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове функции OpenClipboard" skip
      ShowLastError() skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run EmptyClipboard
    (output v-return-value
    ) .
  define variable hMem-unicode          as integer   no-undo .
  define variable hMem-ansi             as integer   no-undo .
  define variable hGlobal-unicode       as integer   no-undo .
  define variable hGlobal-ansi          as integer   no-undo .
  define variable v-buffer-size-unicode as integer   no-undo .
  define variable v-buffer-size-ansi    as integer   no-undo .
  assign
    v-buffer-size-unicode = (length(p-text) + 1) * 2
    v-buffer-size-ansi    = length(p-text) + 1
  .
  run GlobalAlloc
    (input  2
    ,input  v-buffer-size-unicode
    ,output hMem-unicode
    ) .
  if hMem-unicode = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове функции GlobalAlloc" skip
      ShowLastError() skip
      view-as alert-box error .
    run CloseClipboard
      (output v-return-value
      ) .
    undo, return error return-value .
  end.
  run GlobalAlloc
    (input  2
    ,input  v-buffer-size-ansi
    ,output hMem-ANSI
    ) .
  if hMem-ANSI = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове функции GlobalAlloc" skip
      ShowLastError() skip
      view-as alert-box error .
    run CloseClipboard
      (output v-return-value
      ) .
    run GlobalFree
      (input  hMem-unicode
      ,output v-return-value
      ) .
    undo, return error return-value .
  end.
  run GlobalLock
    (input  hMem-unicode
    ,output hGlobal-unicode
    ) .
  run GlobalLock
    (input  hMem-ansi
    ,output hGlobal-ansi
    ) .
  define variable v-data as memptr no-undo .
  define variable v-data-ansi as memptr no-undo .
  assign
    set-size(v-data) = length(p-text) + 1
    set-pointer-value(v-data-ansi) = hGlobal-ansi
  .
  assign
    put-string(v-data, 1) = p-text
    put-string(v-data-ansi, 1) = p-text
  .
  run MultiByteToWideChar
    (input  0
    ,input  0
    ,input  get-pointer-value(v-data)
    ,input  -1
    ,input  hGlobal-unicode
    ,input  v-buffer-size-unicode
    ,output v-return-value
    ) .
  if v-return-value = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры MultiByteToWideChar" skip
      view-as alert-box error .
  end.
  assign
    set-size(v-data) = 0
  .
  run GlobalUnlock
    (input  hMem-unicode
    ,output v-return-value
    ) .
  run GlobalUnlock
    (input  hMem-ansi
    ,output v-return-value
    ) .
  run SetClipboardData
    (input  1
    ,input  hMem-ansi
    ,output v-return-value
    ) .
  if v-return-value = 0
  then do:
    run CloseClipboard
      (output v-return-value
      ) .
    run GlobalFree
      (input  hMem-unicode
      ,output v-return-value
      ) .
    run GlobalFree
      (input  hMem-ansi
      ,output v-return-value
      ) .
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове функции SetClipboardData" skip
      ShowLastError() skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run SetClipboardData
    (input  13
    ,input  hMem-unicode
    ,output v-return-value
    ) .
  if v-return-value = 0
  then do:
    run CloseClipboard
      (output v-return-value
      ) .
    run GlobalFree
      (input  hMem-unicode
      ,output v-return-value
      ) .
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове функции SetClipboardData" skip
      ShowLastError() skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run CloseClipboard
    (output v-return-value
    ) .
end.
PROCEDURE MultiByteToWideChar EXTERNAL "kernel32.dll" :
  define input  parameter uCodePage      as long .
  define input  parameter dwFlags        as long .
  define input  parameter lpMultiByteStr as long .
  define input  parameter cbMubtiByte    as long .
  define input  parameter lpWideCharStr  as long .
  define input  parameter cbMultiByte    as long .
  define return parameter iRetCode       as long .
END.
PROCEDURE GlobalAlloc EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER uFlags     AS LONG .
  DEFINE INPUT  PARAMETER dwBytes    AS LONG .
  DEFINE RETURN PARAMETER hMem       AS LONG .
END PROCEDURE.
PROCEDURE GlobalFree EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hMem   AS LONG .
  DEFINE RETURN PARAMETER Result AS LONG .
END PROCEDURE.
PROCEDURE GlobalLock EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hMem       AS LONG .
  DEFINE RETURN PARAMETER hGlobal    AS LONG .
END PROCEDURE.
PROCEDURE GlobalUnlock EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hGlobal     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
PROCEDURE OpenClipboard EXTERNAL "user32.dll" :
  DEFINE INPUT  PARAMETER hWnd        AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
PROCEDURE SetClipboardData EXTERNAL "user32.dll" :
  DEFINE INPUT  PARAMETER uFormat     AS LONG .
  DEFINE INPUT  PARAMETER hMem        AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
PROCEDURE EmptyClipboard EXTERNAL "user32.dll" :
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
PROCEDURE CloseClipboard EXTERNAL "user32.dll" :
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
