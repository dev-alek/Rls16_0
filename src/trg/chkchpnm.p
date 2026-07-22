block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка уникальности кода скорректированного документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


Параметры:
  p-doc-code   - проверямые код
  p-chip-num   - щепка проверяемого кода
  p-table-name - имя таблицы
  p-recid      - указатель на проверяемую запись

*/

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
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',p-doc-code,p-chip-num,p-table-name,p-recid) }

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