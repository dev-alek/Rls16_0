block-level on error undo, throw.
define input parameter p-action     as character        no-undo.
define input parameter p-tbl-name   like ub.esys-route.esr-name-rec no-undo .
define input parameter p-tbl-handle as handle           no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: calloxml.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/calloxml.p $":U .
define variable vss-description as character no-undo initial "Маршрутизация OpenXML":U .
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
    assign
      p-vss-parameters = substitute('&1|&2',p-tbl-name,p-tbl-handle)
    .
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
    define variable v-cur-db-num        as integer      no-undo.
    define variable v-ext-sys-id-list   as character    no-undo.
    define buffer buf_datatype-table        for ub.datatype-table.
    define buffer buf_datatype-table-exp    for ub.datatype-table-exp.
    define buffer buf_ext-system            for ub.ext-system.
    define buffer buf_esys-datatype-exp     for ub.esys-datatype-exp.
    define buffer buf_BatchProcess          for ub.BatchProcess.
do
for buf_datatype-table
  , buf_datatype-table-exp
  , buf_esys-datatype-exp
  , buf_ext-system
  , buf_BatchProcess
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
:
    find first buf_datatype-table no-lock
         where buf_datatype-table.dtt-name = p-tbl-name
    no-error.
    if available buf_datatype-table
    then do:
        assign
            v-ext-sys-id-list = "":U
        .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-cur-db-num
  )  .
        for each buf_datatype-table-exp no-lock
           where buf_datatype-table-exp.dtt-name = buf_datatype-table.dtt-name
        on error undo, return error
        :
                for each buf_esys-datatype-exp no-lock
                   where buf_esys-datatype-exp.db-num    = v-cur-db-num
                     and buf_esys-datatype-exp.dte-id    = buf_datatype-table-exp.dte-id
                on error undo, return error
                :
                        for each buf_ext-system no-lock
                           where buf_ext-system.esys-id = buf_esys-datatype-exp.esys-id
                             and buf_ext-system.db-num  = buf_esys-datatype-exp.db-num
                        on error undo, return error
                        :
                            if buf_ext-system.esys-type = integer('0':U)
                            and ( buf_ext-system.esys-status = -1
                               or buf_ext-system.esys-status = 1 )
                            then do:
  find first buf_BatchProcess exclusive-lock
    where buf_BatchProcess.bp_type   = 'oxmlnew':U
      and buf_BatchProcess.bp_status = 'N':U
      and  buf_BatchProcess.key#_one  = buf_ext-system.esys-id
      and buf_BatchProcess.key#_two = buf_ext-system.db-num
  no-error .
                                if available buf_BatchProcess
                                then do:
                                    undo, return error
                                        substitute( "Идёт инициализация внешней системы '&3'&1&2 записи возможно только после завершения инициализации."
                                            , chr(10)
                                            , ( if p-action = 'delete':U then "Удаление" else "Изменение" )
                                            , buf_ext-system.esys-name
                                        ).
                                end.
                                assign
                                    v-ext-sys-id-list = substitute( "&1&2&3":U
                                                            , v-ext-sys-id-list
                                                            , ( if v-ext-sys-id-list = "":U then "":U else chr(1) )
                                                            , buf_ext-system.esys-id
                                                        )
                                .
                            end.
                        end.
                end.
        end.
        if v-ext-sys-id-list <> "":U
        then do:
            run nws/cr-route.p (
                  input substitute( "&1,&2", 'send-tbl-oxml':U, p-action )
                , input p-tbl-name
                , input p-tbl-handle
                , input v-ext-sys-id-list
            ) no-error.
            if error-status :error
            then do:
                return error return-value.
            end.
        end.
    end.
end.
