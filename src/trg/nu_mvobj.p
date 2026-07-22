block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о том, что идет перенос объекта из одной БД в другую

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/13/03
Author: Bakhtadze Natalya
Creation date: 10/13/03

*/

define input  parameter p-obj-type  as character   no-undo .
define input  parameter p-obj-code  as integer     no-undo .
define input parameter  p-source-db-num as integer no-undo .
define input parameter  p-target-db-num as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что идет перенос объекта из одной БД в другую".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',p-obj-type,p-obj-code,p-source-db-num,p-target-db-num)"}
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
    &btpr-type="{&btpr-type-move-object}"
    &charkey_one=p-obj-type
    &key#_one=p-obj-code
    &key#_two=p-source-db-num
    &key#_three=p-target-db-num
  }


end.