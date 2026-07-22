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

&Glob main-tbl utd-err
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
  &hist = yes 
  &seqnamehist = "s-c-utd-chip-num"
  &histheadtbl = "c-utd-head"
  &fieldmainheadtab  = "db-num doc-id"   
  
} 

