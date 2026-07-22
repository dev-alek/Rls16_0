block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.contract-specif  old old-contract-specif.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись спец. договора".
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
      p-vss-parameters = substitute('&1|&2|&3', ub.contract-specif.contract-num, ub.contract-specif.host-code, ub.contract-specif.gds-code)
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define buffer buf_c-contract-specif for ub.c-contract-specif .
define variable p-sys-time   as character no-undo .
main-block :
do transaction
on error undo main-block, return error
:
  if not g#news then do:
    create buf_c-contract-specif .
      BUFFER-COPY old-contract-specif except host-code  contract-num gds-code
      TO buf_c-contract-specif
      assign
        buf_c-contract-specif.host-code    = ub.contract-specif.host-code
        buf_c-contract-specif.contract-num = ub.contract-specif.contract-num
        buf_c-contract-specif.gds-code     = ub.contract-specif.gds-code
        buf_c-contract-specif.artic        = ub.contract-specif.artic
        buf_c-contract-specif.prod-type    = ub.contract-specif.prod-type
        buf_c-contract-specif.prod-code    = ub.contract-specif.prod-code
        buf_c-contract-specif.chip-num     = next-value (s-chip-contract-specif, ub)
      .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output buf_c-contract-specif.corr-user-db-num
  ,output buf_c-contract-specif.corr-user-name
  ,output buf_c-contract-specif.corr-date
  ,output p-sys-time
  ,output buf_c-contract-specif.corr-time
  )  .
  end.
  if g#db-num = 0 then do:
    run str/callnews.p ( input "contract-specif", input (buffer ub.contract-specif:handle)) no-error .
    if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip  "Ошибка при передаче в новости спецификации к договору" skip
          error-status :get-message(1) skip    return-value skip  view-as alert-box error .
        undo, return error.
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'contract-specif':U
        , input ( buffer ub.contract-specif:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
