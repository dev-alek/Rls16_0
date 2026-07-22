block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00000010.p $
$Archive: cut/00000010.p $

Файл пирога обрезания. Категория 0.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
_user


*/

{ cmp/str-glbl.i }

define buffer old-user for src._user.
define buffer new-user for dst._user.

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
{ utl/00000001.i }

for each old-user no-lock
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first new-user no-lock
    where new-user._userid = old-user._userid
    no-error .
  if not available new-user then do:
    create new-user.
    buffer-copy old-user to new-user.
  end.
end.

output stream str-gen close.
return "Произведен экспорт таблиц: _user.".

end.