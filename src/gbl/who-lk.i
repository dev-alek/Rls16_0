/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с локом

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/24/08
Author: Bakhtadze Natalya
Creation date: 02/24/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/key-rec.i }
{ gbl/cur-time.i }

procedure who-lk_make-some-lk :
define input  parameter p-resource-id as character no-undo .
define input  parameter p-call-id as character no-undo .
define input  parameter p-call#-id as integer   no-undo .
define input  parameter p-lk-type as character no-undo .
define input  parameter p-corr-user-db-num as integer   no-undo .
define input  parameter p-lk-mess as character no-undo .
define input  parameter p-ps as character no-undo .

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-resource#-id as integer   no-undo .

define buffer buf_who-lk for ub.who-lk.
define buffer buf_some-lk for ub.some-lk.
do
on error undo, return error return-value
:

   find first buf_who-lk no-lock where
            buf_who-lk.resource_id = p-resource-id
       and buf_who-lk.call_id = p-call-id
       and buf_who-lk.lk-type = p-lk-type
       and buf_who-lk.corr-user-db-num = p-corr-user-db-num
       no-error.
   if available buf_who-lk then return ''.

   find first buf_some-lk no-lock where
            buf_some-lk.resource_id = p-resource-id
        and buf_some-lk.lk-type = p-lk-type
            no-error.
   if not available buf_some-lk then do:

     run rul/g-callid.p ( input {&table_some-lk}
                         ,input p-resource-id
                         ,output v-resource#-id).

     create buf_some-lk.
     assign
     buf_some-lk.resource_id = p-resource-id
     buf_some-lk.resource#_id = v-resource#-id
     buf_some-lk.lk-type = p-lk-type
     .
   end.
   else do:
     find current buf_some-lk exclusive-lock.
   end.
   assign
   buf_some-lk.counter = buf_some-lk.counter + 1
   .
   run cur-time in this-procedure(output v-today, output v-time).
   create buf_who-lk.
   assign
   buf_who-lk.call_id = p-call-id
   buf_who-lk.call#_id = p-call#-id
   buf_who-lk.chip-num = next-value(s-lk-chip, {&db-name_schema})
   buf_who-lk.lk-mess      = p-lk-mess
   buf_who-lk.lk-type      = p-lk-type
   buf_who-lk.PS           = p-ps
   buf_who-lk.resource#_id = buf_some-lk.resource#_id
   buf_who-lk.resource_id = buf_some-lk.resource_id
   buf_who-lk.corr-user-db-num = p-corr-user-db-num
   buf_who-lk.corr-user-name = g#userid
   buf_who-lk.corr-date = v-today
   buf_who-lk.corr-time = v-time
   .

end.

end procedure. /* who-lk_make-some-lk */

procedure who-lk_delete-some-lk :
define input  parameter p-resource-id as character no-undo .
define input  parameter p-call-id as character no-undo .
define input  parameter p-lk-type as character no-undo .
define input  parameter p-corr-user-db-num as integer   no-undo .

define buffer buf_who-lk for ub.who-lk.
define buffer buf_some-lk for ub.some-lk.

do
on error undo, return error return-value
:
   find first buf_some-lk no-lock where
            buf_some-lk.resource_id = p-resource-id
        and buf_some-lk.lk-type = p-lk-type
            no-error.
   if not available buf_some-lk then return ''.

   find first buf_who-lk no-lock where
            buf_who-lk.resource_id = p-resource-id
       and buf_who-lk.call_id = p-call-id
       and buf_who-lk.lk-type = p-lk-type
       and buf_who-lk.corr-user-db-num = p-corr-user-db-num
       no-error.
   if not available buf_who-lk then return ''.
   find current buf_who-lk exclusive-lock.
   find current buf_some-lk exclusive-lock .
   assign
   buf_some-lk.counter = buf_some-lk.counter - 1.
   delete buf_who-lk.

end.

end procedure. /* who-lk_delete-some-lk */


/* $Workfile$ e n d */