block-level on error undo, throw.
define input  parameter parParentProc as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: viewmess.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/viewmess.p $":U .
define variable vss-description as character no-undo init "Просмотр рассшифровки сообщений".
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
  define variable passwd as character no-undo.
  run gbl/d-prompt.w (
      'title=':u + "Просмотр расшифровки сообщения" + '\':u
    + 'text1=':u + "Введите Номер сообщения #:" + '\':u
    + 'format=' + ">>>>>>>>>9" + '\':u
    + 'type=int\':u
    + 'fillin_row=1\':u
    + 'fillin_col=24\':u
    + 'fillin_width=9\':u
    + 'fillin_height=1\':u
    + 'readonly=no\':u
    ,input-output passwd
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
  if search("exe/messages.chm") > ''
  then do:
    define variable v-full-pathname as character no-undo .
    assign
      file-info :file-name = search("exe/messages.chm")
    .
    assign
      v-full-pathname = file-info :full-pathname
    .
    run gbl/open_url.p
      (input substitute('mk:@MSITStore:&1::/&2.html':u
                        ,v-full-pathname
                        ,passwd
                        )
      ).
  end.
  else do:
    message "Поместите messages.chm в директорию c r-codes EXE ."  view-as alert-box information .
  end.
  return .
