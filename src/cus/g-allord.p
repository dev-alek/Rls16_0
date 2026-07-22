block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-allord.p $
$Archive: cus/g-allord.p $

Расчет потребности в товарах

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

Creation date: 04/12/02 4:27

*/
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter g#type         as character no-undo .


if g#type = ? then do:
  message "Нельзя рассчитать , так как не знаю какой тип" .
  return .
end.
run rep/d-report.w (
input parParentProc ,
input  'cus/e-allord.w',"Расчет потребности в товарах",
input  0 ,
input  "{&g-choice},{&g-grp-prod}":U,
input  "":U,
input  "",
input  "",
input  "all,{&Excel-yes},{&customer-yes},parent-handle=" + string( this-procedure )  ,
input  no ). /*{&Arc-stk-yes},*/

procedure value-order-type :
define output parameter p-par as character no-undo .
  do
  on error undo, return error return-value
  :
  p-par = g#type .
  end.
end procedure. /* value-order-type */