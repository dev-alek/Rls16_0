block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdf-fill.p $
$Archive: gbl/gdf-fill.p $

Формирование списка товаров по фильтру

Автор: Чернова Светлана Александровна
Дата создания: 03/31/08
Author: Svetlana Chernova
Creation date: 03/31/08


*/


define input parameter par-run-names as character no-undo .
define input parameter Rs-list-method as character no-undo .
define input parameter Rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-filter-var as character no-undo .
define output parameter lns-cnt as integer no-undo .
define output parameter line-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdf-fill.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/gdf-fill.p $":U .
define variable vss-description as character no-undo init "Формирование списка товаров по фильтру".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ gbl/gds-fill.i gds-list-flt }