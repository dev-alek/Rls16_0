block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tpsi-obj.p $
$Archive: gbl/tpsi-obj.p $

Получение признака объекта - участвует в TPSI - самостоятельная процедура

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/25/04
Author: Bakhtadze Natalya
Creation date: 11/25/04

*/

define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define output parameter p-is-tpsi-object as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tpsi-obj.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/tpsi-obj.p $":U .
define variable vss-description as character no-undo init "Получение признака объекта - участвует в TPSI - самостоятельная процедура".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/clntattr.i }
{ gbl/tpsi-obj.i }

do
on error undo, return error
:
   run is-tpsi-object in this-procedure (
                                           input p-obj-type
                                          ,input p-obj-code
                                          ,output p-is-tpsi-object
                                         )
                                         no-error.
   if error-status:error then return error return-value .


end. /*doe*/