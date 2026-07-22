block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rundchow.p $
$Archive: utl/rundchow.p $

Запуск утилиты смены владельца ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/12/06
Author: Bakhtadze Natalya
Creation date: 05/12/06

*/

define input parameter parparentproc as widget-handle.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rundchow.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rundchow.p $":U .
define variable vss-description as character no-undo init "Запуск утилиты смены владельца ДК".
{ cmp/vssrevis.i }

run str/diallog.w (
              input parparentproc
            , input this-procedure
            , input 'dc-chown.p':U
            , input '':U
            , input no /*p-auto-go*/
            , input 'Прервать'
            , input 'СМЕНА ВЛАДЕЛЬЦА ДИСКОНТНЫХ КАРТ') no-error .