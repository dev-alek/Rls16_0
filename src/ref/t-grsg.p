block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: t-grsg.p $
$Archive: ref/t-grsg.p $

Толкач процедуры Группы сроков годности

Автор: Чернова Светлана Александровна
Дата создания: 08/30/06
Author: Svetlana Chernova
Creation date: 08/30/06

*/
define input  parameter ParParentProc as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: t-grsg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/t-grsg.p $":U .
define variable vss-description as character no-undo init "Толкач процедуры Группы сроков годности".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define variable v-sts as integer   no-undo .
define variable v-rid-list as character no-undo .

run ref/gpervals.w (input parParentProc
              , v-cntxt-obj-type
              , v-cntxt-obj-code
              , "b-add,b-de,b-chg":U
              , {&all}
              , input-output v-sts
              , input-output v-rid-list ) no-error .