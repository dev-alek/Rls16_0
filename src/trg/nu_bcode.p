block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о том, что необходимо произвести действие с бар-кодом

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/03
Author: Bakhtadze Natalya
Creation date: 10/31/03

*/

define input  parameter p-b-code    as integer   no-undo .
define input  parameter p-gds-code  as integer   no-undo .
define input  parameter p-node-code as integer   no-undo .
define input  parameter p-part-code  as character no-undo .
define input  parameter p-in-code   as character no-undo .
define input  parameter p-unit-cli  as character no-undo .
define input  parameter p-action    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что необходимо произвести действие с бар-кодом".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5',p-b-code,p-gds-code,p-part-code,p-in-code,p-unit-cli,p-action)"}
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
    &btpr-type="{&btpr-type-bcode}"
    &key#_one=p-b-code
    &key#_two=p-node-code
    &key#_three=p-gds-code
    &charkey_one=p-part-code
    &charkey_two=p-in-code
    &charkey_three=p-unit-cli
  }

  find current ub.batchprocess exclusive-lock.

  assign
    ub.batchprocess.bp_execsystime = p-action  .

end.