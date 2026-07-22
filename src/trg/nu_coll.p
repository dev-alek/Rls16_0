block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать запись о коллизии в новостях в таблице batchprocess

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/00
Author: Bakhtadze Natalya
Creation date: 09/13/00

*/

define input  parameter p-key-rec   as character no-undo .
define input  parameter p-subject   as character no-undo .
define input  parameter p-subject-key as character no-undo .
define input  parameter p-source-db-num like ub.db.db-num no-undo .
define input  parameter p-reaction-level as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о коллизии в новостях".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5',p-key-rec,p-subject,p-subject-key,p-source-db-num,p-reaction-level)"}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


do
on error undo, return error return-value
:

  { trg/btpr_upd.i
    &btpr-status="create"
    &btpr-type="{&btpr-type-nws-coll}"
    &charkey_one=p-key-rec
    &charkey_two=p-subject
    &charkey_three=p-subject-key
    &key#_one=p-source-db-num
    &key#_two=p-reaction-level

  }

end.