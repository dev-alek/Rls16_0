block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: meatsemr.p $
$Archive: ref/meatsemr.p $

Запуск классификатора мясных полуфабрикатов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/31/09
Author: Bakhtadze Natalya
Creation date: 07/31/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: meatsemr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/meatsemr.p $":U .
define variable vss-description as character no-undo init "Запуск классификатора мясных полуфабрикатов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }


define variable v-node-code as integer no-undo .

{ gbl/getcntxt.i get }
if p-mode = "update" then do:
  p-mode = {&update}.
end.

run ref/meatsemi.w ( input parparentproc
                    ,input (if p-mode = {&update} and v-cntxt-db-num = 0 then "b-add" else "")
                    ,input (if p-mode = {&update} and v-cntxt-db-num = 0 then {&update}  else {&lookup})
                    ,input-output v-node-code) no-error.
