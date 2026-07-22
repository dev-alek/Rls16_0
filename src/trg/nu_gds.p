block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о том, что необходимо переслать запись о товаре на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/00
Author: Bakhtadze Natalya
Creation date: 09/13/00

*/

define input  parameter p-gds-code  as integer   no-undo .
define input  parameter p-host-code as integer   no-undo .
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-action    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что необходимо переслать запись о товаре на кассу".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5',p-gds-code,p-host-code,p-obj-type,p-obj-code,p-action)"}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  { trg/btpr_upd.i
    &btpr-status="create"
    &btpr-type="{&btpr-type-gds}"
    &charkey_one=p-obj-type
    &key#_one=p-gds-code
    &key#_two=p-host-code
    &key#_three=p-obj-code
  }

  find current ub.batchprocess exclusive-lock.

  assign
    ub.batchprocess.bp_execsystime = p-action
  .

end.