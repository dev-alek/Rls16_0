block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура удаления партии

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define input  parameter p-doc-code    as character no-undo .
define input  parameter p-parts-recid as recid     no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура удаления партии".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-doc-code,p-parts-recid)" }
{ cmp/trg-def.i  }

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

  if buf_parts.out-code = {&free-code}
  or buf_parts.out-code = {&output-code} then do:
    message
      "Партия свободной или расходной зоны не может быть удалена."
      view-as alert-box .
    return .
  end.

  if buf_parts.in-code <> buf_parts.out-code then do:
    message
      "Партия" buf_parts.part-code " (ПН" buf_parts.in-code ") не является порожденной и не может быть удалена." skip
      /*"Воспользуйтесь интерфейсом изменения партий для изменения количества." skip*/
      view-as alert-box information .
    return .
  end.

  if  buf_trn-doc.doc-type = {&income}
  and buf_trn-doc.internal = no
  and flag_                = yes
  and buf_parts.qnty       <> 0 then do:
    message
      "Партия" buf_parts.part-code " (ПН" buf_parts.in-code ") не может быть удалена." skip
      "Количество по документу не равно 0." skip
      /*"Воспользуйтесь интерфейсом изменения партий для изменения количества." skip */
      view-as alert-box .
    return .
  end.

  delete buf_parts .
end.