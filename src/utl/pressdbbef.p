block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: sibinek-soft $
$Date: 20/01/2026 $
$Workfile: pressdbbef.p $
$Archive: utl/pressdbbef.p $

Сжатие БД. Выгрузка списка таблиц базы.

Автор: Ростовцев Александр
Дата создания: 20.01.2026
Author: Aleksandr Rostovtsev
Creation date: 20/01/2026

*/

/* Parameters Definitions ---                                           */


define input parameter iWrkDir as character no-undo.
define input parameter iTables as character no-undo.
define input parameter p-handle-callback     as handle    no-undo . /* вопросительный знак или указатель на вызываемую процедуру */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 20/01/2026 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pressdbbef.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pressdbbef.p $":U .
define variable vss-description as character no-undo init "Сжатие БД. Выгрузка списка таблиц базы.".
{ cmp/str-glbl.i }
{ utl/cut-load.i &filename="press_db.log"}

find first dst.sys-ctrl no-lock no-error.
if avail dst.sys-ctrl then
  return error 'Сжатие БД невозможно, т.к. база-приемник уже имеет данные.'.

define variable vFullTables as character no-undo.
define buffer old-user for ub._user.
define buffer new-user for dst._user.
define stream sToFile.

os-create-dir value(iWrkDir).

vFullTables = substitute("&1\&2",iWrkDir,iTables).

output stream sToFile to value(vFullTables).

if search(vFullTables) = ? then
  return error substitute("Не удалось открыть файл &1", vFullTables).

run write-to-log in this-procedure
   ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') + 
     {&new-line} + "Формируем список таблиц для выгрузки." + {&new-line}
   ,p-handle-callback
).

for each dst._file no-lock where
         not dst._file._file-name begins "_"
:
  put stream sToFile unformatted dst._file._file-name skip.
end.

output stream sToFile close.

run write-to-log in this-procedure
   ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') + 
     {&new-line} + "Переносим пользователей." + {&new-line}
   ,p-handle-callback
).

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  for each old-user no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    find first new-user no-lock
      where new-user._userid = old-user._userid
      no-error .
    if not available new-user then do:
      create new-user.
      buffer-copy old-user except _TenantId to new-user.
    end.
  end.
end.

