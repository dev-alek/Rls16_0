block-level on error undo, throw.
/*

$Revision: a00ec218f474, 889, rls $
$Author: EShklyar $
$Date: Thu Dec 01 17:04:05 2016 +0300 $
$Workfile: genbfotr.p $
$Archive: str/genbfotr.p $

Процедура генерации ФО покупателей по заданным параметрам

Автор: Чернова Светлана Александровна
Дата создания: 08/24/06
Author: Svetlana Chernova
Creation date: 08/24/06

*/
define temp-table tt-trn-doc  no-undo like ub.trn-doc.

define input parameter parparentproc  as widget-handle no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter p-date-end     as date no-undo    .
define input parameter p-trn-doc      as integer no-undo . /* тип расчета по расходу */
define input parameter p-cons         as integer no-undo .
define input parameter p-nalog        as integer no-undo . /* если = 2 то на каждую ставку налога надо создавать ФО */
define input parameter table for tt-trn-doc .
define input-output parameter p-res as character no-undo .
define input  parameter p-type-date as integer   no-undo .
define input  parameter p-adm       as logical   no-undo .
/*
message par-host-code  'par-host-code  ' skip
        p-date-end     'p-date-end     ' skip
        p-trn-doc      'p-trn-doc      ' skip
        p-cons         'p-cons         ' skip
        p-nalog        'p-nalog        ' skip
        p-type-date    'p-type-date    ' skip
        p-adm          'p-adm          ' skip
        .
  */

define variable vss-revision    as character no-undo init "$Revision: a00ec218f474, 889, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 01 17:04:05 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: genbfotr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/genbfotr.p $":U .
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
  field doc-date       as date
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

define temp-table temp-parts no-undo like ub.parts
field gds-code as integer
field vat-rubl as decimal
field vat-base as decimal
field slt-rubl as decimal
field slt-base as decimal
field sum-rubl       as decimal
field sum-base       as decimal
index pi is unique primary
out-code
gds-code
in-code
part-code
.

define buffer old_fin-gds-part for ub.fin-gds-part  .
define variable p-usl-opl        as character no-undo .
define variable p-contract       as integer no-undo .
define variable p-cli            as integer no-undo .
define variable p-goods          as integer no-undo .

define variable Temp1         as integer init 10 no-undo .
define variable col-fo        as integer init 0 no-undo .
define variable col-bfo       as integer init 0 no-undo .
define variable col-trn       as integer init 0 no-undo .

define variable v-k                 as integer no-undo init 0 .
define variable v-type-trn-doc      as character no-undo .
define variable v-sign-list         as character no-undo .
define variable v-sign              as integer no-undo .
define variable v-shot-type-trn-doc as character no-undo .

define buffer buf_trn-doc          for ub.trn-doc.
define buffer buf_doc-line         for ub.doc-line  .
define buffer buf_contract         for ub.contract.
define buffer buf_goods            for ub.goods.
define buffer buf_fin-ob-trn       for ub.fin-ob-trn.
define buffer buf_fin-gds-part     for ub.fin-gds-part.
define buffer buf2_trn-doc         for ub.trn-doc.

define variable var-sum-rubl        as decimal   no-undo .
define variable var-sum-rublb       as decimal   no-undo .
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

/*{ gbl/getcntxt.i get }*/



run waitfram-show in this-procedure ("Ждите...").

define variable var-fin-calc as integer no-undo .
find first ub.sysconf no-lock where ub.sysconf.host-code = par-host-code no-error .
if available ub.sysconf then var-fin-calc = ub.sysconf.fin-calc   .
p-usl-opl =  {&o-buyer-trn} + "," + {&o-buyer-ord}    .
run make-temp-obj-firm in this-procedure .
assign
  v-type-trn-doc = "{&bef-TDEDT_Ras_Vnesh},{&bef-TDEDT_Ras_Vnesh_Kass},{&bef-TDEDT_Vozvrat_Vnesh},{&bef-TDEDT_Vozvrat_Vnesh_Kass}"
  v-shot-type-trn-doc = {&expense}
  v-sign-list    = "1,1,-1,-1"
.
/* разные типы вызова */

if p-trn-doc <> ?  then do:
      for each buf_trn-doc no-lock where
          buf_trn-doc.host-code  = par-host-code          and
          buf_trn-doc.need-buyer = 1                      and
        ( p-adm or
          buf_trn-doc.cr-fo-buyer   = false )             and
          lookup ( buf_trn-doc.ext-doc-type , v-type-trn-doc ) > 0 and
         /* buf_trn-doc.status_    = {&fact}                and
          buf_trn-doc.fact-date <= p-date-end                */
          buf_trn-doc.doc-date <= p-date-end
          on error undo, return error
          :
         /* message buf_trn-doc.doc-code buf_trn-doc.doc-date view-as alert-box . */
          find first buf_contract where buf_contract.contract-code = buf_trn-doc.contract-code and
                                        buf_contract.host-code     = buf_trn-doc.host-code     no-lock .
          if (lookup (buf_contract.usl-opl , {&o-buyer-ord} ) > 0 and p-trn-doc = 1) or
             (lookup (buf_contract.usl-opl , {&o-buyer-trn} ) > 0 and p-trn-doc = 2) or
             p-trn-doc = 3 or p-trn-doc = 0 then
                run proc-body in this-procedure .
      end. /* trn-doc */
      /*уже создано ФО, а накладную изменили*/
       for each buf_trn-doc no-lock where
          buf_trn-doc.host-code  = par-host-code          and
          buf_trn-doc.need-buyer = 1                      and
          buf_trn-doc.cr-fo-buyer   = true                and
          lookup ( buf_trn-doc.ext-doc-type , v-type-trn-doc ) > 0 and
          buf_trn-doc.status_    <> {&wayb} and buf_trn-doc.flag_ <> no  and
/*          buf_trn-doc.fact-date <= p-date-end*/
          buf_trn-doc.doc-date <= p-date-end,
          first buf_fin-ob-trn where buf_fin-ob-trn.trn-doc-code = tt-trn-doc.doc-code
                               and buf_fin-ob-trn.host-code = tt-trn-doc.host-code
                               and buf_fin-ob-trn.sum-rubl <> (tt-trn-doc.tot-fact - tt-trn-doc.discnt-rubl)
          on error undo, return error
          :
         /* message buf_trn-doc.doc-code buf_trn-doc.doc-date view-as alert-box . */
          find first buf_contract where buf_contract.contract-code = buf_trn-doc.contract-code and
                                        buf_contract.host-code     = buf_trn-doc.host-code     no-lock .
          if (lookup (buf_contract.usl-opl , {&o-buyer-ord} ) > 0 and p-trn-doc = 1) or
             (lookup (buf_contract.usl-opl , {&o-buyer-trn} ) > 0 and p-trn-doc = 2) or
             p-trn-doc = 3 or p-trn-doc = 0 then
                run proc-body in this-procedure .
      end. /* for each buf_trn-doc no-lock where */
 end.
 else do: /* по списку накладных */
    for each tt-trn-doc  no-lock  where
        lookup(tt-trn-doc.ext-doc-type , v-type-trn-doc) > 0
       /* and    tt-trn-doc.status_    = {&fact} */
        break by tt-trn-doc.ext-doc-type
        on error undo, return error
        :
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = tt-trn-doc.doc-code no-error .
        if available buf_trn-doc then  do:
           run proc-body in this-procedure .
        end.
    end. /* tt-trn-doc */
    for each tt-trn-doc  no-lock  where lookup(tt-trn-doc.ext-doc-type , v-type-trn-doc) > 0 
                                    and buf_trn-doc.cr-fo-buyer   = true  ,
                  first buf_fin-ob-trn where buf_fin-ob-trn.trn-doc-code = tt-trn-doc.doc-code
                               and buf_fin-ob-trn.host-code = tt-trn-doc.host-code
                               and buf_fin-ob-trn.sum-rubl <> (tt-trn-doc.tot-fact - tt-trn-doc.discnt-rubl) and
        buf_trn-doc.status_    <> {&wayb} and buf_trn-doc.flag_ <> no  
        break by tt-trn-doc.ext-doc-type
        on error undo, return error
        :
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = tt-trn-doc.doc-code no-error .
        if available buf_trn-doc then  do:
          find first tt-fin-ob no-error .
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
        .

     if var-fin-calc = {&fin-calc-obj}  then do : /* {&fin-calc-obj} */
        for each temp-obj-firm
            on error undo, return error :
                  assign
                    var-sum-rubl     =  0
                    var-sum-base     =  0
                    var-sum-contract =  0
                  .
                  for each tt-fin-ob where
                           tt-fin-ob.obj-code = temp-obj-firm.obj-code and
                           tt-fin-ob.obj-type = temp-obj-firm.obj-type ,
                      first buf_contract no-lock where
                            buf_contract.contract-code = tt-fin-ob.contract-code and
                            buf_contract.host-code     = par-host-code break
                            by tt-fin-ob.contract-code
                            by tt-fin-ob.pc
                            on error undo, return error :

                            var-sum-rubl     = var-sum-rubl     + tt-fin-ob.sum-rubl.
                            var-sum-base     = var-sum-base     + tt-fin-ob.sum-base.
                            var-sum-contract = var-sum-contract + tt-fin-ob.sum-contract .

                            if last-of(tt-fin-ob.contract-code)  or (p-nalog = 2 and last-of(tt-fin-ob.pc)) then do:
                                run make-s-fo-obj in this-procedure (
                                      input var-sum-rubl ,
                                      input var-sum-base ,
                                      input var-sum-contract ,
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
                                               buf_contract.host-code     = par-host-code
                    break
                       by tt-fin-ob.contract-code
                       by tt-fin-ob.pc
                    on error undo, return error :
                    var-sum-rubl = var-sum-rubl + tt-fin-ob.sum-rubl.
                    var-sum-base = var-sum-base + tt-fin-ob.sum-base.
                    var-sum-contract = var-sum-contract + tt-fin-ob.sum-contract.

                    if last-of (tt-fin-ob.contract-code) or (p-nalog = 2 and last-of (tt-fin-ob.pc)) then do:
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
       "Создано финансовых обязательств :" + string(col-fo) + {&new-line} +
       "Просмотрено накладных           :" + string(col-trn)           + {&new-line}

       .
define variable p-text as character no-undo .

return .


procedure proc-body :
 do
 on error undo, return error return-value
 :
define variable sum-gds-code as decimal no-undo .
define variable v-flag-buy as logical no-undo .
define variable v-may-be as logical   no-undo .
{ str/doc-fogn.i
  "'trn'"
  {&income}
  buf_trn-doc.doc-code
  g#db-num
  v-may-be
}
if v-may-be = false then do:
   p-res = p-res + {&new-line} + substitute("По документу &1 нельзя создавать ФО в этой БД" , buf_trn-doc.doc-code ) .
   return .
end.
assign
  v-flag-buy = ( if buf_trn-doc.cr-fo-buyer = true then true else false )
.
if p-adm then do:
    assign
      v-flag-buy =  false
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
      for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code   ,
              first buf_goods no-lock where buf_goods.artic     = buf_doc-line.artic      and
                                            buf_goods.prod-type = buf_doc-line.prod-type  and
                                            buf_goods.prod-code = buf_doc-line.prod-code ,
              first buf_contract no-lock where buf_contract.contract-code = buf_trn-doc.contract-code and
                                               buf_contract.host-code     = buf_trn-doc.host-code     and
                                               lookup (buf_contract.usl-opl , p-usl-opl ) > 0
              and (( can-find (first old_fin-gds-part no-lock where
                                    old_fin-gds-part.obj-type  = buf_trn-doc.obj-type  and
                                    old_fin-gds-part.obj-code  = buf_trn-doc.obj-code  and
                                    old_fin-gds-part.gds-code  = buf_goods.gds-code    and
                                    old_fin-gds-part.doc-type  = "":U                  and
                                    old_fin-gds-part.out-code  = buf_trn-doc.doc-code  )
                    = false )
                     OR ( CAN-FIND (FIRST OLD_FIN-GDS-PART NO-LOCK WHERE
                                    OLD_FIN-GDS-PART.OBJ-TYPE  = BUF_TRN-DOC.OBJ-TYPE  AND
                                    OLD_FIN-GDS-PART.OBJ-CODE  = BUF_TRN-DOC.OBJ-CODE  AND
                                    OLD_FIN-GDS-PART.GDS-CODE  = BUF_GOODS.GDS-CODE    AND
                                    OLD_FIN-GDS-PART.DOC-TYPE  = "":U                  AND
                                    OLD_FIN-GDS-PART.OUT-CODE  = BUF_TRN-DOC.DOC-CODE  AND
                                    OLD_FIN-GDS-PART.SUM-RUBL <> (BUF_TRN-DOC.TOT-FACT - BUF_TRN-DOC.DISCNT-RUBL)  )
                    = TRUE )
                     )/* на партию не найдено ФО по финпартиям */

              break
              by buf_trn-doc.contract-code
              by buf_doc-line.vat-pc
              on error undo, return error
              :

              if /*lookup(buf_contract.usl-opl , {&o-buyer-trn} ) > 0 and*/ v-flag-buy = false then do:
                  run clcprtsl_calc-line in this-procedure ( input recid( buf_doc-line ) ) no-error .
                  if error-status :error then
                  message
                    vss-workfile vss-revision vss-description skip
                    error-status :get-message(1) skip
                    return-value skip
                    "123err"
                    view-as alert-box error
                  .
                  find first tt-allsum-line  where tt-allsum-line.sum-type = {&sum-general} no-error.
                    assign
                      var-sum-rubl     = var-sum-rubl + (v-sign) * abs ( tt-allsum-line.sum-dsc-rubl-doc )
                      var-sum-contract = var-sum-rubl
                      var-sum-base     = var-sum-base + (v-sign) * abs ( tt-allsum-line.sum-dsc-base-doc )
                    .
                    find first temp-parts where 
                      temp-parts.host-code      = buf_trn-doc.host-code and
                      temp-parts.contract-code  = buf_trn-doc.contract-code and
                      temp-parts.out-code       = buf_doc-line.doc-code and
                      temp-parts.gds-code       = buf_goods.gds-code and
                      temp-parts.obj-type       = buf_trn-doc.obj-type and
                      temp-parts.obj-code       = buf_trn-doc.obj-code
                    no-error .
                    if available temp-parts then delete temp-parts . 
                    create temp-parts.
                    buffer-copy buf_doc-line  except buf_doc-line.status_ to temp-parts
                    assign
                      temp-parts.host-code      = buf_trn-doc.host-code
                      temp-parts.contract-code  = buf_trn-doc.contract-code
                      temp-parts.out-code       = buf_doc-line.doc-code
                      temp-parts.gds-code       = buf_goods.gds-code
                      temp-parts.cli-qnty       = v-sign * abs ( buf_doc-line.cli-qnty)
                      temp-parts.fact-qnty      = v-sign * abs ( buf_doc-line.fact-qnty)
                      temp-parts.qnty           = v-sign * abs ( buf_doc-line.fact-qnty)
                      temp-parts.sum-rubl       = v-sign * abs ( tt-allsum-line.sum-dsc-rubl-doc)
                      temp-parts.sum-base       = v-sign * abs ( tt-allsum-line.sum-dsc-base-doc)
                      temp-parts.vat-rubl       = v-sign * abs ( tt-allsum-line.VAT-rubl-buyer-doc)
                      temp-parts.vat-base       = v-sign * abs ( tt-allsum-line.VAT-base-buyer-doc)
                      temp-parts.slt-rubl       = v-sign * abs ( tt-allsum-line.slt-rubl-doc)
                      temp-parts.slt-base       = v-sign * abs ( tt-allsum-line.slt-base-doc)
                      temp-parts.obj-type       = buf_trn-doc.obj-type
                      temp-parts.obj-code       = buf_trn-doc.obj-code
                    .
                end.
          /*-------------------------------------------------------------------------------------------------------------*/
            if last-of (buf_trn-doc.contract-code) or (p-nalog = 2 and last-of (buf_doc-line.vat-pc)) then do:
               var-sum-rublb = 0 .
               var-sum-baseb = 0 .
               var-sum-contractb = 0 .
                      if p-cons = 1 then do: /* Если нало по всем накладным одного договора       M накл. -> 1 фин.об.  */
                            run make-tt-fo in this-procedure
                                ( input var-sum-rubl ,
                                  input var-sum-base ,
                                  input var-sum-contract ,
                                  input buf_doc-line.vat-pc
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
            end. /* if last-of */
      end. /* parts */
 end. /* do */
end procedure. /* proc-body */

procedure make-fo :
 do
 on error undo, return error return-value
 :
define input parameter v-sum-rubl as decimal no-undo .
define input parameter v-sum-base as decimal no-undo .
define input parameter v-sum-contract as decimal no-undo .
{ str/gen-flpj.i }
  run fin-ob-code in this-procedure ( input g#db-num , output p-doc-code) .
  define variable min-date as date no-undo .

  if buf_trn-doc.fact-date <> ? then
        min-date = buf_trn-doc.fact-date.
  else  min-date = buf_trn-doc.doc-date.

  if  min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) <= n-doc-date
      then n-pay-date = n-doc-date.
      else n-pay-date = min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) .

  run create-fin-liab in this-procedure (
        input yes                 ,
        input  p-doc-code         ,
        input  n-doc-date         ,
        input  n-doc-type         ,
        input  n-payer-name       ,
        input  n-receiver-name    ,
        input  n-curr-code        ,
        input  n-sum-doc          ,
        input  n-user-db-num-doc  ,
        input  n-user-name-doc    ,
        input  n-base-rate        ,
        input  n-base-scale       ,
        input  n-receiver-code    ,
        input  n-receiver-type    ,
        input  n-contract-code    ,
        input  n-exch-rate        ,
        input  n-exch-scale       ,
        input  n-contract-curr    ,
        input  n-contract-rate    ,
        input  n-contract-scale   ,
        input  n-fact-date        ,
        input  n-fact-order       ,
        input  par-host-code      ,
        input  n-payer-code       ,
        input  n-payer-type       ,
        input  n-pay-date         ,
        input  string(p-doc-code) ,
        input  {&fin-gen}         ,
        input  n-sum-base-orig    ,
        input  n-sum-base         ,
        input  n-sum-doc-orig     ,
        input  n-sum-rubl-orig    ,
        input  n-sum-rubl         ,
        input  n-sum-contract     ,
        input  n-trn-doc-code     ,
        input  n-user-db-num-fact ,
        input  n-user-db-num-pay  ,
        input  n-user-name-fact   ,
        input  n-user-name-pay    ,
        input  n-in-type          ,
        input  n-sum-tax-base     ,
        input  n-sum-tax-doc      ,
        input  n-sum-tax-rubl     ,
        input  n-sum-tax-contract ,
        input  ""                 ,
        output p-ri )
        no-error .
        /* if error-status :error then  return. */
        col-fo = col-fo + 1.
        find first  buf_fin-ob-trn no-lock  where
              buf_fin-ob-trn.doc-code       = p-doc-code  and
              buf_fin-ob-trn.host-code      = par-host-code  and
              buf_fin-ob-trn.trn-doc-code   = buf_trn-doc.doc-code  no-error .
              if not available  buf_fin-ob-trn then  do:
                create buf_fin-ob-trn.
                assign
                  buf_fin-ob-trn.doc-code       = p-doc-code
                  buf_fin-ob-trn.host-code      = par-host-code
                  buf_fin-ob-trn.trn-doc-code   = buf_trn-doc.doc-code
                  buf_fin-ob-trn.sum-rubl       = n-sum-rubl
                .
               end.
            find first buf2_trn-doc  exclusive-lock  where buf2_trn-doc.doc-code = buf_trn-doc.doc-code no-error .
            if available buf2_trn-doc then do:
/*                if lookup( buf_contract.usl-opl , {&o-buyer-trn}  ) > 0 then do:*/
                assign
                  buf2_trn-doc.cr-fo-buyer        = true
                  buf2_trn-doc.buyer-fo-date      = today
                .
                    if buf2_trn-doc.need-buyer = 2 then do:
                      assign
                        buf2_trn-doc.need-buyer      = 1
                      .
                    end.
/*                end.                                  */
/*                else do:                              */
/*                    assign                            */
/*                      buf2_trn-doc.need-buyer      = 0*/
/*                    .                                 */
/*                end.                                  */
            end.

  run make-fin-parts in this-procedure ( input p-doc-code , input 1 ) .
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
  for each temp-parts where
           temp-parts.contract-code = buf_contract.contract-code :
     delete temp-parts .
  end.

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

{ str/gen-flpj.i }
  v-k = v-k + 1 .

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
          tt-trn-code.pc            = v-pc                       and
          tt-trn-code.doc-code      = buf_trn-doc.doc-code       ) then do:
          create tt-trn-code.
          assign
            tt-trn-code.contract-code = buf_contract.contract-code
            tt-trn-code.host-code     = par-host-code
            tt-trn-code.doc-code      = buf_trn-doc.doc-code
            tt-trn-code.fact-date     = buf_trn-doc.fact-date
            tt-trn-code.doc-date      = buf_trn-doc.doc-date
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
define input parameter v-pc as decimal   no-undo .
v-pc = if p-nalog = 1 then 0 else v-pc.


{ str/gen-flpj.i }
/* найдем мин дату */
define variable min-date as date no-undo .
define variable max-date as date no-undo .
  for each tt-trn-code  where
      tt-trn-code.contract-code = buf_contract.contract-code  and
      tt-trn-code.host-code     = par-host-code
      break by tt-trn-code.fact-date DESCENDING
      on error undo, return error
      :
      if tt-trn-code.fact-date <> ? then
            min-date = tt-trn-code.fact-date.
      else  min-date = tt-trn-code.doc-date.
  end.
  if  min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) <= n-doc-date
      then n-pay-date = n-doc-date.
      else n-pay-date = min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) .
  run fin-ob-code in this-procedure (input g#db-num , output p-doc-code) .
  run create-fin-liab in this-procedure (
    input  yes                   ,
    input  p-doc-code            ,
    input  n-doc-date            ,
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
    output p-ri                  )
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

  for each tt-trn-code  where
      tt-trn-code.contract-code = buf_contract.contract-code  and
      tt-trn-code.host-code     = par-host-code
      on error undo, return error :

        find first  buf_fin-ob-trn no-lock  where
              buf_fin-ob-trn.doc-code     = p-doc-code  and
              buf_fin-ob-trn.host-code    = par-host-code  and
              buf_fin-ob-trn.trn-doc-code = tt-trn-code.doc-code  no-error .
        if not available  buf_fin-ob-trn then do:
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
/*        if lookup( buf_contract.usl-opl , {&o-buyer-trn}  ) > 0 then do:*/
            assign
              buf2_trn-doc.cr-fo-buyer   = true
              buf2_trn-doc.buyer-fo-date = today
            .
          if buf2_trn-doc.need-buyer = 2 then do:
            assign
              buf2_trn-doc.need-buyer      = 1
                      .
          end.
/*        end.                                    */
/*          else do:                              */
/*              assign                            */
/*                buf2_trn-doc.need-buyer      = 0*/
/*              .                                 */
/*          end.                                  */
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
        )
  .

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
 define buffer buf_shop for ub.shop .
 define buffer buf_store for ub.store .
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
define buffer buf_fact-fin-ob   for ub.fin-ob .
define buffer buf_fact-contract for ub.contract .


find first buf_fact-fin-ob  no-lock where
           buf_fact-fin-ob.host-code = p-host-code and
           buf_fact-fin-ob.doc-code  = p-doc-code no-error .
           if error-status :error then do:
              return  error .
           end.

 find first buf_fact-contract no-lock where
            buf_fact-contract.host-code = buf_fact-fin-ob.host-code and
            buf_fact-contract.contract-code = buf_fact-fin-ob.contract-code no-error .
            if error-status :error then do:
               return  error .
            end.


  if buf_fact-contract.auto-pay  > 0 then do:
      run proc-close-one-fin-ob in this-procedure (recid(buf_fact-fin-ob)) no-error .
      if error-status :error then do:
         message vss-workfile vss-revision vss-description skip
                "№ ФО :" buf_fact-fin-ob.doc-code skip
                "№ фирмы :" buf_fact-fin-ob.host-code skip
                "Вн.№ договора :" buf_fact-fin-ob.contract-code skip
                "Ошибка закрытия на факт ФО на РН " skip
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

{ str/gen-flpj.i }
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
            if tt-trn-code.fact-date <> ? then
                 min-date = tt-trn-code.fact-date.
            else min-date = tt-trn-code.doc-date.
        end.

      if  min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) <= n-doc-date
          then n-pay-date = n-doc-date .
          else n-pay-date = min-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) .


  run fin-ob-code in this-procedure ( input g#db-num, output p-doc-code) .
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
/*        if lookup( buf_contract.usl-opl , {&o-buyer-trn}  ) > 0 then do:*/
            assign
              buf2_trn-doc.cr-fo-buyer   = true
              buf2_trn-doc.buyer-fo-date = today
              .
              if buf2_trn-doc.need-buyer = 2 then do:
                assign
                  buf2_trn-doc.need-buyer      = 1
                  .
              end.
/*        end.                                    */
/*          else do:                              */
/*              assign                            */
/*                buf2_trn-doc.need-buyer      = 0*/
/*              .                                 */
/*          end.                                  */
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
        ).

  run update-fin-ob_obj in this-procedure (
        input p-doc-code ,
        input par-host-code
        ).

 run close-fo-fact in this-procedure ( input par-host-code, input p-doc-code ) no-error   .
 if error-status :error then
    p-res = p-res + {&new-line} + " Ошибка процедуры закрытия на ФАКТ совокупного ФО "  + error-status :get-message(1)  + return-value .
 end. /* do */
end procedure. /* make-s-fo */


procedure make-fin-parts :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-code as character no-undo .
define input parameter p-type     as integer no-undo .

define variable col-part   as integer   no-undo .
/* создадим партии по фин обязательству */
  for each temp-parts no-lock  where
           temp-parts.contract-code = buf_contract.contract-code and
           (p-type  = 1  or
            temp-parts.out-code      = buf_fin-ob-trn.trn-doc-code)
           on error undo, return error :
              if not can-find ( first buf_fin-gds-part no-lock where
                    buf_fin-gds-part.host-code   = temp-parts.host-code and
                    buf_fin-gds-part.fin-ob-code = p-doc-code           and
                    buf_fin-gds-part.obj-type    = temp-parts.obj-type  and
                    buf_fin-gds-part.obj-code    = temp-parts.obj-code  and
                    buf_fin-gds-part.gds-code    = temp-parts.gds-code  and
                    buf_fin-gds-part.in-code     = temp-parts.in-code   and
                    buf_fin-gds-part.part-code   = temp-parts.part-code and
                    buf_fin-gds-part.doc-type    = ""    and
                    buf_fin-gds-part.out-code    = temp-parts.out-code use-index pi )
                then do :
                    col-part = col-part + 1.
                    if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show in this-procedure ( "Создано партий : " + string( col-part )) .
                      create buf_fin-gds-part.
                      buffer-copy temp-parts to buf_fin-gds-part
                      assign
                        buf_fin-gds-part.out-code               = temp-parts.out-code
                        buf_fin-gds-part.doc-type               = ""
                        buf_fin-gds-part.fin-ob-code            = p-doc-code
                        buf_fin-gds-part.status_dop             = {&fin-gen}
                        buf_fin-gds-part.user-db-num            = g#db-num
                        buf_fin-gds-part.user-name              = g#userid
                        buf_fin-gds-part.doc-qnty               = temp-parts.qnty
                        buf_fin-gds-part.sum-rubl-orig          = temp-parts.sum-rubl
                        buf_fin-gds-part.sum-rubl               = temp-parts.sum-rubl
                        buf_fin-gds-part.sum-base-orig          = temp-parts.sum-base
                        buf_fin-gds-part.sum-base               = temp-parts.sum-base
                        buf_fin-gds-part.sum-contract-orig      = buf_fin-gds-part.sum-rubl
                        buf_fin-gds-part.sum-contract           = buf_fin-gds-part.sum-rubl
                        buf_fin-gds-part.other-rubl-orig        = temp-parts.other-rubl
                        buf_fin-gds-part.road-tax-rubl-orig     = temp-parts.road-tax-rubl
                        buf_fin-gds-part.transport-rubl-orig    = temp-parts.transport-rubl
                        buf_fin-gds-part.other-base-orig        = temp-parts.other-base
                        buf_fin-gds-part.road-tax-base-orig     = temp-parts.road-tax-base
                        buf_fin-gds-part.transport-base-orig    = temp-parts.transport-base
                        buf_fin-gds-part.other-contract-orig    = buf_fin-gds-part.other-rubl-orig
                        buf_fin-gds-part.road-tax-contract-orig = buf_fin-gds-part.road-tax-rubl-orig
                        buf_fin-gds-part.transport-contract-orig = buf_fin-gds-part.transport-rubl-orig
                        buf_fin-gds-part.vat-rubl-orig      = temp-parts.vat-rubl
                        buf_fin-gds-part.vat-rubl           = temp-parts.vat-rubl
                        buf_fin-gds-part.slt-rubl-orig      = temp-parts.slt-rubl
                        buf_fin-gds-part.slt-rubl           = temp-parts.slt-rubl
                        buf_fin-gds-part.vat-base-orig      = temp-parts.vat-base
                        buf_fin-gds-part.vat-base           = temp-parts.vat-base
                        buf_fin-gds-part.slt-base-orig      = temp-parts.slt-base
                        buf_fin-gds-part.slt-base           = temp-parts.slt-base
                        buf_fin-gds-part.vat-contract-orig  = buf_fin-gds-part.vat-rubl-orig
                        buf_fin-gds-part.vat-contract       = buf_fin-gds-part.vat-rubl
                        buf_fin-gds-part.slt-contract-orig  = buf_fin-gds-part.slt-rubl-orig
                        buf_fin-gds-part.slt-contract       = buf_fin-gds-part.slt-rubl
                      .
                end. /* buf_fin-gds-part.out-code */
            end.    /* temp-parts*/
 end. /* do */
end procedure. /* make-fin-parts */


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
                      create buf_fin-gds-part.
                      buffer-copy temp-parts to buf_fin-gds-part
                      assign
                        buf_fin-gds-part.fin-ob-code          = p-doc-code
                        buf_fin-gds-part.status_dop           = {&fin-gen}
                        buf_fin-gds-part.user-db-num          = g#db-num
                        buf_fin-gds-part.user-name            = g#userid
                        buf_fin-gds-part.doc-qnty           = temp-parts.qnty
                        buf_fin-gds-part.obj-type           = temp-parts.obj-type
                        buf_fin-gds-part.obj-code           = temp-parts.obj-code
                        buf_fin-gds-part.sum-rubl-orig      = temp-parts.price-rubl * temp-parts.qnty
                        buf_fin-gds-part.sum-rubl           = temp-parts.price-rubl * temp-parts.qnty
                        buf_fin-gds-part.sum-base-orig      = temp-parts.price-base * temp-parts.qnty
                        buf_fin-gds-part.sum-base           = temp-parts.price-base * temp-parts.qnty
                        buf_fin-gds-part.sum-contract-orig  = buf_fin-gds-part.sum-rubl
                        buf_fin-gds-part.sum-contract       = buf_fin-gds-part.sum-rubl
                        buf_fin-gds-part.other-rubl-orig    = temp-parts.other-rubl
                        buf_fin-gds-part.road-tax-rubl-orig = temp-parts.road-tax-rubl
                        buf_fin-gds-part.transport-rubl-orig= temp-parts.transport-rubl
                        buf_fin-gds-part.other-base-orig    = temp-parts.other-base
                        buf_fin-gds-part.road-tax-base-orig = temp-parts.road-tax-base
                        buf_fin-gds-part.transport-base-orig= temp-parts.transport-base
                        buf_fin-gds-part.other-contract-orig     = buf_fin-gds-part.other-rubl-orig
                        buf_fin-gds-part.road-tax-contract-orig  = buf_fin-gds-part.road-tax-rubl-orig
                        buf_fin-gds-part.transport-contract-orig = buf_fin-gds-part.transport-rubl-orig
                        buf_fin-gds-part.vat-rubl-orig      = temp-parts.vat-rubl
                        buf_fin-gds-part.vat-rubl           = temp-parts.vat-rubl
                        buf_fin-gds-part.slt-rubl-orig      = temp-parts.slt-rubl
                        buf_fin-gds-part.slt-rubl           = temp-parts.slt-rubl
                        buf_fin-gds-part.vat-base-orig      = temp-parts.vat-base
                        buf_fin-gds-part.vat-base           = temp-parts.vat-base
                        buf_fin-gds-part.slt-base-orig      = temp-parts.slt-base
                        buf_fin-gds-part.slt-base           = temp-parts.slt-base
                        buf_fin-gds-part.vat-contract-orig  = buf_fin-gds-part.vat-rubl-orig
                        buf_fin-gds-part.vat-contract       = buf_fin-gds-part.vat-rubl
                        buf_fin-gds-part.slt-contract-orig  = buf_fin-gds-part.slt-rubl-orig
                        buf_fin-gds-part.slt-contract       = buf_fin-gds-part.slt-rubl

                      .
                end. /* buf_fin-gds-part.out-code */
            end.    /* temp-parts*/

 end. /* do */
end procedure. /* make-fin-parts-VAT */