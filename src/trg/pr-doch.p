block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

новая история переоценки

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "новая история переоценки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define param buffer old_price-doc for ub.price-doc.
define param buffer new_price-doc for ub.price-doc.
define buffer buf_c-price-doc for ub.c-price-doc  .

create buf_c-price-doc.
BUFFER-COPY old_price-doc TO buf_c-price-doc
assign
  buf_c-price-doc.chip-num           = next-value (s-corr-chip, {&db-name_schema})
  buf_c-price-doc.corr-time          = time
  buf_c-price-doc.corr-user-db-num   = g#db-num
  buf_c-price-doc.corr-man           = g#userid
  buf_c-price-doc.corr-date          = today
  buf_c-price-doc.is-del             = false
.
