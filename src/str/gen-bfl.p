block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gen-bfl.p $
$Archive: str/gen-bfl.p $

создание фин обязательств из пред фин об ( )

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 02/11/04 11:02

*/
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: gen-bfl.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/gen-bfl.p $":U .
def var vss-description as character no-undo init " создание фин обязательств из пред фин об  ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i   }
{ cmp/showinf.i   }
{ gbl/cur-time.i }
{ str/crfinob.i  fin-ob }
{ gbl/waitfram.i }
{ str/libofarh.i }
{ str/fo-clos.i  }
{ str/clcprtsl.i }
{ gbl/getcntxt.i def }
{ gbl/thbjattr.i }
define input parameter ParParentProc  as widget-handle no-undo.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter p-view-text as logical no-undo .
define output parameter p-text as character no-undo init "" .

define variable v-message-text as character no-undo init "".

define variable p-ri       as recid   no-undo .
define variable p-doc-code as character no-undo .
define variable n-doc-type             like     ub.fin-ob.doc-type             no-undo .
define variable n-payer-name           like         ub.fin-ob.payer-name       no-undo .
define variable n-receiver-name        like         ub.fin-ob.receiver-name    no-undo .
define variable n-curr-code            like         ub.fin-ob.curr-code        no-undo .
define variable n-sum-doc              like         ub.fin-ob.sum-doc          no-undo .
define variable n-user-db-num-doc      like         ub.fin-ob.user-db-num-doc  no-undo .
define variable n-user-name-doc        like         ub.fin-ob.user-name-doc    no-undo .
define variable n-base-rate            like         ub.fin-ob.base-rate        no-undo .
define variable n-base-scale           like         ub.fin-ob.base-scale       no-undo .
define variable n-receiver-code        like         ub.fin-ob.receiver-code    no-undo .
define variable n-receiver-type        like         ub.fin-ob.receiver-type    no-undo .
define variable n-contract-code        like         ub.fin-ob.contract-code    no-undo .
define variable n-exch-rate            like         ub.fin-ob.exch-rate        no-undo .
define variable n-exch-scale           like         ub.fin-ob.exch-scale       no-undo .
define variable n-contract-curr        like         ub.fin-ob.contract-curr    no-undo .
define variable n-contract-rate        like         ub.fin-ob.contract-rate    no-undo .
define variable n-contract-scale       like         ub.fin-ob.contract-scale   no-undo .
define variable n-fact-date            like         ub.fin-ob.fact-date        no-undo .
define variable n-fact-order           like         ub.fin-ob.fact-order       no-undo .
define variable n-payer-code           like         ub.fin-ob.payer-code       no-undo .
define variable n-payer-type           like         ub.fin-ob.payer-type       no-undo .
define variable n-pay-date             like         ub.fin-ob.pay-date         no-undo .
define variable n-prn-doc-code         like         ub.fin-ob.prn-doc-code     no-undo .
define variable n-sum-base-orig        like         ub.fin-ob.sum-base-orig    no-undo .
define variable n-sum-base             like         ub.fin-ob.sum-base         no-undo .
define variable n-sum-doc-orig         like         ub.fin-ob.sum-doc-orig     no-undo .
define variable n-sum-rubl-orig        like         ub.fin-ob.sum-rubl-orig    no-undo .
define variable n-sum-rubl             like         ub.fin-ob.sum-rubl         no-undo .
define variable n-sum-contract         like         ub.fin-ob.sum-contract     no-undo .
define variable n-trn-doc-code         like         ub.fin-ob.trn-doc-code     no-undo .
define variable n-user-db-num-fact     like         ub.fin-ob.user-db-num-fact no-undo .
define variable n-user-db-num-pay      like         ub.fin-ob.user-db-num-pay  no-undo .
define variable n-user-name-fact       like         ub.fin-ob.user-name-fact   no-undo .
define variable n-user-name-pay        like         ub.fin-ob.user-name-pay    no-undo .
define variable n-in-type              like         ub.fin-ob.in-type          no-undo .
define variable n-sum-tax-base         like         ub.fin-ob.sum-tax-base     no-undo .
define variable n-sum-tax-doc          like         ub.fin-ob.sum-tax-doc      no-undo .
define variable n-sum-tax-rubl         like         ub.fin-ob.sum-tax-rubl     no-undo .
define variable n-sum-tax-contract     like         ub.fin-ob.sum-tax-contract no-undo .
define variable  v-fo-code as integer no-undo .

define variable col-fo as integer no-undo .
define buffer buf_fin-ob-before for fin-ob-before .
define buffer buf_incom-trn-doc  for trn-doc .
define buffer buf_contract for contract.



define variable v-proc-contr as decimal no-undo .
define variable v-sum-pn     as decimal no-undo .
define variable v-sum-ras     as decimal no-undo .
define variable v-tt as character no-undo .
define variable v-go as logical no-undo init true .
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

assign
  varis-doc            = false .
  varis-cur            = false .
  varroad-tax          = 0     .
  varexcise            = 0     .
  varvat-pc            = 0     .
  varcons-vat-pc       = 0     .
  varslt-pc            = 0     .
  varbase-rate         = 0     .
  varbase-scale        = 0     .
  varr-b               = ""     .
  varcur-base          = 0     .
  varcurroad-tax       = 0     .
  varcurexcise         = 0     .
  varcurvat-pc         = 0     .
  varcurcons-vat-pc    = 0     .
  varcurslt-pc         = 0     .
.

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

for each buf_fin-ob-before no-lock where
        buf_fin-ob-before.host-code = par-host-code and
        buf_fin-ob-before.status_ = {&fin-gen}

        break
        by buf_fin-ob-before.trn-doc-code-orig
        by buf_fin-ob-before.sum-rubl
        on error undo, return error
        :

    if first-of (buf_fin-ob-before.trn-doc-code-orig) then do:
       find first buf_contract no-lock where buf_contract.contract-code = buf_fin-ob-before.contract-code no-error .
       if available buf_contract then v-proc-contr = buf_contract.srok-opl .
                                 else do:
                                     v-proc-contr = 0 .
                                     v-message-text =  v-message-text + {&new-line}  + error-status :get-message(1) + " Вн.№ договора " + string(buf_fin-ob-before.contract-code) .
                                 end.

      find first buf_incom-trn-doc no-lock where buf_incom-trn-doc.doc-code = buf_fin-ob-before.trn-doc-code-orig no-error .
      if available buf_incom-trn-doc
          then do:
              /* message buf_incom-trn-doc.need-expfo . */
              if buf_incom-trn-doc.need-expfo = 1 then v-go = false .
                                                  else v-go = true  .
              run sum-in-parts in this-procedure (
                  input buf_incom-trn-doc.doc-code ,
                  input buf_fin-ob-before.contract-code ,
                  output  v-sum-pn
                  ) .
          end.
          else do:
           v-sum-pn = 0 .
            v-go = false . /* ПН - удалена */
            v-message-text =  v-message-text + {&new-line}  + " ПН " + buf_fin-ob-before.trn-doc-code-orig + " УДАЛЕНА".
          end.
      v-sum-ras = 0 .
    end.

    v-sum-ras = v-sum-ras + buf_fin-ob-before.sum-rubl .

    if last-of (buf_fin-ob-before.trn-doc-code-orig) then do:
       /* посчитаем скоколько это процентов */

       if ( 100 * v-sum-ras / v-sum-pn ) >=  v-proc-contr /* превышение процента ук в договоре */ then do:
          if  v-go = true then do:
              run make-fo in this-procedure (input  buf_fin-ob-before.trn-doc-code-orig , output v-fo-code )  no-error .
                  if error-status :error then v-message-text =  v-message-text + {&new-line}  + error-status :get-message(1) + " создание ФО " .
              run close-bfo in this-procedure (input buf_fin-ob-before.trn-doc-code-orig, input  v-fo-code  ) no-error .
                  if error-status :error then v-message-text =  v-message-text + {&new-line}  + error-status :get-message(1) + " закрытие ПФО " .
          end.
       end.
       else do:
            if p-view-text = true then
                v-tt = {&new-line}  +
                "№ ПН          "  + buf_fin-ob-before.trn-doc-code-orig + {&new-line}  +
                "Cумма по ПН   "  + string( v-sum-pn  ) + {&new-line}  +
                "Cумма по ПФО  "  + string( v-sum-ras ) + {&new-line}  +
                "% расчетный   "  + string( 100 * v-sum-ras / v-sum-pn ) + {&new-line} +
                "% по договору "  + string( v-proc-contr ) +  {&new-line} +
                "-------------------------------"
                .
            if v-tt = ? then v-tt = "" .
            v-message-text =  v-message-text + {&new-line}  + v-tt .
       end.
    end.

end. /* for each */
v-message-text =  v-message-text + {&new-line}  +
    {&new-line}  +
    "Сделано ФО по ПФО  "  + string( col-fo )
   .


run waitfram-hide in this-procedure .
p-text = if v-message-text = ? then "" else v-message-text .
if p-view-text = true then
    run gbl/d-prompt.w (
        'title=Результат создания Финобязательств из ПредФинОбязательств\'
      + 'type=editor\'
      + 'fillin_width=50\'
      + 'fillin_height=15\'
      + 'readonly=yes\'
      , input-output v-message-text
      ).



procedure close-bfo :
 do
 on error undo, return error return-value
 :
define input parameter p-in-code as character no-undo . /* Номер ПН */
define input parameter p-fo-code as character no-undo .  /* НОМЕР ФО */

define buffer b_fin-ob-before for fin-ob-before.

define variable  v-fact-date            as date    no-undo . /* фактическая дата закрытия документа  */
define variable  v-fact-time            as integer no-undo . /* фактическое время закрытия документа */
define variable  v-fact-num             as integer no-undo . /* фактический номер закрытия документа */
define variable  v-shift-date           as date    no-undo . /* дата начала смены для документа      */
define variable  v-shift-num            as integer no-undo . /* порядок смены для документа          */
define variable  v-shift-on             as logical no-undo . /* на объекте включены смены            */
define variable  v-fact-order           as decimal no-undo . /* порядковый номер закрытия документа  */
define variable  v-shift-end-fact-order as decimal no-undo . /* номер конца смены                    */
define variable  v-day-end-fact-order   as decimal no-undo . /* номер конца дня                      */


for each b_fin-ob-before  exclusive-lock  where
                                          b_fin-ob-before.host-code = par-host-code and
                                          b_fin-ob-before.trn-doc-code-orig = p-in-code
                                          on error undo, return error :
  run cur-time in this-procedure (
                 output v-fact-date
               , output v-fact-time
                ).

  assign
      v-fact-num   = next-value ( s-fin-ob-fact, {&db-name_schema} )
      v-shift-date = ?
      v-shift-num  = ?
      v-shift-on   = false
  .

   run factord in this-procedure (
      input  v-fact-date
      ,input  v-fact-time
      ,input  v-fact-num
      ,input  v-shift-date
      ,input  v-shift-num
      ,input  v-shift-on
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ).

  assign
    b_fin-ob-before.fact-order  = v-fact-order
    b_fin-ob-before.doc-code    = p-fo-code
    b_fin-ob-before.status_     = {&fin-fact}
    b_fin-ob-before.user-db-num-fact  = g#db-num
    b_fin-ob-before.user-name-fact    = g#userid
    b_fin-ob-before.fact-date         = v-fact-date
  .

end. /* for each */


 end. /* do */
end procedure. /* close-bfo */


/* СОЗДАНИЕ ФО ПО ПН */
procedure make-fo :
 do
 on error undo, return error return-value
 :
define input parameter  p-in-code as character no-undo .
define output parameter p-fo-code as character no-undo .

define buffer b_fin-ob-before  for ub.fin-ob-before .
define buffer buf_fin-ob-trn   for ub.fin-ob-trn .
define buffer buf_parts        for ub.parts .
define buffer buf_fin-gds-part for ub.fin-gds-part .
define buffer buf_goods        for ub.goods .


find first  b_fin-ob-before  no-lock   where
            b_fin-ob-before.host-code         = par-host-code and
            b_fin-ob-before.trn-doc-code-orig = p-in-code
            no-error .
assign
  n-doc-type             = b_fin-ob-before.doc-type
  n-payer-name           = b_fin-ob-before.payer-name
  n-receiver-name        = b_fin-ob-before.receiver-name
  n-curr-code            = b_fin-ob-before.curr-code
  n-user-db-num-doc      = g#db-num
  n-user-name-doc        = g#userid
  n-base-rate            = b_fin-ob-before.base-rate
  n-base-scale           = b_fin-ob-before.base-scale
  n-receiver-code        = b_fin-ob-before.receiver-code
  n-receiver-type        = b_fin-ob-before.receiver-type
  n-contract-code        = b_fin-ob-before.contract-code
  n-exch-rate            = b_fin-ob-before.exch-rate
  n-exch-scale           = b_fin-ob-before.exch-scale
  n-contract-curr        = b_fin-ob-before.contract-curr
  n-contract-rate        = b_fin-ob-before.contract-rate
  n-contract-scale       = b_fin-ob-before.contract-scale

  n-payer-code           = b_fin-ob-before.payer-code
  n-payer-type           = b_fin-ob-before.payer-type
  n-pay-date             = today
  n-trn-doc-code         = ?
  n-in-type              = b_fin-ob-before.in-type
.

run fin-ob-code in this-procedure ( input g#db-num , output p-doc-code) .
  p-fo-code = p-doc-code .

  col-fo = col-fo + 1.


  /*  пометка о создании   */

  create buf_fin-ob-trn.
  assign
    buf_fin-ob-trn.doc-code       = p-doc-code
    buf_fin-ob-trn.host-code      = par-host-code
    buf_fin-ob-trn.sum-rubl       = n-sum-rubl
    buf_fin-ob-trn.sum-tax-rubl   = n-sum-tax-rubl
    buf_fin-ob-trn.trn-doc-code   = p-in-code
  .

  define buffer buf_trn-doc for trn-doc.
  find first buf_trn-doc  exclusive-lock  where buf_trn-doc.doc-code = p-in-code no-error .
  if available buf_trn-doc then do:
      assign
        buf_trn-doc.cr-expfo      = true
        buf_trn-doc.cr-incorexpfo = true
        buf_trn-doc.expfo-date    = today
        buf_trn-doc.need-expfo      = 1   /* чтоб можно было сделать -  */
        buf_trn-doc.need-incfo      = 0
        buf_trn-doc.need-incorexpfo = 1

      .
      end.
     else message error-status :get-message(1) .

define variable col-part as integer no-undo .
define variable vv-sum   as decimal no-undo .
define variable temp1    as integer init 1  no-undo .
      for each buf_parts no-lock where buf_parts.out-code  = buf_incom-trn-doc.doc-code   and
                                       buf_parts.host-code = buf_incom-trn-doc.host-code  and
                                       buf_parts.obj-type  = buf_incom-trn-doc.obj-type   and
                                       buf_parts.obj-code  = buf_incom-trn-doc.obj-code   and
                                       buf_parts.contract-code = n-contract-code
                                             on error undo, return error :

                          vv-sum = vv-sum + buf_parts.fact-qnty * buf_parts.price-rubl.
                          find first buf_goods no-lock where buf_goods.artic     = buf_parts.artic      and
                                                        buf_goods.prod-type = buf_parts.prod-type  and
                                                        buf_goods.prod-code = buf_parts.prod-code no-error .

                          if not can-find (first buf_fin-gds-part no-lock where
                              buf_fin-gds-part.host-code   = buf_parts.host-code and
                              buf_fin-gds-part.fin-ob-code = p-doc-code           and
                              buf_fin-gds-part.obj-type    = buf_parts.obj-type  and
                              buf_fin-gds-part.obj-code    = buf_parts.obj-code  and
                              buf_fin-gds-part.gds-code    = buf_goods.gds-code  and
                              buf_fin-gds-part.in-code     = buf_parts.in-code   and
                              buf_fin-gds-part.part-code   = buf_parts.part-code and
                              buf_fin-gds-part.out-code    = buf_parts.out-code use-index pi )
                          then do:
                           col-part = col-part + 1.
                          if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then
                             run waitfram-show in this-procedure ( "Создано партий : " + string( col-part )) .

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
                            find first tt-allsum where tt-allsum.sum-type = {&sum-general} no-error .

                            create buf_fin-gds-part.
                            BUFFER-COPY buf_parts to buf_fin-gds-part
                            assign
                              buf_fin-gds-part.gds-code           = buf_goods.gds-code
                              buf_fin-gds-part.fin-ob-code        = p-doc-code
                              buf_fin-gds-part.status_dop            = {&fin-gen}
                              buf_fin-gds-part.user-db-num        = g#db-num
                              buf_fin-gds-part.user-name          = g#userid
                              buf_fin-gds-part.doc-qnty           = buf_parts.qnty
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
                          end.
      end. /* buf_parts */


  n-sum-rubl             = vv-sum.
  /*
  n-sum-tax-rubl         =
  */

  n-sum-base             = (  n-base-scale     / n-base-rate ) * n-sum-rubl     .
  n-sum-doc              = (  n-exch-scale     / n-exch-rate ) * n-sum-rubl     .
  n-sum-contract         = (  n-contract-scale / n-contract-rate ) * n-sum-rubl .

  n-sum-doc-orig         = n-sum-doc  .
  n-sum-rubl-orig        = n-sum-rubl .
  n-sum-base-orig        = n-sum-base .

  n-sum-tax-base         = (  n-base-scale     / n-base-rate ) * n-sum-tax-rubl     .
  n-sum-tax-doc          = (  n-exch-scale     / n-exch-rate ) * n-sum-tax-rubl     .
  n-sum-tax-contract     = (  n-contract-scale / n-contract-rate ) * n-sum-tax-rubl .

      run create-fin-liab in this-procedure (
        input yes ,
        input p-doc-code            ,
        input date(cur-time-date()) ,
        input n-doc-type            ,
        input n-payer-name          ,
        input n-receiver-name       ,
        input n-curr-code           ,
        input n-sum-doc             ,
        input n-user-db-num-doc     ,
        input n-user-name-doc       ,
        input n-base-rate           ,
        input n-base-scale          ,
        input n-receiver-code       ,
        input n-receiver-type       ,
        input n-contract-code       ,
        input n-exch-rate           ,
        input n-exch-scale          ,
        input n-contract-curr       ,
        input n-contract-rate       ,
        input n-contract-scale      ,
        input n-fact-date           ,
        input n-fact-order          ,
        input par-host-code         ,
        input n-payer-code          ,
        input n-payer-type          ,
        input n-pay-date            ,
        input string(p-doc-code)    ,
        input {&fin-gen}            ,
        input n-sum-base-orig       ,
        input n-sum-base            ,
        input n-sum-doc-orig        ,
        input n-sum-rubl-orig       ,
        input n-sum-rubl            ,
        input n-sum-contract        ,
        input n-trn-doc-code        ,
        input n-user-db-num-fact    ,
        input n-user-db-num-pay        ,
        input n-user-name-fact         ,
        input n-user-name-pay          ,
        input n-in-type                ,
        input n-sum-tax-base           ,
        input n-sum-tax-doc            ,
        input n-sum-tax-rubl           ,
        input n-sum-tax-contract       ,
        input  ""                       ,
        output p-ri )
        no-error .
        if error-status :error then
        message vss-workfile vss-revision vss-description skip
        error-status :get-message(1)
        1 view-as alert-box error .
         col-part = col-part + 1.
        if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then
           run waitfram-show in this-procedure ( "Создание таблицы налогов " ) .

        run make-tax in this-procedure (
              input p-doc-code ,
              input par-host-code
              )
        no-error .
        if error-status :error then message vss-workfile vss-revision vss-description skip
        error-status :get-message(1)
        2 view-as alert-box error .

        run update-fin-ob_obj in this-procedure
             ( input p-doc-code ,
              input par-host-code
              )
        no-error .
        if error-status :error then message vss-workfile vss-revision vss-description skip
          error-status :get-message(1)
          3 view-as alert-box error .

        /* если есть в договоре условие то закроем на факт */
        run close-fo-fact in this-procedure ( input par-host-code, input p-doc-code ) no-error   .
        if error-status :error then
        message vss-workfile vss-revision vss-description skip
                "Ошибка процедуры закрытия на ФАКТ  (ПФО->ФО->ФАКТ) " skip
                skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error
        .

 end. /* do */
end procedure. /* make-fo */




procedure sum-in-parts :
 do
 on error undo, return error return-value
 :
define input parameter  p-doc-code as character no-undo .
define input parameter  p-contract-code as integer no-undo .
define output parameter p-sum-pn  as decimal init 0 no-undo .

define buffer buf_parts for parts.
define buffer buf_trn-doc for trn-doc.

find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .
for each buf_parts no-lock where buf_parts.contract-code = p-contract-code and
                                 buf_parts.out-code      = buf_trn-doc.doc-code and
                                 buf_parts.obj-code      = buf_trn-doc.obj-code and
                                 buf_parts.obj-type      = buf_trn-doc.obj-type and
                                 buf_parts.host-code     = buf_trn-doc.host-code
    on error undo, return error :
    p-sum-pn = p-sum-pn +  ( buf_parts.fact-qnty * (buf_parts.price-rubl - buf_parts.other-rubl -
                                                                           buf_parts.transport-rubl ))  .

end. /* for each */

 end. /* do */
end procedure. /* sum-in-parts */

procedure close-fo-fact :
define input parameter p-host-code as integer no-undo .
define input parameter p-doc-code  as character no-undo .

 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
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
                "Ошибка закрытия на факт ФО на ПН " skip
                 skip
                 error-status :get-message(1) skip
                 return-value skip
                 view-as alert-box error
         .
         return error .
      end.


      if buf_fact-contract.auto-pay > 1 then do:
         run str/payfoavt.p
            ( input parParentProc, input par-host-code, input recid(buf_fact-fin-ob)) no-error .
         if error-status :error then do:
            message vss-workfile vss-revision vss-description skip
                   "Ошибка автоматического создания платежа . Процедура  payfoavt.p " skip
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

procedure clc-price-tmp :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :


 end. /* do */
end procedure. /* clc-price */