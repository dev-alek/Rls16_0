/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд для Библиотека процедур по работе с информационными таблицами trn-doc-sum doc-line-sum

Автор: Чернова Светлана Александровна
Дата создания: 11/09/06
Author: Svetlana Chernova
Creation date: 11/09/06

create: Суслов Алексей Юрьевич
Дата создания: 04/03/02

*/

assign
  varwast-sum-sale-base-line = 0
  varwast-sum-sale-rubl-line = 0
  varwast-fact-qnty-line     = 0
  varwast-cli-qnty-line      = 0
  varwast-sum-base-line      = 0
  varwast-sum-rubl-line      = 0
  .
 if {3} then do: /*по топливу*/
   for each wast-exp-line where wast-exp-line.obj-type  = tt-wast-line.obj-type  and
                                wast-exp-line.obj-code  = tt-wast-line.obj-code  and
                                wast-exp-line.prod-type = tt-wast-line.prod-type and
                                wast-exp-line.prod-code = tt-wast-line.prod-code and
                                wast-exp-line.artic     = tt-wast-line.artic     and
                                wast-exp-line.status_   = {&fact}
                                &IF "{1}" <> "0" &THEN                           and
                                wast-exp-line.fact-order > {1}
                                &ENDIF
                                &IF "{2}" <> "0" &THEN                           and
                                wast-exp-line.fact-order < {2}
                                &ENDIF
                                no-lock ,
              first wast-exp-doc where  wast-exp-doc.obj-type       = wast-exp-line.obj-type  and
                                        wast-exp-doc.obj-code       = wast-exp-line.obj-code  and
                                        wast-exp-doc.doc-code       = wast-exp-line.doc-code  and
                                        wast-exp-doc.internal       = no                      and
                                        wast-exp-doc.doc-type       = {&income}               and
                                        wast-exp-doc.is-del         = false                   and
                                        wast-exp-doc.ext-doc-type   = {&TDEDT_Pri_Vnesh}
                                        and (not can-find (first buf_sale-doc
                                                           where buf_sale-doc.doc-code = wast-exp-doc.doc-code
                                                             and buf_sale-doc.doc-kind = {&sale-add2-in-tech-refuell}))
                                        or
                                        wast-exp-doc.obj-type       = wast-exp-line.obj-type  and
                                        wast-exp-doc.obj-code       = wast-exp-line.obj-code  and
                                        wast-exp-doc.doc-code       = wast-exp-line.doc-code  and
                                        wast-exp-doc.internal       = no                      and
                                        wast-exp-doc.doc-type       = {&expense}              and
                                        wast-exp-doc.ext-doc-type   = {&TDEDT_Ras_Vnesh_VP}   and
                                        wast-exp-doc.is-del         = false
                                        no-lock on error undo, return error return-value :

    /* Если ведем перерасчет по закрытому документу, то нужно проверить не лежат ли реализации после нашей инвентаризации */
    if wast-exp-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
      assign v-sign = 1.
    end.
    else do:
      assign v-sign = -1.
    end.

    assign
      varwast-sum-sale-base = 0
      varwast-sum-sale-rubl = 0.
    for each wast-exp-gds-dtl where wast-exp-gds-dtl.doc-code  = wast-exp-line.doc-code  and
                                    wast-exp-gds-dtl.artic     = wast-exp-line.artic     and
                                    wast-exp-gds-dtl.prod-type = wast-exp-line.prod-type and
                                    wast-exp-gds-dtl.prod-code = wast-exp-line.prod-code no-lock :
      assign
        varwast-sum-sale-base = varwast-sum-sale-base + (wast-exp-gds-dtl.price-base - wast-exp-gds-dtl.discnt-base) * wast-exp-gds-dtl.fact-qnty
        varwast-sum-sale-rubl = varwast-sum-sale-rubl + (wast-exp-gds-dtl.price-rubl - wast-exp-gds-dtl.discnt-rubl) * wast-exp-gds-dtl.fact-qnty
      .
    end.
    assign
      varwast-fact-qnty-line     = varwast-fact-qnty-line     + wast-exp-line.fact-qnty * v-sign
      varwast-cli-qnty-line      = varwast-cli-qnty-line      + wast-exp-line.cli-qnty  * v-sign
      varwast-sum-sale-base-line = varwast-sum-sale-base-line + varwast-sum-sale-base   * v-sign
      varwast-sum-sale-rubl-line = varwast-sum-sale-rubl-line + varwast-sum-sale-rubl   * v-sign
      varwast-sum-base-line      = varwast-sum-base-line      + wast-exp-line.fact-qnty * wast-exp-line.price-base * v-sign
      varwast-sum-rubl-line      = varwast-sum-rubl-line      + wast-exp-line.fact-qnty * wast-exp-line.price-rubl * v-sign
      .
  end.
 end.
 else do: /*по товарам*/
  for each wast-exp-line where wast-exp-line.obj-type  = tt-wast-line.obj-type  and
                                wast-exp-line.obj-code  = tt-wast-line.obj-code  and
                                wast-exp-line.prod-type = tt-wast-line.prod-type and
                                wast-exp-line.prod-code = tt-wast-line.prod-code and
                                wast-exp-line.artic     = tt-wast-line.artic     and
                                wast-exp-line.status_   = {&fact}
                                &IF "{1}" <> "0" &THEN                           and
                                wast-exp-line.fact-order > {1}
                                &ENDIF
                                &IF "{2}" <> "0" &THEN                           and
                                wast-exp-line.fact-order < {2}
                                &ENDIF
                                no-lock ,
              first wast-exp-doc where  wast-exp-doc.obj-type       = wast-exp-line.obj-type  and
                                        wast-exp-doc.obj-code       = wast-exp-line.obj-code  and
                                        wast-exp-doc.doc-code       = wast-exp-line.doc-code  and
                                        wast-exp-doc.internal       = no                      and
                                        wast-exp-doc.doc-type       = {&expense}              and
                                        wast-exp-doc.is-del         = false                   and
                                        wast-exp-doc.ext-doc-type   = {&TDEDT_Ras_Vnesh}      or
                                        wast-exp-doc.obj-type       = wast-exp-line.obj-type  and
                                        wast-exp-doc.obj-code       = wast-exp-line.obj-code  and
                                        wast-exp-doc.doc-code       = wast-exp-line.doc-code  and
                                        wast-exp-doc.internal       = no                      and
                                        wast-exp-doc.doc-type       = {&expense}              and
                                        wast-exp-doc.ext-doc-type   = {&TDEDT_Ras_Vnesh_Kass} and
                                        wast-exp-doc.is-del         = false
                                        no-lock on error undo, return error return-value :

    /* Если ведем перерасчет по закрытому документу, то нужно проверить не лежат ли реализации после нашей инвентаризации */
    assign
      varwast-sum-sale-base = 0
      varwast-sum-sale-rubl = 0.
    for each wast-exp-gds-dtl where wast-exp-gds-dtl.doc-code  = wast-exp-line.doc-code  and
                                    wast-exp-gds-dtl.artic     = wast-exp-line.artic     and
                                    wast-exp-gds-dtl.prod-type = wast-exp-line.prod-type and
                                    wast-exp-gds-dtl.prod-code = wast-exp-line.prod-code no-lock :
      assign
        varwast-sum-sale-base = varwast-sum-sale-base + (wast-exp-gds-dtl.price-base - wast-exp-gds-dtl.discnt-base) * wast-exp-gds-dtl.fact-qnty
        varwast-sum-sale-rubl = varwast-sum-sale-rubl + (wast-exp-gds-dtl.price-rubl - wast-exp-gds-dtl.discnt-rubl) * wast-exp-gds-dtl.fact-qnty.
    end.
    assign
      varwast-fact-qnty-line     = varwast-fact-qnty-line     + wast-exp-line.fact-qnty
      varwast-cli-qnty-line      = varwast-cli-qnty-line      + wast-exp-line.cli-qnty
      varwast-sum-sale-base-line = varwast-sum-sale-base-line + varwast-sum-sale-base
      varwast-sum-sale-rubl-line = varwast-sum-sale-rubl-line + varwast-sum-sale-rubl
      varwast-sum-base-line      = varwast-sum-base-line      + wast-exp-line.fact-qnty * wast-exp-line.price-base
      varwast-sum-rubl-line      = varwast-sum-rubl-line      + wast-exp-line.fact-qnty * wast-exp-line.price-rubl
      .
  end.
 end.

/* $Workfile$   E n d */