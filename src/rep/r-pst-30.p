block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-pst-30.p $
$Archive: rep/r-pst-30.p $

Оборотка по поставщикам по арх

Автор: Чернова Светлана Александровна
Дата создания: 05/06/08
Author: Svetlana Chernova
Creation date: 05/06/08

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-pst-30.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-pst-30.p $":U .
define variable vss-description as character no-undo init "Оборотка по поставщикам по арх".
{ cmp/vssrevis.i }
&glob fr-name "&framename='oborot':U"
&glob r-sort "&b3 = temp-t-post-stk-line.gds-code"         /* поле сортировки  */
{ rep/r-pstomn.i {&fr-name} {&r-sort} }
{ rep/r-pst-dp.i }