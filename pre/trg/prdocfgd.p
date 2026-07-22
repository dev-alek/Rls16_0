block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.price-doc-forming-gds.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление строки в ДНЦ".
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
Main-block:
do transaction
on error undo main-block, return error
on end-key undo main-block, return error
:
  for each ub.price-doc-forming-gds-qnty exclusive-lock where
          ub.price-doc-forming-gds-qnty.b-code      = ub.price-doc-forming-gds.b-code     and
          ub.price-doc-forming-gds-qnty.pdf-db      = ub.price-doc-forming-gds.pdf-db     and
          ub.price-doc-forming-gds-qnty.pdf-id      = ub.price-doc-forming-gds.pdf-id     and
          ub.price-doc-forming-gds-qnty.plt-db-num  = ub.price-doc-forming-gds.plt-db-num and
          ub.price-doc-forming-gds-qnty.plt-id      = ub.price-doc-forming-gds.plt-id
          :
    delete ub.price-doc-forming-gds-qnty .
  end.
  for each ub.price-doc-forming-gds-sum exclusive-lock where
          ub.price-doc-forming-gds-sum.b-code      = ub.price-doc-forming-gds.b-code     and
          ub.price-doc-forming-gds-sum.pdf-db      = ub.price-doc-forming-gds.pdf-db     and
          ub.price-doc-forming-gds-sum.pdf-id      = ub.price-doc-forming-gds.pdf-id     and
          ub.price-doc-forming-gds-sum.plt-db-num  = ub.price-doc-forming-gds.plt-db-num and
          ub.price-doc-forming-gds-sum.plt-id      = ub.price-doc-forming-gds.plt-id
          :
    delete ub.price-doc-forming-gds-sum .
  end.
  for each ub.price-doc-forming-gds-tnv exclusive-lock where
          ub.price-doc-forming-gds-tnv.b-code      = ub.price-doc-forming-gds.b-code     and
          ub.price-doc-forming-gds-tnv.pdf-db      = ub.price-doc-forming-gds.pdf-db     and
          ub.price-doc-forming-gds-tnv.pdf-id      = ub.price-doc-forming-gds.pdf-id     and
          ub.price-doc-forming-gds-tnv.plt-db-num  = ub.price-doc-forming-gds.plt-db-num and
          ub.price-doc-forming-gds-tnv.plt-id      = ub.price-doc-forming-gds.plt-id
          :
    delete ub.price-doc-forming-gds-tnv .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'delete':U
        , input 'price-doc-forming-gds':U
        , input ( buffer ub.price-doc-forming-gds:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
