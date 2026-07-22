block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание лока для блокирования массива gds-obj-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/01/05
Author: Bakhtadze Natalya
Creation date: 04/01/05

*/

define input parameter p-recid as recid no-undo .
/*define parameter buffer buf_gds-obj-attr for ub.gds-obj-attr.*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание лока для блокирования массива gds-obj-attr".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
define buffer buf_gds-obj-attr for ub.gds-obj-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_gds-obj-attr exclusive-lock where recid(buf_gds-obj-attr) = p-recid no-error no-wait.
  if locked buf_gds-obj-attr then undo main-block, return error "locked":U.
  if not available buf_gds-obj-attr then undo main-block, return error.
end. /*doe*/