block-level on error undo, throw.
define input parameter p-doc-code   as character no-undo .
define input parameter p-chip-num   as integer   no-undo .
define input parameter p-table-name as character no-undo .
define input parameter p-recid      as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка уникальности кода скорректированного документа".
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
      p-vss-parameters = substitute('&1|&2|&3|&4',p-doc-code,p-chip-num,p-table-name,p-recid)
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
main-block:
do
on error undo main-block, return error
:
  if lookup(p-table-name, "c-trn-doc,c-price-doc,c-rvs-doc":u) = 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестный тип таблицы p-table-name" skip
      "p-doc-code"    p-doc-code   skip
      "p-chip-num"    p-chip-num   skip
      "p-table-name"  p-table-name skip
      "p-recid"       p-recid      skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  find first ub.c-trn-doc no-lock
    where ub.c-trn-doc.doc-code = p-doc-code
      and ub.c-trn-doc.chip-num = p-chip-num
      and recid(ub.c-trn-doc) <> p-recid
    no-error .
  if available ub.c-trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер документа" skip
      "Уже существует скорректированый складской документ " ub.c-trn-doc.doc-code  " " ub.c-trn-doc.chip-num
      " с физическим номером " recid(ub.c-trn-doc) skip
      "p-table-name" p-table-name skip
      "p-recid" p-recid skip
      view-as alert-box error .
    undo, return error .
  end.
  find first ub.c-price-doc no-lock
    where ub.c-price-doc.doc-num  = p-doc-code
      and ub.c-price-doc.chip-num = p-chip-num
      and recid(ub.c-price-doc) <> p-recid
    no-error .
  if available ub.c-price-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер документа" skip
      "Уже существует скорректированная переоценка " ub.c-price-doc.doc-num " " ub.c-price-doc.chip-num
      " с физическим номером " recid(ub.c-price-doc) skip
      "p-table-name" p-table-name skip
      "p-recid" p-recid skip
      view-as alert-box error .
    undo, return error .
  end.
  find first ub.c-rvs-doc no-lock
    where ub.c-rvs-doc.rvs-code = p-doc-code
      and ub.c-rvs-doc.chip-num = p-chip-num
      and recid(ub.c-rvs-doc) <> p-recid
    no-error .
  if available ub.c-rvs-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер документа" skip
      "Уже существует скорректированная сверка " ub.c-rvs-doc.rvs-code " " ub.c-rvs-doc.chip-num
      " с физическим номером " recid(ub.c-rvs-doc) skip
      "p-table-name" p-table-name skip
      "p-recid" p-recid skip
      view-as alert-box error .
    undo, return error .
  end.
end.
