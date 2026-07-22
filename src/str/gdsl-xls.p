block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsl-xls.p $
$Archive: str/gdsl-xls.p $

экспорт списка товаров в формате EXCEL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/05
Author: Bakhtadze Natalya
Creation date: 10/31/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdsl-xls.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/gdsl-xls.p $":U .
define variable vss-description as character no-undo init "Экспорт списка товаров в формате EXCEL".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/gds-list.i gds-list def shared }
{ cmp/r-pril.i new }

&glob gds-list_name buf-gds-list
{ cmp/r-page1.i new }
define variable g#report-num as integer no-undo .

{ str/anyl-xls.i gds-list }