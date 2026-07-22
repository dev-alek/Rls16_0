block-level on error undo, throw.
define input parameter p-doc-code   as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter p-recid      as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка уникальности кода документа".
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
      p-vss-parameters = substitute('&1|&2|&3',p-doc-code,p-table-name,p-recid)
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
main-block:
do
on error undo main-block, return error
:
  define buffer buf_trn-doc   for ub.trn-doc .
  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_rvs-doc   for ub.rvs-doc .
  define buffer buf_icnt-doc  for ub.icnt-doc .
  if lookup(p-table-name,
    'trn-doc':U
    + chr(44) + 'price-doc':U
    + chr(44) + 'rvs-doc':U
    + chr(44) + 'icnt-doc':U
    + chr(44) + 'fbr-doc':U
  ) = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестный тип таблицы" skip
      "Код товара" p-doc-code skip
      "Таблица" p-table-name skip
      "Код" p-recid skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
      and recid(buf_trn-doc) <> p-recid
    no-error .
  if available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер документа" skip
      "Уже существует складской документ" buf_trn-doc.doc-code
        "с физическим номером" recid(buf_trn-doc) skip
      "Таблица" p-table-name skip
      "Код" p-recid skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_price-doc no-lock
    where buf_price-doc.doc-num = p-doc-code
      and recid(buf_price-doc) <> p-recid
    no-error .
  if available buf_price-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер документа" skip
      "Уже существует переоценка" buf_price-doc.doc-num
        "с физическим номером" recid(buf_price-doc) skip
      "Таблица" p-table-name skip
      "Код" p-recid skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_rvs-doc no-lock
    where buf_rvs-doc.rvs-code = p-doc-code
      and recid(buf_rvs-doc) <> p-recid
    no-error .
  if available buf_rvs-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер документа" skip
      "Уже существует сверка" buf_rvs-doc.rvs-code
        "с физическим номером" recid(buf_rvs-doc) skip
      "Таблица" p-table-name skip
      "Код" p-recid skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_icnt-doc no-lock
    where buf_icnt-doc.doc-code = p-doc-code
      and recid(buf_icnt-doc)  <> p-recid
    no-error .
  if available buf_icnt-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер документа" skip
      "Уже существует инвентаризация счетчиков ТРК" buf_icnt-doc.doc-code
        "с физическим номером" recid(buf_icnt-doc) skip
      "Таблица" p-table-name skip
      "Код" p-recid skip
      view-as alert-box error .
    undo, return error .
  end.
end.
