block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-isp-zk.p $
$Archive: cus/g-isp-zk.p $

Отчет об исполнении заказов

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-isp-zk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-isp-zk.p $":U .
define variable vss-description as character no-undo init "Отчет об исполнении заказов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w (
  input   parParentProc ,
  input   "cus/e-isp-zk.w",
  input   "Отчет об исполнении заказов",
  input   2 ,
  input   "{&g-all},{&g-choice},{&g-one}":U,
  input   "{&o-firm},{&o-currency},{&o-choice},{&o-all}":U,
  input   "" ,
  input   "{&v-rubl},{&v-base}",
  input   "all,{&Excel-yes}",
  input   no ) .