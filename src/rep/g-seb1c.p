block-level on error undo, throw.
/*

$Revision: 168fdb08b74b, 1981, rls $
$Author: SSlivenko $
$Date: Thu Aug 08 17:36:14 2019 +0300 $
$Workfile: g-seb1c.p $
$Archive: rep/g-seb1c.p $

Расчет себестоимости за день  на АЗС

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 06/15/05
*/
define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: 168fdb08b74b, 1981, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Thu Aug 08 17:36:14 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-seb1c.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-seb1c.p $":U .
define variable vss-description as character no-undo init "Расчет себестоимости за день".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w
    (
    input parParentProc ,
    input 'rep/r-seb1c.p',
    "Выгрузка данных по реализации в учетных ценах (.dbf)",
    2,
    "":U,
    "{&o-firm},{&o-currency},{&o-choice}",
    "" ,
    "",
    "all,{&Excel-yes},{&Arc-stk-yes}",
    yes).