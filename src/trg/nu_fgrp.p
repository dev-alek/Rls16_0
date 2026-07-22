block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о том, что необходимо переслать запись группы меню меню на кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input parameter  p-upper-code as integer no-undo .
define input parameter  p-out-code as integer no-undo .
define input parameter  p-upper-out-code as integer no-undo .
define input parameter  p-lvl-num        as integer no-undo .
define input  parameter p-action    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что необходимо переслать запись группы меню меню на кассы".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6',p-obj-type, p-obj-code, p-node-code, p-upper-code, p-out-code, p-action)"}
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
    &btpr-type="{&btpr-type-fgrp}"
    &charkey_one=p-obj-type
    &key#_one=p-obj-code
    &key#_two=p-node-code
    &key#_three=p-upper-code
    &charkey_two=string(p-out-code)
    &charkey_three="string(p-upper-out-code) + ~{&comma-char~} + string(p-lvl-num)"
   }

  find current ub.batchprocess exclusive-lock.

  assign
    ub.batchprocess.bp_execsystime = p-action
  .

end.