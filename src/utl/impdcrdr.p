block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: impdcrdr.p $
$Archive: utl/impdcrdr.p $

Запуск импорта по ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/16/07
Author: Bakhtadze Natalya
Creation date: 04/16/07

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: impdcrdr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/impdcrdr.p $":U .
define variable vss-description as character no-undo init "Запуск импорта по ДК".
{ cmp/vssrevis.i }

run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/imp-dcrd.w":U
    , input '':U /*parameter*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Импорт данных по ДК")
) no-error.

