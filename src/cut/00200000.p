block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00200000.p $
$Archive: cut/00200000.p $

Файл пирога обрезания. Относится к категории 200.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
schedule
schedule-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00200000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00200000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 200.".
{ cmp/str-glbl.i }

define buffer old-schedule      for src.schedule.
define buffer new-schedule      for dst.schedule.
define buffer old-schedule-attr for src.schedule-attr.
define buffer new-schedule-attr for dst.schedule-attr.

do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.schedule      override do: end.
  on WRITE of dst.schedule-attr override do: end.

  { utl/00000002.i schedule      }
  { utl/00000002.i schedule-attr }
output stream str-gen close.
  return "Произведен экспорт таблиц: schedule schedule-attr.".
end.