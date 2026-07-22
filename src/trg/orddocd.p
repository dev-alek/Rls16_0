block-level on error undo, throw.

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 


Автор: Ростовцев Александр Михайлович
Дата создания: 14/04/2025
Author: Rostovtsev Aleksandr
Creation date: 14/04/2025

*/
&scoped-define main-tbl order-doc
trigger procedure for delete of ub.{&main-tbl}.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления {&main-tbl}". 

define buffer buf_{&main-tbl}-attr for ub.{&main-tbl}-attr.
define buffer buf_order-line for ub.order-line.

for each buf_{&main-tbl}-attr where
         buf_{&main-tbl}-attr.db-num   = {&main-tbl}.db-num
     and buf_{&main-tbl}-attr.doc-code = {&main-tbl}.doc-code
    exclusive-lock:
  delete buf_{&main-tbl}-attr.      
end.

for each buf_order-line where
         buf_order-line.db-num   = {&main-tbl}.db-num
     and buf_order-line.doc-code = {&main-tbl}.doc-code
    exclusive-lock:
  delete buf_order-line.      
end.

{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-c-order-chip-num"
  &histheadtbl = "c-order-head"
  &fieldmainheadtab  = "db-num doc-code" 
  &del  = yes
}
