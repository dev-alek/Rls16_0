block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 


Автор: Рубан Дмитрий Андреевич
Дата создания: 17/02/19
Author: Ruban Dmitriy
Creation date: 17/02/19

*/

&Glob main-tbl utd-marking-lines
trigger procedure for write of ub.{&main-tbl}
  new buffer new-{&main-tbl}
  old buffer old-{&main-tbl}
.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер изменение {&main-tbl}". 

define buffer marking for ub.marking. 
{ trg/trghistnws.i } 
{str/utd-err.i}
{ gbl/objsrv.i }
{str/utd.i}
if new-{&main-tbl}.gds-code eq 0
then 
   new-{&main-tbl}.gds-code = ?.

if     not g#news
   and new new-{&main-tbl}
   and new-{&main-tbl}.doc-level eq 1
then
   addMark(buffer new-{&main-tbl} ).

if     g#esys
   and new new-{&main-tbl}
then do:  /* при загрузке новостей у новой УПД статус марок меняем на глобальный статус марки */
  for first marking where
            marking.mark = new-{&main-tbl}.mark
      no-lock:
    if can-do(objSrv:Env:Marking:Sts:Mark:EqualChecked,string(marking.sts)) then
      new-{&main-tbl}.sts = marking.sts.
  end.
end.

{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-c-utd-chip-num"
  &histheadtbl = "c-utd-head"
  &fieldmainheadtab  = "db-num doc-id" 
} 


/*  &{&main-tbl}_primary_key      = "db-num doc-id LineNum mark"*/
  
  

