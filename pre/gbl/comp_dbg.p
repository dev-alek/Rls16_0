block-level on error undo, throw.
define input  parameter p-module-file-name  as character no-undo .
define input  parameter p-progress-curdir   as character no-undo .
define input  parameter p-progress-inifile  as character no-undo .
define input  parameter p-progress-propath  as character no-undo .
define input  parameter p-r-code-name       as character no-undo .
define input  parameter p-proc-line         as character no-undo .
define input  parameter p-db-connect-string as character no-undo .
define output parameter p-dbg-file          as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: comp_dbg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/comp_dbg.p $":U .
define variable vss-description as character no-undo init "Создать dbg файл для программы из другой сессии".
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
define stream sout .
define variable v-run-filename     as character no-undo .
define variable v-compile-filename as character no-undo .
define variable v-dbg-filename     as character no-undo .
do
on error undo, return error return-value
:
  run gbl/_tmpfile.p
    (input  "prw"
    ,input  ".dbg"
    ,output v-dbg-filename
    ).
  output stream sout to value(v-dbg-filename).
  put stream sout unformatted "ERROR GENERATING *.DBG FILE" skip .
  output stream sout close .
  assign
    file-info :file-name = v-dbg-filename
    v-dbg-filename = file-info :full-pathname
  .
  run gbl/_tmpfile.p
    (input  "prw"
    ,input  ".p"
    ,output v-compile-filename
    ).
  output stream sout to value(v-compile-filename).
  put stream sout unformatted substitute('assign propath = "&1" .':u, p-progress-propath) + chr(10) .
  put stream sout unformatted substitute('do on error undo, leave :':u, p-progress-propath) + chr(10) .
  if p-db-connect-string <> ""
  then do:
    put stream sout unformatted '  connect value("' + p-db-connect-string + '") .':u  + chr(10) .
    put stream sout unformatted '  create alias value("src") for database ub.':u  + chr(10) .
    put stream sout unformatted '  create alias value("dst") for database ub.':u  + chr(10) .
    put stream sout unformatted '  create alias value("db-orig") for database ub.':u  + chr(10) .
    put stream sout unformatted '  create alias value("db-copy") for database ub.':u  + chr(10) .
    put stream sout unformatted '  create alias value("ubflt") for database ub.':u  + chr(10) .
    put stream sout unformatted '  create alias value("ubfltsrc") for database ub.':u  + chr(10) .
    put stream sout unformatted '  create alias value("ubfltdst") for database ub.':u  + chr(10) .
    put stream sout unformatted '  create alias value("restseq") for database ub.':u  + chr(10) .
    put stream sout unformatted '  create alias value("restseqflt") for database ub.':u  + chr(10) .
  end.
  put stream sout unformatted substitute('  assign propath = "&1" .':u, p-progress-propath) + chr(10) .
  put stream sout unformatted substitute('  compile &1 debug-list &2 .':u, p-r-code-name, v-dbg-filename) + chr(10) .
  put stream sout unformatted substitute('end.':u, p-progress-propath) + chr(10) .
  put stream sout unformatted substitute('quit.':u, p-r-code-name, v-dbg-filename) + chr(10) .
  output stream sout close .
  assign
    file-info :file-name = v-compile-filename
    v-compile-filename = file-info :full-pathname
  .
  run gbl/_tmpfile.p
    (input  "prw"
    ,input  ".bat"
    ,output v-run-filename
    ).
  output stream sout to value(v-run-filename).
  put stream sout unformatted substitute('start /w "/d&4" "&1" -ininame "&2" -basekey "INI" -p "&3"':u, p-module-file-name, p-progress-inifile, v-compile-filename, p-progress-curdir) + chr(10) .
  put stream sout unformatted substitute('exit':u) + chr(10) .
  output stream sout close .
  assign
    file-info :file-name = v-run-filename
    v-run-filename = file-info :full-pathname
  .
  os-command value(v-run-filename) .
  os-delete value(v-compile-filename) .
  os-delete value(v-run-filename) .
  assign
    p-dbg-file = v-dbg-filename
  .
end.
