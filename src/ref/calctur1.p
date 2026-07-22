block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: calctur1.p $
$Archive: ref/calctur1.p $

Пересчет оборотов нарастающим итогом с момента fact-order на объекте  по покупателю

Автор: Чернова Светлана Александровна
Дата создания: 11/29/05
Author: Svetlana Chernova
Creation date: 11/29/05

*/

define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-fact-order as decimal no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: calctur1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/calctur1.p $":U .
define variable vss-description as character no-undo init "Пересчет оборотов нарастающим итогом".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
define variable   v-sum-acc-base       as decimal   no-undo init 0 .
define variable   v-sum-acc-rubl       as decimal   no-undo init 0 .
define variable   v-sum-doc-base       as decimal   no-undo init 0 .
define variable   v-sum-doc-rubl       as decimal   no-undo init 0 .
define variable   v-sum-slt-acc-base   as decimal   no-undo init 0 .
define variable   v-sum-slt-acc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-slt-doc-base   as decimal   no-undo init 0 .
define variable   v-sum-slt-doc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-vat-acc-base   as decimal   no-undo init 0 .
define variable   v-sum-vat-acc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-vat-doc-base   as decimal   no-undo init 0 .
define variable   v-sum-vat-doc-rubl   as decimal   no-undo init 0 .
define variable   v-sum-qnty-doc       as decimal   no-undo init 0 .
define variable   v-sum-qnty-check     as decimal   no-undo init 0 .


run waitfram-show ( "Ждите..." ) .

define buffer buf_turnover-buyer      for ub.turnover-buyer  .
define buffer buf_turnover-buyer-main for ub.turnover-buyer-main  .
define buffer buf_turnover-buyer-gds  for ub.turnover-buyer-gds  .

find first buf_turnover-buyer no-lock where
    buf_turnover-buyer.cli-type  =  p-cli-type and
    buf_turnover-buyer.cli-code  =  p-cli-code and
    buf_turnover-buyer.obj-type  =  p-obj-type and
    buf_turnover-buyer.obj-code  =  p-obj-code and
    buf_turnover-buyer.fact-order < p-fact-order use-index clients no-error .
    if available buf_turnover-buyer then do:
    assign
        v-sum-acc-base      = buf_turnover-buyer.sum-acc-base-itog
        v-sum-acc-rubl      = buf_turnover-buyer.sum-acc-rubl-itog
        v-sum-doc-base      = buf_turnover-buyer.sum-doc-base-itog
        v-sum-doc-rubl      = buf_turnover-buyer.sum-doc-rubl-itog
        v-sum-slt-acc-base  = buf_turnover-buyer.sum-slt-acc-base-itog
        v-sum-slt-acc-rubl  = buf_turnover-buyer.sum-slt-acc-rubl-itog
        v-sum-slt-doc-base  = buf_turnover-buyer.sum-slt-doc-base-itog
        v-sum-slt-doc-rubl  = buf_turnover-buyer.sum-slt-doc-rubl-itog
        v-sum-vat-acc-base  = buf_turnover-buyer.sum-vat-acc-base-itog
        v-sum-vat-acc-rubl  = buf_turnover-buyer.sum-vat-acc-rubl-itog
        v-sum-vat-doc-base  = buf_turnover-buyer.sum-vat-doc-base-itog
        v-sum-vat-doc-rubl  = buf_turnover-buyer.sum-vat-doc-rubl-itog
        v-sum-qnty-doc      = buf_turnover-buyer.qnty-doc-itog
        v-sum-qnty-check    = buf_turnover-buyer.qnty-check-itog
    .
       if v-sum-qnty-doc      = ?  then v-sum-qnty-doc   = 0 .
       if v-sum-qnty-check    = ?  then v-sum-qnty-check = 0 .
    end.
    else do:
    assign
        v-sum-acc-base      = 0
        v-sum-acc-rubl      = 0
        v-sum-doc-base      = 0
        v-sum-doc-rubl      = 0
        v-sum-slt-acc-base  = 0
        v-sum-slt-acc-rubl  = 0
        v-sum-slt-doc-base  = 0
        v-sum-slt-doc-rubl  = 0
        v-sum-vat-acc-base  = 0
        v-sum-vat-acc-rubl  = 0
        v-sum-vat-doc-base  = 0
        v-sum-vat-doc-rubl  = 0
        v-sum-qnty-doc      = 0
        v-sum-qnty-check    = 0
    .

    end.

for each buf_turnover-buyer exclusive-lock where
    buf_turnover-buyer.cli-type  =  p-cli-type and
    buf_turnover-buyer.cli-code  =  p-cli-code and
    buf_turnover-buyer.obj-type  =  p-obj-type and
    buf_turnover-buyer.obj-code  =  p-obj-code and
    buf_turnover-buyer.fact-order >= p-fact-order
    break by fact-order :
      assign
        v-sum-acc-base     =  v-sum-acc-base     +  buf_turnover-buyer.sum-acc-base
        v-sum-acc-rubl     =  v-sum-acc-rubl     +  buf_turnover-buyer.sum-acc-rubl
        v-sum-doc-base     =  v-sum-doc-base     +  buf_turnover-buyer.sum-doc-base
        v-sum-doc-rubl     =  v-sum-doc-rubl     +  buf_turnover-buyer.sum-doc-rubl
        v-sum-slt-acc-base =  v-sum-slt-acc-base +  buf_turnover-buyer.sum-slt-acc-base
        v-sum-slt-acc-rubl =  v-sum-slt-acc-rubl +  buf_turnover-buyer.sum-slt-acc-rubl
        v-sum-slt-doc-base =  v-sum-slt-doc-base +  buf_turnover-buyer.sum-slt-doc-base
        v-sum-slt-doc-rubl =  v-sum-slt-doc-rubl +  buf_turnover-buyer.sum-slt-doc-rubl
        v-sum-vat-acc-base =  v-sum-vat-acc-base +  buf_turnover-buyer.sum-vat-acc-base
        v-sum-vat-acc-rubl =  v-sum-vat-acc-rubl +  buf_turnover-buyer.sum-vat-acc-rubl
        v-sum-vat-doc-base =  v-sum-vat-doc-base +  buf_turnover-buyer.sum-vat-doc-base
        v-sum-vat-doc-rubl =  v-sum-vat-doc-rubl +  buf_turnover-buyer.sum-vat-doc-rubl
        .
        if buf_turnover-buyer.doc-code   <> "" then v-sum-qnty-doc = v-sum-qnty-doc + 1.
        if buf_turnover-buyer.inkas-code <> "" then v-sum-qnty-check = v-sum-qnty-check + 1.

      assign
        buf_turnover-buyer.sum-acc-base-itog      = v-sum-acc-base
        buf_turnover-buyer.sum-acc-rubl-itog      = v-sum-acc-rubl
        buf_turnover-buyer.sum-doc-base-itog      = v-sum-doc-base
        buf_turnover-buyer.sum-doc-rubl-itog      = v-sum-doc-rubl
        buf_turnover-buyer.sum-slt-acc-base-itog  = v-sum-slt-acc-base
        buf_turnover-buyer.sum-slt-acc-rubl-itog  = v-sum-slt-acc-rubl
        buf_turnover-buyer.sum-slt-doc-base-itog  = v-sum-slt-doc-base
        buf_turnover-buyer.sum-slt-doc-rubl-itog  = v-sum-slt-doc-rubl
        buf_turnover-buyer.sum-vat-acc-base-itog  = v-sum-vat-acc-base
        buf_turnover-buyer.sum-vat-acc-rubl-itog  = v-sum-vat-acc-rubl
        buf_turnover-buyer.sum-vat-doc-base-itog  = v-sum-vat-doc-base
        buf_turnover-buyer.sum-vat-doc-rubl-itog  = v-sum-vat-doc-rubl
        buf_turnover-buyer.qnty-doc-itog          = v-sum-qnty-doc
        buf_turnover-buyer.qnty-check-itog        = v-sum-qnty-check
        .
end.
run waitfram-show ( "Пересчет по объекту ..." ) .

find first buf_turnover-buyer-main exclusive-lock where
      buf_turnover-buyer-main.cli-code     = p-cli-code  and
      buf_turnover-buyer-main.cli-type     = p-cli-type  and
      buf_turnover-buyer-main.obj-code     = p-obj-code  and
      buf_turnover-buyer-main.obj-type     = p-obj-type  no-error .
      if not available buf_turnover-buyer-main then  do:
         create buf_turnover-buyer-main .
      end.
      assign
        buf_turnover-buyer-main.cli-code     = p-cli-code
        buf_turnover-buyer-main.cli-type     = p-cli-type
        buf_turnover-buyer-main.obj-code     = p-obj-code
        buf_turnover-buyer-main.obj-type     = p-obj-type
        buf_turnover-buyer-main.obj-type     = p-obj-type
        buf_turnover-buyer-main.sum-acc-base-itog     =  v-sum-acc-base
        buf_turnover-buyer-main.sum-acc-rubl-itog     =  v-sum-acc-rubl
        buf_turnover-buyer-main.sum-doc-base-itog     =  v-sum-doc-base
        buf_turnover-buyer-main.sum-doc-rubl-itog     =  v-sum-doc-rubl
        buf_turnover-buyer-main.qnty-doc-itog   = v-sum-qnty-doc
        buf_turnover-buyer-main.qnty-check-itog = v-sum-qnty-check
      .


run waitfram-hide .