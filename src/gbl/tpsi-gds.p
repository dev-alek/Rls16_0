block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tpsi-gds.p $
$Archive: gbl/tpsi-gds.p $


Получение объекта-собственника для товара в определенной БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/25/04
Author: Bakhtadze Natalya
Creation date: 11/25/04

*/

define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-db-num    like ub.db.db-num no-undo .
define input parameter p-check-tpsi-obj as logical no-undo .
/*если p-check-tpsi-obj = yes то на признак объект член ТПСИ проверяется здесь*/
/*если p-check-tpsi-obj = no то проверяется по временной таблице*/
define temp-table temp-tpsi-clients no-undo like ub.clients.
/*вр временной таблице должны лежать только записий clients участвующих в ТПСИ*/
DEFINE INPUT PARAMETER TABLE FOR temp-tpsi-clients.
define output parameter p-proprietor-host-code like ub.clients.host-code no-undo .
define output parameter p-proprietor-obj-type like ub.clients.obj-type no-undo .
define output parameter p-proprietor-obj-code like ub.clients.obj-code no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tpsi-gds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/tpsi-gds.p $":U .
define variable vss-description as character no-undo init "Получение объекта-собственника для товара в определенной БД - самостоятельная процедура".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/gdsoattr.i }
{ gbl/tpsi-gds.i }


do
on error undo, return error
:
   if p-check-tpsi-obj then
   run tpsi-gds-proprietor in this-procedure (
                                           input p-gds-code
                                          ,input p-db-num
                                          ,output p-proprietor-host-code
                                          ,output p-proprietor-obj-type
                                          ,output p-proprietor-obj-code
                                         )
                                         no-error.
   else
   run tpsi-preselect-gds-proprietor in this-procedure (
                                           input p-gds-code
                                          ,input p-db-num
                                          ,output p-proprietor-host-code
                                          ,output p-proprietor-obj-type
                                          ,output p-proprietor-obj-code
                                         )
                                         no-error.

   if error-status:error then return error return-value .


end. /*doe*/