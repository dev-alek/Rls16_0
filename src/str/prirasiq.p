block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prirasiq.p $
$Archive: str/prirasiq.p $

Формирование запроса расх из запр при

Автор: Чернова Светлана Александровна
Дата создания: 08/09/04
Author: Svetlana Chernova
Creation date: 08/09/04

*/
define input parameter parParentProc  as widget-handle no-undo.
define input parameter par-doc-code   as character no-undo . /* Номер для щепки */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prirasiq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/prirasiq.p $":U .
define variable vss-description as character no-undo init "Формирование накладной из поставки".
{ cmp/vssrevis.i }
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: prirasiq.p $ $Revision: aea5316774be, 0, rls $".



{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
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
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i get }

define variable v-ext-doc-type as character no-undo .
define variable to-day       as date no-undo .


define buffer old_trn-doc  for ub.trn-doc.
define buffer old_doc-line for ub.doc-line.
define buffer old_gds-dtl  for ub.gds-dtl.
define buffer old_doc-prts  for ub.doc-prts.

define buffer new_trn-doc  for ub.trn-doc  .
define buffer new_doc-line for ub.doc-line .
define buffer new_gds-dtl  for ub.gds-dtl .
define buffer new_doc-prts  for ub.doc-prts.

define buffer t_trn-doc  for ub.trn-doc  .
define buffer t_doc-line for ub.doc-line .
define buffer t_gds-dtl  for ub.gds-dtl .
define buffer t_goods    for ub.goods .

define variable kkk  as integer no-undo .
define variable p-q  like ub.ord-dtl.qnty no-undo .

define variable parrec-doc  as recid no-undo .
define variable parrecalc-price as logical no-undo init false .
define variable parhandle as handle no-undo .

define variable v-cntxp-cash-pay as integer   no-undo .
define variable v-base-code as integer   no-undo .

define buffer buf_sysconf for ub.sysconf  .
find first buf_sysconf no-lock where buf_sysconf.host-code = v-cntxt-host-code-obj no-error.
  IF available  buf_sysconf then
   assign
     v-cntxp-cash-pay = buf_sysconf.cash-pay
     v-base-code      = buf_sysconf.base-code
   .


 { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }

 run waitfram-show ("Формирование временных таблиц для копирования....") .
  find first old_trn-doc where old_trn-doc.doc-code = par-doc-code no-lock no-error .
  if not avail old_trn-doc then return error.

define variable n-d as character no-undo .

  v-ext-doc-type = {&TDEDT_Ras_Perem} .
  run doc-code in this-procedure
    (input  "chip":u,
     input  v-cntxt-obj-type,
     input  v-cntxt-obj-code,
     input  par-doc-code,
     output n-d ) no-error.
  if error-status:error then do:
    message "Ошибка при генерации номера документа. chip" view-as alert-box.
    return error.
  end.


  create  tt-trn-doc.
  buffer-copy  old_trn-doc  to    tt-trn-doc
    assign
     tt-trn-doc.pay-code   =   v-cntxp-out-pay
     tt-trn-doc.status_    = "temp"
     tt-trn-doc.doc-code   = n-d
     tt-trn-doc.doc-type   = {&expense}
     tt-trn-doc.internal   = true
     tt-trn-doc.cr-db-num  = v-cntxt-db-num
     tt-trn-doc.vat-type   = {&inc-vat}
     tt-trn-doc.slt-type   = {&without-slt}
     tt-trn-doc.office     = false
     tt-trn-doc.fact-num   = 0
     tt-trn-doc.inv-num    = par-doc-code
     tt-trn-doc.out-code   = old_trn-doc.doc-code
     tt-trn-doc.PS         = "Сформирована по запросу № " +  old_trn-doc.doc-code + " " + old_trn-doc.PS
     tt-trn-doc.creid      = v-cntxt-userid
     tt-trn-doc.flag_      = false
     tt-trn-doc.ext-doc-type   =  v-ext-doc-type
     tt-trn-doc.discnt-type    =  {&percent}
     tt-trn-doc.ret-supp       = false
     tt-trn-doc.print-rubl     = true

    tt-trn-doc.obj-code  = old_trn-doc.cli-code
    tt-trn-doc.obj-type  = old_trn-doc.cli-type
    tt-trn-doc.cli-code  = old_trn-doc.obj-code
    tt-trn-doc.cli-type  = old_trn-doc.obj-type
  .
  { gbl/baserate.i v-cntxt-host-code-OBJ
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

   { str/crtrndoc.i   tt-trn-doc.acc-date
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
                 .

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
      new_trn-doc.out-code   = tt-trn-doc.out-code
      new_trn-doc.exch-rate  = tt-trn-doc.exch-rate
      new_trn-doc.exch-scale = tt-trn-doc.exch-scale
      new_trn-doc.exch-date  = to-day
      new_trn-doc.exch-code  = tt-trn-doc.exch-code
      new_trn-doc.status_    = {&inquiry}
      new_trn-doc.print-rubl     = true
      parrec-doc = recid(new_trn-doc)
   .


  for each  old_doc-line no-lock  where
            old_doc-line.doc-code = old_trn-doc.doc-code  :

      create  tt-doc-line  .
      BUFFER-COPY old_doc-line to tt-doc-line
        assign
          tt-doc-line.doc-code       = n-d
          tt-doc-line.status_        = "temp"
          tt-doc-line.obj-code       =  tt-trn-doc.obj-code
          tt-doc-line.obj-type       =  tt-trn-doc.obj-type
          tt-doc-line.ext-doc-type   = {&TDEDT_Ras_Perem}
          .
      { gbl/gdsobjcr.i
        tt-doc-line.obj-type
        tt-doc-line.obj-code
        tt-doc-line.artic
        tt-doc-line.prod-type
        tt-doc-line.prod-code
        ub.gds-obj
        no-error }
        if error-status :error then message error-status :get-message(1) .

        /* признаки  для расходной только корневые */

      p-q = 0 .
      kkk = 0 .
     for each   old_gds-dtl where
                old_trn-doc.doc-code   = old_gds-dtl.doc-code   and
                old_doc-line.artic     = old_gds-dtl.artic      and
                old_doc-line.prod-code = old_gds-dtl.prod-code  and
                old_doc-line.prod-type = old_gds-dtl.prod-type  :
      kkk = kkk + 1 .
      create tt-gds-dtl .
      buffer-copy  old_gds-dtl to  tt-gds-dtl.
        assign
          tt-gds-dtl.doc-code       = n-d
      .
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

for each old_doc-prts  where
         old_doc-prts.out-code = old_trn-doc.doc-code
:

  find first new_doc-prts exclusive-lock where
             new_doc-prts.out-code = new_trn-doc.doc-code and
             new_doc-prts.b-code   = old_doc-prts.b-code no-error .
    if not available new_doc-prts then do:
        create new_doc-prts.
        buffer-copy old_doc-prts to new_doc-prts
        assign
          new_doc-prts.out-code = new_trn-doc.doc-code
        .
    end.
end.


 run waitfram-show ("Создание ЗАПРОСА " + caps({&expense})  + " " +  new_trn-doc.doc-code ) .
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
    v-cntxp-cash-pay
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

run waitfram-hide .
/* Копирование в запросы */