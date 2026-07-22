block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: filesize.p $
$Archive: gbl/filesize.p $

Определить размер файла

Автор: Перваков Михаил Сергеевич
Дата создания: 10/23/02
Author: Mikhail Pervakov
Creation date: 10/23/02

Возвращает неопределенное значение, если файл не найден
Должны быть права на чтение из файла

*/

define input  parameter p-file-name as character no-undo .
define output parameter p-file-size as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: filesize.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/filesize.p $":U .
define variable vss-description as character no-undo init "Определить размер файла".
{ cmp/vssrevis.i "substitute('&1',p-file-name)"}

define stream sin .

do
on error undo, return error return-value
:
  define variable v-full-file-name as character no-undo .

  assign
    v-full-file-name = search(p-file-name)
  .

  if v-full-file-name = ""
  or v-full-file-name = ?
  then do:
    /* файл не найден - вернуть неопределенное значение */
    assign
      p-file-size = ?
    .
    return .
  end.

  input stream sin from value(v-full-file-name) .
  seek stream sin to end .
  assign
    p-file-size = seek(sin)
  .
  input stream sin close .

end.