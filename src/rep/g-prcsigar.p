block-level on error undo, throw.
/*

$Revision: 2ba76cb327bb, 87, rls $
$Author: EShklyar $
$Date: Thu Oct 30 18:55:08 2014 +0300 $
$Workfile: g-prcsigar.p $
$Archive: rep/g-prcsigar.p $

Отчет Прайс лист на табачные изделия

Автор: Гридчина Полина Дмитриевна
Дата создания: 14/07/22
Author: Gridchina Polina
Creation date: 14/07/22

*/

define input  parameter parParentProc  as widget-handle no-undo.
/*define input  parameter p-recid-grp    as recid no-undo .*/

define variable vss-revision    as character no-undo init "$Revision: 2ba76cb327bb, 87, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Oct 30 18:55:08 2014 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-prcsigar.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-prcsigar.p $":U .
define variable vss-description as character no-undo init "Отчет Отчет по прайс-листам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
run rep/d-report.w
    (
    input parParentProc ,
    input 'rep/e-prcsigar.w',
    "Прайс-лист на табачные изделия",
    0,
    "{&g-choice}":U,
    "",
    "" ,
    "",
    "all,{&format-folder},{&Excel-yes}",
    no).