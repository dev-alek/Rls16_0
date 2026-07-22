block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-ordrc2.p $
$Archive: cus/g-ordrc2.p $

Отчет по заказам РЦ

Автор: Чернова Светлана Александровна
Дата создания: 04/20/06
Author: Svetlana Chernova
Creation date: 04/20/06

*/

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-ordrc2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-ordrc2.p $":U .
define variable vss-description as character no-undo init "Отчет по заказам РЦ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i   new }

run rep/d-report.w
( input parparentproc ,
  input "cus/e-ordrc2.w" ,
  input (if p-mode = "RC":U then "2.ОТЧЕТ ПО ЗАКАЗАМ ОРЦ на РЦ" else "1.ОТЧЕТ ПО ЗАКАЗАМ ОРЦ на объекте") ,
  input 2 ,
  input "{&g-all},{&g-choice}":U ,
  input "{&o-currency}" ,
  input ""  ,
  input ""  ,
  input "all,{&Excel-yes}" ,
  input no ) .