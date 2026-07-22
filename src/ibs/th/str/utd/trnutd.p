block-level on error undo, throw.
/*

$Revision: 7162739bf0ea, 3555, rls $
$Author: ARostovtsev $
$Date: 2023/11/27 08:31:18 $
$Workfile: trnutd.p $
$Archive: ibs/th/str/utd/trnutd.p $

Импорт накладных из временной таблицы все надо переделать.

Автор: Чернова Светлана Александровна
Дата создания: 04/05/06
Author: Svetlana Chernova
Creation date: 04/05/06

*/

{ ibs/th/str/utd/trn/tt516.i}

&glob pt1_cost 'TSFCST':U
&glob pt2_sale 'TSFRET':U
&glob pt3_mpl  'TSFOPT':U
&glob pt4_rms  'TSFPRC':U
&glob pt4_tsd  'TSFTSD':U

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  PARAMETER TABLE FOR  temp_trn-doc.
define input  PARAMETER TABLE FOR  temp_doc-line.
define input  PARAMETER TABLE FOR  tt-excisemarks.
define output parameter p-msg    as character no-undo .
define output parameter p-ok-doc as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 7162739bf0ea, 3555, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: 2023/11/27 08:31:18 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trnutd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ibs/th/str/utd/trnutd.p $":U .
define variable vss-description as character no-undo init "Импорт накладных из временной таблицы".
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
{ str/getctxtp.i def }
{ utl/ora-icli.i }
{ trg/factord.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getsect.i def }
{ str/in-vatp.i def  }
{ cmp/trg-def.i }
{ str/trdcalib.i }
{ ref/gds-attr.i }
{ utl/gtin.i }
{ str/utd-attr.i}

{ gbl/objsrv.i }

define temp-table tt2-doc-line      no-undo like lib-trn_ret-line.
define temp-table tt2-doc-line-attr no-undo like lib-trn_ret-line-attr.
define temp-table anlz-bc no-undo
field b-c as integer
index pi b-c.

define variable v-end-message as character no-undo .

define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-in-ov as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time  as integer   no-undo .
define variable v-cntxt-load-time  as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .

define variable v-ext-doc-type as character no-undo .
define variable v-specif as logical   no-undo .


define buffer new_trn-doc  for ub.trn-doc  .
define buffer new_doc-line for ub.doc-line .
define buffer new_gds-dtl  for ub.gds-dtl .
define buffer new_parts for ub.parts .

define buffer t_trn-doc  for ub.trn-doc  .
define buffer t_doc-line for ub.doc-line .
define buffer t_gds-dtl  for ub.gds-dtl .
define buffer buf_goods  for ub.goods .
define buffer buf_contract for ub.contract  .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_marking  for ub.marking.
define buffer buf_utd-marking-lines  for ub.utd-marking-lines.

define variable parrec-doc      as recid    no-undo .
define variable parrecalc-price as logical  no-undo init false .
define variable parhandle       as handle   no-undo .
define variable v-root-node     as integer  no-undo .
define variable par-doc-code as character no-undo .

define variable p-type             as character no-undo .
define variable v-stroka-protocol  as character no-undo .
define variable v-protocol-date    as date      no-undo .
define variable v-protocol-time    as integer   no-undo .
define variable v-logical          as logical   no-undo .
define variable n-d as character no-undo .
define variable v-ret-supp as logical   no-undo .
define variable v-doc-type as character no-undo .
define variable v-purch-code-ch as character no-undo .
define variable v-purch-code as integer   no-undo .
define variable v-purch-code-name as character no-undo .
define variable v-discnt-type  as character no-undo .
define variable v-status_     as character no-undo .
define variable v-print-rubl as logical   no-undo .
define variable v-curr-r-b as character no-undo .
define variable vt-host-code as integer   no-undo .
define variable vt-obj-type as character no-undo .
define variable vt-obj-code      as integer   no-undo .
define variable line-rec as recid no-undo .
define buffer bufo_clients for ub.clients  .
define variable  k as integer   no-undo .
define variable v-str-txt as character no-undo .

 /*Для МПЛ*/
define variable v-fact-order as decimal   no-undo .
define variable v-plt-id as integer   no-undo .
define variable v-plt-db-num as integer   no-undo .
define variable v-pdf-id as integer   no-undo .
define variable v-pdf-db as integer   no-undo .
define variable v-sale-price-base as decimal   no-undo .
define variable v-sale-price-rubl as decimal   no-undo .
define variable v-road-tax-base as decimal   no-undo .
define variable v-road-tax-rubl as decimal   no-undo .
define variable v-excise-base as decimal   no-undo .
define variable v-excise-rubl as decimal   no-undo .
define variable v-main-b-code as integer   no-undo .
define variable is-tsd as logical no-undo .
define variable is-egais as logical no-undo .
define variable is-unit-error   as logical no-undo .
define variable v-internal      as logical no-undo .
define variable v-marking-type as character no-undo.
define variable v-type          as character no-undo.

/* Для ОСУ */
define variable vGT as integer no-undo .
define variable vGtin as character no-undo .
define variable vGtinDocQnty as decimal no-undo .
define variable vGtinFactQnty as decimal no-undo .
define variable vGtinSumDocQnty as decimal no-undo .
define variable v-need-corr-parts as logical no-undo init false .

/*Для ВСД (ФГИС Меркурий) */
define variable v-mercury-value as character no-undo .
define variable v-mercury-type  as character no-undo .
define variable v-mercury-prod as logical no-undo init false .

define variable v-mess-in-doc as character no-undo .
define variable v-in-doc-mode as character no-undo .

define variable varnext-prev as logical no-undo .
define variable br-handle    as handle  no-undo .
define variable bf-handle    as handle  no-undo .
define variable v-doc-rec    as recid   no-undo .
define variable varline-rec  as recid   no-undo .

/*define variable objMarks as class excisemarks no-undo.*/

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  for each  temp_trn-doc :
    for each temp_doc-line where temp_doc-line.line-num = temp_trn-doc.line-num :
      if temp_doc-line.doc-code <> temp_trn-doc.doc-code then do:
        assign
          v-end-message =  substitute("Не верно указан doc-code &1 &2  товар &3" ,
                                      temp_doc-line.doc-code ,
                                      temp_trn-doc.doc-code ,
                                      temp_doc-line.gds-code
                                      )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo, return error v-end-message.
      end.
    end.
  end.

  run get-db-num in parparentproc (output v-cntxt-db-num ) .
  run get-userid in parparentproc (output v-cntxt-userid ) .
  
  if num-entries (v-cntxt-userid) > 1 
  then do:
    v-cntxt-userid = entry (1, v-cntxt-userid).
    is-egais = true.
  end.

  { gbl/curr-r-b.i
    v-curr-r-b
  }
  if v-curr-r-b = {&r-b-base} then v-print-rubl = false .
  else v-print-rubl = true .

  p-ok-doc = 0 .
  
  find first  temp_trn-doc no-lock .
  run clear-tt .
  find first bufo_clients no-lock where
             bufo_clients.obj-type  = temp_trn-doc.obj-type  and
             bufo_clients.obj-code  = temp_trn-doc.obj-code  no-error .

  if error-status :error then do:
          assign
          v-end-message =  substitute(" Не найден объект &1 &2 &3 &4" , temp_trn-doc.obj-type , temp_trn-doc.obj-code , error-status :get-message(1) , return-value )
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
          undo, return error v-end-message.
  end.

  { gbl/hostcode.i
    temp_trn-doc.obj-type
    temp_trn-doc.obj-code
    temp_trn-doc.host-code
    no-error }
  if error-status :error then do:
    assign
        v-end-message =  substitute("Не верно указан объект &1 &2 " ,
        temp_trn-doc.obj-type ,
        temp_trn-doc.obj-code ).

    run pcall-log-file in p-log-handle (input v-end-message) .
    undo, return error v-end-message.
  end.

  assign
    vt-host-code          = temp_trn-doc.host-code
    vt-obj-type           = temp_trn-doc.obj-type
    vt-obj-code           = temp_trn-doc.obj-code
    v-cntxt-host-code-obj = temp_trn-doc.host-code
    v-cntxt-obj-code      = temp_trn-doc.obj-code
    v-cntxt-obj-type      = temp_trn-doc.obj-type
  .
  if temp_trn-doc.vat-type = ""
  or temp_trn-doc.vat-type = ?
  then do:

    { gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-nakl_par} }
  
    for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'type-vat' then v-value-integer = thbjattr_thbj-attr.property-value-integer.
    end.
    case v-value-integer:
      when 1 or when ? then do:
        assign
          temp_trn-doc.vat-type = {&inc-vat}.
      end.
      when 2 then do:
        assign
          temp_trn-doc.vat-type = {&no-vat}.
      end.
      when 3 then do:
        assign
          temp_trn-doc.vat-type = {&without-vat}.
      end.
      otherwise do:
          v-end-message =  substitute(" Не верно задан атрибут 'Тип заведения НДС' (type-vat). &1 &2 &3 &4 &5" , temp_trn-doc.obj-type , temp_trn-doc.obj-code , error-status :get-message(1) , return-value , v-value-integer ) .
          run pcall-log-file in p-log-handle (input v-end-message) .
          undo, return error v-end-message.
      end.
    end case.
  end.

  { gbl/curobjdt.i
    temp_trn-doc.obj-type
    temp_trn-doc.obj-code
    to-day
    no-error }

  if error-status :error then do:
          assign
          v-end-message =  substitute(" Ошибка &1 &2 &3 &4" , temp_trn-doc.obj-type , temp_trn-doc.obj-code , error-status :get-message(1) , return-value )
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
          undo, return error v-end-message.
  end.

  if vt-host-code <>   v-cntxt-host-code-obj
  then do:
    assign
      v-end-message =  substitute(" Не верно указан код фирмы: &1 ( по объектам должен быть :&2) " , temp_trn-doc.host-code , v-cntxt-host-code-obj  )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo, return error v-end-message.
  end.

    


  if temp_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
  then do:
    if available buf_contract
    then do:
      if buf_contract.curr-code <> temp_trn-doc.exch-code
      then do:
        v-end-message =  substitute("По договору &3   ожидалась валюта &1  пришла &2 " ,
                                    buf_contract.curr-code,
                                    temp_trn-doc.exch-code,
                                    temp_trn-doc.contract-code ) .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo, return error v-end-message.
      end.
    end.
  end.

  if not (temp_trn-doc.cli-type = {&cmp} or temp_trn-doc.cli-type = {&prs} or temp_trn-doc.cli-type = {&stock} or temp_trn-doc.cli-type = {&shop}) /*для oracle вообще не присылают, значит из tsd*/ 
  then do: 
    run who-cli-ora in this-procedure (
       input  temp_trn-doc.cli-code ,
       output temp_trn-doc.cli-type ,
       output temp_trn-doc.cli-code
       ) no-error .
    if error-status :error then return error return-value .
  end.
  else do:
    if not is-egais then is-tsd = true.
  end.

  /* *******************************88888   */
  /*
              temp_trn-doc.wrkr         =  .
              temp_trn-doc.agnt         =  .
              temp_trn-doc.boss         =  .
              */

  /* Если не приход то все принимаем в национальной валюте */
  if temp_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh} then do:
     temp_trn-doc.exch-code = 0 .
     temp_trn-doc.exch-rate  = 1.
     temp_trn-doc.exch-scale = 1.
  end.

  if temp_trn-doc.exch-code = ? then do:
      assign
        temp_trn-doc.exch-code = 0
        temp_trn-doc.exch-rate  = 1
        temp_trn-doc.exch-scale = 1
      .
      v-end-message =  substitute("Предупреждение !!! Не верно введена валюта ПОСТВЩИКА код &1 , меняю на национальную " ,              temp_trn-doc.exch-code   ) .
      run pcall-log-file in p-log-handle (input v-end-message) .

  end.


  if temp_trn-doc.exch-rate  = 0 or
     temp_trn-doc.exch-rate  = ? then do:
          assign
            temp_trn-doc.exch-code = 0
            temp_trn-doc.exch-rate  = 1
            temp_trn-doc.exch-scale = 1
          .
      v-end-message =  substitute("Предупреждение !!! Не верно введен курс = &2 валюты ПОСТВЩИКА код &1 , меняю на национальную " ,              temp_trn-doc.exch-code , temp_trn-doc.exch-rate ) .
      run pcall-log-file in p-log-handle (input v-end-message) .

  end.
  if temp_trn-doc.exch-scale  = 0 or
     temp_trn-doc.exch-scale  = ? then do:
          assign
            temp_trn-doc.exch-code = 0
            temp_trn-doc.exch-rate  = 1
            temp_trn-doc.exch-scale = 1
          .
      v-end-message =  substitute("Предупреждение !!! Не верно введен масштаб = &2 валюты ПОСТВЩИКА код &1 , меняю на национальную " ,              temp_trn-doc.exch-code , temp_trn-doc.exch-scale ) .
      run pcall-log-file in p-log-handle (input v-end-message) .

  end.

  find first ub.currency where ub.currency.curr-code = temp_trn-doc.exch-code no-error .
  if error-status :error then do:
        v-end-message =  substitute("Нет валюты с кодом &1  (&2)" ,
        temp_trn-doc.exch-code , error-status :get-message(1)   ) .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo, return error v-end-message.
  end.


  { str/getctxtp.i get this-procedure }
  case temp_trn-doc.ext-doc-type :
    when {&TDEDT_Ras_Vnesh} then do:
     assign
        v-ext-doc-type = {&TDEDT_Ras_Vnesh}
        v-doc-type     = {&expense}
        v-ret-supp     = false
        v-discnt-type    = {&percent}
        v-status_        = {&inquiry}
        v-internal       = false 
        .
    end.
    when {&TDEDT_Ras_Perem} then do:
     assign
        v-ext-doc-type = {&TDEDT_Ras_Perem}
        v-doc-type     = {&expense}
        v-ret-supp     = false
        v-discnt-type    = {&percent}
        v-status_        = {&inquiry}
        v-internal       = true
        .
    end.
    when {&TDEDT_Pri_Vnesh} then do:
     assign
        v-ext-doc-type   = {&TDEDT_Pri_Vnesh}
        v-doc-type = {&income}
        v-ret-supp     = false
        v-status_ = {&wayb}
        v-discnt-type    = ""
        v-internal       = false
        .
    end.
    when {&TDEDT_Pri_Perem} then do:
     assign
        v-ext-doc-type   = {&TDEDT_Pri_Perem}
        v-doc-type = {&income}
        v-ret-supp     = false
        v-status_ = {&wayb}
        v-discnt-type    = ""
        v-internal       = true
        .
    end.
    when {&TDEDT_Vozvrat_Vnesh} then do:
     assign
        v-ext-doc-type   = {&TDEDT_Vozvrat_Vnesh}
        v-doc-type = {&return}
        v-ret-supp     = false
        v-status_ = {&wayb}
        v-discnt-type    = {&percent}
        v-internal       = false
        .
    end.
    otherwise do:
        assign
        v-end-message =  substitute(" Не верный расширенный тип документа &1 &2 &3 &4" , temp_trn-doc.ext-doc-type , temp_trn-doc.obj-type , temp_trn-doc.obj-code , temp_trn-doc.doc-code )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo, return error v-end-message.
    end.
  end case.


  define buffer buf_sysconf for ub.sysconf  .
  find first buf_sysconf where buf_sysconf.host-code = v-cntxt-host-code-obj no-lock no-error .
  if error-status :error then do:
    assign
      v-end-message =  substitute(" Не верный расширенный тип документа &1 &2 &3 &4" , temp_trn-doc.ext-doc-type , temp_trn-doc.obj-type , temp_trn-doc.obj-code , temp_trn-doc.doc-code )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo, return error v-end-message.
  end.

  assign
    v-cntxt-cash-pay   = buf_sysconf.cash-pay
    v-cntxt-base-code  = buf_sysconf.base-code
    v-cntxt-in-ov      = buf_sysconf.in-ov
    v-cntxt-rsrv-time  = buf_sysconf.rsrv-time
    v-cntxt-load-time  = buf_sysconf.load-time
    v-cntxt-holidays   = buf_sysconf.holidays
    v-cntxp-out-pay    = buf_sysconf.out-pay
  .
  { str/getctxtp.i get this-procedure }

  run doc-code in this-procedure
    ( input  "main":U,
      input  temp_trn-doc.obj-type,
      input  temp_trn-doc.obj-code,
      input  ? ,
      output n-d ) no-error.

  if error-status:error then do:
    v-end-message =  "Ошибка при генерации номера документа. chip"  + return-value  + error-status :get-message(1) .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo, return error v-end-message.
  end.

  create  tt-trn-doc.
  buffer-copy  temp_trn-doc  to    tt-trn-doc
    assign
    tt-trn-doc.pay-code             = v-cntxp-out-pay
    tt-trn-doc.status_              = "temp"
    tt-trn-doc.doc-code             = n-d
    tt-trn-doc.doc-date             = to-day
    tt-trn-doc.doc-type             = v-doc-type
    tt-trn-doc.internal             = v-internal
    tt-trn-doc.cr-db-num            = v-cntxt-db-num
    tt-trn-doc.vat-type             = temp_trn-doc.vat-type
    tt-trn-doc.slt-type             = {&without-slt}
    tt-trn-doc.office               = false
    tt-trn-doc.fact-num             = ?
    tt-trn-doc.out-code             = temp_trn-doc.doc-code
    tt-trn-doc.PS                   = ""
    tt-trn-doc.creid                = v-cntxt-userid
    tt-trn-doc.flag_                = false
    tt-trn-doc.ext-doc-type         = v-ext-doc-type
    tt-trn-doc.discnt-type          = v-discnt-type
    tt-trn-doc.ret-supp             = v-ret-supp
    tt-trn-doc.print-rubl           = v-print-rubl
    tt-trn-doc.hold-doc-code-child  = "no-hold":u
    tt-trn-doc.hold-doc-code-parent = "no-hold":u
  .
  { gbl/hostcode.i
    tt-trn-doc.obj-type
    tt-trn-doc.obj-code
    tt-trn-doc.host-code
    }

  { gbl/baserate.i
    tt-trn-doc.host-code
    tt-trn-doc.doc-date
    tt-trn-doc.base-rate
    tt-trn-doc.base-scale
    }
    /* coздание шапки в базе */
    
  run pcall-log-file in p-log-handle ( input "n-d=" + n-d ) .
  if v-doc-type     = {&expense} then do:
    if tt-trn-doc.contract-code > 0 then do:
      find first buf_contract no-lock where
                 buf_contract.contract-code = tt-trn-doc.contract-code and
                 buf_contract.host-code     = tt-trn-doc.host-code no-error .

       if error-status :error then do:
          v-end-message =  substitute("Нет договора  фирма:&1 номер:&2  &3 &4" , tt-trn-doc.host-code , tt-trn-doc.contract-code , return-value , error-status :get-message(1)  ) .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo, return error v-end-message.
       end.

      { str/purchcon.i
        tt-trn-doc.host-code
        tt-trn-doc.contract-code
        v-purch-code-ch
        v-purch-code-name }

        v-purch-code = integer (v-purch-code-ch) .
      end.
      else do:
          if lookup (string(buf_sysconf.purch-code), {&purchase-input-codes}) = 0 then do:
             v-end-message =   substitute("Неверный код типа приобретения по умолчанию &1 _sysconf " ,buf_sysconf.purch-code ) .
             run pcall-log-file in p-log-handle ( input v-end-message ) .
             undo, return error v-end-message.
          end.
          v-purch-code = buf_sysconf.purch-code .
      end.

    if lookup (string(buf_sysconf.purch-code), {&purchase-input-codes}) = 0 then do:
             v-end-message =  "Неверный код типа приобретения по умолчанию. _sysconf".
             run pcall-log-file in p-log-handle ( input v-end-message ) .
             undo, return error v-end-message.
    end.
  end.
  do trans :
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
      v-end-message =  substitute("Ошибка при создании шапки документа  &1 &2 &3" , temp_trn-doc.doc-code , return-value , error-status :get-message(1)  ) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo, return error v-end-message.
    end.


    find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .

    if not available new_trn-doc then do:
      v-end-message = substitute(" Ошибка &1" , error-status :get-message(1)  , return-value) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo, return error v-end-message.
    end.

    assign
        new_trn-doc.contract-code  = tt-trn-doc.contract-code
        new_trn-doc.exch-rate  = tt-trn-doc.exch-rate
        new_trn-doc.exch-scale = tt-trn-doc.exch-scale
        new_trn-doc.exch-date  = to-day
        new_trn-doc.exch-code  = tt-trn-doc.exch-code
        new_trn-doc.status_    = v-status_
        new_trn-doc.flag_      = ( if v-ext-doc-type = {&TDEDT_Ras_Vnesh} then true else false )
        new_trn-doc.print-rubl = v-print-rubl
        new_trn-doc.hold-doc-code-child  = "no-hold":u
        new_trn-doc.hold-doc-code-parent = "no-hold":u
/*        new_trn-doc.agnt  = tt-trn-doc.agnt*/
/*        new_trn-doc.boss  = tt-trn-doc.boss*/
/*        new_trn-doc.wrkr  = tt-trn-doc.wrkr*/
        new_trn-doc.rcv-code = if not (is-tsd or is-egais) then "not_delete" else ""  /* нельзя будет открыть, чтоб потом изменить или удалить */
        parrec-doc = recid (new_trn-doc)
    .
    


    find first ub.utd where ub.utd.db-num = temp_trn-doc.db-num
                        and ub.utd.doc-id = temp_trn-doc.doc-id.
      
    ub.utd.doc-code = new_trn-doc.doc-code.
    temp_trn-doc.db-num = ub.utd.db-num.
    temp_trn-doc.doc-id = ub.utd.doc-id.
  
    find first utd-attr exclusive-lock where utd-attr.db-num = ub.utd.db-num and utd-attr.doc-id = ub.utd.doc-id and utd-attr.attr-code = "wrkr" no-error .
    if available (utd-attr) then do:
      new_trn-doc.wrkr =  integer (utd-attr.attr-value).
    end.  
    find first utd-attr exclusive-lock where utd-attr.db-num = ub.utd.db-num and utd-attr.doc-id = ub.utd.doc-id and utd-attr.attr-code = "agnt" no-error .
    if available (utd-attr) then do:
      new_trn-doc.agnt =  integer (utd-attr.attr-value).  
    end.  
    find first utd-attr exclusive-lock where ub.utd.db-num = utd-attr.db-num and utd-attr.doc-id = ub.utd.doc-id and utd-attr.attr-code = "boss" no-error .
    if available (utd-attr) then do:
      new_trn-doc.boss =  integer (utd-attr.attr-value).
    end.  

  
    { str/tdat-wrt.i
      new_trn-doc.doc-code
      {&trdcattr-nids}
      ub.utd.DocumentNumber
      no-error
    }
    { str/tdat-wrt.i
      new_trn-doc.doc-code
      {&trdcattr-dids}
      ub.utd.DocumentDate
      no-error
    }
    { str/tdat-wrt.i
      new_trn-doc.doc-code
      {&trdcattr-nsf}
      ub.utd.DocumentNumber
      no-error
    }
    { str/tdat-wrt.i
      new_trn-doc.doc-code
      {&trdcattr-dsf}
      ub.utd.DocumentDate
      no-error
    }    
    


/*  if (new_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or new_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh})*/
/*    then                                                                                             */
/*  do:                                                                                                */
/*    find first ub.shift-obj no-lock                                                                  */
/*      where ub.shift-obj.obj-type = new_trn-doc.obj-type                                             */
/*      and ub.shift-obj.obj-code = new_trn-doc.obj-code                                               */
/*      and ub.shift-obj.status_  = {&sht-current}                                                     */
/*      no-error .                                                                                     */
/*    if available ub.shift-obj then                                                                   */
/*    do:                                                                                              */
/*      assign                                                                                         */
/*        new_trn-doc.shift-num  = ub.shift-obj.shift-num                                              */
/*        new_trn-doc.shift-name = ub.shift-obj.shift-name                                             */
/*        new_trn-doc.shift-date = ub.shift-obj.shift-date                                             */
/*        new_trn-doc.fact-date  = ub.shift-obj.shift-date                                             */
/*        .                                                                                            */
/*    end.                                                                                             */
/*    else do:                                                                                         */
/*      new_trn-doc.fact-date  = now.                                                                  */
/*    end.                                                                                             */
/*  end.                                                                                               */
  
    k = 0 .
  
    for each  temp_doc-line  no-lock  where
              temp_doc-line.doc-code = temp_trn-doc.doc-code by temp_doc-line.line-num :
      
      find first buf_goods where buf_goods.gds-code  = temp_doc-line.gds-code no-lock no-error .

      if error-status :error then do:
        v-end-message = substitute("Ошибка: нет товара &1 &2 &3 " , temp_doc-line.gds-code , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
      end.

      temp_doc-line.artic     = buf_goods.artic .
      temp_doc-line.prod-type = buf_goods.prod-type .
      temp_doc-line.prod-code = buf_goods.prod-code .

      if v-specif = true and temp_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}  then do:
        find first ub.contract-specif no-lock where
                    ub.contract-specif.gds-code = buf_goods.gds-code and
                    ub.contract-specif.contract-num = temp_trn-doc.contract-code and
                    ub.contract-specif.host-code     = temp_trn-doc.host-code no-error .
        if not available ub.contract-specif then do:
          v-end-message =  substitute(" Товара &1 &2 нет в спецификации &3" ,
                            buf_goods.gds-code,
                            buf_goods.gds-name,
                            temp_trn-doc.contract-code ) .
          run pcall-log-file in p-log-handle (input v-end-message) .
          undo, return error v-end-message.
        end.
      end.

      assign
        temp_doc-line.artic      = buf_goods.artic
        temp_doc-line.prod-type  = buf_goods.prod-type
        temp_doc-line.prod-code  = buf_goods.prod-code
        .

      { gbl/gdsobjcr.i
        tt-trn-doc.obj-type
        tt-trn-doc.obj-code
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        ub.gds-obj
        no-error }
      /* Если не приход то все принимаем в национальной валюте */
      if temp_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh} then do:
         temp_doc-line.price-cli  = temp_doc-line.price-rubl .
      end.
      v-str-txt = "" .

      if not available ub.gds-obj then do:
        find first ub.gds-obj no-lock where
              ub.gds-obj.obj-type = tt-trn-doc.obj-type and
              ub.gds-obj.obj-code = tt-trn-doc.obj-code and
              ub.gds-obj.gds-code = buf_goods.gds-code no-error .
        if not available ub.gds-obj then do:
          v-end-message =  substitute("Товар &1 &2 &3  &4 &5" ,
                            buf_goods.gds-code,
                            buf_goods.artic,
                            buf_goods.gds-name,
                            error-status :get-message(1) ,
                            return-value  ) .
          run pcall-log-file in p-log-handle (input v-end-message) .
          undo, return error v-end-message.
        end.
      end.

      if ub.gds-obj.inv-on = true then do:
        v-end-message =  substitute("Товар &1 &2 &3  находится в инвентаризации. Прием документов невозможен." ,
                          buf_goods.gds-code ,
                          buf_goods.artic ,
                          buf_goods.gds-name
                          ) .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo, return error v-end-message.
      end.

      if temp_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} then do:
        case temp_trn-doc.price-type :
          when  {&pt4_rms} /* от rms */
          then do:
            v-str-txt = "Цена из RMS".
          end.
          when  {&pt4_tsd} /* от tsd */
          then do:
    
          end.
          when  {&pt1_cost} /* Учетная */
          then do:
            temp_doc-line.price-cli  = ub.gds-obj.avrg-rubl.
            v-str-txt = "Цена учетная".
          end.
          when  {&pt2_sale} /* Продажная переоценки */
          then do:
            temp_doc-line.price-cli  = ub.gds-obj.price-sale.
            v-str-txt = "Цена переоценки по объекту на момент создания".
          end.
          when  {&pt3_mpl} /* МПЛ */
          then do:
            run factord-end-day in this-procedure (input new_trn-doc.doc-date , output v-fact-order ).
            /* баркод по главному коду*/
            { gbl/gdsbcode.i buf_goods.gds-code ? v-main-b-code }
            /* узнаем цену не по переоценке а по МПЛ */
            run str/set-mppr.p (
               input  true
              ,input  new_trn-doc.cli-type
              ,input  new_trn-doc.cli-code
              ,input  v-main-b-code
              ,input  v-main-b-code
              ,input  new_trn-doc.obj-type
              ,input  new_trn-doc.obj-code
              ,input  temp_doc-line.fact-qnty
              ,input  0
              ,input  string(new_trn-doc.pay-code)
              ,input  ""
              ,input  v-fact-order
              ,output v-plt-id
              ,output v-plt-db-num
              ,output v-pdf-id
              ,output v-pdf-db
              ,output v-sale-price-base
              ,output v-sale-price-rubl
              ,output v-road-tax-base
              ,output v-road-tax-rubl
              ,output v-excise-base
              ,output v-excise-rubl
              ) no-error .
              temp_doc-line.price-cli  = v-sale-price-rubl.
              v-str-txt = substitute("Цена по МПЛ  ТПЛ &1(БД&2) ДНЦ &3(БД&4)",v-plt-id,v-plt-db-num, v-pdf-id,v-pdf-db).
          end.
          otherwise do:
              v-end-message =  substitute(" trn-doc.Line-num &1 №Документа &2 не корректное значение поля price-type = &3" ,
                                temp_trn-doc.line-num,
                                temp_trn-doc.doc-code,
                                temp_trn-doc.price-type ) .
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
    
          end.
        end case.
      end.

      { gbl/rootnode.i
        temp_doc-line.artic
        temp_doc-line.prod-type
        temp_doc-line.prod-code
        v-root-node
        }
      k = k + 1  .
      find first buf_bar-code where 
                 buf_bar-code.gds-code = buf_goods.gds-code
             and buf_bar-code.unit-cli = temp_doc-line.unit-cli
      no-lock no-error.
      find first tt2-doc-line where 
        tt2-doc-line.artic = temp_doc-line.artic and
        tt2-doc-line.prod-code = temp_doc-line.prod-code and
        tt2-doc-line.prod-type = temp_doc-line.prod-type no-error.
      if not available (tt2-doc-line)
      then do:
        create tt2-doc-line .
        BUFFER-COPY temp_doc-line  to tt2-doc-line
          assign
            tt2-doc-line.doc-qnty       = if not is-tsd then temp_doc-line.fact-qnty else temp_doc-line.doc-qnty when not is-egais
            tt2-doc-line.fact-qnty      = temp_doc-line.fact-qnty when not is-egais
            
            tt2-doc-line.cli-qnty       = temp_doc-line.cli-qnty
            tt2-doc-line.doc-qnty       = temp_doc-line.doc-qnty
            tt2-doc-line.fact-qnty      = temp_doc-line.fact-qnty
            
            tt2-doc-line.price-cli      = temp_doc-line.price-cli
            tt2-doc-line.price-rubl     = (tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale) / (if avail buf_bar-code then buf_bar-code.cli-base-rate else buf_goods.cli-base-rate)
            tt2-doc-line.price-base     = tt2-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
            tt2-doc-line.VAT-pc         = temp_doc-line.vat-pc 
            tt2-doc-line.doc-code       = n-d
            tt2-doc-line.status_        = "temp"
            tt2-doc-line.ext-doc-type   = v-ext-doc-type
            tt2-doc-line.slt-pc         = 0
            tt2-doc-line.cli-base-rate  = (if avail buf_bar-code then buf_bar-code.cli-base-rate else 1) when not is-egais
            tt2-doc-line.cli-base-rate  = buf_goods.cli-base-rate when is-egais
            
            tt2-doc-line.line-num       = next-value (s-line-num, {&db-name_schema})
            tt2-doc-line.prt-root       = buf_goods.prt-root
            tt2-doc-line.unit-cli       = temp_doc-line.unit-cli when not is-egais
            tt2-doc-line.unit-cli       = buf_goods.unit-cli when is-egais 
            tt2-doc-line.doc-density    = 1 / tt2-doc-line.cli-base-rate
            tt2-doc-line.fact-density   = 1 / tt2-doc-line.cli-base-rate
            tt2-doc-line.obj-code       = tt-trn-doc.obj-code
            tt2-doc-line.obj-type       = tt-trn-doc.obj-type
            .
      end.
      else do:
        if not is-egais
        then do:
          assign
            tt2-doc-line.price-cli      = (tt2-doc-line.price-cli * tt2-doc-line.cli-qnty + temp_doc-line.price-cli * temp_doc-line.cli-qnty) 
                                        / (tt2-doc-line.cli-qnty + temp_doc-line.cli-qnty)
            tt2-doc-line.cli-qnty       = tt2-doc-line.cli-qnty + temp_doc-line.cli-qnty
            tt2-doc-line.doc-qnty       = tt2-doc-line.doc-qnty + temp_doc-line.doc-qnty
            tt2-doc-line.fact-qnty      = tt2-doc-line.fact-qnty + temp_doc-line.fact-qnty
            tt2-doc-line.price-rubl     = (tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale) / (if avail buf_bar-code then buf_bar-code.cli-base-rate else buf_goods.cli-base-rate)
            tt2-doc-line.price-base     = tt2-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
  /*            tt2-doc-line.price-cli      = temp_doc-line.price-cli
              tt2-doc-line.price-rubl     = tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale
              tt2-doc-line.price-base     = tt2-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale*/
            .
        end.
        else do:
          assign
            
            tt2-doc-line.price-cli      = (tt2-doc-line.price-cli * tt2-doc-line.cli-qnty + temp_doc-line.price-cli * temp_doc-line.cli-qnty) 
                                        / (tt2-doc-line.cli-qnty + temp_doc-line.cli-qnty)
            tt2-doc-line.price-rubl     = (tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale) / buf_goods.cli-base-rate
            tt2-doc-line.price-base     = tt2-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
            
            tt2-doc-line.cli-qnty       = tt2-doc-line.cli-qnty + temp_doc-line.cli-qnty
            tt2-doc-line.doc-qnty       = tt2-doc-line.doc-qnty +  temp_doc-line.doc-qnty
            tt2-doc-line.fact-qnty      = tt2-doc-line.fact-qnty + temp_doc-line.fact-qnty
            .
        end.
/*        tt2-doc-line.price-cli = round(tt2-doc-line.price-cli, 3) .  */
/*        tt2-doc-line.price-rubl = round(tt2-doc-line.price-rubl, 3) .*/
/*        tt2-doc-line.price-base = round(tt2-doc-line.price-base, 3) .*/
      end.
        
/*        if is-egais or is-tsd*/
/*        then do:             */
          /*create tt-doc-line-attr.
          assign
            tt-doc-line-attr.attr-code = "RefA"
            tt-doc-line-attr.doc-code = tt-trn-doc.doc-code
            tt-doc-line-attr.gds-code = temp_doc-line.gds-code
            tt-doc-line-attr.attr-value = temp_doc-line.RefA
          .
          create tt-doc-line-attr.
          assign
            tt-doc-line-attr.attr-code = "RefB"
            tt-doc-line-attr.doc-code = tt-trn-doc.doc-code
            tt-doc-line-attr.gds-code = temp_doc-line.gds-code
            tt-doc-line-attr.attr-value = temp_doc-line.RefB
          .*/
/*          { gbl/pftxvalg.i temp_doc-line.gds-code {&vat-tax-code} ? temp_trn-doc.host-code temp_trn-doc.obj-type temp_trn-doc.obj-code tt2-doc-line.VAT-pc no-error }*/
          
/*        end.*/

      find first tt-gds-dtl where 
        tt-gds-dtl.artic = temp_doc-line.artic and
        tt-gds-dtl.prod-code = temp_doc-line.prod-code and
        tt-gds-dtl.prod-type = temp_doc-line.prod-type no-error.
      
      if not available (tt-gds-dtl) then do:
      create tt-gds-dtl.
      BUFFER-COPY tt2-doc-line  to tt-gds-dtl
        assign
          tt-gds-dtl.doc-qnty  = if not is-tsd then temp_doc-line.fact-qnty else temp_doc-line.doc-qnty
          tt-gds-dtl.fact-qnty = temp_doc-line.fact-qnty
          tt-gds-dtl.prt-code  = v-root-node
          tt-gds-dtl.ov = yes     /*  yes  зафиксируем цены для внутреннего перемещения . Они определены в заказе */
                                  /*  no - будет спрашивать */
        .
        /* признаки  для расходной только корневые */
        
      end.
      else do:
      BUFFER-COPY tt2-doc-line  to tt-gds-dtl
        assign
          tt-gds-dtl.doc-qnty  = tt-gds-dtl.doc-qnty  +  temp_doc-line.doc-qnty
          tt-gds-dtl.fact-qnty = tt-gds-dtl.fact-qnty +  temp_doc-line.fact-qnty
          tt-gds-dtl.prt-code  = v-root-node
          tt-gds-dtl.ov = yes     /*  yes  зафиксируем цены для внутреннего перемещения . Они определены в заказе */
                                  /*  no - будет спрашивать */
        .
        /* признаки  для расходной только корневые */
      end.
        
    end. /*temp_doc-line*/
    
    def var jj as int no-undo.
    
    for each tt2-doc-line :
      jj = 0.
      for each temp_doc-line no-lock where temp_doc-line.artic = tt2-doc-line.artic
                and temp_doc-line.prod-code = tt2-doc-line.prod-code
                and temp_doc-line.prod-type = tt2-doc-line.prod-type:
        find first buf_goods where buf_goods.gds-code  = temp_doc-line.gds-code no-lock no-error .
        find first buf_bar-code where 
                   buf_bar-code.gds-code = buf_goods.gds-code
               and buf_bar-code.unit-cli = temp_doc-line.unit-cli
        no-lock no-error.
        if temp_doc-line.gtinList > ""
        then
        do vGT = 1 to num-entries(temp_doc-line.gtinList) :
          jj = jj + 1.
          vGtin = entry(vGT, temp_doc-line.gtinList) .
          vGtinDocQnty = decimal(entry(vGT, temp_doc-line.gtinDocQntyList)) .
          vGtinFactQnty = decimal(entry(vGT, temp_doc-line.gtinFactQntyList)) .
          
          create tt-parts.
          buffer-copy tt2-doc-line except tt2-doc-line.status_ to tt-parts .
          assign
            tt-parts.prod-type      = tt2-doc-line.prod-type
            tt-parts.prod-code      = tt2-doc-line.prod-code
            tt-parts.artic          = tt2-doc-line.artic
            tt-parts.in-code        = new_trn-doc.doc-code
            tt-parts.out-code       = new_trn-doc.doc-code
            tt-parts.cli-base-rate  = tt2-doc-line.cli-base-rate
            tt-parts.price-cli      = temp_doc-line.price-cli
            tt-parts.price-rubl     = (temp_doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale) / tt-parts.cli-base-rate
            tt-parts.price-base     = tt-parts.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
            tt-parts.qnty           = vGtinDocQnty
            tt-parts.obj-type       = new_trn-doc.obj-type
            tt-parts.obj-code       = new_trn-doc.obj-code
            tt-parts.fact-date      = new_trn-doc.fact-date
            tt-parts.fact-num       = new_trn-doc.fact-num
            tt-parts.VAT-pc         = tt2-doc-line.vat-pc
            tt-parts.part-code      = vGtin + "_" + string(temp_doc-line.line-num)
            tt-parts.PS             = temp_trn-doc.utdDocumentExt
            tt-parts.pay-code       = new_trn-doc.pay-code
            tt-parts.status_        = no
            tt-parts.fact-qnty      = vGtinFactQnty
            tt-parts.supp-type      = new_trn-doc.cli-type
            tt-parts.supp-code      = new_trn-doc.cli-code
            tt-parts.rsrv-free      = ?
            tt-parts.doc-type       = new_trn-doc.doc-type
            tt-parts.cli-qnty       = vGtinDocQnty / tt-parts.cli-base-rate /* temp_doc-line.cli-qnty */
            tt-parts.pl-code        = ?
            tt-parts.VAT-type       = temp_trn-doc.vat-type
            tt-parts.exch-code      = 0
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
          if error-status:error then do :
              v-end-message = substitute(" Ошибка &1 &2 " , error-status :get-message(1)  , return-value) .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo, return error v-end-message.
          end.
          
          if temp_doc-line.doc-qnty <> temp_doc-line.fact-qnty
          and temp_doc-line.fact-qnty > 0
          and vGT > 1
          then do :
            v-need-corr-parts = yes .
          end .
          
          run gds-attr-value (
              input temp_doc-line.gds-code,
              input {&attr-mark-type},
              output v-marking-type,
              output v-type
              ).

/*          if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(new_trn-doc.obj-type, new_trn-doc.obj-code):GetIsArticForType(v-marking-type)*/
/*          then do:                                                                                                                    */
            fe1_:
            for each ub.utd-marking-lines where 
                ub.utd-marking-lines.db-num = temp_doc-line.db-num
            and ub.utd-marking-lines.doc-id = temp_doc-line.doc-id
            and ub.utd-marking-lines.gds-code = temp_doc-line.gds-code
            and ub.utd-marking-lines.LineNum = temp_doc-line.line-num
            :
              
              if getGtinByDM(ub.utd-marking-lines.mark) <> vGtin
              then next fe1_ .
              
              if logical (getAttrUtdLinesEx(ub.utd-marking-lines.db-num,ub.utd-marking-lines.doc-id,ub.utd-marking-lines.LineNum,"MarkUtdLine","no")) and
                 ub.utd-marking-lines.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB 
              /* если лок. статус марки "Проверен", то считаем ее принятой и добавляем в партию */
              then do :
                find first ub.marking no-lock where 
                           ub.marking.mark = ub.utd-marking-lines.mark 
                       and ub.marking.sts <> objSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB 
                       and ub.marking.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB no-error.
                if not available (ub.marking)
                then next fe1_.
              end .
              else
                find first ub.marking no-lock where 
                           ub.marking.mark = ub.utd-marking-lines.mark no-error.
              
              create ub.marking-lines.
              assign
                ub.marking-lines.obj-type = tt-parts.obj-type
                ub.marking-lines.obj-code = tt-parts.obj-code
                ub.marking-lines.in-code = tt-parts.in-code
                ub.marking-lines.out-code = tt-parts.out-code
                ub.marking-lines.part-code = tt-parts.part-code
                ub.marking-lines.gds-code = temp_doc-line.gds-code
                ub.marking-lines.mark = ub.utd-marking-lines.mark
                ub.marking-lines.doc-level = ub.utd-marking-lines.doc-level
              .
              
              if avail ub.marking and
                 ub.marking.unit-ext = "UNIT" and
                 ub.marking.mark-parent <> "" then
              do:  /* BTS-1690 и BTS-1862 Если это КМ потреб. упаковки и она есть в УПД, то добавим КМ груп. упаковки к партии*/
                   /* ZI-701 вынесено в процедуру для рекурсивного вызова, т.к. с коробами появилась многоуровневой вложенностью */
                run addUpak2MarkingLines in this-procedure (ub.marking.mark-parent). 
              end.
            end.
/*          end .*/
          
        end .
        else do :       
          jj = jj + 1.
          create tt-parts.
          buffer-copy tt2-doc-line except tt2-doc-line.status_ to tt-parts .
          assign
            tt-parts.prod-type      = tt2-doc-line.prod-type
            tt-parts.prod-code      = tt2-doc-line.prod-code
            tt-parts.artic          = tt2-doc-line.artic
            tt-parts.in-code        = new_trn-doc.doc-code
            tt-parts.out-code       = new_trn-doc.doc-code
  
            tt-parts.price-cli      = temp_doc-line.price-cli
            tt-parts.price-rubl     = (temp_doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale) / tt-parts.cli-base-rate
                      
            tt-parts.price-base     = tt-parts.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
            tt-parts.qnty           = temp_doc-line.doc-qnty
            tt-parts.obj-type       = new_trn-doc.obj-type
            tt-parts.obj-code       = new_trn-doc.obj-code
            tt-parts.fact-date      = new_trn-doc.fact-date
            tt-parts.fact-num       = new_trn-doc.fact-num
            tt-parts.VAT-pc         = temp_doc-line.vat-pc
            tt-parts.part-code      = if temp_doc-line.gtinline <> "" 
                                         then (temp_doc-line.gtinline + "_" + string(temp_doc-line.line-num))
                                         else string(temp_doc-line.line-num)
            tt-parts.PS             = ""
            tt-parts.pay-code       = new_trn-doc.pay-code
            tt-parts.status_        = no
            tt-parts.fact-qnty      = temp_doc-line.fact-qnty
            tt-parts.supp-type      = new_trn-doc.cli-type
            tt-parts.supp-code      = new_trn-doc.cli-code
            tt-parts.rsrv-free      = ?
            tt-parts.doc-type       = new_trn-doc.doc-type
            tt-parts.cli-qnty       = temp_doc-line.cli-qnty
            tt-parts.pl-code        = ?
            tt-parts.VAT-type       = temp_trn-doc.vat-type
            tt-parts.exch-code      = 0
            tt-parts.cli-base-rate  = 1 when not is-egais
            tt-parts.cli-base-rate  = buf_goods.cli-base-rate when is-egais
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
          if error-status:error then do :
              v-end-message = substitute(" Ошибка &1 &2 " , error-status :get-message(1)  , return-value) .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo, return error v-end-message.
          end.
              
          find first ub.utd where 
                ub.utd.db-num = temp_doc-line.db-num
            and ub.utd.doc-id = temp_doc-line.doc-id.
          
          ub.utd.doc-code = new_trn-doc.doc-code.
          new_trn-doc.contract-code = ub.utd.contract-code.
          new_trn-doc.host-code = ub.utd.host-code.
          
          run gds-attr-value (
              input temp_doc-line.gds-code,
              input {&attr-mark-type},
              output v-marking-type,
              output v-type
              ).

          if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(new_trn-doc.obj-type, new_trn-doc.obj-code):GetIsMarkingForType(v-marking-type)
          or ObjSrv:Env:ParametrsOfSection:GetSectionEDO(new_trn-doc.obj-type, new_trn-doc.obj-code):GetIsEDOForType(v-marking-type)
          or temp_doc-line.isWeight
          then do:
            fe1_:
            for each ub.utd-marking-lines where 
                ub.utd-marking-lines.db-num = temp_doc-line.db-num
            and ub.utd-marking-lines.doc-id = temp_doc-line.doc-id
            and ub.utd-marking-lines.gds-code = temp_doc-line.gds-code
            and ub.utd-marking-lines.LineNum = temp_doc-line.line-num
            :

              if ub.utd-marking-lines.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB then
              /* если лок. статус марки "Проверен", то считаем ее принятой и добавляем в партию */
              do:
                find first ub.marking no-lock where 
                           ub.marking.mark = ub.utd-marking-lines.mark 
                       and ub.marking.sts <> objSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB 
                       and ub.marking.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB no-error.
                if not available (ub.marking)
                  then next fe1_.
              end.
              
              create ub.marking-lines.
              assign
                ub.marking-lines.obj-type = tt-parts.obj-type
                ub.marking-lines.obj-code = tt-parts.obj-code
                ub.marking-lines.in-code = tt-parts.in-code
                ub.marking-lines.out-code = tt-parts.out-code
                ub.marking-lines.part-code = tt-parts.part-code
                ub.marking-lines.gds-code = temp_doc-line.gds-code
                ub.marking-lines.mark = ub.utd-marking-lines.mark
                ub.marking-lines.doc-level = ub.utd-marking-lines.doc-level
              .
            end.
          end.
    /*          else do:                                                                                                                                              */
    /*            fe2_:                                                                                                                                               */
    /*            for each ub.utd-marking-lines where                                                                                                                 */
    /*                ub.utd-marking-lines.db-num = temp_doc-line.db-num                                                                                              */
    /*            and ub.utd-marking-lines.doc-id = temp_doc-line.doc-id                                                                                              */
    /*            and ub.utd-marking-lines.gds-code = temp_doc-line.gds-code                                                                                          */
    /*            and ub.utd-marking-lines.LineNum = temp_doc-line.line-num                                                                                           */
    /*            :                                                                                                                                                   */
    /*              find first ub.marking no-lock where ub.marking.mark = ub.utd-marking-lines.mark and ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB*/
    /*                and ub.marking.unit-ext = "Levele1" no-error.                                                                                                   */
    /*              if not available (ub.marking)                                                                                                                     */
    /*                then next fe2_.                                                                                                                                 */
    /*                                                                                                                                                                */
    /*              create ub.marking-lines.                                                                                                                          */
    /*              assign                                                                                                                                            */
    /*                ub.marking-lines.obj-type = tt-parts.obj-type                                                                                                   */
    /*                ub.marking-lines.obj-code = tt-parts.obj-code                                                                                                   */
    /*                ub.marking-lines.in-code = tt-parts.in-code                                                                                                     */
    /*                ub.marking-lines.out-code = tt-parts.out-code                                                                                                   */
    /*                ub.marking-lines.part-code = tt-parts.part-code                                                                                                 */
    /*                ub.marking-lines.gds-code = temp_doc-line.gds-code                                                                                              */
    /*                ub.marking-lines.mark = ub.utd-marking-lines.mark                                                                                               */
    /*                ub.marking-lines.doc-level = ub.utd-marking-lines.doc-level                                                                                     */
    /*              .                                                                                                                                                 */
    /*            end.                                                                                                                                                */
    /*          end.                                                                                                                                                  */
    /*                                                                                                                                                                */
        end .
      end.
    end.
  
    if is-unit-error then do:
      run pcall-log-file in p-log-handle (input "Не все товары попали в накладную") .
    end.

/*

for each tt2-doc-line :
    message
           'doc-line' skip
            n-d tt2-doc-line.artic skip
            'cli-qnty ' tt2-doc-line.cli-qnty skip
            'price-rub'tt2-doc-line.price-rubl skip
            'fact-qnty' tt2-doc-line.fact-qnty   skip
            'doc-qnty ' tt2-doc-line.doc-qnty     skip
        .
end.
for each tt-gds-dtl :
    message
    'gds-dtl' skip
    n-d
    tt-gds-dtl.artic skip
    tt-gds-dtl.fact-qnty    tt-gds-dtl.doc-qnty skip
            'price-rubl' tt-gds-dtl.price-rubl skip
            .
end.
for each tt-parts:
    message
    'parts'  skip
    n-d  skip
    tt-parts.artic skip
    tt-parts.cli-qnty tt-parts.fact-qnty tt-parts.qnty   skip
    'price-rubl' tt-parts.price-rubl skip
    .
end.
*/
    case v-ext-doc-type :
      when  {&TDEDT_Pri_Vnesh}
      or when {&TDEDT_Pri_Perem}
      then do:
  
        /* проверка спецификаций */
        if v-specif 
        then do:
          for each tt-parts :
            find first buf_goods no-lock  where
                       tt-parts.artic     = buf_goods.artic    and
                       tt-parts.prod-type = buf_goods.prod-type  and
                       tt-parts.prod-code = buf_goods.prod-code
                       no-error .
            define variable v-price-doc as decimal .
            v-price-doc = tt-parts.price-cli / tt-parts.cli-base-rate .
   
            { str/ckcntspc.i
               tt-parts.host-code
               tt-parts.contract-code
               buf_goods.gds-code
               v-price-doc
               tt-parts.VAT-type
               tt-parts.VAT-pc
               no-error
            }
            if error-status :error then do:
              v-end-message = substitute("Ошибка  &1 &2 " , error-status :get-message(1)  , return-value ) .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo, return error v-end-message.
            end.
          end.
        end.
  
        
         /* копирование */
        { str/copy-in.i
          this-procedure
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
        if error-status:error then do :
            v-end-message = substitute(" Ошибка &1 &2 " , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo, return error v-end-message.
        end.
        
        for each new_doc-line exclusive-lock where new_doc-line.doc-code = new_trn-doc.doc-code :
          find first tt2-doc-line where tt2-doc-line.artic = new_doc-line.artic
                                    and tt2-doc-line.prod-type = new_doc-line.prod-type
                                    and tt2-doc-line.prod-code = new_doc-line.prod-code
                                    no-error .
          if available tt2-doc-line
          and tt2-doc-line.fact-qnty = new_doc-line.fact-qnty
          then do :
            assign                 
              new_doc-line.doc-qnty = tt2-doc-line.doc-qnty 
              new_doc-line.cli-qnty = tt2-doc-line.cli-qnty
            .
          end .
          find first new_gds-dtl exclusive-lock where new_gds-dtl.doc-code = new_doc-line.doc-code
                                                  and new_gds-dtl.artic = new_doc-line.artic
                                                  and new_gds-dtl.prod-type = new_doc-line.prod-type
                                                  and new_gds-dtl.prod-code = new_doc-line.prod-code
                                                  no-error .
          if available new_gds-dtl
          and new_gds-dtl.fact-qnty = new_doc-line.fact-qnty
          then do :
            assign
              new_gds-dtl.doc-qnty = new_doc-line.doc-qnty
            .
          end .
          for each tt-parts where tt-parts.out-code = new_doc-line.doc-code
                              and tt-parts.obj-type = new_doc-line.obj-type
                              and tt-parts.obj-code = new_doc-line.obj-code
                              and tt-parts.artic = new_doc-line.artic
                              and tt-parts.prod-type = new_doc-line.prod-type
                              and tt-parts.prod-code = new_doc-line.prod-code
          :
            find first new_parts exclusive-lock where new_parts.out-code = tt-parts.out-code
                                                  and new_parts.obj-type = tt-parts.obj-type
                                                  and new_parts.obj-code = tt-parts.obj-code
                                                  and new_parts.artic = tt-parts.artic
                                                  and new_parts.prod-type = tt-parts.prod-type
                                                  and new_parts.prod-code = tt-parts.prod-code
                                                  and new_parts.part-code = tt-parts.part-code
                                                  no-error .
            if available new_parts
            and tt-parts.fact-qnty = new_parts.fact-qnty
            then do :
              assign
                new_parts.qnty = tt-parts.qnty
                new_parts.cli-qnty = tt-parts.cli-qnty
                new_parts.PS = tt-parts.PS
                new_parts.price-cli = tt-parts.price-cli
                new_parts.price-rubl = tt-parts.price-rubl
                new_parts.price-base = tt-parts.price-base
              .
            end .
            else
            if tt-parts.fact-qnty = 0
            then do :
              create new_parts .
              buffer-copy tt-parts to new_parts
              assign
                new_parts.pl-code = (if tt-parts.pl-code = ? then 0 else tt-parts.pl-code)
              .
            end .
          end .      
          vGtinSumDocQnty = 0 .    
          for each new_parts no-lock where new_parts.out-code = new_doc-line.doc-code
                                       and new_parts.obj-type = new_doc-line.obj-type
                                       and new_parts.obj-code = new_doc-line.obj-code
                                       and new_parts.artic = new_doc-line.artic
                                       and new_parts.prod-type = new_doc-line.prod-type
                                       and new_parts.prod-code = new_doc-line.prod-code     
          :
            vGtinSumDocQnty = vGtinSumDocQnty + new_parts.qnty .
          end .           
          if vGtinSumDocQnty < new_doc-line.doc-qnty
          then do :
            create new_parts .
            buffer-copy new_doc-line except new_doc-line.status_ to new_parts 
            assign
              new_parts.prod-type      = tt2-doc-line.prod-type
              new_parts.prod-code      = tt2-doc-line.prod-code
              new_parts.artic          = tt2-doc-line.artic
              new_parts.in-code        = new_trn-doc.doc-code
              new_parts.out-code       = new_trn-doc.doc-code
              new_parts.cli-base-rate  = tt2-doc-line.cli-base-rate
              new_parts.price-cli      = tt2-doc-line.price-cli
              new_parts.price-rubl     = (tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale) / new_parts.cli-base-rate
              new_parts.price-base     = new_parts.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
              new_parts.qnty           = new_doc-line.doc-qnty - vGtinSumDocQnty
              new_parts.obj-type       = new_trn-doc.obj-type
              new_parts.obj-code       = new_trn-doc.obj-code
              new_parts.fact-date      = new_trn-doc.fact-date
              new_parts.fact-num       = new_trn-doc.fact-num
              new_parts.VAT-pc         = tt2-doc-line.vat-pc
              new_parts.part-code      = "empty"
              new_parts.PS             = ""
              new_parts.pay-code       = new_trn-doc.pay-code
              new_parts.status_        = no
              new_parts.fact-qnty      = 0
              new_parts.supp-type      = new_trn-doc.cli-type
              new_parts.supp-code      = new_trn-doc.cli-code
              new_parts.rsrv-free      = ?
              new_parts.doc-type       = new_trn-doc.doc-type
              new_parts.cli-qnty       = new_doc-line.doc-qnty - vGtinSumDocQnty /* temp_doc-line.cli-qnty */
              new_parts.pl-code        = 0
              new_parts.VAT-type       = new_trn-doc.vat-type
              new_parts.exch-code      = 0
              new_parts.SLT-pc         = 0
              new_parts.host-code      = new_trn-doc.host-code
              new_parts.is-supp        = yes
              new_parts.SLT-type       = {&without-slt}
              new_parts.cst-code       = ""
              new_parts.last-date      = ?
              new_parts.road-tax-base  = 0
              new_parts.road-tax-rubl  = 0
              new_parts.transport-base = 0
              new_parts.transport-rubl = 0
              new_parts.other-base     = 0
              new_parts.other-rubl     = 0
              new_parts.purch-code     = new_trn-doc.purch-code
              new_parts.contract-code  = new_trn-doc.contract-code
            .
          end .                       
        end .
        
  /*                                                                                                          */
  /*                                                                                                          */
  /*          for each ub.doc-line exclusive-lock where new_trn-doc.doc-code = ub.doc-line.doc-code:          */
  /*                                                                                                          */
  /*            find first buf_goods where ub.doc-line.artic = buf_goods.artic and                            */
  /*              ub.doc-line.prod-type = buf_goods.prod-type  and                                            */
  /*              ub.doc-line.prod-code = buf_goods.prod-code                                                 */
  /*              no-lock no-error .                                                                          */
  /*                                                                                                          */
  /*            find first ub.gds-dtl exclusive-lock where ub.gds-dtl.doc-code = ub.doc-line.doc-code and     */
  /*              ub.gds-dtl.artic = buf_goods.artic and                                                      */
  /*              ub.gds-dtl.prod-type = buf_goods.prod-type  and                                             */
  /*              ub.gds-dtl.prod-code = buf_goods.prod-code.                                                 */
  /*                                                                                                          */
  /*            find first temp_doc-line where temp_doc-line.gds-code = buf_goods.gds-code.                   */
  /*                                                                                                          */
  /*            ub.gds-dtl.doc-qnty  = if not is-tsd then temp_doc-line.fact-qnty else temp_doc-line.doc-qnty.*/
  /*                                                                                                          */
  /*                                                                                                          */
  /*            ub.doc-line.doc-qnty = temp_doc-line.doc-qnty.                                                */
  /*            ub.doc-line.cli-qnty = temp_doc-line.doc-qnty.                                                */
  /*                                                                                                          */
  /*          end.                                                                                            */
       
/*        if not is-tsd then do:*/
          run gbl/calc-trn.p ( this-procedure  , recid(new_trn-doc)) no-error .
          if error-status :error then do:
            v-end-message = substitute(" Ошибка пересчета &1 &2 " , error-status :get-message(1)  , return-value ) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo, return error v-end-message.
          end.
/*        end.*/
  
        find current new_trn-doc exclusive-lock .
            new_trn-doc.tot-cli =  new_trn-doc.tot-calc.
      end.
    end case.
  
  
    if new_trn-doc.vat-type = "" or new_trn-doc.vat-type = ?
    or new_trn-doc.slt-type = "" or new_trn-doc.slt-type = ?
    then do:
      v-end-message = substitute(" Не настроено значение тип НДС или тип НсП !!! АРМ Администратор/Глобальные параметры/ &1 &2" , error-status :get-message(1)  , return-value) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo, return error v-end-message.
    end.
  
    if error-status:error then do :
      v-end-message = substitute(" Ошибка записи атрибута документа &1 &2" , error-status :get-message(1)  , return-value) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo, return error v-end-message.
    end.
    if temp_trn-doc.cargo-from <> ""
    then do:
      find first ub.doc-attr exclusive-lock where
               ub.doc-attr.doc-code = new_trn-doc.doc-code and
               ub.doc-attr.attr-code = {&trdcattr-shipper} no-error .
      if not available ub.doc-attr then create ub.doc-attr.
      assign
        ub.doc-attr.doc-code = new_trn-doc.doc-code
        ub.doc-attr.attr-code = {&trdcattr-shipper}
        ub.doc-attr.attr-value = temp_trn-doc.cargo-from
      .
    end.
    assign
      v-end-message =  string(temp_trn-doc.obj-type) + string(temp_trn-doc.obj-code)
                    + {&tabulation} + "Документ:" + string(new_trn-doc.doc-code) + " / " + string(temp_trn-doc.doc-code)
                    + {&tabulation} + string( k ) + " товаров"
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    release new_trn-doc.
  end .     

  p-ok-doc = p-ok-doc + 1.
  find first new_trn-doc where new_trn-doc.doc-code = n-d.
  
  v-mercury-prod = false .
  { gbl/conf-rd.i
    "'mercuri':u"
    "'':u"
    "'':u"
    0
    "'':u"
    "'':u"
    "'':u"
    no
    v-mercury-value
    v-mercury-type
    no-error
  }
  if  not error-status :error
  and lookup(v-mercury-value, 'no':u) = 0
  then do:
    for each new_doc-line no-lock where new_doc-line.doc-code = new_trn-doc.doc-code,
    first buf_goods no-lock where buf_goods.artic = new_doc-line.artic
                              and buf_goods.prod-type = new_doc-line.prod-type
                              and buf_goods.prod-code = new_doc-line.prod-code
                              :
      { gbl/gdscdat.i
        buf_goods.gds-code
        "'mercur_FGIS=request':u"
        v-mercury-prod
        no-error
      }   
      if error-status :error then v-mercury-prod = false .
      if v-mercury-prod then leave .            
    end .
  end .
  if v-mercury-prod
  or v-need-corr-parts
  then do :
    if v-mercury-prod
    and v-need-corr-parts
    then do :
      v-mess-in-doc = "Необходимо уточнение количества частично принятого товара в разрезе GTIN." + {&new-line}
                    + "Также в поставке присутствуют товары, подконтрольные ФГИС Меркурий. Для таких товаров необходимо добавить ВСД." .
      v-in-doc-mode = {&lookup} + '{&delim-flt}':U + "vsd_corr-parts" .              
    end .
    else
    if v-mercury-prod
    then do :
      v-mess-in-doc = "В поставке присутствуют товары, подконтрольные ФГИС Меркурий. Для таких товаров необходимо добавить ВСД." .
      v-in-doc-mode = {&lookup} + '{&delim-flt}':U + "vsd" .
    end .
    else
    if v-need-corr-parts
    then do :
      v-mess-in-doc = "Необходимо уточнение количества частично принятого товара в разрезе GTIN." .
      v-in-doc-mode = {&lookup} + '{&delim-flt}':U + "corr-parts" .
    end .
    v-doc-rec = recid(new_trn-doc) .
    if mBatchMode
    then do :
      p-msg = "need-user-action" + v-mess-in-doc .
      return .
    end .
    else do :
      message v-mess-in-doc view-as alert-box .
      run str/in-doc.w
        ( input        parparentproc
        , input-output v-doc-rec
        , input        v-in-doc-mode
        , input        {&income}
        , input        no
        , input-output varnext-prev
        , input        new_trn-doc.ext-doc-type
        , input        no
        , input-output varline-rec
        , input        br-handle
        , input        bf-handle
        , input        new_trn-doc.status_)
      .
    end .
  end .
  
  run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
  if error-status:error
    then p-msg  = "Ошибка закрытия на факт: " + replace (replace (return-value, {&new-line}, " "), '"', "'").
    else p-msg  = "Накладная закрыта на факт.".

/*end.*/
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
define variable varchg-inv      as logical no-undo .

assign
  varmode         = {&close-doc}
  varstatus       = {&inquiry}
  varflag         = true
  varcopystatus   = {&g___new}
  varcopyflag     = false
  varcheck-return = true
  varchg-inv      = true
  .

for each tt2-doc-line where is-tsd and doc-code = p-trn-code no-lock:

  run unitqnty1 (
      input tt2-doc-line.unit-cli, 
      input "",
      input "",
      input 0,
      input "",
      input tt2-doc-line.doc-qnty) 
  no-error.
  
  if error-status:error then do:
    run pcall-log-file in p-log-handle (input return-value) .
    is-unit-error  = true.
  end.
  
  run unitqnty1 (
      input tt2-doc-line.unit-cli, 
      input "",
      input "",
      input 0,
      input "",
      input tt2-doc-line.fact-qnty) 
  no-error.
  
  if error-status:error then do:
    run pcall-log-file in p-log-handle (input return-value) .
    is-unit-error  = true.
  end.


end. 

if is-unit-error then do:
  run pcall-log-file in p-log-handle (input "Невозможно перевести накладную в статус накл") .
  return.
  
end.

run str/trn-graf.p
  ( input  p-trn-code ,
    input  v-cntxt-db-num ,
    input  varmode ,
    output varstatus ,
    output varflag ,
    output varcopystatus ,
    output varcopyflag
  ) no-error .

if error-status:error then do :
    v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
    run pcall-log-file in p-log-handle ( input v-end-message ) .
    undo, return error v-end-message.
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
if error-status:error then do :
    v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
    run pcall-log-file in p-log-handle ( input v-end-message ) .
    undo, return error v-end-message.
end.

end.

if is-tsd then do:
  
  for each ub.doc-line exclusive-lock where new_trn-doc.doc-code = ub.doc-line.doc-code:
  
    find first buf_goods where ub.doc-line.artic = buf_goods.artic and
      ub.doc-line.prod-type = buf_goods.prod-type  and
      ub.doc-line.prod-code = buf_goods.prod-code
      no-lock no-error .
    
    find first ub.gds-dtl exclusive-lock where ub.gds-dtl.doc-code = ub.doc-line.doc-code and
      ub.gds-dtl.artic = buf_goods.artic and
      ub.gds-dtl.prod-type = buf_goods.prod-type  and
      ub.gds-dtl.prod-code = buf_goods.prod-code.

    find first temp_doc-line where temp_doc-line.gds-code = buf_goods.gds-code.
    
    ub.gds-dtl.doc-qnty  = temp_doc-line.doc-qnty.
    ub.gds-dtl.fact-qnty = temp_doc-line.fact-qnty.  
    
    ub.doc-line.fact-qnty = temp_doc-line.fact-qnty.
    ub.doc-line.doc-qnty = temp_doc-line.doc-qnty.
    ub.doc-line.cli-qnty = temp_doc-line.cli-qnty.
    
  end.
  
end.

end procedure. /* clos-trn */


procedure clos-trn2 :
define input parameter p-trn-code as character no-undo .
do
on error undo, return error return-value
:
  define buffer buf_s-trn-doc for ub.trn-doc.
  define variable varmode            as   character           no-undo.
  define variable varstatus          like ub.trn-doc.status_  no-undo.
  define variable varflag            like ub.trn-doc.flag     no-undo.
  define variable varcopystatus      like ub.trn-doc.status_  no-undo.
  define variable varcopyflag        like ub.trn-doc.flag     no-undo.
  define variable varcheck-return as logical no-undo .
  define variable varchg-inv as logical no-undo .

  if g#news
  then do:
    { str/tdat-wrt.i
      p-trn-code
      {&trdcattr-is-not-close-fact-news}
      "yes"
      no-error
    }
  end.

  run str/trn-stat.p (
      input  parparentproc ,
      input  this-procedure ,
      input  {&close-fact} ,
      input  p-trn-code,
      input  false /* проверка старого возврата */ ,
      input  v-cntxt-db-num,
      input  false /* проверка переоценки */,
      input  v-cntxt-rsrv-time,
      input  v-cntxt-load-time,
      input  v-cntxt-holidays,
      input  false ,
      output varchg-inv ,
      output table gds-list)
      no-error.
  if error-status:error
  then do:
    find first ub.doc-attr where ub.doc-attr.doc-code = new_trn-doc.doc-code and ub.doc-attr.attr-code = {&trdcattr-is-not-close-fact-news} no-error.
    if available (ub.doc-attr)
    then
      delete ub.doc-attr.       
    undo, return error return-value.
  end.
  find first ub.doc-attr where ub.doc-attr.doc-code = new_trn-doc.doc-code and ub.doc-attr.attr-code = {&trdcattr-is-not-close-fact-news} no-error.
  if available (ub.doc-attr)
  then
    delete ub.doc-attr.
    
end.
end procedure. /* clos-trn2 */


/* для подсовывания trn-clos  и прочим */
procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo . /* текущая БД            */
define output parameter p-cntxt-userid                as character no-undo . /* текущий пользователь  */
define output parameter p-cntxt-level                 as character no-undo . /* уровень контекста     */
define output parameter p-cntxt-host-code-obj         as integer   no-undo . /* текущая фирма         */
define output parameter p-cntxt-obj-type              as character no-undo . /* тип текущего объекта  */
define output parameter p-cntxt-obj-code              as integer   no-undo . /* код текущего объекта  */
define output parameter p-cntxt-db-num-obj            as integer   no-undo . /* база текущего объекта */
define output parameter p-cntxt-is-admin              as logical   no-undo . /* база текущего объекта */

do
on error undo, return error return-value
:
  { gbl/objdbnum.i
     vt-obj-type
     vt-obj-code
     p-cntxt-db-num-obj
     }

  assign
    p-cntxt-db-num          =  v-cntxt-db-num
    p-cntxt-userid          =  v-cntxt-userid
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  vt-obj-type
    p-cntxt-obj-code        =  vt-obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .

end.
end procedure. /* mainmenu_getcntxt */


procedure get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-report-num = 1
    .
  end.
 end procedure. /* get-report-num */

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

procedure calc-cost-price :
define input  parameter p-doc-code as character no-undo .
define buffer cur-doc-line  for ub.doc-line.
define buffer cur-goods     for ub.goods.
define buffer cur-gds-dtl   for ub.gds-dtl.
define buffer t-doc         for ub.trn-doc  .
define variable varnew-price like ub.doc-line.price-base no-undo.

do
on error undo, return error return-value
:
  v-end-message = substitute("Просчет учетной цены для расходной накладной &1" , p-doc-code) .
  run pcall-log-file in p-log-handle ( input v-end-message ) .

  find first t-doc no-lock where t-doc.doc-code = p-doc-code .

  for each  cur-doc-line where cur-doc-line.doc-code   = t-doc.doc-code         ,
  first cur-goods    where cur-goods.artic         = cur-doc-line.artic     and
                           cur-goods.prod-type     = cur-doc-line.prod-type and
                           cur-goods.prod-code     = cur-doc-line.prod-code no-lock,
  each  cur-gds-dtl  where cur-gds-dtl.doc-code    = cur-doc-line.doc-code  and
                           cur-gds-dtl.artic       = cur-doc-line.artic     and
                           cur-gds-dtl.prod-type   = cur-doc-line.prod-type and
                           cur-gds-dtl.prod-code   = cur-doc-line.prod-code no-lock :

    assign
      line-rec = recid(cur-doc-line)
    .
    { str/in-vatp.i
     calc
     cur-doc-line.
     t-doc.
     g
    }
    assign
    varnew-price = (if t-doc.print-rubl then price-rubl-with-tax-loc
                                        else price-base-with-tax-loc ) .
    run str/out-add.p ( this-procedure ,
                    recid (t-doc),
                    recid (cur-doc-line),
                    recid (cur-gds-dtl),
                    recid (cur-goods),
                    "update-sale-price",
                    string(varnew-price)) no-error.
    if error-status :error then do:
      v-end-message = substitute(" Ошибка при вызове программы out-add &1 &2" , error-status :get-message(1)  , return-value) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo, return error v-end-message.
    end.
  end.
  if not is-tsd then do:
    run gbl/calc-trn.p (  this-procedure , recid(new_trn-doc)) no-error .
    if error-status :error then do:
      v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo, return error v-end-message.
    end.
  end.

end.

end procedure. /* calc-cost-price */

procedure cb_cloce-quest-neg :
define output parameter p-is-negostmess as logical   no-undo .
do
on error undo, return error return-value
:

 p-is-negostmess = false .

end.

end procedure. /* cb_cloce-quest-neg */

procedure unitqnty1 :
  /*

  Контроль допустимых количеств для данной единицы измерения (товара)

  Для серийного и штучного товара количество должно быть целым

  Параметры:

  Необходимо задать контролируемое количество p-qnty
  И либо единицу измерения p-unit-name
  либо артикул товара, которые необходимо контролировать.

  Если задан только артикул товара, то будет контролироваться базовая единица
  измерения товара.

  Необязательный параметр p-unit-description определяет
  имя единицы измерения.
  Например можно задать его как
    p-unit-description = "Единица измерения поставщика"
    или
    p-unit-description = "Базовая единица измерения"

  */

  define input parameter  p-unit-name        like ub.units.unit-name no-undo .
  define input parameter  p-artic            like ub.goods.artic     no-undo .
  define input parameter  p-prod-type        like ub.goods.prod-type no-undo .
  define input parameter  p-prod-code        like ub.goods.prod-code no-undo .
  define input parameter  p-unit-description as character            no-undo .
  define input parameter  p-qnty             as decimal              no-undo .


  define buffer buf_units for ub.units .
  define buffer buf_goods for ub.goods .

  define variable v-artic as character no-undo .
  define variable v-msg   as character no-undo .

  if p-unit-description = ''
  or p-unit-description = ?
  then do:
    assign
      p-unit-description = "Единица измерения "
    .
  end.

  if  p-unit-name <> ''
  and p-unit-name <> ?
  then do:
    find first buf_units no-lock
      where buf_units.unit-name = p-unit-name
      no-error .
    if not available buf_units
    then do:
      v-msg = 
        "Не найдена единица измерения " + {&new-line} +
        "p-unit-name" +   p-unit-name + {&new-line} +
        "p-artic" +       p-artic +  {&new-line} +
        "p-prod-type" +   p-prod-type + {&new-line} +
        "p-proc-code" +   string (p-prod-code) + {&new-line} +
        "p-qnty" +        string (p-qnty) + {&new-line} 
         .
      undo, return error v-msg .
    end.
  end.
  else do:
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      v-msg =
        "Не найден товар" + {&new-line} +
        "p-unit-name" +   p-unit-name + {&new-line} +
        "p-artic" +       p-artic +  {&new-line} +
        "p-prod-type" +   p-prod-type + {&new-line} +
        "p-proc-code" +   string (p-prod-code) + {&new-line} +
        "p-qnty" +        string (p-qnty) + {&new-line}
        .
      undo, return error v-msg .
    end.

    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      no-error .
    if not available buf_units
    then do:
      v-msg =
        "Не найдена единица измерения " + {&new-line} +
        "p-unit-name" +   p-unit-name + {&new-line} +
        "p-artic" +       p-artic +  {&new-line} +
        "p-prod-type" +   p-prod-type + {&new-line} +
        "p-proc-code" +   string (p-prod-code) + {&new-line} +
        "p-qnty" +        string (p-qnty) + {&new-line}
        .
      undo, return error v-msg .
    end.

    assign
      v-artic = "Артикул " + string(p-artic) + " " + string(p-prod-type)
              + " " + string(p-prod-code)
      p-unit-description = "Базовая единица измерения"
    .
  end.


  if lookup({&pieces}, buf_units.type) > 0
  or lookup({&serial}, buf_units.type) > 0
  then do:
    if p-qnty <> truncate(p-qnty, 0)
    then do:
      v-msg =
        "Для штучного и серийного товаров резервируемое количество должно быть целым" + {&new-line} +
        v-artic + {&new-line} +
        p-unit-description + buf_units.unit-name + {&new-line} +
        "Запрошено количество " + string (p-qnty) + {&new-line}.
      undo, return error v-msg .
    end.
  end.

end procedure. /* unitqnty */

procedure create-line:
  define input parameter p-doc-code as character no-undo.
  define input-output parameter table for tt2-doc-line.

  def var gds-code as int no-undo.
  def var cli-qnty as dec no-undo.
  def var v-root-node as int no-undo.
  def var vat-pc as dec no-undo.
  
  /* найдем накладную */
  find first ub.trn-doc no-lock
      where ub.trn-doc.doc-code = p-doc-code
      no-error.
  if error-status:error then
      return error subst("Не найден документ с кодом &1", p-doc-code).

/*    { gbl/pftxvalg.i      */
/*      ub.goods.gds-code   */
/*      {&vat-tax-code}     */
/*      today               */
/*      ub.trn-doc.host-code*/
/*      ub.trn-doc.obj-type */
/*      ub.trn-doc.obj-code */
/*      vat-pc              */
/*      no-error            */
/*    }                     */
    
    /* создаем линию накладной */
  { str/crdoclin.i
    ub.trn-doc.doc-code
    tt2-doc-line.artic
    tt2-doc-line.prod-type
    tt2-doc-line.prod-code
    ub.trn-doc.obj-type
    ub.trn-doc.obj-code
    "''"
    trn-doc.ext-doc-type
    tt2-doc-line.prt-root
    tt2-doc-line.vat-pc
    0
    0
    no-error
  }
  if error-status:error then
      return error substitute("Ошибка при создании линии накладной &1, &2", ub.trn-doc.doc-code, return-value).
      
  /* ищем линии для дописывания дополнительных параметров */
  find first ub.doc-line
      where ub.doc-line.doc-code = ub.trn-doc.doc-code            
      and ub.doc-line.artic = tt2-doc-line.artic
      and ub.doc-line.prod-type = tt2-doc-line.prod-type
      and ub.doc-line.prod-code = tt2-doc-line.prod-code
      share-lock.
      
  buffer-copy tt2-doc-line to ub.doc-line.
  
  { gbl/rootnode.i
    ub.doc-line.artic
    ub.doc-line.prod-type
    ub.doc-line.prod-code
    v-root-node
  }

  /* создание признака */
  { str/crgdsdtl.i
    ub.trn-doc.obj-code
    ub.trn-doc.obj-type
    ub.trn-doc.doc-code
    ub.doc-line.artic
    ub.doc-line.prod-code
    ub.doc-line.prod-type
    v-root-node
    true
  }
  
  find first ub.gds-dtl share-lock
      where ub.gds-dtl.doc-code = ub.trn-doc.doc-code
      and ub.gds-dtl.artic = tt2-doc-line.artic
      and ub.gds-dtl.prod-type = tt2-doc-line.prod-type
      and ub.gds-dtl.prod-code = tt2-doc-line.prod-code
      and ub.gds-dtl.prt-code = v-root-node.
  
  buffer-copy ub.doc-line to ub.gds-dtl.
  for each tt-parts where tt-parts.artic = tt2-doc-line.artic
                      and tt-parts.prod-type = tt2-doc-line.prod-type
                      and tt-parts.prod-code = tt2-doc-line.prod-code:
    create ub.parts.
    buffer-copy tt-parts except tt-parts.supp-type tt-parts.supp-code to ub.parts 
    assign ub.parts.pl-code = 0.
  end.
        
end.

procedure addUpak2MarkingLines:
/* процедура рекурсивного добавления в marking-lines для UNIT */
/* всеx упаковок верхнего уровня                              */
  define input parameter iMark like ub.marking.mark no-undo.
  
  find first ub.marking-lines no-lock where
             ub.marking-lines.mark = iMark
         and ub.marking-lines.obj-type = tt-parts.obj-type
         and ub.marking-lines.obj-code = tt-parts.obj-code
         and ub.marking-lines.gds-code = temp_doc-line.gds-code
         and ub.marking-lines.in-code = tt-parts.in-code
         and ub.marking-lines.out-code = tt-parts.out-code
         and ub.marking-lines.part-code = tt-parts.part-code no-error.
  if avail ub.marking-lines 
    then return.              /* уже добавлено */
  find first buf_marking no-lock where 
             buf_marking.mark = iMark 
         and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB 
         and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB no-error.
  if not available (buf_marking)
    then return.    
  find first buf_utd-marking-lines no-lock where 
             buf_utd-marking-lines.mark   = buf_marking.mark
         and buf_utd-marking-lines.db-num = temp_doc-line.db-num
         and buf_utd-marking-lines.doc-id = temp_doc-line.doc-id
         and buf_utd-marking-lines.gds-code = temp_doc-line.gds-code
         and buf_utd-marking-lines.LineNum = temp_doc-line.line-num no-error.
  if not available (buf_utd-marking-lines)
    then return.
  create ub.marking-lines.
  assign
    ub.marking-lines.obj-type = tt-parts.obj-type
    ub.marking-lines.obj-code = tt-parts.obj-code
    ub.marking-lines.in-code = tt-parts.in-code
    ub.marking-lines.out-code = tt-parts.out-code
    ub.marking-lines.part-code = tt-parts.part-code
    ub.marking-lines.gds-code = temp_doc-line.gds-code
    ub.marking-lines.mark = buf_utd-marking-lines.mark
    ub.marking-lines.doc-level = buf_utd-marking-lines.doc-level
  .
  if buf_marking.mark-parent <> "" then
    run addUpak2MarkingLines in this-procedure (buf_marking.mark-parent). 
end procedure.
