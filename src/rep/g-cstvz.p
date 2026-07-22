block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-cstvz.p $
$Archive: rep/g-cstvz.p $

ОТЧЕТ Документы возврата в разрезе накладных поставщика и ГТД

Автор: Чернова Светлана Александровна
Дата создания: 07/14/09
Author: Svetlana Chernova
Creation date: 07/14/09

*/
define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-cstvz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-cstvz.p $":U .
define variable vss-description as character no-undo init "ОТЧЕТ Документы возврата в разрезе накладных поставщика и ГТД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}

run rep/d-report.w
( input parParentProc,
  input "rep/r-cstvz.p",
  input "Документы возврата в разрезе накладных поставщика и ГТД" ,
  input 2,
  input "",
  input "*",
  input "{&p-sale}" ,
  input "{&v-RUBL},{&v-base}",
  input "all,{&Excel-yes}",
  input yes
  ).