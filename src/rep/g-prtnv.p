block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-prtnv.p $
$Archive: rep/g-prtnv.p $

Прайс-лист по группе оборотов

Автор: Чернова Светлана Александровна
Дата создания: 03/15/06
Author: Svetlana Chernova
Creation date: 03/15/06

*/

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-recid-grp    as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-prtnv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-prtnv.p $":U .
define variable vss-description as character no-undo init "Прайс-лист по группе оборотов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
define buffer buf_turnover-group for ub.turnover-group  .
find first buf_turnover-group no-lock where recid(buf_turnover-group) = p-recid-grp no-error .
if error-status :error then return .

run rep/d-report.w
( input  parParentProc ,
  input  "rep/e-prqnty.w"  ,
  input  "Прайс-лист по группе оборотов " + caps(buf_turnover-group.name) + fill(" ",200) + "|" +
          string(p-recid-grp) + "|4"   ,
  input  1,
  input  "{&g-all}":U,
  input  "{&o-currency},{&o-choice}":U,
  input  "",
  input  "",
  input  "all,{&Excel-yes},{&schet-yes},{&hide-schet-all-firm},{&hide-schet-firm},{&hide-schet-choice},{&hide-schet-one},{&hide-schet-rubl}," +
         "X-SCHET-NAME=Выбор валюты"  ,
  input  no ).