block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dat_obj.p $
$Archive: utl/dat_obj.p $

Создание списка дат на объектах БД

Автор: Хныкин Павел Андреевич
Дата создания: 01/12/10
Author: Pavel Khnykin
Creation date: 01/12/10

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dat_obj.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/dat_obj.p $":U .
define variable vss-description as character no-undo init "Создание списка дат на объектах БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define temp-table tt-obj-db no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field db-num   like ub.clients.db-num
index pi is primary unique
  obj-type
  obj-code
.

define buffer buf_obj-date  for ub.obj-date.
define buffer buf_clients   for ub.clients.
define buffer buf_tt-obj-db for tt-obj-db.

&scoped-define datelist-filename "Date1.txt":U

define variable v-list-file    as character    no-undo.
define variable v-counter      as integer      no-undo.


do
on error undo, return error
:
  assign
    v-counter = 0
  .
  output to {&datelist-filename} .

  empty temp-table buf_tt-obj-db.

  for each buf_obj-date no-lock
  :
    find first buf_tt-obj-db
      where buf_tt-obj-db.obj-type = buf_obj-date.obj-type
        and buf_tt-obj-db.obj-code = buf_obj-date.obj-code
    no-error.
    if not available buf_tt-obj-db
    then do:
      find first buf_clients no-lock
          where buf_clients.obj-type = buf_obj-date.obj-type
            and buf_clients.obj-code = buf_obj-date.obj-code
      no-error.
      if available buf_clients
      then do:
        create buf_tt-obj-db.
        assign
            buf_tt-obj-db.obj-type = buf_clients.obj-type
            buf_tt-obj-db.obj-code = buf_clients.obj-code
            buf_tt-obj-db.db-num   = buf_clients.db-num
        .
      end.
    end. /* if not available buf_tt-obj-db  */
    display buf_obj-date with width 320 stream-io.
    assign
      v-counter = v-counter + 1
    .
  end. /* for each buf_obj-date no-lock */

  put unformatted skip(2) fill('=',200) skip.

  for each buf_tt-obj-db
  :
    display buf_tt-obj-db with width 320 stream-io.
  end.

  output close.

  empty temp-table buf_tt-obj-db.

  if v-counter = 0
  then do:
    message
      "Таблица дат на объекте пуста" skip
    view-as alert-box warning
    title "Даты на объектах".
  end.
  assign
    v-list-file = search( {&datelist-filename} )
  .
  if v-list-file = ?
  then do:
    message
      "Не удалось выгрузить список дат"
      skip "в файл " {&datelist-filename}
    view-as alert-box error
    title "Даты на объектах".
  end.
  else do:
    message
      "Cписок дат на объектах"
      skip "выгружен в файл "
      skip v-list-file
    view-as alert-box information
    title "Даты на объектах".
  end.
end.