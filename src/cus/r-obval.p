block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-obval.p $
$Archive: cus/r-obval.p $

ќборот в валюте поставщика - создание записей во времнной таблице

јвтор: Ѕахтадзе Ќаталь€ ¬икторовна
ƒата создани€: 12/28/05
Author: Bakhtadze Natalya
Creation date: 12/28/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter pcurr-code like ub.trn-doc.exch-code no-undo.
/* валюта поставки если ? значит все */
define input parameter pnum-obj    as integer no-undo.
/* количество объектов в выборке */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obval.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-obval.p $":U .
define variable vss-description as character no-undo init "ќборот в валюте поставщика - создание записей во времнной таблице".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }
{ cmp/cli-list.i cli-list def shared }
{ cus/r-obval.i "def" "SHARED"}
{ gbl/waitfram.i }

DEFINE VARIABLE doc-num like ub.trn-doc.doc-code no-undo.
DEFINE VARIABLE is-out as decimal no-undo.
DEFINE VARIABLE is-prihod as logical no-undo.
DEFINE VARIABLE is-rashod as logical no-undo.
DEFINE VARIABLE prt-qnty as decimal no-undo.
define buffer for-doc for ub.trn-doc.
define buffer for-line for ub.doc-line.
define buffer in-parts for ub.parts.
define buffer b-temp-goods for temp-goods.
DEFINE VARIABLE my-accum as integer no-undo .
DEFINE VARIABLE all-obj-type as character no-undo.
DEFINE VARIABLE all-obj-code as integer no-undo.
DEFINE VARIABLE for-part-code like ub.parts.part-code no-undo.
DEFINE VARIABLE is-twounit as logical no-undo .
DEFINE VARIABLE first-find as logical no-undo .
DEFINE VARIABLE         v-supp-type     like ub.parts-attr.supp-type        no-undo .
DEFINE VARIABLE         v-supp-code     like ub.parts-attr.supp-code        no-undo .
DEFINE VARIABLE         v-in-code       like ub.parts-attr.income-in-code   no-undo .
DEFINE VARIABLE         v-part-code     like ub.parts-attr.part-code        no-undo .
DEFINE VARIABLE         v-gds-code      like ub.parts-attr.gds-code         no-undo .
DEFINE VARIABLE         v-price-cli     like ub.parts-attr.price-cli        no-undo .
DEFINE VARIABLE         v-cli-base-rate like ub.parts-attr.cli-base-rate    no-undo .
DEFINE VARIABLE         v-obj-type      like ub.parts-attr.obj-type         no-undo .
DEFINE VARIABLE         v-obj-code      like ub.parts-attr.obj-code         no-undo .
DEFINE VARIABLE         v-vat-type      like ub.parts-attr.vat-type         no-undo .
DEFINE VARIABLE         v-slt-type      like ub.parts-attr.slt-type         no-undo .
DEFINE VARIABLE         v-vat-pc        like ub.parts-attr.vat-pc           no-undo .
DEFINE VARIABLE         v-slt-pc        like ub.parts-attr.slt-pc           no-undo .
DEFINE VARIABLE         v-fact-qnty     like ub.parts-attr.fact-qnty        no-undo .
DEFINE VARIABLE         v-qnty          like ub.parts-attr.doc-qnty         no-undo .
DEFINE VARIABLE         v-fact-date     like ub.parts-attr.fact-date        no-undo .
DEFINE VARIABLE         v-exch-code     like ub.parts-attr.exch-code        no-undo .
DEFINE VARIABLE         v-inv           as logical                          no-undo .
DEFINE VARIABLE         v-real-is-prihod as logical no-undo .
DEFINE VARIABLE         v-real-is-rashod as logical no-undo .

define buffer buf_parts-attr for ub.parts-attr.

{ cus/r-obvat.i def in-parts. loc- ub.trn-doc. }


&scoped-define INT-docs 'iv,rv,ev':U
&scoped-define PLUS-docs 'ie,re,rs,vt,im':U
/*приход внешний,возврат внешний,касса возврат,инвентаризаци€,приход производство*/
&scoped-define PART-docs 'ap,pc':U
&scoped-define INT-PART-docs ~{&INT-docs~} + ~{&PART-docs~}

if pnum-obj > 1 then
assign
all-obj-type = ""
all-obj-code = 0
.
else do:
  find first obj-list No-LOCK No-ERROR.
  if avail obj-list then do:
    assign
    all-obj-type = obj-list.obj-type
    all-obj-code = obj-list.obj-code
    .
  end.
end.
FOR EACH temp-goods:
  delete temp-goods.
END.

FOR EACH obj-list NO-LOCK:

  FOR EACH for-doc No-LOCK WHERE
          for-doc.obj-type = obj-list.obj-type AND
          for-doc.obj-code = obj-list.obj-code AND
          for-doc.fact-date >= X-date-start AND
          for-doc.fact-date <= X-date-end AND
          for-doc.status_ = {&fact}:
          /*не можем ограничитьс€ только внешними документами потому что производство - внутренний*/
    if for-doc.office then NEXT.
    /*отсекаем внутренний приход расход и возврат и документы преобр партий*/
    if LOOKUP(for-doc.ext-doc-type, {&INT-PART-docs}) > 0 then NEXT.
    /*отсекаем вс€кие чисто партионные преобразовани€*/
    /*оставл€ем только*/
    assign
    doc-num = for-doc.doc-code
    is-out = if LOOKUP(for-doc.ext-doc-type, {&PLUS-docs}) > 0  then 1 else -1
    is-prihod = if (for-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} OR
                    for-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} /* возврат поставщику сюда ? */
                    )
                then yes else no
    is-rashod = NOt is-prihod
    .
    { cus/r-obval.i calc }
  END.
END. /*FOR EACH obj-list*/

run waitfram-hide in this-procedure .