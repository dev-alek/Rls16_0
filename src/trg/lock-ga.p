block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание лока для блокирования массива goods-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/22/05
Author: Bakhtadze Natalya
Creation date: 11/22/05

*/

define input parameter p-recid as recid no-undo .
/*define parameter buffer buf_goods-attr for ub.goods-attr.*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание лока для блокирования массива goods-attr".
{ cmp/vssrevis.i }
define buffer buf_goods-attr for ub.goods-attr.

do
on error undo, return error
:
  find first buf_goods-attr exclusive-lock where recid(buf_goods-attr) = p-recid no-error no-wait.
  if locked buf_goods-attr then undo, return error "locked":U.
  if not available buf_goods-attr then undo, return error.
end. /*doe*/