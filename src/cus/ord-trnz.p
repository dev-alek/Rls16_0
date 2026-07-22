block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-trnz.p $
$Archive: cus/ord-trnz.p $

Формирование запроса из поставки

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 05/20/02 3:22

*/
define input parameter parParentProc   as widget-handle no-undo.
define input parameter tp-rec as recid no-undo .
define input parameter par-type as character no-undo .     /* Приход расход */
define input parameter par-doc-code as character no-undo . /* Номер для щепки */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-trnz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-trnz.p $":U .
define variable vss-description as character no-undo init "Формирование накладной из поставки".
{ cmp/vssrevis.i }
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: ord-trnz.p $ $Revision: aea5316774be, 0, rls $".

{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ str/lib-trn.i  }
{ cmp/df-sub.i   }
{ str/doc-code.i }
{ gbl/waitfram.i }
{ cmp/croslist.i }
{ gbl/clntattr.i }
{ cmp/strcodec.i }
{ str/lib-def.i  }
{ str/hvrdtax.i  }
{ str/lib-calc.i }
{ str/plgdsfnd.i }
{ cus/copyinqu.i }
{ cus/ord-lib.i create-chain }

define variable v-ext-doc-type as character no-undo .
define buffer ttt_ord-doc-rcv  for ub.ord-doc-rcv.
define buffer ttt_ord-line-rcv for ub.ord-line-rcv.
define buffer ttt_ord-dtl-rcv  for ub.ord-dtl-rcv.

define buffer new_trn-doc  for ub.trn-doc  .
define buffer new_doc-line for ub.doc-line .
define buffer new_gds-dtl  for ub.gds-dtl .

define buffer t_trn-doc  for ub.trn-doc  .
define buffer t_doc-line for ub.doc-line .
define buffer t_gds-dtl  for ub.gds-dtl .
define buffer t_goods    for ub.goods .

define variable kkk  as integer no-undo .
define variable p-q  like ub.ord-dtl-rcv.qnty no-undo .

define variable parrec-doc  as recid no-undo .
define variable parrecalc-price as logical no-undo init false .
define variable parhandle as handle no-undo .


define variable v-host-code as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable v-base-code as integer   no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostcode.i store-type store-code  v-host-code }
define buffer buf_sysconf for ub.sysconf  .
find first buf_sysconf where buf_sysconf.host-code = v-host-code no-lock.
define variable g#cash-pay as integer   no-undo .
define variable g#out-pay as integer   no-undo .
assign
  g#cash-pay = buf_sysconf.cash-pay
  v-base-code  = buf_sysconf.base-code
  g#out-pay  = buf_sysconf.out-pay
.



{ cmp/df-sub.i  pr }

 run waitfram-show in this-procedure ( "Формирование временных таблиц для копирования....") .
  find first ttt_ord-doc-rcv where recid(ttt_ord-doc-rcv) = tp-rec no-lock no-error .
  if not avail ttt_ord-doc-rcv then return error.

define variable n-d as character no-undo .

if par-type =  {&income} then do:
   v-ext-doc-type = {&TDEDT_Pri_Perem} .
  run doc-code in this-procedure
    (input  "main":u,
     input  store-type,
     input  store-code,
     input  ?,
     output n-d ) no-error.
  if error-status:error then do:
    message "Ошибка при генерации номера документа. main" view-as alert-box.
    return error.
  end.

end.
else do:
   v-ext-doc-type = {&TDEDT_Ras_Perem} .
  run doc-code in this-procedure
    (input  "chip":u,
     input  store-type,
     input  store-code,
     input  par-doc-code,
     output n-d ) no-error.
  if error-status:error then do:
    message "Ошибка при генерации номера документа. chip" view-as alert-box.
    return error.
  end.

end.



  create  tt-trn-doc.
  buffer-copy  ttt_ord-doc-rcv  to    tt-trn-doc
    assign
     tt-trn-doc.pay-code   =   g#out-pay
     tt-trn-doc.status_    = "temp"
     tt-trn-doc.doc-code   = n-d
     tt-trn-doc.doc-type   = par-type
     tt-trn-doc.internal   = true
     tt-trn-doc.cr-db-num  = g#db-num
     tt-trn-doc.vat-type   = {&inc-vat}
     tt-trn-doc.slt-type   = {&without-slt}
     tt-trn-doc.office     = false
     tt-trn-doc.fact-num   = 0
     tt-trn-doc.inv-num    = par-doc-code
     tt-trn-doc.out-code   = ttt_ord-doc-rcv.doc-code
     tt-trn-doc.PS         = "Сформирована по заказу № " +  ttt_ord-doc-rcv.doc-code + " " + ttt_ord-doc-rcv.PS
     tt-trn-doc.creid      = g#userid
     tt-trn-doc.flag_      = false
     tt-trn-doc.ext-doc-type   =  v-ext-doc-type
     tt-trn-doc.discnt-type    =  {&percent}
     tt-trn-doc.ret-supp       = false
     tt-trn-doc.print-rubl     = true
    .
    if par-type =  {&expense} then do:
        assign
          tt-trn-doc.obj-code  = ttt_ord-doc-rcv.cli-code
          tt-trn-doc.obj-type  = ttt_ord-doc-rcv.cli-type
          tt-trn-doc.cli-code  = ttt_ord-doc-rcv.obj-code
          tt-trn-doc.cli-type  = ttt_ord-doc-rcv.obj-type
        .
    end.
      { gbl/baserate.i
            v-host-code
            tt-trn-doc.DOC-DATE
            tt-trn-doc.base-rate
            tt-trn-doc.base-scale
            no-error   }
    /* coздание шапки в базе */
   if lookup (string(buf_sysconf.purch-code), {&purchase-input-codes}) = 0 then do:
      message "Неверный код типа приобретения по умолчанию. " skip
              "Допустимые типы: " {&purchase-input-code-full}
      view-as alert-box error.
      return error.
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
      buf_sysconf.purch-code
      no-error }
  find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .

  if not avail new_trn-doc then do:
     message vss-workfile vss-revision vss-description skip
           "Ошибка  создания шапки документа " skip
             skip
             error-status :get-message(1) skip
             return-value skip
             view-as alert-box error
     .
     undo, return error .
  end.

  assign
      new_trn-doc.exch-rate  = tt-trn-doc.exch-rate
      new_trn-doc.exch-scale = tt-trn-doc.exch-scale
      new_trn-doc.exch-date  = to-day
      new_trn-doc.exch-code  = tt-trn-doc.exch-code
      new_trn-doc.status_    = {&inquiry}
      new_trn-doc.print-rubl     = true
      parrec-doc = recid(new_trn-doc)
   .


  for each  ttt_ord-line-rcv no-lock where   ttt_ord-line-rcv.doc-code = ttt_ord-doc-rcv.doc-code and
                                             ttt_ord-line-rcv.rcv-code = ttt_ord-doc-rcv.rcv-code
                                             by ttt_ord-line-rcv.line-num       :
      find first t_goods where
                  t_goods.artic     = ttt_ord-line-rcv.artic    and
                  t_goods.prod-type = ttt_ord-line-rcv.prod-type and
                  t_goods.prod-code = ttt_ord-line-rcv.prod-code no-lock no-error .
      if error-status :error then do:
         message vss-workfile vss-revision vss-description skip
              "Ошибка поиска товара  " skip
               skip
               ttt_ord-line-rcv.artic
               ttt_ord-line-rcv.prod-type
               ttt_ord-line-rcv.prod-code skip
               error-status :get-message(1) skip
               return-value skip
               view-as alert-box error
       .
       next.
       end.
      create  tt-doc-line  .
        assign
          tt-doc-line.doc-code       = n-d
          tt-doc-line.status_        = "temp"
          tt-doc-line.obj-code       = new_trn-doc.obj-code
          tt-doc-line.obj-type       = new_trn-doc.obj-type
          tt-doc-line.SLT-pc         = ttt_ord-line-rcv.SLT-pc
          tt-doc-line.VAT-pc         = ttt_ord-line-rcv.VAT-pc
          tt-doc-line.cli-base-rate  = ttt_ord-line-rcv.cli-base-rate
          tt-doc-line.cli-qnty       = ttt_ord-line-rcv.cli-qnty
          tt-doc-line.doc-qnty       = ttt_ord-line-rcv.qnty
          tt-doc-line.fact-qnty      = ttt_ord-line-rcv.qnty
          tt-doc-line.excise         = ttt_ord-line-rcv.excise
          tt-doc-line.ext-doc-type   = {&TDEDT_Pri_Perem}
          tt-doc-line.line-num       = next-value(s-line-num, {&db-name_schema})
          tt-doc-line.other-base     = ttt_ord-line-rcv.other-base
          tt-doc-line.other-rubl     = ttt_ord-line-rcv.other-rubl
          tt-doc-line.price-base     = ttt_ord-line-rcv.price-base
          tt-doc-line.price-cli      = ttt_ord-line-rcv.price-cli
          tt-doc-line.price-rubl     = ttt_ord-line-rcv.price-rubl
          tt-doc-line.artic          = ttt_ord-line-rcv.artic
          tt-doc-line.prod-code      = ttt_ord-line-rcv.prod-code
          tt-doc-line.prod-type      = ttt_ord-line-rcv.prod-type
  /*      tt-doc-line.prt-OK         = true */
          tt-doc-line.prt-root       = t_goods.prt-root
          tt-doc-line.road-tax       = ttt_ord-line-rcv.road-tax
          tt-doc-line.transport-base = ttt_ord-line-rcv.transport-base
          tt-doc-line.transport-rubl = ttt_ord-line-rcv.transport-rubl
          tt-doc-line.unit-cli       = ttt_ord-line-rcv.unit-cli
          .

{ gbl/gdsobjcr.i
  tt-doc-line.obj-type
  tt-doc-line.obj-code
  tt-doc-line.artic
  tt-doc-line.prod-type
  tt-doc-line.prod-code
  ub.gds-obj
  no-error }
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
            "Ошибка gdsobjcr.i " skip
             skip
             error-status :get-message(1) skip
             return-value skip
             view-as alert-box error
     .
  end.
  /* признаки  для расходной только корневые */
p-q = 0 .
kkk = 0 .
        for each  ttt_ord-dtl-rcv where
                  ttt_ord-dtl-rcv.rcv-code  = ttt_ord-doc-rcv.rcv-code   and
                  ttt_ord-dtl-rcv.doc-code  = ttt_ord-doc-rcv.doc-code   and
                  ttt_ord-dtl-rcv.artic     = ttt_ord-line-rcv.artic     and
                  ttt_ord-dtl-rcv.prod-code = ttt_ord-line-rcv.prod-code and
                  ttt_ord-dtl-rcv.prod-type = ttt_ord-line-rcv.prod-type
                  :
              kkk = kkk + 1 .
              create tt-gds-dtl .
              buffer-copy  tt-doc-line to  tt-gds-dtl.
              assign
                tt-gds-dtl.fact-qnty =  ttt_ord-dtl-rcv.qnty
                tt-gds-dtl.doc-qnty  =  ttt_ord-dtl-rcv.qnty
                tt-gds-dtl.prt-code  =  ttt_ord-dtl-rcv.node-code
                p-q = p-q + ttt_ord-dtl-rcv.qnty
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

      if p-q <> tt-doc-line.doc-qnty then do:
         message "В поставке :"  ttt_ord-doc-rcv.rcv-code skip
                 "по товару :"
                 tt-doc-line.artic
                 tt-doc-line.prod-type
                 tt-doc-line.prod-code skip
                "По cтроке товара" tt-doc-line.doc-qnty Skip
                "По признакам разнесено только :"  p-q skip
                "Надо разнести еще :" ( tt-doc-line.doc-qnty  -  p-q ) skip
                "Проверьте данные по признакам в накладной " view-as alert-box .
      end.
end.
for each tt-doc-line :
    create tt-parts.
    BUFFER-COPY tt-doc-line except  tt-doc-line.status_  TO tt-parts   .
      assign
        tt-parts.prod-type      = tt-doc-line.prod-type
        tt-parts.prod-code      = tt-doc-line.prod-code
        tt-parts.artic          = tt-doc-line.artic
        tt-parts.in-code        = new_trn-doc.doc-code
        tt-parts.out-code       = new_trn-doc.doc-code
        tt-parts.price-base     = tt-doc-line.price-cli / new_trn-doc.base-rate * new_trn-doc.base-scale
        tt-parts.price-rubl     = tt-doc-line.price-cli
        tt-parts.qnty           = tt-doc-line.doc-qnty
        tt-parts.obj-type       = new_trn-doc.obj-type
        tt-parts.obj-code       = new_trn-doc.obj-code
        tt-parts.fact-date      = new_trn-doc.fact-date
        tt-parts.fact-num       = new_trn-doc.fact-num
        tt-parts.VAT-pc         = tt-doc-line.vat-pc
        tt-parts.part-code      = ""
        tt-parts.PS             = "Партия создана по заказу"
        tt-parts.pay-code       = new_trn-doc.pay-code
        tt-parts.status_        = no
        tt-parts.fact-qnty      = tt-doc-line.fact-qnty
        tt-parts.supp-type      = new_trn-doc.cli-type
        tt-parts.supp-code      = new_trn-doc.cli-code
        tt-parts.rsrv-free      = ?
        tt-parts.doc-type       = new_trn-doc.doc-type
        tt-parts.cli-qnty       = tt-doc-line.fact-qnty
        tt-parts.pl-code        = ?
        tt-parts.VAT-type       = {&inc-vat}
        tt-parts.exch-code      = 0
        tt-parts.price-cli      = tt-doc-line.price-cli
        tt-parts.cli-base-rate  = 1
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

end.

 run waitfram-show in this-procedure ( "Создание ЗАПРОСА " + caps(par-type)) .

  { cus/copyinqu.i
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
    new_trn-doc.discnt-pc
    new_trn-doc.agnt
    new_trn-doc.boss
    new_trn-doc.wrkr
    new_trn-doc.base-rate
    new_trn-doc.base-scale
    g#cash-pay
    v-base-code
    tt-doc-line
    tt-gds-dtl
    tt-parts
    no
    yes
    no
    no-error }
    if error-status:error then do :
        message "Не удалось добавить товар в расходную накладную !"
        skip "Ошибка из lib-trn_copy-inqu "
        error-status :get-message(1)
        view-as alert-box error buttons ok.
        return error.
    end.

  parhandle =  ? .
  { str/calc-out.i
    parrec-doc
    parrecalc-price
    parhandle
    }
/* пометочка о созданной накладной в поставках */

find first ttt_ord-doc-rcv where
       recid(ttt_ord-doc-rcv) = tp-rec  exclusive-lock  no-error .
assign
  ttt_ord-doc-rcv.status_  = {&ord-rcv}
  .
find current ttt_ord-doc-rcv no-lock .

/* связка поставки и  созданной накладной */
run create-chain in this-procedure
  ( ttt_ord-doc-rcv.rcv-code
  ,'rcv'
  ,new_trn-doc.doc-code
  ,'trn'
  ,''
  ,''
  ) .

run waitfram-hide in this-procedure .
/* Копирование в запросы */