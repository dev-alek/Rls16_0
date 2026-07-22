block-level on error undo, throw.
/*

$Revision: 9859e4e10c80, 2113, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:23:52 2019 +0300 $
$Workfile: g-cashbk.p $
$Archive: rep/g-cashbk.p $

Кассовая книга

Автор: Комаров Иван Сергеевич
Дата создания: 03/29/10
Author: Ivan Komarov
Creation date: 03/29/10

*/

define variable vss-revision    as character no-undo init "$Revision: 9859e4e10c80, 2113, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:52 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-cashbk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-cashbk.p $":U .
define variable vss-description as character no-undo init "Кассовая книга".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (
                input parParentProc ,
                input "rep/e-cashbok.w",
                input "Кассовая книга",
                input 4,
                input "",
                input "*",
                input "",
                input "",
                input "all,{&Excel-yes}",
                input no).