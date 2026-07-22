block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-db.p $
$Archive: adm/chk-db.p $

Проверка возможности выполнения действий в БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 05/11/07
Author: Dmitry Ukhanov
Creation date: 05/11/07

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-db.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/chk-db.p $":U .
define variable vss-description as character no-undo init "Проверка возможности выполнения действий в БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  find first buf_sys-ctrl .
  if buf_sys-ctrl.status_ <> "":U then do:
    return error substitute( "БД имеет статус &1. Работа с ней запрещена!", buf_sys-ctrl.status_ ).
  end.
  return.
end.

/* $Workfile: chk-db.p $ e n d */