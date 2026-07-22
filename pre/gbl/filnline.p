block-level on error undo, throw.
define input  parameter p-file-name    as character no-undo .
define output parameter p-end-new-line as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: filnline.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/filnline.p $":U .
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
define stream sinp .
do
on error undo, return error return-value
:
  assign
    p-end-new-line = false
  .
  define variable v-full-path-name as character no-undo .
  assign
    v-full-path-name = search(p-file-name)
  .
  if v-full-path-name = ?
  or v-full-path-name = ""
  then do:
    return "Файл не найден" .
  end.
  input stream sinp from value(v-full-path-name) no-echo no-map .
  seek stream sinp to end.
  define variable v-file-position as integer   no-undo .
  assign
    v-file-position = seek(sinp)
  .
  if v-file-position = 0
  then do:
    return "Размер файла 0" .
  end.
  seek stream sinp to v-file-position - 1 .
  readkey stream sinp pause 0.
  define variable v-last-key as integer   no-undo .
  assign
    v-last-key = lastkey
  .
  if v-last-key = 13
  then do:
    assign
      p-end-new-line = true
    .
    return .
  end.
  else do:
    return "Последний символ отличен от конца строки" .
  end.
end.
