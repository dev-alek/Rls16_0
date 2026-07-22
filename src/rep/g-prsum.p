block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-prsum.p $
$Archive: rep/g-prsum.p $

Прайс-лист по суммовой группе

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
define variable vss-workfile    as character no-undo init "$Workfile: g-prsum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-prsum.p $":U .
define variable vss-description as character no-undo init "Прайс-лист по суммовой группе".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
define buffer buf_sum-group for ub.sum-group  .
find first buf_sum-group no-lock where recid(buf_sum-group) = p-recid-grp no-error .
if error-status :error then return .

run rep/d-report.w
( input  parParentProc ,
  input  "rep/e-prqnty.w"  ,
  input  "Прайс-лист по суммовой группе " + caps(buf_sum-group.name) + fill(" ",200) + "|" +
          string(p-recid-grp) + "|3"   ,
  input  1,
  input  "{&g-all}":U,
  input  "{&o-currency},{&o-choice}":U,
  input  "",
  input  "",
  input  "all,{&Excel-yes},{&schet-yes},{&hide-schet-all-firm},{&hide-schet-firm},{&hide-schet-choice},{&hide-schet-one},{&hide-schet-rubl}," +
         "{&format-folder},X-SCHET-NAME=Выбор валюты"  ,
  input  no ).