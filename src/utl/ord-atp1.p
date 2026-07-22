block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-atp1.p $
$Archive: utl/ord-atp1.p $

Утилита по объектам

Автор: Чернова Светлана Александровна
Дата создания: 11/07/08
Author: Svetlana Chernova
Creation date: 11/07/08

*/

define input  parameter parParentProc as handle no-undo .
define variable  p-install     as logical no-undo init no .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-atp1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ord-atp1.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

run utl/ord-atru.w ( parParentProc , "obj" ) .