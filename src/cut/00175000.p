block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00175000.p $
$Archive: cut/00175000.p $

Файл пирога обрезания. Относится к категории 175.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06

Обработка таблиц:
tare
c-tare
units
c-units
units-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00175000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00175000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 175.".

{ cmp/str-glbl.i }


define buffer old-units      for src.units.
define buffer new-units      for dst.units.
define buffer old-c-units    for src.c-units.
define buffer new-c-units    for dst.c-units.
define buffer old-units-attr for src.units-attr.
define buffer new-units-attr for dst.units-attr.
define buffer old-tare      for src.tare.
define buffer new-tare      for dst.tare.
define buffer old-c-tare    for src.c-tare.
define buffer new-c-tare    for dst.c-tare.



do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
{ utl/00000001.i }
on WRITE of dst.units override do: end.
on WRITE of dst.c-units override do: end.
on WRITE of dst.tare override do: end.
on WRITE of dst.c-tare override do: end.
on WRITE of dst.units-attr override do: end.
{ utl/00000002.i units }
if varstay-history then do:
  { utl/00000002.i c-units }
end.
{ utl/00000002.i units-attr }
{ utl/00000002.i tare }
if varstay-history then do:
  { utl/00000002.i c-tare }
end.
output stream str-gen close.
return "Произведен экспорт таблиц: units c-units units-attr tare c-tare .".
end.