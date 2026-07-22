block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пометить межфирменные архивы, как требующие перерасчета с определенной даты

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/12/02

*/

define input  parameter p-cat-code  as integer   no-undo .
define input  parameter p-lock-code as character no-undo .
define input  parameter p-fact-date as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пометить межфирменные архивы, как требующие перерасчета с определенной даты".
{ cmp/vssrevis.i "substitute('&1|&2|&3',p-cat-code,p-lock-code,p-fact-date)" }
{ cmp/trg-def.i  }
{ gbl/holdattr.i }

do
on error undo, return error return-value
:
  if  p-cat-code <> {&hold-main-cat-code}
  and p-cat-code <> {&hold-inv-cat-code}
  and p-cat-code <> {&hold-spi-cat-code}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестная категория межфирменных архивов" skip
      "Категория" p-cat-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  if p-fact-date = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Дата имеет неопределенное значение" skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  define buffer calc-hold-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input p-lock-code
    ,input p-cat-code
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input "Категория,,,,,,Расчет межфирменных архивов"
    ,input true
    ,buffer calc-hold-lock_batchprocess
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент рассчитываются межфирменные архивы" skip
      "Категория" p-cat-code skip
      "Пометить межфирменные архивы, как требующие перерасчета" skip
      view-as alert-box error .
    undo, return error .
  end.

  define variable v-hold-calc-value as character no-undo .
  define variable v-hold-calc-type  as character no-undo .
  define variable v-hold-calc       as logical   no-undo .

  /* проверяем, что не производится первоначальный расчет межфирменного архива */
  run holdattr-value in this-procedure
    (input  p-cat-code           /* p-cat-code */
    ,input  {&hold-attr-is-calc} /* p-code     */
    ,output v-hold-calc-value    /* p-value    */
    ,output v-hold-calc-type     /* p-type     */
    ) .

  assign
    v-hold-calc = (lookup(v-hold-calc-value, 'yes,true') > 0)
  .
  if v-hold-calc = true then do:
    return . /* --->>>--- */
  end.

  /* считываем дату, с которой рассчитаны межфирменные архивы */
  define variable v-attr-begin-date-value as character no-undo .
  define variable v-attr-begin-date-type  as character no-undo .
  define variable v-attr-begin-date       as date      no-undo .

  assign
    v-attr-begin-date = ?
  .
  run holdattr-value in this-procedure
    (input  p-cat-code              /* p-cat-code */
    ,input  {&hold-attr-begin-date} /* p-code     */
    ,output v-attr-begin-date-value /* p-value    */
    ,output v-attr-begin-date-type  /* p-type     */
    ) .
  if v-attr-begin-date-value <> "" then do:
    assign
      v-attr-begin-date = date(v-attr-begin-date-value)
    .
  end.

  define variable v-start-date as date      no-undo .

  assign
    v-start-date = date(month(p-fact-date), 1, year(p-fact-date))
  .


  if  v-attr-begin-date <> ?
  and v-start-date < v-attr-begin-date
  then do:
    /* позволяем удалять документ, так как архивы были рассчитаны с более поздней даты */
    /* в межфирменных архивах учитываются только обороты */
    return . /* --->>>--- */
  end.

  /* пометить архивы как требующие перерасчета */
  define buffer del_hold-time for ub.hold-time .
  find first del_hold-time exclusive-lock
    where del_hold-time.cat-code = p-cat-code
      and del_hold-time.time-type = {&harh-type-month}
      and del_hold-time.start-date = v-start-date
    no-error .
  if  available del_hold-time then do:
  assign
    del_hold-time.status_ = {&deleted}
    del_hold-time.grpupdate-date = today
    del_hold-time.update-date = today
  .
  end.
end.