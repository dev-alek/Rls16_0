block-level on error undo, throw.
/*

$Revision: 288743b2d1c0, 2956, rls $
$Author: VRukavishnikov $
$Date: Ср апр 06 16:23:40 2022 +0300 $
$Workfile: websrv_trn-doc.p $
$Archive: utl/websrv_trn-doc.p $

Импорт накладных из временной таблицы

Автор: Чернова Светлана Александровна
Дата создания: 04/05/06
Author: Svetlana Chernova
Creation date: 04/05/06

*/

{ utl/tt516.i    }
{ibs/th/skt/ControlledClients/websrvTT.i}

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  PARAMETER TABLE FOR  temp_trn-doc.
define input  PARAMETER TABLE FOR  temp_doc-line.
define input  PARAMETER TABLE FOR  TempGdsDtl.
define input  PARAMETER TABLE FOR  TempParts.
define input  PARAMETER TABLE FOR  TempDocAttr.
define output parameter p-ok-doc as integer   no-undo .
define output parameter ERROR_ as logical no-undo initial false .


define variable vss-revision    as character no-undo init "$Revision: 288743b2d1c0, 2956, rls $":U .
define variable vss-author      as character no-undo init "$Author: VRukavishnikov $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:40 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: websrv_trn-doc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/websrv_trn-doc.p $":U .
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

g#auto = true .

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

define buffer t_trn-doc  for ub.trn-doc  .
define buffer t_doc-line for ub.doc-line .
define buffer t_gds-dtl  for ub.gds-dtl .
define buffer buf_goods  for ub.goods .
define buffer buf_contract for ub.contract  .

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


MAIN-BLOCK:
DO
/*   ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK*/
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:


    run get-db-num in parparentproc (output v-cntxt-db-num ) .
    run get-userid in parparentproc (output v-cntxt-userid ) .
    

    { gbl/curr-r-b.i
      v-curr-r-b
    }
    if v-curr-r-b = {&r-b-base} then v-print-rubl = false .
    else v-print-rubl = true .

p-ok-doc = 0 .

for each  temp_trn-doc :
  run clear-tt .
  find first bufo_clients no-lock where
             bufo_clients.obj-type  = temp_trn-doc.obj-type  and
             bufo_clients.obj-code  = temp_trn-doc.obj-code  no-error .

      if error-status :error then do:
              assign
              v-end-message =  substitute(" Не найден объект &1 &2 " , temp_trn-doc.obj-type , temp_trn-doc.obj-code)
              .
/*              run pcall-log-file in p-log-handle (input v-end-message) .*/
              ERROR_ = true .
              return v-end-message.
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

/*        run pcall-log-file in p-log-handle (input v-end-message) .*/
        ERROR_ = true .
        return v-end-message.
      end.

      assign
        vt-host-code          = temp_trn-doc.host-code
        vt-obj-type           = temp_trn-doc.obj-type
        vt-obj-code           = temp_trn-doc.obj-code
        v-cntxt-host-code-obj = temp_trn-doc.host-code
        v-cntxt-obj-code      = temp_trn-doc.obj-code
        v-cntxt-obj-type      = temp_trn-doc.obj-type
        .
        if temp_trn-doc.vat-type = "" or
           temp_trn-doc.vat-type = ? then do:

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
              v-end-message =  substitute(" Не верно задан атрибут 'Тип заведения НДС' (type-vat). &1 &2 &3" , temp_trn-doc.obj-type , temp_trn-doc.obj-code , v-value-integer ) .
/*              run pcall-log-file in p-log-handle (input v-end-message) .*/
              ERROR_ = true .
              return v-end-message.
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
              v-end-message =  substitute(" Ошибка &1 &2 &3 " , temp_trn-doc.obj-type , temp_trn-doc.obj-code , error-status :get-message(1) )
              .
/*              run pcall-log-file in p-log-handle (input v-end-message) .*/
              ERROR_ = true .
              return v-end-message.
      end.

     if vt-host-code <>   v-cntxt-host-code-obj then do:
                  assign
                  v-end-message =  substitute(" Не верно указан код фирмы: &1 ( по объектам должен быть :&2) " , temp_trn-doc.host-code , v-cntxt-host-code-obj  )
                  .
/*                  run pcall-log-file in p-log-handle (input v-end-message) .*/
                  ERROR_ = true .
                  return v-end-message.
     end.


    find first buf_contract no-lock where
               buf_contract.contract-code =  temp_trn-doc.contract-code and
               buf_contract.host-code     =  temp_trn-doc.host-code 
               no-error .


   v-specif = false .

   if temp_trn-doc.contract-code  > 0 then do:
      find first  ub.contract-specif no-lock where
                  ub.contract-specif.contract-num = temp_trn-doc.contract-code and
                  ub.contract-specif.host-code    = temp_trn-doc.host-code
                  no-error .
      if available ub.contract-specif then
      assign
        v-specif = true
        temp_trn-doc.vat-type = ub.contract-specif.VAT-type
      .

   end.

   if temp_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
      if available buf_contract then do:
         if buf_contract.curr-code <> temp_trn-doc.exch-code then do:
                    v-end-message =  substitute("По договору &3   ожидалась валюта &1  пришла &2 " ,
                    buf_contract.curr-code,
                    temp_trn-doc.exch-code,
                    temp_trn-doc.contract-code ) .
                    run pcall-log-file in p-log-handle (input v-end-message) .
                    ERROR_ = true .
                    return v-end-message.
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

/* *******************************88888   */
/*
            temp_trn-doc.wrkr         =  .
            temp_trn-doc.agnt         =  .
            temp_trn-doc.boss         =  .
            */

  /* Если не приход то все принимаем в национальной валюте */
  if temp_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}
  then do:
     temp_trn-doc.exch-code = 0 .
     temp_trn-doc.exch-rate  = 1.
     temp_trn-doc.exch-scale = 1.
  end.
  
  if temp_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
  then do:
      find first ub.contract no-lock where ub.contract.contract-code = temp_trn-doc.contract-code
                                       and ub.contract.host-code = temp_trn-doc.host-code 
                                       and ub.contract.contract-date-end >= temp_trn-doc.doc-date
                                       and ub.contract.status_ = {&current-status} no-error.
      if not available ub.contract
      then do :
          v-end-message =  "Ошибка. Не найден договор с внутреннем номером " + string(temp_trn-doc.contract-code) + ". Или его срок действия истек"
                            + {&new-line} +
                           "Возврат поставщику не может быть оформлен без договора" .
/*          run pcall-log-file in p-log-handle ( input v-end-message ) .*/
          ERROR_ = true .
          undo, return v-end-message.
      end.           
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
            ERROR_ = true .
            return v-end-message.
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
      when {&TDEDT_Ras_Vnesh_VP} then do:
       assign
          v-ext-doc-type   = {&TDEDT_Ras_Vnesh_VP}
          v-doc-type = {&expense}
          v-ret-supp     = true
          v-status_ = {&wayb}
          v-discnt-type    = {&percent}
          v-internal       = false
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
      otherwise do:
          assign
          v-end-message =  substitute(" Не верный расширенный тип документа &1 &2 &3 &4" , temp_trn-doc.ext-doc-type , temp_trn-doc.obj-type , temp_trn-doc.obj-code , temp_trn-doc.doc-code )
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
          ERROR_ = true .
          return v-end-message.
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
      ERROR_ = true .
      undo, return v-end-message.
    end.

    create  tt-trn-doc.
    buffer-copy  temp_trn-doc  to    tt-trn-doc
      assign
/*      tt-trn-doc.pay-code             = v-cntxp-out-pay*/
      tt-trn-doc.status_              = "temp"
      tt-trn-doc.doc-code             = n-d
      tt-trn-doc.doc-date             = temp_trn-doc.doc-date
      tt-trn-doc.doc-type             = v-doc-type
      tt-trn-doc.internal             = v-internal
      tt-trn-doc.cr-db-num            = v-cntxt-db-num
      tt-trn-doc.vat-type             = temp_trn-doc.vat-type
      tt-trn-doc.slt-type             = {&without-slt}
      tt-trn-doc.office               = false
      tt-trn-doc.fact-num             = 0
      tt-trn-doc.out-code             = temp_trn-doc.doc-code
      tt-trn-doc.PS                   = substitute("&1 &2 &3 &5&4 ", temp_trn-doc.doc-code , string(temp_trn-doc.doc-date, "99/99/9999") , temp_trn-doc.creid ,temp_trn-doc.ps ,{&new-line} )
      tt-trn-doc.creid                = temp_trn-doc.creid
      tt-trn-doc.flag_                = false
      tt-trn-doc.ext-doc-type         = v-ext-doc-type
      tt-trn-doc.discnt-type          = v-discnt-type
      tt-trn-doc.ret-supp             = v-ret-supp
      tt-trn-doc.print-rubl           = v-print-rubl
    .
    if tt-trn-doc.hold-obj-type <> "" and tt-trn-doc.hold-obj-type <> ?
    and tt-trn-doc.hold-obj-code <> 0 and tt-trn-doc.hold-obj-code <> ?
    then do :
        assign
            tt-trn-doc.hold-doc-code-child  = "hold":u
            tt-trn-doc.hold-doc-code-parent = "hold":u
        .
    end.
    else do :
        assign
            tt-trn-doc.hold-doc-code-child  = "no-hold":u
            tt-trn-doc.hold-doc-code-parent = "no-hold":u
        .
    end.
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
            ERROR_ = true .
            undo, return v-end-message.
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
               ERROR_ = true .
               undo, return v-end-message.
            end.
            v-purch-code = buf_sysconf.purch-code .
      end.

      if lookup (string(buf_sysconf.purch-code), {&purchase-input-codes}) = 0 then do:
               v-end-message =  "Неверный код типа приобретения по умолчанию. _sysconf".
               run pcall-log-file in p-log-handle ( input v-end-message ) .
               ERROR_ = true .
               undo, return v-end-message.
      end.
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
      .
    if error-status :error then do:
        v-end-message =  substitute("Ошибка при создании шапки документа  &1 &2 &3" , temp_trn-doc.doc-code , return-value , error-status :get-message(1)  ) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        ERROR_ = true .
        undo, return v-end-message.
    end.


    find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .

    if not available new_trn-doc then do:
      v-end-message = substitute(" Ошибка &1  &2" , error-status :get-message(1)  , return-value) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      ERROR_ = true .
      undo, return v-end-message.
    end.

    assign
        new_trn-doc.contract-code  = tt-trn-doc.contract-code
        new_trn-doc.exch-rate  = tt-trn-doc.exch-rate
        new_trn-doc.exch-scale = tt-trn-doc.exch-scale
        new_trn-doc.exch-date  = to-day
        new_trn-doc.exch-code  = tt-trn-doc.exch-code
        new_trn-doc.reason-code = tt-trn-doc.reason-code
        new_trn-doc.status_    = v-status_
        new_trn-doc.flag_      = false
        new_trn-doc.print-rubl = v-print-rubl
        new_trn-doc.agnt  = tt-trn-doc.agnt
        new_trn-doc.boss  = tt-trn-doc.boss
        new_trn-doc.wrkr  = tt-trn-doc.wrkr
        new_trn-doc.hold-obj-type = tt-trn-doc.hold-obj-type
        new_trn-doc.hold-obj-code = tt-trn-doc.hold-obj-code
/*        new_trn-doc.rcv-code = "not_delete"  /* нельзя будет открыть, чтоб потом изменить или удалить */*/
        parrec-doc = recid (new_trn-doc)
    .
    if new_trn-doc.hold-obj-type <> "" and new_trn-doc.hold-obj-type <> ?
    and new_trn-doc.hold-obj-code <> 0 and new_trn-doc.hold-obj-code <> ?
    then do :
        assign
            new_trn-doc.hold-doc-code-child  = "hold":u
            new_trn-doc.hold-doc-code-parent = "hold":u
        .
    end.
    else do :
        assign
            new_trn-doc.hold-doc-code-child  = "no-hold":u
            new_trn-doc.hold-doc-code-parent = "no-hold":u
        .
    end. 
    
  if (new_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or new_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or new_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}) 
    then 
  do:
    find first ub.shift-obj no-lock
      where ub.shift-obj.obj-type = new_trn-doc.obj-type
      and ub.shift-obj.obj-code = new_trn-doc.obj-code
      and ub.shift-obj.status_  = {&sht-current}
      no-error .
    if available ub.shift-obj then 
    do:
      assign
        new_trn-doc.shift-num  = ub.shift-obj.shift-num
        new_trn-doc.shift-name = ub.shift-obj.shift-name
        new_trn-doc.shift-date = ub.shift-obj.shift-date
/*        new_trn-doc.fact-date = ub.shift-obj.shift-date*/
        .
    end.
  end.
  
  k = 0 .

  for each  temp_doc-line  no-lock  where
            temp_doc-line.doc-code = temp_trn-doc.doc-code by temp_doc-line.line-num :
/*       run ora-ver-goods (temp_doc-line.gds-code )  no-error .          */
/*        if error-status :error then do:                                 */
/*            v-end-message = return-value .                              */
/*            run pcall-log-file in p-log-handle ( input v-end-message ) .*/
/*            undo, return error v-end-message.                           */
/*        end.                                                            */

      find first buf_goods where buf_goods.gds-code  = temp_doc-line.gds-code
                                 no-lock no-error .

      if error-status :error then do:
          v-end-message = substitute("Ошибка: нет товара &1 &2 &3 " , temp_doc-line.gds-code , error-status :get-message(1)  , return-value) .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          ERROR_ = true .
          next .
/*            undo, return v-end-message.*/
      end.

      temp_doc-line.artic     = buf_goods.artic .
      temp_doc-line.prod-type = buf_goods.prod-type .
      temp_doc-line.prod-code = buf_goods.prod-code .


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
                  ERROR_ = true .
              end.
      end.

      if ub.gds-obj.inv-on = true then do:
            v-end-message =  substitute("Товар &1 &2 &3  находится в инвентаризации. Прием документов невозможен." ,
                              buf_goods.gds-code ,
                              buf_goods.artic ,
                              buf_goods.gds-name
                              ) .
            run pcall-log-file in p-log-handle (input v-end-message) .
            ERROR_ = true .
      end.

     
        { gbl/rootnode.i
          temp_doc-line.artic
          temp_doc-line.prod-type
          temp_doc-line.prod-code
          v-root-node
          }
        k = k + 1  .
        find first tt2-doc-line where 
          tt2-doc-line.artic = temp_doc-line.artic and
          tt2-doc-line.prod-code = temp_doc-line.prod-code and
          tt2-doc-line.prod-type = temp_doc-line.prod-type no-error.
        
        if not available (tt2-doc-line)
        then do:
          create tt2-doc-line .
          BUFFER-COPY temp_doc-line  to tt2-doc-line
            assign
              tt2-doc-line.cli-qnty       = temp_doc-line.fact-qnty
              tt2-doc-line.doc-qnty       = temp_doc-line.fact-qnty
              tt2-doc-line.fact-qnty      = temp_doc-line.fact-qnty
              
              tt2-doc-line.price-cli      = temp_doc-line.price-cli
              tt2-doc-line.price-rubl     = tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale
              tt2-doc-line.price-base     = tt2-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
  
              tt2-doc-line.doc-code       = n-d
              tt2-doc-line.status_        = "temp"
              tt2-doc-line.ext-doc-type   = v-ext-doc-type
              tt2-doc-line.slt-pc         = 0
              tt2-doc-line.cli-base-rate  = 1
              tt2-doc-line.line-num       = next-value (s-line-num, {&db-name_schema})
              tt2-doc-line.prt-root       = buf_goods.prt-root
              tt2-doc-line.unit-cli       = buf_goods.unit-base
              tt2-doc-line.doc-density    = 1 / tt2-doc-line.cli-base-rate
              tt2-doc-line.fact-density   = 1 / tt2-doc-line.cli-base-rate
              tt2-doc-line.obj-code       = tt-trn-doc.obj-code
              tt2-doc-line.obj-type       = tt-trn-doc.obj-type
              .
        end.
        else do:
          assign
            tt2-doc-line.cli-qnty       = tt2-doc-line.cli-qnty + temp_doc-line.fact-qnty
            tt2-doc-line.price-cli      = (tt2-doc-line.price-cli * tt2-doc-line.doc-qnty + temp_doc-line.price-cli * if not is-tsd then temp_doc-line.fact-qnty else temp_doc-line.doc-qnty) 
                                        / (tt2-doc-line.doc-qnty + if not is-tsd then temp_doc-line.fact-qnty else temp_doc-line.doc-qnty)
            tt2-doc-line.doc-qnty       = tt2-doc-line.doc-qnty + if not is-tsd then temp_doc-line.fact-qnty else temp_doc-line.doc-qnty
            tt2-doc-line.fact-qnty      = tt2-doc-line.fact-qnty + temp_doc-line.fact-qnty
            tt2-doc-line.price-rubl     = tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale
            tt2-doc-line.price-base     = tt2-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
/*            tt2-doc-line.price-cli      = temp_doc-line.price-cli
            tt2-doc-line.price-rubl     = tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale
            tt2-doc-line.price-base     = tt2-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale*/
            .
      end.
        

        find first TempGdsDtl where TempGdsDtl.SuppInDocNo = temp_trn-doc.doc-code
                                and TempGdsDtl.gds-code    = temp_doc-line.gds-code
                                and TempGdsDtl.line-num    = temp_doc-line.line-num
                                no-error.
        if not available TempGdsDtl then do :
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
                tt-gds-dtl.prt-code  = v-root-node
                tt-gds-dtl.ov = yes     /*  yes  зафиксируем цены для внутреннего перемещения . Они определены в заказе */
                                        /*  no - будет спрашивать */
              .
              /* признаки  для расходной только корневые */
            end.
        end.
        else do :
            for each TempGdsDtl where TempGdsDtl.SuppInDocNo = temp_trn-doc.doc-code
                                and TempGdsDtl.gds-code    = temp_doc-line.gds-code
                                and TempGdsDtl.line-num    = temp_doc-line.line-num :
                create tt-gds-dtl.
                BUFFER-COPY tt2-doc-line  to tt-gds-dtl
                  assign
                    tt-gds-dtl.doc-qnty  = TempGdsDtl.doc-qnty
                    tt-gds-dtl.fact-qnty = TempGdsDtl.doc-qnty
                    tt-gds-dtl.prt-code  = TempGdsDtl.prt-code
                    tt-gds-dtl.price-rubl = TempGdsDtl.price-rubl
                    tt-gds-dtl.ov = yes     /*  yes  зафиксируем цены для внутреннего перемещения . Они определены в заказе */
                                            /*  no - будет спрашивать */
                  .
            end.
        end.
        
  end. /*temp_doc-line*/
  def var jj as int no-undo.
  for each tt2-doc-line :
    jj = 0.
    for each temp_doc-line no-lock where temp_doc-line.artic = tt2-doc-line.artic
              and temp_doc-line.prod-code = tt2-doc-line.prod-code
              and temp_doc-line.prod-type = tt2-doc-line.prod-type:
      jj = jj + 1.
      find first TempParts where TempParts.SuppInDocNo = temp_trn-doc.doc-code
                             and TempParts.gds-code    = temp_doc-line.gds-code
                             and TempParts.line-num    = temp_doc-line.line-num
                             no-error .
      create tt-parts.
      buffer-copy tt2-doc-line except tt2-doc-line.status_ to tt-parts .
        assign
          tt-parts.prod-type      = tt2-doc-line.prod-type
          tt-parts.prod-code      = tt2-doc-line.prod-code
          tt-parts.artic          = tt2-doc-line.artic
          tt-parts.in-code        = new_trn-doc.doc-code
          tt-parts.out-code       = if available TempParts then TempParts.out-code else new_trn-doc.doc-code
          tt-parts.price-cli      = temp_doc-line.price-cli
          tt-parts.price-rubl     = temp_doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale
          tt-parts.price-base     = tt-parts.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
          tt-parts.qnty           = temp_doc-line.fact-qnty
          tt-parts.obj-type       = new_trn-doc.obj-type
          tt-parts.obj-code       = new_trn-doc.obj-code
          tt-parts.fact-date      = new_trn-doc.fact-date
          tt-parts.fact-num       = new_trn-doc.fact-num
          tt-parts.VAT-pc         = tt2-doc-line.vat-pc
          tt-parts.part-code      = if available TempParts then TempParts.part-code else string (jj)
          tt-parts.PS             = ""
          tt-parts.pay-code       = new_trn-doc.pay-code
          tt-parts.status_        = no
          tt-parts.fact-qnty      = temp_doc-line.fact-qnty
          tt-parts.supp-type      = new_trn-doc.cli-type
          tt-parts.supp-code      = new_trn-doc.cli-code
          tt-parts.rsrv-free      = ?
          tt-parts.doc-type       = new_trn-doc.doc-type
          tt-parts.cli-qnty       = tt2-doc-line.fact-qnty
          tt-parts.pl-code        = ?
          tt-parts.VAT-type       = temp_trn-doc.vat-type
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
          if error-status:error then do :
              v-end-message = substitute(" Ошибка &1 &2 " , error-status :get-message(1)  , return-value) .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              ERROR_ = true .
/*              return v-end-message.*/
          end.
          if v-ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
            run unitqnty1 (
              input tt2-doc-line.unit-cli, 
              input "",
              input "",
              input 0,
              input "",
              input tt2-doc-line.doc-qnty) 
              no-error.

            if error-status:error then 
            do:
              v-str-txt = "Товар - " + string (tt2-doc-line.artic) + ": " +  return-value.
              run pcall-log-file in p-log-handle (input v-str-txt) .
              is-unit-error  = true.
              new_trn-doc.ps = new_trn-doc.ps + {&new-line} + v-str-txt.
              delete tt2-doc-line.
            end.
            
            if available tt2-doc-line then do:

              run unitqnty1 (
                input tt2-doc-line.unit-cli, 
                input "",
                input "",
                input 0,
                input "",
                input tt2-doc-line.fact-qnty) 
                no-error.
              
              if error-status:error then 
              do:
                v-str-txt = "Товар - " + string (tt2-doc-line.artic) + ": " +  return-value.
                run pcall-log-file in p-log-handle (input v-str-txt) .
                is-unit-error  = true.
                new_trn-doc.ps = new_trn-doc.ps + {&new-line} + v-str-txt.
                delete tt2-doc-line.
              end.
              
            end.
              

            
          end.
    end.
  end.

  if is-unit-error then do:
    run pcall-log-file in p-log-handle (input "Не все товары попали в накладную") .
  end.



/*for each tt2-doc-line :                                      */
/*    message                                                  */
/*           'doc-line' skip                                   */
/*            n-d tt2-doc-line.artic skip                      */
/*            'cli-qnty ' tt2-doc-line.cli-qnty skip           */
/*            'price-rub'tt2-doc-line.price-rubl skip          */
/*            'fact-qnty' tt2-doc-line.fact-qnty   skip        */
/*            'doc-qnty ' tt2-doc-line.doc-qnty     skip       */
/*        .                                                    */
/*end.                                                         */
/*for each tt-gds-dtl :                                        */
/*    message                                                  */
/*    'gds-dtl' skip                                           */
/*    n-d                                                      */
/*    tt-gds-dtl.artic skip                                    */
/*    tt-gds-dtl.fact-qnty    tt-gds-dtl.doc-qnty skip         */
/*            'price-rubl' tt-gds-dtl.price-rubl skip          */
/*            .                                                */
/*end.                                                         */
/*for each tt-parts:                                           */
/*    message                                                  */
/*    'parts'  skip                                            */
/*    n-d  skip                                                */
/*    tt-parts.artic skip                                      */
/*    tt-parts.cli-qnty tt-parts.fact-qnty tt-parts.qnty   skip*/
/*    'price-rubl' tt-parts.price-rubl skip                    */
/*    .                                                        */
/*end.                                                         */

  case v-ext-doc-type :
      when  {&TDEDT_Pri_Vnesh}
      or when {&TDEDT_Pri_Perem}
      then do:

          /* проверка спецификаций */
           if v-specif 
           then do:
              for each tt-parts          :
                 find first buf_goods no-lock  where
                       tt-parts.artic     = buf_goods.artic    and
                       tt-parts.prod-type = buf_goods.prod-type  and
                       tt-parts.prod-code = buf_goods.prod-code
                       no-error .
   
                 { str/ckcntspc.i
                   tt-parts.host-code
                   tt-parts.contract-code
                   buf_goods.gds-code
                   tt-parts.price-cli
                   tt-parts.VAT-type
                   tt-parts.VAT-pc
                   no-error
                 }
                 if error-status :error then do:
                   v-end-message = substitute("Ошибка  &1 &2 " , error-status :get-message(1)  , return-value ) .
                   run pcall-log-file in p-log-handle ( input v-end-message ) .
                   ERROR_ = true .
                   next.
/*                   undo, return v-end-message.*/
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
              ERROR_ = true .
              return v-end-message.
          end.
          

          find current new_trn-doc exclusive-lock .
              new_trn-doc.tot-cli =  new_trn-doc.tot-calc.
              
          
      end.
      when {&TDEDT_Ras_Vnesh} 
      or when {&TDEDT_Ras_Vnesh_VP}
      or when {&TDEDT_Ras_Perem}
      or when {&TDEDT_Vozvrat_Vnesh}    then do:
/*          run gbl/inidebug.p .*/
          if v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} and v-specif
          then do :
              for each tt-parts          :
                 find first buf_goods no-lock  where
                       tt-parts.artic     = buf_goods.artic    and
                       tt-parts.prod-type = buf_goods.prod-type  and
                       tt-parts.prod-code = buf_goods.prod-code
                       no-error .
   
                 { str/ckcntspc.i
                   tt-parts.host-code
                   tt-parts.contract-code
                   buf_goods.gds-code
                   tt-parts.price-cli
                   tt-parts.VAT-type
                   tt-parts.VAT-pc
                   no-error
                 }
                 if error-status :error then do:
                   v-end-message = substitute("Ошибка  &1 &2 " , error-status :get-message(1)  , return-value ) .
                   run pcall-log-file in p-log-handle ( input v-end-message ) .
                   ERROR_ = true .
                   next.
/*                   undo, return v-end-message.*/
                 end.
              end.
          end.
          
          { str/copy-ret.i
            this-procedure
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
            tt2-doc-line
            tt-gds-dtl
            tt-parts
            no
            yes
            yes
            yes
            no-error }

            if error-status:error then do :
                v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
/*                run pcall-log-file in p-log-handle ( input v-end-message ) .*/
                ERROR_ = true .
                undo, return v-end-message.
            end.


            if (v-ext-doc-type = {&TDEDT_Ras_Vnesh})
            and temp_trn-doc.stts <> {&inquiry}
            then do:
            /* "Создание НАКЛ- " + caps({&expense})) . */
                run clos-trn in this-procedure (new_trn-doc.doc-code) no-error .
                if error-status:error then do :
                   v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
                   run pcall-log-file in p-log-handle ( input v-end-message ) .
                   undo, return error v-end-message.
                end.
                if is-unit-error then do:
                  new_trn-doc.flag_ = false.
                end.
/*                if temp_trn-doc.price-type   = {&pt1_cost} then do:                                                                     */
/*                  run calc-cost-price (new_trn-doc.doc-code) no-error .                                                                 */
/*                  if error-status :error then do:                                                                                       */
/*                      v-end-message = substitute(" Ошибка пересчета учетных цен &1 &2" , error-status :get-message(1)  , return-value) .*/
/*                      run pcall-log-file in p-log-handle ( input v-end-message ) .                                                      */
/*                      undo, return error v-end-message.                                                                                 */
/*                  end.                                                                                                                  */
/*                end.                                                                                                                    */

                run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
                if error-status:error then do :
                   v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
                   run pcall-log-file in p-log-handle ( input v-end-message ) .
                   undo, return error v-end-message.
                end.

            end.
          assign
            new_trn-doc.PS  = trim(new_trn-doc.PS) + " " + v-str-txt .
      end.
   end case.


  if new_trn-doc.vat-type = "" or new_trn-doc.vat-type = ? or
     new_trn-doc.slt-type = "" or new_trn-doc.slt-type = ? then do:
        v-end-message = substitute(" Не настроено значение тип НДС или тип НсП !!! АРМ Администратор/Глобальные параметры/ &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.

  end.

   run add-nn (new_trn-doc.doc-code , temp_trn-doc.doc-code ) no-error .
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
  for each TempDocAttr where TempDocAttr.SuppInDocNo = temp_trn-doc.doc-code :
      find first ub.doc-attr exclusive-lock where
             ub.doc-attr.doc-code = new_trn-doc.doc-code and
             ub.doc-attr.attr-code = TempDocAttr.attr-code no-error .
      if not available ub.doc-attr then create ub.doc-attr.
      assign
          ub.doc-attr.doc-code = new_trn-doc.doc-code
          ub.doc-attr.attr-code = TempDocAttr.attr-code
          ub.doc-attr.attr-value = TempDocAttr.attr-value
      .
  end.
/*  run gbl/inidebug.p .*/
   run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
    if error-status:error then do :
        v-end-message = substitute(" Ошибка при закрытиии документа &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        ERROR_ = true .
        if temp_trn-doc.stts = {&inquiry} or new_trn-doc.status_ = {&inquiry}
        then do :
            new_trn-doc.flag_ = false .
        end.
        return v-end-message.
/*        undo, return error v-end-message.*/
    end.

    if new_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}    then do:
        v-end-message = substitute("Закрытиии внешнего возврата &1 на статус РАЗР " , new_trn-doc.doc-code) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка при закрытиии внешнего возврата на статус РАЗР &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = {&inquiry} or new_trn-doc.status_ = {&inquiry}
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
/*            undo, return error v-end-message.*/
        end.
        v-end-message = substitute("Закрытиии внешнего возврата &1 на статус ФАКТ ", new_trn-doc.doc-code ) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка при закрытиии внешнего возврата на статус ФАКТ &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = {&inquiry} or new_trn-doc.status_ = {&inquiry}
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
/*            undo, return error v-end-message.*/
        end.
    end.
    
    if new_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
    and (temp_trn-doc.stts = "накл" or temp_trn-doc.stts = "разр" or temp_trn-doc.stts = "факт")
    then do :
        v-end-message = substitute("Закрытие документа &1 на статус НАКЛ- ", new_trn-doc.doc-code ) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка при закрытии документа на статус НАКЛ-.  &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = {&inquiry} or new_trn-doc.status_ = {&inquiry}
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
/*            undo, return error v-end-message.*/
        end.
        v-end-message = substitute("Закрытие документа &1 на статус НАКЛ+ ", new_trn-doc.doc-code ) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка при закрытии документа на статус НАКЛ+.  &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = {&inquiry} or new_trn-doc.status_ = {&inquiry}
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
/*            undo, return error v-end-message.*/
        end.
    end.
    
    if (temp_trn-doc.stts = "разр" and new_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh})
    or ((new_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
         or new_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
         or new_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
         )
    and temp_trn-doc.stts = "факт")
    then do : 
        v-end-message = substitute("Закрытие документа &1 на статус РАЗР ", new_trn-doc.doc-code ) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка при закрытии документа на статус РАЗР.  &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = {&inquiry} or new_trn-doc.status_ = {&inquiry}
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
/*            undo, return error v-end-message.*/
        end.
    end.    
    
    if temp_trn-doc.stts = "факт"
    then do : 
        if new_trn-doc.contract-code = ? or new_trn-doc.contract-code = 0 and new_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
        then do :
            v-end-message =  "Ошибка при закрытиии документа. Нет номера договора" .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = {&inquiry} or new_trn-doc.status_ = {&inquiry}
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
        end.
        else do : 
/*            run gbl/inidebug.p .*/
            if new_trn-doc.fact-date = ? then new_trn-doc.fact-date = to-day .
            if new_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} then new_trn-doc.fact-date = ? .
            v-end-message = substitute("Закрытие документа &1 на статус ФАКТ ", new_trn-doc.doc-code ) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
            if error-status:error then do :
                assign new_trn-doc.fact-date = ? no-error .
                v-end-message = substitute(" Ошибка при закрытиии документа &1 &2" , error-status :get-message(1)  , return-value) .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                ERROR_ = true .
                if temp_trn-doc.stts = {&inquiry} or new_trn-doc.status_ = {&inquiry}
                then do :
                    new_trn-doc.flag_ = false .
                end.
                return v-end-message.
/*                undo, return error v-end-message.*/
            end.
        end.
    end.
    
    if temp_trn-doc.stts = {&inquiry} or new_trn-doc.status_ = {&inquiry}
    then do :
        new_trn-doc.flag_ = false .
    end.
    
    assign
        v-end-message =  string(temp_trn-doc.obj-type) + string(temp_trn-doc.obj-code)
                    + {&tabulation} + "Документ:" + string(new_trn-doc.doc-code) + " / " + string(temp_trn-doc.doc-code) + {&tabulation} + string( k ) + " товаров"
                    .

     run pcall-log-file in p-log-handle (input v-end-message) .

     p-ok-doc = p-ok-doc + 1.

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

/*  if is-tsd then do:*/
    
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
      ub.doc-line.cli-qnty = temp_doc-line.fact-qnty.
      
    end.
    
/*  end.*/

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

/*if is-tsd or is-egais*/
/*  then return.       */
run str/trn-stat.p (
    input  parparentproc ,
    input  this-procedure ,
    input  {&close-doc} ,
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
    if error-status:error then do :
        v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
/*        run pcall-log-file in p-log-handle ( input v-end-message ) .*/
/*        undo,*/
/*        return error v-end-message.*/
        return error v-end-message.
    end.
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

procedure add-nn :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-doc-out as character no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.doc-attr exclusive-lock where
             ub.doc-attr.doc-code = p-doc-code and
             ub.doc-attr.attr-code = {&trdcattr-nids} no-error .
    if not available ub.doc-attr then create ub.doc-attr.
    assign
      ub.doc-attr.doc-code = p-doc-code
      ub.doc-attr.attr-code = {&trdcattr-nids}
      ub.doc-attr.attr-value = p-doc-out
    .
  end.

end procedure. /* add-nn */


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
      undo, return v-msg .
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
      undo, return v-msg .
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
      undo, return v-msg .
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
      undo, return v-msg .
    end.
  end.

end procedure. /* unitqnty */