block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о том, что необходимо переслать данные о клиенте - карте - на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/30/03
Author: Bakhtadze Natalya
Creation date: 06/30/03

*/

define input  parameter p-d-card    as character no-undo .
define input  parameter p-host-code as integer   no-undo .
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-action    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что необходимо переслать данные о клиенте - карте - на кассу".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5',p-d-card,p-host-code,p-obj-type,p-obj-code,p-action)"}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

do
on error undo, return error return-value
:

  { trg/btpr_upd.i
    &btpr-status="create"
    &btpr-type="{&btpr-type-dcard}"
    &charkey_one=p-d-card
    &key#_one=p-host-code
    &charkey_two=p-obj-type
    &key#_two=p-obj-code
  }

  find current ub.batchprocess exclusive-lock.

  assign
    ub.batchprocess.bp_execsystime = p-action
  .

end.