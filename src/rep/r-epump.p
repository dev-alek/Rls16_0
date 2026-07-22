block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-epump.p $
$Archive: rep/r-epump.p $

Печать документа измреения погрешности счетчиков ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/27/07
Author: Bakhtadze Natalya
Creation date: 07/27/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-recid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-epump.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-epump.p $":U .
define variable vss-description as character no-undo init "Печать документа измреения погрешности счетчиков ТРК".
{ cmp/vssrevis.i }

message
"Не предусмотрено печатной формы для документа"  skip
"СМ. СМЕННЫЙ ОТЧЕТ"
view-as alert-box .