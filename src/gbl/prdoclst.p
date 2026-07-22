block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prdoclst.p $
$Archive: gbl/prdoclst.p $

Вызвать список переоценок

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 05/27/05

*/

define input  parameter parParentProc as widget-handle no-undo .
define input  parameter p-list-mode   as character no-undo .
define input  parameter p-status      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prdoclst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/prdoclst.p $":U .
define variable vss-description as character no-undo init "Вызвать список переоценок".
{ cmp/vssrevis.i "substitute('&1|&2',p-list-mode,p-status)"}
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

do
on error undo, return error return-value
:

  define variable loc-ref-list as character no-undo .

  run str/pr-docs.w
    (input parparentproc
    ,input "b-mark":U
    ,input p-list-mode
    ,input p-status
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input ""
    ,output loc-ref-list
    ) .
end.