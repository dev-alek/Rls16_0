block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверить, что партии в переоценке правильные и при необходимости рассчитать их

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/19/04

*/

define input parameter p-doc-num like ub.price-doc.doc-num no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Проверить, что партии в переоценке правильные и при необходимости рассчитать их".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define buffer buf_price-doc     for ub.price-doc .
define buffer buf_batchprocess  for ub.batchprocess .
define buffer exec_batchprocess for ub.batchprocess .

do
on error undo, return error return-value
:

  find first buf_price-doc no-lock
    where buf_price-doc.doc-num = p-doc-num
    no-error .
  if not available buf_price-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найдена переоценка" skip
      "Переоценка" p-doc-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  do transaction
  on error undo, return error return-value
  :
    find first buf_BatchProcess exclusive-lock
      where buf_BatchProcess.bp_type       = {&btpr-type-prc}
        and buf_BatchProcess.bp_status     = {&btpr-normal}
        and buf_BatchProcess.CharKey_Three = buf_price-doc.obj-type
        and buf_BatchProcess.Key#_One      = buf_price-doc.obj-code
        and buf_batchprocess.charkey_one   = buf_price-doc.doc-num
      no-error .
    if available buf_BatchProcess
    then do:
      { trg/btpr_upd.i
        &btpr-status="executing_deleted"
        &btpr-table="exec_batchprocess"
        &btpr-rowid="rowid(buf_batchprocess)"
      }

      run str/pr-oldd.p
        (input buf_price-doc.doc-num /* p-doc-num */
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при перерасчете переоценки" skip
          "Переоценка" buf_price-doc.doc-num skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end.