block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00187000.p $
$Archive: cut/00187000.p $

Файл пирога обрезания. Относится к категории 187.

Автор: Чернова Светлана Александровна
Дата создания: 08/05/09
Author: Svetlana Chernova
Creation date: 08/05/09

Обработка таблиц:
rename-fld
rename-flt-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00187000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00187000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 187.".

{ cmp/str-glbl.i }

define buffer old-rename-fld for src.rename-fld.
define buffer new-rename-fld for dst.rename-fld.
define buffer old-rename-fld-attr for src.rename-fld-attr.
define buffer new-rename-fld-attr for dst.rename-fld-attr.

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
{ utl/00000001.i }
on WRITE of dst.rename-fld override do: end.
{ utl/00000002.i rename-fld }
{ utl/00000002.i rename-fld-attr }
output stream str-gen close.
return "Произведен экспорт таблиц: rename-fld rename-fld-attr.".
end.