block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bat-err.p $
$Archive: gbl/bat-err.p $

Запись ошибки в файл на диске для обмена между приложениями

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/01/06
Author: Bakhtadze Natalya
Creation date: 04/01/06

*/

define input parameter p-file      as character no-undo .
define input parameter p-is-err    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bat-err.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/bat-err.p $":U .
define variable vss-description as character no-undo init "Запись ошибки в файл на диске".
{ cmp/vssrevis.i }

OS-DELETE value(p-file).
output to value(p-file).
PUT UNFORMATTED p-is-err SKIP.
output close.