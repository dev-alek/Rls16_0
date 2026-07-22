block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-rnoost.p $
$Archive: rep/g-rnoost.p $

Отчет о продаже блюд через ККМ

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 04/07/04 5:50
Скопировано с    g - n o o s t . p
*/

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
run rep/d-report.w (
    input parParentProc ,
    input 'rep/e-rnoost.w' ,
    input "Отчет о продаже блюд через ККМ " ,
    input 4 ,
    input "{&g-all},{&g-choice},{&g-one}":U ,
    input "*":U ,
    input "" ,
    input "{&v-RUBL},{&v-base}" ,
    input "all,{&Arc-ot-yes},{&Excel-yes},{&format-folder}" ,
    input no ) .