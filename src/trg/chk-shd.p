block-level on error undo, throw.
/*
$Revision$
$Author$
$Workfile$
$Archive$

Автор: SlivenkoSA
Дата создания: 17/03/22
Author: SlivenkoSA
Creation date: 17/03/22

*/
&Glob main-tbl chk-slip-head
trigger procedure for delete of ub.{&main-tbl} .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер изменение {&main-tbl}". 

{ trg/trghistnws.i 
  &del  = yes
  &nobufhist = yes  
}
