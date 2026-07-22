block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определяет, какую информацию можно копировать из строки накладной в партию

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/
define input parameter  p-doc-code      like ub.doc-line.doc-code  no-undo .
define input parameter  p-obj-type      like ub.doc-line.obj-type  no-undo .
define input parameter  p-obj-code      like ub.doc-line.obj-code  no-undo .
define input parameter  p-artic         like ub.doc-line.artic     no-undo .
define input parameter  p-prod-type     like ub.doc-line.prod-type no-undo .
define input parameter  p-prod-code     like ub.doc-line.prod-code no-undo .
define output parameter p-same-price    as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Анализ строки накладной и партий".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6':u,p-doc-code,p-obj-type,p-obj-code,p-artic,p-prod-type,p-prod-code)" }
{ cmp/str-glbl.i }

define variable l-first-part    as logical no-undo init true .


define variable v-price-cli     like ub.parts.price-cli  no-undo .
define variable v-price-base    like ub.parts.price-base no-undo .
define variable v-price-rubl    like ub.parts.price-rubl no-undo .
define variable l-same-price    as logical no-undo init true .


for each ub.parts no-lock
  where ub.parts.out-code  = p-doc-code
    and ub.parts.obj-type  = p-obj-type
    and ub.parts.obj-code  = p-obj-code
    and ub.parts.artic     = p-artic
    and ub.parts.prod-type = p-prod-type
    and ub.parts.prod-code = p-prod-code
on error undo, return error
:

  if l-first-part then do:
    assign
      l-first-part = false
    .

    assign
      v-price-cli  = ub.parts.price-cli
      v-price-base = ub.parts.price-base
      v-price-rubl = ub.parts.price-rubl
    .

  end.
  else do:
    if ub.parts.price-cli  <> v-price-cli
    or ub.parts.price-base <> v-price-base
    or ub.parts.price-rubl <> v-price-rubl
    then do:
      assign
        l-same-price   = false
      .
    end.
  end.
end.


assign
  p-same-price    = l-same-price
.