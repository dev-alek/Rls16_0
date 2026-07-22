block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.schet-fact-doc .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление счета-фактуры".
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
      p-vss-parameters = substitute('&1|&2|&3', ub.schet-fact-doc.doc-code, ub.schet-fact-doc.doc-date, ub.schet-fact-doc.status_)
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
main-block :
do transaction
on error undo main-block, return error
:
  define buffer buf_factur-connect  for ub.factur-connect.
  define buffer buf_schet-fact-line for ub.schet-fact-line.
  define buffer buf_fin-ob  for ub.fin-ob.
  define buffer buf_fin-doc for ub.fin-doc.
  define buffer buf_trn-doc for ub.trn-doc.
  define variable  p-sys-date     as date      no-undo .
  define variable  p-sys-time     as character no-undo .
  define variable  p-sys-time-int as integer   no-undo .
  for each buf_factur-connect exclusive-lock
    where buf_factur-connect.db-num          = ub.schet-fact-doc.db-num
      and buf_factur-connect.factur-doc-code = ub.schet-fact-doc.doc-code
  :
    delete buf_factur-connect .
  end.
  for each buf_schet-fact-line exclusive-lock
     where buf_schet-fact-line.db-num   = ub.schet-fact-doc.db-num
       and buf_schet-fact-line.doc-code = ub.schet-fact-doc.doc-code
  :
    delete buf_schet-fact-line .
  end.
  if ub.schet-fact-doc.in-doc-type <> "" then do:
    case ub.schet-fact-doc.in-doc-type :
      when 'fo':U then do:
        find first buf_fin-ob exclusive-lock where buf_fin-ob.host-code = ub.schet-fact-doc.host-code and  buf_fin-ob.doc-code = ub.schet-fact-doc.in-doc-code no-error .
        if available buf_fin-ob then do:
          assign
            buf_fin-ob.factur-date      = ?
            buf_fin-ob.cr-factur        = no
            buf_fin-ob.need-factur      = 1
          .
        end.
      end.
      when 'td':U then do:
        find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = ub.schet-fact-doc.in-doc-code no-error .
        if available buf_trn-doc then do:
          assign
            buf_trn-doc.factur-date      = ?
            buf_trn-doc.cr-factur        = no
            buf_trn-doc.need-factur      = 1
          .
        end.
      end.
      when 'fd':U then do:
        find first buf_fin-doc exclusive-lock where buf_fin-doc.host-code = ub.schet-fact-doc.host-code and  buf_fin-doc.fin-doc-code = int(ub.schet-fact-doc.in-doc-code) no-error .
        if available buf_fin-doc then do:
          assign
            buf_fin-doc.factur-date      = ?
            buf_fin-doc.cr-factur        = no
            buf_fin-doc.need-factur      = 1
          .
        end.
      end.
    end.
  end.
  if not g#news and ( g#db-num <> 0 or ub.schet-fact-doc.db-num <> g#db-num) then do:
    define variable v-list-db as character no-undo .
    if g#db-num <> 0 then assign v-list-db = "0" .
    else                  assign v-list-db = string(ub.schet-fact-doc.db-num) .
    run nws/cmd-del.p
      ( input 'schet-fact-doc':U
       ,input (buffer ub.schet-fact-doc:handle)
       ,input v-list-db
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
end.
