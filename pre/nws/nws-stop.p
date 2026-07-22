block-level on error undo, throw.
define input parameter  p-action as   character    no-undo .
define input parameter  p-db-num like ub.db.db-num no-undo .
define output parameter p-answer as   logical      no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: nws-stop.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/nws-stop.p $":U .
def var vss-description as character no-undo init "Отключение СПН для БД".
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
do
on error undo, return error
:
  define buffer buf_db for ub.db .
  if lookup( p-action, "stop,check":U ) = 0 then do:
     message
       substitute( "Не предусмотрена обработка операции &1", p-action )
       view-as alert-box.
  end.
  find first buf_db exclusive-lock
    where buf_db.db-num = p-db-num
    no-error
  .
  if not available buf_db then do:
    return error substitute( "БД с номером &1 не найдена", p-db-num ) .
  end.
  assign
    p-answer = false
  .
  case p-action :
    when "stop":U then do:
      assign
        buf_db.db-key     = "":U
        buf_db.db-key-enc = "":U
        p-answer          = true
      .
      release buf_db .
    end.
    when "check":U then do:
      if buf_db.db-key = "":U
          or buf_db.db-key = ?
      then do:
        assign
          p-answer = true
        .
      end.
    end.
  end case.
end.
return.
