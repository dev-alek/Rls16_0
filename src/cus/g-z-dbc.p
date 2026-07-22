block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-z-dbc.p $
$Archive: cus/g-z-dbc.p $

Состояние запаса по объектам + доп.бар-коды

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/01/04 6:46

*/

define input  parameter parParentProc  as widget-handle no-undo.

{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW }

run rep/d-report.w
(
input parParentProc ,
'cus/e-z-dbc.w',
"Состояние запаса по объектам + Доп.БК ",
 1,
"*":U,
"*":U,
"{&p-cost},{&p-crsa}" ,
"{&v-RUBL},{&v-base}",
"all,{&Arc-stk-yes},{&Excel-yes}",
no
).