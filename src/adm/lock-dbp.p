block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lock-dbp.p $
$Archive: adm/lock-dbp.p $

Блокировка базы данных

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/08/06
Author: Bakhtadze Natalya
Creation date: 06/08/06

*/

define input parameter  p-db-num     as integer no-undo .

define variable  vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable  vss-author      as character no-undo init "$Author: expertek $":U .
define variable  vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable  vss-workfile    as character no-undo init "$Workfile: lock-dbp.p $":U .
define variable  vss-archive     as character no-undo init "$Archive: adm/lock-dbp.p $":U .
define variable  vss-description as character no-undo init "Блокировка базы данных".
{ cmp/vssrevis.i "substitute('&1':u,p-db-num )" }
{ cmp/str-glbl.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

define buffer buf_db for ub.db.

  find first buf_db exclusive-lock
    where buf_db.db-num = p-db-num
    no-wait no-error
  .
  if not available buf_db then do:
    if locked buf_db then do:
      undo main-block, return error substitute("&1 Другой пользователь работает с базой данных &2"
                             , vss-workfile
                             , p-db-num )  .
    end.
    else do:
      undo main-block, return error substitute("&1 БД с номером &2 не найдена"
                              ,vss-workfile
                              ,p-db-num ).
    end.
  end.
  return.
end.