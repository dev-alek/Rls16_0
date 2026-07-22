block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: run-prch.p $
$Archive: str/run-prch.p $

Толкач выгрузки на прайс-чекер

Автор: Чернова Светлана Александровна
Дата создания: 10/27/06
Author: Svetlana Chernova
Creation date: 10/27/06


*/

define input  parameter parParentproc as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: run-prch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/run-prch.p $":U .
define variable vss-description as character no-undo init "Толкач выгрузки на прайс-чекер".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i get }


define variable v-host-code as integer   no-undo .
do
on error undo, return error return-value
:

{ gbl/hostcode.i
  v-cntxt-obj-type
  v-cntxt-obj-code
  v-host-code
}
  run str/gds-cash.p (
      input parparentproc
    , input v-host-code
    , input v-cntxt-obj-type
    , input v-cntxt-obj-code
    , input {&cd-type-pricecheck-Servispl}
    ) .



end.