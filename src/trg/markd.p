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


&scoped-define main-tbl marking
trigger procedure for delete of ub.{&main-tbl}.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления {&main-tbl}".

define buffer buf_marking-attr for ub.{&main-tbl}-attr.
{cmp\trg-def.i}
if not g#auto
then do:
   message " попытка удаления марки" view-as alert-box. 
   return error " попытка удаления марки".
end.
for each buf_marking-attr where
         buf_marking-attr.mark = ub.{&main-tbl}.mark
    exclusive-lock:
    delete buf_marking-attr.
end.
/*{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-promo-chip"
  &nws  = yes
  &del  = yes
} */
