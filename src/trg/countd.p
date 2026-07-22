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
block-level on error undo, throw.

&scoped-define main-tbl counter
trigger procedure for delete of ub.{&main-tbl}.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления {&main-tbl}". 

if {&main-tbl}.file-name eq "cashbookrule"
then do:
{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-c-{&main-tbl}-chip-num"
  &nws  = yes 
  &del  = yes
}
end.
else do:
{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-c-{&main-tbl}-chip-num"
  &del  = yes
}
end.