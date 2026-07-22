block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 


Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: Ruban Dmitriy
Creation date: 11/07/18

*/


&scoped-define main-tbl utd
trigger procedure for delete of ub.{&main-tbl}.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления {&main-tbl}". 
define variable v-msg as character no-undo.

{gbl\objsrv.i}
{ gbl/key-rec.i }
{str/utd-err.i}
{str\utd.i} 
{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-c-utd-chip-num"
  &histheadtbl = "c-utd-head"
  &fieldmainheadtab  = "db-num doc-id" 
  &del  = yes
}

if not g#news 
then do:
  define variable v-list-db as char no-undo.
  
  if {&main-tbl}.db-num ne g#db-num and not g#esys and not g#auto
  then do:
    v-msg = substitute( "&1. Ошибка при удалении документа. Запрещено удалять документ не своей БД.", vss-workfile ).
    message v-msg view-as alert-box information title "Информация".
    undo, return error v-msg.
  end.
  
  if g#db-num = 0
  then do:
    find first ub.clients no-lock where ub.clients.obj-type = {&main-tbl}.obj-type and ub.clients.obj-code = {&main-tbl}.obj-code no-error.
     if     avail  ub.clients
        and ub.clients.db-num ne 0
     then
        v-list-db = string (ub.clients.db-num).
  end.  
  else do:
    v-list-db = "0".
  end.
  run nws/cmd-del.p
      ( input {&table_utd}
      ,input (buffer {&main-tbl}:handle)
      ,input v-list-db
      ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
end.
UnLockUTDMarkbuf(buffer {&main-tbl},yes).
for each utd-err where {&main-tbl}-err.db-num eq  {&main-tbl}.db-num
                   and {&main-tbl}-err.doc-id eq  {&main-tbl}.doc-id
exclusive-lock:
   delete {&main-tbl}-err.
end.

for each {&main-tbl}-lines where {&main-tbl}-lines.db-num eq  {&main-tbl}.db-num
                             and {&main-tbl}-lines.doc-id eq  {&main-tbl}.doc-id
exclusive-lock:
   delete {&main-tbl}-lines.
end.

for each utd-err-attr where {&main-tbl}-err-attr.db-num eq  {&main-tbl}.db-num
                        and {&main-tbl}-err-attr.doc-id eq  {&main-tbl}.doc-id
exclusive-lock:
   delete {&main-tbl}-err-attr.
end.

