block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scnlbxls.p $
$Archive: str/scnlbxls.p $

экспорт списка кодов с количествами в формате EXCEL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/05
Author: Bakhtadze Natalya
Creation date: 02/11/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: scnlbxls.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/scnlbxls.p $":U .
def var vss-description as character no-undo init "Экспорт списка товаров в формате EXCEL".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/bb-list.i scnblist def shared }
{ cmp/r-pril.i new }
&glob gds-list_name buf-gds-list
{ cmp/r-page1.i new }
define variable g#report-num as integer no-undo .

{ str/anyl-xls.i scnblist bb-list }