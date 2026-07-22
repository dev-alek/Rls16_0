block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dir-canw.p $
$Archive: gbl/dir-canw.p $

Проверка возможности записи в директорию грубым способом

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/19/09
Author: Bakhtadze Natalya
Creation date: 06/19/09

*/

define input parameter p-dir-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dir-canw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/dir-canw.p $":U .
define variable vss-description as character no-undo init "Проверка возможности записи в директорию грубым способом".
{ cmp/vssrevis.i }

define variable v-test-file as character no-undo .
define stream outstream.

file-info:file-name = p-dir-name.
if file-info:full-pathname = ?
or file-info:full-pathname = '' then do:
  return error substitute("Не найдена директория &1", p-dir-name).
end.
if index( file-info:file-type, "D":U ) = 0  then do:
  return error substitute("&1 - это не директория &1", p-dir-name).
end.

run gbl/_tmpfile.p ( input "":U
                   , input ".txt":U
                   , output v-test-file   ) .
output stream outstream to value(v-test-file) .
put
stream outstream
unformatted "test" skip.
output stream outstream close.
file-info:file-name = v-test-file.
if file-info:full-pathname = ?
or file-info:full-pathname = '' then do:
  return error substitute("Нет возможности записи в директорию &1", p-dir-name).
end.
os-delete value(v-test-file) .