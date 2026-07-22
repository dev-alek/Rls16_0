block-level on error undo, throw.
define input parameter p-parent-handle      as handle           no-undo.
define input parameter p-esys-id            as integer          no-undo.
define input parameter p-db-num             as integer          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxmlinit.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxmlinit.p $":U .
define variable vss-description as character no-undo init "OpenXML. Начальная выгрузка данных внешней системы".
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
    define variable v-table-handle      as handle       no-undo.
    define variable v-query-handle      as handle       no-undo.
    define buffer buf_ext-system            for ub.ext-system.
    define buffer buf_datatype-table        for ub.datatype-table.
    define buffer buf_esys-datatype-exp     for ub.esys-datatype-exp.
    define buffer buf_datatype-table-exp    for ub.datatype-table-exp.
do
for buf_ext-system
  , buf_datatype-table
  , buf_esys-datatype-exp
  , buf_datatype-table-exp
on error undo, return error
:
    do transaction
    on error undo, return error
    :
        find first buf_ext-system exclusive-lock
             where buf_ext-system.esys-id   = p-esys-id
               and buf_ext-system.db-num    = p-db-num
        .
    end.
    find current buf_ext-system .
    for each buf_esys-datatype-exp no-lock
       where buf_esys-datatype-exp.esys-id  = p-esys-id
         and buf_esys-datatype-exp.db-num   = p-db-num
    on error undo, return error
    :
        for each buf_datatype-table-exp no-lock
           where buf_datatype-table-exp.dte-id  = buf_esys-datatype-exp.dte-id
        on error undo, return error
        :
            find first buf_datatype-table no-lock
                 where buf_datatype-table.dtt-name = buf_datatype-table-exp.dtt-name
            no-error.
            if available buf_datatype-table
            then do:
                create buffer v-table-handle for table buf_datatype-table-exp.dtt-name.
                create query v-query-handle.
                v-query-handle :set-buffers( v-table-handle ).
                v-query-handle :query-prepare( substitute( "for each &1", buf_datatype-table-exp.dtt-name ) ).
                v-query-handle :query-open.
                v-query-handle :get-first().
                repeat
                :
                    v-query-handle :get-next().
                    if v-query-handle :query-off-end then leave.
                    run nws/cr-route.p (
                          input substitute( "&1,&2", 'send-tbl-oxml':U, 'update':U )
                        , input buf_datatype-table-exp.dtt-name
                        , input v-table-handle
                        , input string( p-esys-id )
                    ) no-error.
                    if error-status :error
                    then do:
                        return error return-value.
                    end.
                end.
                delete object v-query-handle.
                delete object v-table-handle.
            end.
        end.
    end.
    do transaction
    on error undo, return error
    :
        find first buf_ext-system exclusive-lock
             where buf_ext-system.esys-id   = p-esys-id
               and buf_ext-system.db-num    = p-db-num
        .
        assign
            buf_ext-system.esys-status = integer( '1':U ).
        .
    end.
end.
