block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00995000.p $
$Archive: cut/00995000.p $

Файл пирога обрезания. Относится к категории 995.

some-lk
some-lk-attr
who-lk
who-lk-attr


Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/25/09
Author: Bakhtadze Natalya
Creation date: 05/25/09

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00995000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00995000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 995.".
{ cmp/str-glbl.i }

define buffer old-some-lk for src.some-lk.
define buffer new-some-lk for dst.some-lk.
define buffer old-some-lk-attr for src.some-lk-attr.
define buffer new-some-lk-attr for dst.some-lk-attr.
define buffer old-who-lk for src.who-lk.
define buffer new-who-lk for dst.who-lk.
define buffer old-who-lk-attr for src.who-lk-attr.
define buffer new-who-lk-attr for dst.who-lk-attr.






do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.some-lk override do: end.
on WRITE of dst.some-lk-attr override do: end.
on WRITE of dst.who-lk override do: end.
on WRITE of dst.who-lk-attr override do: end.


{ utl/00000002.i some-lk }
{ utl/00000002.i some-lk-attr }
{ utl/00000002.i who-lk }
{ utl/00000002.i who-lk-attr }

output stream str-gen close.
return "Произведен экспорт таблиц: some-lk some-lk-attr who-lk who-lk-attr .".
end.





