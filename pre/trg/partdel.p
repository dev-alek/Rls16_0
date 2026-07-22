block-level on error undo, throw.
define input  parameter p-doc-code    as character no-undo .
define input  parameter p-parts-recid as recid     no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура удаления партии".
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
      p-vss-parameters = substitute('&1|&2':u,p-doc-code,p-parts-recid)
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
define buffer buf_parts    for ub.parts .
define buffer buf_trn-doc  for ub.trn-doc .
do
on error undo, return error
:
  find buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      "Указатель партии" p-parts-recid skip
      view-as alert-box error .
    undo, return error .
  end.
  find buf_parts exclusive-lock
    where recid (buf_parts) = p-parts-recid
    no-error .
  if not available buf_parts then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найдена партия" skip
      "Документ" p-doc-code skip
      "Указатель партии" p-parts-recid skip
      view-as alert-box error .
    undo, return error .
  end.
  if buf_parts.out-code <> buf_trn-doc.doc-code then do:
    message
      "Отмеченная партия" buf_parts.part-code "не относится к документу и не может быть удалена."
      view-as alert-box .
    return .
  end.
  if buf_parts.status_ <> false then do:
    message
      "Архивная партия не может быть удалена."
      view-as alert-box .
    return .
  end.
  if buf_parts.out-code = 'free-zone':U
  or buf_parts.out-code = 'out-zone':U then do:
    message
      "Партия свободной или расходной зоны не может быть удалена."
      view-as alert-box .
    return .
  end.
  if buf_parts.in-code <> buf_parts.out-code then do:
    message
      "Партия" buf_parts.part-code " (ПН" buf_parts.in-code ") не является порожденной и не может быть удалена." skip
      view-as alert-box information .
    return .
  end.
  if  buf_trn-doc.doc-type = 'при':U
  and buf_trn-doc.internal = no
  and flag_                = yes
  and buf_parts.qnty       <> 0 then do:
    message
      "Партия" buf_parts.part-code " (ПН" buf_parts.in-code ") не может быть удалена." skip
      "Количество по документу не равно 0." skip
      view-as alert-box .
    return .
  end.
  delete buf_parts .
end.
