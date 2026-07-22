block-level on error undo, throw.
define stream i-stream.
do
on error undo, return error
:
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcsldprd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcsldprd.p $":U .
define variable vss-description as character no-undo init "RCS: Начальная загрузка таблицы импорта товаров.".
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
define temp-table temp-codes no-undo
    field id-string         as character
    field gds-code-string   as character
index pi is primary unique id-string
.
define buffer buf_rcs-retail1product        for rcs-retail1product.
    create temp-codes.
    input stream i-stream from 'cross.csv'.
    do transaction
    :
            repeat
            :
                find first temp-codes.
                import stream i-stream delimiter "," temp-codes no-error .
                if error-status :error
                then do:
                        message
                                "Ошибка импорта, ID=" temp-codes.id-string
                                skip "Закачка отменена. "
                                skip "Исправьте файл импорта и повторите операцию."
                                skip return-value
                                skip error-status :get-message (1)
                                skip error-status :get-message (2)
                        view-as alert-box error.
                        undo, return error.
                end.
                create buf_rcs-retail1product.
                assign
                    buf_rcs-retail1product.id                   = temp-codes.id-string
                    buf_rcs-retail1product.file-name            = 'cross.csv'
                    buf_rcs-retail1product.gds-code             = integer( temp-codes.gds-code-string )
                    buf_rcs-retail1product.imp-date             = today
                    buf_rcs-retail1product.imp-time             = time
                    buf_rcs-retail1product.imp-user             = g#userid
                .
            end.
    end.
end.
