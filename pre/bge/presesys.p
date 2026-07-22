block-level on error undo, throw.
define output parameter p-pres-esys-list as character no-undo .
define output parameter p-message      as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: presesys.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/presesys.p $":U .
define variable vss-description as character no-undo init "Создание списка выгруженных и работающих ВС ".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
do
on error undo, return error
:
  define buffer buf_ext-system for ub.ext-system.
  define variable v-unpres-esys-list as character no-undo .
  define variable v-unpres-esys-list-view as character no-undo .
  assign
    p-pres-esys-list   = "":U
    p-message        = "":U
    v-unpres-esys-list = "":U
  .
  for each buf_ext-system no-lock where
  buf_ext-system.esys-db-num-exp = g#db-num
  or buf_ext-system.esys-db-num-imp = g#db-num
  on error undo, return error
  :
    if buf_ext-system.esys-status = 1
    then do:
      if p-pres-esys-list = "":U then do:
        assign
          p-pres-esys-list =
          substitute("&1&2&3"
                                      , buf_ext-system.esys-id
                                      , chr(4)
                                      , buf_Ext-system.db-num )
        .
      end.
      else do:
        assign
          p-pres-esys-list = p-pres-esys-list + ",":U +
                            substitute("&1&2&3"
                                      , buf_ext-system.esys-id
                                      , chr(4)
                                      , buf_Ext-system.db-num )
        .
      end.
    end.
    else do:
      if v-unpres-esys-list = "":U then do:
        assign
          v-unpres-esys-list =  string(buf_Ext-system.esys-id )
        .
      end.
      else do:
        assign
          v-unpres-esys-list = v-unpres-esys-list + ",":U + string(buf_Ext-system.esys-id )
        .
      end.
    end.
  end.
  if v-unpres-esys-list <> "":U then do:
    assign
      p-message = substitute( "Работа Системы OXML с ВС &1 не производится", v-unpres-esys-list )
    .
  end.
end.
