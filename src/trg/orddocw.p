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
&glob main-tbl order-doc
TRIGGER PROCEDURE FOR WRITE OF ub.{&main-tbl}
  new buffer new-{&main-tbl}
  old buffer old-{&main-tbl}
.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на изменение таблицы {&main-tbl}".

{ trg/trghistnws.i }

if new(new-{&main-tbl}) and not g#news
then do:
  new-{&main-tbl}.db-num = g#db-num.
end.

{ trg/trghistnws.i
  &hist = yes
  &seqnamehist = "s-c-order-chip-num"
  &histheadtbl = "c-order-head"
  &fieldmainheadtab  = "db-num doc-code"
}
