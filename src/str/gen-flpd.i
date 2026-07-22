/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

генерация по удаленным документам
для подмены буфера buf_parts-attr так как нужен и c-parts-attr и parts-attr (если ПН по раходу еще не удалена)
по удаленным генерится ФО и ПФО если они были!


Автор: Чернова Светлана Александровна
Дата создания: 11/01/05
Author: Svetlana Chernova
Creation date: 11/01/05

Creation date: 06/01/04 2:42

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "процедура генерации Фин Об по заданным параметрам".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ str/crfinob.i  fin-ob }
{ str/clcprtsl.i }
{ gbl/getcntxt.i def }
{ str/libofarh.i }

/*  define buffer   buf_parts-attr for c-parts-attr. */
 define buffer buf_parts-attr for {1} .

define temp-table tt-cli-list no-undo  like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .

define temp-table tt-trn-doc  no-undo like ub.c-trn-doc.
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

define temp-table tt-trn-code no-undo
  field host-code      as integer
  field contract-code  as integer
  field pc as decimal
  field doc-code       as character
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
      pc
      doc-code

.
/* Список объектов фирмы */
define temp-table temp-obj-firm no-undo
  field obj-code      as integer
  field obj-type      as char
index pi is primary unique
obj-code
obj-type
.

define temp-table temp-parts no-undo like ub.c-parts
  field gds-code     as integer
  field income-in-code      like c-parts.in-code
  /*
  field host-code    like parts.host-code
  field obj-type     like parts.obj-type
  field obj-code     like parts.obj-code

  field out-code     like parts.out-code
  field part-code    like parts.part-code
  field fact-qnty    as decimal
  field qnty         as decimal
  field price-rubl   as decimal
  field price-base   as decimal
  field other-rubl   as decimal
  field road-tax-rubl as decimal
  field transport-rubl as decimal
  */
index pi IS UNIQUE PRIMARY
  out-code
  gds-code
  in-code
  part-code
  .

define input parameter parparentproc  as widget-handle no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter p-date-end     as date no-undo .
define input parameter p-trn-doc      as integer no-undo . /* тип расчета по приходу или расходу */
define input parameter p-cons         as integer no-undo .
define input parameter p-nalog        as integer no-undo . /* если = 2 то на каждую ставку налога надо создавать ФО */
define input parameter table for tt-trn-doc .
define input-output parameter p-res as character no-undo .
define input  parameter p-type-date as integer   no-undo .

define variable p-usl-opl      as character no-undo .
define variable p-contract       as integer no-undo .
define variable p-cli            as integer no-undo .
define variable p-goods          as integer no-undo .

define variable Temp1 as integer init 10 no-undo .
define variable col-fo as integer init 0 no-undo .
define variable col-bfo as integer init 0 no-undo .
define variable col-trn as integer init 0 no-undo .
define variable col-contract as integer init 0 no-undo .

define variable v-k as integer no-undo init 0 .
define variable v-type-trn-doc as character no-undo .
define variable v-sign-list    as character no-undo .
define variable v-sign         as integer no-undo .
define variable v-shot-type-trn-doc as character no-undo .

define buffer buf_trn-doc    for c-trn-doc.
define buffer buf_parts      for c-parts.
define buffer buf_contract   for contract.
define buffer buf_goods      for goods.
define buffer buf_fin-ob-trn for fin-ob-trn.
define buffer buf_fin-gds-part for fin-gds-part.
define buffer buf2_trn-doc     for c-trn-doc.

define variable var-sum-rubl as decimal no-undo .
define variable var-sum-rublb as decimal no-undo .
define variable var-income-in-code as character no-undo .
define variable var-sum-base        as decimal   no-undo .
define variable var-sum-baseb       as decimal   no-undo .
define variable var-sum-contract    as decimal   no-undo .
define variable var-sum-contractb   as decimal   no-undo .

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


if p-trn-doc = 1 /* по приходу  */ then do:
    p-usl-opl =  {&o-postavka} .
   end.
   else do:
    p-usl-opl =  {&o-realiz}  .
   end.


run waitfram-show("Ждите...").

define variable var-fin-calc as integer no-undo .
find first sysconf no-lock where sysconf.host-code = par-host-code no-error .
var-fin-calc = sysconf.fin-calc   .

run make-temp-obj-firm.
/**/
if p-trn-doc = ? then assign
                       v-type-trn-doc = {&in-fo-tdedt} + {&ex-fo-tdedt} + {&inv-fo-tdedt}
                       v-sign-list    = {&in-fo-sign} + {&ex-fo-sign} + {&inv-fo-sign}
                       .

if p-trn-doc = 1 then assign
                       v-type-trn-doc = {&in-fo-tdedt} + {&inv-fo-tdedt}
                       v-shot-type-trn-doc = {&income}
                       v-sign-list    = {&in-fo-sign} + {&inv-fo-sign}
                       .
if p-trn-doc = 2 then assign
                      v-type-trn-doc = {&ex-fo-tdedt} + {&inv-fo-tdedt}
                      v-shot-type-trn-doc = {&expense}
                      v-sign-list    = {&ex-fo-sign} + {&inv-fo-sign}
                      .
/* разные типы вызова */
define buffer buf_p_fin-ob-trn for fin-ob-trn.


if p-trn-doc <> ?  then do:
    for each temp-obj-firm on error undo, return error :
        if p-trn-doc = 1 /* по приходу  */ then do:
           for each buf_trn-doc no-lock where
                buf_trn-doc.is-del     = true                   and
                buf_trn-doc.obj-type   = temp-obj-firm.obj-type and
                buf_trn-doc.obj-code   = temp-obj-firm.obj-code and
                buf_trn-doc.status_    = {&fact}                and
                buf_trn-doc.fact-date <= p-date-end             and
                buf_trn-doc.host-code  = par-host-code          and
                buf_trn-doc.need-incfo = 1                      and
                buf_trn-doc.cr-incfo   = false                  and
                lookup ( buf_trn-doc.ext-doc-type , v-type-trn-doc ) > 0
                ,
                first buf_p_fin-ob-trn no-lock where
                      buf_p_fin-ob-trn.trn-doc-code = buf_trn-doc.doc-code

                      break by buf_trn-doc.ext-doc-type
                      on error undo, return error
                      :
                      run proc-body-corr-acc.
                      run proc-body .
           end. /* c-trn-doc */
        end. /* по приходу  */

        if p-trn-doc = 2 /* по реализации */ then do:
           for each buf_trn-doc no-lock where
                buf_trn-doc.is-del     = true                   and
                buf_trn-doc.obj-type   = temp-obj-firm.obj-type and
                buf_trn-doc.obj-code   = temp-obj-firm.obj-code and
                buf_trn-doc.status_    = {&fact}                and
                buf_trn-doc.fact-date <= p-date-end             and
                buf_trn-doc.host-code  = par-host-code          and
                buf_trn-doc.need-expfo = 1                      and
                buf_trn-doc.cr-expfo   = false                  and
                lookup ( buf_trn-doc.ext-doc-type , v-type-trn-doc ) > 0
                ,
                first buf_p_fin-ob-trn no-lock where
                      buf_p_fin-ob-trn.trn-doc-code = buf_trn-doc.doc-code

                      break by buf_trn-doc.ext-doc-type
                      on error undo, return error
                      :
                      run proc-body-corr-acc.
                      run proc-body .
           end. /* c-trn-doc */
        end. /* по реализации  */
    end. /* temp-obj-firm */
 end.
 else do: /* по списку накладных */
    p-usl-opl = {&o-postavka} + "," + {&o-realiz} .

    for each tt-trn-doc  no-lock  where
        tt-trn-doc.is-del     = true and
        lookup(tt-trn-doc.ext-doc-type , v-type-trn-doc) > 0
        and    tt-trn-doc.status_    = {&fact}
        break by tt-trn-doc.ext-doc-type
        on error undo, return error
        :
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = tt-trn-doc.doc-code no-error .
        find first buf_p_fin-ob-trn no-lock where   buf_p_fin-ob-trn.trn-doc-code = buf_trn-doc.doc-code  no-error .

        if available buf_trn-doc and
           available buf_p_fin-ob-trn  then  do:

                run proc-body-corr-acc .
                run proc-body .
        end.
    end. /* tt-trn-doc */
 end.




  if p-cons = 1  then do:
  /* Если нало по всем накладным одного договора       M накл. -> 1 фин.об.  */
     var-sum-rubl =  0 .
     var-sum-base     =  0 .
     var-sum-contract =  0 .
     col-contract =  0 .
     if var-fin-calc = {&fin-calc-obj}  then do:
     /* {&fin-calc-obj} */
        for each temp-obj-firm
            on error undo, return error :
              var-sum-rubl =  0 .
              var-sum-base     =  0 .
              var-sum-contract =  0 .
              col-contract =  0 .

                   for each tt-fin-ob where
                            tt-fin-ob.obj-code =  temp-obj-firm.obj-code and
                            tt-fin-ob.obj-type =  temp-obj-firm.obj-type
                            ,
                      first buf_contract no-lock where buf_contract.contract-code = tt-fin-ob.contract-code and
                                                        buf_contract.host-code     = par-host-code           and
                                                        buf_contract.usl-opl       <> {&contr-pay-fact-out-prc}
                            break by tt-fin-ob.contract-code
                                  by tt-fin-ob.pc
                            on error undo, return error :
                            var-sum-rubl = var-sum-rubl         + tt-fin-ob.sum-rubl.
                            var-sum-base     = var-sum-base     + tt-fin-ob.sum-base.
                            var-sum-contract = var-sum-contract + tt-fin-ob.sum-contract .


                            if last-of(tt-fin-ob.contract-code)  or (p-nalog = 2 and last-of(tt-fin-ob.pc))  then do:
                                col-contract = col-contract + 1 .
                                if ( col-contract  modulo temp1 = 0 ) and ( col-contract >= temp1 ) then run waitfram-show( "Объединение по договорам : " + string( col-contract )) .
                                run make-s-fo-obj (
                                      input var-sum-rubl,
                                      input var-sum-base,
                                      input var-sum-contract,
                                      input temp-obj-firm.obj-type ,
                                      input temp-obj-firm.obj-code,
                                      input tt-fin-ob.pc    )
                                      no-error .

                                    if error-status :error then do:
                                      col-fo = col-fo - 1.
                                      p-res = p-res + {&new-line} + error-status :get-message(1) .
                                    end.
                                var-sum-rubl =  0 .
                                var-sum-base =  0 .
                                var-sum-contract =  0 .

                            end.
                   end.  /* tt-fin-`ob */


        end.
     end.
     else do:

          for each tt-fin-ob  ,
              first buf_contract no-lock where buf_contract.contract-code = tt-fin-ob.contract-code and
                                                buf_contract.host-code     = par-host-code           and
                                                buf_contract.usl-opl       <> {&contr-pay-fact-out-prc}
                    break by tt-fin-ob.contract-code
                          by tt-fin-ob.pc
                    on error undo, return error :
                    var-sum-rubl = var-sum-rubl + tt-fin-ob.sum-rubl.
                    var-sum-base = var-sum-base + tt-fin-ob.sum-base.
                    var-sum-contract = var-sum-contract + tt-fin-ob.sum-contract.


                    if last-of(tt-fin-ob.contract-code)  or (p-nalog = 2 and last-of(tt-fin-ob.pc))  then do:
                        col-contract = col-contract + 1 .
                        if ( col-contract  modulo temp1 = 0 ) and ( col-contract >= temp1 ) then run waitfram-show( "Объединение по договорам : " + string( col-contract )) .
                        run make-s-fo ( input var-sum-rubl, input var-sum-base , input var-sum-contract , input tt-fin-ob.pc ) no-error .
                            if error-status :error then do:
                              col-fo = col-fo - 1.
                              p-res = p-res + {&new-line} + error-status :get-message(1) .
                            end.
                        var-sum-rubl =  0 .
                        var-sum-base     =  0 .
                        var-sum-contract =  0 .

                    end.
            end.  /* tt-fin-ob */
     end.
  end. /* if p-cons = 1 */
run waitfram-hide.

if col-fo    < 0 then col-fo    = 0 .
if col-bfo   < 0 then col-bfo   = 0 .

p-res = p-res  + {&new-line}   +  {&new-line}   +
       "Генерация завершена: " + cur-time-string()  + {&new-line} +
       "за период до " + string( p-date-end,"99/99/9999")  + {&new-line} +
       " Создано финансовых обязательств :" + string(col-fo) + {&new-line} +
       " Создано ПредФинанОбязательств   :" + string(col-bfo) + {&new-line} +  {&new-line} +
       "Просмотрено накладных            :" + string(col-trn)           + {&new-line} +
       "Просмотрено договоров            :" + string(col-contract)
       .
return .

/*---------------*/

procedure proc-body :
 do
 on error undo, return error return-value
 :

/* ПО НАКЛАДНОЙ */



define variable sum-gds-code as decimal no-undo .
define buffer buf_minus-parts for c-parts.

define variable v-flag-po as logical no-undo .
define variable v-flag-ex as logical no-undo .
define variable v-may-be as logical   no-undo .

if buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price} then return.
if buf_trn-doc.is-del     = false                     then return.
{ str/doc-fogn.i
  "'del'"
  {&expense}
  buf_trn-doc.doc-code
  g#db-num
  v-may-be
}
if v-may-be = false then do:
   p-res = p-res + {&new-line} + substitute("По документу &1 нельзя создавать ФО в этой БД" , buf_trn-doc.doc-code ) .
   return .
end.

assign
  v-flag-po = ( if buf_trn-doc.cr-incfo = true then true else false )
  v-flag-ex = ( if buf_trn-doc.cr-expfo = true then true else false )
  col-trn = col-trn + 1
  .

/* Определение знака для накапливания суммы */
define variable v-num-pl as integer no-undo .

v-num-pl = lookup( buf_trn-doc.ext-doc-type, v-type-trn-doc ) .
v-sign = integer (entry(v-num-pl, v-sign-list )).
if v-sign = ? or v-sign = 0 then v-sign = 1.

var-sum-rubl = 0 . /* если по каждому документу свое фин об */
var-sum-base = 0 .
var-sum-contract = 0.

if ( col-trn  modulo temp1 = 0 ) and ( col-trn >= temp1 ) then run waitfram-show( "Обработано накладных : " + string( col-trn )) .

      for each buf_parts no-lock where buf_parts.out-code  = buf_trn-doc.doc-code   and
                                       buf_parts.host-code = buf_trn-doc.host-code  and
                                       buf_parts.obj-type  = buf_trn-doc.obj-type   and
                                       buf_parts.obj-code  = buf_trn-doc.obj-code ,
              first buf_goods no-lock where buf_goods.artic     = buf_parts.artic      and
                                            buf_goods.prod-type = buf_parts.prod-type  and
                                            buf_goods.prod-code = buf_parts.prod-code ,
              first buf_parts-attr no-lock where buf_parts-attr.in-code   = buf_parts.in-code   and
                                                 buf_parts-attr.part-code = buf_parts.part-code and
                                                 buf_parts-attr.gds-code  = buf_goods.gds-code ,
              first buf_contract no-lock where buf_contract.contract-code = buf_parts.contract-code and
                                               buf_contract.host-code     = buf_parts.host-code     and
                                               lookup(buf_contract.usl-opl , p-usl-opl ) > 0  and
                          /* проверка на соответствеи расширенного типа партии и условия договора */
                          /* если это по поставке */
                            ((
                            lookup ( buf_contract.usl-opl , {&o-postavka} ) > 0 and
                            lookup ( buf_trn-doc.ext-doc-type , {&in-fo-tdedt}  ) > 0
                            ) OR
                          /* если это по реализации */
                            ( lookup ( buf_contract.usl-opl , {&o-realiz} ) > 0   and
                              lookup ( buf_trn-doc.ext-doc-type , {&ex-fo-tdedt} + {&inv-fo-tdedt} ) > 0
                              ) )
              break
                    by buf_parts.contract-code
                    by buf_parts.vat-pc
                    by buf_parts-attr.income-in-code
                    on error undo, return error :

          run ver-purch-resp-store (output  v-ok ).
          if v-ok = true then do:

/*                    message buf_contract.usl-opl buf_trn-doc.ext-doc-type
                    buf_parts.contract-code
                    buf_parts-attr.income-in-code
                    v-flag-ex
                    .
  */
         Run clc-price.
         /* обработка инвентаризации ------------------------------------------------------------------------------------*/
         if lookup ( buf_trn-doc.ext-doc-type , {&inv-fo-tdedt} ) > 0 then do:
             find first c-doc-attr no-lock where
                        c-doc-attr.doc-code  = buf_trn-doc.doc-code and
                        c-doc-attr.attr-code = {&trdcattr-oldsuppcntr} no-error .

                if available c-doc-attr then do:
                   if  c-doc-attr.attr-value = "yes" then next .
                end.
              if  /* если по realiz и  партии fact-qnty   - */
                  ( lookup(buf_contract.usl-opl , {&o-realiz} ) > 0 and
                    buf_parts.fact-qnty <= 0 and
                    v-flag-ex = false
                    )
               then do:
                  if buf_trn-doc.ext-doc-type <> {&TDEDT_Peresort} then do:
                  if buf_contract.usl-opl = {&contr-pay-fact-out-prc}
                    then  assign
                          var-sum-rublb     = var-sum-rublb     + abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) ) * (-1)
                          var-sum-contractb = var-sum-contractb + abs(tt-allsum.sum-dsc-cli-acc                                                                )  * (-1)
                          var-sum-baseb     = var-sum-baseb     + abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) ) * (-1)

                          .
                    else
                        assign
                                var-sum-rubl     = var-sum-rubl     + abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc)  ) * (-1)
                                var-sum-contract = var-sum-contract + abs(tt-allsum.sum-dsc-cli-acc                                                                )  * (-1)
                                var-sum-base     = var-sum-base     + abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc)  ) * (-1)
                        .


                  create temp-parts.
                  BUFFER-COPY buf_parts to temp-parts
                  assign
                    temp-parts.cli-qnty       =  abs( buf_parts.cli-qnty  ) * (-1)
                    temp-parts.fact-qnty      =  abs( buf_parts.fact-qnty ) * (-1)
                    temp-parts.qnty           =  abs( buf_parts.qnty      ) * (-1)
                    temp-parts.gds-code       =  buf_goods.gds-code
                    temp-parts.income-in-code =  buf_parts-attr.income-in-code
                    var-income-in-code        =  buf_parts-attr.income-in-code
                  .
              end.
                  else do: /* Пересортица  только по партиям списания (-) и только по расходным договорам */
                    if buf_contract.usl-opl = {&contr-pay-fact-out-prc} then
                            assign
                              var-sum-rublb     = var-sum-rublb     +  abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )  * (-1)
                              var-sum-contractb = var-sum-contractb +  abs(tt-allsum.sum-dsc-cli-acc                                                                )  * (-1)
                              var-sum-baseb     = var-sum-baseb     +  abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) )  * (-1)
                            .
                        else
                            assign
                                    var-sum-rubl     = var-sum-rubl     + abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )  * (-1)
                                    var-sum-contract = var-sum-contract + abs(tt-allsum.sum-dsc-cli-acc                                                                )  * (-1)
                                    var-sum-base     = var-sum-base     + abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) )  * (-1)
                            .
                      create temp-parts .
                      BUFFER-COPY buf_parts to temp-parts
                      assign
                        temp-parts.cli-qnty       =  abs( buf_parts.cli-qnty  )  * (-1)
                        temp-parts.fact-qnty      =  abs( buf_parts.fact-qnty )  * (-1)
                        temp-parts.qnty           =  abs( buf_parts.qnty      )  * (-1)
                        temp-parts.gds-code       =  buf_goods.gds-code
                        temp-parts.income-in-code =  buf_parts-attr.income-in-code
                        var-income-in-code        =  buf_parts-attr.income-in-code
                      .

                  end.
              end.

              if  /* если по realiz    и партии fact-qnty + */
                  ( lookup(buf_contract.usl-opl , {&o-realiz} ) > 0 and
                    buf_parts.fact-qnty > 0 and
                    v-flag-ex = false )
               then do:
                 if buf_trn-doc.ext-doc-type <> {&TDEDT_Peresort} then do:
                 if buf_contract.usl-opl = {&contr-pay-fact-out-prc} then
                        assign
                          var-sum-rublb     = var-sum-rublb     +  abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )
                          var-sum-contractb = var-sum-contractb +  abs(tt-allsum.sum-dsc-cli-acc                                                                )
                          var-sum-baseb     = var-sum-baseb     +  abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) )
                        .

                    else
                        assign
                                var-sum-rubl     = var-sum-rubl     + abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )
                                var-sum-contract = var-sum-contract + abs(tt-allsum.sum-dsc-cli-acc                                                                )
                                var-sum-base     = var-sum-base     + abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) )
                        .


                  create temp-parts .
                  BUFFER-COPY buf_parts to temp-parts
                  assign
                    temp-parts.cli-qnty       =  (-1) * abs( buf_parts.cli-qnty  ) * (-1)
                    temp-parts.fact-qnty      =  (-1) * abs( buf_parts.fact-qnty ) * (-1)
                    temp-parts.qnty           =  (-1) * abs( buf_parts.qnty      ) * (-1)
                    temp-parts.gds-code       =  buf_goods.gds-code
                    temp-parts.income-in-code =  buf_parts-attr.income-in-code
                    var-income-in-code        =  buf_parts-attr.income-in-code
                  .
              end.
              end.

         end.
         /* не инвентаризация -------------------------------------------------------------------------------------------*/
         if lookup ( buf_trn-doc.ext-doc-type , {&inv-fo-tdedt} ) = 0  and
              (  /* проверка на галочки в trn  */
               ( lookup(buf_contract.usl-opl , {&o-postavka} ) > 0 and /* по поставке можно */
                    v-flag-po = false )
                  or
                  ( lookup(buf_contract.usl-opl , {&o-postavka} ) = 0 and     /* по реализации можно */
                    v-flag-ex = false )
                    )
         then do:
              run ver-type-purch (output v-ok ).
              if v-ok = true then do:
                if buf_contract.usl-opl = {&contr-pay-fact-out-prc}
                    then
                        assign
                          var-sum-rublb     = var-sum-rublb     + (v-sign) * abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )  * (-1)
                          var-sum-contractb = var-sum-contractb + (v-sign) * abs(tt-allsum.sum-dsc-cli-acc                                                                )  * (-1)
                          var-sum-baseb     = var-sum-baseb     + (v-sign) * abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) )  * (-1)
                        .

                    else
                        assign
                                var-sum-rubl     = var-sum-rubl     + (v-sign) * abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )  * (-1)
                                var-sum-contract = var-sum-contract + (v-sign) * abs(tt-allsum.sum-dsc-cli-acc                                                                )   * (-1)
                                var-sum-base     = var-sum-base     + (v-sign) * abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) )  * (-1)
                        .

                  create temp-parts.
                  BUFFER-COPY buf_parts to temp-parts
                  assign
                    temp-parts.cli-qnty       = v-sign * abs(buf_parts.cli-qnty)  * (-1)
                    temp-parts.fact-qnty      = v-sign * abs(buf_parts.fact-qnty) * (-1)
                    temp-parts.qnty           = v-sign * abs(buf_parts.qnty)      * (-1)
                    temp-parts.gds-code       = buf_goods.gds-code
                    temp-parts.income-in-code = buf_parts-attr.income-in-code
                    var-income-in-code        = buf_parts-attr.income-in-code
                  .
              end.
              /* message var-income-in-code . */
         end.
       end.
          /*-------------------------------------------------------------------------------------------------------------*/
            if last-of ( buf_parts-attr.income-in-code ) then do:
                  if buf_contract.usl-opl = {&contr-pay-fact-out-prc}  and
                     lookup ( buf_trn-doc.ext-doc-type , {&ex-fo-tdedt} + {&inv-fo-tdedt} ) > 0 /* для накладных расходных  */
                     then do:
                            /* создание предфин обяз     1 накл. -> М пред.фин.об.  */
                            /* message var-sum-rublb "PFO" . */
                            run make-bfo ( input var-sum-rublb ,
                                           input var-sum-baseb ,
                                           input var-sum-contractb,
                                           input buf_parts-attr.income-in-code)
                                           no-error .
                            if error-status :error then
                            do:
                                message vss-workfile vss-revision vss-description skip
                                       "Ошибка  " skip
                                        skip
                                        error-status :get-message(1) skip
                                        return-value skip
                                        view-as alert-box error
                                .
                                col-bfo = col-bfo - 1.
                                p-res = p-res + {&new-line} + error-status :get-message(1) .
                            end.
                            var-sum-rublb = 0 .
                            var-sum-baseb = 0 .
                            var-sum-contractb = 0 .

                  end.
            end.

            if last-of(buf_parts.contract-code) or (p-nalog = 2 and last-of(buf_parts.vat-pc)) then do:
               var-sum-rublb = 0 .
               var-sum-baseb = 0 .
               var-sum-contractb = 0 .

                  if buf_contract.usl-opl <> {&contr-pay-fact-out-prc} then do:
                      if p-cons = 1 then do: /* Если нало по всем накладным одного договора       M накл. -> 1 фин.об.  */
                            run make-tt-fo ( input var-sum-rubl ,
                                             input var-sum-base ,
                                             input var-sum-contract ,
                                             input buf_parts.vat-pc
                                             ) no-error .
                            if error-status :error then do:
                                message vss-workfile vss-revision vss-description skip
                                      "test3" error-status :get-message(1)
                                       error-status :error
                                       error-status :get-message(1) skip
                                       return-value skip
                                       view-as alert-box error
                               .
                               p-res = p-res + {&new-line} + error-status :get-message(1) .
                            end.
                          var-sum-rubl = 0 .
                          var-sum-base = 0 .
                          var-sum-contract = 0 .

                      end.
                      else do: /* Если нало по каждой накладной создавать ФинОб        1 накл. -> М фин.об.  */
                          run make-fo ( input var-sum-rubl ,
                                        input var-sum-base ,
                                        input var-sum-contract
                                        ) no-error .
                          if error-status :error then  do:
                             col-fo = col-fo - 1.
                             p-res = p-res + {&new-line} + error-status :get-message(1) .
                          end.
                          var-sum-rubl = 0 .
                          var-sum-base = 0 .
                          var-sum-contract = 0 .

                      end.
                  end.  /* не по частям */

            end. /* if last-of */
      end. /* parts */


 end. /* do */
end procedure. /* proc-body */



procedure proc-body-corr-acc :
 do
 on error undo, return error return-value
 :

define variable sum-gds-code as decimal no-undo .
define buffer buf_minus-parts for c-parts.

define variable v-flag-po as logical no-undo .
define variable v-flag-ex as logical no-undo .
define variable v-may-be as logical   no-undo .

if buf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price} then return.
if buf_trn-doc.is-del     = false                     then return.


{ str/doc-fogn.i
  "'del'"
  {&expense}
  buf_trn-doc.doc-code
  g#db-num
  v-may-be
}
if v-may-be = false then do:
   p-res = p-res + {&new-line} + substitute("По документу &1 нельзя создавать ФО в этой БД" , buf_trn-doc.doc-code ) .
   return .
end.

assign
  v-flag-po = ( if buf_trn-doc.cr-incfo = true then true else false )
  v-flag-ex = ( if buf_trn-doc.cr-expfo = true then true else false )
.


 /* ПО НАКЛАДНОЙ */
       col-trn = col-trn + 1 .

var-sum-rubl = 0 . /* если по каждому документу свое фин об */
var-sum-base = 0 .
var-sum-contract = 0 .

      if ( col-trn  modulo temp1 = 0 ) and ( col-trn >= temp1 ) then run waitfram-show( "Обработано накладных : " + string( col-trn )) .

      /* порожденные партиии с   -  */
      for each buf_parts no-lock where buf_parts.out-code  = buf_trn-doc.doc-code   and
                                       buf_parts.in-code   <> buf_trn-doc.doc-code   and
                                       buf_parts.host-code = buf_trn-doc.host-code  and
                                       buf_parts.obj-type  = buf_trn-doc.obj-type   and
                                       buf_parts.obj-code  = buf_trn-doc.obj-code   and
                                       buf_parts.fact-qnty < 0  ,
              first buf_contract no-lock where buf_contract.contract-code = buf_parts.contract-code and
                                               buf_contract.host-code     = buf_parts.host-code     and
                                               lookup(buf_contract.usl-opl , {&o-postavka} ) > 0    and
                                               v-flag-po = false
              break
                    by buf_parts.contract-code
                    by buf_parts.vat-pc
                    on error undo, return error  :

              Run clc-price.
              find first buf_goods no-lock where buf_goods.artic     = buf_parts.artic      and
                                                buf_goods.prod-type = buf_parts.prod-type  and
                                                buf_goods.prod-code = buf_parts.prod-code .

              find first buf_parts-attr no-lock where buf_parts-attr.in-code   = buf_parts.in-code   and
                                                 buf_parts-attr.part-code = buf_parts.part-code and
                                                 buf_parts-attr.gds-code  = buf_goods.gds-code .


                  assign
                          var-sum-rubl     = var-sum-rubl     +  abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )
                          var-sum-contract = var-sum-contract +  abs(tt-allsum.sum-dsc-cli-acc                                                                )
                          var-sum-base     = var-sum-base     +  abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) )
                  .

                  create temp-parts.
                  BUFFER-COPY buf_parts to temp-parts
                  assign
                    temp-parts.cli-qnty       =  (-1) * abs( buf_parts.cli-qnty)    * (-1)
                    temp-parts.fact-qnty      =  (-1) * abs( buf_parts.fact-qnty)   * (-1)
                    temp-parts.qnty           =  (-1) * abs( buf_parts.qnty     )   * (-1)
                    temp-parts.gds-code       =  buf_goods.gds-code
                    temp-parts.income-in-code =  buf_parts-attr.income-in-code
                    var-income-in-code        =  buf_parts-attr.income-in-code
                  .

            if last-of(buf_parts.contract-code) or (p-nalog = 2 and last-of(buf_parts.vat-pc)) then do:

              run make-fo-corr ( input var-sum-rubl ,
                                     input var-sum-base ,
                                     input var-sum-contract )
                                     no-error .
              if error-status :error then p-res = p-res + {&new-line} + error-status :get-message(1) .
              var-sum-rubl = 0 .
              var-sum-rublb = 0 .
              var-sum-base      = 0 .
              var-sum-baseb     = 0 .
              var-sum-contract  = 0 .
              var-sum-contractb = 0 .

            end. /* if last-of */

      end. /* parts - */

var-sum-rubl  = 0 .
var-sum-rublb = 0 .
var-sum-base      = 0 .
var-sum-baseb     = 0 .
var-sum-contract  = 0 .
var-sum-contractb = 0 .

      /* порожденные партиии с   +  */
      for each buf_parts no-lock where buf_parts.out-code  = buf_trn-doc.doc-code   and
                                       buf_parts.in-code   = buf_trn-doc.doc-code   and
                                       buf_parts.host-code = buf_trn-doc.host-code  and
                                       buf_parts.obj-type  = buf_trn-doc.obj-type   and
                                       buf_parts.obj-code  = buf_trn-doc.obj-code   and
                                       buf_parts.fact-qnty >= 0     ,
              first buf_goods no-lock where buf_goods.artic     = buf_parts.artic      and
                                            buf_goods.prod-type = buf_parts.prod-type  and
                                            buf_goods.prod-code = buf_parts.prod-code ,
              first buf_contract no-lock where buf_contract.contract-code = buf_parts.contract-code and
                                               buf_contract.host-code     = buf_parts.host-code     and
                                               lookup(buf_contract.usl-opl , {&o-postavka} ) > 0 and
                                               v-flag-po = false
              break
                    by buf_parts.contract-code
                    by buf_parts.vat-pc
                    on error undo, return error :
              Run clc-price.
              find first buf_parts-attr no-lock where buf_parts-attr.in-code   = buf_parts.in-code   and
                                                 buf_parts-attr.part-code = buf_parts.part-code and
                                                 buf_parts-attr.gds-code  = buf_goods.gds-code .

              /* если по postavka и  партии fact-qnty   + */
                  assign
                    var-sum-rubl     = var-sum-rubl     +  abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )   * (-1)
                    var-sum-contract = var-sum-contract +  abs(tt-allsum.sum-dsc-cli-acc                                                                )    * (-1)
                    var-sum-base     = var-sum-base     +  abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) )   * (-1)
                  .

                  create temp-parts.
                  BUFFER-COPY buf_parts to temp-parts
                  assign
                    temp-parts.cli-qnty       =  abs( buf_parts.cli-qnty  )     * (-1)
                    temp-parts.fact-qnty      =  abs( buf_parts.fact-qnty )     * (-1)
                    temp-parts.qnty           =  abs( buf_parts.qnty      )     * (-1)
                    temp-parts.gds-code       =  buf_goods.gds-code
                    temp-parts.income-in-code =  buf_parts-attr.income-in-code
                    var-income-in-code        =  buf_parts-attr.income-in-code
                  .

            if last-of(buf_parts.contract-code) or (p-nalog = 2 and last-of(buf_parts.vat-pc)) then do:
              run make-fo-corr (  input var-sum-rubl ,
                                      input var-sum-base ,
                                      input var-sum-contract ) no-error .
              if error-status :error then p-res = p-res + {&new-line} + error-status :get-message(1) .
              var-sum-rubl = 0 .
              var-sum-rublb = 0 .
              var-sum-base      = 0 .
              var-sum-baseb     = 0 .
              var-sum-contract  = 0 .
              var-sum-contractb = 0 .

            end. /* if last-of */
      end. /* parts +  */

 end. /* do */
end procedure. /* proc-body-corr */

procedure make-fo :
 do
 on error undo, return error return-value
 :
define input parameter v-sum-rubl as decimal no-undo .
define input parameter v-sum-base as decimal no-undo .
define input parameter v-sum-contract as decimal no-undo .



 define variable pfo as logical no-undo .
 pfo = false  .
{ str/gen-flpi.i }
  run fin-ob-code (input g#db-num , output p-doc-code) .
  run create-fin-liab (
        input yes ,
        input  p-doc-code                       ,
        input  n-doc-date            ,
        input  n-doc-type           ,
        input  n-payer-name         ,
        input  n-receiver-name      ,
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
        input  "Корректирующее ФО "  ,
        output p-ri )
        no-error .
        /* if error-status :error then  return. */
        col-fo = col-fo + 1.
        col-contract = col-contract + 1 .

          find first  buf_fin-ob-trn no-lock  where
              buf_fin-ob-trn.doc-code       = p-doc-code  and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = tt-trn-code.doc-code  no-error .
              if not available  buf_fin-ob-trn then  do:

            create buf_fin-ob-trn.
            assign
              buf_fin-ob-trn.doc-code       = p-doc-code
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.sum-rubl       = n-sum-rubl
              buf_fin-ob-trn.trn-doc-code   = buf_trn-doc.doc-code
              buf_fin-ob-trn.is-corr        = true
            .
            end.


                find first buf2_trn-doc  exclusive-lock  where buf2_trn-doc.doc-code = buf_trn-doc.doc-code no-error .
                if available buf2_trn-doc then do:
                   if lookup( buf_contract.usl-opl , {&o-postavka}  ) > 0 then do:
                    assign
                      buf2_trn-doc.cr-incfo   = true
                      buf2_trn-doc.cr-incorexpfo = true
                      buf2_trn-doc.incfo-date = today
                    .
                     if buf2_trn-doc.need-incfo = 2 then do:
                       assign
                         buf2_trn-doc.need-incfo      = 1
                         buf2_trn-doc.need-expfo      = 0
                         buf2_trn-doc.need-incorexpfo = 1
                       .
                     end.
                    end.
                    else do:
                      assign
                        buf2_trn-doc.cr-expfo   = true
                        buf2_trn-doc.cr-incorexpfo = true
                        buf2_trn-doc.expfo-date = today
                      .
                      if buf2_trn-doc.need-expfo = 2 then do:
                        assign
                          buf2_trn-doc.need-expfo      = 1
                          buf2_trn-doc.need-incfo      = 0
                          buf2_trn-doc.need-incorexpfo = 1
                        .
                      end.
                    end.
                    end.
                  else
                  message vss-workfile vss-revision vss-description skip
                         "Ошибка  test2" skip
                          skip
                          error-status :get-message(1) skip
                          return-value skip
                          view-as alert-box error
                  .

/* создадим партии по фин обязательству */
    run make-fin-parts (input p-doc-code , input 1 ) .
  for each temp-parts where temp-parts.contract-code = buf_contract.contract-code : delete temp-parts . end.
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

 end. /* do */
end procedure. /* make-fo */

procedure make-tt-fo :
 do
 on error undo, return error return-value
 :

define input parameter v-sum-rubl as decimal no-undo .
define input parameter v-sum-base as decimal no-undo .
define input parameter v-sum-contract as decimal no-undo .
define input  parameter v-pc as decimal   no-undo .

v-pc = if p-nalog = 1 then 0 else v-pc .
 define variable pfo as logical no-undo .
 pfo = false  .

{ str/gen-flpi.i }
  v-k = v-k + 1    .

   create tt-fin-ob .
   assign
    tt-fin-ob.contract-code = buf_contract.contract-code
    tt-fin-ob.host-code     = par-host-code
    tt-fin-ob.sum-rubl      = v-sum-rubl
    tt-fin-ob.sum-base      = v-sum-base
    tt-fin-ob.sum-contract  = v-sum-contract
    tt-fin-ob.doc-code      = string(v-k)
    tt-fin-ob.obj-code      = buf_trn-doc.obj-code
    tt-fin-ob.obj-type      = buf_trn-doc.obj-type
    tt-fin-ob.pc            =  v-pc
  .
      if not can-find ( first tt-trn-code  where
            tt-trn-code.contract-code = buf_contract.contract-code and
            tt-trn-code.host-code     = par-host-code              and
            tt-trn-code.pc            = v-pc                      and
            tt-trn-code.doc-code      = buf_trn-doc.doc-code       ) then do:
            create tt-trn-code.
            assign
                  tt-trn-code.contract-code = buf_contract.contract-code
                  tt-trn-code.host-code     = par-host-code
                  tt-trn-code.doc-code      = buf_trn-doc.doc-code
                  tt-trn-code.fact-date     = buf_trn-doc.fact-date
                  tt-trn-code.sum-rubl      = v-sum-rubl
                  tt-trn-code.sum-base      = v-sum-base
                  tt-trn-code.sum-contract  = v-sum-contract
                  tt-trn-code.pc            = v-pc
                  tt-trn-code.obj-code      = buf_trn-doc.obj-code
                  tt-trn-code.obj-type      = buf_trn-doc.obj-type

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
{ str/gen-flpi.i }
/* найдем мин дату */
define variable min-date as date no-undo .
define variable max-date as date no-undo .
        for each tt-trn-code  where
            tt-trn-code.contract-code = buf_contract.contract-code  and
            tt-trn-code.host-code     = par-host-code
            break by tt-trn-code.fact-date DESCENDING
            on error undo, return error
            :
            min-date = tt-trn-code.fact-date.
        end.
        /*
        for each tt-trn-code  where
            tt-trn-code.contract-code = buf_contract.contract-code  and
            tt-trn-code.host-code     = par-host-code
            break by tt-trn-code.fact-date
            on error undo, return error
            :
            max-date = tt-trn-code.fact-date.
        end.
        */
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
    input  "Корректирующее ФО "  ,
    output p-ri )
    no-error .

  /* if error-status :error then  return. */
  col-fo = col-fo + 1.
  /* col-contract = col-contract + 1 . */

  for each tt-trn-code  where
      tt-trn-code.contract-code = buf_contract.contract-code  and
      tt-trn-code.host-code     = par-host-code
      on error undo, return error :

        find first  buf_fin-ob-trn no-lock  where
              buf_fin-ob-trn.doc-code       = p-doc-code  and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = tt-trn-code.doc-code  no-error .
              if not available  buf_fin-ob-trn then  do:

            create buf_fin-ob-trn.
            assign
              buf_fin-ob-trn.doc-code       = p-doc-code
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.sum-rubl       = tt-trn-code.sum-rubl
              buf_fin-ob-trn.sum-tax-rubl   = 0
              buf_fin-ob-trn.trn-doc-code   = tt-trn-code.doc-code
              buf_fin-ob-trn.is-corr        = true
            .
            end.


      find first buf2_trn-doc  exclusive-lock  where buf2_trn-doc.doc-code = tt-trn-code.doc-code no-error .
      if available buf2_trn-doc then do:
        if lookup( buf_contract.usl-opl , {&o-postavka}  ) > 0 then do:
            assign
              buf2_trn-doc.cr-incfo   = true
              buf2_trn-doc.cr-incorexpfo = true
              buf2_trn-doc.incfo-date = today

            .
            if buf2_trn-doc.need-incfo = 2 then do:
              assign
                buf2_trn-doc.need-incfo      = 1
                buf2_trn-doc.need-expfo      = 0
                buf2_trn-doc.need-incorexpfo = 1
              .
            end.
        end.
        else do:
            assign
              buf2_trn-doc.cr-expfo   = true
              buf2_trn-doc.cr-incorexpfo = true
              buf2_trn-doc.expfo-date = today
            .
            if buf2_trn-doc.need-expfo = 2 then do:
              assign
                buf2_trn-doc.need-expfo      = 1
                buf2_trn-doc.need-incfo      = 0
                buf2_trn-doc.need-incorexpfo = 1
              .
            end.
        end.
       end.
       else do:
          message vss-workfile vss-revision vss-description skip
                 "Ошибка test " skip
                  skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error
          .
       end.

      /* создадим партии по фин обязательству */
      if p-nalog = 1 then
          run make-fin-parts (input p-doc-code, input 2) .
       else
          run make-fin-parts-VAT (input p-doc-code, input v-pc) .

  end. /* tt-trn-code */

  run make-tax (
        input p-doc-code ,
        input par-host-code
        )                .
  run update-fin-ob_obj (
        input p-doc-code ,
        input par-host-code
        )
    .

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



procedure make-bfo :
 do
 on error undo, return error return-value
 :
define input parameter v-sum-rubl as decimal no-undo .
define input parameter v-sum-base as decimal no-undo .
define input parameter v-sum-contract as decimal no-undo .
define input parameter p-doc-code-pri as character no-undo .

define buffer t-buf_fin-ob-trn for fin-ob-trn .
define buffer t-buf_fin-ob     for fin-ob .
define buffer buf4_trn-doc     for c-trn-doc.
define variable v-n  as character no-undo .
define variable v-go as logical no-undo init false .
define variable v-doc-code-fo as character no-undo init "".
define variable v-recid as recid no-undo .

define buffer buf3_trn-doc for c-trn-doc.
define buffer buf5_trn-doc for trn-doc. /* для прихода !!! */
define variable pfo as logical no-undo .
pfo = true .

run waitfram-show(" Создание корректирующих ПФО...").
/* Если по ПН уже создано ФО по ПФО */

define variable v-no-exist as logical no-undo init false .
/*  найдем последнее ФО по ПН  */
for each    t-buf_fin-ob-trn no-lock where
            t-buf_fin-ob-trn.trn-doc-code = var-income-in-code ,
            first  t-buf_fin-ob no-lock where
                   t-buf_fin-ob.doc-code      = t-buf_fin-ob-trn.doc-code   and
                   t-buf_fin-ob.contract-code = buf_contract.contract-code
             break by t-buf_fin-ob.doc-code
            :
              v-n = t-buf_fin-ob-trn.doc-code  .  /* № ФО у ПН  */
                                                 /* Созданное ФО и по тому же договору */
              v-doc-code-fo = string(v-n) .              /* Номер ФО на ПН */
              v-recid = recid(t-buf_fin-ob) .     /* recid  этого ФО */

end.




{ str/gen-flpi.i }

  run fin-ob-code (input g#db-num , output p-doc-code) .
  run create-fin-ob-before (
    input yes                    ,
    input  p-doc-code            ,
    input  v-doc-code-fo         ,
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
    input  n-trn-doc-code-orig   ,
    input  n-user-db-num-fact    ,
    input  n-user-db-num-pay      ,
    input  n-user-name-fact       ,
    input  n-user-name-pay        ,
    input  n-in-type              ,
    input  n-sum-tax-base         ,
    input  n-sum-tax-doc          ,
    input  n-sum-tax-rubl         ,
    input  n-sum-tax-contract     ,
    input "Корректирующее ПФО"  ,
    output p-ri )
    no-error .
    if error-status :error then
    message vss-workfile vss-revision vss-description skip
            "Ошибка  " skip
            skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error
    .

        col-bfo = col-bfo + 1.
        col-contract = col-contract + 1 .


           find first  buf_fin-ob-trn no-lock  where
              buf_fin-ob-trn.doc-code       = p-doc-code  and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = buf_trn-doc.doc-code
              no-error .
              if not available  buf_fin-ob-trn then  do:

            create buf_fin-ob-trn.
            assign
              buf_fin-ob-trn.doc-code       = p-doc-code
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.sum-rubl       = n-sum-rubl
              buf_fin-ob-trn.sum-tax-rubl   = n-sum-tax-rubl
              buf_fin-ob-trn.trn-doc-code   = buf_trn-doc.doc-code
              buf_fin-ob-trn.is-corr        = true
            .
            end.

                find first buf3_trn-doc  exclusive-lock  where buf3_trn-doc.doc-code = buf_trn-doc.doc-code no-error .
                if available buf3_trn-doc then do:
                    assign
                      buf3_trn-doc.cr-expfo      = true
                      buf3_trn-doc.cr-incorexpfo = true
                      buf3_trn-doc.expfo-date    = today
                     .
                    end.
                  else message error-status :get-message(1) "test pfo".
                      /* создадим партии по фин обязательству */

        /* создадим партии по фин обязательству */
          run make-fin-parts(input p-doc-code , input 2 ) .

        /* создадим налоги по партиям */
        run make-tax-before (
              input p-doc-code ,
              input par-host-code
              )                .


     run ver-prc (
        input v-doc-code-fo /* ФО */  ,
        output v-go ) .
     /* message "нужно создадим корр ФО" v-go . */
      /* если нужно создадим корр ФО */
      if v-go =  true    then do:
            /* создать корректирующее ФО */

            run make-fo-small ( input v-recid ,
                                input p-doc-code-pri)
                                no-error .
            if error-status :error then do:
              message vss-workfile vss-revision vss-description skip
                      "Ошибка make-fo-small " skip
                      skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error
              .
            end.
      end.


      for each temp-parts  where temp-parts.contract-code = buf_contract.contract-code
                              and temp-parts.out-code      = buf_fin-ob-trn.trn-doc-code :
            delete temp-parts .
      end.



 end. /* do */
end procedure. /* make-bfo */


procedure make-tax-before :
 do
 on error undo, return error return-value
 :

define input parameter p-doc-code as character no-undo .
define input parameter p-host-code as integer no-undo .
define buffer buf_fin-gds-part for  fin-gds-part .
define buffer buf_fin-ob-tax-before   for  fin-ob-tax-before .
define buffer buf_fin-ob-before       for  fin-ob-before     .
define variable v-line    as integer no-undo .
define variable v-sum     as decimal no-undo .
define variable v-tax-sum as decimal no-undo .
define variable v-tax-sum-rubl as decimal no-undo .
define variable v-tax-sum-base as decimal no-undo .
define variable v-tax-sum-contr as decimal no-undo .
define variable v-tax-sum-doc  as decimal no-undo .


for each buf_fin-ob-before  exclusive-lock  where  buf_fin-ob-before.host-code   = p-host-code and
                                                   buf_fin-ob-before.before-code = p-doc-code
                                                   on error undo, return error :
    v-tax-sum-rubl = 0 .
    v-tax-sum-base = 0 .
    v-tax-sum-contr = 0 .
    v-tax-sum-doc  = 0 .
    v-sum  = 0 .
    v-line = 0 .
    for each buf_fin-gds-part no-lock where
             buf_fin-gds-part.host-code   = buf_fin-ob-before.host-code and
             buf_fin-gds-part.fin-ob-code = buf_fin-ob-before.before-code
             break  by buf_fin-gds-part.SLT-pc
                    by buf_fin-gds-part.SLT-type
                    by buf_fin-gds-part.vat-pc
                    by buf_fin-gds-part.vat-type
                    by buf_fin-gds-part.gds-code
             on error undo, return error :

             v-sum = v-sum + buf_fin-gds-part.sum-rubl .
             if last-of(buf_fin-gds-part.gds-code) then do:
                v-line = v-line + 1.
                create buf_fin-ob-tax-before.
                assign
                    buf_fin-ob-tax-before.before-code        = buf_fin-ob-before.before-code
                    buf_fin-ob-tax-before.host-code          = buf_fin-ob-before.host-code
                    buf_fin-ob-tax-before.line-num           = v-line
                    buf_fin-ob-tax-before.slt-pc             = buf_fin-gds-part.slt-pc
                    buf_fin-ob-tax-before.vat-pc             = buf_fin-gds-part.vat-pc
                    buf_fin-ob-tax-before.with-slt           = true
                    buf_fin-ob-tax-before.with-vat           = true

                    buf_fin-ob-tax-before.sum-line-rubl      = v-sum
                    buf_fin-ob-tax-before.sum-slt-line-rubl  = buf_fin-ob-tax-before.slt-PC *    buf_fin-ob-tax-before.sum-line-rubl  / ( 100 + buf_fin-ob-tax-before.slt-PC )
                    buf_fin-ob-tax-before.sum-vat-line-rubl  = buf_fin-ob-tax-before.vat-PC * (( buf_fin-ob-tax-before.sum-line-rubl  -         buf_fin-ob-tax-before.sum-slt-line-rubl  ) / ( 100  + buf_fin-ob-tax-before.vat-PC))

                    buf_fin-ob-tax-before.sum-line-base       = ( buf_fin-ob-before.base-scale     / buf_fin-ob-before.base-rate)     * buf_fin-ob-tax-before.sum-line-rubl
                    buf_fin-ob-tax-before.sum-line-doc        = ( buf_fin-ob-before.exch-scale     / buf_fin-ob-before.exch-rate)     * buf_fin-ob-tax-before.sum-line-rubl
                    buf_fin-ob-tax-before.sum-line-contr      = ( buf_fin-ob-before.contract-scale / buf_fin-ob-before.contract-rate) * buf_fin-ob-tax-before.sum-line-rubl

                    buf_fin-ob-tax-before.sum-slt-line-base    = ( buf_fin-ob-before.base-scale     / buf_fin-ob-before.base-rate)     * buf_fin-ob-tax-before.sum-slt-line-rubl
                    buf_fin-ob-tax-before.sum-slt-line-doc     = ( buf_fin-ob-before.exch-scale     / buf_fin-ob-before.exch-rate)     * buf_fin-ob-tax-before.sum-slt-line-rubl
                    buf_fin-ob-tax-before.sum-slt-line-contr   = ( buf_fin-ob-before.contract-scale / buf_fin-ob-before.contract-rate) * buf_fin-ob-tax-before.sum-slt-line-rubl

                    buf_fin-ob-tax-before.sum-vat-line-base    = ( buf_fin-ob-before.base-scale     / buf_fin-ob-before.base-rate)     * buf_fin-ob-tax-before.sum-vat-line-rubl
                    buf_fin-ob-tax-before.sum-vat-line-doc     = ( buf_fin-ob-before.exch-scale     / buf_fin-ob-before.exch-rate)     * buf_fin-ob-tax-before.sum-vat-line-rubl
                    buf_fin-ob-tax-before.sum-vat-line-contr   = ( buf_fin-ob-before.contract-scale / buf_fin-ob-before.contract-rate) * buf_fin-ob-tax-before.sum-vat-line-rubl
                    .

                assign
                    buf_fin-ob-tax-before.with-slt-orig                = buf_fin-ob-tax-before.with-slt
                    buf_fin-ob-tax-before.slt-pc-orig                  = buf_fin-ob-tax-before.slt-pc
                    buf_fin-ob-tax-before.vat-pc-orig                  = buf_fin-ob-tax-before.vat-pc
                    buf_fin-ob-tax-before.sum-slt-line-doc-orig        = buf_fin-ob-tax-before.sum-slt-line-doc
                    buf_fin-ob-tax-before.sum-slt-line-base-orig       = buf_fin-ob-tax-before.sum-slt-line-base
                    buf_fin-ob-tax-before.sum-slt-line-contr-orig      = buf_fin-ob-tax-before.sum-slt-line-contr
                    buf_fin-ob-tax-before.sum-slt-line-rubl-orig       = buf_fin-ob-tax-before.sum-slt-line-rubl
                    buf_fin-ob-tax-before.with-vat-orig                = buf_fin-ob-tax-before.with-vat
                    buf_fin-ob-tax-before.sum-vat-line-doc-orig        = buf_fin-ob-tax-before.sum-vat-line-doc
                    buf_fin-ob-tax-before.sum-vat-line-base-orig       = buf_fin-ob-tax-before.sum-vat-line-base
                    buf_fin-ob-tax-before.sum-vat-line-contr-orig      = buf_fin-ob-tax-before.sum-vat-line-contr
                    buf_fin-ob-tax-before.sum-vat-line-rubl-orig       = buf_fin-ob-tax-before.sum-vat-line-rubl
                .

                assign
                    v-tax-sum-rubl                    = v-tax-sum-rubl + buf_fin-ob-tax-before.sum-slt-line-rubl   + buf_fin-ob-tax-before.sum-vat-line-rubl
                    v-tax-sum-base                    = v-tax-sum-base + buf_fin-ob-tax-before.sum-slt-line-base   + buf_fin-ob-tax-before.sum-vat-line-base
                    v-tax-sum-contr                   = v-tax-sum-contr + buf_fin-ob-tax-before.sum-slt-line-contr + buf_fin-ob-tax-before.sum-vat-line-contr
                    v-tax-sum-doc                     = v-tax-sum-doc + buf_fin-ob-tax-before.sum-slt-line-doc     + buf_fin-ob-tax-before.sum-vat-line-doc
                .
                v-sum  = 0 .
              end. /* if */
    end. /* for each */
    buf_fin-ob-before.sum-tax-doc   = v-tax-sum-doc .
    buf_fin-ob-before.sum-tax-rubl  = v-tax-sum-rubl .
    buf_fin-ob-before.sum-tax-base  = v-tax-sum-base .
    buf_fin-ob-before.sum-tax-contract = v-tax-sum-contr .
    v-tax-sum-rubl = 0 .
    v-tax-sum-base = 0 .
    v-tax-sum-contr = 0 .
    v-tax-sum-doc  = 0 .
end.

 end. /* do */
end procedure. /* make-tax */




procedure make-fo-corr :
 do
 on error undo, return error return-value
 :
define input parameter v-sum-rubl as decimal no-undo .
define input parameter v-sum-base as decimal no-undo .
define input parameter v-sum-contract as decimal no-undo .
 define variable pfo as logical no-undo .
 pfo = false  .

if buf_trn-doc.is-del     = false                     then return.

run waitfram-show(" Создание корректирующих ФО...").
{ str/gen-flpi.i }
  if  buf_trn-doc.fact-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) <= n-doc-date
      then n-pay-date = n-doc-date .
      else n-pay-date = buf_trn-doc.fact-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) .

      run fin-ob-code (input g#db-num , output p-doc-code) .
      run create-fin-liab (
        input yes ,
        input  p-doc-code                       ,
        input  n-doc-date           ,
        input  n-doc-type           ,
        input  n-payer-name         ,
        input  n-receiver-name      ,
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
        input  n-user-db-num-pay        ,
        input  n-user-name-fact         ,
        input  n-user-name-pay          ,
        input  n-in-type                ,
        input  n-sum-tax-base           ,
        input  n-sum-tax-doc            ,
        input  n-sum-tax-rubl           ,
        input  n-sum-tax-contract       ,
        input  "Корректирующее ФО "  ,
        output p-ri )
        no-error .
        /* if error-status :error then return. */
        col-fo = col-fo + 1.
        col-contract = col-contract + 1 .

            find first  buf_fin-ob-trn no-lock  where
              buf_fin-ob-trn.doc-code       = p-doc-code  and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = buf_trn-doc.doc-code
              no-error .
              if not available  buf_fin-ob-trn then  do:

            create buf_fin-ob-trn.
            assign
              buf_fin-ob-trn.doc-code       = p-doc-code
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.sum-tax-rubl   = n-sum-tax-rubl
              buf_fin-ob-trn.sum-rubl       = n-sum-rubl
              buf_fin-ob-trn.trn-doc-code   = buf_trn-doc.doc-code
              buf_fin-ob-trn.is-corr        = true


            .
            end.


                find first buf2_trn-doc  exclusive-lock  where buf2_trn-doc.doc-code = buf_trn-doc.doc-code no-error .
                if available buf2_trn-doc then do:
                   if lookup( buf_contract.usl-opl , {&o-postavka}  ) > 0 then do:
                    assign
                      buf2_trn-doc.cr-incfo   = true
                      buf2_trn-doc.cr-incorexpfo = true
                      buf2_trn-doc.incfo-date = today
                    .
                     if buf2_trn-doc.need-incfo = 2 then do:
                       assign
                         buf2_trn-doc.need-incfo      = 1
                         buf2_trn-doc.need-expfo      = 0
                         buf2_trn-doc.need-incorexpfo = 1
                       .
                     end.
                    end.
                    else do:
                    assign
                      buf2_trn-doc.cr-expfo   = true
                      buf2_trn-doc.cr-incorexpfo = true
                      buf2_trn-doc.expfo-date = today
                    .
                     if buf2_trn-doc.need-expfo = 2 then do:
                       assign
                         buf2_trn-doc.need-expfo      = 1
                         buf2_trn-doc.need-incfo      = 0
                         buf2_trn-doc.need-incorexpfo = 1
                       .
                     end.

                    end.

                    end.
                  else message "test4" error-status :get-message(1) .

        /* создадим партии по фин обязательству */
        run make-fin-parts (input p-doc-code , input 1 ) .

        for each temp-parts  where temp-parts.contract-code = buf_contract.contract-code  : delete temp-parts . end.
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

 end. /* do */
end procedure. /* make-fo-corr */



procedure make-fo-small :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
/* Корректируещее ФО если удалили РН с ПФО ,  а по ПН уже есть ФО */

define input parameter p-fo-recid as recid no-undo .
define input parameter p-doc-code-pri as character no-undo .

define variable v-doc-code  as character no-undo .
define variable  v-sum-rubl as decimal no-undo .
define variable  v-sum-base as decimal no-undo .
define variable  v-sum-contract as decimal no-undo .

define buffer buf-sm_fin-gds-part for fin-gds-part.
define buffer buf-sm_fin-ob for fin-ob.
define buffer buf-sm_fin-ob-tax for fin-ob-tax.
define buffer new_fin-ob for fin-ob.
define buffer new_fin-ob-tax for fin-ob-tax.
define buffer new_fin-gds-part for fin-gds-part.
define buffer buf_PN_trn-doc for trn-doc.

/* это значит что было создано +  и значит можно создать корректирующее  */
find first buf_PN_trn-doc no-lock  where
            buf_PN_trn-doc.doc-code =  p-doc-code-pri and
            buf_PN_trn-doc.need-expfo      = 1 no-error   .
 if not available buf_PN_trn-doc then return .



run waitfram-show(" Создание корректирующих ФО, вызванное ПФО...").

find first buf-sm_fin-ob no-lock where recid(buf-sm_fin-ob) = p-fo-recid no-error .
if error-status :error then
 message vss-workfile vss-revision vss-description skip
        "Ошибка поиска " skip
         skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error
 .



 define variable pfo as logical no-undo .
 pfo = false  .
{ str/gen-flpi.i }
assign
  n-sum-tax-base        = -1 * buf-sm_fin-ob.sum-tax-base
  n-sum-tax-doc         = -1 * buf-sm_fin-ob.sum-tax-doc
  n-sum-tax-rubl        = -1 * buf-sm_fin-ob.sum-tax-rubl
  n-sum-tax-contract    = -1 * buf-sm_fin-ob.sum-tax-contract
  n-sum-base-orig       = -1 * buf-sm_fin-ob.sum-base-orig
  n-sum-base            = -1 * buf-sm_fin-ob.sum-base
  n-sum-doc-orig        = -1 * buf-sm_fin-ob.sum-doc-orig
  n-sum-doc             = -1 * buf-sm_fin-ob.sum-doc
  n-sum-rubl-orig       = -1 * buf-sm_fin-ob.sum-rubl-orig
  n-sum-rubl            = -1 * buf-sm_fin-ob.sum-rubl
  n-sum-contract        = -1 * buf-sm_fin-ob.sum-contract
  .

  run fin-ob-code (input g#db-num , output v-doc-code) .
  run create-fin-liab (
        input yes                    ,
        input  v-doc-code            ,
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
        input  string(v-doc-code)    ,
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
        input  "Корректирующее ФО - вызвано удалением РН по ФО № " +
               string(buf-sm_fin-ob.doc-code) + " на ПН № " +  p-doc-code-pri ,
        output p-ri )
        no-error .
         if error-status :error then
         message vss-workfile vss-revision vss-description skip
                "Ошибка создания ФО " skip
                 skip
                 error-status :get-message(1) skip
                 return-value skip
                 view-as alert-box error
         .

        col-fo = col-fo + 1.

        /* изменяем статус ПФО на avto  */
        define buffer buf_pfo_fin-ob-before for fin-ob-before.

        for each  buf_pfo_fin-ob-before  exclusive-lock  where
                  buf_pfo_fin-ob-before.status_           = {&fin-fact}     and
                  buf_pfo_fin-ob-before.trn-doc-code-orig =  p-doc-code-pri and
                  buf_pfo_fin-ob-before.contract-code     =  n-contract-code
                  on error undo, return error :
            buf_pfo_fin-ob-before.status_           = {&fin-gen}.
        end. /* for each */


            create buf_fin-ob-trn.   /* Чтоб было видно из РН */
            assign
              buf_fin-ob-trn.doc-code       = v-doc-code
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.sum-rubl       = n-sum-rubl
              buf_fin-ob-trn.trn-doc-code   = buf_trn-doc.doc-code
              buf_fin-ob-trn.is-corr        = true
            .
            create buf_fin-ob-trn.  /* Чтоб было видно из прихода */
            assign
              buf_fin-ob-trn.doc-code       = v-doc-code
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.sum-rubl       = n-sum-rubl
              buf_fin-ob-trn.trn-doc-code   = p-doc-code-pri
              buf_fin-ob-trn.is-corr        = true
            .

                find first buf2_trn-doc  exclusive-lock  where buf2_trn-doc.doc-code = buf_trn-doc.doc-code no-error .
                  if available buf2_trn-doc then do:
                      assign
                        buf2_trn-doc.cr-expfo   = true
                        buf2_trn-doc.cr-incorexpfo = true
                        buf2_trn-doc.expfo-date = today
                      .
                      if buf2_trn-doc.need-expfo = 2 then do:
                        assign
                          buf2_trn-doc.need-expfo      = 1
                          buf2_trn-doc.need-incfo      = 0
                          buf2_trn-doc.need-incorexpfo = 1
                        .
                      end.
                    end.
                  else do:
                  message vss-workfile vss-revision vss-description skip
                         "Ошибка  при изменении РН" skip
                          skip
                          error-status :get-message(1) skip
                          return-value skip
                          view-as alert-box error
                  .
                  undo, return error .
                  end.
                find first buf_PN_trn-doc exclusive-lock  where buf_PN_trn-doc.doc-code =  p-doc-code-pri no-error .
                  if available buf_PN_trn-doc then do:
                      assign
                        buf_PN_trn-doc.cr-expfo        = true
                        buf_PN_trn-doc.cr-incorexpfo   = true
                        buf_PN_trn-doc.expfo-date      = today
                        buf_PN_trn-doc.need-expfo      = 0   /* чтоб можно было сделать +  */
                        buf_PN_trn-doc.need-incfo      = 0
                        buf_PN_trn-doc.need-incorexpfo = 0
                        .
                    end.
                  else do:
                  message vss-workfile vss-revision vss-description skip
                         "Ошибка  при изменении ПН" p-doc-code-pri skip
                          skip
                          error-status :get-message(1) skip
                          return-value skip
                          view-as alert-box error
                  .
                  undo, return error .
                  end.

   /* cоздадим партии */
  for each buf-sm_fin-gds-part no-lock where
           buf-sm_fin-gds-part.host-code    = par-host-code and
           buf-sm_fin-gds-part.fin-ob-code  = buf-sm_fin-ob.doc-code
           on error undo, return error :
           create new_fin-gds-part.
           BUFFER-COPY buf-sm_fin-gds-part to new_fin-gds-part
           assign
              new_fin-gds-part.fin-ob-code     = v-doc-code
              new_fin-gds-part.slt-base-orig  = -1 * buf-sm_fin-gds-part.slt-base-orig
              new_fin-gds-part.slt-base       = -1 * buf-sm_fin-gds-part.slt-base
              new_fin-gds-part.slt-contract-orig   = -1 * buf-sm_fin-gds-part.slt-contract-orig
              new_fin-gds-part.slt-contract        = -1 * buf-sm_fin-gds-part.slt-contract
              new_fin-gds-part.slt-rubl-orig  = -1 * buf-sm_fin-gds-part.slt-rubl-orig
              new_fin-gds-part.slt-rubl       = -1 * buf-sm_fin-gds-part.slt-rubl
              new_fin-gds-part.sum-base-orig  = -1 * buf-sm_fin-gds-part.sum-base-orig
              new_fin-gds-part.sum-base       = -1 * buf-sm_fin-gds-part.sum-base
              new_fin-gds-part.sum-contract-orig   = -1 * buf-sm_fin-gds-part.sum-contract-orig
              new_fin-gds-part.sum-contract        = -1 * buf-sm_fin-gds-part.sum-contract
              new_fin-gds-part.sum-rubl-orig  = -1 * buf-sm_fin-gds-part.sum-rubl-orig
              new_fin-gds-part.sum-rubl       = -1 * buf-sm_fin-gds-part.sum-rubl
              new_fin-gds-part.vat-base-orig  = -1 * buf-sm_fin-gds-part.vat-base-orig
              new_fin-gds-part.vat-base       = -1 * buf-sm_fin-gds-part.vat-base
              new_fin-gds-part.vat-contract-orig   = -1 * buf-sm_fin-gds-part.vat-contract-orig
              new_fin-gds-part.vat-contract        = -1 * buf-sm_fin-gds-part.vat-contract
              new_fin-gds-part.vat-rubl-orig  = -1 * buf-sm_fin-gds-part.vat-rubl-orig
              new_fin-gds-part.vat-rubl       = -1 * buf-sm_fin-gds-part.vat-rubl
           .
  end. /* for each */


  /* создадим налоги */

  for each buf-sm_fin-ob-tax no-lock where
           buf-sm_fin-ob-tax.host-code = par-host-code and
           buf-sm_fin-ob-tax.doc-code  = buf-sm_fin-ob.doc-code
           on error undo, return error :
           create new_fin-ob-tax.
           BUFFER-COPY buf-sm_fin-ob-tax to new_fin-ob-tax
           assign
              new_fin-ob-tax.doc-code = v-doc-code
              new_fin-ob-tax.sum-line-base-orig      = -1 *  buf-sm_fin-ob-tax.sum-line-base-orig
              new_fin-ob-tax.sum-line-base           = -1 *  buf-sm_fin-ob-tax.sum-line-base
              new_fin-ob-tax.sum-line-contr-orig     = -1 *  buf-sm_fin-ob-tax.sum-line-contr-orig
              new_fin-ob-tax.sum-line-contr          = -1 *  buf-sm_fin-ob-tax.sum-line-contr
              new_fin-ob-tax.sum-line-doc-orig       = -1 *  buf-sm_fin-ob-tax.sum-line-doc-orig
              new_fin-ob-tax.sum-line-doc            = -1 *  buf-sm_fin-ob-tax.sum-line-doc
              new_fin-ob-tax.sum-line-rubl-orig      = -1 *  buf-sm_fin-ob-tax.sum-line-rubl-orig
              new_fin-ob-tax.sum-line-rubl           = -1 *  buf-sm_fin-ob-tax.sum-line-rubl
              new_fin-ob-tax.sum-slt-line-base-orig  = -1 *  buf-sm_fin-ob-tax.sum-slt-line-base-orig
              new_fin-ob-tax.sum-slt-line-base       = -1 *  buf-sm_fin-ob-tax.sum-slt-line-base
              new_fin-ob-tax.sum-slt-line-contr-orig = -1 *  buf-sm_fin-ob-tax.sum-slt-line-contr-orig
              new_fin-ob-tax.sum-slt-line-contr      = -1 *  buf-sm_fin-ob-tax.sum-slt-line-contr
              new_fin-ob-tax.sum-slt-line-doc-orig   = -1 *  buf-sm_fin-ob-tax.sum-slt-line-doc-orig
              new_fin-ob-tax.sum-slt-line-doc        = -1 *  buf-sm_fin-ob-tax.sum-slt-line-doc
              new_fin-ob-tax.sum-slt-line-rubl-orig  = -1 *  buf-sm_fin-ob-tax.sum-slt-line-rubl-orig
              new_fin-ob-tax.sum-slt-line-rubl       = -1 *  buf-sm_fin-ob-tax.sum-slt-line-rubl
              new_fin-ob-tax.sum-vat-line-base-orig  = -1 *  buf-sm_fin-ob-tax.sum-vat-line-base-orig
              new_fin-ob-tax.sum-vat-line-base       = -1 *  buf-sm_fin-ob-tax.sum-vat-line-base
              new_fin-ob-tax.sum-vat-line-contr-orig = -1 *  buf-sm_fin-ob-tax.sum-vat-line-contr-orig
              new_fin-ob-tax.sum-vat-line-contr      = -1 *  buf-sm_fin-ob-tax.sum-vat-line-contr
              new_fin-ob-tax.sum-vat-line-doc-orig   = -1 *  buf-sm_fin-ob-tax.sum-vat-line-doc-orig
              new_fin-ob-tax.sum-vat-line-doc        = -1 *  buf-sm_fin-ob-tax.sum-vat-line-doc
              new_fin-ob-tax.sum-vat-line-rubl-orig  = -1 *  buf-sm_fin-ob-tax.sum-vat-line-rubl-orig
              new_fin-ob-tax.sum-vat-line-rubl       = -1 *  buf-sm_fin-ob-tax.sum-vat-line-rubl
           .
  end. /* for each */

  run update-fin-ob_obj (
        input buf-sm_fin-ob.doc-code ,
        input par-host-code
        )
    .

 end. /* do */
end procedure. /* make-fo-small */


procedure ver-prc :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-fo-code  like ub.fin-ob.doc-code no-undo .
define output parameter p-GT as logical no-undo .

define buffer bufv_fin-ob-before for fin-ob-before.
define buffer bufv_contract for contract.
define buffer buf_incom-trn-doc for trn-doc.

define variable v-message-text as character no-undo .
define variable v-proc-contr as decimal no-undo .
define variable v-sum-pn as decimal no-undo .
define variable v-sum-ras as decimal no-undo .

    for each bufv_fin-ob-before  exclusive-lock   where
             bufv_fin-ob-before.doc-code     =  p-fo-code and
             bufv_fin-ob-before.host-code    =  par-host-code
                break
                by bufv_fin-ob-before.doc-code
                on error undo, return error
                :
        /*-------------------------------------------------*/
        if first-of (bufv_fin-ob-before.doc-code) then do:
          find first bufv_contract no-lock where bufv_contract.contract-code = bufv_fin-ob-before.contract-code no-error .
          if available bufv_contract then v-proc-contr = bufv_contract.srok-opl .
                                    else do:
                                        v-proc-contr = 0 .
                                        v-message-text =  v-message-text + {&new-line}  + error-status :get-message(1) + " Вн.№ договора " + string(bufv_fin-ob-before.contract-code) .
                                    end.

          run sum-in-parts (
              input  bufv_fin-ob-before.trn-doc-code-orig ,
              input  bufv_fin-ob-before.contract-code ,
              output v-sum-pn
              ) .
          v-sum-ras = 0 .
        end.

        bufv_fin-ob-before.status_ = {&fin-gen} .
        v-sum-ras = v-sum-ras + bufv_fin-ob-before.sum-rubl .

        /*-------------------------------------------------*/
        if last-of (bufv_fin-ob-before.doc-code) then do:
              /* посчитаем скоколько это процентов */
              if ( 100 * v-sum-ras / v-sum-pn ) >=  v-proc-contr /* превышение процента ук в договоре */ then do:
                  p-GT = false  . /* не надо делать корректирующее ФО ! */
              end.
              else do:
                  p-GT = true  .
              end.
              /*message  v-sum-ras  v-sum-pn   skip
                       "%         " 100 * v-sum-ras / v-sum-pn  skip
                       "% contract" v-proc-contr  .
                       */
        end.

    end. /* for each */
 end. /* do */
end procedure. /* ver-prc */

procedure sum-in-parts :
 do
 on error undo, return error return-value
 :
define input parameter  p-doc-code as character no-undo .
define input parameter  p-contract-code as integer no-undo .
define output parameter p-sum-pn  as decimal init 0 no-undo .

define buffer bufi_parts for parts.
define buffer bufi_trn-doc for trn-doc.

define buffer bufi_c-parts for c-parts.
define buffer bufi_c-trn-doc for c-trn-doc.

find first bufi_trn-doc no-lock where bufi_trn-doc.doc-code = p-doc-code no-error .
if available bufi_trn-doc then do:
      for each bufi_parts no-lock where
              bufi_parts.contract-code = p-contract-code and
              bufi_parts.out-code      = bufi_trn-doc.doc-code and
              bufi_parts.obj-code      = bufi_trn-doc.obj-code and
              bufi_parts.obj-type      = bufi_trn-doc.obj-type and
              bufi_parts.host-code     = bufi_trn-doc.host-code
          on error undo, return error :
          p-sum-pn = p-sum-pn +  ( bufi_parts.fact-qnty * bufi_parts.price-rubl)  .
      end. /* for each */
end.
else do:
  find first bufi_c-trn-doc no-lock where bufi_c-trn-doc.doc-code = p-doc-code no-error .
      if available bufi_c-trn-doc then do:
          for each bufi_c-parts no-lock where
                    bufi_c-parts.contract-code = p-contract-code and
                    bufi_c-parts.out-code      = bufi_c-trn-doc.doc-code and
                    bufi_c-parts.obj-code      = bufi_c-trn-doc.obj-code and
                    bufi_c-parts.obj-type      = bufi_c-trn-doc.obj-type and
                    bufi_c-parts.host-code     = bufi_c-trn-doc.host-code
              on error undo, return error :
              p-sum-pn = p-sum-pn +  ( bufi_c-parts.fact-qnty * bufi_c-parts.price-rubl)  .

          end. /* for each */
    end.
end.

 end. /* do */
end procedure. /* sum-in-parts */

procedure make-s-fo-obj :
 do
 on error undo, return error return-value
 :
define input parameter v-sum-rubl as decimal no-undo .
define input parameter v-sum-base as decimal no-undo .
define input parameter v-sum-contract as decimal no-undo .
define input parameter p-obj-type as character no-undo  .
define input parameter p-obj-code as integer no-undo    .
define input parameter v-pc       as decimal   no-undo .

v-pc = if p-nalog = 1 then 0 else v-pc.


 define variable pfo as logical no-undo .
 pfo = false  .
{ str/gen-flpi.i }
/* найдем мин дату */
define variable min-date as date no-undo .
define variable max-date as date no-undo .
        for each tt-trn-code  where
            tt-trn-code.contract-code = buf_contract.contract-code  and
            tt-trn-code.host-code     = par-host-code and
            tt-trn-code.pc            = v-pc          and
            tt-trn-code.obj-type      = p-obj-type    and
            tt-trn-code.obj-code      = p-obj-code
            break by tt-trn-code.fact-date DESCENDING
            on error undo, return error
            :
            min-date = tt-trn-code.fact-date.
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
    input  "Корректирующее ФО "  ,
    output p-ri )
    no-error .

  /* if error-status :error then  return. */
  col-fo = col-fo + 1.
  /* col-contract = col-contract + 1 . */

  for each tt-trn-code  where
      tt-trn-code.contract-code = buf_contract.contract-code  and
      tt-trn-code.obj-type      = p-obj-type    and
      tt-trn-code.pc            = v-pc          and
      tt-trn-code.obj-code      = p-obj-code    and
      tt-trn-code.host-code     = par-host-code
      on error undo, return error :

      create buf_fin-ob-trn.
      assign
        buf_fin-ob-trn.doc-code       = p-doc-code
        buf_fin-ob-trn.host-code      = par-host-code
        buf_fin-ob-trn.sum-rubl       = tt-trn-code.sum-rubl
        buf_fin-ob-trn.trn-doc-code   = tt-trn-code.doc-code
        buf_fin-ob-trn.is-corr        = true
      .

      find first buf2_trn-doc  exclusive-lock  where buf2_trn-doc.doc-code = tt-trn-code.doc-code no-error .
      if available buf2_trn-doc then do:
        if lookup( buf_contract.usl-opl , {&o-postavka}  ) > 0 then do:
            assign
              buf2_trn-doc.cr-incfo   = true
              buf2_trn-doc.cr-incorexpfo = true
              buf2_trn-doc.incfo-date = today

            .
            if buf2_trn-doc.need-incfo = 2 then do:
              assign
                buf2_trn-doc.need-incfo      = 1
                buf2_trn-doc.need-expfo      = 0
                buf2_trn-doc.need-incorexpfo = 1
              .
            end.
        end.
        else do:
            assign
              buf2_trn-doc.cr-expfo   = true
              buf2_trn-doc.cr-incorexpfo = true
              buf2_trn-doc.expfo-date = today
            .
            if buf2_trn-doc.need-expfo = 2 then do:
              assign
                buf2_trn-doc.need-expfo      = 1
                buf2_trn-doc.need-incfo      = 0
                buf2_trn-doc.need-incorexpfo = 1
              .
            end.
        end.
       end.
       else do:
          message vss-workfile vss-revision vss-description skip
                 "Ошибка test " skip
                  skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error
          .
       end.
      /* создадим партии по фин обязательству */
       if p-nalog = 1 then
          run make-fin-parts (input p-doc-code, input 2) .
       else
          run make-fin-parts-VAT (input p-doc-code, input v-pc) .


  end. /* tt-trn-code */

  run make-tax (
        input p-doc-code ,
        input par-host-code
        )                .
  run update-fin-ob_obj (
        input p-doc-code ,
        input par-host-code
        )
    .

 end. /* do */
end procedure. /* make-s-fo */

procedure clc-price :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

for each tt-clcparts
    on error undo, return error :
    delete tt-clcparts .
end. /* for each */
BUFFER-COPY buf_parts to tt-clcparts .
run clcprtsl_calc-parts
(
  input recid(tt-clcparts) ,
  input varis-doc          ,
  input varis-cur          ,
  input varroad-tax        ,
  input varexcise          ,
  input varvat-pc          ,
  input varcons-vat-pc     ,
  input varslt-pc          ,
  input varbase-rate       ,
  input varbase-scale      ,
  input varr-b             ,
  input varcur-base        ,
  input varcurroad-tax     ,
  input varcurexcise       ,
  input varcurvat-pc       ,
  input varcurcons-vat-pc  ,
  input varcurslt-pc
  ) no-error
  .
  if error-status :error then  p-res = p-res + {&new-line} + error-status :get-message(1) + return-value .
     find first tt-allsum where tt-allsum.sum-type = {&sum-general} no-error .
  if error-status :error then  p-res = p-res + {&new-line} + error-status :get-message(1) .

 end. /* do */
end procedure. /* clc-price */

procedure clc-price-tmp :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

for each tt-clcparts
    on error undo, return error :
    delete tt-clcparts .
end. /* for each */
BUFFER-COPY temp-parts to tt-clcparts .
run clcprtsl_calc-parts
(
  input recid(tt-clcparts) ,
  input varis-doc          ,
  input varis-cur          ,
  input varroad-tax        ,
  input varexcise          ,
  input varvat-pc          ,
  input varcons-vat-pc     ,
  input varslt-pc          ,
  input varbase-rate       ,
  input varbase-scale      ,
  input varr-b             ,
  input varcur-base        ,
  input varcurroad-tax     ,
  input varcurexcise       ,
  input varcurvat-pc       ,
  input varcurcons-vat-pc  ,
  input varcurslt-pc
  ) no-error
  .
  if error-status :error then  p-res = p-res + {&new-line} + error-status :get-message(1) + return-value .
     find first tt-allsum where tt-allsum.sum-type = {&sum-general} no-error .
  if error-status :error then  p-res = p-res + {&new-line} + error-status :get-message(1) .

 end. /* do */
end procedure. /* clc-price */



procedure make-fin-parts :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-code as character no-undo .
define input parameter p-type as integer no-undo .
define variable col-part   as integer   no-undo .

/* создадим партии по фин обязательству */
  for each temp-parts no-lock  where
           temp-parts.contract-code = buf_contract.contract-code and
           ((p-type = 1) or
           ( p-type = 2 and temp-parts.out-code      = buf_fin-ob-trn.trn-doc-code))
           on error undo, return error :
                if not can-find (first buf_fin-gds-part no-lock where
                    buf_fin-gds-part.host-code   = temp-parts.host-code and
                    buf_fin-gds-part.fin-ob-code = p-doc-code           and
                    buf_fin-gds-part.obj-type    = temp-parts.obj-type  and
                    buf_fin-gds-part.obj-code    = temp-parts.obj-code  and
                    buf_fin-gds-part.gds-code    = temp-parts.gds-code  and
                    buf_fin-gds-part.in-code     = temp-parts.in-code   and
                    buf_fin-gds-part.part-code   = temp-parts.part-code and
                    buf_fin-gds-part.out-code    = temp-parts.out-code use-index pi )
                then do:

                    col-part = col-part + 1.
                    if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show( "Создано партий : " + string( col-part )) .

                      run clc-price-tmp .
                      create buf_fin-gds-part.
                      buffer-copy temp-parts to buf_fin-gds-part
                      assign
                        buf_fin-gds-part.fin-ob-code        = p-doc-code
                        buf_fin-gds-part.status_dop         = {&fin-gen}
                        buf_fin-gds-part.user-db-num        = g#db-num
                        buf_fin-gds-part.user-name          = g#userid
                        buf_fin-gds-part.doc-qnty           = temp-parts.qnty
                        buf_fin-gds-part.sum-rubl-orig      = tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc)
                        buf_fin-gds-part.sum-rubl           = tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc)
                        buf_fin-gds-part.sum-base-orig      = tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc)
                        buf_fin-gds-part.sum-base           = tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc)
                        buf_fin-gds-part.sum-contract-orig  = tt-allsum.sum-dsc-cli-acc
                        buf_fin-gds-part.sum-contract       = tt-allsum.sum-dsc-cli-acc
                        buf_fin-gds-part.other-rubl-orig    = tt-allsum.other-rubl-acc
                        buf_fin-gds-part.road-tax-rubl-orig = tt-allsum.road-tax-rubl-acc
                        buf_fin-gds-part.transport-rubl-orig= tt-allsum.transport-rubl-acc
                        buf_fin-gds-part.other-base-orig    = tt-allsum.other-base-acc
                        buf_fin-gds-part.road-tax-base-orig = tt-allsum.road-tax-base-acc
                        buf_fin-gds-part.transport-base-orig= tt-allsum.transport-base-acc
                        buf_fin-gds-part.other-contract-orig     = tt-allsum.other-cli-acc
                        buf_fin-gds-part.road-tax-contract-orig  = tt-allsum.road-tax-cli-acc
                        buf_fin-gds-part.transport-contract-orig = tt-allsum.transport-cli-acc
                        buf_fin-gds-part.vat-rubl-orig      = tt-allsum.vat-rubl-acc
                        buf_fin-gds-part.vat-rubl           = tt-allsum.vat-rubl-acc
                        buf_fin-gds-part.slt-rubl-orig      = tt-allsum.slt-rubl-acc
                        buf_fin-gds-part.slt-rubl           = tt-allsum.slt-rubl-acc
                        buf_fin-gds-part.vat-base-orig      = tt-allsum.vat-base-acc
                        buf_fin-gds-part.vat-base           = tt-allsum.vat-base-acc
                        buf_fin-gds-part.slt-base-orig      = tt-allsum.slt-base-acc
                        buf_fin-gds-part.slt-base           = tt-allsum.slt-base-acc
                        buf_fin-gds-part.vat-contract-orig  = tt-allsum.vat-cli-acc
                        buf_fin-gds-part.vat-contract       = tt-allsum.vat-cli-acc
                        buf_fin-gds-part.slt-contract-orig  = tt-allsum.slt-cli-acc
                        buf_fin-gds-part.slt-contract       = tt-allsum.slt-cli-acc
                      .
                end. /* buf_fin-gds-part.out-code */
            end.    /* temp-parts*/

 end. /* do */
end procedure. /* make-fin-parts */

procedure ver-type-purch :
do
on error undo, return error return-value
:
 define output parameter p-ok as logical   no-undo .

 p-ok = true .
  if buf_trn-doc.ext-doc-type   = {&TDEDT_Chg_Purch_Code} then do:
    p-ok = false   .
    if  buf_contract.contract-type = {&contr-resp-store} and
        buf_parts.purch-code       = {&bef-responsible-storage-code} then p-ok = true .
  end.

end.
end procedure. /* ver-type-purch */

procedure ver-purch-resp-store :
do
on error undo, return error return-value
:
 define output parameter p-ok as logical   no-undo .

 p-ok = true .
  if buf_trn-doc.ext-doc-type   <> {&TDEDT_Chg_Purch_Code} then do:
    if  buf_contract.contract-type = {&contr-resp-store} and
        buf_parts.purch-code      <> {&bef-responsible-storage-code}  then p-ok = false  .
  end.

end.
end procedure. /* ver-type-purch */


/* $Workfile$ e n d */

procedure make-fin-parts-VAT :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-code as character no-undo .
define input  parameter v-pc as decimal   no-undo .

if var-fin-calc <> {&fin-calc-obj}  then find first temp-obj-firm no-error .
define variable col-part   as integer   no-undo .

/* создадим партии по фин обязательству */
  for each temp-parts no-lock  where
           temp-parts.contract-code = buf_contract.contract-code and
           temp-parts.VAT-pc = v-pc and
           ( var-fin-calc <> {&fin-calc-obj}  or (
           temp-parts.obj-type = temp-obj-firm.obj-type  and
           temp-parts.obj-code = temp-obj-firm.obj-code ))
           on error undo, return error :
                if not can-find (first buf_fin-gds-part no-lock where
                    buf_fin-gds-part.host-code   = temp-parts.host-code and
                    buf_fin-gds-part.fin-ob-code = p-doc-code           and
                    buf_fin-gds-part.obj-type    = temp-parts.obj-type  and
                    buf_fin-gds-part.obj-code    = temp-parts.obj-code  and
                    buf_fin-gds-part.gds-code    = temp-parts.gds-code  and
                    buf_fin-gds-part.in-code     = temp-parts.in-code   and
                    buf_fin-gds-part.part-code   = temp-parts.part-code and
                    buf_fin-gds-part.out-code    = temp-parts.out-code use-index pi )
                then do:

                    col-part = col-part + 1.
                    if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show( "Создано партий : " + string( col-part )) .

                      run clc-price-tmp .
                      create buf_fin-gds-part.
                      buffer-copy temp-parts to buf_fin-gds-part
                      assign
                        buf_fin-gds-part.fin-ob-code        = p-doc-code
                        buf_fin-gds-part.status_dop         = {&fin-gen}
                        buf_fin-gds-part.user-db-num        = g#db-num
                        buf_fin-gds-part.user-name          = g#userid
                        buf_fin-gds-part.doc-qnty           = temp-parts.qnty
                        buf_fin-gds-part.sum-rubl-orig      = tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc)
                        buf_fin-gds-part.sum-rubl           = tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc)
                        buf_fin-gds-part.sum-base-orig      = tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc)
                        buf_fin-gds-part.sum-base           = tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc)
                        buf_fin-gds-part.sum-contract-orig  = tt-allsum.sum-dsc-cli-acc
                        buf_fin-gds-part.sum-contract       = tt-allsum.sum-dsc-cli-acc
                        buf_fin-gds-part.other-rubl-orig    = tt-allsum.other-rubl-acc
                        buf_fin-gds-part.road-tax-rubl-orig = tt-allsum.road-tax-rubl-acc
                        buf_fin-gds-part.transport-rubl-orig= tt-allsum.transport-rubl-acc
                        buf_fin-gds-part.other-base-orig    = tt-allsum.other-base-acc
                        buf_fin-gds-part.road-tax-base-orig = tt-allsum.road-tax-base-acc
                        buf_fin-gds-part.transport-base-orig= tt-allsum.transport-base-acc
                        buf_fin-gds-part.other-contract-orig     = tt-allsum.other-cli-acc
                        buf_fin-gds-part.road-tax-contract-orig  = tt-allsum.road-tax-cli-acc
                        buf_fin-gds-part.transport-contract-orig = tt-allsum.transport-cli-acc
                        buf_fin-gds-part.vat-rubl-orig      = tt-allsum.vat-rubl-acc
                        buf_fin-gds-part.vat-rubl           = tt-allsum.vat-rubl-acc
                        buf_fin-gds-part.slt-rubl-orig      = tt-allsum.slt-rubl-acc
                        buf_fin-gds-part.slt-rubl           = tt-allsum.slt-rubl-acc
                        buf_fin-gds-part.vat-base-orig      = tt-allsum.vat-base-acc
                        buf_fin-gds-part.vat-base           = tt-allsum.vat-base-acc
                        buf_fin-gds-part.slt-base-orig      = tt-allsum.slt-base-acc
                        buf_fin-gds-part.slt-base           = tt-allsum.slt-base-acc
                        buf_fin-gds-part.vat-contract-orig  = tt-allsum.vat-cli-acc
                        buf_fin-gds-part.vat-contract       = tt-allsum.vat-cli-acc
                        buf_fin-gds-part.slt-contract-orig  = tt-allsum.slt-cli-acc
                        buf_fin-gds-part.slt-contract       = tt-allsum.slt-cli-acc
                      .
                end. /* buf_fin-gds-part.out-code */
            end.    /* temp-parts*/



 end. /* do */
end procedure. /* make-fin-parts-VAT */