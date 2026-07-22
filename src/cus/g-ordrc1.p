block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-ordrc1.p $
$Archive: cus/g-ordrc1.p $

Отчет о выполнении РЦ заказов на товары

Автор: Чернова Светлана Александровна
Дата создания: 04/20/06
Author: Svetlana Chernova
Creation date: 04/20/06

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-ordrc1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-ordrc1.p $":U .
define variable vss-description as character no-undo init "Отчет о выполнении РЦ заказов на товары".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i new }

run rep/d-report.w
( input parparentproc ,
  input "cus/e-ordrc1.w" ,
  input "Отчет о выполнении РЦ заказов на товары" ,
  input 2 ,
  input "{&g-all},{&g-choice},{&g-one},{&g-grp-prod}":U ,
  input "{&o-all},{&o-choice},{&o-firm}" ,
  input ""  ,
  input ""  ,
  input "all,{&Excel-yes}" ,
  input no ) .