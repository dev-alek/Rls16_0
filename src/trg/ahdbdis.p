block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запретить или разрешить расчет архива по базе данных

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/14/05

*/

define input  parameter p-archive-type as character no-undo .
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-disable      as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запретить или разрешить расчет архива по базе данных".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/db-attr.i  }

define buffer buf_db      for ub.db .
define buffer buf_clients for ub.clients .

define variable v-db-attr-code  as character no-undo .
define variable v-db-attr-value as character no-undo .

do
on error undo, return error return-value
:
  case p-archive-type
  :
    when {&btpr-type-arh}
    then do:
      assign
        v-db-attr-code = {&attr-db-arh-disable}
      .
    end.
    when {&btpr-type-ahsp}
    then do:
      assign
        v-db-attr-code = {&attr-db-ahsp-disable}
      .
    end.
    when {&btpr-type-aht}
    then do:
      assign
        v-db-attr-code = {&attr-db-aht-disable}
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение параметра p-archive-type" skip
        "" p-archive-type skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .

  find first buf_db no-lock
    where buf_db.db-num = p-db-num
    no-error .
  if not available buf_db
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найдена база данных" skip
      "Номер базы данных" p-db-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  case p-disable
  :
    when true
    then do:
      assign
        v-db-attr-value = 'yes':u
      .
    end.
    when false
    then do:
      assign
        v-db-attr-value = 'no':u
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задано значение параметра p-disable" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  run db-attr-write in this-procedure
    (input  p-db-num
    ,input  v-db-attr-code
    ,input  v-db-attr-value
    ) .

  for each buf_clients no-lock
    where buf_clients.db-num = p-db-num
  on error undo, return error return-value
  :
    run trg/ahobjdis.p
      (input  p-archive-type
      ,input  buf_clients.obj-type
      ,input  buf_clients.obj-code
      ,input  p-disable
      ) .
  end.

end.