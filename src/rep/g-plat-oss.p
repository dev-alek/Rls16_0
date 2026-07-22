block-level on error undo, throw.
/*

$Revision: 18c78ad2e652, 707, rls $
$Author: SShalanin $
$Date: Tue Jul 12 17:49:36 2016 +0300 $
$Workfile: g-plat-oss.p $
$Archive: rep/g-plat-oss.p $

Отчет Платежи ОСС

Автор: Кривошеин Александр Николаевич
Дата создания: 02/09/14
Author: Krivoshein Alexander
Creation date: 02/09/14

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-plat-oss.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-plat-oss.p $":U .
define variable vss-description as character no-undo init "Отчет Платежи ОСС".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }


run rep/d-report.w
    (
    input parParentProc ,
    input 'rep/e-plat-oss.w',
    "Пополнение счетов(карт)",
    4,
    "",
    "*",
    "" ,
    "",
    "all,{&Excel-yes}",
    no).
