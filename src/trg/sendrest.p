block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отправка остатков по всем признакам товара в УБД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/18/09
Author: Dmitry Ukhanov
Creation date: 02/18/09

Автор1: Перваков Михаил Сергеевич
Дата создания1: 09/18/03

*/

define input  parameter p-db-num as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Отправка остатков по всем признакам товара в УБД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }


define variable v-ok as logical   no-undo .

do
on error undo, return error return-value
:
  define buffer buf_db      for ub.db .
  define buffer buf_clients for ub.clients .
  define buffer buf_prt-obj for ub.prt-obj .

  find first buf_db no-lock
    where buf_db.db-num = p-db-num
    no-error .
  if not available buf_db
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестный Номер БД" skip
      "Номер БД" p-db-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if buf_db.db-num = 0
  then do:
    message
      "В ГБД уже содержаться информация об остатках по признакам товара из всех УБД" skip
      "Операция выгрузка остатков не будет произведена" skip
      view-as alert-box information .
    undo, return error return-value .
  end.

  if buf_db.remote-stock = no
  then do:
    message
      "Выгрузку остатков можно выполнять" skip
      "только после после включения опции ЧУЖИЕ ОСТАТКИ." skip (2)
      "Для этой базы не установлен параметр - 'чужие остатки'." skip
      "Операция выгрузка остатков не будет произведена" skip
      view-as alert-box information .
    undo, return error return-value .
  end.

  assign
    v-ok = false
  .
  message
    "Отправка остатков по всем товарам в БД" buf_db.db-num skip
    "ВНИМАНИЕ! Отправка остатков может привести к чрезмерной нагрузке новостей!" skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update v-ok.
  if v-ok <> true
  then do:
    undo, return error return-value .
  end.

  define variable v-ind as integer no-undo .

  for each buf_clients no-lock
    where buf_clients.db-num <> buf_db.db-num
      and buf_clients.db-num <> ?
  on error undo, return error return-value
  :
    for each buf_prt-obj share-lock
      where buf_prt-obj.obj-type = buf_clients.obj-type
        and buf_prt-obj.obj-code = buf_clients.obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      run waitfram-show in this-procedure
        (input substitute("Маршрутизация остатков. Отправлено &1. Объект &2 &3. "
                        ,v-ind
                        ,buf_clients.obj-type
                        ,buf_clients.obj-code
                        )
        ) .

      run nws/cr-route.p
        ( input {&send-tbl}             /* act-name   */
        , input {&table_prt-obj}        /* tbl-name   */
        , input (buffer buf_prt-obj:handle) /* tbl-handle */
        , input string(buf_db.db-num)       /* lst-db-num */
        ).
    end.
  end.

  run waitfram-hide in this-procedure .


end.