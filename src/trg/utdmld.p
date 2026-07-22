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


&scoped-define main-tbl utd-marking-lines
trigger procedure for delete of ub.{&main-tbl}.

define buffer buf_marking for ub.marking.
define buffer buf-{&main-tbl} for ub.{&main-tbl}.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления {&main-tbl}". 
{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-c-utd-chip-num"
  &histheadtbl = "c-utd-head"
  &fieldmainheadtab  = "db-num doc-id" 
  &del  = yes
}

/*  &fieldmaintab      = "db-num doc-id LineNum mark"*/
 

for each {&main-tbl}-attr where {&main-tbl}-attr.db-num eq  {&main-tbl}.db-num
                            and {&main-tbl}-attr.doc-id eq  {&main-tbl}.doc-id
                            and {&main-tbl}-attr.linenum eq  {&main-tbl}.linenum
                            and {&main-tbl}-attr.mark eq  {&main-tbl}.mark
exclusive-lock:
   delete {&main-tbl}-attr.
end.

for each buf_marking no-lock where buf_marking.mark-parent = {&main-tbl}.mark :
    find first buf-{&main-tbl} where buf-{&main-tbl}.db-num eq  {&main-tbl}.db-num
                            and buf-{&main-tbl}.doc-id eq  {&main-tbl}.doc-id
                            and buf-{&main-tbl}.linenum eq  {&main-tbl}.linenum
                            and buf-{&main-tbl}.mark eq buf_marking.mark
    exclusive-lock no-error.
    if avail buf-{&main-tbl}
    then
       delete buf-{&main-tbl}. 
end.