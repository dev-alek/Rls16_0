block-level on error undo, throw.
/*

$Revision: 549cf341336a, 1921, rls $
$Author: EShklyar $
$Date: Tue Jun 25 15:59:58 2019 +0300 $
$Workfile: g-change_price.p $
$Archive: rep/g-change_price.p $

Отчет по изменению розничных цен в соответствии с МРЦ

Автор: Комаров Иван Сергеевич
Дата создания: 03/29/10
Author: Ivan Komarov
Creation date: 03/29/10

*/

define variable vss-revision    as character no-undo init "$Revision: 549cf341336a, 1921, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jun 25 15:59:58 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-change_price.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-change_price.p $":U .
define variable vss-description as character no-undo init "Отчет по изменению розничных цен в соответствии с МРЦ".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (
                input parParentProc ,
                input "rep/r-change_price.p " + string(parParentProc),
                input "Отчет по изменению розничных цен в соответствии с МРЦ",
                input 4,
                input "",
                input "*",
                input "",
                input "",
                input "all,{&Excel-yes}",
                input yes).