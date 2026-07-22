block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-calcwast.p $
$Archive: rep/r-calcwast.p $

Расет естественной убыли

Автор: Шальнев Иван Сергеевич
Дата создания: 17/05/11
Author: Shalnev ivan
Creation date: 17/05/11


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-calcwast.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-calcwast.p $":U .
define variable vss-description as character no-undo init "Расчет естественной убыли ".
{ cmp/vssrevis.i }

define input parameter parparentproc  as   widget-handle  no-undo .
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-date-out-type as character            no-undo.
define input parameter xclassify       as character            no-undo.
define input parameter xsorttype       as character            no-undo.

define temp-table tt-calcwast no-undo
field artic         like ub.goods.artic
field gds-name      like ub.goods.gds-name
field deficit       like ub.doc-line.fact-qnty /*format ">>>>9.999"*/
field wastage       as decimal /*format "99.99"*/
field price         like ub.doc-line.price-rubl /*format ">>>9.99"*/
field oborot        like ub.doc-line.doc-qnty /*format ">>>>9.999"*/
field allowed-wast  as decimal /*format ">>>9.999"*/
field over-wast     as decimal /*format ">>>9.999"*/
field all-wast-rubl as decimal /*format ">>>9.99"*/
field deficit-rubl  as decimal /*format ">>>9.99"*/
field grp-code      like ub.goods.grp-code
field grp-name      like ub.goods.grp-name
field prod-type     like ub.goods.prod-type
field prod-code     like ub.goods.prod-code
field prod-name     like ub.clients.obj-name
.

define buffer buf_goods   for ub.goods.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ot-line for ub.ot-line.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_clients for ub.clients.

define variable Counter1      as integer no-undo.
define variable v-sum-price   as decimal no-undo.
define variable v-sum-qnty    as decimal no-undo.
define variable v-sum-deficit as decimal no-undo.
define variable v-fact-order-start like ub.ot-line.fact-order.
define variable v-fact-order-end   like ub.ot-line.fact-order.
define variable zagolovok as character no-undo.
define variable znachenie as decimal no-undo.

&scop frame-name calcwastage

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i "new shared" }
{ trg/factord.i }
{ rep/r-sym.i    }
{ cmp/breakstr.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ cmp/r-page1.i  }

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
        sym1                       column-label ":!:!:"                                  format "X(1)"         space(0)
        tt-calcwast.artic          column-label "Артикул":C8                           format "X(8)"         space(0)
        sym2                       column-label ":!:!:"                                  format "X(1)"         space(0)
        tt-calcwast.gds-name       column-label "Название товара":C66                  format "x(66)"        space(0)
        sym3                       column-label ":!:!:"                                  format "X(1)"         space(0)
        tt-calcwast.deficit        column-label "Недостача,кг":C14                     format "->>>>>>>>9.999"    space(0)
        sym4                       column-label ":!:!:"                                  format "X(1)"         space(0)
        tt-calcwast.wastage        column-label "% ест.убыли":C12                       format "99.99"        space(0)
        sym5                       column-label ":!:!:"                                  format "X(1)"         space(0)
        tt-calcwast.price          column-label "Учетная цена":C14                     format "->>>>>>>>9.99"      space(0)
        sym6                       column-label ":!:!:"                                  format "X(1)"         space(0)
        tt-calcwast.oborot         column-label "Оборот,кг":C14                        format "->>>>>>>>9.999"    space(0)
        sym7                       column-label ":!:!:"                                  format "X(1)"         space(0)
        tt-calcwast.allowed-wast   column-label "Допустимая!ест.убыль,кг":C14            format "->>>>>>>>9.999"     space(0)
        sym8                       column-label ":!:!:"                                  format "X(1)"         space(0)
        tt-calcwast.over-wast      column-label "Превышение!допустимой!ест.убыли,кг":C14  format "->>>>>>>>9.999"     space(0)
        sym9                       column-label ":!:!:"                                  format "X(1)"         space(0)
        tt-calcwast.all-wast-rubl  column-label "Допустимая!ест.убыль,руб":C14           format "->>>>>>>>9.99"      space(0)
        sym10                      column-label ":!:!:"                                  format "X(1)"         space(0)
        tt-calcwast.deficit-rubl   column-label "Недостача,руб":C14                    format "->>>>>>>>9.99"      space(0)
        sym11                      column-label ":!:!:"                                  format "X(1)"         space(0)
HEADER
/* ....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+....C....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8....+....9....+.... */
"---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" SKIP
with width {&DOS_CW_2} down stream-io .

define frame itog
space(134) sym1 column-label ":" format "X(1)"
zagolovok format "X(44)" space(0)
sym2 column-label ":" format "X(1)" space(0)
znachenie format "->>>>>>>>9.99"      space(0)
with width {&DOS_CW_2} down stream-io no-label.

do:

  run prn-lib-open-stream  in this-procedure
    ( input parParentProc
    , input {&LS_PS_A4}
    , input yes /*p-is-stream*/
    , input no /*p-append*/
    ).
  run print-header.
  assign  Counter1 = 0 .
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
  assign
    v-sum-price  = 0
    v-sum-qnty   = 0
  .
  case x-date-out-type :
    when "calend-date" then do :
      run day-begin-fact-order(
          input x-Date-Start,
          output v-fact-order-start
          ).
      run factord-end-day(
          input x-Date-End,
          output v-fact-order-end
          ).
      for each gds-list no-lock :
          for each buf_ot-line
              where buf_ot-line.obj-type   = x-store-type
                and buf_ot-line.obj-code   = x-store-code
                and buf_ot-line.fact-order >= v-fact-order-start
                and buf_ot-line.fact-order <= v-fact-order-end
                and buf_ot-line.artic      = gds-list.artic
                and buf_ot-line.prod-code  = gds-list.prod-code
                and buf_ot-line.prod-type  = gds-list.prod-type
                and buf_ot-line.sum-type   = "cost"
                and (buf_ot-line.ext-doc-type = {&TDEDT_Inv}
                 or buf_ot-line.ext-doc-type = {&TDEDT_Ras_Perem}
                 or buf_ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh}
                 or buf_ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}) no-lock :
            if buf_ot-line.ext-doc-type = {&TDEDT_Inv} then do :
                assign
                  v-sum-deficit = v-sum-deficit - buf_ot-line.fact-qnty
                .
            end.
            else do :
              assign
                v-sum-price = v-sum-price - buf_ot-line.sum-rubl
                v-sum-qnty  = v-sum-qnty  - buf_ot-line.fact-qnty
              .
            end.
          end. /* each buf_ot-line */
          create tt-calcwast.
          assign
            tt-calcwast.artic    = gds-list.artic
            tt-calcwast.gds-name = gds-list.gds-name
            tt-calcwast.deficit  = if v-sum-deficit <> ? then v-sum-deficit else 0
            tt-calcwast.price    = if v-sum-price / v-sum-qnty <> ? then v-sum-price / v-sum-qnty else 0
            tt-calcwast.oborot   = if v-sum-qnty <> ? then v-sum-qnty else 0
          .
          find first buf_goods no-lock
               where buf_goods.gds-code = gds-list.gds-code no-error.
          if available buf_goods then do :
            assign
              tt-calcwast.wastage       = buf_goods.normal-wastage
              tt-calcwast.allowed-wast  = tt-calcwast.oborot * tt-calcwast.wastage / 100
              tt-calcwast.over-wast     = if tt-calcwast.deficit <= 0 then 0 else ( tt-calcwast.deficit - tt-calcwast.allowed-wast )
              tt-calcwast.all-wast-rubl = if tt-calcwast.deficit <= 0 then 0 else tt-calcwast.allowed-wast * tt-calcwast.price
              tt-calcwast.deficit-rubl  = tt-calcwast.deficit * tt-calcwast.price
              tt-calcwast.grp-code      = buf_goods.grp-code
              tt-calcwast.grp-name      = buf_goods.grp-name
              tt-calcwast.prod-code     = buf_goods.prod-code
              tt-calcwast.prod-type     = buf_goods.prod-type
            .
          end.
          find first buf_clients no-lock
              where buf_clients.obj-code = buf_goods.prod-code
                and buf_clients.obj-code = buf_goods.prod-code no-error.
          if available buf_clients then do :
            tt-calcwast.prod-name = buf_clients.obj-name.
          end.
          assign
            Counter1 = Counter1 + 1
            v-sum-price  = 0
            v-sum-qnty   = 0
            v-sum-deficit = 0
            .
          { rep/repfrm.i disp Counter1 }
      end.
    end.
    when "inv-to-date" then do :
      run factord-end-day(
          input x-Date-End,
          output v-fact-order-end
          ).

      for each gds-list no-lock :
        find last  buf_doc-line no-lock
             where buf_doc-line.obj-type = x-store-type
               and buf_doc-line.obj-code = x-store-code
               and buf_doc-line.artic      = gds-list.artic
               and buf_doc-line.prod-code  = gds-list.prod-code
               and buf_doc-line.prod-type  = gds-list.prod-type
               and buf_doc-line.ext-doc-type = {&TDEDT_Inv}
               and buf_doc-line.status_ = {&fact} no-error.
        if available buf_doc-line then do :
          assign
            v-fact-order-start = buf_doc-line.fact-order
          .
          for each buf_ot-line
              where buf_ot-line.obj-type   = x-store-type
                and buf_ot-line.obj-code   = x-store-code
                and buf_ot-line.fact-order > v-fact-order-start
                and buf_ot-line.fact-order <= v-fact-order-end
                and buf_ot-line.artic      = gds-list.artic
                and buf_ot-line.prod-code  = gds-list.prod-code
                and buf_ot-line.prod-type  = gds-list.prod-type
                and buf_ot-line.sum-type   = "cost"
                and (buf_ot-line.ext-doc-type = {&TDEDT_Inv}
                  or buf_ot-line.ext-doc-type = {&TDEDT_Ras_Perem}
                  or buf_ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh}
                  or buf_ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}) no-lock :
            if buf_ot-line.ext-doc-type = {&TDEDT_Inv} then do :
                assign
                  v-sum-deficit = v-sum-deficit - buf_ot-line.fact-qnty
                .
            end.
            else do :
              assign
                v-sum-price = v-sum-price - buf_ot-line.sum-rubl
                v-sum-qnty  = v-sum-qnty  - buf_ot-line.fact-qnty
              .
            end.
          end. /* each buf_ot-line */
        end.
        create tt-calcwast.
        assign
          tt-calcwast.artic    = gds-list.artic
          tt-calcwast.gds-name = gds-list.gds-name
          tt-calcwast.deficit  = if v-sum-deficit <> ? then v-sum-deficit else 0
          tt-calcwast.price    = if v-sum-price / v-sum-qnty <> ? then v-sum-price / v-sum-qnty else 0
          tt-calcwast.oborot   = if v-sum-qnty <> ? then v-sum-qnty else 0
        .
        find first buf_goods no-lock
              where buf_goods.gds-code = gds-list.gds-code no-error.
        if available buf_goods then do :
          assign
            tt-calcwast.wastage       = buf_goods.normal-wastage
            tt-calcwast.allowed-wast  = tt-calcwast.oborot * tt-calcwast.wastage / 100
            tt-calcwast.over-wast     = if tt-calcwast.deficit < 0 then 0 else ( tt-calcwast.deficit - tt-calcwast.allowed-wast )
            tt-calcwast.all-wast-rubl = if tt-calcwast.deficit <= 0 then 0 else tt-calcwast.allowed-wast * tt-calcwast.price
            tt-calcwast.deficit-rubl  = tt-calcwast.deficit * tt-calcwast.price
            tt-calcwast.grp-code      = buf_goods.grp-code
            tt-calcwast.grp-name      = buf_goods.grp-name
            tt-calcwast.prod-code     = buf_goods.prod-code
            tt-calcwast.prod-type     = buf_goods.prod-type
          .
        end.
        find first buf_clients no-lock
            where buf_clients.obj-code = buf_goods.prod-code
              and buf_clients.obj-code = buf_goods.prod-code no-error.
        if available buf_clients then do :
          tt-calcwast.prod-name = buf_clients.obj-name.
        end.
        assign
          Counter1 = Counter1 + 1
          v-sum-price  = 0
          v-sum-qnty   = 0
          v-sum-deficit = 0
          .
        { rep/repfrm.i disp Counter1 }
      end.
    end.
  end case.

  { rep/repfrm.i off }

  case xclassify :
    when "prod" then do :
      if xsorttype = "sort-article" then do :
        for each tt-calcwast break by tt-calcwast.prod-code by tt-calcwast.artic :
          accumulate tt-calcwast.deficit       (sub-total by tt-calcwast.prod-code).
          accumulate tt-calcwast.oborot        (sub-total by tt-calcwast.prod-code).
          accumulate tt-calcwast.allowed-wast  (sub-total by tt-calcwast.prod-code).
          accumulate tt-calcwast.over-wast     (sub-total by tt-calcwast.prod-code).
          accumulate tt-calcwast.all-wast-rubl (sub-total by tt-calcwast.prod-code).
          accumulate tt-calcwast.deficit-rubl  (sub-total by tt-calcwast.prod-code).

          accumulate tt-calcwast.deficit       (total).
          accumulate tt-calcwast.oborot        (total).
          accumulate tt-calcwast.allowed-wast  (total).
          accumulate tt-calcwast.over-wast     (total).
          accumulate tt-calcwast.all-wast-rubl (total).
          accumulate tt-calcwast.deficit-rubl  (total).

          if first-of (tt-calcwast.prod-code) then do :
            {&PutExcel}
                {&tabulation} "Производитель - " + tt-calcwast.prod-type + string(tt-calcwast.prod-code) + " " + tt-calcwast.prod-name
            skip.
            run print-prod (tt-calcwast.prod-type
                            ,tt-calcwast.prod-code
                            ,tt-calcwast.prod-name).
          end.
          run  print-line (input recid(tt-calcwast)).
          if last-of (tt-calcwast.prod-code) then do :
            {&PutExcel}
                {&tabulation} "Итоги по производителю" {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.deficit)
                                                       {&tabulation}
                                                       {&tabulation}
                                                       {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.oborot )
                                                       {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.allowed-wast)
                                                       {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.over-wast)
                                                       {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.all-wast-rubl)
                                                       {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.deficit-rubl)
            skip.
            run print-sub-total("Итоги по производителю",
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.deficit,
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.oborot,
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.allowed-wast,
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.over-wast,
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.all-wast-rubl,
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.deficit-rubl
                                ).
          end.
        end.
      end.
      else do :
        for each tt-calcwast break by tt-calcwast.prod-code by tt-calcwast.gds-name :
          accumulate tt-calcwast.deficit       (sub-total by tt-calcwast.prod-code).
          accumulate tt-calcwast.oborot        (sub-total by tt-calcwast.prod-code).
          accumulate tt-calcwast.allowed-wast  (sub-total by tt-calcwast.prod-code).
          accumulate tt-calcwast.over-wast     (sub-total by tt-calcwast.prod-code).
          accumulate tt-calcwast.all-wast-rubl (sub-total by tt-calcwast.prod-code).
          accumulate tt-calcwast.deficit-rubl  (sub-total by tt-calcwast.prod-code).

          accumulate tt-calcwast.deficit       (total).
          accumulate tt-calcwast.oborot        (total).
          accumulate tt-calcwast.allowed-wast  (total).
          accumulate tt-calcwast.over-wast     (total).
          accumulate tt-calcwast.all-wast-rubl (total).
          accumulate tt-calcwast.deficit-rubl  (total).

          if first-of (tt-calcwast.prod-code) then do:
            {&PutExcel}
                {&tabulation} "Производитель - " + tt-calcwast.prod-type + string(tt-calcwast.prod-code) + "" + tt-calcwast.prod-name
            skip.
            run print-prod ( tt-calcwast.prod-type
                            ,tt-calcwast.prod-code
                            ,tt-calcwast.prod-name).
          end.
          run  print-line (input recid(tt-calcwast)).
          if last-of (tt-calcwast.prod-code) then do :
            {&PutExcel}
                {&tabulation} "Итоги по производителю" {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.deficit)
                                                       {&tabulation}
                                                       {&tabulation}
                                                       {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.oborot )
                                                       {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.allowed-wast)
                                                       {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.over-wast)
                                                       {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.all-wast-rubl)
                                                       {&tabulation} (accum sub-total by tt-calcwast.prod-code tt-calcwast.deficit-rubl)
            skip.
            run print-sub-total("Итоги по производителю",
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.deficit,
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.oborot,
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.allowed-wast,
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.over-wast,
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.all-wast-rubl,
                                accum sub-total by tt-calcwast.prod-code tt-calcwast.deficit-rubl
                                ).
          end.
        end.
      end.
    end.
    when "grp-goods" then do :
      if xsorttype = "sort-article" then do :
        for each tt-calcwast break by tt-calcwast.grp-code by tt-calcwast.artic :
          accumulate tt-calcwast.deficit       (sub-total by tt-calcwast.grp-code).
          accumulate tt-calcwast.oborot        (sub-total by tt-calcwast.grp-code).
          accumulate tt-calcwast.allowed-wast  (sub-total by tt-calcwast.grp-code).
          accumulate tt-calcwast.over-wast     (sub-total by tt-calcwast.grp-code).
          accumulate tt-calcwast.all-wast-rubl (sub-total by tt-calcwast.grp-code).
          accumulate tt-calcwast.deficit-rubl  (sub-total by tt-calcwast.grp-code).

          accumulate tt-calcwast.deficit       (total).
          accumulate tt-calcwast.oborot        (total).
          accumulate tt-calcwast.allowed-wast  (total).
          accumulate tt-calcwast.over-wast     (total).
          accumulate tt-calcwast.all-wast-rubl (total).
          accumulate tt-calcwast.deficit-rubl  (total).

          if first-of (tt-calcwast.grp-code) then do :
            {&PutExcel}
                {&tabulation} "Группа товаров - " + tt-calcwast.grp-name
            skip.
            run print-grp (tt-calcwast.grp-name).
          end.
          run  print-line (input recid(tt-calcwast)).
          if last-of (tt-calcwast.grp-code) then do :
            {&PutExcel}
                {&tabulation} "Итоги по группе "       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.deficit)
                                                       {&tabulation}
                                                       {&tabulation}
                                                       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.oborot )
                                                       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.allowed-wast)
                                                       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.over-wast)
                                                       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.all-wast-rubl)
                                                       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.deficit-rubl)
            skip.
            run print-sub-total("Итоги по группе ",
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.deficit,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.oborot,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.allowed-wast,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.over-wast,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.all-wast-rubl,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.deficit-rubl
                              ).
          end.
        end.
      end.
      else do :
        for each tt-calcwast break by tt-calcwast.grp-code by tt-calcwast.gds-name :
          accumulate tt-calcwast.deficit       (sub-total by tt-calcwast.grp-code).
          accumulate tt-calcwast.oborot        (sub-total by tt-calcwast.grp-code).
          accumulate tt-calcwast.allowed-wast  (sub-total by tt-calcwast.grp-code).
          accumulate tt-calcwast.over-wast     (sub-total by tt-calcwast.grp-code).
          accumulate tt-calcwast.all-wast-rubl (sub-total by tt-calcwast.grp-code).
          accumulate tt-calcwast.deficit-rubl  (sub-total by tt-calcwast.grp-code).

          accumulate tt-calcwast.deficit       (total).
          accumulate tt-calcwast.oborot        (total).
          accumulate tt-calcwast.allowed-wast  (total).
          accumulate tt-calcwast.over-wast     (total).
          accumulate tt-calcwast.all-wast-rubl (total).
          accumulate tt-calcwast.deficit-rubl  (total).

          if first-of (tt-calcwast.grp-code) then do :
            {&PutExcel}
                {&tabulation} "Группа товаров - " + tt-calcwast.grp-name
            skip.
            run print-grp (tt-calcwast.grp-name).
          end.
          run  print-line (input recid(tt-calcwast)).
          if last-of (tt-calcwast.grp-code) then do :
            {&PutExcel}
                {&tabulation} "Итоги по группе "       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.deficit)
                                                       {&tabulation}
                                                       {&tabulation}
                                                       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.oborot )
                                                       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.allowed-wast)
                                                       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.over-wast)
                                                       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.all-wast-rubl)
                                                       {&tabulation} (accum sub-total by tt-calcwast.grp-code tt-calcwast.deficit-rubl)
            skip.
            run print-sub-total( "Итоги по группе " ,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.deficit,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.oborot,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.allowed-wast,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.over-wast,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.all-wast-rubl,
                                accum sub-total by tt-calcwast.grp-code tt-calcwast.deficit-rubl
                                ).
          end.
        end.
      end.
    end.
  end case.
  {&PutExcel}
      {&tabulation} "ИТОГО "       {&tabulation} (accum total tt-calcwast.deficit)
                                   {&tabulation}
                                   {&tabulation}
                                   {&tabulation} (accum total tt-calcwast.oborot )
                                   {&tabulation} (accum total tt-calcwast.allowed-wast)
                                   {&tabulation} (accum total tt-calcwast.over-wast)
                                   {&tabulation} (accum total tt-calcwast.all-wast-rubl)
                                   {&tabulation} (accum total tt-calcwast.deficit-rubl)
  skip.
  run print-sub-total( "ИТОГО",
                       accum total tt-calcwast.deficit,
                       accum total tt-calcwast.oborot ,
                       accum total tt-calcwast.allowed-wast ,
                       accum total tt-calcwast.over-wast ,
                       accum total tt-calcwast.all-wast-rubl,
                       accum total tt-calcwast.deficit-rubl
                     ).
  run print-podval(accum total tt-calcwast.deficit-rubl,
                   accum total tt-calcwast.all-wast-rubl
                  ).
  {&PutExcel}
     {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} "Недостача,руб"
     {&tabulation} {&tabulation} (accum total tt-calcwast.deficit-rubl) skip.
   {&PutExcel}
     {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} "Допустимая ест.убыль"
     {&tabulation} {&tabulation} (accum total tt-calcwast.all-wast-rubl) skip.
   {&PutExcel}
     {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} "Недостача с кор.учетом ест.убыли"
     {&tabulation} {&tabulation} ((accum total tt-calcwast.deficit-rubl) - (accum total tt-calcwast.all-wast-rubl)) skip.
  {&CloseExcel}
  output stream PrnLibStream close.
  { gbl/stopwork.i }
  run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
end.

/* **********************  Internal Procedures  *********************** */

procedure print-line :
  DEFINE  INPUT PARAMETER p-line-rec_id   AS RECID     NO-UNDO.
for tt-calcwast field ( artic
                        gds-name
                        deficit
                        wastage
                        price
                        oborot
                        allowed-wast
                        over-wast
                        all-wast-rubl
                        deficit-rubl ) where recid (tt-calcwast) = p-line-rec_id no-lock :

    {&PutExcel}
              tt-calcwast.artic              {&tabulation}
              tt-calcwast.gds-name           {&tabulation}
              tt-calcwast.deficit            {&tabulation}
              tt-calcwast.wastage            {&tabulation}
              tt-calcwast.price              {&tabulation}
              tt-calcwast.oborot             {&tabulation}
              tt-calcwast.allowed-wast       {&tabulation}
              tt-calcwast.over-wast          {&tabulation}
              tt-calcwast.all-wast-rubl      {&tabulation}
              tt-calcwast.deficit-rubl  {&tabulation}
    skip.
    display stream PrnLibStream sym1  tt-calcwast.artic
                                sym2  tt-calcwast.gds-name
                                sym3  tt-calcwast.deficit
                                sym4  tt-calcwast.wastage
                                sym5  tt-calcwast.price
                                sym6  tt-calcwast.oborot
                                sym7  tt-calcwast.allowed-wast
                                sym8  tt-calcwast.over-wast
                                sym9  tt-calcwast.all-wast-rubl
                                sym10 tt-calcwast.deficit-rubl
                                sym11 skip
    with frame {&FRAME-NAME} .
    down stream PrnLibStream with frame {&FRAME-NAME} .
end.
end. /*procedure print-line*/

procedure print-grp.
  define input parameter p-grp as character.
  form with frame {&FRAME-NAME}.
  display stream PrnLibStream sym1 "Группа товаров - " + p-grp @ tt-calcwast.gds-name sym11 with frame {&FRAME-NAME}.
  down stream PrnLibStream with frame {&FRAME-NAME} .
  put stream PrnLibStream unformatted "          ------------------------------------------------------------------- " .
end.

procedure print-prod.
  define input parameter p-prod-type as character.
  define input parameter p-prod-code as integer.
  define input parameter p-prod-name as character.
  form with frame {&FRAME-NAME}.
  display stream PrnLibStream sym1 "Производитель - " + p-prod-type + string(p-prod-code) + "" + p-prod-name @ tt-calcwast.gds-name sym11 with frame {&FRAME-NAME}.
  down stream PrnLibStream with frame {&FRAME-NAME} .
  put stream PrnLibStream unformatted "          ------------------------------------------------------------------- " .
end.

procedure print-sub-total.
  define input parameter p-str        as character.
  define input parameter p-st-deficit as decimal.
  define input parameter p-st-oborot  as decimal.
  define input parameter p-st-allowed-wast as decimal.
  define input parameter p-st-over-wast as decimal.
  define input parameter p-st-all-wast-rubl as decimal.
  define input parameter p-st-deficit-rubl as decimal.
  form with frame {&FRAME-NAME}.
  if p-str <> "ИТОГО" then put stream PrnLibStream unformatted "          ------------------------------------------------------------------- " .
  display stream PrnLibStream sym1 p-str @ tt-calcwast.gds-name
                              sym3 p-st-deficit @ tt-calcwast.deficit format "->>>>>>>>9.999"
                              sym6 p-st-oborot @ tt-calcwast.oborot format "->>>>>>>>9.999"
                              sym7 p-st-allowed-wast @ tt-calcwast.allowed-wast format "->>>>>>>9.999"
                              sym8 p-st-over-wast @ tt-calcwast.over-wast format "->>>>>>>9.999"
                              sym9 p-st-all-wast-rubl @ tt-calcwast.all-wast-rubl format "->>>>>>>9.99"
                              sym10 p-st-deficit-rubl @ tt-calcwast.deficit-rubl format "->>>>>>>9.99"
                              sym11  skip with frame {&FRAME-NAME}.
  down stream PrnLibStream with frame {&FRAME-NAME} .
  put stream PrnLibStream unformatted "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" .
end.

procedure print-header :
find first sheetf where sheet-num = 1 /*no-error*/.

    assign
    Sheetf.MergeCellsH = ""
    Sheetf.MergeCellsV = ""
    Sheetf.Excel-Column-Lable = "Артикул" + {&comma-char} +
                         "Название товара" + {&comma-char} +
                         "Недостача кг" + {&comma-char} +
                         "% ест.убыли" + {&comma-char} +
                         "Учетная цена" + {&comma-char} +
                         "Оборот кг" + {&comma-char} +
                         "Допустимая ест.убыль кг" + {&comma-char} +
                         "Превышение допустимой ест.убыль кг" + {&comma-char} +
                         "Допустимая ест.убыль руб" + {&comma-char} +
                         "Недостача руб"
    Sheetf.Sizes = "8,66,15,6,15,15,15,15,15,15"
    Sheetf.colformat = "1=@;2=@;3=0,000;4=0,00;5=0,00;6=0,000;7=0,000;8=0,000;9=0,00;10=0,00"
    .
  str2 = "" .
  RUN rep/extitle.p (1).
  put stream PrnLibStream unformatted
  reportNAme  + {&new-line}
              + str1 + str3 + str4 + {&new-line}
              + ReportHeader.

end. /*procedure print-header*/

procedure print-podval.
  define input parameter p-st-deficit-rubl as decimal.
  define input parameter p-st-all-wast-rubl as decimal.
  define variable v-line as character no-undo.
  assign
    v-line = "                                                                                                                                       ------------------------------------------------------------"
  .
  form with frame itog.
  display stream PrnLibStream sym1 "Недостача,руб" @ zagolovok
                              sym2 p-st-deficit-rubl @ znachenie
                              sym3 skip with frame itog.
  put stream PrnLibStream unformatted v-line.
  down stream PrnLibStream with frame itog.
  display stream PrnLibStream sym1 "Допустимая ест.убыль" @ zagolovok
                              sym2 p-st-all-wast-rubl @ znachenie
                              sym3 skip with frame itog.
  put stream PrnLibStream unformatted v-line.
  down stream PrnLibStream with frame itog.
  display stream PrnLibStream sym1 "Недостача с кор.учетом ест.убыли" @ zagolovok
                              sym2 (p-st-deficit-rubl - p-st-all-wast-rubl) @ znachenie
                              sym3 skip with frame itog.
  put stream PrnLibStream unformatted v-line.
  down stream PrnLibStream with frame itog.
end.  /*procedure print-podval*/