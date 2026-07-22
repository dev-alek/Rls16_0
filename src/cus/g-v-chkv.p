block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-v-chkv.p $
$Archive: cus/g-v-chkv.p $

Возврат товара

Автор: Чернова Светлана Александровна
Дата создания: 10/20/05
Author: Svetlana Chernova
Creation date: 10/20/05


*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-v-chkv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-v-chkv.p $":U .
define variable vss-description as character no-undo init "Возврат товара".
define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW }
run rep/d-report.w (
input  parParentProc ,
input  "cus/r-a-chkv.p {&rcpt-return}",
input  "Возврат товара",
input  2,
input  "":U,
input  "{&o-currency},{&o-choice}":U,
input  "",
input  "{&v-base}",
input  "shop,{&Excel-yes}",
input  yes).