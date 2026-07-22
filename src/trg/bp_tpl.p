block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка дублирования приоритета для ТПЛ , создание BP

Автор: Чернова Светлана Александровна
Дата создания: 02/07/08
Author: Svetlana Chernova
Creation date: 02/07/08

*/

define input  parameter p-id     as integer   no-undo .
define input  parameter p-db-num as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка дублирования приоритета для ТПЛ , создание BP".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
find first ub.price-list-type no-lock where
           ub.price-list-type.plt-id      = p-id      and
           ub.price-list-type.plt-db-num  = p-db-num  .
if ub.price-list-type.stts <> integer({&pdf-new}) then return .
/* Проверка дублирования приоритета в ТПЛ */

define variable is-dubl      as logical   no-undo .
define variable v-plt-id     as integer   no-undo .
define variable v-plt-db-num as integer   no-undo .
define variable v-recid      as character no-undo .
define variable v-recid1     as character no-undo .

define buffer buf_price-list-type for ub.price-list-type  .
define buffer exec_batchprocess for ub.batchprocess .

if ub.price-list-type.priority > 0 then do:

is-dubl = false  .
v-recid1 = string(recid(ub.price-list-type)) .
  for each buf_price-list-type no-lock where
           buf_price-list-type.stts               = integer({&pdf-new}) and
           buf_price-list-type.priority           = ub.price-list-type.priority and
           buf_price-list-type.plt-main-id        <> ub.price-list-type.plt-id and
           buf_price-list-type.plt-main-db-num    <> ub.price-list-type.plt-db-num and
           buf_price-list-type.plt-id             <> ub.price-list-type.plt-id and
           buf_price-list-type.plt-db-num         <> ub.price-list-type.plt-db-num
           :
          is-dubl      = true  .
          v-plt-id     = buf_price-list-type.plt-id     .
          v-plt-db-num = buf_price-list-type.plt-db-num .
          v-recid      = string(recid (buf_price-list-type)) .

  end.
  if is-dubl = true then do:
      if g#news then do:
        { trg/btpr_upd.i
          &btpr-status="create"
          &btpr-type="{&btpr-type-twotpl}"
          &CharKey_One=v-recid1
          &CharKey_Two=v-recid
        }
      end.
      else do:
        message  substitute("ВНИМАНИЕ !!! У ТПЛ № &1(&2)  приоритет совпадает с ТПЛ № &3(&4) . Вы уверены ? " , ub.price-list-type.plt-id  ,  ub.price-list-type.plt-db-num  , v-plt-id  ,  v-plt-db-num  ) view-as alert-box information .
      end.
  end.
end.