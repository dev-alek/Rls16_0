block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xl-out.p $
$Archive: cus/xl-out.p $

Вызов старого отчета "Отчет по расходу товара"

Автор: Чернова Светлана Александровна
Дата создания: 09/07/05
Author: Svetlana Chernova
Creation date: 09/07/05

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xl-out.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/xl-out.p $":U .
define variable vss-description as character no-undo init "    ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
define input  parameter parParentProc  as widget-handle no-undo.
run cus/xl-inout.w (parParentProc , {&expense}) .