block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-pr.p $
$Archive: str/pr-pr.p $

вызов печати переоценок для АКТ и для автоматич закр по параметру

Автор: Комаров Иван Сергеевич
Дата создания: 10/07/10
Author: Ivan Komarov
Creation date: 10/07/10

Автор1: Чернова Светлана Александровна
Дата создания1: 03/03/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-pr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-pr.p $":U .
define variable vss-description as character no-undo init "вызов печати переоценок для АКТ и для автоматич закр по параметру".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/thbj-def.i }

define input parameter p-mainmenu-handle    as handle           no-undo.
define input  parameter p-recid as recid     no-undo .

define buffer    buf_price-doc for ub.price-doc.

define variable par-pr-print      as character no-undo .
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .

find first  buf_price-doc no-lock where
            recid(buf_price-doc) = p-recid  and
            buf_price-doc.status_ = {&act-overvalue}
            no-error .
if error-status :error then return .

empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_price-doc.obj-type
  ,input buf_price-doc.obj-code
  ,input {&attr-overval}
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .

for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-print} then par-pr-print = string ( thbjattr_thbj-attr.property-value-logical) .
end.

if par-pr-print = "yes"  then do:
    run rep/tick-doc.p (p-mainmenu-handle, p-recid, "price", 1, no, no) .
end.

return .