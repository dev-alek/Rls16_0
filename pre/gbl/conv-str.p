block-level on error undo, throw.
define input  parameter p-from-encoding as integer   no-undo .
define input  parameter p-from-string   as character no-undo .
define input  parameter p-to-encoding   as integer   no-undo .
define output parameter p-to-string     as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: conv-str.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/conv-str.p $":U .
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
define variable lp-from-string as  memptr  no-undo .
define variable lp-out-string as  memptr  no-undo .
define variable lp-wide-char  as  memptr  no-undo .
PROCEDURE WideCharToMultiByte   EXTERNAL "KERNEL32.dll"
:
  define input  parameter uCodePage         as long.
  define input  parameter dwFlags           as long.
  define input  parameter lpWideCharStr     as long.
  define input  parameter cbWideChar        as long.
  define input  parameter lpMultiByteStr    as long.
  define input  parameter cbMultiByte       as long.
  define input  parameter lpDefaultChar     as long.
  define input  parameter lpUsedDefaultChar as long.
  define return parameter iRetCode          as long.
END.
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
do
on error undo, return error return-value
:
  define variable v-max-length as integer   no-undo .
  assign
    v-max-length = length(p-from-string) * 5
  .
  set-size(lp-out-string) = v-max-length.
  set-size(lp-from-string) = v-max-length.
  set-size(lp-wide-char)  = v-max-length.
  put-string(lp-from-string, 1) = p-from-string .
  define variable v-ret-code as integer   no-undo .
  run MultiByteToWideChar
    (input  p-from-encoding
    ,input  0
    ,input  get-pointer-value(lp-from-string)
    ,input  -1
    ,input  get-pointer-value(lp-wide-char)
    ,input  get-size(lp-wide-char)
    ,output v-ret-code
    ) .
  if v-ret-code = 0
  then do:
    set-size(lp-out-string)  = 0.
    set-size(lp-from-string) = 0.
    set-size(lp-wide-char)   = 0.
    undo, return error "Ошибка при вызове процедуры MultiByteToWideChar" .
  end.
  run WideCharToMultiByte
    (input p-to-encoding
    ,input 0
    ,input get-pointer-value(lp-wide-char)
    ,input -1
    ,input get-pointer-value(lp-out-string)
    ,input get-size(lp-out-string)
    ,input 0
    ,input 0
    ,output v-ret-code
    ).
  if v-ret-code = 0
  then do:
    set-size(lp-out-string)  = 0.
    set-size(lp-from-string) = 0.
    set-size(lp-wide-char)   = 0.
    undo, return error "Ошибка при вызове процедуры WideCharToMultiByte" .
  end.
  assign
    p-to-string = get-string(lp-out-string, 1)
  .
  set-size(lp-out-string)  = 0.
  set-size(lp-from-string) = 0.
  set-size(lp-wide-char)   = 0.
end.
