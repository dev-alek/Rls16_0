block-level on error undo, throw.
/*

$Revision: e470dcf1e011, 295, rls $
$Author: SSlivenko $
$Date: Tue Dec 01 19:11:38 2015 +0300 $
$Workfile: ord-trn.p $
$Archive: cus/ord-trn.p $

Формирование накладной из поставки

Автор: Чернова Светлана Александровна
Дата создания: 20/05/02
Author: Svetlana Chernova
Creation date: 20/05/02

Внешний приход
Внутренний расход
Внешний расход
*/
define input  parameter parParentProc   as widget-handle no-undo.
define input  parameter tp-rec as recid no-undo . /* поставка */
define input  parameter p-allow-chain-trn-qnty as logical no-undo . /*учитывать количества из привязанных накладных*/

define variable vss-revision    as character no-undo init "$Revision: e470dcf1e011, 295, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:38 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-trn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-trn.p $":U .
define variable vss-description as character no-undo init "Формирование накладной из поставки".
{ cmp/vssrevis.i }
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: ord-trn.p $ $Revision: e470dcf1e011, 295, rls $".

{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ str/lib-def.i  }
{ cmp/df-sub.i   }
{ str/doc-code.i }
{ gbl/waitfram.i }
{ cus/ord-lib.i create-chain }
{ str/trdcalib.i }

define temp-table tt-trn-doc  no-undo like ub.trn-doc.
define temp-table tt-doc-line no-undo like ub.doc-line.
define temp-table tt2-doc-line      no-undo like lib-trn_ret-line.
define temp-table tt-doc-line-attr no-undo like ub.doc-line-attr.
define temp-table tt-gds-dtl  no-undo like ub.gds-dtl.
define temp-table tt-parts    no-undo like ub.parts.

define buffer ttt_ord-doc-rcv  for ub.ord-doc-rcv.
define buffer ttt_ord-line-rcv for ub.ord-line-rcv.
define buffer ttt_ord-dtl-rcv  for ub.ord-dtl-rcv.
define buffer bf_ord-chain     for ub.ord-chain.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_doc-line      for ub.doc-line.
define buffer bf_ord-rcv-attr  for ub.ord-rcv-attr.

define buffer new_trn-doc  for ub.trn-doc  .
define buffer new_doc-line for ub.doc-line .
define buffer new_gds-dtl  for ub.gds-dtl .

define buffer t_trn-doc  for ub.trn-doc  .
define buffer t_doc-line for ub.doc-line .
define buffer t_gds-dtl  for ub.gds-dtl .
define buffer t_goods    for ub.goods .

define variable kkk  as integer no-undo .
define variable p-q  like ub.ord-dtl-rcv.qnty no-undo .
define variable v-contract-code as integer no-undo .
define variable v-purch-code as integer   no-undo .
define variable v-purch-code-name as character no-undo .
define variable v-host-code as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable v-price-base as decimal   no-undo init 0.
define variable v-price-cli  as decimal   no-undo init 0.
define variable v-price-rubl as decimal   no-undo init 0.
define variable v-cli-qnty   as decimal   no-undo .
define variable v-doc-qnty   as decimal   no-undo .
define variable v-fact-qnty  as decimal   no-undo .

define variable v-out-pay-str as character no-undo .
define variable v-out-pay-type as character no-undo .
define variable g#cash-pay as integer   no-undo .
define variable g#out-pay as integer   no-undo .
define variable v-base-code as integer   no-undo .
define variable v-ps        as character no-undo .
define variable v-Ok       as logical   no-undo .
define variable v-mess as character no-undo .
define variable v-event-code as character no-undo .



define buffer buf_ord-doc for ub.ord-doc .
define buffer buf_sysconf for ub.sysconf  .

find first  ttt_ord-doc-rcv where recid ( ttt_ord-doc-rcv) = tp-rec no-lock no-error .
  if not avail ttt_ord-doc-rcv then return error.


assign
  store-type    = ttt_ord-doc-rcv.obj-type
  store-code    = ttt_ord-doc-rcv.obj-code
.
  { gbl/hostcode.i
    ttt_ord-doc-rcv.obj-type
    ttt_ord-doc-rcv.obj-code
    v-host-code
  }

  { gbl/curobjdt.i
    ttt_ord-doc-rcv.obj-type
    ttt_ord-doc-rcv.obj-code
    to-day
  }

  { gbl/objatext.i
    ttt_ord-doc-rcv.obj-type
    ttt_ord-doc-rcv.obj-code
    "'out-pay=request'"
    v-out-pay-str
    v-out-pay-type
  }


find first buf_sysconf where buf_sysconf.host-code = v-host-code no-lock.

assign
  g#cash-pay   = buf_sysconf.cash-pay
  v-base-code  = buf_sysconf.base-code
  g#out-pay    = buf_sysconf.out-pay
.
  assign
    g#out-pay  = integer(v-out-pay-str)
  .

  if ttt_ord-doc-rcv.status_ <> {&ord-rcv} then do:
     message "Нельзя сделать накладную на поставку в статусе " caps(ttt_ord-doc-rcv.status_) view-as alert-box .
     return.
  end.

define variable v-ord-doc-type as character no-undo .
define variable v-pay-code as integer   no-undo .
define variable v-doc-type  as character no-undo .
define variable v-internal  as logical   no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-discnt-type as character no-undo .
define variable v-status_ as character no-undo .

  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = ttt_ord-doc-rcv.doc-code no-error .
  if available buf_ord-doc
     then
      assign
        v-contract-code = buf_ord-doc.contract-code
        v-ord-doc-type  = buf_ord-doc.doc-type
        v-pay-code      = buf_ord-doc.pay-code
      .
     else
     assign
       v-contract-code = 0
       v-ord-doc-type  = ""
       v-pay-code      = 0
     .


if ttt_ord-doc-rcv.doc-type = 'out':U then do:
          if v-ord-doc-type  = {&p-o} then do: /* покупатель-объект */
                assign
                  v-doc-type = {&expense}
                  v-internal = false
                  v-ext-doc-type   = {&TDEDT_Ras_Vnesh}
                  v-discnt-type    = {&percent}
                  v-status_ = {&inquiry}
                .
          end.
          else do:  /* заказы поставщику */
                assign
                  v-doc-type = {&income}
                  v-internal = false
                  v-ext-doc-type   = {&TDEDT_Pri_Vnesh}
                  v-discnt-type    = ""
                  v-status_ = {&wayb}
                .
          end.
    end.
    else do: /* внутренние поставки */
        assign
          v-doc-type = {&expense}
          v-internal = true
          v-ext-doc-type   = {&TDEDT_Ras_Perem}
          v-discnt-type    = {&percent}
          v-status_ = {&wayb}
        .
    end.


define variable n-d as character no-undo .
  run doc-code in this-procedure
    (input  "main":u,
     input  store-type,
     input  store-code,
     input  ?,
     output n-d ) no-error.
  if error-status:error then do:
    message "Ошибка при генерации номера документа." view-as alert-box.
    return error.
  end.
  define variable v-type-vat as character no-undo .
  v-type-vat =  entry(2,ttt_ord-doc-rcv.sub-par,{&delim-par}) no-error .
  if v-type-vat = "" or v-type-vat = ? then v-type-vat = {&inc-vat} .

  create  tt-trn-doc.
  buffer-copy  ttt_ord-doc-rcv  to    tt-trn-doc
    assign
     tt-trn-doc.pay-code   = if  ( v-pay-code = ? OR v-pay-code = 0  ) then g#out-pay
                                                                       else v-pay-code
     tt-trn-doc.status_    = "temp"
     tt-trn-doc.doc-code   = n-d
     tt-trn-doc.doc-type   = v-doc-type
     tt-trn-doc.internal   = v-internal
     tt-trn-doc.cr-db-num  = g#db-num
     tt-trn-doc.vat-type   = v-type-vat
     tt-trn-doc.slt-type   = {&without-slt}
     tt-trn-doc.office     = false
     tt-trn-doc.fact-num   = 0
     tt-trn-doc.PS         = "Сформирована по Поставке № " +  ttt_ord-doc-rcv.rcv-code +
                             (if ttt_ord-doc-rcv.doc-code <> "" then " Заказ № " +  ttt_ord-doc-rcv.doc-code  Else "" )
     tt-trn-doc.creid      = g#userid
     tt-trn-doc.flag_      = false
     tt-trn-doc.ext-doc-type   = v-ext-doc-type
     tt-trn-doc.discnt-type    = v-discnt-type
     tt-trn-doc.ret-supp       = false
     tt-trn-doc.contract-code = v-contract-code
     .

     if ttt_ord-doc-rcv.doc-type = 'in':U then do:
     assign tt-trn-doc.obj-code = ttt_ord-doc-rcv.cli-code
            tt-trn-doc.obj-type = ttt_ord-doc-rcv.cli-type
            tt-trn-doc.cli-code = ttt_ord-doc-rcv.obj-code
            tt-trn-doc.cli-type = ttt_ord-doc-rcv.obj-type
            .
     end.
      { gbl/baserate.i v-host-code
            tt-trn-doc.doc-date
            tt-trn-doc.base-rate
            tt-trn-doc.base-scale
            no-error   }
    /* coздание шапки в базе */
   if v-contract-code > 0 then do:
    define variable v-purch-code-ch as character no-undo .
  { str/purchcon.i
    v-host-code
    v-contract-code
    v-purch-code-ch
    v-purch-code-name }
    v-purch-code = integer (v-purch-code-ch) .
   end.
   else do:
      if lookup (string(buf_sysconf.purch-code), {&purchase-input-codes}) = 0 then do:
          message "Неверный код типа приобретения по умолчанию. " skip
                  "Допустимые типы: " {&purchase-input-code-full}
          view-as alert-box error.
          return error.
      end.
      v-purch-code = buf_sysconf.purch-code .
   end.
   { str/crtrndoc.i
      tt-trn-doc.acc-date
      tt-trn-doc.bge-date
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      tt-trn-doc.cli-code
      tt-trn-doc.cli-type
      tt-trn-doc.cli-name
      tt-trn-doc.cr-db-num
      tt-trn-doc.creid
      tt-trn-doc.discnt-type
      tt-trn-doc.doc-code
      tt-trn-doc.doc-date
      tt-trn-doc.doc-type
      tt-trn-doc.flag_
      tt-trn-doc.host-code
      tt-trn-doc.internal
      tt-trn-doc.obj-code
      tt-trn-doc.obj-type
      tt-trn-doc.office
      tt-trn-doc.pay-code
      tt-trn-doc.ps
      tt-trn-doc.ret-supp
      tt-trn-doc.slt-type
      tt-trn-doc.status_
      tt-trn-doc.vat-type
      tt-trn-doc.ext-doc-type
      v-purch-code
      no-error }
    .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "str/crtrndoc.i"
      view-as alert-box error
    .

  find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .

  if not available new_trn-doc then do:
     message error-status :get-message(1) .
     return.
  end.
  
  define variable v-print-rubl as logical   no-undo .
  define variable v-curr-r-b as character no-undo .
  
  { gbl/curr-r-b.i
    v-curr-r-b
  }
    
  if v-curr-r-b = {&r-b-base} then v-print-rubl = false .
  else v-print-rubl = true .

  /* атрибуты накладной */
  find first bf_ord-rcv-attr no-lock
    where bf_ord-rcv-attr.doc-code = ttt_ord-doc-rcv.doc-code
    and bf_ord-rcv-attr.rcv-code = ttt_ord-doc-rcv.rcv-code
    and bf_ord-rcv-attr.attr-code = {&orddocattr-nids}
    no-error.
  if available bf_ord-rcv-attr then do:
    { str/tdat-wrt.i
      new_trn-doc.doc-code
      {&trdcattr-nids}
      bf_ord-rcv-attr.attr-value
      no-error
    }
  end.
  
  find first bf_ord-rcv-attr no-lock
    where bf_ord-rcv-attr.doc-code = ttt_ord-doc-rcv.doc-code
    and bf_ord-rcv-attr.rcv-code = ttt_ord-doc-rcv.rcv-code
    and bf_ord-rcv-attr.attr-code = {&orddocattr-dids}
    no-error.
  if available bf_ord-rcv-attr then do:
    { str/tdat-wrt.i
      new_trn-doc.doc-code
      {&trdcattr-dids}
      bf_ord-rcv-attr.attr-value
      no-error
    }
  end.
  
  find first bf_ord-rcv-attr no-lock
    where bf_ord-rcv-attr.doc-code = ttt_ord-doc-rcv.doc-code
    and bf_ord-rcv-attr.rcv-code = ttt_ord-doc-rcv.rcv-code
    and bf_ord-rcv-attr.attr-code = {&orddocattr-invoiceNumber}
    no-error.
  if available bf_ord-rcv-attr then do:
    { str/tdat-wrt.i
      new_trn-doc.doc-code
      {&trdcattr-nsf}
      bf_ord-rcv-attr.attr-value
      no-error
    }
  end.
  
  find first bf_ord-rcv-attr no-lock
    where bf_ord-rcv-attr.doc-code = ttt_ord-doc-rcv.doc-code
    and bf_ord-rcv-attr.rcv-code = ttt_ord-doc-rcv.rcv-code
    and bf_ord-rcv-attr.attr-code = {&orddocattr-invoiceDate}
    no-error.
  if available bf_ord-rcv-attr then do:
    { str/tdat-wrt.i
      new_trn-doc.doc-code
      {&trdcattr-dsf}
      bf_ord-rcv-attr.attr-value
      no-error
    }
  end.

  assign
  new_trn-doc.contract-code  = v-contract-code
  new_trn-doc.exch-rate  = tt-trn-doc.exch-rate
  new_trn-doc.exch-scale = tt-trn-doc.exch-scale
  new_trn-doc.exch-date  = to-day
  new_trn-doc.exch-code  = tt-trn-doc.exch-code
  new_trn-doc.status_    = v-status_
  new_trn-doc.hold-doc-code-child   = "no-hold"
  new_trn-doc.hold-doc-code-parent  = "no-hold"
  new_trn-doc.print-rubl = v-print-rubl
  new_trn-doc.whole-send-news = ttt_ord-doc-rcv.whole-send-news /*дорога накладной*/
   .

  for each  ttt_ord-line-rcv no-lock where   ttt_ord-line-rcv.doc-code = ttt_ord-doc-rcv.doc-code and
                                             ttt_ord-line-rcv.rcv-code = ttt_ord-doc-rcv.rcv-code
                                             by ttt_ord-line-rcv.line-num
                                             :
      find first t_goods where t_goods.artic     = ttt_ord-line-rcv.artic and
                               t_goods.prod-type = ttt_ord-line-rcv.prod-type and
                               t_goods.prod-code = ttt_ord-line-rcv.prod-code no-lock no-error .
      if error-status :error then do:
         message error-status :get-message(1) .
         next.
      end.

      if ttt_ord-line-rcv.qnty = 0 then do:
          v-ps = v-ps + substitute(" Кол-во=0 артикул:&1," , t_goods.artic ) .
          next.
      end.

{ gbl/gdsobjcr.i
  tt-trn-doc.obj-type
  tt-trn-doc.obj-code
  ttt_ord-line-rcv.artic
  ttt_ord-line-rcv.prod-type
  ttt_ord-line-rcv.prod-code
  ub.gds-obj
  no-error }
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "gbl/gdsobjcr.i"
    view-as alert-box error
  .

  find first ub.gds-obj no-lock where
        ub.gds-obj.obj-type  = tt-trn-doc.obj-type   and
        ub.gds-obj.obj-code  = tt-trn-doc.obj-code   and
        ub.gds-obj.artic     = ttt_ord-line-rcv.artic     and
        ub.gds-obj.prod-type = ttt_ord-line-rcv.prod-type and
        ub.gds-obj.prod-code = ttt_ord-line-rcv.prod-code .

/* Проверяем Ассортиментную политику на создание накладных */
        v-event-code = tt-trn-doc.ext-doc-type .
        { gbl/goassizt.i
          v-event-code
          t_goods.gds-code
          tt-trn-doc.obj-type
          tt-trn-doc.obj-code
          false
          v-Ok
          v-mess
          no-error }
       if v-Ok = false then do:
          v-ps = v-ps + v-mess.
          next.
       end.
    if  ttt_ord-line-rcv.price-rubl  = 0 or ttt_ord-line-rcv.price-rubl  = ? then do:
        assign
         v-price-base  =  ub.gds-obj.last-base
         v-price-rubl  =  ub.gds-obj.last-rubl
        .
    end.
    else do:
        assign
         v-price-base  =   ttt_ord-line-rcv.price-base
         v-price-cli   =   ttt_ord-line-rcv.price-cli
         v-price-rubl  =   ttt_ord-line-rcv.price-rubl
        .
    end.


    assign
      v-cli-qnty  = 0
      v-doc-qnty  = 0
      v-fact-qnty = 0
    .
    if  p-allow-chain-trn-qnty then do:
       for each bf_ord-chain /*ищем все привязки к поставке*/
          where bf_ord-chain.doc-code = ttt_ord-doc-rcv.rcv-code
            and bf_ord-chain.doc-type = "rcv":U
            no-lock :
            find first bf_trn-doc /*ищем накладную к привязке*/
                 where bf_trn-doc.doc-code = bf_ord-chain.rel-doc-code
            no-error.
            if available bf_trn-doc then do: /*нашли накладную */
              find first bf_doc-line /*ищем линии накладной */
                   where bf_doc-line.artic     = ttt_ord-line-rcv.artic
                     and bf_doc-line.prod-code = ttt_ord-line-rcv.prod-code
                     and bf_doc-line.prod-type = ttt_ord-line-rcv.prod-type
                     and bf_doc-line.doc-code  = bf_trn-doc.doc-code
                     no-error.
              if available bf_doc-line then do:
                 assign
                   v-cli-qnty    = v-cli-qnty   + bf_doc-line.cli-qnty
                   v-doc-qnty    = v-doc-qnty   + bf_doc-line.doc-qnty
                   v-fact-qnty   = v-fact-qnty  + bf_doc-line.fact-qnty
                 .
              end.
            end.
       end.
    end.

      create  tt-doc-line  .
        assign
          tt-doc-line.doc-code       = n-d
          tt-doc-line.status_        = "temp"
          tt-doc-line.obj-code       = tt-trn-doc.obj-code
          tt-doc-line.obj-type       = tt-trn-doc.obj-type
          tt-doc-line.slt-pc         = ttt_ord-line-rcv.slt-pc
          tt-doc-line.vat-pc         = ttt_ord-line-rcv.vat-pc
          tt-doc-line.cli-base-rate  = ttt_ord-line-rcv.cli-base-rate
          tt-doc-line.cli-qnty       = if v-cli-qnty  >= ttt_ord-line-rcv.cli-qnty  then 0 else ( ttt_ord-line-rcv.cli-qnty - v-cli-qnty ) /*ttt_ord-line-rcv.cli-qnty*/
          tt-doc-line.doc-qnty       = if v-doc-qnty  >= ttt_ord-line-rcv.qnty      then 0 else ( ttt_ord-line-rcv.qnty     - v-doc-qnty ) /*ttt_ord-line-rcv.qnty*/
          tt-doc-line.fact-qnty      = if v-fact-qnty >= ttt_ord-line-rcv.qnty      then 0 else ( ttt_ord-line-rcv.qnty     - v-fact-qnty ) /*ttt_ord-line-rcv.qnty*/
          tt-doc-line.excise         = ttt_ord-line-rcv.excise
          tt-doc-line.ext-doc-type   = v-ext-doc-type
          tt-doc-line.line-num       = next-value (s-line-num, {&db-name_schema})
          tt-doc-line.other-base     = ttt_ord-line-rcv.other-base
          tt-doc-line.other-rubl     = ttt_ord-line-rcv.other-rubl
          tt-doc-line.price-base     = v-price-base
          tt-doc-line.price-cli      = v-price-cli
          tt-doc-line.price-rubl     = v-price-rubl
          tt-doc-line.artic          = ttt_ord-line-rcv.artic
          tt-doc-line.prod-code      = ttt_ord-line-rcv.prod-code
          tt-doc-line.prod-type      = ttt_ord-line-rcv.prod-type
  /*      tt-doc-line.prt-OK         = true */
          tt-doc-line.prt-root       = t_goods.prt-root
          tt-doc-line.road-tax       = ttt_ord-line-rcv.road-tax
          tt-doc-line.transport-base = ttt_ord-line-rcv.transport-base
          tt-doc-line.transport-rubl = ttt_ord-line-rcv.transport-rubl
          tt-doc-line.unit-cli       = ttt_ord-line-rcv.unit-cli
          tt-doc-line.doc-density     = 1 / tt-doc-line.cli-base-rate
          tt-doc-line.fact-density    = 1 / tt-doc-line.cli-base-rate
          .
          create  tt2-doc-line .
          BUFFER-COPY tt-doc-line to tt2-doc-line.
  /* признаки  для расходной только корневые */

p-q = 0 .
kkk = 0 .

     kkk = 0 .
     for each   ttt_ord-dtl-rcv where
                ttt_ord-doc-rcv.rcv-code   = ttt_ord-dtl-rcv.rcv-code   and
                ttt_ord-doc-rcv.doc-code   = ttt_ord-dtl-rcv.doc-code   and
                ttt_ord-line-rcv.artic     = ttt_ord-dtl-rcv.artic      and
                ttt_ord-line-rcv.prod-code = ttt_ord-dtl-rcv.prod-code  and
                ttt_ord-line-rcv.prod-type = ttt_ord-dtl-rcv.prod-type  :
      kkk = kkk + 1 .
      create tt-gds-dtl .
      buffer-copy  tt-doc-line to  tt-gds-dtl.
      assign
        tt-gds-dtl.fact-qnty =  ttt_ord-dtl-rcv.qnty
        tt-gds-dtl.doc-qnty  =  ttt_ord-dtl-rcv.qnty
        tt-gds-dtl.prt-code  =  ttt_ord-dtl-rcv.node-code
        p-q = ttt_ord-dtl-rcv.qnty
      .
     end.

     if kkk = 0 then do:
          create tt-gds-dtl.
          buffer-copy  tt-doc-line  to  tt-gds-dtl.
          assign
            tt-gds-dtl.prt-code  =  tt-doc-line.prt-root
            p-q = tt-doc-line.doc-qnty
          .
      end.
      if p-q <> tt-doc-line.doc-qnty then
         message "В поставке :"  ttt_ord-doc-rcv.rcv-code skip
                 "по товару :"
                 tt-doc-line.artic
                 tt-doc-line.prod-type
                 tt-doc-line.prod-code
                "По признакам разнесено только :"  p-q skip
                "Надо разнести еще :" ( tt-doc-line.doc-qnty  -  p-q ) skip
                "Исправьте данные по признакам в накладной " view-as alert-box .

end.

for each tt2-doc-line :
    create tt-parts.
    BUFFER-COPY tt2-doc-line except  tt2-doc-line.status_  TO tt-parts   .
      assign
        tt-parts.prod-type      = tt2-doc-line.prod-type
        tt-parts.prod-code      = tt2-doc-line.prod-code
        tt-parts.artic          = tt2-doc-line.artic
        tt-parts.in-code        = new_trn-doc.doc-code
        tt-parts.out-code       = new_trn-doc.doc-code
        tt-parts.price-base     = tt2-doc-line.price-cli / new_trn-doc.base-rate * new_trn-doc.base-scale
        tt-parts.price-rubl     = tt2-doc-line.price-cli
        tt-parts.qnty           = tt2-doc-line.doc-qnty
        tt-parts.obj-type       = new_trn-doc.obj-type
        tt-parts.obj-code       = new_trn-doc.obj-code
        tt-parts.fact-date      = new_trn-doc.fact-date
        tt-parts.fact-num       = new_trn-doc.fact-num
        tt-parts.VAT-pc         = tt2-doc-line.vat-pc
        tt-parts.part-code      = ""
        tt-parts.PS             = "Партия создана по заказу"
        tt-parts.pay-code       = new_trn-doc.pay-code
        tt-parts.status_        = no
        tt-parts.fact-qnty      = tt2-doc-line.fact-qnty
        tt-parts.supp-type      = new_trn-doc.cli-type
        tt-parts.supp-code      = new_trn-doc.cli-code
        tt-parts.rsrv-free      = ?
        tt-parts.doc-type       = new_trn-doc.doc-type
        tt-parts.cli-qnty       = tt2-doc-line.cli-qnty
        tt-parts.pl-code        = 0
        tt-parts.VAT-type       = new_trn-doc.vat-type
        tt-parts.exch-code      = 0
        tt-parts.price-cli      = tt2-doc-line.price-cli
        tt-parts.cli-base-rate  = tt2-doc-line.cli-base-rate
        tt-parts.SLT-pc         = 0
        tt-parts.host-code      = new_trn-doc.host-code
        tt-parts.is-supp        = yes
        tt-parts.SLT-type       = {&without-slt}
        tt-parts.cst-code       = ""
        tt-parts.last-date      = ?
        tt-parts.road-tax-base  = 0
        tt-parts.road-tax-rubl  = 0
        tt-parts.transport-base = 0
        tt-parts.transport-rubl = 0
        tt-parts.other-base     = 0
        tt-parts.other-rubl     = 0
        tt-parts.purch-code     = new_trn-doc.purch-code
        tt-parts.contract-code  = new_trn-doc.contract-code
      no-error.

define buffer buf_pl-gds for ub.pl-gds  .
define variable is-petrolium as logical   no-undo .
define variable is-pieces    as logical   no-undo .

  { str/is-petrl.i
    tt-parts.artic
    tt-parts.prod-type
    tt-parts.prod-code
    is-petrolium
    is-pieces
    no-error
  }
if is-petrolium then do:
 find first t_goods where t_goods.artic     = tt-parts.artic and
                          t_goods.prod-type = tt-parts.prod-type and
                          t_goods.prod-code = tt-parts.prod-code no-lock no-error .

find first buf_pl-gds no-lock where
      buf_pl-gds.obj-code =  tt-parts.obj-code and
      buf_pl-gds.obj-type =  tt-parts.obj-type and
      buf_pl-gds.gds-code =  t_goods.gds-code no-error .
     if available buf_pl-gds then do:
       assign
        tt-parts.pl-code   = buf_pl-gds.pl-code
        tt-parts.part-code = string(buf_pl-gds.pl-code)
       .
     end.
end.

end.

if ttt_ord-doc-rcv.doc-type = 'out':U and v-ord-doc-type <> {&p-o}  then do:
    { str/copy-in.i
      parParentProc
      recid(new_trn-doc)
      tt-trn-doc
      tt2-doc-line
      tt-doc-line-attr
      tt-gds-dtl
      tt-parts
      yes
      yes
      no
      yes
      this-procedure
      no-error }
    if error-status:error then do :
        message "Не удалось добавить товар в приходную накладную !"
          skip "Ошибка из copy-in.i "
          skip error-status :get-message(1)
          skip return-value
        view-as alert-box error buttons ok.
        return error.
    end.
end.

if ttt_ord-doc-rcv.doc-type = 'in':U or v-ord-doc-type = {&p-o} then do:
  { str/copy-ret.i
    parParentProc
    new_trn-doc.doc-code
    new_trn-doc.doc-type
    new_trn-doc.status_
    new_trn-doc.internal
    new_trn-doc.cli-type
    new_trn-doc.cli-code
    new_trn-doc.discnt-type
    new_trn-doc.tot-calc
    new_trn-doc.discnt-pc
    new_trn-doc.agnt
    new_trn-doc.boss
    new_trn-doc.wrkr
    new_trn-doc.base-rate
    new_trn-doc.base-scale
    new_trn-doc.exch-code
    new_trn-doc.vat-type
    new_trn-doc.doc-code
    no
    ?
    ?
    ?
    ?
    ?
    ?
    g#cash-pay
    v-base-code
    tt2-doc-line
    tt-gds-dtl
    tt-parts
    no
    yes
   "( if v-ord-doc-type = {&p-o} then true else false )"
    yes
    no-error }
  if error-status:error then do :
      message "Не удалось добавить товар во внутреннюю расходную накладную !"
      skip "Ошибка из copy-ret.i "
      skip error-status :get-message(1)
      skip return-value
      view-as alert-box error buttons ok.
      return error.
  end.
  run gbl/calc-trn.p ( input parparentproc, input recid(new_trn-doc)) no-error.
end.
/* связка поставки и  созданной накладной */

if LENGTH(new_trn-doc.Ps) < 31900 then do:
   new_trn-doc.Ps = new_trn-doc.Ps + {&new-line} + V-ps.
end.

run create-chain in this-procedure
  ( ttt_ord-doc-rcv.rcv-code
  ,'rcv'
  ,new_trn-doc.doc-code
  ,'trn'
  ,''
  ,''
  ) .