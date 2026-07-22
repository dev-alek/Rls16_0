/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

операции со списком ключей БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

{ gbl/conf-enc.i }
{ cmp/operlist.i }

procedure save-db-key :
/* запись ключа */

  define input parameter p-db-key like ub.db.db-key no-undo .

  do
  on error undo, return error
  :
    define buffer buf_rep for ub.rep .

    find buf_rep
      where buf_rep.rep-num = 1996011200
      no-error
    .
    if not available buf_rep then do:
      create buf_rep.
      assign
        buf_rep.rep-num = 1996011200
      .
    end.

    if lookup( p-db-key, buf_rep.name1 ) = 0 then do:
      assign
        buf_rep.name1 = buf_rep.name1 + ",":U + p-db-key
      .
    end.

  end.

end procedure. /* save-db-key */

procedure del-db-key :
/* удаление ключа */

  define input parameter p-db-key like ub.db.db-key no-undo .

  do
  on error undo, return error
  :
    define buffer buf_rep for ub.rep .
    define buffer buf_db  for ub.db .

    find first buf_db
      where buf_db.db-key = p-db-key
      no-error
    .
    if not available buf_db then do:
      find first buf_rep
        where buf_rep.rep-num = 1996011200
        no-error
      .
      if available buf_rep
        and lookup( p-db-key, buf_rep.name1 ) <> 0
      then do:
        assign
          buf_rep.name1 = diff-list( buf_rep.name1, p-db-key, ",":U )
        .
      end.
    end.

  end.

end procedure. /* del-db-key */

procedure chk-db-key :
/* процедура проверки уникальности db-key и правильности его кодировки */

  define input  parameter p-db-num     like ub.db.db-num     no-undo.
  define input  parameter p-db-key     like ub.db.db-key     no-undo.
  define input  parameter p-db-key-enc like ub.db.db-key-enc no-undo.
  define output parameter p-result     as   integer          no-undo .

  do
  on error undo, return error
  :
    define buffer buf_rep for ub.rep .
    define buffer buf_db  for ub.db .

    define variable v-ok as logical no-undo .

    if p-db-key = ?
      or p-db-key = ""
    then do:
      assign
        p-result = 1
      .
      return string("Не задано значение ключа БД.").
    end.
    if p-db-key-enc = ?
      or p-db-key-enc = ""
    then do:
      assign
        p-result = 2
      .
      return string("Не задано кодированное значение ключа БД.").
    end.

    /* подготовка списка ключей */
    find buf_rep
      where buf_rep.rep-num = 1996011200
      no-error
    .
    if not available buf_rep then do:
      create buf_rep.
      assign
        buf_rep.rep-num = 1996011200
      .
    end.

    for each buf_db no-lock
    on error undo, return error
    :
      if lookup( buf_db.db-key, buf_rep.name1 ) = 0 then do:
        assign
          buf_rep.name1 = buf_rep.name1 + ",":U + buf_db.db-key
        .
      end.
    end.

    /* проверка уникальности */
    assign
      p-result = 0
    .
    if lookup( p-db-key, buf_rep.name1 ) <> 0 then do:
      assign
        p-result = 1
      .
      return string("Данное значение ключа БД уже существует.").
    end.

    /* проверка правильности кодирования */
    run check-enc in this-procedure
      ( input p-db-num
       ,input p-db-key
       ,input ""
       ,input ""
       ,input ?
       ,input ?
       ,input p-db-key-enc
       ,output v-ok
      ) no-error.
    if error-status:error then do:
      assign
        p-result = 1
      .
      return substitute( "Ошибка при проверке правильности кодирования. &1", error-status:get-message (1) ) .
    end.
    if v-ok <> true then do:
      assign
        p-result = 2
      .
      return string("Неверное кодированное значение ключа БД.").
    end.

  end.

end procedure. /* chk-db-key */


/* $Workfile$ end */