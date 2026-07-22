block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00205000.p $
$Archive: cut/00205000.p $

Файл пирога обрезания. Относится к категории 205.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06

Обработка таблиц:
upgrade
upgrade-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00205000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00205000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 205.".
{ cmp/str-glbl.i }

define buffer old-upgrade       for src.upgrade.
define buffer new-upgrade       for dst.upgrade.
define buffer old-upgrade-attr  for src.upgrade-attr.
define buffer new-upgrade-attr  for dst.upgrade-attr.


do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.upgrade       override do: end.
  on WRITE of dst.upgrade-attr  override do: end.

  { utl/00000002.i upgrade      }
  { utl/00000002.i upgrade-attr }
output stream str-gen close.
  return "Произведен экспорт таблиц: upgrade upgrade-attr.".
end.