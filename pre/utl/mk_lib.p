block-level on error undo, throw.
define input parameter p-rc-dic-name  as character no-undo .
define input parameter p-pl-file-name as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mk_lib.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mk_lib.p $":U .
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
define variable v-startup-filename as character no-undo .
define variable v-command-filename as character no-undo .
do
on error undo, return error return-value
:
  define stream slog .
  run gbl/_tmpfile.p
    (input  "f":u
    ,input  ".pf":u
    ,output v-startup-filename
    ) .
  run gbl/_tmpfile.p
    (input  'f':u
    ,input  '.bat':u
    ,output v-command-filename
    ).
  output stream slog to value(v-startup-filename) no-echo .
  put stream slog unformatted
    '-cpcase '     session :cpcase     skip
    '-cpcoll '     session :cpcoll     skip
    '-cpinternal ' session :cpinternal skip
    '-cpstream '   session :cpstream   skip
    .
  output stream slog close.
  define variable v-dlc-dir-name as character no-undo .
  get-key-value section "startup" key "dlc" value v-dlc-dir-name .
  output stream slog to value( v-command-filename ) no-echo.
  put stream slog unformatted
    '@ echo off':u skip
    'set dlc=':u v-dlc-dir-name skip
    substring(p-rc-dic-name, 1, 2) skip
    'cd ':u + p-rc-dic-name skip
    .
  put stream slog unformatted
    v-dlc-dir-name + '\bin\prolib ':u + p-pl-file-name + ' -cre -add *.* -pf ' + v-startup-filename skip
    .
  output stream slog close.
  if search(p-pl-file-name) <> ? then do:
    os-rename value(p-pl-file-name) value(p-pl-file-name + '.old').
    os-delete value(p-pl-file-name) .
  end.
  os-command silent value(v-command-filename) .
  os-delete value(v-command-filename) .
  os-delete value(v-startup-filename) .
end.
