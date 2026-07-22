block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00997000.p $
$Archive: cut/00997000.p $

Файл пирога обрезания. Относится к категории 997.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
rcs-destn
rcs-shops

rcs-retail1delete Не переносим

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00997000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00997000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 10.".
{ cmp/str-glbl.i }

define buffer old-rcs-destn  for src.rcs-destn.
define buffer new-rcs-destn  for dst.rcs-destn.
define buffer old-rcs-shops  for src.rcs-shops.
define buffer new-rcs-shops  for dst.rcs-shops.

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.rcs-destn override do: end.
on WRITE of dst.rcs-shops override do: end.

for each old-rcs-destn no-lock
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
    create new-rcs-destn.
    buffer-copy old-rcs-destn to new-rcs-destn.
end.
for each old-rcs-shops no-lock
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
    create new-rcs-shops.
    buffer-copy old-rcs-shops to new-rcs-shops.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: rcs-destn rcs-shops.".
end.