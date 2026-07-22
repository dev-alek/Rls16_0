block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: crrasper.p $
$Archive: cus/crrasper.p $

Создание внутреннего расхода по временной таблице

Автор: Чернова Светлана Александровна
Дата создания: 04/05/06
Author: Svetlana Chernova
Creation date: 04/05/06

*/
define input parameter parparentproc as handle no-undo .
define input parameter par-doc-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: crrasper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/crrasper.p $":U .
define variable vss-description as character no-undo init "Создание внутреннего расхода  по временной таблице".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
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
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ cus/ord-code.i def }
{ cus/ord-lib.i create-chain}
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/thbjattr.i }

define buffer buf_sysconf for ub.sysconf  .
define buffer buf_goods for ub.goods  .

find first buf_sysconf where buf_sysconf.host-code = v-cntxt-host-code-obj no-lock.
define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-in-ov as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time  as integer   no-undo .
define variable v-cntxt-load-time  as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable v-no-ask as logical   no-undo .
define variable v-Ok       as logical   no-undo .
define variable v-mess as character no-undo .
define variable v-event-code as character no-undo .

define stream str.
output stream str to value('no-price.txt') .



assign
  v-cntxt-cash-pay   = buf_sysconf.cash-pay
  v-cntxt-base-code  = buf_sysconf.base-code
  v-cntxt-in-ov      = buf_sysconf.in-ov
  v-cntxt-rsrv-time  = buf_sysconf.rsrv-time
  v-cntxt-load-time  = buf_sysconf.load-time
  v-cntxt-holidays   = buf_sysconf.holidays
.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

define variable v-ext-doc-type as character no-undo .

define buffer old_trn-ord-doc  for  ub.ord-doc .
define buffer old_doc-ord-line for  ub.ord-line .
define temp-table old_gds-dtl no-undo like ub.gds-dtl .

define buffer new_trn-doc  for ub.trn-doc  .
define buffer new_doc-line for ub.doc-line .
define buffer new_gds-dtl  for ub.gds-dtl .

define buffer t_trn-doc  for ub.trn-doc  .
define buffer t_doc-line for ub.doc-line .
define buffer t_gds-dtl  for ub.gds-dtl .
define buffer t_goods    for ub.goods .

define buffer corr_ord-line for ub.ord-line  .
define variable kkk  as integer no-undo .
define variable p-q  like ub.ord-dtl.qnty no-undo .

define variable parrec-doc      as recid    no-undo .
define variable parrecalc-price as logical  no-undo init false .
define variable parhandle       as handle   no-undo .
define variable v-root-node     as integer  no-undo .
define variable varconf-par-cd as character no-undo .

define variable p-type             as character no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-stroka-protocol  as character no-undo .
define variable v-protocol-date    as date      no-undo .
define variable v-protocol-time    as integer   no-undo .
define variable v-logical          as logical   no-undo .
define variable is-rt as logical   no-undo .


 /*  yes  зафиксируем цены для внутреннего перемещения . Они определены в заказе */
 /*  no - будет спрашивать */

/*  v-no-ask = no  . */

 empty temp-table tt-doc-line.
 empty temp-table tt-gds-dtl .
 empty temp-table tt-parts   .



  is-rt = false  .
  run is-radioterminal in parparentproc (output is-rt ) no-error .
  if error-status :error then do:
     is-rt = false  .
  end.

  v-no-ask = yes .


run waitfram-show in this-procedure ("Формирование временных таблиц для копирования....") .
   find first old_trn-ord-doc exclusive-lock where old_trn-ord-doc.doc-code = par-doc-code no-error .
   if not available old_trn-ord-doc then return error.

{ gbl/dflt-cd.i v-cntxt-obj-type v-cntxt-obj-code varconf-par-cd }

define variable n-d as character no-undo .

  v-ext-doc-type = {&TDEDT_Ras_Perem} .
  run doc-code in this-procedure
    (input  "main":U,
     input  v-cntxt-obj-type,
     input  v-cntxt-obj-code,
     input  par-doc-code,
     output n-d ) no-error.
  if error-status:error then do:
    if not is-rt  then message "Ошибка при генерации номера документа. chip" view-as alert-box.
    return error "Ошибка при генерации номера документа. chip".
  end.


  create  tt-trn-doc.
  buffer-copy  old_trn-ord-doc  to    tt-trn-doc
    assign
     tt-trn-doc.pay-code       = v-cntxp-out-pay
     tt-trn-doc.status_        = "temp"
     tt-trn-doc.doc-code       = n-d
     tt-trn-doc.doc-date       = to-day
     tt-trn-doc.doc-type       = {&expense}
     tt-trn-doc.internal       = true
     tt-trn-doc.cr-db-num      = v-cntxt-db-num
     tt-trn-doc.vat-type       = {&inc-vat}
     tt-trn-doc.slt-type       = {&without-slt}
     tt-trn-doc.office         = false
     tt-trn-doc.fact-num       = 0
     tt-trn-doc.inv-num        = par-doc-code
     tt-trn-doc.out-code       = old_trn-ord-doc.doc-code
     tt-trn-doc.PS             = "Сформирована по заказу № " +  old_trn-ord-doc.doc-code + " " + old_trn-ord-doc.doc-type + " " + old_trn-ord-doc.PS
     tt-trn-doc.creid          = v-cntxt-userid
     tt-trn-doc.flag_          = false
     tt-trn-doc.ext-doc-type   = v-ext-doc-type
     tt-trn-doc.discnt-type    = {&percent}
     tt-trn-doc.ret-supp       = false
     tt-trn-doc.print-rubl     = true
     tt-trn-doc.hold-doc-code-child  = "no-hold":u
     tt-trn-doc.hold-doc-code-parent = "no-hold":u
     tt-trn-doc.obj-code       = old_trn-ord-doc.cli-code
     tt-trn-doc.obj-type       = old_trn-ord-doc.cli-type
     tt-trn-doc.cli-code       = old_trn-ord-doc.obj-code
     tt-trn-doc.cli-type       = old_trn-ord-doc.obj-type
  .

  { gbl/baserate.i
    v-cntxt-host-code-obj
    tt-trn-doc.doc-date
    tt-trn-doc.base-rate
    tt-trn-doc.base-scale
    no-error   }
    /* coздание шапки в базе */
   find first ub.sysconf where ub.sysconf.host-code = v-cntxt-host-code-obj no-lock.
   if lookup (string(ub.sysconf.purch-code), {&purchase-input-codes}) = 0 then do:
     if not is-rt then
 message "Неверный код типа приобретения по умолчанию. " skip
              "Допустимые типы: " {&purchase-input-code-full}
      view-as alert-box error.
      return error "Неверный код типа приобретения по умолчанию. ".
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
    ub.sysconf.purch-code
    no-error }
    .

  find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .

  if not avail new_trn-doc then do:
     if not is-rt  then
     message vss-workfile vss-revision vss-description skip
           "Ошибка  создания шапки документа " skip
             skip
             error-status :get-message(1) skip
             return-value skip
             view-as alert-box error
     .
     undo, return error "Ошибка  создания шапки документа " + return-value  + error-status :get-message(1) .
  end.

  assign
      new_trn-doc.exch-rate  = tt-trn-doc.exch-rate
      new_trn-doc.exch-scale = tt-trn-doc.exch-scale
      new_trn-doc.exch-date  = to-day
      new_trn-doc.exch-code  = tt-trn-doc.exch-code
      new_trn-doc.status_    = {&inquiry}  /* +++ */
      new_trn-doc.flag_      = true        /* +++ */
      new_trn-doc.print-rubl = true
      new_trn-doc.hold-doc-code-child  = "no-hold":u
      new_trn-doc.hold-doc-code-parent = "no-hold":u
      parrec-doc = recid(new_trn-doc)
   .

define variable v-err2 as logical   no-undo .
  v-err2 = false .

  for each  old_doc-ord-line no-lock  where
            old_doc-ord-line.doc-code = old_trn-ord-doc.doc-code :
           find first buf_goods no-lock where
                      buf_goods.artic     =  old_doc-ord-line.artic and
                      buf_goods.prod-type =  old_doc-ord-line.prod-type and
                      buf_goods.prod-code =  old_doc-ord-line.prod-code
                      no-error .
    if buf_goods.stts <> 0 then do:

          if LENGTH(new_trn-doc.Ps) < 31900 then do:
              new_trn-doc.Ps = trim(new_trn-doc.Ps) + {&new-line} + 'товар удален '  + old_doc-ord-line.artic.
          end.

          put stream str unformatted
              substitute("&1,&2" , buf_goods.gds-code,  old_doc-ord-line.qnty )
              skip.
          v-err2 = true  .
          next.
    end.
    /* Ассортиментная политика */
        v-event-code = substitute("&1" , new_trn-doc.ext-doc-type) .
        { gbl/goassizt.i
          v-event-code
          buf_goods.gds-code
          new_trn-doc.obj-type
          new_trn-doc.obj-code
          false
          v-Ok
          v-mess
          no-error }
          if v-Ok = false then do:
              if LENGTH(new_trn-doc.Ps) < 31900 then do:
                  new_trn-doc.Ps = trim(new_trn-doc.Ps) + {&new-line} +  v-mess.
              end.
              put stream str unformatted
                  substitute("&1,&2" , buf_goods.gds-code,  v-mess )
                  skip.
              v-err2 = true  .
              next.
          end.

        v-event-code = substitute("cli_&1" , new_trn-doc.ext-doc-type) .
        { gbl/goassizt.i
          v-event-code
          buf_goods.gds-code
          new_trn-doc.cli-type
          new_trn-doc.cli-code
          false
          v-Ok
          v-mess
          no-error }
          if v-Ok = false then do:
              if LENGTH(new_trn-doc.Ps) < 31900 then do:
                  new_trn-doc.Ps = trim(new_trn-doc.Ps) + {&new-line} +  v-mess.
              end.
              put stream str unformatted
                  substitute("&1,&2" , buf_goods.gds-code,  v-mess )
                  skip.
              v-err2 = true  .
              next.
          end.

      { gbl/gdsobjcr.i
        new_trn-doc.obj-type
        new_trn-doc.obj-code
        old_doc-ord-line.artic
        old_doc-ord-line.prod-type
        old_doc-ord-line.prod-code
        ub.gds-obj
        no-error }
        if error-status :error then message error-status :get-message(1) .

    find first ub.gds-obj no-lock where
        ub.gds-obj.obj-type  = new_trn-doc.obj-type    and
        ub.gds-obj.obj-code  = new_trn-doc.obj-code    and
        ub.gds-obj.artic     = old_doc-ord-line.artic      and
        ub.gds-obj.prod-type = old_doc-ord-line.prod-type  and
        ub.gds-obj.prod-code = old_doc-ord-line.prod-code  no-error .
        if error-status :error then message error-status :get-message(1) .


    if ub.gds-obj.price-sale  = 0  or ub.gds-obj.price-sale  = ?  then do:
          if LENGTH(new_trn-doc.Ps) < 31900 then do:
              new_trn-doc.Ps = trim(new_trn-doc.Ps) + {&new-line} + 'нет цены у '  + old_doc-ord-line.artic.
          end.
          put stream str unformatted
              substitute("&1,&2" , buf_goods.gds-code,  old_doc-ord-line.qnty )
              skip.
          v-err2 = true  .
          next.
    end.

  /* в ОРЦ берем цену с объекта РЦ */
    if old_doc-ord-line.price-rubl <> ub.gds-obj.price-sale and old_doc-ord-line.price-rubl <> 0 then do:
      if length(old_trn-ord-doc.ps) < 31900 then do:
          old_trn-ord-doc.Ps = trim(old_trn-ord-doc.Ps) + {&new-line} + old_doc-ord-line.artic  + " Цена взята с РЦ , была: " + string (old_doc-ord-line.price-rubl) .
      end.
    end.

  find first corr_ord-line exclusive-lock where recid(corr_ord-line) = recid(old_doc-ord-line).
  assign
    corr_ord-line.price-rubl = ub.gds-obj.price-sale
  .

      { gbl/rootnode.i
        old_doc-ord-line.artic
        old_doc-ord-line.prod-type
        old_doc-ord-line.prod-code
        v-root-node
        }

      create old_gds-dtl.
      BUFFER-COPY old_doc-ord-line to old_gds-dtl
        assign
          old_gds-dtl.doc-qnty = old_doc-ord-line.qnty
          old_gds-dtl.prt-code = v-root-node
          old_gds-dtl.ov = v-no-ask /*  yes  зафиксируем цены для внутреннего перемещения . Они определены в заказе */
                                    /*  no - будет спрашивать */
        .

      create tt-doc-line .
      BUFFER-COPY old_doc-ord-line to tt-doc-line
        assign
          tt-doc-line.doc-qnty       = old_doc-ord-line.qnty
          tt-doc-line.fact-qnty      = old_doc-ord-line.qnty
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
                old_trn-ord-doc.doc-code   = old_gds-dtl.doc-code   and
                old_doc-ord-line.artic     = old_gds-dtl.artic      and
                old_doc-ord-line.prod-code = old_gds-dtl.prod-code  and
                old_doc-ord-line.prod-type = old_gds-dtl.prod-type
                :
      kkk = kkk + 1 .
      create tt-gds-dtl .
      buffer-copy  old_gds-dtl to  tt-gds-dtl.
        assign
          tt-gds-dtl.doc-code       = n-d
          tt-gds-dtl.fact-qnty      = old_doc-ord-line.qnty
          tt-gds-dtl.doc-qnty       = old_doc-ord-line.qnty
      .

     end.
  end.

output stream str close.

for each tt-doc-line :
    create tt-parts.
    buffer-copy tt-doc-line except tt-doc-line.status_ to tt-parts .
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

 run corr-rcv-from-rt ( input substitute("ОР|&1" ,par-doc-code ) ) no-error .


 run waitfram-show in this-procedure ("Создание ЗАПР " + caps({&expense})) .
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
    v-cntxt-cash-pay
    v-cntxt-base-code
    tt-doc-line
    tt-gds-dtl
    tt-parts
    no
    yes
    v-no-ask
    no-error }
    if error-status:error then do :
       if not is-rt  then
        message "Не удалось добавить товар в расходную накладную !"
        skip "Ошибка из lib-trn_copy-inqu "
        error-status :get-message(1)
        view-as alert-box error buttons ok.
        return error "Не удалось добавить товар в расходную накладную !" + return-value  + error-status :get-message(1)  .
    end.

  parhandle =  ? .

  { str/calc-out.i
    parrec-doc
    parrecalc-price
    parhandle
    }

run waitfram-show in this-procedure ("Создание НАКЛ- " + caps({&expense})) .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define variable loc-ord-num as character no-undo .
define variable varchip-num-main as integer   no-undo .
define variable varchip-num      as integer   no-undo .
define variable i-doc-code as character no-undo .
{ cus/ord-code.i
  'main'
  v-cntxt-db-num
  v-cntxt-obj-type
  v-cntxt-obj-code
  i-doc-code
  loc-ord-num
  }

   create buf_ord-doc-rcv.
   buffer-copy old_trn-ord-doc to buf_ord-doc-rcv
   assign
     buf_ord-doc-rcv.doc-type = {&ord-req}
     buf_ord-doc-rcv.status_  = {&ord-rcv}
     buf_ord-doc-rcv.rcv-code = loc-ord-num
   .
 run create-chain in this-procedure (
     loc-ord-num
     ,'rcv'
     ,new_trn-doc.doc-code
     ,'trn'
     ,''
     ,'' ).
run clos-trn in this-procedure (new_trn-doc.doc-code) no-error .

if not error-status :error then do:
 run cus/ordorcls.p ( input parparentproc, input recid(old_trn-ord-doc) , input false ) no-error .
 if  old_trn-ord-doc.status_ = {&ord-req} or error-status :error then do:
    run waitfram-hide in this-procedure .
    UNDO MAIN-BLOCK, return error substitute(" Нельзя закрыть заказ! &1 &2" , return-value , error-status :get-message(1)   ) .
 end.
end.
else do:
    run waitfram-hide in this-procedure .
    UNDO MAIN-BLOCK, return error 'Нельзя закрыть накладную !'.
end.
  /*пока не убиваю
   define buffer buf_i_trn-doc for ub.trn-doc  .
   find first buf_i_trn-doc exclusive-lock
         where buf_i_trn-doc.out-code = new_trn-doc.doc-code and
               buf_i_trn-doc.status_  = {&inquiry} and
               buf_i_trn-doc.flag_    = false    no-error .
        if available buf_i_trn-doc then do:
            run str/del-doc.p
            ( input  parparentproc,
              input  buf_i_trn-doc.doc-code,
              input  v-cntxt-db-num,
              input  "del-doc.err",
              input  ?,
              input  ?,
              input  v-cntxt-userid,
              input  new_trn-doc.doc-code,
              input  varchip-num-main,
              output varchip-num ).
        end.
    */

run waitfram-hide in this-procedure .
 if v-err2 then do:
    if not is-rt  then
    message "Не все товары включены в накладную. Список невошедших товаров в файле no-price.txt" view-as alert-box information .
 end.
end.
/* перевод запроса в накл - */


procedure clos-trn :

  do
  on error undo, return error return-value
  :
define input parameter p-trn-code as character no-undo .


define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .
assign
  varmode         = {&close-doc}
  varstatus       = {&inquiry}
  varflag         = true
  varcopystatus   = {&g___new}
  varcopyflag     = false
  varcheck-return = true
  varchg-inv      = true
  .

run str/trn-graf.p
  ( input  p-trn-code ,
    input  v-cntxt-db-num ,
    input  varmode ,
    output varstatus ,
    output varflag ,
    output varcopystatus ,
    output varcopyflag
  ) no-error .

if error-status:error then do:
   if error-status :get-message(1) <> "" or  return-value = ""
      then do:
     if not is-rt  then
     message "Ошибка при вызове trn-graf.p." skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error.
   end.
   else do:
    if not is-rt  then
     message return-value
     view-as alert-box error.
   end.
   return error return-value + error-status :get-message(1) .
end.

run str/trn-stat.p (
    input  parparentproc ,
    input  this-procedure ,
    input  varmode,
    input  p-trn-code,
    input  varcheck-return,
    input  v-cntxt-db-num,
    input  v-cntxt-in-ov,
    input  v-cntxt-rsrv-time,
    input  v-cntxt-load-time,
    input  v-cntxt-holidays,
    input  NO,
    output varchg-inv,
    output table gds-list)
    no-error.
if error-status:error then do:
   if not is-rt then
   message
     vss-workfile vss-revision vss-description skip
     "Ошибка при принудительном закрытии документа " p-trn-code skip
     skip
     return-value skip
     trim(error-status :get-message(1))
     trim(error-status :get-message(2))
     trim(error-status :get-message(3))
     trim(error-status :get-message(4))
     trim(error-status :get-message(5)) skip
     view-as alert-box error.
   return error "Ошибка при принудительном закрытии документа " + return-value  + error-status :get-message(1) .
end.
  end.

end procedure. /* clos-trn */

procedure cloce-ord :
define output parameter p-ask as logical   no-undo .
  do
  on error undo, return error return-value
  :

  p-ask = true .
  end.

end procedure. /* cloce-ord */


procedure cb_cloce-quest-neg :
define output parameter p-is-negostmess as logical   no-undo .
  do
  on error undo, return error return-value
  :
/* В РТ сообщения о резервировании в отрсторону не показывать */
   if is-rt then
      p-is-negostmess = false .
   else
      p-is-negostmess = true  .

  end.

end procedure. /* cb_cloce-quest-neg */


procedure corr-rcv-from-rt :
/* корректировка временной таблицы по данным РТ */
define input  parameter p-ord-doc as character no-undo .

define variable v-b-code        as integer   no-undo .
define variable v-set-qnty      as decimal   no-undo .
define variable v-new-price-cli as decimal   no-undo .

define buffer buf_batchprocess for ub.batchprocess  .
define buffer buf_goods        for ub.goods  .
define buffer buf_bar-code     for ub.bar-code  .
define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv  .
define variable is-exist  as logical   no-undo .
define variable v-is-ex as logical   no-undo .


  do
  on error undo, return error return-value

  :

  if not is-rt then return .

/* Цикл нужен чтоб все строки по документу были отпущены ДЛЯ ЧИСТОТЫ ЭКСПЕРЕМЕНТА */
    for each buf_batchprocess exclusive-lock
        where buf_batchprocess.bp_type     = {&btpr-type-rt-line}
          and buf_batchprocess.bp_status   = {&btpr-normal}
          and buf_batchprocess.charkey_one = p-ord-doc
          on error undo , return error substitute(" buf_batchprocess &1" , return-value)
          :

          run waitfram-show in this-procedure ("Проверка данных присланных с РТ....") .

           release buf_batchprocess.
    end.

   /* Удалим те строки,  которых нет в РТ */
   v-is-ex = false .
   for each tt-doc-line :
        find first buf_goods no-lock where
                   buf_goods.artic     =  tt-doc-line.artic     and
                   buf_goods.prod-type =  tt-doc-line.prod-type and
                   buf_goods.prod-code =  tt-doc-line.prod-code no-error .

        v-is-ex = false .
        for each buf_bar-code no-lock where
                 buf_bar-code.gds-code = buf_goods.gds-code :
            find first  buf_batchprocess no-lock
                  where buf_batchprocess.bp_type     = {&btpr-type-rt-line}
                    and buf_batchprocess.bp_status   = {&btpr-normal}
                    and buf_batchprocess.charkey_one = p-ord-doc
                    and buf_batchprocess.key#_one    = buf_bar-code.b-code
                    no-error .
                if  available buf_batchprocess then do:
                    v-is-ex = true .
                end.
         end.

         if v-is-ex = false  then do:
            run delete-tt (
                input buf_goods.artic  ,
                input buf_goods.prod-type,
                input buf_goods.prod-code
                ) .
         end.
     end. /* for each tt-doc-line */

      /* Корректировка времменых таблиц по значениям снятых с РТ */
      for each buf_batchprocess no-lock
        where buf_batchprocess.bp_type     = {&btpr-type-rt-line}
          and buf_batchprocess.bp_status   = {&btpr-normal}
          and buf_batchprocess.charkey_one = p-ord-doc
      on error undo , return error substitute(" buf_batchprocess &1" , return-value)
      :

        assign
          v-b-code        = buf_batchprocess.key#_one
          v-set-qnty      = decimal ( buf_batchprocess.bp_execsystime )
          v-new-price-cli = decimal ( buf_batchprocess.charkey_three  )
          .

        find first buf_bar-code no-lock where
                   buf_bar-code.b-code = v-b-code no-error .

        find first buf_goods no-lock where
                   buf_goods.gds-code = buf_bar-code.gds-code no-error .

        find first  tt-doc-line  where
                    tt-doc-line.artic     = buf_goods.artic and
                    tt-doc-line.prod-type = buf_goods.prod-type and
                    tt-doc-line.prod-code = buf_goods.prod-code no-error .
        if available tt-doc-line then do:
           if v-set-qnty  = 0 then do:  /* Нулевое количество  по РТ - удаляем */
             run delete-tt (
                input buf_goods.artic  ,
                input buf_goods.prod-type,
                input buf_goods.prod-code
                ).
           end.
           else do:
              tt-doc-line.doc-qnty  = v-set-qnty * tt-doc-line.cli-base-rate.
              tt-doc-line.fact-qnty = v-set-qnty * tt-doc-line.cli-base-rate.
              tt-doc-line.cli-qnty  = v-set-qnty.

    /*          if v-new-price-cli <> 0 and v-new-price-cli <> ? then
                  assign
                      tt-doc-line.price-cli   = v-new-price-cli
                      tt-doc-line.price-rubl  = tt-doc-line.price-cli * tt-doc-line.cli-base-rate
                      tt-doc-line.price-base  = tt-doc-line.price-rubl / tt-trn-doc.base-rate * tt-trn-doc.base-scale
                  .
      */
              for each tt-gds-dtl where
                    tt-gds-dtl.artic     = buf_goods.artic and
                    tt-gds-dtl.prod-type = buf_goods.prod-type and
                    tt-gds-dtl.prod-code = buf_goods.prod-code
                    :
                 assign
                      tt-gds-dtl.doc-qnty    = tt-doc-line.doc-qnty
                      tt-gds-dtl.fact-qnty   = tt-doc-line.fact-qnty
        /*              tt-gds-dtl.price-rubl  = tt-doc-line.price-rubl
                      tt-gds-dtl.price-base  = tt-doc-line.price-base
                      */
                    .
              end.
              for each tt-parts where
                    tt-parts.artic     = buf_goods.artic and
                    tt-parts.prod-type = buf_goods.prod-type and
                    tt-parts.prod-code = buf_goods.prod-code :

                    assign
                      tt-parts.cli-qnty    = tt-doc-line.cli-qnty
                      tt-parts.qnty        = tt-doc-line.doc-qnty
                      tt-parts.fact-qnty   = tt-doc-line.fact-qnty
                      tt-parts.price-cli   = tt-doc-line.price-cli
                      tt-parts.price-rubl  = tt-doc-line.price-rubl
                      tt-parts.price-base  = tt-doc-line.price-base
                    .
              end.
           end.
        end.
    end.
 end.
end procedure. /* corr-rcv-from-rt */


procedure delete-tt :
define input  parameter p-artic as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
  do
  on error undo, return error return-value
  :

/* message 'Удаление товара в tt' p-artic .*/
  define buffer b_tt-doc-line for tt-doc-line  .

    for each tt-gds-dtl where
             tt-gds-dtl.artic     = p-artic and
             tt-gds-dtl.prod-type = p-prod-type and
             tt-gds-dtl.prod-code = p-prod-code
             :
      delete tt-gds-dtl.
    end.

    for each tt-parts where
             tt-parts.artic     = p-artic and
             tt-parts.prod-type = p-prod-type and
             tt-parts.prod-code = p-prod-code
             :
      delete tt-parts.
    end.

    for each b_tt-doc-line  where
             b_tt-doc-line.artic     = p-artic and
             b_tt-doc-line.prod-type = p-prod-type and
             b_tt-doc-line.prod-code = p-prod-code
             :
      delete b_tt-doc-line .
    end.

  end.
end procedure. /* delete-tt */

