block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: hoca-inv.p $
$Archive: utl/hoca-inv.p $

Первоначальный расчет межфирменных архивов по категории 2 - инвентаризаци

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/19/03

*/

define input parameter p-install as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: hoca-inv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/hoca-inv.p $":U .
define variable vss-description as character no-undo init "Первоначальный расчет межфирменных архивов по категории 1".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-ok as logical   no-undo .

do
on error undo, return error return-value
:
  if p-install = false then do:
    message
      "Частичный расчет межфирменных архивов" skip
      "по документам инвентаризации" skip
      "Информация в архивах с даты перерасчета будет удалена" skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true then do:
      return . /* --->>>--- */
    end.
  end.

  run trg/hocacalc.p
    (input {&hold-inv-cat-code}
    ,input {&lock-prc-calc-hinv}
    ,input {&btpr-type-hinv}
    ,input "Межфирменный архив по документам инвентаризации"
    ) .

  message
    "Частичный расчет межфирменных архивов" skip
    "по документам инвентаризации закончен" skip
    view-as alert-box information .
end.