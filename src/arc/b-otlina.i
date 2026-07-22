/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тело b-otlina.w

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create Суслов Алексей Юрьевич

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FOR EACH tt-clients,
    EACH tt-goods,
    EACH ub.ot-line WHERE
         ub.ot-line.obj-code   = tt-clients.obj-code and
         ub.ot-line.obj-type   = tt-clients.obj-type and
         ub.ot-line.artic      = tt-goods.artic      and
         ub.ot-line.prod-type  = tt-goods.prod-type  and
         ub.ot-line.prod-code  = tt-goods.prod-code  and
         ub.ot-line.fact-order > fact-order-min      and
         ub.ot-line.fact-order <= fact-order-max
         {&prep-sum-type}
         {&prep-ext-doc-type} NO-LOCK:
    if ub.ot-line.sum-type begins {&arh-cost}         and ub.ot-line.cat-id <> {&root-cat-id} then next.
    if ub.ot-line.sum-type begins {&arh-cost-service} and ub.ot-line.cat-id <> {&root-cat-id} then next.
    FIND FIRST ub.trn-doc   WHERE ub.trn-doc.doc-code  = ub.ot-line.doc-code NO-LOCK NO-ERROR.
    FIND FIRST ub.price-doc WHERE ub.price-doc.doc-num = ub.ot-line.doc-code NO-LOCK NO-ERROR.
    IF AVAILABLE ub.trn-doc THEN
       FIND FIRST ot-full WHERE ot-full.doc-code = ub.trn-doc.doc-code NO-ERROR.
    ELSE
       FIND FIRST ot-full WHERE ot-full.doc-code = ub.price-doc.doc-num NO-ERROR.
    IF NOT AVAILABLE ot-full THEN DO:
       CREATE ot-full.
       ASSIGN
       ot-full.doc-code     = ub.ot-line.doc-code
       ot-full.doc-type     = (if available ub.trn-doc then ub.trn-doc.doc-code else " ")
       ot-full.cli-type     = (if available ub.trn-doc then ub.trn-doc.cli-type else " ")
       ot-full.cli-code     = (if available ub.trn-doc then ub.trn-doc.cli-code else 0)
       ot-full.artic        = tt-goods.artic
       ot-full.prod-type    = tt-goods.prod-type
       ot-full.prod-code    = tt-goods.prod-code
       ot-full.gds-type     = tt-goods.gds-type
       ot-full.obj-type     = tt-clients.obj-type
       ot-full.obj-code     = tt-clients.obj-code
       ot-full.fact-date    = (if available ub.trn-doc then ub.trn-doc.fact-date else ub.price-doc.fact-date)
       ot-full.fact-order   = (if available ub.trn-doc then ub.trn-doc.fact-order else ub.price-doc.fact-order)
       ot-full.ext-doc-type = ub.ot-line.ext-doc-type.
       ot-full.ext-doc-type-full =  entry(lookup(ot-full.ext-doc-type, {&tdedt_list}), {&tdedt_list-full}).
       if available ub.trn-doc then do:
          find  ub.clients where  ub.clients.obj-type = ub.trn-doc.cli-type and
                              ub.clients.obj-code = ub.trn-doc.cli-code no-lock.
          assign ot-full.cli-name =  ub.clients.obj-name.
       end.
       else ot-full.cli-name = " ".
    END.
    if ot-full.gds-type = {&gds-office} then do:
      CASE ub.ot-line.sum-type:
         WHEN {&arh-cost-service} THEN DO:
           if g-cost then
              ASSIGN
              ot-full.sum-base       = ot-full.sum-base       + ub.ot-line.sum-base
              ot-full.sum-rubl       = ot-full.sum-rubl       + ub.ot-line.sum-rubl
              ot-full.vat-base       = ot-full.vat-base       + ub.ot-line.vat-base
              ot-full.vat-rubl       = ot-full.vat-rubl       + ub.ot-line.vat-rubl
              ot-full.slt-base       = ot-full.slt-base       + ub.ot-line.slt-base
              ot-full.slt-rubl       = ot-full.slt-rubl       + ub.ot-line.slt-rubl
              ot-full.excise-base    = ot-full.excise-base    + ub.ot-line.excise-base
              ot-full.excise-rubl    = ot-full.excise-rubl    + ub.ot-line.excise-rubl
              ot-full.road-tax-base  = ot-full.road-tax-base  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl  = ot-full.road-tax-rubl  + ub.ot-line.road-tax-rubl
              ot-full.transport-base = ot-full.transport-base + ub.ot-line.transport-base
              ot-full.transport-rubl = ot-full.transport-rubl + ub.ot-line.transport-rubl
              ot-full.other-base     = ot-full.other-base     + ub.ot-line.other-base
              ot-full.other-rubl     = ot-full.other-rubl     + ub.ot-line.other-rubl.
           else
              ASSIGN
              ot-full.sum-base       = ?
              ot-full.sum-rubl       = ?
              ot-full.vat-base       = ?
              ot-full.vat-rubl       = ?
              ot-full.slt-base       = ?
              ot-full.slt-rubl       = ?
              ot-full.excise-base    = ?
              ot-full.excise-rubl    = ?
              ot-full.road-tax-base  = ?
              ot-full.road-tax-rubl  = ?
              ot-full.transport-base = ?
              ot-full.transport-rubl = ?
              ot-full.other-base     = ?
              ot-full.other-rubl     = ?.
         END. /*arh-cost-service*/
         WHEN {&arh-sale-service} THEN DO:
              assign ot-full.fact-qnty = ot-full.fact-qnty + ub.ot-line.fact-qnty.
              ASSIGN
              ot-full.sum-base-doc       = ot-full.sum-base-doc       + ub.ot-line.sum-base
              ot-full.sum-rubl-doc       = ot-full.sum-rubl-doc       + ub.ot-line.sum-rubl
              ot-full.vat-base-doc       = ot-full.vat-base-doc       + ub.ot-line.vat-base
              ot-full.vat-rubl-doc       = ot-full.vat-rubl-doc       + ub.ot-line.vat-rubl
              ot-full.slt-base-doc       = ot-full.slt-base-doc       + ub.ot-line.slt-base
              ot-full.slt-rubl-doc       = ot-full.slt-rubl-doc       + ub.ot-line.slt-rubl
              ot-full.excise-base-doc    = ot-full.excise-base-doc    + ub.ot-line.excise-base
              ot-full.excise-rubl-doc    = ot-full.excise-rubl-doc    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-doc  = ot-full.road-tax-base-doc  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-doc  = ot-full.road-tax-rubl-doc  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-doc = ot-full.transport-base-doc + ub.ot-line.transport-base
              ot-full.transport-rubl-doc = ot-full.transport-rubl-doc + ub.ot-line.transport-rubl
              ot-full.other-base-doc     = ot-full.other-base-doc     + ub.ot-line.other-base
              ot-full.other-rubl-doc     = ot-full.other-rubl-doc     + ub.ot-line.other-rubl.
         END. /*arh-sale-service*/
         WHEN {&arh-crsa-service} THEN DO:
              ASSIGN
              ot-full.sum-base-sale       = ot-full.sum-base-sale       + ub.ot-line.sum-base
              ot-full.sum-rubl-sale       = ot-full.sum-rubl-sale       + ub.ot-line.sum-rubl
              ot-full.vat-base-sale       = ot-full.vat-base-sale       + ub.ot-line.vat-base
              ot-full.vat-rubl-sale       = ot-full.vat-rubl-sale       + ub.ot-line.vat-rubl
              ot-full.slt-base-sale       = ot-full.slt-base-sale       + ub.ot-line.slt-base
              ot-full.slt-rubl-sale       = ot-full.slt-rubl-sale       + ub.ot-line.slt-rubl
              ot-full.excise-base-sale    = ot-full.excise-base-sale    + ub.ot-line.excise-base
              ot-full.excise-rubl-sale    = ot-full.excise-rubl-sale    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-sale  = ot-full.road-tax-base-sale  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-sale  = ot-full.road-tax-rubl-sale  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-sale = ot-full.transport-base-sale + ub.ot-line.transport-base
              ot-full.transport-rubl-sale = ot-full.transport-rubl-sale + ub.ot-line.transport-rubl
              ot-full.other-base-sale     = ot-full.other-base-sale     + ub.ot-line.other-base
              ot-full.other-rubl-sale     = ot-full.other-rubl-sale     + ub.ot-line.other-rubl .
         END.  /*arh-crsa-service*/
         OTHERWISE DO:
           message "Некорректный sum-type " ub.ot-line.sum-type " при просмотре архива(b-otlina.w)." skip
                   "Ошибка в расчетах."
                   view-as alert-box error.
         END. /*otherwise*/
      END CASE.
    end.
    else do:
      CASE ub.ot-line.sum-type:
         WHEN {&arh-cost} THEN DO:
           assign ot-full.fact-qnty = ot-full.fact-qnty + ub.ot-line.fact-qnty.
           if g-cost then
              ASSIGN
              ot-full.sum-base       = ot-full.sum-base       + ub.ot-line.sum-base
              ot-full.sum-rubl       = ot-full.sum-rubl       + ub.ot-line.sum-rubl
              ot-full.vat-base       = ot-full.vat-base       + ub.ot-line.vat-base
              ot-full.vat-rubl       = ot-full.vat-rubl       + ub.ot-line.vat-rubl
              ot-full.slt-base       = ot-full.slt-base       + ub.ot-line.slt-base
              ot-full.slt-rubl       = ot-full.slt-rubl       + ub.ot-line.slt-rubl
              ot-full.excise-base    = ot-full.excise-base    + ub.ot-line.excise-base
              ot-full.excise-rubl    = ot-full.excise-rubl    + ub.ot-line.excise-rubl
              ot-full.road-tax-base  = ot-full.road-tax-base  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl  = ot-full.road-tax-rubl  + ub.ot-line.road-tax-rubl
              ot-full.transport-base = ot-full.transport-base + ub.ot-line.transport-base
              ot-full.transport-rubl = ot-full.transport-rubl + ub.ot-line.transport-rubl
              ot-full.other-base     = ot-full.other-base     + ub.ot-line.other-base
              ot-full.other-rubl     = ot-full.other-rubl     + ub.ot-line.other-rubl.
           else
              ASSIGN
              ot-full.sum-base       = ?
              ot-full.sum-rubl       = ?
              ot-full.vat-base       = ?
              ot-full.vat-rubl       = ?
              ot-full.slt-base       = ?
              ot-full.slt-rubl       = ?
              ot-full.excise-base    = ?
              ot-full.excise-rubl    = ?
              ot-full.road-tax-base  = ?
              ot-full.road-tax-rubl  = ?
              ot-full.transport-base = ?
              ot-full.transport-rubl = ?
              ot-full.other-base     = ?
              ot-full.other-rubl     = ?.
         END. /*arh-cost*/
         WHEN {&arh-sale} THEN DO:
              ASSIGN
              ot-full.sum-base-doc       = ot-full.sum-base-doc       + ub.ot-line.sum-base
              ot-full.sum-rubl-doc       = ot-full.sum-rubl-doc       + ub.ot-line.sum-rubl
              ot-full.vat-base-doc       = ot-full.vat-base-doc       + ub.ot-line.vat-base
              ot-full.vat-rubl-doc       = ot-full.vat-rubl-doc       + ub.ot-line.vat-rubl
              ot-full.slt-base-doc       = ot-full.slt-base-doc       + ub.ot-line.slt-base
              ot-full.slt-rubl-doc       = ot-full.slt-rubl-doc       + ub.ot-line.slt-rubl
              ot-full.excise-base-doc    = ot-full.excise-base-doc    + ub.ot-line.excise-base
              ot-full.excise-rubl-doc    = ot-full.excise-rubl-doc    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-doc  = ot-full.road-tax-base-doc  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-doc  = ot-full.road-tax-rubl-doc  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-doc = ot-full.transport-base-doc + ub.ot-line.transport-base
              ot-full.transport-rubl-doc = ot-full.transport-rubl-doc + ub.ot-line.transport-rubl
              ot-full.other-base-doc     = ot-full.other-base-doc     + ub.ot-line.other-base
              ot-full.other-rubl-doc     = ot-full.other-rubl-doc     + ub.ot-line.other-rubl.
         END. /*arh-sale*/
         WHEN {&arh-crsa} THEN DO:
              ASSIGN
              ot-full.sum-base-sale       = ot-full.sum-base-sale       + ub.ot-line.sum-base
              ot-full.sum-rubl-sale       = ot-full.sum-rubl-sale       + ub.ot-line.sum-rubl
              ot-full.vat-base-sale       = ot-full.vat-base-sale       + ub.ot-line.vat-base
              ot-full.vat-rubl-sale       = ot-full.vat-rubl-sale       + ub.ot-line.vat-rubl
              ot-full.slt-base-sale       = ot-full.slt-base-sale       + ub.ot-line.slt-base
              ot-full.slt-rubl-sale       = ot-full.slt-rubl-sale       + ub.ot-line.slt-rubl
              ot-full.excise-base-sale    = ot-full.excise-base-sale    + ub.ot-line.excise-base
              ot-full.excise-rubl-sale    = ot-full.excise-rubl-sale    + ub.ot-line.excise-rubl
              ot-full.road-tax-base-sale  = ot-full.road-tax-base-sale  + ub.ot-line.road-tax-base
              ot-full.road-tax-rubl-sale  = ot-full.road-tax-rubl-sale  + ub.ot-line.road-tax-rubl
              ot-full.transport-base-sale = ot-full.transport-base-sale + ub.ot-line.transport-base
              ot-full.transport-rubl-sale = ot-full.transport-rubl-sale + ub.ot-line.transport-rubl
              ot-full.other-base-sale     = ot-full.other-base-sale     + ub.ot-line.other-base
              ot-full.other-rubl-sale     = ot-full.other-rubl-sale     + ub.ot-line.other-rubl .
         END.  /*arh-crsa*/
         OTHERWISE DO:
           message "Некорректный sum-type " ub.ot-line.sum-type " при просмотре архива(b-otlina.w)." skip
                   "Ошибка в расчетах."
                   view-as alert-box error.
         END. /*otherwise*/
      END CASE.
    end.
END.
/* Workfile: b - o t l i n a . i  e n d*/