block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: imp-izpr.p $
$Archive: utl/imp-izpr.p $

Создание ВНЕШНЕГО расхода по временной таблице

Автор: Чернова Светлана Александровна
Дата создания: 04/05/06
Author: Svetlana Chernova
Creation date: 04/05/06

*/
{ utl/ttzpr.i  }

define input parameter parparentproc as handle no-undo .
define input PARAMETER TABLE FOR  temp_trn-doc.
define input PARAMETER TABLE FOR  temp_doc-line.
define output parameter p-trndoc as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-izpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-izpr.p $":U .
define variable vss-description as character no-undo init "Создание ВНЕШНЕГО расхода по временной таблице".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
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
{ cmp/gds-list.i gds-list def "new shared" }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

define variable v-ext-doc-type as character no-undo .

{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }
define temp-table old_gds-dtl no-undo like ub.gds-dtl .

define buffer new_trn-doc  for ub.trn-doc  .
define buffer new_doc-line for ub.doc-line .
define buffer new_gds-dtl  for ub.gds-dtl .

define buffer t_trn-doc  for ub.trn-doc  .
define buffer t_doc-line for ub.doc-line .
define buffer t_gds-dtl  for ub.gds-dtl .
define buffer t_goods    for ub.goods .

define variable kkk  as integer no-undo .
define variable p-q  like ub.ord-dtl.qnty no-undo .

define variable parrec-doc      as recid    no-undo .
define variable parrecalc-price as logical  no-undo init false .
define variable parhandle       as handle   no-undo .
define variable v-root-node     as integer  no-undo .
define variable varconf-attr   as character no-undo.
define variable varconf-par-cd as character no-undo.
define variable varpar-type    as character no-undo.
define variable n-d as character no-undo .
define variable v-host-code as integer   no-undo .

 run waitfram-show ("Формирование временных таблиц ....") .
  for each  temp_trn-doc  no-lock :

    if temp_trn-doc.obj-code = 0 or temp_trn-doc.obj-code = ? then do:
        temp_trn-doc.obj-code = v-cntxt-obj-code.
        temp_trn-doc.obj-type = v-cntxt-obj-type.
    end.
      { gbl/hostcode.i
        temp_trn-doc.obj-type
        temp_trn-doc.obj-code
        v-host-code
        }
      find first ub.sysconf where ub.sysconf.host-code = v-host-code no-lock.
      if lookup (string(ub.sysconf.purch-code), {&purchase-input-codes}) = 0 then do:
          return error substitute("Неверный код типа приобретения по умолчанию. "  ).
      end.

    if temp_trn-doc.cli-code = 0 or temp_trn-doc.cli-code = ? then do:
       temp_trn-doc.cli-code = ub.sysconf.sale-code.
       temp_trn-doc.cli-type = {&cmp}.
    end.


    v-ext-doc-type = {&TDEDT_Ras_Vnesh} .
    run doc-code in this-procedure
      (input  "main":U,
        input  v-cntxt-obj-type,
        input  v-cntxt-obj-code,
        input  "",
        output n-d ) no-error.
    if error-status:error then do:
      return error "Ошибка при генерации номера документа. chip".
    end.
    p-trndoc = p-trndoc + n-d  + "," .
    create  tt-trn-doc.
    buffer-copy temp_trn-doc to tt-trn-doc
      assign
        tt-trn-doc.pay-code       = v-cntxp-out-pay
        tt-trn-doc.status_        = "temp"
        tt-trn-doc.doc-code       = n-d
        tt-trn-doc.doc-date       = to-day
        tt-trn-doc.doc-type       = {&expense}
        tt-trn-doc.internal       = false
        tt-trn-doc.cr-db-num      = g#db-num
        tt-trn-doc.vat-type       = {&inc-vat}
        tt-trn-doc.slt-type       = {&without-slt}
        tt-trn-doc.office         = false
        tt-trn-doc.fact-num       = 0
        tt-trn-doc.inv-num        = temp_trn-doc.doc-code
        tt-trn-doc.out-code       = temp_trn-doc.doc-code
        tt-trn-doc.PS             = "Сформирована по заказу № " +  temp_trn-doc.doc-code + " На " + string(temp_trn-doc.doc-date) + " " + temp_trn-doc.PS
        tt-trn-doc.creid          = userid("ub")
        tt-trn-doc.flag_          = false
        tt-trn-doc.ext-doc-type   = v-ext-doc-type
        tt-trn-doc.discnt-type    = {&percent}
        tt-trn-doc.ret-supp       = false
        tt-trn-doc.print-rubl     = true
        tt-trn-doc.hold-doc-code-child  = "no-hold":u
        tt-trn-doc.hold-doc-code-parent = "no-hold":u
        tt-trn-doc.obj-code       = temp_trn-doc.obj-code
        tt-trn-doc.obj-type       = temp_trn-doc.obj-type
        tt-trn-doc.cli-code       = temp_trn-doc.cli-code
        tt-trn-doc.cli-type       = temp_trn-doc.cli-type
        tt-trn-doc.host-code      = v-host-code
    .

    { gbl/baserate.i
      tt-trn-doc.host-code
      tt-trn-doc.doc-date
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      no-error   }

      /* coздание шапки в базе */

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
      sysconf.purch-code
      no-error }
      .

    find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .

    if not avail new_trn-doc then do:
        undo, return error return-value + "Ошибка  создания шапки документа " + error-status :get-message(1)  .
    end.

    assign
        new_trn-doc.exch-rate  = tt-trn-doc.exch-rate
        new_trn-doc.exch-scale = tt-trn-doc.exch-scale
        new_trn-doc.base-rate  = tt-trn-doc.base-rate
        new_trn-doc.base-scale = tt-trn-doc.base-scale
        new_trn-doc.exch-date  = to-day
        new_trn-doc.exch-code  = tt-trn-doc.exch-code
        new_trn-doc.status_    = {&inquiry}  /* +++ */
        new_trn-doc.flag_      = false       /* +++ */
        new_trn-doc.print-rubl = true
        new_trn-doc.hold-doc-code-child  = "no-hold":u
        new_trn-doc.hold-doc-code-parent = "no-hold":u
        parrec-doc = recid(new_trn-doc)
      .

    define buffer buf_goods for ub.goods  .

    for each  temp_doc-line no-lock  where
              temp_doc-line.doc-code = temp_trn-doc.doc-code :

      find first buf_goods where buf_goods.gds-code  = temp_doc-line.gds-code  no-lock no-error .

        { gbl/rootnode.i
          temp_doc-line.artic
          temp_doc-line.prod-type
          temp_doc-line.prod-code
          v-root-node
          }

        create tt-doc-line .
        BUFFER-COPY temp_doc-line to tt-doc-line
          assign
              tt-doc-line.cli-qnty       = temp_doc-line.fact-qnty
              tt-doc-line.doc-qnty       = temp_doc-line.fact-qnty
              tt-doc-line.fact-qnty      = temp_doc-line.fact-qnty
              tt-doc-line.price-cli      = temp_doc-line.price-rubl
              tt-doc-line.price-rubl     = temp_doc-line.price-rubl
              tt-doc-line.price-base     = tt-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
              tt-doc-line.doc-code       = n-d
              tt-doc-line.status_        = "temp"
              tt-doc-line.ext-doc-type   = v-ext-doc-type
              tt-doc-line.slt-pc         = 0
              tt-doc-line.cli-base-rate  = 1
              tt-doc-line.line-num       = next-value (s-line-num, {&db-name_schema})
              tt-doc-line.prt-root       = buf_goods.prt-root
              tt-doc-line.unit-cli       = buf_goods.unit-base
              tt-doc-line.obj-code       = tt-trn-doc.obj-code
              tt-doc-line.obj-type       = tt-trn-doc.obj-type
              .
          create old_gds-dtl.
          BUFFER-COPY tt-doc-line to old_gds-dtl
            assign
              old_gds-dtl.doc-code  = temp_trn-doc.doc-code
              old_gds-dtl.doc-qnty  = temp_doc-line.fact-qnty
              old_gds-dtl.prt-code  = v-root-node
            .

        { gbl/gdsobjcr.i
          tt-doc-line.obj-type
          tt-doc-line.obj-code
          tt-doc-line.artic
          tt-doc-line.prod-type
          tt-doc-line.prod-code
          ub.gds-obj
          no-error }
          /* признаки  для расходной только корневые */
        p-q = 0 .
        kkk = 0 .
        for each   old_gds-dtl where
                  old_gds-dtl.doc-code  = temp_trn-doc.doc-code    and
                  old_gds-dtl.artic     = temp_doc-line.artic      and
                  old_gds-dtl.prod-code = temp_doc-line.prod-code  and
                  old_gds-dtl.prod-type = temp_doc-line.prod-type :
        kkk = kkk + 1 .
        create tt-gds-dtl .
        buffer-copy  old_gds-dtl to  tt-gds-dtl.
          assign
            tt-gds-dtl.doc-code       = n-d
            tt-gds-dtl.fact-qnty      = temp_doc-line.fact-qnty
            tt-gds-dtl.doc-qnty       = temp_doc-line.fact-qnty
            tt-gds-dtl.ov = true
        .

        end.
    end.

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

    /*
    for each tt-doc-line :  message 'doc-line' skip tt-doc-line.doc-code  tt-doc-line.artic tt-doc-line.fact-qnty  tt-doc-line.price-rubl  . end.
    for each tt-gds-dtl :  message  'gds-dtl'  skip  tt-gds-dtl.doc-code    tt-gds-dtl.artic tt-gds-dtl.fact-qnty   tt-gds-dtl.price-rubl  tt-gds-dtl.prt-code     . end.
    for each tt-parts   :  message  'parts'    skip  tt-parts.out-code      tt-parts.artic   tt-parts.fact-qnty        . end.
    */

    run waitfram-show ("Создание ЗАПР " + caps({&expense})) .
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
      v-cntxp-out-pay
      base-code
      tt-doc-line
      tt-gds-dtl
      tt-parts
      no
      yes
      yes
      no-error }
      if error-status:error then do :
          return error return-value + error-status :get-message(1) + " Не удалось добавить товар в расходную накладную !" .
      end.

      parhandle =  ? .

    { str/calc-out.i
      parrec-doc
      parrecalc-price
      parhandle
      }
    /* run clos-trn in this-procedure (new_trn-doc.doc-code) no-error . */
  end.
run waitfram-hide in this-procedure .
end.



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
  varcheck-return = false
  varchg-inv      = false
  .

run str/trn-stat.p (
    input  parparentproc ,
    input this-procedure ,
    input  varmode,
    input  p-trn-code,
    input  varcheck-return,
    input  v-cntxt-db-num,
    input  v-cntxp-in-ov,
    input  v-cntxp-rsrv-time,
    input  v-cntxp-load-time,
    input  v-cntxp-holidays,
    input  NO,
    output varchg-inv,
    output table gds-list)
    no-error.
    if error-status:error then do:
      return error substitute("Ошибка закрытия документа &3 &2 &1" , error-status :error , return-value ,  p-trn-code ) .
    end.
  end.

end procedure. /* clos-trn */