block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cus-lblr.p $
$Archive: utl/cus-lblr.p $

Запуск списка настраиваемых полей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/07/07
Author: Bakhtadze Natalya
Creation date: 07/07/07

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cus-lblr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cus-lblr.p $":U .
define variable vss-description as character no-undo init "Запуск списка настраиваемых полей".
{ cmp/vssrevis.i }

define variable v-rid-list as character no-undo .

run utl/cuslbls.w ( input parparentproc
                   ,input 'b-add':U
                   ,input '':U /*p-list-code*/
                   ,input-output v-rid-list ) no-error.