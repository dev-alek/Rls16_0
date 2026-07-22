block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00000001.p $
$Archive: cut/00000001.p $

Проверка, что все таблицы в базе данных dst пустые.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

*/

{ cmp/str-glbl.i }

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
{ utl/00000001.i }
define buffer new_file for dst._file.
define buffer newflt_file for ubfltdst._file.
define variable v-ok as logical no-undo .
define variable v-skip-tables as character no-undo .
define variable v-skip-flt-tables as character no-undo .
for each new_file no-lock
  where new_file._hidden = false
:
  if lookup(new_file._file-name, v-skip-tables) > 0 then next.
  run check-clear in this-procedure ( input "dst." + new_file._file-name
                                     ,output v-ok) no-error.
  if error-status:error then do:
    return error substitute("Ошибка при проверке пуста ли таблица &1 в БД-приемнике", new_file._file-name).
  end.
  if not v-ok then do:
    return error substitute("База данных dst не пуста. Eсть записи в таблице &1", new_file._file-name).
  end.
end.
if sdbname( "ubfltdst" ) <> sdbname( "dst" ) then do:
  for each newflt_file no-lock
    where newflt_file._hidden = false
  :
    if lookup(newflt_file._file-name, v-skip-flt-tables) > 0 then next.
    run check-clear in this-procedure ( input "ubfltdst." + newflt_file._file-name
                                       ,output v-ok) no-error.
    if error-status:error then do:
      return error substitute("Ошибка при проверке пуста ли таблица &1 в БД-приемнике для фильтров", newflt_file._file-name).
    end.
    if not v-ok then do:
      return error substitute("База данных ubfltdst не пуста. Eсть записи в таблице &1", newflt_file._file-name).
    end.
  end.
end.

output stream str-gen close.
return "Проверили, что все таблицы в базе данных dst пусты.".

end. /*do*/

procedure check-clear :
define input parameter p-tbl-name as character no-undo .
define output parameter p-ok as logical no-undo .

define variable v-bh as handle no-undo .
do
on error undo, return error
:

  create buffer v-bh for table p-tbl-name.
  v-ok = v-bh:find-first( " where true ") no-error.
  if v-bh:available then do:
    delete widget v-bh.
  end.
  else do:
    delete widget v-bh.
    p-ok = yes.
  end.
end.
end procedure. /* check-clear */