block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: filecanr.p $
$Archive: gbl/filecanr.p $

Проверка возможности записи в файл

Автор: Перваков Михаил Сергеевич
Дата создания: 03/25/03
Author: Mikhail Pervakov
Creation date: 03/25/03

*/

define input  parameter p-file-name as character no-undo .
define output parameter p-can-write as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: filecanr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/filecanr.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define stream slog .

do
on error undo, return error return-value
:
  assign
    p-can-write = false
  .

  if search(p-file-name) = ?
  then do:
    undo, return error substitute("Файл не найден &1",p-file-name) .
  end.

  /* определяем - не установлен ли у файла атрибут read-only */
  assign
    file-info :file-name  = p-file-name
  .
  if index(file-info :file-type, "W") = 0
  then do:
    return .
  end.

  /* а теперь проверяем возможность записи */
  /* открываем файл для записи и закрываем его */
  run open-file-append in this-procedure
    (input p-file-name
    ) no-error .
  if error-status :error then do:
    return .
  end.

  assign
    p-can-write = true
  .
end.

procedure open-file-append :

  define input  parameter p-file-name as character no-undo .

  do
  on error undo, return error return-value
  :
    output stream slog to value(p-file-name) append .
    output stream slog close .
  end.

end procedure. /* open-file-append */