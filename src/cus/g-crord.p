block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-crord.p $
$Archive: cus/g-crord.p $

Сбор заказов Объект-Фирма в СЗФП

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05

Creation date: 04/03/02 2:39

*/
define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }
define variable l-date as date no-undo .

run rep/d-report.w (
input parParentProc ,
input 'cus/e-cr-f-o.w',
input "Сбор заказов Объект->Фирма",
input 2    ,
input "":U ,
input "{&o-firm},{&o-currency},{&o-choice}":U,
input ""   ,
input ""   ,
input "all",
input no   ).