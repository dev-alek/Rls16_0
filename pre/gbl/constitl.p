block-level on error undo, throw.
define input  parameter p-title           as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: constitl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/constitl.p $":U .
define variable vss-description as character no-undo init "Запись информации в консоль".
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
define variable v-window-handle        as integer   no-undo .
define variable v-result               as integer   no-undo .
define variable v-stdout               as integer   no-undo .
define variable v-title                as character no-undo .
define variable v-title-length         as integer   no-undo .
define variable v-memptr-console-title as memptr    no-undo .
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
  end.
  assign
    v-title        = p-title
    v-title-length = length(v-title)
  .
  assign
    set-size(v-memptr-console-title) = (v-title-length + 1) * 3
  .
  assign
    put-string(v-memptr-console-title, 1) = v-title
  .
  run MultiByteToWideChar
    (input  1251
    ,input  0
    ,input  get-pointer-value(v-memptr-console-title)
    ,input  v-title-length
    ,input  get-pointer-value(v-memptr-console-title) + (v-title-length + 1)
    ,input  (v-title-length + 1) * 2
    ,output v-result
    ) .
  run SetConsoleTitleW
    (input  get-pointer-value(v-memptr-console-title) + (v-title-length + 1)
    ,output v-result
    ) .
  assign
    set-size(v-memptr-console-title) = 0
  .
end.
PROCEDURE AllocConsole EXTERNAL "kernel32.dll"
:
   DEFINE RETURN PARAMETER RetParam  AS LONG .
END PROCEDURE .
PROCEDURE GetConsoleWindow EXTERNAL "kernel32.dll"
:
   DEFINE RETURN PARAMETER RetParam  AS LONG .
END PROCEDURE .
PROCEDURE SetConsoleTitleW EXTERNAL "kernel32.dll"
:
   DEFINE INPUT  PARAMETER lpConsoleTitle AS LONG .
   DEFINE RETURN PARAMETER RetParam       AS LONG .
END PROCEDURE .
PROCEDURE MultiByteToWideChar EXTERNAL "KERNEL32.dll"
:
  define input  parameter uCodePage      as long.
  define input  parameter dwFlags        as long.
  define input  parameter lpMultiByteStr as long.
  define input  parameter cbMubtiByte    as long.
  define input  parameter lpWideCharStr  as long.
  define input  parameter cbMultiByte    as long.
  define return parameter iRetCode       as long.
END.
