block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cutl-inf.p $
$Archive: utl/cutl-inf.p $

Возвращает информацию о текущей базе данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

do
on error undo, return error return-value :
  find first src.sys-ctrl.
  find first src.db
    where src.db.db-num = src.sys-ctrl.db-num
    .
  return string("db: " + string(src.db.db-num) + " db-name: " + src.db.db-name + " db-key: " + src.db.db-key ).
end.