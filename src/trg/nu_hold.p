block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о том, что необходимо пересчитать межфирменные архивы по документу

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/13/00

*/

define input  parameter p-doc-code   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что необходимо пересчитать межфирменные архивы по документу".
{ cmp/vssrevis.i "substitute('&1',p-doc-code)"}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-start-date as date      no-undo .

define buffer buf_trn-doc   for ub.trn-doc   .
define buffer buf_hold-time for ub.hold-time .
define buffer buf_hold-trn  for ub.hold-trn  .

do
on error undo, return error return-value
:
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if buf_trn-doc.fact-date = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не задана дата фактического закрытия документа" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    v-start-date = date(month(buf_trn-doc.fact-date), 1, year(buf_trn-doc.fact-date))
  .

  find first buf_hold-time no-lock
    where buf_hold-time.cat-code   = {&hold-main-cat-code}
      and buf_hold-time.time-type  = {&harh-type-month}
      and buf_hold-time.start-date = v-start-date
    no-error .
  if available buf_hold-time
  then do:
    find first buf_hold-trn no-lock
      where buf_hold-trn.cat-code  = {&hold-main-cat-code}
        and buf_hold-trn.doc-code  = p-doc-code
        and buf_hold-trn.time-code = buf_hold-time.time-code
      no-error .
    if available buf_hold-trn
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "ВНИМАНИЕ!!!!" skip
        "Попытка повторного создания записи расчета межфирменного архива" skip
        "Пожалуйста, не закрывайте это сообщение и позвните в службу поддержки" skip
        "Межфирменный архив по приходам и продажам" skip
        "Документ" p-doc-code skip
        "Дата фактического закрытия" buf_trn-doc.fact-date skip
        "Дата начала периода" v-start-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  find first buf_hold-time no-lock
    where buf_hold-time.cat-code   = {&hold-inv-cat-code}
      and buf_hold-time.time-type  = {&harh-type-month}
      and buf_hold-time.start-date = v-start-date
    no-error .
  if available buf_hold-time
  then do:
    find first buf_hold-trn no-lock
      where buf_hold-trn.cat-code  = {&hold-inv-cat-code}
        and buf_hold-trn.doc-code  = p-doc-code
        and buf_hold-trn.time-code = buf_hold-time.time-code
      no-error .
    if available buf_hold-trn
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "ВНИМАНИЕ!!!!" skip
        "Попытка повторного создания записи расчета межфирменного архива" skip
        "Пожалуйста, не закрывайте это сообщение и позвните в службу поддержки" skip
        "Межфирменный архив по инвентаризациям" skip
        "Документ" p-doc-code skip
        "Дата фактического закрытия" buf_trn-doc.fact-date skip
        "Дата начала периода" v-start-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  find first buf_hold-time no-lock
    where buf_hold-time.cat-code   = {&hold-spi-cat-code}
      and buf_hold-time.time-type  = {&harh-type-month}
      and buf_hold-time.start-date = v-start-date
    no-error .
  if available buf_hold-time
  then do:
    find first buf_hold-trn no-lock
      where buf_hold-trn.cat-code  = {&hold-spi-cat-code}
        and buf_hold-trn.doc-code  = p-doc-code
        and buf_hold-trn.time-code = buf_hold-time.time-code
      no-error .
    if available buf_hold-trn
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "ВНИМАНИЕ!!!!" skip
        "Попытка повторного создания записи расчета межфирменного архива" skip
        "Пожалуйста, не закрывайте это сообщение и позвните в службу поддержки" skip
        "Межфирменный архив по списаниям" skip
        "Документ" p-doc-code skip
        "Дата фактического закрытия" buf_trn-doc.fact-date skip
        "Дата начала периода" v-start-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  { trg/btpr_upd.i
    &btpr-status="create"
    &btpr-type="{&btpr-type-hold}"
    &charkey_one=p-doc-code
  }

  { trg/btpr_upd.i
    &btpr-status="create"
    &btpr-type="{&btpr-type-hinv}"
    &charkey_one=p-doc-code
  }

  { trg/btpr_upd.i
    &btpr-status="create"
    &btpr-type="{&btpr-type-hspi}"
    &charkey_one=p-doc-code
  }


end.