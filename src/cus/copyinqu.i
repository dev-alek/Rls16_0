/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

 опирование в запрос

јвтор: „ернова —ветлана јлександровна
ƒата создани€: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 08/04/04 3:03
{1}
*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}"  <> "" &then
run lib-trn_copy-inqu (
    input {1}      /*pardoc-code          */
  , input {2}      /*pardoc-type          */
  , input {3}      /*parstatus_           */
  , input {4}      /*parinternal          */
  , input {5}      /*parcli-type          */
  , input {6}      /*parcli-code          */
  , input {7}      /*pardiscnt-type       */
  , input {8}      /*partot-calc          */
  , input {9}      /*pardiscnt-pc         */
  , input {10}     /*paragnt              */
  , input {11}     /*parboss              */
  , input {12}     /*parwrkr              */
  , input {13}     /*parbase-rate         */
  , input {14}     /*parbase-scale        */
  , input {15}     /*parexch-code         */
  , input {16}     /*parvat-type          */
  , input {17}     /*pardstdoc-code       */
  , input {18}     /*parinp-discnt-type   */
  , input {19}     /*parinp-discnt-pc     */
  , input {20}     /*parinp-agnt          */
  , input {21}     /*parinp-boss          */
  , input {22}     /*parinp-wrkr          */
  , input {23}     /*parinp-base-rate     */
  , input {24}     /*parinp-base-scale    */
  , input {25}     /*parcash-pay          */
  , input {26}        /*parglob-base-code    */
  , input table {27}  /*table for tt-doc-line*/
  , input table {28}  /*table for tt-gds-dtl */
  , input table {29}  /*table for tt-parts   */
  , input {30}        /*paruse-parts         */
  , input {31}        /*parall-qnty          */
  , input {32}        /*parfix-price         */
  ) {33}.

&else
define temp-table tt-trn-doc  no-undo like ub.trn-doc.
define temp-table tt-doc-line no-undo like ub.doc-line
field cst-code like ub.trn-doc.cst-code
.
define temp-table tt-doc-line-attr no-undo like ub.doc-line-attr.
define temp-table tt-gds-dtl  no-undo like ub.gds-dtl.
define temp-table tt-parts    no-undo like ub.parts.

procedure lib-trn_copy-inqu :
/*ƒокумент источник*/
define input parameter pardoc-code    like ub.trn-doc.doc-code    no-undo.
define input parameter pardoc-type    like ub.trn-doc.doc-type    no-undo.
define input parameter parstatus_     like ub.trn-doc.status_     no-undo.
define input parameter parinternal    like ub.trn-doc.internal    no-undo.
define input parameter parcli-type    like ub.trn-doc.cli-type    no-undo.
define input parameter parcli-code    like ub.trn-doc.cli-code    no-undo.
define input parameter pardiscnt-type like ub.trn-doc.discnt-type no-undo.
define input parameter partot-calc    like ub.trn-doc.tot-calc    no-undo.
define input parameter pardiscnt-pc   like ub.trn-doc.discnt-pc   no-undo.
define input parameter paragnt        like ub.trn-doc.agnt        no-undo.
define input parameter parboss        like ub.trn-doc.boss        no-undo.
define input parameter parwrkr        like ub.trn-doc.wrkr        no-undo.
define input parameter parbase-rate   like ub.trn-doc.base-rate   no-undo.
define input parameter parbase-scale  like ub.trn-doc.base-scale  no-undo.
define input parameter parexch-code   like ub.trn-doc.exch-code   no-undo.
define input parameter parvat-type    like ub.trn-doc.vat-type    no-undo.
/*ƒокумент приемник*/
define input parameter pardstdoc-code     like ub.trn-doc.doc-code    no-undo.
define input parameter parinp-discnt-type as   logical                no-undo.
define input parameter parinp-discnt-pc   like ub.trn-doc.discnt-pc   no-undo.
define input parameter parinp-agnt        like ub.trn-doc.agnt        no-undo.
define input parameter parinp-boss        like ub.trn-doc.boss        no-undo.
define input parameter parinp-wrkr        like ub.trn-doc.wrkr        no-undo.
define input parameter parinp-base-rate   like ub.trn-doc.base-rate   no-undo.
define input parameter parinp-base-scale  like ub.trn-doc.base-scale  no-undo.
/*√лобальные параметры*/
define input parameter parcash-pay        like ub.sysconf.cash-pay    no-undo.
define input parameter parglob-base-code  like ub.sysconf.base-code   no-undo.
/*¬ременные таблицы*/
define input parameter table for tt-doc-line.
define input parameter table for tt-gds-dtl.
define input parameter table for tt-parts.
define input parameter paruse-parts       as   logical                no-undo.
define input parameter parall-qnty        as   logical                no-undo.
define input parameter parfix-price       as   logical                no-undo.

define buffer crt_trn-doc  for ub.trn-doc.
define buffer crt_goods    for ub.goods.
define buffer crt_doc-line for ub.doc-line.
define buffer crt_gds-dtl  for ub.gds-dtl.

define variable end-price    as   logical              no-undo. /* при возврате подставл€ть цену - скидка */
define variable real-type    like ub.goods.gds-type    no-undo.
define variable legal-node   like ub.gds-prt.node-code no-undo. /* код признака, в который копируетс€ gds-dtl, если призн-вкл -> призн-выкл или наоборот */
define variable chg-qnty     like ub.gds-dtl.fact-qnty no-undo.
define variable varchg-qnty  like ub.gds-dtl.fact-qnty no-undo.
define variable varfact-qnty like ub.gds-dtl.fact-qnty no-undo.
define variable g-log        as   logical              no-undo.
define variable mem-qnty like chg-qnty no-undo.
define variable dflt-cd as character no-undo .

c-l:
do on error undo, return error return-value :

find first crt_trn-doc where crt_trn-doc.doc-code = pardstdoc-code.
assign
    paruse-parts = false
    .

/* ссылка на исходный документ сохран€етс€ только при создании ¬Ќ на основании –Ќ */
assign
  end-price = no.

if parinp-discnt-type = yes and
   parinp-discnt-pc   = 0   and
   can-do ({&d-type-list}, pardiscnt-type)
   then do:
  assign
    crt_trn-doc.tot-calc    = partot-calc
    crt_trn-doc.discnt-pc   = pardiscnt-pc
    crt_trn-doc.discnt-type = pardiscnt-type.
end.

if parinp-agnt = ? then do:
  assign
    crt_trn-doc.agnt = paragnt.
end.
if parinp-boss = ? then do:
  assign
    crt_trn-doc.boss = parboss.
end.
if parinp-wrkr = ? then do:
  assign
    crt_trn-doc.wrkr = parwrkr.
end.

if parinp-base-rate  = ? then do:
  assign
    crt_trn-doc.base-rate  = parbase-rate.
end.
if parinp-base-scale = ? then do:
  assign
    crt_trn-doc.base-scale = parbase-scale.
end.
/* проверка на услуги (считаем, что в документе источнике и приемнике до этого все было однородно)*/
find first tt-doc-line where tt-doc-line.doc-code = pardoc-code no-lock no-error.
if available tt-doc-line then do:
  find crt_goods where crt_goods.artic     = tt-doc-line.artic
                   and crt_goods.prod-type = tt-doc-line.prod-type
                   and crt_goods.prod-code = tt-doc-line.prod-code no-lock.
  if crt_goods.gds-type = {&gds-office} and
     (crt_trn-doc.doc-type <> {&expense} or crt_trn-doc.internal) then do:
    return error "¬ данный документ нельз€ копировать услуги.".
  end.
  assign
    real-type = crt_goods.gds-type.
  find first crt_doc-line where crt_doc-line.doc-code = crt_trn-doc.doc-code no-lock no-error.
  if available crt_doc-line then do:
    find crt_goods where crt_goods.artic     = crt_doc-line.artic
                     and crt_goods.prod-type = crt_doc-line.prod-type
                     and crt_goods.prod-code = crt_doc-line.prod-code no-lock.
    if crt_goods.gds-type <> real-type then do:
      return error "”слуги и товары не могут быть добавлены в один и тот же документ.".
    end.
  end.
  else do:
    assign
      crt_trn-doc.office = (if real-type = {&gds-office} then yes else no).
  end.
end.
r-l:
for each tt-doc-line where tt-doc-line.doc-code = pardoc-code no-lock on error undo, return error return-value :
  find crt_goods where crt_goods.artic     = tt-doc-line.artic
                   and crt_goods.prod-type = tt-doc-line.prod-type
                   and crt_goods.prod-code = tt-doc-line.prod-code no-lock.


&scop proc-name lib-trn_crdoclno
{&run_proc_lib-trn}
   (
    input crt_trn-doc.doc-code
   ,input crt_trn-doc.obj-type
   ,input crt_trn-doc.obj-code
   ,input crt_goods.artic
   ,input crt_goods.prod-type
   ,input crt_goods.prod-code
   ,input crt_goods.gds-name
   ,input crt_goods.prt-root
   ,input ?
   ,input ?
   ,input parcash-pay      ) no-error.
  if error-status:error then do:
    undo c-l, return error return-value.
  end.
  if return-value = "next" then do:
    next r-l.
  end.
  find first crt_doc-line where crt_doc-line.doc-code  = crt_trn-doc.doc-code and
                                crt_doc-line.artic     = crt_goods.artic      and
                                crt_doc-line.prod-type = crt_goods.prod-type  and
                                crt_doc-line.prod-code = crt_goods.prod-code .
  for each tt-gds-dtl where tt-gds-dtl.prod-type = tt-doc-line.prod-type and
                            tt-gds-dtl.prod-code = tt-doc-line.prod-code and
                            tt-gds-dtl.artic     = tt-doc-line.artic     and
                            tt-gds-dtl.doc-code  = tt-doc-line.doc-code no-lock
                            break by tt-gds-dtl.artic
                                  by tt-gds-dtl.prod-type
                                  by tt-gds-dtl.prod-code
                            :
    { str/lgl-node.i
      tt-gds-dtl.artic
      tt-gds-dtl.prod-type
      tt-gds-dtl.prod-code
      tt-gds-dtl.prt-code
      tt-doc-line.obj-type
      tt-doc-line.obj-code
      legal-node
      no-error }
    if error-status:error then do:
       undo c-l, return error substitute ("&1 &2", return-value, error-status:get-message (1)).
    end.
    { str/crgdsdtl.i
       crt_trn-doc.obj-code
       crt_trn-doc.obj-type
       crt_trn-doc.doc-code
       crt_goods.artic
       crt_goods.prod-code
       crt_goods.prod-type
       legal-node
       yes
       no-error }
     if error-status:error then do:
        return error substitute ("ќшибка при создании признака &1.", return-value) .
     end.


     find first crt_gds-dtl where crt_gds-dtl.doc-code  = crt_trn-doc.doc-code and
                                  crt_gds-dtl.artic     = crt_goods.artic      and
                                  crt_gds-dtl.prod-code = crt_goods.prod-code  and
                                  crt_gds-dtl.prod-type = crt_goods.prod-type  and
                                  crt_gds-dtl.prt-code  = legal-node.
    assign
      /* фиксируем цену, либо будет подставлена текуща€ цена объекта */
      crt_gds-dtl.ov             = parfix-price
      crt_gds-dtl.price-base     = tt-gds-dtl.price-base
      crt_gds-dtl.price-rubl     = tt-gds-dtl.price-rubl
      crt_gds-dtl.new-price-sale = tt-gds-dtl.new-price-sale
      .
    if can-do ({&d-type-list}, pardiscnt-type) then do:
      assign
        crt_gds-dtl.discnt-base  = tt-gds-dtl.discnt-base
        crt_gds-dtl.discnt-rubl  = tt-gds-dtl.discnt-rubl
        crt_gds-dtl.discnt-pc    = tt-gds-dtl.discnt-pc
        crt_gds-dtl.discnt-type  = tt-gds-dtl.discnt-type.
    end.
    /* при возврате подставл€ем фикс. цены без скидки */
    if end-price then do:
      assign
        crt_gds-dtl.ov             = yes
        crt_gds-dtl.price-base     = tt-gds-dtl.price-base - tt-gds-dtl.discnt-base
        crt_gds-dtl.discnt-base    = 0
        crt_gds-dtl.price-rubl     = tt-gds-dtl.price-rubl - tt-gds-dtl.discnt-rubl
        crt_gds-dtl.discnt-rubl    = 0
        crt_gds-dtl.discnt-pc      = 0
        crt_gds-dtl.discnt-type    = yes.
    end.
    /* подстановка цены, в т.ч. возврат поставщику или перемещение по цене магазина */
        { str/set-pr.i recid(crt_gds-dtl) no ? no-error }
        if error-status:error then do:
          undo c-l, return error return-value.
        end.
    /* защита от вопросительных цен */
    if (crt_gds-dtl.price-rubl = ? or crt_gds-dtl.price-base = ?) and
       crt_gds-dtl.ov then do:
      undo c-l, return error "ѕри добавлении с фиксацией вз€тых из документа - источника цен требуетс€, чтобы ни одна из цен источника не была '?'. ƒобавл€йте с текущими ценами продажи или выберите другой источник.".
    end.
    if paruse-parts then do:
       if first-of (tt-gds-dtl.prod-code) then do:
         for each tt-parts :
           assign
             chg-qnty = tt-parts.fact-qnty
             mem-qnty = chg-qnty.
           assign
           crt_doc-line.doc-qnty  = crt_doc-line.doc-qnty + chg-qnty
           crt_doc-line.fact-qnty = crt_doc-line.doc-qnty.
         end.
         assign
           crt_gds-dtl.doc-qnty   = crt_gds-dtl.doc-qnty  + tt-gds-dtl.fact-qnty
           crt_gds-dtl.fact-qnty  = crt_gds-dtl.doc-qnty.
         /* считаем суммарное количество, которое удалось скопировать */
         assign
           varchg-qnty  = varchg-qnty  + tt-gds-dtl.fact-qnty
           varfact-qnty = varfact-qnty + tt-gds-dtl.fact-qnty.
         if crt_gds-dtl.doc-qnty = 0 then do:
           delete crt_gds-dtl.
         end.
       end.
    end. /*резервирование по парти€м*/
    else do:
      assign
        chg-qnty = tt-gds-dtl.fact-qnty
        mem-qnty = chg-qnty.

      assign
        crt_doc-line.doc-qnty  = crt_doc-line.doc-qnty + chg-qnty
        crt_gds-dtl.doc-qnty   = crt_gds-dtl.doc-qnty  + chg-qnty
        crt_gds-dtl.fact-qnty  = crt_gds-dtl.doc-qnty
        crt_doc-line.fact-qnty = crt_doc-line.doc-qnty.
      /* считаем суммарное количество, которое удалось скопировать */
      assign
      varchg-qnty  = varchg-qnty  + chg-qnty
      varfact-qnty = varfact-qnty + tt-gds-dtl.fact-qnty.
      if crt_gds-dtl.doc-qnty = 0 then do:
        delete crt_gds-dtl.
      end.
    end. /*резервирование по признакам*/
  end.
  if crt_doc-line.doc-qnty = 0 then do:
    delete crt_doc-line.
  end.
end.
end.
end procedure.

&endif

/* $Workfile$ e n d */