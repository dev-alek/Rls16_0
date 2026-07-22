block-level on error undo, throw.
define input parameter pardoc-code like ub.wth-line.doc-code no-undo .
define input parameter parhost-code like ub.wth-doc.host-code no-undo .
define input parameter parobj-type like ub.wth-doc.obj-type no-undo .
define input parameter parobj-code like ub.wth-doc.obj-code no-undo .
define input parameter parcli-type like ub.wth-doc.cli-type no-undo .
define input parameter parcli-code like ub.wth-doc.cli-code no-undo .
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input parameter par-borned like ub.wth-doc.borned no-undo .
define input parameter par-rid as recid no-undo .
define input parameter parwth-code like ub.wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.wth-line.w-p-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности записи строки документа МЦ инвентар".
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
DEFINE VARIABLE var-entry as character no-undo .
define buffer buf_wth-place for ub.wth-place .
define buffer buf_wth-line for ub.wth-line .
do
on error undo, return error
:
IF NOT CAN-FIND( ub.wealth NO-LOCK WHERE ub.wealth.wth-code = parwth-code ) THEN DO:
  MESSAGE
  "Материальная ценность" parwth-code "не найдена в справочнике!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "wth-code":U.
  return error var-entry .
END.
FIND FIRST buf_wth-place NO-LOCK WHERE
    buf_wth-place.host-code   = parhost-code AND
    buf_wth-place.obj-type    = parobj-type AND
    buf_wth-place.obj-code    = parobj-code AND
    buf_wth-place.w-p-code    = parw-p-code  NO-ERROR.
IF NOT AVAIL buf_wth-place THEN DO:
  MESSAGE
  "Документ" pardoc-code skip
  "МЦ" parwth-code skip
  "МХ" parw-p-code skip
  "Не найдено место хранения МЦ в справочнике!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "w-p-code":U.
  return error var-entry .
END.
if parauto-fill and buf_wth-place.cash-desk = 0 and not par-borned then do:
  MESSAGE
  "Документ" pardoc-code skip
  "МЦ" parwth-code skip
  "МХ" parw-p-code skip
  "Для автоматического документа место хранения должно быть кассой!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "w-p-code":U.
  return error var-entry .
end.
FIND FIRST buf_wth-line NO-LOCK WHERE
          buf_wth-line.obj-type    = parobj-type   AND
          buf_wth-line.obj-code    = parobj-code   AND
          buf_wth-line.w-p-code    = parw-p-code   AND
          buf_wth-line.wth-code    = parwth-code   AND
          buf_wth-line.doc-code    = pardoc-code AND
          RECID( buf_wth-line )   <>  par-rid NO-ERROR.
IF AVAIL buf_wth-line THEN DO:
  MESSAGE
  "В этом документе уже есть запись материальной ценности" parwth-code "по м/х" parw-p-code "!" SKIP
  "Невозможно добавить в документ!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "wth-code":U.
  return error var-entry .
END.
end.
