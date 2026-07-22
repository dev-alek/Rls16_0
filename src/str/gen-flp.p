block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gen-flp.p $
$Archive: str/gen-flp.p $

Процедура генерации Фин Об по заданным параметрам

Автор: Чернова Светлана Александровна
Дата создания: 18/12/03
Author: Svetlana Chernova
Creation date: 18/12/03


*/
define temp-table tt-trn-doc  no-undo like ub.trn-doc.

define input parameter parparentproc  as widget-handle no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter p-date-end     as date no-undo    .
define input parameter p-trn-doc      as integer no-undo . /* тип расчета по приходу или расходу */
define input parameter p-cons         as integer no-undo .
define input parameter p-nalog        as integer no-undo . /* если = 2 то на каждую ставку налога надо создавать ФО */
define input parameter table for tt-trn-doc .
define input-output parameter p-res as character no-undo .
define input  parameter p-type-date as integer   no-undo .
define input  parameter p-adm       as logical   no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gen-flp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/gen-flp.p $":U .
define variable vss-description as character no-undo init "процедура генерации Фин Об по заданным параметрам".

{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ str/crfinob.i  fin-ob }
{ str/libofarh.i }
{ str/fo-clos.i  }
{ str/clcprtsl.i }
{ gbl/getcntxt.i def }
{ str/trdcalib.i }
{ gbl/thbjattr.i }

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

define temp-table tt-trn-code no-undo
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

.
/* Список объектов фирмы */
define temp-table temp-obj-firm no-undo
  field obj-code      as integer
  field obj-type      as char
index pi is primary unique
obj-code
obj-type
.
define buffer buf_parts-attr for parts-attr.

define temp-table temp-parts no-undo like ub.parts
field gds-code     as integer
field income-in-code      like parts.in-code
index pi IS UNIQUE PRIMARY
  out-code
  gds-code
  in-code
  part-code
  .



define variable v-type     as character no-undo .
define variable is-trdcattr-oldsuppcntr as character no-undo .

define buffer old_fin-gds-part for ub.fin-gds-part  .
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

define buffer buf_trn-doc          for trn-doc.
define buffer buf_parts            for parts.
define buffer buf_contract         for contract.
define buffer buf_goods            for goods.
define buffer buf_fin-ob-trn       for fin-ob-trn.
define buffer buf_fin-gds-part     for fin-gds-part.
define buffer buf2_trn-doc         for trn-doc.

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

run waitfram-show in this-procedure ("Ждите...").

define variable var-fin-calc as integer no-undo .
find first sysconf no-lock where sysconf.host-code = par-host-code no-error .
var-fin-calc = sysconf.fin-calc   .


if p-trn-doc = 1 /* по приходу  */ then do:
    p-usl-opl =  {&o-postavka} .
   end.
   else do:
    p-usl-opl =  {&o-realiz}  .
   end.



run make-temp-obj-firm in this-procedure .
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

if p-trn-doc <> ?  then do:
        if p-trn-doc = 1 /* по приходу  */ then do:
           for each buf_trn-doc no-lock where
                buf_trn-doc.host-code  = par-host-code          and
                buf_trn-doc.need-incfo = 1                      and
              ( p-adm or
                buf_trn-doc.cr-incfo   = false )                 and
                lookup ( buf_trn-doc.ext-doc-type , v-type-trn-doc ) > 0 and
                buf_trn-doc.status_    = {&fact}                and
                buf_trn-doc.fact-date <= p-date-end
                on error undo, return error
                :
                run proc-body-corr-acc in this-procedure .
                run proc-body in this-procedure .
           end. /* trn-doc */
        end. /* по приходу  */

        if p-trn-doc = 2 /* по реализации */ then do:
           for each buf_trn-doc no-lock where
                buf_trn-doc.host-code  = par-host-code          and
                buf_trn-doc.need-expfo = 1                      and
                ( p-adm or buf_trn-doc.cr-expfo   = false  )    and
                lookup ( buf_trn-doc.ext-doc-type , v-type-trn-doc ) > 0 and
                buf_trn-doc.status_    = {&fact}                and
                buf_trn-doc.fact-date <= p-date-end
                on error undo, return error
                :
                run proc-body-corr-acc in this-procedure .
                run proc-body in this-procedure .
           end. /* trn-doc */
        end. /* по реализации  */
 end.
 else do: /* по списку накладных */
    p-usl-opl = {&o-postavka} + "," + {&o-realiz} .

    for each tt-trn-doc  no-lock  where
        lookup(tt-trn-doc.ext-doc-type , v-type-trn-doc) > 0
        and    tt-trn-doc.status_    = {&fact}
        break by tt-trn-doc.ext-doc-type
        on error undo, return error
        :
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = tt-trn-doc.doc-code no-error .
        if available buf_trn-doc then  do:
                run proc-body-corr-acc in this-procedure  .
                run proc-body in this-procedure .
        end.
    end. /* tt-trn-doc */
 end.




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
                                                      buf_contract.usl-opl       <> {&contr-pay-fact-out-prc}
                            break
                            by tt-fin-ob.contract-code
                            by tt-fin-ob.pc
                            on error undo, return error :

                            var-sum-rubl     = var-sum-rubl     + tt-fin-ob.sum-rubl.
                            var-sum-base     = var-sum-base     + tt-fin-ob.sum-base.
                            var-sum-contract = var-sum-contract + tt-fin-ob.sum-contract .

                            if last-of(tt-fin-ob.contract-code)  or (p-nalog = 2 and last-of(tt-fin-ob.pc)) then do:
                                col-contract = col-contract + 1 .
                                if ( col-contract  modulo temp1 = 0 ) and ( col-contract >= temp1 ) then run waitfram-show in this-procedure ( "Объединение по договорам : " + string( col-contract )) .
                                run make-s-fo-obj in this-procedure (
                                      input var-sum-rubl,
                                      input var-sum-base,
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
                                                buf_contract.host-code     = par-host-code           and
                                                buf_contract.usl-opl       <> {&contr-pay-fact-out-prc}
                    break
                       by tt-fin-ob.contract-code
                       by tt-fin-ob.pc
                    on error undo, return error :
                    var-sum-rubl = var-sum-rubl + tt-fin-ob.sum-rubl.
                    var-sum-base = var-sum-base + tt-fin-ob.sum-base.
                    var-sum-contract = var-sum-contract + tt-fin-ob.sum-contract.

                    if last-of(tt-fin-ob.contract-code) or (p-nalog = 2 and last-of(tt-fin-ob.pc)) then do:
                        col-contract = col-contract + 1 .
                        if ( col-contract  modulo temp1 = 0 ) and ( col-contract >= temp1 ) then run waitfram-show in this-procedure ( "Объединение по договорам : " + string( col-contract )) .
                        run make-s-fo in this-procedure ( input var-sum-rubl , input var-sum-base , input var-sum-contract , input tt-fin-ob.pc ) no-error .
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
run waitfram-hide in this-procedure .

if col-fo    < 0 then col-fo    = 0 .
if col-bfo   < 0 then col-bfo   = 0 .

p-res = p-res  + {&new-line}   +
       "Генерация завершена: " + cur-time-string()  + {&new-line} +
       "за период до " + string( p-date-end,"99/99/9999")  + {&new-line} +
       " Создано финансовых обязательств :" + string(col-fo) + {&new-line} +
       " Создано ПредФинанОбязательств   :" + string(col-bfo) + {&new-line} +  {&new-line} +
       "Просмотрено накладных            :" + string(col-trn)           + {&new-line} +
       "Просмотрено договоров            :" + string(col-contract)
       .
define variable p-text as character no-undo .
if not ( p-trn-doc <> ?  and p-trn-doc = 1 ) /* по PFO */ then do:
   run str/gen-bfl.p
    ( input parparentproc ,
      input par-host-code ,
      input no,
      output p-text
      ).

    p-res = p-res  + p-text .
 end.


return .

/*---------------*/

procedure proc-body :
 do
 on error undo, return error return-value
 :
/* ПО НАКЛАДНОЙ */


define variable sum-gds-code as decimal no-undo .
define buffer buf_minus-parts for parts.

define variable v-flag-po as logical no-undo .
define variable v-flag-ex as logical no-undo .


if buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price} then return.
define variable v-may-be as logical   no-undo .
{ str/doc-fogn.i
  "'trn'"
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
if p-adm then do:
    assign
      v-flag-po =  false
      v-flag-ex =  false
    .
end.


       col-trn = col-trn + 1 .

/* Определение знака для накапливания суммы */
define variable v-num-pl as integer no-undo .

v-num-pl = lookup( buf_trn-doc.ext-doc-type, v-type-trn-doc ) .
v-sign = integer (entry(v-num-pl, v-sign-list )).
if v-sign = ? or v-sign = 0 then v-sign = 1.
assign
    var-sum-rubl = 0
    var-sum-base = 0
    var-sum-contract = 0
    . /* если по каждому документу свое фин об */
if ( col-trn  modulo temp1 = 0 ) and ( col-trn >= temp1 ) then run waitfram-show in this-procedure ( "Обработано накладных : " + string( col-trn )) .
      run ver-parts-attr in this-procedure .

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
              and ( can-find (first old_fin-gds-part no-lock where
                                    old_fin-gds-part.obj-type  = buf_parts.obj-type  and
                                    old_fin-gds-part.obj-code  = buf_parts.obj-code  and
                                    old_fin-gds-part.gds-code  = buf_goods.gds-code  and
                                    old_fin-gds-part.in-code   = buf_parts.in-code   and
                                    old_fin-gds-part.part-code = buf_parts.part-code and
                                    old_fin-gds-part.doc-type  = ""                  and
                                    old_fin-gds-part.out-code  = buf_parts.out-code  )
                    = false ) /* на партию не найдено ФО по финпартиям */

              break
                    by buf_parts.contract-code
                    by buf_parts.vat-pc
                    by buf_parts-attr.income-in-code
                    on error undo, return error :
                   /* message buf_contract.usl-opl buf_trn-doc.ext-doc-type . */

          run ver-purch-resp-store in this-procedure ( output  v-ok ).
          if v-ok = true then do:

          run clc-price in this-procedure .

              /* обработка инвентаризации ------------------------------------------------------------------------------------*/
              if lookup ( buf_trn-doc.ext-doc-type , {&inv-fo-tdedt} ) > 0 then do:
                { str/tdat-val.i
                  buf_trn-doc.doc-code
                  {&trdcattr-oldsuppcntr}
                  is-trdcattr-oldsuppcntr
                  v-type
                  }
                  /* Документ пересортицы делается по тем же контрагентам и договорам */
                if  is-trdcattr-oldsuppcntr = "yes" then next .

                    if  /* если по realiz и  партии fact-qnty   - */
                        ( lookup(buf_contract.usl-opl , {&o-realiz} ) > 0 and
                          buf_parts.fact-qnty <= 0 and
                          v-flag-ex = false
                          )
                    then do:
                        if buf_trn-doc.ext-doc-type <> {&TDEDT_Peresort} then do:
                            if buf_contract.usl-opl = {&contr-pay-fact-out-prc}
                              then
                                  assign
                                    var-sum-rublb     = var-sum-rublb     + abs(tt-allsum.sum-dsc-rubl-acc  - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc))
                                    var-sum-contractb = var-sum-contractb + abs(tt-allsum.sum-dsc-cli-acc )
                                    var-sum-baseb     = var-sum-baseb     + abs(tt-allsum.sum-dsc-base-acc  - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc))
                                  .
                              else
                                  assign
                                          var-sum-rubl     = var-sum-rubl     + abs(tt-allsum.sum-dsc-rubl-acc  - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc))
                                          var-sum-contract = var-sum-contract + abs(tt-allsum.sum-dsc-cli-acc )
                                          var-sum-base     = var-sum-base     + abs(tt-allsum.sum-dsc-base-acc  - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc))
                                  .

                            create temp-parts.
                            BUFFER-COPY buf_parts to temp-parts
                            assign
                              temp-parts.cli-qnty       =  abs( buf_parts.cli-qnty  )
                              temp-parts.fact-qnty      =  abs( buf_parts.fact-qnty )
                              temp-parts.qnty           =  abs( buf_parts.qnty      )
                              temp-parts.gds-code       =  buf_goods.gds-code
                              temp-parts.income-in-code =  buf_parts-attr.income-in-code
                              var-income-in-code        =  buf_parts-attr.income-in-code
                            .
                    end.
                        else do: /* Пересортица  только по партиям списания (-) и только по расходным договорам */
                            if buf_contract.usl-opl = {&contr-pay-fact-out-prc}
                              then
                                  assign
                                    var-sum-rublb     = var-sum-rublb     + abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc))
                                    var-sum-contractb = var-sum-contractb + abs(tt-allsum.sum-dsc-cli-acc )
                                    var-sum-baseb     = var-sum-baseb     + abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc))
                                  .
                              else
                                  assign
                                    var-sum-rubl     = var-sum-rubl     +  abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )
                                    var-sum-contract = var-sum-contract +  abs(tt-allsum.sum-dsc-cli-acc )
                                    var-sum-base     = var-sum-base     +  abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) )
                                  .
                            create temp-parts .
                            BUFFER-COPY buf_parts to temp-parts
                            assign
                              temp-parts.cli-qnty       =   abs( buf_parts.cli-qnty  )
                              temp-parts.fact-qnty      =   abs( buf_parts.fact-qnty )
                              temp-parts.qnty           =   abs( buf_parts.qnty      )
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
                      if buf_contract.usl-opl = {&contr-pay-fact-out-prc}
                          then
                              assign
                                var-sum-rublb     = var-sum-rublb     + (-1) * abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc))
                                var-sum-contractb = var-sum-contractb + (-1) * abs(tt-allsum.sum-dsc-cli-acc )
                                var-sum-baseb     = var-sum-baseb     + (-1) * abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc))
                              .
                          else
                              assign
                                      var-sum-rubl     = var-sum-rubl     + (-1) * abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )
                                      var-sum-contract = var-sum-contract + (-1) * abs(tt-allsum.sum-dsc-cli-acc )
                                      var-sum-base     = var-sum-base     + (-1) * abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc) )
                              .
                        create temp-parts .
                        BUFFER-COPY buf_parts to temp-parts
                        assign
                          temp-parts.cli-qnty       =  (-1) * abs( buf_parts.cli-qnty  )
                          temp-parts.fact-qnty      =  (-1) * abs( buf_parts.fact-qnty )
                          temp-parts.qnty           =  (-1) * abs( buf_parts.qnty      )
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
                        run ver-type-purch in this-procedure ( output v-ok ).
                        if v-ok = true then do:
                            if buf_contract.usl-opl = {&contr-pay-fact-out-prc}
                                  then
                                      assign
                                        var-sum-rublb     = var-sum-rublb     + (v-sign) * abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc))
                                        var-sum-contractb = var-sum-contractb + (v-sign) * abs(tt-allsum.sum-dsc-cli-acc )
                                        var-sum-baseb     = var-sum-baseb     + (v-sign) * abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc))
                                      .

                                  else
                                      assign
                                              var-sum-rubl     = var-sum-rubl     + (v-sign) * abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc) )
                                              var-sum-contract = var-sum-contract + (v-sign) * abs(tt-allsum.sum-dsc-cli-acc )
                                              var-sum-base     = var-sum-base     + (v-sign) * abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc))
                                      .
                            create temp-parts.
                            BUFFER-COPY buf_parts to temp-parts
                            assign
                              temp-parts.cli-qnty       = v-sign * abs(buf_parts.cli-qnty)
                              temp-parts.fact-qnty      = v-sign * abs(buf_parts.fact-qnty)
                              temp-parts.qnty           = v-sign * abs(buf_parts.qnty)
                              temp-parts.gds-code       = buf_goods.gds-code
                              temp-parts.income-in-code = buf_parts-attr.income-in-code
                              var-income-in-code        = buf_parts-attr.income-in-code
                            .
                        end.
              end.
         end.
          /*-------------------------------------------------------------------------------------------------------------*/
            if last-of ( buf_parts-attr.income-in-code ) then do:
                  if buf_contract.usl-opl = {&contr-pay-fact-out-prc}  and
                     lookup ( buf_trn-doc.ext-doc-type , {&ex-fo-tdedt} + {&inv-fo-tdedt} ) > 0 /* для накладных расходных  */
                     then do:
                      /* проверим не создавали ли мы уже для этой прих накладной  предФинОб */
                            /* создание предфин обяз     1 накл. -> М пред.фин.об.  */
                            run make-bfo in this-procedure
                                         ( input var-sum-rublb ,
                                           input var-sum-baseb ,
                                           input var-sum-contractb
                                            ) no-error .
                            if error-status :error then
                            do:
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
                            run make-tt-fo in this-procedure
                                           ( input var-sum-rubl ,
                                             input var-sum-base ,
                                             input var-sum-contract ,
                                             input buf_parts.vat-pc
                                             ) no-error .
                            if error-status :error then do:
                               p-res = p-res + {&new-line} + error-status :get-message(1) .
                            end.
                          var-sum-rubl = 0 .
                          var-sum-base = 0 .
                          var-sum-contract = 0 .
                      end.
                      else do: /* Если нало по каждой накладной создавать ФинОб        1 накл. -> М фин.об.  */
                          run make-fo in this-procedure
                                      ( input var-sum-rubl ,
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
define buffer buf_minus-parts for parts.

define variable v-flag-po as logical no-undo .
define variable v-flag-ex as logical no-undo .


if buf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price} then return.

define variable v-may-be as logical   no-undo .
{ str/doc-fogn.i
  "'trn'"
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
if p-adm then do:
    assign
      v-flag-po =  false
      v-flag-ex =  false
    .
end.

 /* ПО НАКЛАДНОЙ */
       col-trn = col-trn + 1 .

var-sum-rubl = 0 .
var-sum-base = 0 .
var-sum-contract = 0 .
 /* если по каждому документу свое фин об */

      if ( col-trn  modulo temp1 = 0 ) and ( col-trn >= temp1 ) then run waitfram-show in this-procedure ( "Обработано накладных : " + string( col-trn )) .

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
                                               v-flag-po = false ,
             first buf_goods no-lock where
                        buf_goods.artic     = buf_parts.artic      and
                        buf_goods.prod-type = buf_parts.prod-type  and
                        buf_goods.prod-code = buf_parts.prod-code
              and ( can-find (first old_fin-gds-part no-lock where
                                    old_fin-gds-part.obj-type  = buf_parts.obj-type  and
                                    old_fin-gds-part.obj-code  = buf_parts.obj-code  and
                                    old_fin-gds-part.gds-code  = buf_goods.gds-code  and
                                    old_fin-gds-part.in-code   = buf_parts.in-code   and
                                    old_fin-gds-part.part-code = buf_parts.part-code and
                                    old_fin-gds-part.doc-type  = ""                  and
                                    old_fin-gds-part.out-code  = buf_parts.out-code  )
                    = false ) /* на партию не найдено ФО по финпартиям */

              break
                    by buf_parts.contract-code
                    by buf_parts.vat-pc
                    on error undo, return error  :

              run clc-price in this-procedure .

              find first buf_parts-attr no-lock where buf_parts-attr.in-code   = buf_parts.in-code   and
                                                 buf_parts-attr.part-code = buf_parts.part-code and
                                                 buf_parts-attr.gds-code  = buf_goods.gds-code .


                  assign
                          var-sum-rubl     = var-sum-rubl     + (-1) * abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc))
                          var-sum-contract = var-sum-contract + (-1) * abs(tt-allsum.sum-dsc-cli-acc )
                          var-sum-base     = var-sum-base     + (-1) * abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc))
                  .

                  create temp-parts.
                  BUFFER-COPY buf_parts to temp-parts
                  assign
                    temp-parts.cli-qnty       =  (-1) * abs( buf_parts.cli-qnty)
                    temp-parts.fact-qnty      =  (-1) * abs( buf_parts.fact-qnty)
                    temp-parts.qnty           =  (-1) * abs( buf_parts.qnty     )
                    temp-parts.gds-code       =  buf_goods.gds-code
                    temp-parts.income-in-code =  buf_parts-attr.income-in-code
                    var-income-in-code        =  buf_parts-attr.income-in-code
                  .

            if last-of(buf_parts.contract-code) or (p-nalog = 2 and last-of(buf_parts.vat-pc)) then do:

              run make-fo-corr-acc in this-procedure
                ( input var-sum-rubl ,
                  input var-sum-base ,
                  input var-sum-contract )
                  no-error .

              if error-status :error then p-res = p-res + {&new-line} + error-status :get-message(1) .
              var-sum-rubl      = 0 .
              var-sum-rublb     = 0 .
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
              and ( can-find (first old_fin-gds-part no-lock where
                                    old_fin-gds-part.obj-type  = buf_parts.obj-type  and
                                    old_fin-gds-part.obj-code  = buf_parts.obj-code  and
                                    old_fin-gds-part.gds-code  = buf_goods.gds-code  and
                                    old_fin-gds-part.in-code   = buf_parts.in-code   and
                                    old_fin-gds-part.part-code = buf_parts.part-code and
                                    old_fin-gds-part.doc-type  = ""                  and
                                    old_fin-gds-part.out-code  = buf_parts.out-code  )
                    = false ) /* на партию не найдено ФО по финпартиям */
              break
                    by buf_parts.contract-code
                    by buf_parts.vat-pc
                    on error undo, return error :
              run clc-price in this-procedure .
              find first buf_parts-attr no-lock where buf_parts-attr.in-code   = buf_parts.in-code   and
                                                 buf_parts-attr.part-code = buf_parts.part-code and
                                                 buf_parts-attr.gds-code  = buf_goods.gds-code .

              /* если по postavka и  партии fact-qnty   + */

                  assign
                          var-sum-rubl     = var-sum-rubl     +  abs(tt-allsum.sum-dsc-rubl-acc - ( tt-allsum.transport-rubl-acc +  tt-allsum.other-rubl-acc))
                          var-sum-contract = var-sum-contract +  abs(tt-allsum.sum-dsc-cli-acc )
                          var-sum-base     = var-sum-base     +  abs(tt-allsum.sum-dsc-base-acc - ( tt-allsum.transport-base-acc +  tt-allsum.other-base-acc))
                  .

                  create temp-parts.
                  BUFFER-COPY buf_parts to temp-parts
                  assign
                    temp-parts.cli-qnty       =  abs( buf_parts.cli-qnty  )
                    temp-parts.fact-qnty      =  abs( buf_parts.fact-qnty )
                    temp-parts.qnty           =  abs( buf_parts.qnty      )
                    temp-parts.gds-code       =  buf_goods.gds-code
                    temp-parts.income-in-code =  buf_parts-attr.income-in-code
                    var-income-in-code        =  buf_parts-attr.income-in-code
                  .

            if last-of(buf_parts.contract-code) or (p-nalog = 2 and last-of(buf_parts.vat-pc)) then do:
              run make-fo-corr-acc in this-procedure
              (  input var-sum-rubl ,
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
  run fin-ob-code in this-procedure ( input g#db-num , output p-doc-code) .
  run create-fin-liab in this-procedure (
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
        input  n-user-db-num-pay        ,
        input  n-user-name-fact         ,
        input  n-user-name-pay          ,
        input  n-in-type                ,
        input  n-sum-tax-base           ,
        input  n-sum-tax-doc            ,
        input  n-sum-tax-rubl           ,
        input  n-sum-tax-contract       ,
        input  ""                       ,
        output p-ri )
        no-error .
        /* if error-status :error then  return. */

        define variable v-vv as character no-undo .

        col-fo = col-fo + 1.
        col-contract = col-contract + 1 .
        find first  buf_fin-ob-trn exclusive-lock where
              buf_fin-ob-trn.doc-code       = p-doc-code  and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = tt-trn-code.doc-code  no-error .
              if not available  buf_fin-ob-trn then  do:
                  create buf_fin-ob-trn.
                  assign
                    buf_fin-ob-trn.doc-code       = p-doc-code
                    buf_fin-ob-trn.host-code      = par-host-code
                    buf_fin-ob-trn.sum-rubl       = n-sum-rubl
                    buf_fin-ob-trn.trn-doc-code   =  buf_trn-doc.doc-code
                  .
                  v-vv = buf_fin-ob-trn.trn-doc-code .
                  release buf_fin-ob-trn no-error .
              end.
             find first buf2_trn-doc  exclusive-lock  where buf2_trn-doc.doc-code = v-vv no-error .
                if available buf2_trn-doc then do:
                   if lookup( buf_contract.usl-opl , {&o-postavka}  ) > 0 then do:
                    assign
                      buf2_trn-doc.cr-incfo        = true
                      buf2_trn-doc.cr-incorexpfo   = true
                      buf2_trn-doc.incfo-date      = today
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
                          buf2_trn-doc.cr-expfo      = true
                          buf2_trn-doc.cr-incorexpfo = true
                          buf2_trn-doc.expfo-date    = today
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
                          "№ ФО :" p-doc-code skip
                          "№ фирмы :" par-host-code skip
                          skip
                          error-status :get-message(1) skip
                          return-value skip
                          view-as alert-box error
                  .

   run make-fin-parts in this-procedure ( input p-doc-code , input 1 ) .

  for each temp-parts where
           temp-parts.contract-code = buf_contract.contract-code
           :
            delete temp-parts .
  end.

  /* создадим налоги по партиям */
  run make-tax in this-procedure (
        input p-doc-code ,
        input par-host-code
        )                .

  run update-fin-ob_obj in this-procedure (
        input p-doc-code ,
        input par-host-code
        )
    .


 /* если есть в договоре условие то закроем на факт */
 run close-fo-fact in this-procedure ( input par-host-code, input p-doc-code ) no-error   .
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
        if  min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) <= n-doc-date
            then n-pay-date = n-doc-date.
            else n-pay-date = min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) .
  run fin-ob-code in this-procedure (input g#db-num , output p-doc-code) .
  run create-fin-liab in this-procedure (
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
              buf_fin-ob-trn.trn-doc-code   = tt-trn-code.doc-code
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
       if p-nalog = 1 then
          run make-fin-parts in this-procedure ( input p-doc-code, input 2) .
       else
          run make-fin-parts-VAT in this-procedure ( input p-doc-code, input v-pc) .
  end. /* tt-trn-code */

  run make-tax in this-procedure (
        input p-doc-code ,
        input par-host-code
        )                .

  run update-fin-ob_obj in this-procedure (
        input p-doc-code ,
        input par-host-code
        )
    .

 run close-fo-fact in this-procedure ( input par-host-code, input p-doc-code ) no-error   .
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


procedure make-bfo :
 do
 on error undo, return error return-value
 :
define input parameter v-sum-rubl as decimal no-undo .
define input parameter v-sum-base as decimal no-undo .
define input parameter v-sum-contract as decimal no-undo .

define buffer t-buf_fin-ob-trn for fin-ob-trn .
define buffer t-buf_fin-ob     for fin-ob .
define buffer buf4_trn-doc for trn-doc.
define variable v-n as character no-undo .
define variable v-fo-prih as logical no-undo .
v-fo-prih = false .
/* Если по ПН уже создано ФО по ПФО */

for each t-buf_fin-ob-trn no-lock where
         t-buf_fin-ob-trn.trn-doc-code = var-income-in-code
         :
         v-n = t-buf_fin-ob-trn.doc-code  .

         if  can-find ( first t-buf_fin-ob no-lock where
                              t-buf_fin-ob.doc-code      = v-n   and
                              t-buf_fin-ob.contract-code = buf_contract.contract-code
                              )  /* Созданное ФО и по тому же договору */
          then do:

          find first buf4_trn-doc  exclusive-lock  where buf4_trn-doc.doc-code = buf_trn-doc.doc-code no-error .
              if available buf4_trn-doc then do:
                  p-res = p-res + ">> Создание ПФО - На накладную " + string(var-income-in-code) +
                                 " уже создано ФО " + string(v-n)  + {&new-line}
                                 .
                  v-fo-prih = true  .

              end.
          end.

 end.



define buffer buf3_trn-doc for trn-doc.

define variable pfo as logical no-undo .
define variable var-status as character no-undo .
define variable v-fo-doc-code as character no-undo .
define variable  v-fact-date            as date    no-undo . /* фактическая дата закрытия документа  */
define variable  v-fact-time            as integer no-undo . /* фактическое время закрытия документа */
define variable  v-fact-num             as integer no-undo . /* фактический номер закрытия документа */
define variable  v-shift-date           as date    no-undo . /* дата начала смены для документа      */
define variable  v-shift-num            as integer no-undo . /* порядок смены для документа          */
define variable  v-shift-on             as logical no-undo . /* на объекте включены смены            */
define variable  v-fact-order           as decimal no-undo . /* порядковый номер закрытия документа  */
define variable  v-shift-end-fact-order as decimal no-undo . /* номер конца смены                    */
define variable  v-day-end-fact-order   as decimal no-undo . /* номер конца дня                      */

 pfo = true .
 { str/gen-flpi.i }

 if v-fo-prih = true  then do:
  assign
    var-status          = {&fin-gen}
    v-fo-doc-code       = v-n
    .

 end.
 else do:
   assign
    var-status = {&fin-gen}
    v-fo-doc-code = ""
   .
 end.

      run fin-ob-code in this-procedure ( input g#db-num , output p-doc-code) .
      run create-fin-ob-before in this-procedure (
        input yes                    ,
        input  p-doc-code            ,
        input  v-fo-doc-code         ,
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
        input  var-status            ,
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
        input "" ,
        output p-ri )
        no-error .

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
             run make-fin-parts in this-procedure ( input p-doc-code, input 2 ) .

              for each temp-parts  where temp-parts.contract-code = buf_contract.contract-code
                                     and temp-parts.out-code      = buf_fin-ob-trn.trn-doc-code :
                  delete temp-parts .
              end.
              /* создадим налоги по партиям */
              run make-tax-before in this-procedure (
                    input p-doc-code ,
                    input par-host-code
                    )                .

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




procedure make-fo-corr-acc :
 do
 on error undo, return error return-value
 :
/* Коррекция учетной цены */

define input parameter v-sum-rubl as decimal no-undo .
define input parameter v-sum-base as decimal no-undo .
define input parameter v-sum-contract as decimal no-undo .
 define variable pfo as logical no-undo .
 pfo = false  .

{ str/gen-flpi.i }
  if  buf_trn-doc.fact-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) <= n-doc-date
      then n-pay-date = n-doc-date .
      else n-pay-date = buf_trn-doc.fact-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) .

      run fin-ob-code in this-procedure ( input g#db-num , output p-doc-code) .
      run create-fin-liab in this-procedure (
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
        input  n-user-db-num-pay        ,
        input  n-user-name-fact         ,
        input  n-user-name-pay          ,
        input  n-in-type                ,
        input  n-sum-tax-base           ,
        input  n-sum-tax-doc            ,
        input  n-sum-tax-rubl           ,
        input  n-sum-tax-contract       ,
        input "" ,
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
              buf_fin-ob-trn.sum-rubl       = n-sum-rubl
              buf_fin-ob-trn.sum-tax-rubl   = n-sum-tax-rubl
              buf_fin-ob-trn.trn-doc-code   = buf_trn-doc.doc-code

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
        run make-fin-parts in this-procedure ( input p-doc-code , input 1 ) .
        for each temp-parts  where temp-parts.contract-code = buf_contract.contract-code  : delete temp-parts . end.
        /* создадим налоги по партиям */
        run make-tax in this-procedure (
              input p-doc-code ,
              input par-host-code
              )                .

        run update-fin-ob_obj in this-procedure (
              input p-doc-code ,
              input par-host-code
              )
          .

 run close-fo-fact in this-procedure ( input par-host-code, input p-doc-code ) no-error   .
 if error-status :error then
    p-res = p-res + {&new-line} +  " Ошибка при закрытии на факт ФО " + return-value  + error-status :get-message(1) .
 end. /* do */
end procedure. /* make-fo-corr-acc */



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
      run proc-close-one-fin-ob in this-procedure (recid(buf_fact-fin-ob)) no-error .
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
                    "ЭТО ПРОЦЕДУРА КОЧЕТКОВА "
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
{ str/gen-flpi.i }
/* найдем мин дату */
define variable min-date as date no-undo .
define variable max-date as date no-undo .


        for each tt-trn-code  where
            tt-trn-code.contract-code = buf_contract.contract-code  and
            tt-trn-code.pc            = v-pc          and
            tt-trn-code.host-code     = par-host-code and
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


  run fin-ob-code in this-procedure ( input g#db-num , output p-doc-code) .
  run create-fin-liab in this-procedure (
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

  for each tt-trn-code  where
      tt-trn-code.contract-code = buf_contract.contract-code  and
      tt-trn-code.obj-type      = p-obj-type    and
      tt-trn-code.obj-code      = p-obj-code    and
      tt-trn-code.pc            = v-pc                      and
      tt-trn-code.host-code     = par-host-code
      on error undo, return error :

        find first  buf_fin-ob-trn no-lock  where
              buf_fin-ob-trn.doc-code       = p-doc-code  and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = tt-trn-code.doc-code
              no-error .
              if not available  buf_fin-ob-trn then  do:

            create buf_fin-ob-trn.
            assign
              buf_fin-ob-trn.doc-code       = p-doc-code
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.sum-tax-rubl   = n-sum-tax-rubl
              buf_fin-ob-trn.sum-rubl       = tt-trn-code.sum-rubl
              buf_fin-ob-trn.trn-doc-code   = tt-trn-code.doc-code


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
          run make-fin-parts in this-procedure (input p-doc-code, input 2) .
       else
          run make-fin-parts-VAT in this-procedure (input p-doc-code, input v-pc) .

  end. /* tt-trn-code */

  run make-tax in this-procedure (
        input p-doc-code ,
        input par-host-code
        )                .

  run update-fin-ob_obj in this-procedure (
        input p-doc-code ,
        input par-host-code
        )
    .

 run close-fo-fact in this-procedure ( input par-host-code, input p-doc-code ) no-error   .
 if error-status :error then
    p-res = p-res + {&new-line} + " Ошибка процедуры закрытия на ФАКТ совокупного ФО "  + error-status :get-message(1)  + return-value .

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
run clcprtsl_calc-parts in this-procedure
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
run clcprtsl_calc-parts in this-procedure
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
           ((p-type  = 1 ) or
           ( p-type  = 2 and temp-parts.out-code      = buf_fin-ob-trn.trn-doc-code))
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
                    if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show in this-procedure ( "Создано партий : " + string( col-part )) .

                      run clc-price-tmp in this-procedure .
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
    p-ok = false  .
    if  buf_contract.contract-type = {&contr-resp-store} and
        buf_parts.purch-code       = {&bef-responsible-storage-code}  then p-ok = true .
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
           temp-parts.VAT-pc = v-pc  and
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
                    if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show in this-procedure ( "Создано партий : " + string( col-part )) .

                      run clc-price-tmp in this-procedure .
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

procedure ver-parts-attr :

  do
  on error undo, return error return-value
  :
      for each buf_parts no-lock where buf_parts.out-code  = buf_trn-doc.doc-code   and
                                       buf_parts.host-code = buf_trn-doc.host-code  and
                                       buf_parts.obj-type  = buf_trn-doc.obj-type   and
                                       buf_parts.obj-code  = buf_trn-doc.obj-code ,
              first buf_goods no-lock where buf_goods.artic     = buf_parts.artic      and
                                            buf_goods.prod-type = buf_parts.prod-type  and
                                            buf_goods.prod-code = buf_parts.prod-code ,
              first buf_contract no-lock where buf_contract.contract-code = buf_parts.contract-code and
                                               buf_contract.host-code     = buf_parts.host-code     and
                                               lookup(buf_contract.usl-opl , p-usl-opl ) > 0  and
                          /* проверка на соответствеи расширенного типа партии и условия договора */
                          /* если это по поставке */
                            ((
                            lookup ( buf_contract.usl-opl , {&o-postavka} ) > 0 and
                            lookup ( buf_trn-doc.ext-doc-type , {&in-fo-tdedt} ) > 0
                            ) OR
                          /* если это по реализации */
                            ( lookup ( buf_contract.usl-opl , {&o-realiz} ) > 0   and
                              lookup ( buf_trn-doc.ext-doc-type , {&ex-fo-tdedt} + {&inv-fo-tdedt} ) > 0
                              ) )
     :
        find first buf_parts-attr no-lock where buf_parts-attr.in-code   = buf_parts.in-code   and
                                              buf_parts-attr.part-code = buf_parts.part-code and
                                              buf_parts-attr.gds-code  = buf_goods.gds-code no-error .
               if not available buf_parts-attr then
                  p-res = p-res + {&new-line}   + " У документа " +  buf_trn-doc.doc-code + "Нет атрибутов партий !!! Используйте утилиту восстановления" .

  end.
  end.

end procedure. /* ver-parts-attr */