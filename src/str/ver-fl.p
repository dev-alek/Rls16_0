block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ver-fl.p $
$Archive: str/ver-fl.p $

Проверка количества зваведенного в атрибутах и в gds-dtl

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 01/27/05

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ver-fl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/ver-fl.p $":U .
define variable vss-description as character no-undo init "Проверка количества зваведенного в атрибутах и в gds-dtl".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/lineattr.i }
{ str/trdcalib.i }
define input  parameter p-mode as character no-undo .
define input  parameter   p-doc-code  as character no-undo .
define output parameter   p-error       as logical   no-undo .

define temp-table temp-gds-dtl no-undo
field node-code as integer
field artic     as char
field prod-type     as char
field prod-code     as int
field gds-code  as integer
field rel-bk    as logical
index pi node-code
.
def buffer t-doc for ub.trn-doc.
find first t-doc where t-doc.doc-code = p-doc-code.
p-error = false  .

if  p-mode = {&lookup}
then do:
return .
end.

if not (( t-doc.status_ = {&wayb} or
     t-doc.status_ = {&permitted} ) and
     t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh})
then do:
define variable v-ex as logical   no-undo .
define variable v-exist as logical   no-undo .
{ str/resvinqv.i t-doc.doc-code v-ex }
  if not v-ex then do:
        { str/tdat-xst.i
            t-doc.doc-code
            {&trdcattr-frsrv-date}
            v-exist
        }
        if error-status :error or v-exist = false or v-exist = ? then do:
          message "Нет даты заказа букета!" view-as alert-box error .
          return error "Нет даты заказа букета!".
        end.
  end.

return .
end.

define variable v-ok as logical   no-undo .

define buffer prt_goods for ub.goods.
define buffer b2_doc-line-attr for ub.doc-line-attr.
for each ub.gds-dtl no-lock  where ub.gds-dtl.doc-code  = p-doc-code :
  find first prt_goods no-lock where
            prt_goods.artic     = ub.gds-dtl.artic       and
            prt_goods.prod-type = ub.gds-dtl.prod-type   and
            prt_goods.prod-code = ub.gds-dtl.prod-code   no-error .
   find first b2_doc-line-attr no-lock where b2_doc-line-attr.doc-code = p-doc-code         and
                                             b2_doc-line-attr.gds-code = prt_goods.gds-code  and
                                             num-entries(b2_doc-line-attr.attr-code) = 3    no-error .
    { str/grpnabor.i prt_goods.gds-code  v-ok }
    if v-ok = true then next.
    create  temp-gds-dtl .
    assign
    temp-gds-dtl.node-code = ub.gds-dtl.prt-code
    temp-gds-dtl.artic     = prt_goods.artic
    temp-gds-dtl.prod-type = prt_goods.prod-type
    temp-gds-dtl.prod-code = prt_goods.prod-code
    temp-gds-dtl.gds-code  = prt_goods.gds-code
    temp-gds-dtl.rel-bk    = if available b2_doc-line-attr then true else false
    .
end.


define variable v-qnty as decimal   no-undo .
define variable v-qnty-prt as decimal   no-undo .
define buffer buf_goods  for ub.goods.
define buffer buf2_goods for ub.goods.
define buffer buf2_doc-line for ub.doc-line.


for each ub.gds-dtl exclusive-lock where ub.gds-dtl.doc-code  = p-doc-code ,
    first temp-gds-dtl where
        temp-gds-dtl.artic     = ub.gds-dtl.artic and
        temp-gds-dtl.prod-type = ub.gds-dtl.prod-type and
        temp-gds-dtl.prod-code = ub.gds-dtl.prod-code and
        temp-gds-dtl.node-code = ub.gds-dtl.prt-code and
        temp-gds-dtl.rel-bk = true
  :
    v-qnty = 0 .
    v-qnty-prt = 0 .
    for each ub.doc-line-attr exclusive-lock
      where ub.doc-line-attr.doc-code  = p-doc-code
        and ub.doc-line-attr.gds-code  = temp-gds-dtl.gds-code
        and ub.doc-line-attr.attr-code begins {&lineattr-flora_gds-code} + {&comma-char} + string(ub.gds-dtl.prt-code)  + {&comma-char}
     :
      v-qnty-prt = v-qnty-prt + dec(ub.doc-line-attr.attr-value) .
    end.


    if v-qnty-prt <> ub.gds-dtl.fact-qnty then do:
      p-error = true .
      find first  ub.goods WHERE ub.goods.gds-code = temp-gds-dtl.gds-code NO-LOCK no-error .
      find first  ub.gds-prt WHERE ub.gds-prt.node-code =  temp-gds-dtl.node-code NO-LOCK no-error .

       message "Несовпадают количества по наборам и общим количеством товара" skip
       "Товар :" (if ub.gds-prt.node-name <> {&empty-scale} and ub.gds-prt.upper-code <> ub.goods.prt-root then ub.goods.gds-name + ' - ' + ub.gds-prt.f-name else ub.goods.gds-name) skip
       "Всего в наборах :" v-qnty-prt   skip
       "Итого товара :"    gds-dtl.fact-qnty
       view-as alert-box error
       .

      return error "Несовпадают количества по наборам и общим количеством товара".
    end.
end.