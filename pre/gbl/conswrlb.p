block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: conswrlb.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/conswrlb.p $":U .
define variable vss-description as character no-undo initial "Библиотека  процедур".
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
define new global shared variable g#conswrlb as handle no-undo .
if valid-handle (g#conswrlb)
and g#conswrlb <> this-procedure :handle
and g#conswrlb :get-signature('conswrlb_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#conswrlb skip
    g#conswrlb :type skip
    g#conswrlb :file-name skip
    valid-handle(g#conswrlb) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#conswrlb = this-procedure :handle
  .
end.
if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.
on delete of this-procedure
do:
  assign
    g#conswrlb = ?
  .
end.
procedure conswrlb_testproc :
end.
procedure conswr :
  define input  parameter p-console-message as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-window-handle        as integer   no-undo .
    define variable v-menu-handle          as integer   no-undo .
    define variable v-result               as integer   no-undo .
    define variable v-stdout               as integer   no-undo .
    define variable v-write-string         as character no-undo .
    define variable v-write-string-length  as integer   no-undo .
    define variable v-memptr-write-string  as memptr    no-undo .
    do
    on error undo, return error return-value
    :
      run GetConsoleWindow
        (output v-window-handle
        ) .
      if v-window-handle = 0
      then do:
        run AllocConsole
          (output v-result
          ) .
        run GetConsoleWindow
          (output v-window-handle
          ) .
        run GetSystemMenu
          (input  v-window-handle
          ,input  0
          ,output v-menu-handle
          ) .
        run DeleteMenu
          (input  v-menu-handle
          ,input  61536
          ,input  0
          ,output v-result
          ) .
      end.
      run GetStdHandle in this-procedure
        (input  -11
        ,output v-stdout
        ) .
      assign
        v-write-string                  = p-console-message
        v-write-string-length           = length(v-write-string)
        set-size(v-memptr-write-string) = (v-write-string-length + 1) * 3 + 4
        put-string(v-memptr-write-string, 5) = v-write-string
      .
      run MultiByteToWideChar
        (input  1251
        ,input  0
        ,input  get-pointer-value(v-memptr-write-string) + 4
        ,input  v-write-string-length
        ,input  get-pointer-value(v-memptr-write-string) + 4 + (v-write-string-length + 1)
        ,input  (v-write-string-length + 1) * 2
        ,output v-result
        ) .
      if v-result = v-write-string-length
      then do:
        run WriteConsoleW
          (input  v-stdout
          ,input  get-pointer-value(v-memptr-write-string) + 4 + (v-write-string-length + 1)
          ,input  v-write-string-length
          ,input  get-pointer-value(v-memptr-write-string)
          ,input  0
          ,output v-result
          ) .
      end.
      assign
        set-size(v-memptr-write-string) = 0
      .
    end.
  end.
end procedure.
PROCEDURE AllocConsole EXTERNAL "kernel32.dll"
:
   DEFINE RETURN PARAMETER RetParam  AS LONG .
END PROCEDURE .
PROCEDURE GetConsoleWindow EXTERNAL "kernel32.dll"
:
   DEFINE RETURN PARAMETER RetParam  AS LONG .
END PROCEDURE .
PROCEDURE GetStdHandle EXTERNAL "kernel32.dll"
:
   DEFINE INPUT  PARAMETER nStdHandle AS LONG .
   DEFINE RETURN PARAMETER RetParam   AS LONG .
END PROCEDURE .
PROCEDURE WriteConsoleW EXTERNAL "kernel32.dll"
:
   DEFINE INPUT  PARAMETER hConsoleOutput         AS LONG .
   DEFINE INPUT  PARAMETER lpBuffer               AS LONG .
   DEFINE INPUT  PARAMETER nNumberOfCharsToWrite  AS LONG .
   DEFINE INPUT  PARAMETER lpNumberOfCharsWritten AS LONG .
   DEFINE INPUT  PARAMETER lpReserved             AS LONG .
   DEFINE RETURN PARAMETER RetParam               AS LONG .
END PROCEDURE .
PROCEDURE MultiByteToWideChar EXTERNAL "kernel32.dll"
:
  define input  parameter uCodePage      as long.
  define input  parameter dwFlags        as long.
  define input  parameter lpMultiByteStr as long.
  define input  parameter cbMubtiByte    as long.
  define input  parameter lpWideCharStr  as long.
  define input  parameter cbMultiByte    as long.
  define return parameter iRetCode       as long.
END.
PROCEDURE GetSystemMenu EXTERNAL "user32.dll"
:
  define input  parameter hWnd      as long.
  define input  parameter bRevert   as long.
  define return parameter hMenu     as long.
END.
PROCEDURE EnableMenuItem EXTERNAL "user32.dll"
:
  define input  parameter hMenu         as long.
  define input  parameter uIDEnableItem as long.
  define input  parameter uEnable       as long.
  define return parameter iRetCode      as long.
END.
PROCEDURE DeleteMenu EXTERNAL "user32.dll"
:
  define input  parameter hMenu         as long.
  define input  parameter uIDEnableItem as long.
  define input  parameter uEnable       as long.
  define return parameter iRetCode      as long.
END.
