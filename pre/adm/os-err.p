block-level on error undo, throw.
define output parameter errText as character no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: os-err.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/os-err.p $":U .
define variable vss-description as character no-undo init "Преобразование кодов ошибок ОС в текст".
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
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  case OS-ERROR:
    when   0 then assign errText = "".
    when   1 then assign errText = "Not Owner".
    when   2 then assign errText = "No such file or directory".
    when   3 then assign errText = "Interrupted system call".
    when   4 then assign errText = "I/O error".
    when   5 then assign errText = "Bad file number".
    when   6 then assign errText = "No more processes".
    when   7 then assign errText = "Not enough core memory".
    when   8 then assign errText = "Permission denied".
    when   9 then assign errText = "Bad address".
    when  10 then assign errText = "File exists".
    when  11 then assign errText = "No such device".
    when  12 then assign errText = "Not a directory".
    when  13 then assign errText = "Is a directory".
    when  14 then assign errText = "File table overflow".
    when  15 then assign errText = "Too many open files".
    when  16 then assign errText = "File too large".
    when  17 then assign errText = "No space left on device".
    when  18 then assign errText = "Directory not empty".
    otherwise     assign errText = "Unmapped error (PROGRESS default)".
  end.
  assign
    errText = errText + " (":U + string( OS-ERROR ) + ")":U
  .
  return.
end.
