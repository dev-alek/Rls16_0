block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: dbdiscon.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/dbdiscon.p $":U .
def var vss-description as character no-undo init "Разрыв соединений со всеми базами данных".
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
on error  undo, return error substitute( "&1. ERROR &2", vss-workfile, error-status:get-message( error-status:num-messages ) )
on stop   undo, return error substitute( "&1. STOP", vss-workfile )
on endkey undo, return error substitute( "&1. ENDKEY", vss-workfile )
on quit   undo, return error substitute( "&1. QUIT", vss-workfile )
:
  define variable ind           as integer   no-undo .
  define variable database-list as character no-undo .
  define variable alias-list    as character no-undo .
  run gbl/del-pers.p no-error .
  if error-status :error then do:
    return error vss-workfile + "Ошибка при удалении persistent-procedures" .
  end.
  assign
    database-list = ""
  .
  do ind = 1 to num-dbs
  :
    assign
      database-list = database-list
                    + ( if database-list > "" then "," else "" ) + ldbname(ind)
    .
  end.
  do ind = 1 to num-entries(database-list)
  on error undo, return error
  :
    disconnect value(entry(ind,database-list)) .
  end.
  assign
    alias-list = ""
  .
  do ind = 1 to num-aliases
  :
    assign
      alias-list = alias-list
                    + ( if alias-list > "" then "," else "" ) + alias(ind)
    .
  end.
  do ind = 1 to num-entries(alias-list)
  on error undo, return error
  :
    delete alias value(entry(ind,alias-list)) .
  end.
end.
