block-level on error undo, throw.
define input parameter p-dir-name as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dir-canw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/dir-canw.p $":U .
define variable vss-description as character no-undo init "ѕроверка возможности записи в директорию грубым способом".
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
define variable v-test-file as character no-undo .
define stream outstream.
file-info:file-name = p-dir-name.
if file-info:full-pathname = ?
or file-info:full-pathname = '' then do:
  return error substitute("Ќе найдена директори€ &1", p-dir-name).
end.
if index( file-info:file-type, "D":U ) = 0  then do:
  return error substitute("&1 - это не директори€ &1", p-dir-name).
end.
run gbl/_tmpfile.p ( input "":U
                   , input ".txt":U
                   , output v-test-file   ) .
output stream outstream to value(v-test-file) .
put
stream outstream
unformatted "test" skip.
output stream outstream close.
file-info:file-name = v-test-file.
if file-info:full-pathname = ?
or file-info:full-pathname = '' then do:
  return error substitute("Ќет возможности записи в директорию &1", p-dir-name).
end.
os-delete value(v-test-file) .
