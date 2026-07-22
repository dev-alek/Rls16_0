block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ppr-1.p $
$Archive: rep/r-ppr-1.p $

вызов отчета

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&glob fr-name "&framename='oborot-pri':U"
&glob r-sort "&b3 = temp-t-post-stk-line.artic"         /* поле сортировки  */
{ rep/r-pst-mn.i {&fr-name} {&r-sort} }
{ rep/r-ppr-dp.i }