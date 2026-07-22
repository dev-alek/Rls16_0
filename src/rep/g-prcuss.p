block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-prcuss.p $
$Archive: rep/g-prcuss.p $

Отчет Отчет по прайс-листам

Автор: Морозов Александр Сергеевич
Дата создания: 05/31/11
Author: Alexandr Morozov
Creation date: 05/21/11

*/

define input  parameter parParentProc  as widget-handle no-undo.
/*define input  parameter p-recid-grp    as recid no-undo .*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-prcuss.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-prcuss.p $":U .
define variable vss-description as character no-undo init "Отчет Отчет по прайс-листам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
run rep/d-report.w
( input  parParentProc ,
  input  "rep/e-prcuss.w"  ,
  input  "Отчет по прайс-листам" ,
  input  1,
  input  "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U,
  input  "{&o-currency},{&o-choice}":U,
  input  "",
  input  "",
  input  "all,{&Excel-yes}," +
         "{&format-folder},X-SCHET-NAME=Выбор валюты"  ,
  input  no ).