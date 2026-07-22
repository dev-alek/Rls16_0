/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ utl/gencutld.p


Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/01
Author: Dmitry Ukhanov
Creation date: 11/29/01

*/

/* Список утилит пирога обрезания */


create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00037000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00037001.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00043000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00043001.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00045000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00055000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00061000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00090000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00091000.p'
  .
if can-find(first _File where _file._file-name = "order-doc") then
do:
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00127000.p'
  .
end.
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00169000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00193000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00199000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00217000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00221000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00230000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00240000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00994000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/01000000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/01010000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/01020000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/01030000.p'
  .
  