block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00109000.p $
$Archive: cut/00109000.p $

Файл пирога обрезания. Относится к категории 109.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
grpa
grp-acta

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00109000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00109000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 109.".

{ cmp/str-glbl.i }
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
{ utl/00000001.i }
output stream str-gen close.
return "Произведен экспорт таблиц по группам прав: .".
end.