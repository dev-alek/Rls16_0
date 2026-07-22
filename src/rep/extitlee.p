block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: extitlee.p $
$Archive: rep/extitlee.p $

Вызов extitle.p c подменой переменных

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/06
Author: Bakhtadze Natalya
Creation date: 01/07/06

*/

DEFINE INPUT PARAMETER current-sheet as integer no-undo.
define input parameter new-reportheader as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extitlee.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/extitlee.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }


define variable old-reportheader as character no-undo .

assign
old-ReportHeader = ReportHeader
ReportHeader = ReportHeader + {&new-line} + new-reportheader.
run rep/extitle.p (input current-sheet) no-error .
ReportHeader = old-ReportHeader.