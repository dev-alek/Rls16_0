/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор шкалы для сортировки признаков

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 02/05/03

no_app_help.i

*/


define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Выбор шкалы для сортировки признаков".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }



define variable v-node-code as integer   no-undo .
define variable v-level     as integer   no-undo .

do
on error undo, return error return-value
:
  run gbl/d-selprt.w
    (output v-node-code
    ) .
  if v-node-code = 0
  then do:
    return . /* --->>>--- */
  end.

  define buffer buf_gds-prt for ub.gds-prt .
  find first buf_gds-prt no-lock
    where buf_gds-prt.node-code = v-node-code
    no-error .
  if not available buf_gds-prt
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена шкала" skip
      "Код шкалы" v-node-code skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.

  define variable v-prt-level as integer   no-undo .

  run gbl/d-prtlev.w
    (input  v-node-code
    ,output v-prt-level
    ) .
  if v-prt-level = 0
  then do:
    return . /* --->>>--- */
  end.

  define variable v-ok as logical   no-undo .
  message
    "Сортировка шкалы" skip
    "Шкала" buf_gds-prt.node-name skip
    "Уровень" v-prt-level skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true then do:
    return .
  end.

  run utl/srtgdprt.p
    (input v-node-code
    ,input v-prt-level
    ,input true
    ) .

  message
    "Сортировка шкалы успешно закончена" skip
    "Шкала" buf_gds-prt.node-name skip
    "Уровень" v-prt-level skip
    view-as alert-box information .

end.