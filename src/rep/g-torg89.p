block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-torg89.p $
$Archive: rep/g-torg89.p $

Отчет по движению СТ. НТФ-8.9 (Кедр-М)

Автор: Комаров Иван Сергеевич
Дата создания: 02/05/10
Author: Ivan Komarov
Creation date: 02/05/10

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-torg89.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-torg89.p $":U .
define variable vss-description as character no-undo init "Отчет по движению СТ. НТФ-8.9 (Кедр-М)".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (
                input parParentProc ,
                input 'rep/r-torg89.p',"Отчет по движению сопутствующих товаров на АЗС\АЗК (ТОРГ8.9)",
                input 8,
                input "{&g-grp}":U,
                input "{&o-currency}":U,
                input "",
                input "",
                input "all,{&Excel-yes},{&Arc-ot-yes}",
                input yes).