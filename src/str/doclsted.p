block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: doclsted.p $
$Archive: str/doclsted.p $

Редактировать список документов в символьной переменной

Автор: Перваков Михаил Сергеевич
Дата создания: 11/25/05
Author: Mikhail Pervakov
Creation date: 11/25/05

*/

define input  parameter parparentproc       as widget-handle no-undo .
define input  parameter p-curr-host-code    like ub.sysconf.host-code no-undo .
define input  parameter p-curr-obj-type     like ub.clients.obj-type no-undo .
define input  parameter p-curr-obj-code     like ub.clients.obj-code no-undo .
define input  parameter p-doc-code-list     as character no-undo .
define input  parameter p-doc-type-list     as character no-undo .
define output parameter p-new-doc-code-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doclsted.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/doclsted.p $":U .
define variable vss-description as character no-undo init "Редактировать список документов в символьной переменной".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/doc-list.i doc-list def " new shared " }

define variable lns-cnt  as integer   no-undo .
define variable line-rec as recid     no-undo .
define buffer buf_trn-doc  for ub.trn-doc .
define buffer buf_doc-list for doc-list .

define variable v-ind                  as integer   no-undo .
define variable v-doc-list-num-entries as integer   no-undo .

do
on error undo, return error return-value
:

  assign
    v-doc-list-num-entries = num-entries(p-doc-code-list, {&comma-char})
  .

  do v-ind = 1 to v-doc-list-num-entries
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = entry(v-ind, p-doc-code-list, {&comma-char})
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Код документа" entry(v-ind, p-doc-code-list, {&comma-char}) skip
        "Номер элемента" v-ind skip
        view-as alert-box error .
    end.

    { cmp/doc-list.i doc-list assign-trn buf_trn-doc v-ind }
  end.

  run str/doc-liso.w
    (input  parparentproc    /* parparentproc    */
    ,input  p-curr-host-code /* p-curr-host-code */
    ,input  p-curr-obj-type  /* p-curr-obj-type  */
    ,input  p-curr-obj-code  /* p-curr-obj-code  */
    ) .

  define variable v-doc-list as character no-undo .

  assign
    v-doc-list = ''
  .
  define variable v-show-err-message as logical   no-undo .

  assign
    v-show-err-message = true
  .

  check_doc:
  for each buf_doc-list
  by buf_doc-list.sel-order
  :
    if lookup(buf_doc-list.doc-type, p-doc-type-list) = 0
    then do:
      if v-show-err-message = true
      then do:
        message
          "Нельзя указывать для ограничения резервирования документы типа" skip
          "" buf_doc-list.doc-type skip
          "Документ с номером" buf_doc-list.doc-code skip
          "не будет включен в список документов" skip
          "Продолжать информировать об исключенных документах?"
          view-as alert-box question buttons yes-no update v-show-err-message .
      end.
      next check_doc . /* --->>>--- */
    end.

    assign
      v-doc-list = v-doc-list
                 + (if v-doc-list <> '' then {&comma-char} else '')
                 + buf_doc-list.doc-code
    .

    if length(v-doc-list) > 10000
    then do:
      message
        "Строковый список документов может содержать только ограниченное число документов" skip
        "Всего будет учтено документов" num-entries(v-doc-list, {&comma-char}) skip
        "Оставшиеся документы будут проигнорированы" skip
        "Работа программы будет продолжена" skip
        view-as alert-box information .
      leave . /* --->>>--- */
    end.
  end.

  assign
    p-new-doc-code-list = v-doc-list
  .
end.