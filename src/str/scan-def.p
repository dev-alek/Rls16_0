block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scan-def.p $
$Archive: str/scan-def.p $

Программа вызова scan.p

Автор: Чернова Светлана Александровна
Дата создания: 10/31/06
Author: Svetlana Chernova
Creation date: 10/31/06

create: Суслов Алексей Юрьевич
Дата создания: 04/12/06


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scan-def.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/scan-def.p $":U .
define variable vss-description as character no-undo init "Программа вызова scan.p".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-recid as recid no-undo .
run str/scan.p (parParentProc , ?, p-recid , ?).