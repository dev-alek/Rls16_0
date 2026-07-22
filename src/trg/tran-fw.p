/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Рукавишников Вадим
Дата создания: 24/05/21
Author: Rukavishnikov Vadim
Creation date: 24/05/21

*/
block-level on error undo, throw.

&Glob main-tbl tran-fuel
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

{ trg/trghistnws.i 
  &nws  = yes
  &nobufhist = yes  
}