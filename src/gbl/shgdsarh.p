block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: shgdsarh.p $
$Archive: gbl/shgdsarh.p $

Показать складской архив по товару на объекте

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/05/03

*/
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .


define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: shgdsarh.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/shgdsarh.p $":U .
define variable vss-description as character no-undo initial "Показать складской архив по товару на объекте".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ arc/gds_inf.i def }
{ arc/gds_inf.i calc ub.goods p-obj-type p-obj-code }

do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  find first ub.goods no-lock
    where ub.goods.gds-code = p-gds-code
    .

  run local-gds_inf in this-procedure .

end.