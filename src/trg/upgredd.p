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

&scoped-define main-tbl upgrade
trigger procedure for delete of {&main-tbl}.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления {&main-tbl}". 
{ trg/trghistnws.i 
  &nws  = yes
  &del  = yes
  &nobufhist = yes
}

for each {&main-tbl}-attr where {&main-tbl}-attr.db           eq {&main-tbl}.db
                            and {&main-tbl}-attr.version-num  eq {&main-tbl}.version-num
exclusive-lock:
   delete {&main-tbl}-attr.
end.
