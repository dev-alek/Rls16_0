block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 579765cb4320, 2677, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Вт ноя 17 10:53:21 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-pers.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/del-pers.p $":U .
define variable vss-description as character no-undo init "Удаление всех persistent процедур".
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
define stream LogStream.
output stream LogStream to "memdump.log".
output stream LogStream close.
   DEFINE VARIABLE hProc AS HANDLE     NO-UNDO.
   DEFINE VARIABLE iCounter AS INTEGER    NO-UNDO.
   define variable v-procedure-handle as handle    no-undo .
  hProc = session:first-procedure .
  iCounter = 0 .
  if valid-handle(hProc) then do :
    OUTPUT stream LogStream TO "memdump.log" APPEND.
    do while valid-handle(hProc)
    on error undo, return error :
      iCounter = iCounter + 1.
      v-procedure-handle = hProc .
      hProc = hProc:next-sibling .
      put stream LogStream unformatted
            "Procedure No.:~t" iCounter "~t"
            "Procedure:~t" v-procedure-handle:file-name
      skip.
      apply 'delete':u to v-procedure-handle .
      delete procedure v-procedure-handle .
    end.
    output stream LogStream close.
  end .
run utl/ttq.p ( input "utl/del-pers.p").
run utl/tto.p ( input "utl/del-pers.p").
