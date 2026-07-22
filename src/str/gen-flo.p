block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gen-flo.p $
$Archive: str/gen-flo.p $

Процедура генерации Фин Об по заданным параметрам по заказам

Автор: Чернова Светлана Александровна
Дата создания: 11/02/05
Author: Svetlana Chernova
Creation date: 11/02/05

*/
define temp-table tt-trn-doc  no-undo like ub.ord-doc.

define input parameter parparentproc  as widget-handle no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter p-date-end     as date no-undo    .
define input parameter p-trn-doc      as integer no-undo . /* тип вызова */
define input parameter p-cons         as integer no-undo . /* Совокупная или  раздельно */
define input parameter p-nalog        as integer no-undo . /* если = 2 то на каждую ставку налога надо создавать ФО */
define input parameter table for tt-trn-doc .
define input-output parameter p-res as character no-undo .
define input  parameter p-type-date as integer   no-undo .
define input  parameter p-adm     as logical   no-undo .
define input  parameter p-fo-type as character no-undo . /* Тип ФО: приходное или расходное  */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gen-flo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/gen-flo.p $":U .
define variable vss-description as character no-undo init "Генерации ФО по заказам".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ str/crfinob.i  fin-ob }
{ str/libofarh.i }
{ str/fo-clos.i  }
{ str/clcprtsl.i }
{ gbl/getcntxt.i def }
{ gbl/thbjattr.i }

 /*
 message " по заказам "   skip
  'p-fo-type' p-fo-type skip
  'p-trn-doc' p-trn-doc
   .
   */
define temp-table tt-cli-list no-undo  like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .


define temp-table tt-contract no-undo like ub.contract.

define temp-table tt-gds-grp  no-undo like ub.gds-grp.

define temp-table tt-fin-ob   no-undo like ub.fin-ob
field pc as decimal
index pp is primary unique
      host-code
      contract-code
      pc
      doc-code

index pp_obj
      obj-type
      obj-code
      contract-code
      pc
      doc-code
.

define temp-table tt-ord-code no-undo
  field host-code      as integer
  field contract-code  as integer
  field doc-code       as character
  field pc as decimal
  field fact-date      as date
  field sum-rubl       as decimal
  field sum-base       as decimal
  field sum-contract   as decimal
  field obj-type as character
  field obj-code as integer

index pi is primary unique
      host-code
      contract-code
      pc
      doc-code

index p2
      obj-type
      obj-code
      contract-code
      doc-code

index p3
      fact-date DESCENDING
.
/* Список объектов фирмы */
define temp-table temp-obj-firm no-undo
  field obj-code      as integer
  field obj-type      as char
index pi is primary unique
obj-code
obj-type
.

define temp-table temp-ord-line no-undo like ub.ord-line
field out-code as character
field part-code as character
field contract-code as integer
field sum-vat-rubl as decimal
field sum-vat-base as decimal
index pi IS UNIQUE PRIMARY
  out-code
  gds-code
  in-code
  part-code
  .


define variable p-usl-opl        as character no-undo .
define variable p-contract       as integer no-undo .
define variable p-cli            as integer no-undo .
define variable p-goods          as integer no-undo .

define variable Temp1         as integer init 10 no-undo .
define variable col-fo        as integer init 0 no-undo .
define variable col-bfo       as integer init 0 no-undo .
define variable col-trn       as integer init 0 no-undo .
define variable col-contract  as integer init 0 no-undo .

define variable v-k                 as integer no-undo init 0 .
define variable v-type-trn-doc      as character no-undo .
define variable v-sign-list         as character no-undo .
define variable v-sign              as integer no-undo .
define variable v-shot-type-trn-doc as character no-undo .

define buffer buf_trn-doc          for ub.trn-doc.
define buffer buf_ord-doc          for ub.ord-doc.
define buffer buf_ord-line         for ub.ord-line.
define buffer buf_contract         for ub.contract.
define buffer buf_goods            for ub.goods.
define buffer buf_fin-ob-trn       for ub.fin-ob-trn.
define buffer buf_fin-gds-part     for ub.fin-gds-part.
define buffer buf2_ord-doc         for ub.ord-doc.

define variable var-sum-rubl        as decimal   no-undo .
define variable var-sum-rublb       as decimal   no-undo .
define variable var-sum-base        as decimal   no-undo .
define variable var-sum-baseb       as decimal   no-undo .
define variable var-sum-contract    as decimal   no-undo .
define variable var-sum-contractb   as decimal   no-undo .
define variable var-income-in-code  as character no-undo .

define variable  varis-doc           as   logical                 no-undo.
define variable  varis-cur           as   logical                 no-undo.
define variable  varroad-tax         like ub.doc-line.road-tax    no-undo.
define variable  varexcise           like ub.doc-line.excise      no-undo.
define variable  varvat-pc           like ub.doc-line.vat-pc      no-undo.
define variable  varcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define variable  varslt-pc           like ub.doc-line.slt-pc      no-undo.
define variable  varbase-rate        like ub.trn-doc.base-rate    no-undo.
define variable  varbase-scale       like ub.trn-doc.base-scale   no-undo.
define variable  varr-b              as   character               no-undo.
define variable  varcur-base         like ub.gds-dtl.cur-base     no-undo.
define variable  varcurroad-tax      like ub.doc-line.road-tax    no-undo.
define variable  varcurexcise        like ub.doc-line.excise      no-undo.
define variable  varcurvat-pc        like ub.doc-line.vat-pc      no-undo.
define variable  varcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define variable  varcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define variable  v-ok                as logical   no-undo .
define variable v-spis-contract-type as character no-undo .
assign
  varis-doc            = false
  varis-cur            = false
  varroad-tax          = 0
  varexcise            = 0
  varvat-pc            = 0
  varcons-vat-pc       = 0
  varslt-pc            = 0
  varbase-rate         = 0
  varbase-scale        = 0
  varr-b               = ""
  varcur-base          = 0
  varcurroad-tax       = 0
  varcurexcise         = 0
  varcurvat-pc         = 0
  varcurcons-vat-pc    = 0
  varcurslt-pc         = 0
.

&scop c-temp-table 'temp-table':U
&scop c-table      'table':U
&scop c-table-m    'table-m':U


p-res = p-res +  {&new-line}.

{ gbl/getcntxt.i get }

define variable g-log as logical no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_add-def':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .

run waitfram-show("Ждите...").

define variable var-fin-calc as integer no-undo .
find first sysconf no-lock where sysconf.host-code = par-host-code no-error .
var-fin-calc = sysconf.fin-calc   .


run make-temp-obj-firm.
/**/
assign
    v-type-trn-doc = "order"
    v-shot-type-trn-doc = {&pmnt-ord-doc}
    v-sign-list    = "1"
.
/* разные типы вызова */


if p-trn-doc <> ?  then do:
    for each temp-obj-firm on error undo, return error :
           for each buf_ord-doc no-lock where
                   (buf_ord-doc.obj-type   = temp-obj-firm.obj-type and
                    buf_ord-doc.obj-code   = temp-obj-firm.obj-code and
                    buf_ord-doc.host-code  = par-host-code and
                    buf_ord-doc.need-fo = 1            and
                    buf_ord-doc.cr-fo   = false        and
                    buf_ord-doc.cr-fo2  = false        and
                    buf_ord-doc.doc-date <= p-date-end and
                    buf_ord-doc.contract-code <> 0
                    )
                    or
                   (buf_ord-doc.obj-type   = temp-obj-firm.obj-type and
                    buf_ord-doc.obj-code   = temp-obj-firm.obj-code and
                    buf_ord-doc.host-code  = par-host-code          and
                    buf_ord-doc.status_ = {&fact}  and
                    buf_ord-doc.need-fo2 = 1       and
                    buf_ord-doc.cr-fo   = true     and
                    buf_ord-doc.cr-fo2  = false    and
                    buf_ord-doc.contract-code <> 0 and
                    buf_ord-doc.doc-date <= p-date-end
                    )
                    on error undo, return error :
                run proc-body .
           end. /* trn-doc */
    end. /* temp-obj-firm */
 end.
 else do: /*по списку  */
    for each tt-trn-doc  no-lock
        on error undo, return error
        :
        find first buf_ord-doc no-lock where buf_ord-doc.doc-code = tt-trn-doc.doc-code no-error .
        if available buf_ord-doc  and
          (( buf_ord-doc.need-fo2 = 1 and
             buf_ord-doc.status_ = {&fact} and
             buf_ord-doc.cr-fo2  = false and
             buf_ord-doc.cr-fo   = true )
             or
          ( buf_ord-doc.need-fo = 1 and
            buf_ord-doc.cr-fo2  = false and
            buf_ord-doc.cr-fo   = false
            )) then do:
           run proc-body .
        end.
    end. /* tt-trn-doc */
 end.


/*-----------------------------------------------------------------------------------------------------------------------*/
  if p-cons = 1  then do:
  /* Если нало по всем накладным одного договора       M накл. -> 1 фин.об.  */
     assign
        var-sum-rubl     =  0
        var-sum-base     =  0
        var-sum-contract =  0
        col-contract     =  0
        .

     if var-fin-calc = {&fin-calc-obj}  then do:
     /* {&fin-calc-obj} */
        for each temp-obj-firm
            on error undo, return error :
                  assign
                    var-sum-rubl     =  0
                    var-sum-base     =  0
                    var-sum-contract =  0
                    col-contract     =  0
                  .
                  for each tt-fin-ob where
                            tt-fin-ob.obj-code =  temp-obj-firm.obj-code and
                            tt-fin-ob.obj-type =  temp-obj-firm.obj-type
                            ,
                      first buf_contract no-lock where buf_contract.contract-code = tt-fin-ob.contract-code and
                                                       buf_contract.host-code     = par-host-code           and
                                                       lookup( buf_contract.usl-opl ,  {&contr-pay-order} + "," + {&contr-pay-order-delay} + "," + {&o-buyer-ord} )   > 0
                            break
                            by tt-fin-ob.contract-code
                            by tt-fin-ob.pc
                            on error undo, return error :

                            var-sum-rubl     = var-sum-rubl     + tt-fin-ob.sum-rubl.
                            var-sum-base     = var-sum-base     + tt-fin-ob.sum-base.
                            var-sum-contract = var-sum-contract + tt-fin-ob.sum-contract .

                            if last-of(tt-fin-ob.contract-code)  or (p-nalog = 2 and last-of(tt-fin-ob.pc)) then do:
                                col-contract = col-contract + 1 .
                                if ( col-contract  modulo temp1 = 0 ) and ( col-contract >= temp1 ) then run waitfram-show( "Объединение по договорам : " + string( col-contract )) .
                                run make-s-fo-obj (
                                      input var-sum-rubl ,
                                      input var-sum-base ,
                                      input var-sum-contract,
                                      input temp-obj-firm.obj-type ,
                                      input temp-obj-firm.obj-code ,
                                      input tt-fin-ob.pc )
                                      no-error .
                                    if error-status :error then do:
                                      col-fo = col-fo - 1.
                                      p-res = p-res + {&new-line} + error-status :get-message(1) .
                                    end.
                                var-sum-rubl =  0 .
                                var-sum-base =  0 .
                                var-sum-contract =  0 .
                            end.
                    end.  /* tt-fin-ob */
        end. /* for each temp-obj-firm */
     end.
     else do:
          for each tt-fin-ob  ,
              first buf_contract no-lock where buf_contract.contract-code = tt-fin-ob.contract-code and
                                                buf_contract.host-code    = par-host-code           and
                                                lookup( buf_contract.usl-opl ,  {&contr-pay-order} + "," + {&contr-pay-order-delay}  + "," + {&o-buyer-ord}  )   > 0
                    break
                       by tt-fin-ob.contract-code
                       by tt-fin-ob.pc
                    on error undo, return error :
                    var-sum-rubl = var-sum-rubl + tt-fin-ob.sum-rubl.
                    var-sum-base = var-sum-base + tt-fin-ob.sum-base.
                    var-sum-contract = var-sum-contract + tt-fin-ob.sum-contract.

                    if last-of(tt-fin-ob.contract-code) or (p-nalog = 2 and last-of(tt-fin-ob.pc)) then do:
                        col-contract = col-contract + 1 .
                        if ( col-contract  modulo temp1 = 0 ) and ( col-contract >= temp1 ) then run waitfram-show( "Объединение по договорам : " + string( col-contract )) .
                        run make-s-fo ( input var-sum-rubl , input var-sum-base , input var-sum-contract , input tt-fin-ob.pc ) no-error .
                            if error-status :error then do:
                              col-fo = col-fo - 1.
                              p-res = p-res + {&new-line} + error-status :get-message(1) .
                            end.
                        var-sum-rubl     =  0 .
                        var-sum-base     =  0 .
                        var-sum-contract =  0 .
                    end.
            end.  /* tt-fin-ob */
     end. /*  {&fin-calc-firm}  */
  end. /* if p-cons = 1 */
run waitfram-hide.

if col-fo    < 0 then col-fo    = 0 .

p-res = p-res  + {&new-line}   +
       "Генерация завершена: " + cur-time-string()  + {&new-line} +
       "за период до " + string( p-date-end,"99/99/9999")  + {&new-line} +
       " Создано финансовых обязательств :" + string(col-fo) + {&new-line} +
       "Просмотрено заказов              :" + string(col-trn)           + {&new-line} +
       "Просмотрено договоров            :" + string(col-contract)
       .

return .

/*---------------*/

procedure proc-body :
 do
 on error undo, return error return-value
 :
/* ПО ЗАКАЗУ */
define buffer buf1_ord-doc for ub.ord-doc  .

define variable sum-gds-code  as decimal no-undo .
define variable v-cl-sum-rubl as decimal no-undo .
define variable v-cl-sum-base as decimal no-undo .
define variable v-cl-sum-cli  as decimal no-undo .
define variable v-cl-vat-rubl as decimal no-undo .
define variable v-cl-vat-base as decimal no-undo .
define variable v-cl-vat-cli  as decimal no-undo .

define variable v-rest-sum-rubl as decimal   no-undo .
define variable v-rest-sum-base as decimal   no-undo .
define variable v-rest-vat-rubl like ub.ord-line.sum-vat no-undo .
define variable v-rest-vat-base like ub.ord-line.sum-vat no-undo .

define variable v-flag-po as logical no-undo .
define variable v-may-be  as logical   no-undo .

{ str/doc-fogn.i
  "'ord'"
  p-fo-type
  buf_ord-doc.doc-code
  g#db-num
  v-may-be
}

if v-may-be = false then do:
   p-res = p-res + {&new-line} + substitute("По заказу &1 нельзя создавать ФО в этой БД" , buf_ord-doc.doc-code ) .
   return .
end.

assign
  v-flag-po = ( if buf_ord-doc.cr-fo = true then true else false )
.
if p-adm then v-flag-po =  false .

 col-trn = col-trn + 1 .

assign
    var-sum-rubl = 0
    var-sum-base = 0
    var-sum-contract = 0
    .
    /* если по каждому документу свое фин об */
if ( col-trn  modulo temp1 = 0 ) and ( col-trn >= temp1 ) then run waitfram-show( "Обработано заказов : " + string( col-trn )) .


      for each buf_ord-line no-lock where buf_ord-line.doc-code  = buf_ord-doc.doc-code  ,
              first buf1_ord-doc no-lock where buf1_ord-doc.doc-code  = buf_ord-line.doc-code ,
              first buf_goods no-lock where buf_goods.artic     = buf_ord-line.artic      and
                                            buf_goods.prod-type = buf_ord-line.prod-type  and
                                            buf_goods.prod-code = buf_ord-line.prod-code ,
              first buf_contract no-lock where buf_contract.contract-code = buf_ord-doc.contract-code and
                                               buf_contract.host-code     = buf_ord-doc.host-code     and
                                               lookup( buf_contract.usl-opl ,  {&contr-pay-order}
                                                                       + "," + {&contr-pay-order-delay}
                                                                       + "," + {&o-buyer-ord}) > 0
              break
                    by buf1_ord-doc.contract-code
                    by buf_ord-line.vat-pc
                    on error undo, return error
                    :

                  case buf_contract.usl-opl :
                  when {&contr-buyer-ord-prc} then do:
                        if buf1_ord-doc.status_ = {&fact} then do:
                           run calc-rest-sum in this-procedure ( buffer buf_ord-line ,
                                                                 input buf_contract.srok-opl,
                                                                 output v-cl-sum-rubl ,
                                                                 output v-cl-sum-base,
                                                                 output v-cl-vat-rubl ,
                                                                 output v-cl-vat-base
                                                                 ).
                            assign
                              var-sum-rubl     = var-sum-rubl + v-cl-sum-rubl
                              var-sum-contract = var-sum-contract  + v-cl-sum-cli
                              var-sum-base     = var-sum-base + v-cl-sum-base
                            .
                        end.
                        else do:
                            assign
                              var-sum-rubl     = var-sum-rubl + buf_contract.srok-opl *  abs (buf_ord-line.sum-rubl) / 100
                              var-sum-contract = var-sum-contract  + buf_contract.srok-opl *  abs (buf_ord-line.sum-cli) / 100
                              var-sum-base     = var-sum-base + buf_contract.srok-opl *  abs (buf_ord-line.sum-base) / 100
                            .
                        end.
                  end.
                  when {&contr-buyer-ord} then do:
                    assign
                      var-sum-rubl     = var-sum-rubl + abs (buf_ord-line.sum-rubl)
                      var-sum-contract = var-sum-contract  + abs (buf_ord-line.sum-cli)
                      var-sum-base     = var-sum-base + abs (buf_ord-line.sum-base)
                    .
                  end.
                  otherwise do:
                    assign
                      var-sum-rubl     = var-sum-rubl + abs (buf_ord-line.sum-rubl - ( buf_ord-line.sum-other-rubl + buf_ord-line.sum-transport-rubl))
                      var-sum-contract = var-sum-rubl *  (  buf_ord-doc.exch-scale   / buf_ord-doc.exch-rate )
                      var-sum-base     = var-sum-base + abs (buf_ord-line.sum-base - ( buf_ord-line.sum-other-base + buf_ord-line.sum-transport-base))
                    .
                  end.
                  end case.
                   /* buf_ord-line.sum-vat в валюте документа */
                  v-rest-sum-rubl = buf_ord-line.sum-rubl.
                  v-rest-sum-base = buf_ord-line.sum-base.
                  v-rest-vat-rubl = buf_ord-line.sum-vat  *  ( buf1_ord-doc.exch-rate  / buf1_ord-doc.exch-scale ).
                  v-rest-vat-base = v-rest-vat-rubl       *  ( buf1_ord-doc.base-scale / buf1_ord-doc.base-rate ).
                  if buf_contract.usl-opl = {&contr-buyer-ord-prc} then do:
                    if buf1_ord-doc.status_ = {&fact} then do:
                       run calc-rest-sum in this-procedure (
                           buffer buf_ord-line ,
                           input buf_contract.srok-opl,
                           output v-rest-sum-rubl ,
                           output v-rest-sum-base ,
                           output v-rest-vat-rubl ,
                           output v-rest-vat-base
                           ).
                    end.
                    if buf1_ord-doc.status_ = {&ord-rcv} then do:
                        v-rest-sum-rubl = buf_contract.srok-opl * buf_ord-line.sum-rubl / 100 .
                        v-rest-sum-base = buf_contract.srok-opl * buf_ord-line.sum-base / 100 .
                        v-rest-vat-rubl = buf_contract.srok-opl * buf_ord-line.sum-vat  *  ( buf1_ord-doc.exch-rate  / buf1_ord-doc.exch-scale ) / 100 .
                        v-rest-vat-base = v-rest-vat-rubl * ( buf1_ord-doc.base-scale / buf1_ord-doc.base-rate ) .
                    end.
                  end.

                  create temp-ord-line.
                  BUFFER-COPY buf_ord-line to temp-ord-line
                  assign
                    temp-ord-line.sum-vat-rubl   = v-rest-vat-rubl
                    temp-ord-line.sum-vat-base   = v-rest-vat-base
                    temp-ord-line.sum-rubl       = v-rest-sum-rubl
                    temp-ord-line.sum-base       = v-rest-sum-base
                    temp-ord-line.sum-cli        = v-rest-sum-rubl *  (  buf1_ord-doc.exch-scale   / buf1_ord-doc.exch-rate )
                    temp-ord-line.fact-date      = buf1_ord-doc.fact-date
                    temp-ord-line.contract-code  = buf1_ord-doc.contract-code
                    temp-ord-line.out-code       = buf_ord-line.doc-code
                    temp-ord-line.cli-qnty       = buf_ord-line.cli-qnty
                    temp-ord-line.fact-qnty      = buf_ord-line.fact-qnty
                    temp-ord-line.qnty           = buf_ord-line.qnty
                    temp-ord-line.gds-code       = buf_goods.gds-code
                  .
          /*-------------------------------------------------------------------------------------------------------------*/
            if last-of(buf1_ord-doc.contract-code) or (p-nalog = 2 and last-of(buf_ord-line.vat-pc)) then do:
                if p-cons = 1 then do: /* Если нало по всем накладным одного договора       M накл. -> 1 фин.об.  */
                      run make-tt-fo ( input var-sum-rubl ,
                                       input var-sum-base ,
                                       input var-sum-contract ,
                                       input buf_ord-line.vat-pc
                                       ) no-error .
                      if error-status :error then do:
                          p-res = p-res + {&new-line} + error-status :get-message(1) .
                      end.
                end.
                else do: /* Если нало по каждой накладной создавать ФинОб        1 накл. -> М фин.об.  */
                    run make-fo ( input var-sum-rubl ,
                                  input var-sum-base ,
                                  input var-sum-contract
                                  ) no-error .
                    if error-status :error then  do:
                        col-fo = col-fo - 1.
                        p-res  = p-res + {&new-line} + error-status :get-message(1) .
                    end.
                end.
                var-sum-rubl = 0 .
                var-sum-base = 0 .
                var-sum-contract = 0 .
            end. /* if last-of */
      end. /* ord-line */
 end. /* do */
end procedure. /* proc-body */


procedure make-fo :
 do
 on error undo, return error return-value
 :
define input parameter v-sum-rubl     as decimal no-undo .
define input parameter v-sum-base     as decimal no-undo .
define input parameter v-sum-contract as decimal no-undo .

define variable pfo as logical no-undo .
pfo = false  .
{ str/gen-flpo.i  ord-doc }
   n-doc-type = p-fo-type .
  run fin-ob-code (input g#db-num , output p-doc-code) .
  run create-fin-liab (
    input  yes                  ,
    input  p-doc-code           ,
    input  n-doc-date           ,
    input  n-doc-type           ,
    input  n-payer-name         ,
    input  n-receiver-name      ,
    input  n-curr-code         ,
    input  n-sum-doc           ,
    input  n-user-db-num-doc   ,
    input  n-user-name-doc     ,
    input  n-base-rate         ,
    input  n-base-scale        ,
    input  n-receiver-code     ,
    input  n-receiver-type     ,
    input  n-contract-code     ,
    input  n-exch-rate         ,
    input  n-exch-scale        ,
    input  n-contract-curr     ,
    input  n-contract-rate     ,
    input  n-contract-scale    ,
    input  n-fact-date         ,
    input  n-fact-order        ,
    input  par-host-code       ,
    input  n-payer-code        ,
    input  n-payer-type        ,
    input  n-pay-date          ,
    input  string(p-doc-code)  ,
    input  {&fin-gen}          ,
    input  n-sum-base-orig     ,
    input  n-sum-base          ,
    input  n-sum-doc-orig      ,
    input  n-sum-rubl-orig     ,
    input  n-sum-rubl          ,
    input  n-sum-contract      ,
    input  n-trn-doc-code      ,
    input  n-user-db-num-fact  ,
    input  n-user-db-num-pay   ,
    input  n-user-name-fact    ,
    input  n-user-name-pay     ,
    input  n-in-type           ,
    input  n-sum-tax-base      ,
    input  n-sum-tax-doc       ,
    input  n-sum-tax-rubl      ,
    input  n-sum-tax-contract  ,
    input  ""                  ,
    output p-ri )
    no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "-6"
      view-as alert-box error
    .
        /* if error-status :error then  return. */
        col-fo = col-fo + 1.
        col-contract = col-contract + 1 .
        find first  buf_fin-ob-trn no-lock  where
                    buf_fin-ob-trn.doc-code       = p-doc-code  and
                    buf_fin-ob-trn.host-code      = par-host-code  and
                    buf_fin-ob-trn.doc-type       = "order"  and
                    buf_fin-ob-trn.trn-doc-code   = buf_ord-doc.doc-code
                    no-error .

        if not available  buf_fin-ob-trn then  do :
            create buf_fin-ob-trn.
            assign
              buf_fin-ob-trn.doc-code       = p-doc-code
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.doc-type       = "order"
              buf_fin-ob-trn.sum-rubl       = n-sum-rubl
              buf_fin-ob-trn.trn-doc-code   = buf_ord-doc.doc-code
            .
        end.

        find first buf2_ord-doc  exclusive-lock  where buf2_ord-doc.doc-code = buf_ord-doc.doc-code no-error .
        if available buf2_ord-doc then do:
            if buf_contract.usl-opl = {&contr-buyer-ord-prc} and buf2_ord-doc.status_ = {&fact} then
            assign
              buf2_ord-doc.cr-fo2        = true
              buf2_ord-doc.fo-date2      = today
            .
            else
            assign
              buf2_ord-doc.cr-fo        = true
              buf2_ord-doc.fo-date      = today
            .

        end.
/*+++++++*/


  run make-fin-ord-line in this-procedure
    ( input p-doc-code ,
      input 1  ,
      input buf2_ord-doc.base-rate  ,
      input buf2_ord-doc.base-scale ,
      input buf2_ord-doc.exch-rate  ,
      input buf2_ord-doc.exch-scale

      ) .

  for each temp-ord-line where
           temp-ord-line.contract-code = buf_contract.contract-code
           :
      delete temp-ord-line .
  end.

  /* создадим налоги по партиям */
  run make-tax (
        input p-doc-code ,
        input par-host-code
        )                .

  run update-fin-ob_obj (
        input p-doc-code ,
        input par-host-code
        )
    .


 /* если есть в договоре условие то закроем на факт */
 run close-fo-fact ( input par-host-code, input p-doc-code ) no-error   .
 if error-status :error then
    p-res = p-res + {&new-line} + " Ошибка при закрытии на факт ФО " + return-value  + error-status :get-message(1) .
end. /* do */
end procedure. /* make-fo */

procedure make-tt-fo :
 do
 on error undo, return error return-value
 :

define input  parameter v-sum-rubl as decimal no-undo .
define input  parameter v-sum-base as decimal no-undo .
define input  parameter v-sum-contract as decimal no-undo .
define input  parameter v-pc as decimal   no-undo .


  v-pc = if p-nalog = 1 then 0 else v-pc .

 define variable pfo as logical no-undo .
 pfo = false  .

{ str/gen-flpo.i ord-doc }
   n-doc-type            = p-fo-type . /* {&expense} */
  v-k = v-k + 1    .

   create tt-fin-ob .
   assign
    tt-fin-ob.contract-code = buf_contract.contract-code
    tt-fin-ob.host-code     = par-host-code
    tt-fin-ob.sum-rubl      = v-sum-rubl
    tt-fin-ob.sum-base      = v-sum-base
    tt-fin-ob.sum-contract  = v-sum-contract
    tt-fin-ob.doc-code      = string( v-k )
    tt-fin-ob.obj-code      = buf_ord-doc.obj-code
    tt-fin-ob.obj-type      = buf_ord-doc.obj-type
    tt-fin-ob.pc            =  v-pc
  .
      if not can-find ( first tt-ord-code  where
            tt-ord-code.contract-code = buf_contract.contract-code and
            tt-ord-code.host-code     = par-host-code              and
            tt-ord-code.pc            = v-pc                      and
            tt-ord-code.doc-code      = buf_ord-doc.doc-code       ) then do:
            create tt-ord-code.
            assign
                  tt-ord-code.contract-code = buf_contract.contract-code
                  tt-ord-code.host-code     = par-host-code
                  tt-ord-code.doc-code      = buf_ord-doc.doc-code
                  tt-ord-code.fact-date     = buf_ord-doc.fact-date
                  tt-ord-code.sum-rubl      = v-sum-rubl
                  tt-ord-code.sum-base      = v-sum-base
                  tt-ord-code.sum-contract  = v-sum-contract
                  tt-ord-code.pc            = v-pc
                  tt-ord-code.obj-code      = buf_ord-doc.obj-code
                  tt-ord-code.obj-type      = buf_ord-doc.obj-type

            .
      end.
end.
end procedure.


procedure make-s-fo :
 do
 on error undo, return error return-value
 :
define input parameter v-sum-rubl as decimal no-undo .
define input parameter v-sum-base as decimal no-undo .
define input parameter v-sum-contract as decimal no-undo .
define input  parameter v-pc as decimal   no-undo .
v-pc = if p-nalog = 1 then 0 else v-pc.

/* message  "make-s-fo cymm " v-sum-rubl . */

 define variable pfo as logical no-undo .
 pfo = false  .
{ str/gen-flpo.i ord-doc }
  n-doc-type            = p-fo-type . /* {&expense} */
/* найдем мин дату */
define variable min-date as date no-undo .
define variable max-date as date no-undo .
        for each tt-ord-code  where
            tt-ord-code.contract-code = buf_contract.contract-code  and
            tt-ord-code.host-code     = par-host-code
            break by tt-ord-code.fact-date DESCENDING
            on error undo, return error
            :
            min-date = tt-ord-code.fact-date.
        end.
        if  min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) <= n-doc-date
            then n-pay-date = n-doc-date.
            else n-pay-date = min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) .
  run fin-ob-code (input g#db-num , output p-doc-code) .
  run create-fin-liab (
    input  yes                   ,
    input  p-doc-code            ,
    input  n-doc-date ,
    input  n-doc-type            ,
    input  n-payer-name          ,
    input  n-receiver-name       ,
    input  n-curr-code           ,
    input  n-sum-doc             ,
    input  n-user-db-num-doc     ,
    input  n-user-name-doc       ,
    input  n-base-rate           ,
    input  n-base-scale          ,
    input  n-receiver-code       ,
    input  n-receiver-type       ,
    input  n-contract-code       ,
    input  n-exch-rate           ,
    input  n-exch-scale          ,
    input  n-contract-curr       ,
    input  n-contract-rate       ,
    input  n-contract-scale      ,
    input  n-fact-date           ,
    input  n-fact-order          ,
    input  par-host-code         ,
    input  n-payer-code          ,
    input  n-payer-type          ,
    input  n-pay-date            ,
    input  string(p-doc-code)    ,
    input  {&fin-gen}            ,
    input  n-sum-base-orig       ,
    input  n-sum-base            ,
    input  n-sum-doc-orig        ,
    input  n-sum-rubl-orig       ,
    input  n-sum-rubl            ,
    input  n-sum-contract        ,
    input  n-trn-doc-code        ,
    input  n-user-db-num-fact    ,
    input  n-user-db-num-pay     ,
    input  n-user-name-fact      ,
    input  n-user-name-pay       ,
    input  n-in-type             ,
    input  n-sum-tax-base        ,
    input  n-sum-tax-doc         ,
    input  n-sum-tax-rubl        ,
    input  n-sum-tax-contract    ,
    input  ""                    ,
    output p-ri )
    no-error .

  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
            "Ошибка create-fin-liab " skip
             skip
             error-status :get-message(1) skip
             return-value skip
             view-as alert-box error
     .
     return.
  end.
  col-fo = col-fo + 1.
  /* col-contract = col-contract + 1 . */

  for each tt-ord-code  where
      tt-ord-code.contract-code = buf_contract.contract-code  and
      tt-ord-code.host-code     = par-host-code
      on error undo, return error :

        find first  buf_fin-ob-trn no-lock  where
              buf_fin-ob-trn.doc-code       = p-doc-code     and
              buf_fin-ob-trn.doc-type       = "order"        and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = tt-ord-code.doc-code  no-error .
              if not available  buf_fin-ob-trn then  do:
                  create buf_fin-ob-trn.
                  assign
                    buf_fin-ob-trn.doc-code       = p-doc-code
                    buf_fin-ob-trn.host-code      = par-host-code
                    buf_fin-ob-trn.doc-type       = "order"
                    buf_fin-ob-trn.sum-rubl       = tt-ord-code.sum-rubl
                    buf_fin-ob-trn.trn-doc-code   = tt-ord-code.doc-code
                  .
              end.


      find first buf2_ord-doc  exclusive-lock  where buf2_ord-doc.doc-code = tt-ord-code.doc-code no-error .
      if available buf2_ord-doc then do:
         if buf_contract.usl-opl = {&contr-buyer-ord-prc} and buf2_ord-doc.status_ = {&fact} then
            assign
              buf2_ord-doc.cr-fo2   = true
              buf2_ord-doc.fo-date2 = today
            .
          else
            assign
              buf2_ord-doc.cr-fo   = true
              buf2_ord-doc.fo-date = today
            .

       end.
       if p-nalog = 1 then
          run make-fin-ord-line in this-procedure
            ( input p-doc-code,
              input 2  ,
              input buf2_ord-doc.base-rate  ,
              input buf2_ord-doc.base-scale ,
              input buf2_ord-doc.exch-rate  ,
              input buf2_ord-doc.exch-scale
              ) .
       else
          run make-fin-ord-line-VAT in this-procedure
           ( input p-doc-code ,
             input v-pc  ,
             input buf2_ord-doc.base-rate  ,
             input buf2_ord-doc.base-scale ,
             input buf2_ord-doc.exch-rate  ,
             input buf2_ord-doc.exch-scale
             ) .
  end. /* tt-ord-code */

  run make-tax (
        input p-doc-code ,
        input par-host-code
        )
        .

  run update-fin-ob_obj (
        input p-doc-code ,
        input par-host-code
        )
       .

 run close-fo-fact ( input par-host-code, input p-doc-code ) no-error   .
 if error-status :error then
    p-res = p-res + {&new-line} + " Ошибка процедуры закрытия на ФАКТ совокупного ФО "  + error-status :get-message(1)  + return-value .

 end. /* do */
end procedure. /* make-s-fo */



procedure make-temp-obj-firm :
 do
 on error undo, return error return-value
 :
 define buffer buf_shop for shop .
 define buffer buf_store for store .

for each temp-obj-firm : delete temp-obj-firm. end.

    for each buf_shop no-lock where buf_shop.host-code = par-host-code  on error undo, return error :
        create temp-obj-firm.
        assign
          temp-obj-firm.obj-code = buf_shop.obj-code
          temp-obj-firm.obj-type = {&shop}
        .
    end.
    for each buf_store no-lock where buf_store.host-code = par-host-code  on error undo, return error :
        create temp-obj-firm.
        assign
          temp-obj-firm.obj-code = buf_store.obj-code
          temp-obj-firm.obj-type = {&stock}
        .
    end.
 end. /* do */
end procedure. /* make-temp-obj-firm */


procedure close-fo-fact :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-host-code as integer no-undo .
define input parameter p-doc-code  as character no-undo .
define buffer buf_fact-fin-ob   for fin-ob .
define buffer buf_fact-contract for contract .


find first buf_fact-fin-ob  no-lock where buf_fact-fin-ob.host-code = p-host-code and
                                          buf_fact-fin-ob.doc-code  = p-doc-code no-error .
                                          if error-status :error then
                                          do:
                                          return  error .
                                          end.

  find first buf_fact-contract no-lock where  buf_fact-contract.host-code = buf_fact-fin-ob.host-code and
                                              buf_fact-contract.contract-code = buf_fact-fin-ob.contract-code no-error .
                                              if error-status :error then
                                              do:
                                              return  error .
                                              end.


  if buf_fact-contract.auto-pay  > 0 then do:
      run proc-close-one-fin-ob (recid(buf_fact-fin-ob)) no-error .
      if error-status :error then do:
         message vss-workfile vss-revision vss-description skip
                "№ ФО :" buf_fact-fin-ob.doc-code skip
                "№ фирмы :" buf_fact-fin-ob.host-code skip
                "Вн.№ договора :" buf_fact-fin-ob.contract-code skip
                "Ошибка закрытия на факт ФО на ПН " skip
                 skip
                 error-status :get-message(1) skip
                 return-value skip
                 view-as alert-box error
         .
         return error .
      end.

      if buf_fact-contract.auto-pay > 1 then do:
         run str/payfoavt.p ( input parParentProc, input par-host-code, input recid(buf_fact-fin-ob)) no-error .
         if error-status :error then do:
            message vss-workfile vss-revision vss-description skip
                    "№ ФО :" buf_fact-fin-ob.doc-code skip
                    "№ фирмы :" buf_fact-fin-ob.host-code skip
                    "Вн.№ договора :" buf_fact-fin-ob.contract-code skip
                    "Ошибка автоматического создания платежа . Вернула процедура  payfoavt.p " skip
                    skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error
            .
            return error .
         end.
      end.
  end.
 end. /* do */
end procedure. /* close-fo-fact */

procedure make-s-fo-obj :
 do
 on error undo, return error return-value
 :
define input parameter v-sum-rubl as decimal no-undo    .
define input parameter v-sum-base as decimal no-undo    .
define input parameter v-sum-contract as decimal no-undo    .
define input parameter p-obj-type as character no-undo  .
define input parameter p-obj-code as integer no-undo    .
define input parameter v-pc       as decimal   no-undo .

v-pc = if p-nalog = 1 then 0 else v-pc.


 define variable pfo as logical no-undo .
 pfo = false  .
{ str/gen-flpo.i ord-doc }
  n-doc-type            = p-fo-type . /* {&expense} */
/* найдем мин дату */
define variable min-date as date no-undo .
define variable max-date as date no-undo .


        for each tt-ord-code  where
            tt-ord-code.contract-code = buf_contract.contract-code  and
            tt-ord-code.pc            = v-pc          and
            tt-ord-code.host-code     = par-host-code and
            tt-ord-code.obj-type      = p-obj-type    and
            tt-ord-code.obj-code      = p-obj-code
            break by tt-ord-code.fact-date DESCENDING
            on error undo, return error
            :
            min-date = tt-ord-code.fact-date.
        end.

      if  min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) <= n-doc-date
          then n-pay-date = n-doc-date .
          else n-pay-date = min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) .


  run fin-ob-code (input g#db-num , output p-doc-code) .
  run create-fin-liab (
    input  yes                   ,
    input  p-doc-code            ,
    input  n-doc-date ,
    input  n-doc-type            ,
    input  n-payer-name          ,
    input  n-receiver-name       ,
    input  n-curr-code           ,
    input  n-sum-doc             ,
    input  n-user-db-num-doc     ,
    input  n-user-name-doc       ,
    input  n-base-rate           ,
    input  n-base-scale          ,
    input  n-receiver-code       ,
    input  n-receiver-type       ,
    input  n-contract-code       ,
    input  n-exch-rate           ,
    input  n-exch-scale          ,
    input  n-contract-curr       ,
    input  n-contract-rate       ,
    input  n-contract-scale      ,
    input  n-fact-date           ,
    input  n-fact-order          ,
    input  par-host-code         ,
    input  n-payer-code          ,
    input  n-payer-type          ,
    input  n-pay-date            ,
    input  string(p-doc-code)    ,
    input  {&fin-gen}            ,
    input  n-sum-base-orig       ,
    input  n-sum-base            ,
    input  n-sum-doc-orig        ,
    input  n-sum-rubl-orig       ,
    input  n-sum-rubl            ,
    input  n-sum-contract        ,
    input  n-trn-doc-code        ,
    input  n-user-db-num-fact    ,
    input  n-user-db-num-pay     ,
    input  n-user-name-fact      ,
    input  n-user-name-pay       ,
    input  n-in-type             ,
    input  n-sum-tax-base        ,
    input  n-sum-tax-doc         ,
    input  n-sum-tax-rubl        ,
    input  n-sum-tax-contract    ,
    input  ""                    ,
    output p-ri )
    no-error .

  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
            "Ошибка create-fin-liab " skip
             skip
             error-status :get-message(1) skip
             return-value skip
             view-as alert-box error
     .
     return.
  end.
  col-fo = col-fo + 1.
  /* col-contract = col-contract + 1 . */

  for each tt-ord-code  where
      tt-ord-code.contract-code = buf_contract.contract-code  and
      tt-ord-code.obj-type      = p-obj-type    and
      tt-ord-code.obj-code      = p-obj-code    and
      tt-ord-code.pc            = v-pc                      and
      tt-ord-code.host-code     = par-host-code
      on error undo, return error :

        find first  buf_fin-ob-trn no-lock  where
              buf_fin-ob-trn.doc-code       = p-doc-code  and
              buf_fin-ob-trn.doc-type       = "order"     and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = tt-ord-code.doc-code
              no-error .
              if not available  buf_fin-ob-trn then  do:

            create buf_fin-ob-trn.
            assign
              buf_fin-ob-trn.doc-code       = p-doc-code
              buf_fin-ob-trn.doc-type       = "order"
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.sum-tax-rubl   = n-sum-tax-rubl
              buf_fin-ob-trn.sum-rubl       = tt-ord-code.sum-rubl
              buf_fin-ob-trn.trn-doc-code   = tt-ord-code.doc-code
            .
            end.

      find first buf2_ord-doc  exclusive-lock  where buf2_ord-doc.doc-code = tt-ord-code.doc-code no-error .
      if available buf2_ord-doc then do:
      if buf_contract.usl-opl = {&contr-buyer-ord-prc} and buf2_ord-doc.status_ = {&fact} then
            assign
              buf2_ord-doc.cr-fo2   = true
              buf2_ord-doc.fo-date2 = today
            .
         else
            assign
              buf2_ord-doc.cr-fo   = true
              buf2_ord-doc.fo-date = today
            .

      end.
      /* создадим партии по фин обязательству */
       if p-nalog = 1 then
          run make-fin-ord-line in this-procedure
          ( input p-doc-code,
            input 2 ,
            input buf2_ord-doc.base-rate  ,
            input buf2_ord-doc.base-scale ,
            input buf2_ord-doc.exch-rate  ,
            input buf2_ord-doc.exch-scale ).
       else
          run make-fin-ord-line-VAT in this-procedure
          ( input p-doc-code,
            input v-pc ,
            input buf2_ord-doc.base-rate  ,
            input buf2_ord-doc.base-scale ,
            input buf2_ord-doc.exch-rate  ,
            input buf2_ord-doc.exch-scale
            ).

  end. /* tt-ord-code */

  run make-tax (
        input p-doc-code ,
        input par-host-code
        )                .

  run update-fin-ob_obj (
        input p-doc-code ,
        input par-host-code
        )
    .

 run close-fo-fact ( input par-host-code, input p-doc-code ) no-error   .
 if error-status :error then
    p-res = p-res + {&new-line} + " Ошибка процедуры закрытия на ФАКТ совокупного ФО "  + error-status :get-message(1)  + return-value .

 end. /* do */
end procedure. /* make-s-fo */





procedure make-fin-ord-line :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-code as character no-undo .
define input parameter p-type as integer no-undo .
define input parameter v-base-rate as decimal   no-undo .
define input parameter v-base-scale as integer   no-undo .
define input parameter v-exch-rate as decimal   no-undo .
define input parameter v-exch-scale as integer   no-undo .

/*
message p-type "p-type"  buf_contract.contract-code.
*/
define variable col-part   as integer   no-undo .

/* создадим партии по фин обязательству */
  for each temp-ord-line no-lock  where
           temp-ord-line.contract-code = buf_contract.contract-code
           on error undo, return error :
                if not can-find ( first buf_fin-gds-part no-lock where
                    buf_fin-gds-part.host-code   = par-host-code and
                    buf_fin-gds-part.fin-ob-code = p-doc-code              and
                    buf_fin-gds-part.obj-type    = temp-ord-line.obj-type  and
                    buf_fin-gds-part.obj-code    = temp-ord-line.obj-code  and
                    buf_fin-gds-part.gds-code    = temp-ord-line.gds-code  and
                    buf_fin-gds-part.in-code     = temp-ord-line.in-code   and
                    buf_fin-gds-part.part-code   = temp-ord-line.part-code and
                    buf_fin-gds-part.doc-type    = "order"                 and
                    buf_fin-gds-part.out-code    = temp-ord-line.out-code )
                then do:

                    col-part = col-part + 1.
                    if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show( "Создано партий : " + string( col-part )) .

                      create buf_fin-gds-part.
                      buffer-copy temp-ord-line to buf_fin-gds-part
                      assign
                        buf_fin-gds-part.doc-qnty    = temp-ord-line.qnty
                        buf_fin-gds-part.fact-qnty   = temp-ord-line.qnty
                        buf_fin-gds-part.obj-type    = temp-ord-line.obj-type
                        buf_fin-gds-part.obj-code    = temp-ord-line.obj-code
                        buf_fin-gds-part.gds-code    = temp-ord-line.gds-code
                        buf_fin-gds-part.in-code     = temp-ord-line.in-code
                        buf_fin-gds-part.part-code   = temp-ord-line.part-code
                        buf_fin-gds-part.out-code    = temp-ord-line.out-code
                        buf_fin-gds-part.doc-type    = "order"
                        buf_fin-gds-part.host-code          = par-host-code
                        buf_fin-gds-part.fin-ob-code        = p-doc-code
                        buf_fin-gds-part.status_dop         = {&fin-gen}
                        buf_fin-gds-part.user-db-num        = g#db-num
                        buf_fin-gds-part.user-name          = g#userid
                        buf_fin-gds-part.doc-qnty           = temp-ord-line.qnty
                        buf_fin-gds-part.sum-rubl           = temp-ord-line.sum-rubl
                        buf_fin-gds-part.sum-base           = temp-ord-line.sum-base
                        buf_fin-gds-part.sum-rubl-orig      = temp-ord-line.sum-rubl
                        buf_fin-gds-part.sum-base-orig      = temp-ord-line.sum-base
                        buf_fin-gds-part.sum-contract-orig  = temp-ord-line.sum-cli
                        buf_fin-gds-part.sum-contract       = temp-ord-line.sum-cli
                        buf_fin-gds-part.vat-rubl-orig      = temp-ord-line.sum-vat-rubl
                        buf_fin-gds-part.vat-rubl           = temp-ord-line.sum-vat-rubl
                        buf_fin-gds-part.vat-base-orig      = temp-ord-line.sum-vat-base
                        buf_fin-gds-part.vat-base           = temp-ord-line.sum-vat-base
                        buf_fin-gds-part.vat-contract-orig  = temp-ord-line.sum-vat
                        buf_fin-gds-part.vat-contract       = temp-ord-line.sum-vat
                        buf_fin-gds-part.slt-contract-orig  = temp-ord-line.sum-slt
                        buf_fin-gds-part.slt-contract       = temp-ord-line.sum-slt
                        buf_fin-gds-part.slt-rubl-orig      = temp-ord-line.sum-slt / v-exch-scale * v-exch-rate
                        buf_fin-gds-part.slt-rubl           = temp-ord-line.sum-slt / v-exch-scale * v-exch-rate
                        buf_fin-gds-part.slt-base-orig      = buf_fin-gds-part.slt-rubl * v-base-scale / v-base-rate
                        buf_fin-gds-part.slt-base           = buf_fin-gds-part.slt-rubl * v-base-scale / v-base-rate

                      .
                end. /* buf_fin-gds-part.out-code */
            end.    /* temp-ord-line*/

 end. /* do */
end procedure. /* make-fin-ord-line */



procedure make-fin-ord-line-VAT :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input  parameter p-doc-code as character no-undo .
define input  parameter v-pc as decimal   no-undo .
define input  parameter v-base-rate as decimal   no-undo .
define input  parameter v-base-scale as integer   no-undo .
define input  parameter v-exch-rate as decimal   no-undo .
define input  parameter v-exch-scale as integer   no-undo .


if var-fin-calc <> {&fin-calc-obj}  then find first temp-obj-firm no-error .
define variable col-part   as integer   no-undo .

/* создадим партии по фин обязательству */
  for each temp-ord-line no-lock  where
           temp-ord-line.contract-code = buf_contract.contract-code and
           temp-ord-line.VAT-pc = v-pc  and
           ( var-fin-calc <> {&fin-calc-obj}  or (
           temp-ord-line.obj-type = temp-obj-firm.obj-type  and
           temp-ord-line.obj-code = temp-obj-firm.obj-code ))
           on error undo, return error :
                if not can-find (first buf_fin-gds-part no-lock where
                    buf_fin-gds-part.host-code   = par-host-code and
                    buf_fin-gds-part.fin-ob-code = p-doc-code              and
                    buf_fin-gds-part.obj-type    = temp-ord-line.obj-type  and
                    buf_fin-gds-part.obj-code    = temp-ord-line.obj-code  and
                    buf_fin-gds-part.gds-code    = temp-ord-line.gds-code  and
                    buf_fin-gds-part.in-code     = temp-ord-line.in-code   and
                    buf_fin-gds-part.part-code   = temp-ord-line.part-code and
                    buf_fin-gds-part.doc-type    = "order"                 and
                    buf_fin-gds-part.out-code    = temp-ord-line.out-code  use-index pi )
                then do:
                    col-part = col-part + 1.
                    if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show( "Создано партий : " + string( col-part )) .
                      run clc-price-tmp .
                      create buf_fin-gds-part.
                      buffer-copy temp-ord-line to buf_fin-gds-part
                      assign
                        buf_fin-gds-part.doc-qnty    = temp-ord-line.qnty
                        buf_fin-gds-part.fact-qnty   = temp-ord-line.qnty
                        buf_fin-gds-part.fin-ob-code        = p-doc-code
                        buf_fin-gds-part.doc-type           = "order"
                        buf_fin-gds-part.status_dop         = {&fin-gen}
                        buf_fin-gds-part.user-db-num        = g#db-num
                        buf_fin-gds-part.user-name          = g#userid
                        buf_fin-gds-part.doc-qnty           = temp-ord-line.qnty
                        buf_fin-gds-part.sum-rubl-orig      = temp-ord-line.sum-rubl - ( temp-ord-line.sum-transport-rubl +  temp-ord-line.sum-other-rubl)
                        buf_fin-gds-part.sum-rubl           = temp-ord-line.sum-rubl - ( temp-ord-line.sum-transport-rubl +  temp-ord-line.sum-other-rubl)
                        buf_fin-gds-part.sum-base-orig      = temp-ord-line.sum-base - ( temp-ord-line.sum-transport-base +  temp-ord-line.sum-other-base)
                        buf_fin-gds-part.sum-base           = temp-ord-line.sum-base - ( temp-ord-line.sum-transport-base +  temp-ord-line.sum-other-base)
                        buf_fin-gds-part.sum-contract-orig  = temp-ord-line.sum-cli
                        buf_fin-gds-part.sum-contract       = temp-ord-line.sum-cli
                        buf_fin-gds-part.vat-contract-orig  = temp-ord-line.sum-vat
                        buf_fin-gds-part.vat-contract       = temp-ord-line.sum-vat
                        buf_fin-gds-part.slt-contract-orig  = temp-ord-line.sum-slt
                        buf_fin-gds-part.slt-contract       = temp-ord-line.sum-slt
                        buf_fin-gds-part.vat-rubl-orig      = temp-ord-line.sum-vat-rubl
                        buf_fin-gds-part.vat-rubl           = temp-ord-line.sum-vat-rubl
                        buf_fin-gds-part.slt-rubl-orig      = temp-ord-line.sum-slt  / v-exch-scale * v-exch-rate
                        buf_fin-gds-part.slt-rubl           = temp-ord-line.sum-slt  / v-exch-scale * v-exch-rate
                        buf_fin-gds-part.vat-base-orig      = temp-ord-line.sum-vat-base
                        buf_fin-gds-part.vat-base           = temp-ord-line.sum-vat-base
                        buf_fin-gds-part.slt-base-orig      = buf_fin-gds-part.slt-rubl  * v-base-scale / v-base-rate
                        buf_fin-gds-part.slt-base           = buf_fin-gds-part.slt-rubl  * v-base-scale / v-base-rate
                      .
                end. /* buf_fin-gds-part.out-code */
            end.    /* temp-ord-line*/
 end. /* do */
end procedure. /* make-fin-ord-line-VAT */

procedure clc-price-tmp :

  do
  on error undo, return error return-value
  :

  end.

end procedure. /* clc-price-tmp */


procedure calc-rest-sum :
define parameter buffer buff_ord-line for ub.ord-line.
define input  parameter p-proc        as decimal   no-undo .
define output parameter p-cl-sum-rubl as decimal   no-undo .
define output parameter p-cl-sum-base as decimal   no-undo .
define output parameter p-cl-vat-rubl as decimal   no-undo .
define output parameter p-cl-vat-base  as decimal   no-undo .

define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv  .
define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
define buffer buf_trn-doc      for ub.trn-doc .
define buffer buf_doc-line     for ub.doc-line.
  do
  on error undo, return error return-value
  :
    for each buf_ord-line-rcv no-lock where
            buf_ord-line-rcv.doc-code = buff_ord-line.doc-code and
            buf_ord-line-rcv.artic    = buff_ord-line.artic and
            buf_ord-line-rcv.prod-type = buff_ord-line.prod-type and
            buf_ord-line-rcv.prod-code = buff_ord-line.prod-code ,
            first buf_ord-doc-rcv no-lock where
                  buf_ord-doc-rcv.rcv-code = buf_ord-line-rcv.rcv-code and
                  buf_ord-doc-rcv.doc-code = buf_ord-line-rcv.doc-code ,
            each ub.ord-chain no-lock where
                      ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                      ub.ord-chain.doc-type = 'rcv'                  and
                      ub.ord-chain.rel-doc-type = 'trn' ,
            each buf_doc-line no-lock where
                  buf_doc-line.doc-code  = ub.ord-chain.rel-doc-code and
                  buf_doc-line.artic     = buff_ord-line.artic and
                  buf_doc-line.prod-type = buff_ord-line.prod-type and
                  buf_doc-line.prod-code = buff_ord-line.prod-code and
                  buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh}   and
                  buf_doc-line.status_      = {&fact}
            :
              empty temp-table tt-allsum-line .
              run clcprtsl_calc-line in this-procedure ( input recid( buf_doc-line ) ) no-error .
                find first tt-allsum-line  where tt-allsum-line.sum-type = {&sum-general} no-error.
                if available tt-allsum-line then
                  assign
                    p-cl-sum-rubl  = p-cl-sum-rubl + abs ( tt-allsum-line.sum-dsc-rubl-doc )
                    p-cl-sum-base  = p-cl-sum-base + abs ( tt-allsum-line.sum-dsc-base-doc )
                    p-cl-vat-rubl  = p-cl-vat-rubl + abs ( tt-allsum-line.VAT-rubl-buyer-doc )
                    p-cl-vat-base  = p-cl-vat-base + abs ( tt-allsum-line.VAT-base-buyer-doc)
                    .
    end.
    assign
      p-cl-sum-rubl  = p-cl-sum-rubl - ( p-proc *  buff_ord-line.sum-rubl / 100 )
      p-cl-sum-base  = p-cl-sum-base - ( p-proc *  buff_ord-line.sum-base / 100 )
      p-cl-vat-rubl  = p-cl-vat-rubl - ( p-proc *  buff_ord-line.sum-vat / 100 )
      p-cl-vat-base  = p-cl-vat-base - ( p-proc *  buff_ord-line.sum-vat / 100 )
      .
  end.
end procedure. /* calc-rest-sum */