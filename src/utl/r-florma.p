block-level on error undo, throw.
/*

$Revision: 288743b2d1c0, 2956, rls $
$Author: VRukavishnikov $
$Date: Ср апр 06 16:23:40 2022 +0300 $
$Workfile: r-florma.p $
$Archive: utl/r-florma.p $

Генерация ПН по РН

Автор: Чернова Светлана Александровна
Дата создания: 03/30/10
Author: Svetlana Chernova
Creation date: 03/30/10

*/

define variable vss-revision    as character no-undo init "$Revision: 288743b2d1c0, 2956, rls $":U .
define variable vss-author      as character no-undo init "$Author: VRukavishnikov $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:40 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-florma.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/r-florma.p $":U .
define variable vss-description as character no-undo init "Генерация ПН по РН".
{ cmp/vssrevis.i }
define variable  parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/rep-bt.i   }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ cmp/croslist.i }
{ gbl/clntattr.i }
{ cmp/strcodec.i }
{ str/lib-def.i  }
{ str/hvrdtax.i  }
{ str/lib-calc.i }
{ str/plgdsfnd.i }
{ cus/copyinqu.i }
{ trg/factord.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getsect.i def  }
{ str/in-vatp.i def  }
parParentProc  = my-handle.
define temp-table tt2-doc-line      no-undo like lib-trn_ret-line.
define buffer buf_trn-doc  for ub.trn-doc  .
define buffer buf_goods for ub.goods  .

find first g#customer no-error .
if error-status :error or not available g#customer then do:
   message "Не выбрали ни одного Контрагента! Или выбрана опция ВСЕ.  Утилита работает только со списком контрагентов ! " view-as alert-box information .
   return .
end.

run waitfram-show in this-procedure  ("Ждите...") .
for each obj-list :
  for each g#customer :
    for each buf_trn-doc no-lock where
            buf_trn-doc.fact-date <= x-date-end    and
            buf_trn-doc.fact-date >= x-date-start  and
            buf_trn-doc.doc-type   = {&expense}    and
            buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}   and
            buf_trn-doc.cli-type     = g#customer.obj-type  and
            buf_trn-doc.cli-code     = g#customer.obj-code  and
            buf_trn-doc.obj-type     = obj-list.obj-type    and
            buf_trn-doc.obj-code     = obj-list.obj-code
            :
      run clear-tt .
        run create-income (buf_trn-doc.doc-code) .
      end.
  end.
end.

run waitfram-hide in this-procedure .
message "Все" view-as alert-box information .


procedure create-income :
define input  parameter p-ex-doc-code as character no-undo .

define buffer bufe_trn-doc  for ub.trn-doc  .
define buffer bufe_doc-line for ub.doc-line  .
define buffer bufe_gds-dtl  for ub.gds-dtl  .
define buffer bufe_parts    for ub.parts  .

define buffer new_trn-doc  for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_gds-dtl  for ub.gds-dtl  .
define buffer buf_parts    for ub.parts  .
define buffer buf_sysconf for ub.sysconf  .

define variable v-vat-type as character no-undo .
define variable v-new-doc-code as character no-undo .
define variable varchg-inv as logical no-undo .

  do
  on error undo, return error return-value
  :

find first buf_sysconf where buf_sysconf.host-code = v-cntxt-host-code-obj no-lock no-error .

 find first bufe_trn-doc no-lock  where
            bufe_trn-doc.doc-code = p-ex-doc-code no-error .


    run doc-code in this-procedure
      ( input  "main":U,
        input  v-cntxt-obj-type,
        input  v-cntxt-obj-code,
        input  ? ,
        output v-new-doc-code ) no-error.

      { gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-nakl_par} }

      for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'type-vat' then v-value-integer = thbjattr_thbj-attr.property-value-integer.
      end.
          case v-value-integer:
          when 1 or when ? then do:
            assign
              v-vat-type = {&inc-vat}.
          end.
          when 2 then do:
            assign
              v-vat-type = {&no-vat}.
          end.
          when 3 then do:
            assign
              v-vat-type = {&without-vat}.
          end.
          otherwise do:
              message   substitute(" Не верно задан атрибут 'Тип заведения НДС' (type-vat). &1 &2 &3 &4 &5" , v-cntxt-obj-type , v-cntxt-obj-code , error-status :get-message(1) , return-value , v-value-integer ) .
              return error return-value .
          end.
          end case.

    create  tt-trn-doc.
    buffer-copy  bufe_trn-doc  to    tt-trn-doc
      assign
      tt-trn-doc.pay-code             = buf_sysconf.out-pay
      tt-trn-doc.status_              = {&wayb}
      tt-trn-doc.exch-date            = bufe_trn-doc.doc-date
      tt-trn-doc.exch-scale           = 1
      tt-trn-doc.exch-rate            = 1
      tt-trn-doc.doc-code             = v-new-doc-code
      tt-trn-doc.doc-type             = {&income}
      tt-trn-doc.internal             = false
      tt-trn-doc.cr-db-num            = v-cntxt-db-num
      tt-trn-doc.vat-type             = v-vat-type
      tt-trn-doc.slt-type             = {&without-slt}
      tt-trn-doc.office               = false
      tt-trn-doc.fact-num             = 0
      tt-trn-doc.out-code             = ""
      tt-trn-doc.creid                = v-cntxt-userid
      tt-trn-doc.flag_                = false
      tt-trn-doc.ext-doc-type         = {&TDEDT_Pri_Vnesh}
      tt-trn-doc.discnt-type          = ""
      tt-trn-doc.ret-supp             = false
      tt-trn-doc.print-rubl           = true
      tt-trn-doc.hold-doc-code-child  = "no-hold":u
      tt-trn-doc.hold-doc-code-parent = "no-hold":u
      tt-trn-doc.obj-type             = v-cntxt-obj-type
      tt-trn-doc.obj-code             = v-cntxt-obj-code
    .

    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      tt-trn-doc.host-code
      }

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
      .
     if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "str/crtrndoc.i"
          view-as alert-box error
        .
     end.
    find first new_trn-doc where new_trn-doc.doc-code = v-new-doc-code  exclusive-lock no-error .

    if not available new_trn-doc then do:
      message  substitute(" Ошибка &1" , error-status :get-message(1)  , return-value ) .
      return error .
    end.


  for each  bufe_doc-line  no-lock  where
            bufe_doc-line.doc-code = bufe_trn-doc.doc-code by bufe_doc-line.line-num :

   find first buf_goods no-lock where
              buf_goods.artic     = bufe_doc-line.artic     and
              buf_goods.prod-type = bufe_doc-line.prod-type and
              buf_goods.prod-code = bufe_doc-line.prod-code no-error .

    { gbl/gdsobjcr.i
      tt-trn-doc.obj-type
      tt-trn-doc.obj-code
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      ub.gds-obj
      no-error }

      if not available ub.gds-obj then do:
        find first ub.gds-obj no-lock where
              ub.gds-obj.obj-type = new_trn-doc.obj-type and
              ub.gds-obj.obj-code = new_trn-doc.obj-code and
              ub.gds-obj.gds-code = buf_goods.gds-code no-error .
              if not available ub.gds-obj then do:
                  message  substitute("Товар &1 &2 &3  &4 &5" ,
                                    buf_goods.gds-code,
                                    buf_goods.artic,
                                    buf_goods.gds-name,
                                    error-status :get-message(1) ,
                                    return-value  ) .
                  undo, return error .
              end.
      end.

      if ub.gds-obj.inv-on = true then do:
            message  substitute("Товар &1 &2 &3  находится в инвентаризации. Прием документов невозможен." ,
                              buf_goods.gds-code ,
                              buf_goods.artic ,
                              buf_goods.gds-name
                              ) .
            undo, return error .
      end.
        create tt2-doc-line .
        BUFFER-COPY bufe_doc-line  to tt2-doc-line
          assign
            tt2-doc-line.cli-qnty       = bufe_doc-line.fact-qnty
            tt2-doc-line.doc-qnty       = bufe_doc-line.fact-qnty
            tt2-doc-line.fact-qnty      = bufe_doc-line.fact-qnty
            tt2-doc-line.price-cli      = bufe_doc-line.price-rubl
            tt2-doc-line.price-rubl     = bufe_doc-line.price-rubl
            tt2-doc-line.price-base     = bufe_doc-line.price-base
            tt2-doc-line.doc-code       = v-new-doc-code
            tt2-doc-line.status_        = {&wayb}
            tt2-doc-line.ext-doc-type   = {&TDEDT_Pri_Vnesh}
            tt2-doc-line.slt-pc         = 0
            tt2-doc-line.cli-base-rate  = 1
            tt2-doc-line.line-num       = next-value (s-line-num, {&db-name_schema})
            tt2-doc-line.unit-cli       = buf_goods.unit-base
            tt2-doc-line.doc-density    = 1
            tt2-doc-line.fact-density   = 1
            tt2-doc-line.obj-code       = new_trn-doc.obj-code
            tt2-doc-line.obj-type       = new_trn-doc.obj-type
            .

          for each bufe_gds-dtl no-lock where
                   bufe_gds-dtl.doc-code  =  bufe_trn-doc.doc-code and
                   bufe_gds-dtl.artic     =  bufe_doc-line.artic and
                   bufe_gds-dtl.prod-type =  bufe_doc-line.prod-type and
                   bufe_gds-dtl.prod-code =  bufe_doc-line.prod-code
                   :
                  create tt-gds-dtl.
                  BUFFER-COPY bufe_gds-dtl  to tt-gds-dtl
                    assign
                      tt-gds-dtl.doc-code     = v-new-doc-code
                      tt-gds-dtl.doc-qnty     = bufe_gds-dtl.fact-qnty
                      tt-gds-dtl.fact-qnty    = bufe_gds-dtl.fact-qnty
                      tt-gds-dtl.price-base   = bufe_gds-dtl.price-base
                      tt-gds-dtl.price-rubl   = bufe_gds-dtl.price-rubl
                      tt2-doc-line.price-cli  = bufe_gds-dtl.price-rubl
                      tt2-doc-line.price-rubl = bufe_gds-dtl.price-rubl
                      tt2-doc-line.price-base = bufe_gds-dtl.price-base
                      tt-gds-dtl.obj-code     = new_trn-doc.obj-code
                      tt-gds-dtl.obj-type     = new_trn-doc.obj-type

                      .
            end.

      create tt-parts.
      buffer-copy tt2-doc-line except tt2-doc-line.status_ to tt-parts .
        assign
          tt-parts.prod-type      = tt2-doc-line.prod-type
          tt-parts.prod-code      = tt2-doc-line.prod-code
          tt-parts.artic          = tt2-doc-line.artic
          tt-parts.in-code        = new_trn-doc.doc-code
          tt-parts.out-code       = new_trn-doc.doc-code
          tt-parts.price-cli      = tt2-doc-line.price-rubl
          tt-parts.price-rubl     = tt2-doc-line.price-rubl
          tt-parts.price-base     = tt2-doc-line.price-base
          tt-parts.qnty           = tt2-doc-line.fact-qnty
          tt-parts.obj-type       = new_trn-doc.obj-type
          tt-parts.obj-code       = new_trn-doc.obj-code
          tt-parts.fact-date      = new_trn-doc.fact-date
          tt-parts.fact-num       = new_trn-doc.fact-num
          tt-parts.VAT-pc         = tt2-doc-line.vat-pc
          tt-parts.part-code      = ""
          tt-parts.PS             = ""
          tt-parts.pay-code       = new_trn-doc.pay-code
          tt-parts.status_        = no
          tt-parts.fact-qnty      = tt2-doc-line.fact-qnty
          tt-parts.supp-type      = new_trn-doc.cli-type
          tt-parts.supp-code      = new_trn-doc.cli-code
          tt-parts.rsrv-free      = ?
          tt-parts.doc-type       = new_trn-doc.doc-type
          tt-parts.cli-qnty       = tt2-doc-line.fact-qnty
          tt-parts.pl-code        = ?
          tt-parts.VAT-type       = new_trn-doc.vat-type
          tt-parts.exch-code      = 0
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
    assign
      new_trn-doc.status_    = {&wayb}
      new_trn-doc.flag_      = false
      new_trn-doc.print-rubl = true
      new_trn-doc.hold-doc-code-child  = "no-hold":u
      new_trn-doc.hold-doc-code-parent = "no-hold":u
      new_trn-doc.agnt  = tt-trn-doc.agnt
      new_trn-doc.boss  = tt-trn-doc.boss
      new_trn-doc.wrkr  = tt-trn-doc.wrkr
      new_trn-doc.fact-order = 0
      new_trn-doc.exch-scale           = 1
      new_trn-doc.exch-rate            = 1
    .

     { str/copy-in.i
          parparentproc
          recid(new_trn-doc)
          tt-trn-doc
          tt2-doc-line
          tt-doc-line-attr
          tt-gds-dtl
          tt-parts
          no
          no
          no
          yes
          this-procedure
          no-error }
          if error-status :error then do:
             message
               vss-workfile vss-revision vss-description skip
               error-status :get-message(1) skip
               return-value skip
               "str/copy-in.i"
               view-as alert-box error
             .
          end.

     run gbl/calc-trn.p ( parParentProc  , recid(new_trn-doc)).
      find current new_trn-doc exclusive-lock .
          new_trn-doc.tot-cli =  new_trn-doc.tot-calc.

      run str/trn-stat.p (
          input  parparentproc ,
          input  this-procedure ,
          input  {&close-fact} ,
          input  new_trn-doc.doc-code,
          input  false /* проверка старого возврата */ ,
          input  v-cntxt-db-num,
          input  false /* проверка переоценки */,
          input  buf_sysconf.rsrv-time,
          input  buf_sysconf.load-time,
          input  buf_sysconf.holidays,
          input  false ,
          output varchg-inv ,
          output table gds-list)
          no-error.
          if error-status :error then do:
             message
               vss-workfile vss-revision vss-description skip
               error-status :get-message(1) skip
               return-value skip
               ""
               view-as alert-box error
             .
          end.

  end.

end procedure. /* create-income */


procedure clear-tt :

  do
  on error undo, return error return-value
  :
   for each tt-trn-doc:
    delete tt-trn-doc.
   end.

    for each tt2-doc-line :
        delete tt2-doc-line .
    end.
    for each tt-doc-line :
        delete tt-doc-line .
    end.
    for each tt-gds-dtl :
        delete tt-gds-dtl .
    end.
    for each tt-parts:
        delete tt-parts .
    end.
    for each lib-trn_ret-doc :
      delete lib-trn_ret-doc.
    end.
    for each lib-trn_ret-line :
      delete lib-trn_ret-line      .
    end.
    for each lib-trn_ret-line-attr :
      delete lib-trn_ret-line.
    end.
    for each lib-trn_ret-dtl :
      delete lib-trn_ret-dtl.
    end.
    for each lib-trn_ret-parts :
      delete lib-trn_ret-parts .
    end.

 end.
end procedure. /* clear-tt */