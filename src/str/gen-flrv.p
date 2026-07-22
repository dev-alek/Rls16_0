block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gen-flrv.p $
$Archive: str/gen-flrv.p $

Процедура генерации Фин Об по заданным параметрам по поставкам

Автор: Чернова Светлана Александровна
Дата создания: 11/02/05
Author: Svetlana Chernova
Creation date: 11/02/05

*/
define temp-table tt-trn-doc  no-undo like ub.ord-doc-rcv.

define input parameter parparentproc  as widget-handle no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter p-date-end     as date no-undo    .
define input parameter p-trn-doc      as integer no-undo . /* тип расчета по приходу или расходу */
define input parameter p-cons         as integer no-undo . /* Совокупная или  раздельно */
define input parameter p-nalog        as integer no-undo . /* если = 2 то на каждую ставку налога надо создавать ФО */
define input parameter table for tt-trn-doc .
define input-output parameter p-res as character no-undo .
define input  parameter p-type-date as integer   no-undo .
define input  parameter p-adm as logical   no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gen-flrv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/gen-flrv.p $":U .
define variable vss-description as character no-undo init "Процедура генерации Фин Об по заданным параметрам по поставкам".
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
{ gbl/thbjattr.i }

/* message " по поставкам "  . */
define variable p-fo-type as character no-undo . /* Тип ФО: приходное или расходное  */
p-fo-type = {&expense} .
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

.
/* Список объектов фирмы */
define temp-table temp-obj-firm no-undo
  field obj-code      as integer
  field obj-type      as char
index pi is primary unique
obj-code
obj-type
.

define temp-table temp-ord-line-rcv no-undo like ub.ord-line-rcv
field out-code as character
field part-code as character
field contract-code as integer
field fact-date as date
field obj-type as character
field obj-code as int
index pi IS UNIQUE PRIMARY
  out-code
  gds-code
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
define buffer buf_ord-doc-rcv          for ub.ord-doc-rcv.
define buffer buf_ord-line-rcv         for ub.ord-line-rcv.
define buffer buf_contract         for ub.contract.
define buffer buf_goods            for ub.goods.
define buffer buf_fin-ob-trn       for ub.fin-ob-trn.
define buffer buf_fin-gds-part     for ub.fin-gds-part.
define buffer buf2_ord-doc-rcv         for ub.ord-doc-rcv.

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

run waitfram-show("Ждите...").

define variable var-fin-calc as integer no-undo .
find first sysconf no-lock where sysconf.host-code = par-host-code no-error .
var-fin-calc = sysconf.fin-calc   .


run make-temp-obj-firm.
/**/
assign
    v-type-trn-doc = "rcv"
    v-shot-type-trn-doc = {&ord-rcv}
    v-sign-list    = "1"
.
/* разные типы вызова */



if p-trn-doc <> ?  then do:
    for each temp-obj-firm on error undo, return error :
           for each buf_ord-doc-rcv no-lock where
                    buf_ord-doc-rcv.obj-type   = temp-obj-firm.obj-type and
                    buf_ord-doc-rcv.obj-code   = temp-obj-firm.obj-code and
                    buf_ord-doc-rcv.status_    = {&fact}                and
                    buf_ord-doc-rcv.host-code  = par-host-code          and
                    buf_ord-doc-rcv.need-fo = 1                         and
                    (p-adm or
                    buf_ord-doc-rcv.cr-fo   = false )                   and
                    buf_ord-doc-rcv.fact-date <= p-date-end
                    on error undo, return error  :

                run proc-body .

           end. /* trn-doc */
    end. /* temp-obj-firm */
 end.
 else do: /* по списку накладных */
    for each tt-trn-doc  no-lock
        on error undo, return error
        :

        find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.rcv-code = tt-trn-doc.rcv-code no-error .
        if available buf_ord-doc-rcv then  do:
                /* проверим не создавали ли мы уже для этой накладной  ФинОб */
                if can-find ( first buf_fin-ob-trn no-lock where
                                    buf_fin-ob-trn.doc-type = "rcv"  and
                                    buf_fin-ob-trn.trn-doc-code = buf_ord-doc-rcv.rcv-code
                                     ) then  do:
                                      next.
                                    end.
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
                                                       lookup( buf_contract.usl-opl ,  {&contr-pay-rcv} + "," + {&contr-pay-rcv-delay} )   > 0
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
                                                buf_contract.host-code    = par-host-code           and
                                                lookup( buf_contract.usl-opl ,  {&contr-pay-rcv} + "," + {&contr-pay-rcv-delay} )   > 0
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
       "Просмотрено поставок             :" + string(col-trn)           + {&new-line} +
       "Просмотрено договоров            :" + string(col-contract)
       .

return .

/*---------------*/

procedure proc-body :
 do
 on error undo, return error return-value
 :
/* ПО ЗАКАЗУ */
define buffer buf1_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf1_ord-doc for ub.ord-doc  .

define variable sum-gds-code as decimal no-undo .

define variable v-flag-po as logical no-undo .
define variable v-may-be as logical   no-undo .
{ str/doc-fogn.i
  "'rcv'"
  {&expense}
  buf_ord-doc-rcv.rcv-code
  g#db-num
  v-may-be
}
if v-may-be = false then do:
   p-res = p-res + {&new-line} + substitute("По поставке &1 нельзя создавать ФО в этой БД" , buf_ord-doc-rcv.rcv-code ) .
   return .
end.

assign
  v-flag-po = ( if buf_ord-doc-rcv.cr-fo = true then true else false )
.
if p-adm then v-flag-po = false .

 col-trn = col-trn + 1 .

assign
    var-sum-rubl = 0
    var-sum-base = 0
    var-sum-contract = 0
    .
    /* если по каждому документу свое фин об */
if ( col-trn  modulo temp1 = 0 ) and ( col-trn >= temp1 ) then run waitfram-show( "Обработано заказов : " + string( col-trn )) .


      for each buf_ord-line-rcv no-lock where buf_ord-line-rcv.RCV-CODE  = buf_ord-doc-rcv.rcv-code  ,
              first buf1_ord-doc     no-lock where buf1_ord-doc.doc-code  = buf_ord-line-rcv.doc-CODE ,
              first buf1_ord-doc-rcv no-lock where buf1_ord-doc-rcv.rcv-code  = buf_ord-line-rcv.RCV-CODE ,
              first buf_goods no-lock where buf_goods.artic     = buf_ord-line-rcv.artic      and
                                            buf_goods.prod-type = buf_ord-line-rcv.prod-type  and
                                            buf_goods.prod-code = buf_ord-line-rcv.prod-code ,
              first buf_contract no-lock where buf_contract.contract-code = buf1_ord-doc.contract-code and
                                               buf_contract.host-code     = buf1_ord-doc.host-code    and
                                               lookup( buf_contract.usl-opl ,  {&contr-pay-rcv} + "," + {&contr-pay-rcv-delay} )   > 0
              break
                    by buf1_ord-doc-rcv.contract-code
                    by buf_ord-line-rcv.vat-pc
                    on error undo, return error
                    :
                  assign
                    var-sum-rubl     = var-sum-rubl     +  abs (buf_ord-line-rcv.sum-rubl - ( buf_ord-line-rcv.sum-other-rubl + buf_ord-line-rcv.sum-transport-rubl))
                    var-sum-contract = var-sum-contract +  abs (buf_ord-line-rcv.sum-cli  )
                    var-sum-base     = var-sum-base     +  abs (buf_ord-line-rcv.sum-base - ( buf_ord-line-rcv.sum-other-base + buf_ord-line-rcv.sum-transport-base))
                  .

                  create temp-ord-line-rcv.
                  BUFFER-COPY buf_ord-line-rcv to temp-ord-line-rcv
                  assign
                    temp-ord-line-rcv.fact-date      = buf1_ord-doc-rcv.fact-date
                    temp-ord-line-rcv.contract-code  = buf1_ord-doc.contract-code
                    temp-ord-line-rcv.obj-type       = buf1_ord-doc-rcv.obj-type
                    temp-ord-line-rcv.obj-code       = buf1_ord-doc-rcv.obj-code
                    temp-ord-line-rcv.out-code       = buf_ord-line-rcv.RCV-CODE
                    temp-ord-line-rcv.cli-qnty       = buf_ord-line-rcv.cli-qnty
                    temp-ord-line-rcv.qnty           = buf_ord-line-rcv.qnty
                    temp-ord-line-rcv.gds-code       = buf_goods.gds-code
                  .
          /*-------------------------------------------------------------------------------------------------------------*/
            if last-of(buf1_ord-doc-rcv.contract-code) or (p-nalog = 2 and last-of(buf_ord-line-rcv.vat-pc)) then do:
                if p-cons = 1 then do: /* Если нало по всем накладным одного договора       M накл. -> 1 фин.об.  */
                      run make-tt-fo ( input var-sum-rubl ,
                                        input var-sum-base ,
                                        input var-sum-contract ,
                                        input buf_ord-line-rcv.vat-pc
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
                        p-res = p-res + {&new-line} + error-status :get-message(1) .
                    end.
                end.
                var-sum-rubl = 0 .
                var-sum-base = 0 .
                var-sum-contract = 0 .
            end. /* if last-of */
      end. /* ord-line-rcv */
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
{ str/gen-flpo.i  ord-doc-rcv }
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
                    buf_fin-ob-trn.doc-type       = "rcv"  and
                    buf_fin-ob-trn.trn-doc-code   = tt-ord-code.doc-code
                    no-error .

        if not available  buf_fin-ob-trn then  do :
            create buf_fin-ob-trn.
            assign
              buf_fin-ob-trn.doc-code       = p-doc-code
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.doc-type       = "rcv"
              buf_fin-ob-trn.sum-rubl       = n-sum-rubl
              buf_fin-ob-trn.trn-doc-code   = buf_ord-doc-rcv.rcv-code
            .
        end.

        find first buf2_ord-doc-rcv  exclusive-lock  where buf2_ord-doc-rcv.rcv-code = buf_ord-doc-rcv.rcv-code no-error .
        if available buf2_ord-doc-rcv then do:
            assign
              buf2_ord-doc-rcv.cr-fo        = true
              buf2_ord-doc-rcv.fo-date      = today
            .
        end.
        /*
  for each temp-ord-line-rcv
           :
      message  temp-ord-line-rcv.contract-code skip
             "gds-code"  temp-ord-line-rcv.gds-code       skip
             "artic   "  temp-ord-line-rcv.artic          skip
             "vat-pc  "  temp-ord-line-rcv.vat-pc         skip
             "in-code "  temp-ord-line-rcv.in-code        skip
             "out-code"  temp-ord-line-rcv.out-code       skip

               .
  end.    */
/*+++++++*/


  run make-fin-ord-line-rcv ( input p-doc-code , input 1  , buf2_ord-doc-rcv.base-rate , buf2_ord-doc-rcv.base-scale) .

  for each temp-ord-line-rcv where
           temp-ord-line-rcv.contract-code = buf_contract.contract-code
           :
      delete temp-ord-line-rcv .
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

{ str/gen-flpo.i ord-doc-rcv }
  v-k = v-k + 1    .

   create tt-fin-ob .
   assign
    tt-fin-ob.contract-code = buf_contract.contract-code
    tt-fin-ob.host-code     = par-host-code
    tt-fin-ob.sum-rubl      = v-sum-rubl
    tt-fin-ob.sum-base      = v-sum-base
    tt-fin-ob.sum-contract  = v-sum-contract
    tt-fin-ob.doc-code      = string(v-k)
    tt-fin-ob.obj-code      = buf_ord-doc-rcv.obj-code
    tt-fin-ob.obj-type      = buf_ord-doc-rcv.obj-type
    tt-fin-ob.pc            =  v-pc
  .
      if not can-find ( first tt-ord-code  where
            tt-ord-code.contract-code = buf_contract.contract-code and
            tt-ord-code.host-code     = par-host-code              and
            tt-ord-code.pc            = v-pc                      and
            tt-ord-code.doc-code      = buf_ord-doc-rcv.rcv-code       ) then do:
            create tt-ord-code.
            assign
                  tt-ord-code.contract-code = buf_contract.contract-code
                  tt-ord-code.host-code     = par-host-code
                  tt-ord-code.doc-code      = buf_ord-doc-rcv.rcv-code
                  tt-ord-code.fact-date     = buf_ord-doc-rcv.fact-date
                  tt-ord-code.sum-rubl      = v-sum-rubl
                  tt-ord-code.sum-base      = v-sum-base
                  tt-ord-code.sum-contract  = v-sum-contract
                  tt-ord-code.pc            = v-pc
                  tt-ord-code.obj-code      = buf_ord-doc-rcv.obj-code
                  tt-ord-code.obj-type      = buf_ord-doc-rcv.obj-type

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
{ str/gen-flpo.i ord-doc-rcv }
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
              buf_fin-ob-trn.doc-type       = "rcv"        and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = tt-ord-code.doc-code  no-error .
              if not available  buf_fin-ob-trn then  do:
                  create buf_fin-ob-trn.
                  assign
                    buf_fin-ob-trn.doc-code       = p-doc-code
                    buf_fin-ob-trn.host-code      = par-host-code
                    buf_fin-ob-trn.doc-type       = "rcv"
                    buf_fin-ob-trn.sum-rubl       = tt-ord-code.sum-rubl
                    buf_fin-ob-trn.trn-doc-code   = tt-ord-code.doc-code
                  .
              end.


      find first buf2_ord-doc-rcv  exclusive-lock  where buf2_ord-doc-rcv.rcv-code = tt-ord-code.doc-code no-error .
      if available buf2_ord-doc-rcv then do:
            assign
              buf2_ord-doc-rcv.cr-fo   = true
              buf2_ord-doc-rcv.fo-date = today
            .
       end.
       if p-nalog = 1 then
          run make-fin-ord-line-rcv ( input p-doc-code, input 2  , buf2_ord-doc-rcv.base-rate , buf2_ord-doc-rcv.base-scale) .
       else
          run make-fin-ord-line-rcv-VAT ( input p-doc-code, input v-pc , buf2_ord-doc-rcv.base-rate , buf2_ord-doc-rcv.base-scale ) .
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
{ str/gen-flpo.i ord-doc-rcv }
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
              buf_fin-ob-trn.doc-type       = "rcv"     and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = tt-ord-code.doc-code
              no-error .
              if not available  buf_fin-ob-trn then  do:

            create buf_fin-ob-trn.
            assign
              buf_fin-ob-trn.doc-code       = p-doc-code
              buf_fin-ob-trn.doc-type       = "rcv"
              buf_fin-ob-trn.host-code      = par-host-code
              buf_fin-ob-trn.sum-tax-rubl   = n-sum-tax-rubl
              buf_fin-ob-trn.sum-rubl       = tt-ord-code.sum-rubl
              buf_fin-ob-trn.trn-doc-code   = tt-ord-code.doc-code
            .
            end.

      find first buf2_ord-doc-rcv  exclusive-lock  where buf2_ord-doc-rcv.rcv-code = tt-ord-code.doc-code no-error .
      if available buf2_ord-doc-rcv then do:
            assign
              buf2_ord-doc-rcv.cr-fo   = true
              buf2_ord-doc-rcv.fo-date = today
            .
      end.
      /* создадим партии по фин обязательству */
       if p-nalog = 1 then
          run make-fin-ord-line-rcv (input p-doc-code, input 2  , buf2_ord-doc-rcv.base-rate , buf2_ord-doc-rcv.base-scale) .
       else
          run make-fin-ord-line-rcv-VAT (input p-doc-code, input v-pc , buf2_ord-doc-rcv.base-rate , buf2_ord-doc-rcv.base-scale) .

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





procedure make-fin-ord-line-rcv :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-code as character no-undo .
define input parameter p-type as integer no-undo .
define input  parameter v-base-rate as decimal   no-undo .
define input  parameter v-base-scale as integer   no-undo .
/*
message p-type "p-type"  buf_contract.contract-code.
*/
define variable col-part   as integer   no-undo .

/* создадим партии по фин обязательству */
  for each temp-ord-line-rcv no-lock  where
           temp-ord-line-rcv.contract-code = buf_contract.contract-code
          /*
          (( p-type  = 1 ) or
           ( p-type  = 2   and temp-ord-line-rcv.out-code      = buf_fin-ob-trn.trn-doc-code))
           */
           on error undo, return error :
                if not can-find ( first buf_fin-gds-part no-lock where
                    buf_fin-gds-part.host-code   = par-host-code and
                    buf_fin-gds-part.fin-ob-code = p-doc-code           and
                    buf_fin-gds-part.obj-type    = temp-ord-line-rcv.obj-type  and
                    buf_fin-gds-part.obj-code    = temp-ord-line-rcv.obj-code  and
                    buf_fin-gds-part.gds-code    = temp-ord-line-rcv.gds-code  and
                    buf_fin-gds-part.part-code   = temp-ord-line-rcv.part-code and
                    buf_fin-gds-part.doc-type    = "rcv"                       and
                    buf_fin-gds-part.out-code    = temp-ord-line-rcv.out-code )
                then do:
                    col-part = col-part + 1.
                    if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show( "Создано партий : " + string( col-part )) .

                      create buf_fin-gds-part.
                      buffer-copy temp-ord-line-rcv to buf_fin-gds-part
                      assign
                        buf_fin-gds-part.doc-qnty    = temp-ord-line-rcv.qnty
                        buf_fin-gds-part.fact-qnty   = temp-ord-line-rcv.qnty
                        buf_fin-gds-part.obj-type    = temp-ord-line-rcv.obj-type
                        buf_fin-gds-part.obj-code    = temp-ord-line-rcv.obj-code
                        buf_fin-gds-part.gds-code    = temp-ord-line-rcv.gds-code
                        buf_fin-gds-part.part-code   = temp-ord-line-rcv.part-code
                        buf_fin-gds-part.out-code    = temp-ord-line-rcv.out-code
                        buf_fin-gds-part.doc-type    = "rcv"
                        buf_fin-gds-part.host-code          = par-host-code
                        buf_fin-gds-part.fin-ob-code        = p-doc-code
                        buf_fin-gds-part.status_dop         = {&fin-gen}
                        buf_fin-gds-part.user-db-num        = g#db-num
                        buf_fin-gds-part.user-name          = g#userid
                        buf_fin-gds-part.doc-qnty           = temp-ord-line-rcv.qnty
                        buf_fin-gds-part.sum-rubl-orig      = buf_fin-gds-part.sum-rubl
                        buf_fin-gds-part.sum-base-orig      = buf_fin-gds-part.sum-base
                        buf_fin-gds-part.sum-contract-orig  = temp-ord-line-rcv.sum-cli
                        buf_fin-gds-part.sum-contract       = temp-ord-line-rcv.sum-cli
                        /*
                        buf_fin-gds-part.other-rubl-orig    =
                        buf_fin-gds-part.road-tax-rubl-orig =
                        buf_fin-gds-part.transport-rubl-orig=
                        buf_fin-gds-part.other-base-orig    =
                        buf_fin-gds-part.road-tax-base-orig =
                        buf_fin-gds-part.transport-base-orig=
                        buf_fin-gds-part.other-contract-orig     =
                        buf_fin-gds-part.road-tax-contract-orig  =
                        buf_fin-gds-part.transport-contract-orig =
                        */
                        buf_fin-gds-part.vat-rubl-orig      = temp-ord-line-rcv.sum-vat
                        buf_fin-gds-part.vat-rubl           = temp-ord-line-rcv.sum-vat
                        buf_fin-gds-part.slt-rubl-orig      = temp-ord-line-rcv.sum-slt
                        buf_fin-gds-part.slt-rubl           = temp-ord-line-rcv.sum-slt
                        buf_fin-gds-part.vat-base-orig      = temp-ord-line-rcv.sum-vat * v-base-scale / v-base-rate
                        buf_fin-gds-part.vat-base           = temp-ord-line-rcv.sum-vat * v-base-scale / v-base-rate
                        buf_fin-gds-part.slt-base-orig      = temp-ord-line-rcv.sum-slt * v-base-scale / v-base-rate
                        buf_fin-gds-part.slt-base           = temp-ord-line-rcv.sum-slt * v-base-scale / v-base-rate
                        buf_fin-gds-part.vat-contract-orig  = temp-ord-line-rcv.sum-vat
                        buf_fin-gds-part.vat-contract       = temp-ord-line-rcv.sum-vat
                        buf_fin-gds-part.slt-contract-orig  = temp-ord-line-rcv.sum-vat
                        buf_fin-gds-part.slt-contract       = temp-ord-line-rcv.sum-vat
                      .
                end. /* buf_fin-gds-part.out-code */
            end.    /* temp-ord-line-rcv*/

 end. /* do */
end procedure. /* make-fin-ord-line-rcv */



procedure make-fin-ord-line-rcv-VAT :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-code as character no-undo .
define input  parameter v-pc as decimal   no-undo .
define input  parameter v-base-rate as decimal   no-undo .
define input  parameter v-base-scale as integer   no-undo .

if var-fin-calc <> {&fin-calc-obj}  then find first temp-obj-firm no-error .
define variable col-part   as integer   no-undo .

/* создадим партии по фин обязательству */
  for each temp-ord-line-rcv no-lock  where
           temp-ord-line-rcv.contract-code = buf_contract.contract-code and
           temp-ord-line-rcv.VAT-pc = v-pc  and
           ( var-fin-calc <> {&fin-calc-obj}  or (
           temp-ord-line-rcv.obj-type = temp-obj-firm.obj-type  and
           temp-ord-line-rcv.obj-code = temp-obj-firm.obj-code ))
           on error undo, return error :
                if not can-find (first buf_fin-gds-part no-lock where
                    buf_fin-gds-part.host-code   = par-host-code and
                    buf_fin-gds-part.fin-ob-code = p-doc-code              and
                    buf_fin-gds-part.doc-type    = "rcv"                       and
                    buf_fin-gds-part.obj-type    = temp-ord-line-rcv.obj-type  and
                    buf_fin-gds-part.obj-code    = temp-ord-line-rcv.obj-code  and
                    buf_fin-gds-part.gds-code    = temp-ord-line-rcv.gds-code  and
                    buf_fin-gds-part.part-code   = temp-ord-line-rcv.part-code and
                    buf_fin-gds-part.out-code    = temp-ord-line-rcv.out-code  use-index pi )
                then do:
                    col-part = col-part + 1.
                    if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show( "Создано партий : " + string( col-part )) .
                      run clc-price-tmp .
                      create buf_fin-gds-part.
                      buffer-copy temp-ord-line-rcv to buf_fin-gds-part
                      assign
                        buf_fin-gds-part.doc-qnty    = temp-ord-line-rcv.qnty
                        buf_fin-gds-part.fact-qnty   = temp-ord-line-rcv.qnty
                        buf_fin-gds-part.fin-ob-code        = p-doc-code
                        buf_fin-gds-part.doc-type           = "rcv"
                        buf_fin-gds-part.status_dop         = {&fin-gen}
                        buf_fin-gds-part.user-db-num        = g#db-num
                        buf_fin-gds-part.user-name          = g#userid
                        buf_fin-gds-part.doc-qnty           = temp-ord-line-rcv.qnty
                        buf_fin-gds-part.sum-rubl-orig      = temp-ord-line-rcv.sum-rubl - ( temp-ord-line-rcv.sum-transport-rubl +  temp-ord-line-rcv.sum-other-rubl)
                        buf_fin-gds-part.sum-rubl           = temp-ord-line-rcv.sum-rubl - ( temp-ord-line-rcv.sum-transport-rubl +  temp-ord-line-rcv.sum-other-rubl)
                        buf_fin-gds-part.sum-base-orig      = temp-ord-line-rcv.sum-base - ( temp-ord-line-rcv.sum-transport-base +  temp-ord-line-rcv.sum-other-base)
                        buf_fin-gds-part.sum-base           = temp-ord-line-rcv.sum-base - ( temp-ord-line-rcv.sum-transport-base +  temp-ord-line-rcv.sum-other-base)
                        buf_fin-gds-part.sum-contract-orig  = temp-ord-line-rcv.sum-cli
                        buf_fin-gds-part.sum-contract       = temp-ord-line-rcv.sum-cli
                        /*
                        buf_fin-gds-part.other-rubl-orig          =
                        buf_fin-gds-part.road-tax-rubl-orig       = tt-allsum.road-tax-rubl-acc
                        buf_fin-gds-part.transport-rubl-orig      = tt-allsum.transport-rubl-acc
                        buf_fin-gds-part.other-base-orig          = tt-allsum.other-base-acc
                        buf_fin-gds-part.road-tax-base-orig       = tt-allsum.road-tax-base-acc
                        buf_fin-gds-part.transport-base-orig      = tt-allsum.transport-base-acc
                        buf_fin-gds-part.other-contract-orig     = tt-allsum.other-cli-acc
                        buf_fin-gds-part.road-tax-contract-orig  = tt-allsum.road-tax-cli-acc
                        buf_fin-gds-part.transport-contract-orig = tt-allsum.transport-cli-acc
                        */
                        buf_fin-gds-part.vat-rubl-orig      = temp-ord-line-rcv.sum-vat
                        buf_fin-gds-part.vat-rubl           = temp-ord-line-rcv.sum-vat
                        buf_fin-gds-part.slt-rubl-orig      = temp-ord-line-rcv.sum-slt
                        buf_fin-gds-part.slt-rubl           = temp-ord-line-rcv.sum-slt
                        buf_fin-gds-part.vat-base-orig      = temp-ord-line-rcv.sum-vat * v-base-scale / v-base-rate
                        buf_fin-gds-part.vat-base           = temp-ord-line-rcv.sum-vat * v-base-scale / v-base-rate
                        buf_fin-gds-part.slt-base-orig      = temp-ord-line-rcv.sum-slt * v-base-scale / v-base-rate
                        buf_fin-gds-part.slt-base           = temp-ord-line-rcv.sum-slt * v-base-scale / v-base-rate
                        buf_fin-gds-part.vat-contract-orig  = temp-ord-line-rcv.sum-vat
                        buf_fin-gds-part.vat-contract       = temp-ord-line-rcv.sum-vat
                        buf_fin-gds-part.slt-contract-orig  = temp-ord-line-rcv.sum-vat
                        buf_fin-gds-part.slt-contract       = temp-ord-line-rcv.sum-vat

                      .
                end. /* buf_fin-gds-part.out-code */
            end.    /* temp-ord-line-rcv*/

 end. /* do */
end procedure. /* make-fin-ord-line-rcv-VAT */

procedure clc-price-tmp :

  do
  on error undo, return error return-value
  :

  end.

end procedure. /* clc-price-tmp */