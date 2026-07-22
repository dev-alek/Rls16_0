block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка уникальности кода документа

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

Параметры:
  p-doc-code   - проверямый код
  p-table-name - имя таблицы
  p-recid      - указатель на проверяемую запись

*/

define input parameter p-doc-code   as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter p-recid      as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка уникальности кода документа".
{ cmp/vssrevis.i "substitute('&1|&2|&3',p-doc-code,p-table-name,p-recid)" }
{ cmp/str-glbl.i }

main-block:
do
on error undo main-block, return error
:
  define buffer buf_trn-doc   for ub.trn-doc .
  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_rvs-doc   for ub.rvs-doc .
  define buffer buf_icnt-doc  for ub.icnt-doc .

  if lookup(p-table-name,
    {&table_trn-doc}
    + {&comma-char} + {&table_price-doc}
    + {&comma-char} + {&table_rvs-doc}
    + {&comma-char} + {&table_icnt-doc}
    + {&comma-char} + {&table_fbr-doc}
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