block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-sebpt.p $
$Archive: rep/g-sebpt.p $

Расчет себестоимости за день  на АЗС

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 06/15/05
*/
define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-sebpt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-sebpt.p $":U .
define variable vss-description as character no-undo init "Расчет себестоимости за день".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w
    (
    input parParentProc ,
    input 'rep/r-sebpt.p',"Расчет себестоимости за день",1,
    "{&g-all}":U,
    "{&o-firm},{&o-currency},{&o-choice}",
    "{&p-cost}" ,
    "{&v-base},{&v-rubl}",
    "all,{&Excel-yes},{&Arc-stk-yes}", yes).