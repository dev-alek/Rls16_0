block-level on error undo, throw.
/*

$Revision: 99ee5d7cf2dc, 3448, rls $
$Author: EShklyar $
$Date: 2023/10/16 15:13:33 $
$Workfile: g-obprt3.p $
$Archive: rep/g-obprt3.p $

Оборотная ведомасть по партиям с ценами производителя (Аптека)

Автор: Чернова Светлана Александровна
Дата создания: 02/05/10
Author: Svetlana Chernova
Creation date: 02/05/10


*/

define variable vss-revision    as character no-undo init "$Revision: 99ee5d7cf2dc, 3448, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:33 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-obprt3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-obprt3.p $":U .
define variable vss-description as character no-undo init "Оборотная ведомасть по партиям с ценами производителя (Аптека)".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}

run rep/d-report.w (
  input parParentProc ,
  input "rep/e-obort3.w" ,
  input "Оборотная ведомость с ценами производителя",
  input 2,
  input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U,
  input "*":U,
  input "",
  input "{&v-RUBL},{&v-base}",
  input "all,{&Arc-ot-yes}",
  input no).