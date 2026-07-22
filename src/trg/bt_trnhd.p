block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет шапки документа

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/21/00

*/

define input parameter pBatchProcess# like BatchProcess.BatchProcess# no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет шапки документа".
{ cmp/vssrevis.i "substitute('&1':u,pBatchProcess#)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable lwasprocessing as logical no-undo init false .


if pBatchProcess# <> 0
then do:
  find first BatchProcess no-lock
    where BatchProcess.BatchProcess# = pBatchProcess#
    no-error .
  if not available BatchProcess
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "BatchProcess не найден" skip
      view-as alert-box error .
    undo, return error .
  end.
  if BatchProcess.BP_Type <> {&btpr-type-trnhd}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверный тип записи BatchProcess" skip
      "BatchProcess#" BatchProcess.BatchProcess# skip
      "BP_Type" BatchProcess.BP_Type skip
      view-as alert-box error .
    undo, return error .
  end.
  run process-BatchProcess
    (buffer BatchProcess
    ).
end.
else do:
  /* update all information dependent on changes of productbom */
  for each BatchProcess no-lock
    where BatchProcess.bp_type   = {&btpr-type-trnhd}
      and BatchProcess.bp_status = {&btpr-normal}
  :
    run process-BatchProcess
      (buffer BatchProcess
      ).
    assign
      lwasprocessing = true
    .
  end.
end.

if lwasprocessing
then do:
  return "true":u .
end.
else do:
  return "":u .
end.


procedure process-BatchProcess :

  define parameter buffer pbuf_batchprocess for batchprocess .

  define buffer buf_batchprocess for batchprocess .

  /* update batchprocess record status as executing */
  { trg/btpr_upd.i
    &btpr-status="executing"
    &btpr-table="buf_batchprocess"
    &btpr-rowid="rowid(pbuf_batchprocess)"
  }

  find first ub.trn-doc no-lock
    where ub.trn-doc.doc-code = buf_batchprocess.charkey_one
    no-error .
  if available ub.trn-doc
  then do:
    run gbl/calc-trn.p
      ( input ?
        ,input recid(ub.trn-doc)
      ) no-error .
    if not error-status :error
    then do:
      assign
        bpr_lprocessedok = true
      .
    end.
  end.

  /* update batchprocess recods status as deleted */
  { trg/btpr_upd.i
    &btpr-status="deleted"
    &btpr-table="buf_batchprocess"
  }

end procedure. /* process-BatchProcess */