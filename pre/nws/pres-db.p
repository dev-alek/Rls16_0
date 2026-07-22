block-level on error undo, throw.
define output parameter p-pres-db-list as character no-undo .
define output parameter p-message      as character no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: pres-db.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/pres-db.p $":U .
def var vss-description as character no-undo init "Создание списка выгруженных и работающих УБД ".
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
on error undo, return error
:
  define buffer buf_db for ub.db .
  define variable v-unpres-db-list as character no-undo .
  assign
    p-pres-db-list   = "":U
    p-message        = "":U
    v-unpres-db-list = "":U
  .
  for each buf_db no-lock
    where buf_db.db-num > 0
  on error undo, return error
  :
    if trim( buf_db.db-key ) <> "":U
      and buf_db.db-key <> ?
    then do:
      if p-pres-db-list = "":U then do:
        assign
          p-pres-db-list = string( buf_db.db-num )
        .
      end.
      else do:
        assign
          p-pres-db-list = p-pres-db-list + ",":U + string( buf_db.db-num )
        .
      end.
    end.
    else do:
      if v-unpres-db-list = "":U then do:
        assign
          v-unpres-db-list = string( buf_db.db-num )
        .
      end.
      else do:
        assign
          v-unpres-db-list = v-unpres-db-list + ",":U + string( buf_db.db-num )
        .
      end.
    end.
  end.
  if v-unpres-db-list <> "":U then do:
    assign
      p-message = substitute( "Работа СПН с БД &1 не производится", v-unpres-db-list )
    .
  end.
end.
