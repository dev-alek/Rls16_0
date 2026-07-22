block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обновление информации о времени последнего закрытого документа

Автор: Перваков Михаил Сергеевич
Дата создания: 03/28/02
Author: Mikhail Pervakov
Creation date: 03/28/02

*/

define input parameter p-db-num    like ub.db-status.db-num     no-undo .
define input parameter p-fact-date like ub.db-status.stock-date no-undo .
define input parameter p-fact-time like ub.db-status.stock-time no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обновление информации о времени последнего закрытого документа".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-db-num,p-fact-date,p-fact-time)" }
{ cmp/trg-def.i }

define buffer buf_db for ub.db .

do
on error undo, return error return-value
:

  if g#db-num <> 0
  then do:
    find first buf_db no-lock
      where buf_db.db-num = g#db-num
      .
    if buf_db.remote-stock <> true
    then do:
      /* если передача остатков выключена, */
      /* то не нужно обновлять дату и время актуальности информации по другим БД */
      return . /* --->>>--- */
    end.
  end.

  find first ub.db-status exclusive-lock
    where ub.db-status.db-num = p-db-num
      no-error .
  if not available ub.db-status then do:
    create ub.db-status .
    assign
      ub.db-status.db-num = p-db-num
    .
  end.
  if ( ub.db-status.stock-date = p-fact-date
      and ub.db-status.stock-time >= p-fact-time
    )
  or ( ub.db-status.stock-date > p-fact-date
      and ub.db-status.stock-time <> ?
    )
  then do:
    /* ничего не делаем - дата в базе данных больше чем дата закрываемого документа */
  end.
  else do:
    assign
      ub.db-status.stock-date = p-fact-date
      ub.db-status.stock-time = p-fact-time
    .
  end.

end.