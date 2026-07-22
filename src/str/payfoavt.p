block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: payfoavt.p $
$Archive: str/payfoavt.p $

Автомат. оплата фин. обязательств

Автор: Чернова Светлана Александровна
Дата создания: 03/23/06
Author: Svetlana Chernova
Creation date: 03/23/06

*/
/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code    as integer   no-undo . /* надо передавать фирму */
define input  parameter p-ri as recid no-undo .

define variable  vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable  vss-author      as character no-undo init "$Author: expertek $":u .
define variable  vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable  vss-workfile    as character no-undo init "$Workfile: payfoavt.p $":u .
define variable  vss-archive     as character no-undo init "$Archive: str/payfoavt.p $":u .
define variable  vss-description as character no-undo init "Автомат. оплата фин. обязательств" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ ref/fndocip.i }
{ cmp/library.i }
{ gbl/cur-time.i }
{ trg/new-bcod.i }


do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:

/* Local Variable Definitions ---                                       */
  DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
  DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
  DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax
    INDEX pi1 vat-pc slt-pc with-vat with-slt
  .
  define temp-table tt0-payment no-undo like ub.payment.

  define buffer b_fin-ob for ub.fin-ob .
  define buffer buf_contract for ub.contract .
  define buffer b1_fin-schet for ub.fin-schet .
  define buffer b2_fin-schet for ub.fin-schet .

{ str/pay-fo.i }
/* Temp-Table and Buffer definitions                                    */

  define variable line as integer initial 1 no-undo .
  define variable v-curr-r-b as integer   no-undo .
  define variable curr-rc    as character no-undo .
  define variable sss    as character no-undo .
  define variable p-sys-time  as character no-undo .
  define variable v-fd-code as integer no-undo .
  { gbl/basecode.i p-host-code v-curr-r-b }

  find first b_fin-ob no-lock     where recid(b_fin-ob) = p-ri .
  find first ub.sysconf no-lock      where ub.sysconf.host-code = p-host-code .
  find first ub.firm no-lock         where ub.firm.firm-code    = p-host-code .
  find first buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.contract-code = b_fin-ob.contract-code no-error .
  run gen-b-code in this-procedure ( input {&gbl-fd-code}
                                  , output v-fd-code) no-error .
  if error-status:error then do:
    define variable v-mess as character no-undo .
    v-mess = substitute("Ошибка при генерации внутреннего номера фин. док-та:&1&2&1&3"
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).

    undo, return error v-mess.
  end.
  create tt-fin-doc .
  assign
    tt-fin-doc.host-code       = p-host-code
    tt-fin-doc.fin-doc-code    = v-fd-code
    tt-fin-doc.base-rate       = b_fin-ob.base-rate
    tt-fin-doc.base-scale      = b_fin-ob.base-scale
    tt-fin-doc.contract-code   = b_fin-ob.contract-code
    tt-fin-doc.contract-curr   = b_fin-ob.contract-curr
    tt-fin-doc.contract-rate   = b_fin-ob.contract-rate
    tt-fin-doc.contract-scale  = b_fin-ob.contract-scale
    tt-fin-doc.curr-code       = b_fin-ob.curr-code
    tt-fin-doc.obj-code        = b_fin-ob.obj-code
    tt-fin-doc.obj-type        = b_fin-ob.obj-type
    tt-fin-doc.doc-date        = today
    tt-fin-doc.exch-rate       = b_fin-ob.exch-rate
    tt-fin-doc.exch-scale      = b_fin-ob.exch-scale
    tt-fin-doc.PS              = ""
    tt-fin-doc.ocher-pl        = "6"
    tt-fin-doc.stat-pl         = ""
    tt-fin-doc.naznach-plat    = "Оплата по договору № " + buf_contract.contract-prn-code + " от " + string( buf_contract.contract-date,"99/99/9999")
    tt-fin-doc.payer-name      = b_fin-ob.payer-name
    tt-fin-doc.payer-code      = b_fin-ob.payer-code
    tt-fin-doc.payer-type      = b_fin-ob.payer-type
    tt-fin-doc.receiver-code   = b_fin-ob.receiver-code
    tt-fin-doc.receiver-name   = b_fin-ob.receiver-name
    tt-fin-doc.receiver-type   = b_fin-ob.receiver-type
    tt-fin-doc.prn-doc-code    = string(tt-fin-doc.fin-doc-code)
    tt-fin-doc.sum-doc         = b_fin-ob.sum-doc
    tt-fin-doc.sum-base        = b_fin-ob.sum-base
    tt-fin-doc.sum-rubl        = b_fin-ob.sum-rubl
    tt-fin-doc.sum-contr       = b_fin-ob.sum-contract
  .
  for each ub.fin-ob-tax no-lock where ub.fin-ob-tax.host-code = p-host-code and ub.fin-ob-tax.doc-code = b_fin-ob.doc-code :
    create tt0-fin-doc-tax .
    BUFFER-COPY ub.fin-ob-tax TO tt0-fin-doc-tax .
    assign
      tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
      tt0-fin-doc-tax.line-num = line
      line = line + 1
      tt0-fin-doc-tax.sum-line-doc       =  ROUND( tt0-fin-doc-tax.sum-line-doc      , 2)
      tt0-fin-doc-tax.sum-vat-line-doc   =  ROUND( tt0-fin-doc-tax.sum-vat-line-doc  , 2)
      tt0-fin-doc-tax.sum-line-rubl      =  ROUND( tt0-fin-doc-tax.sum-line-rubl     , 2)
      tt0-fin-doc-tax.sum-vat-line-rubl  =  ROUND( tt0-fin-doc-tax.sum-vat-line-rubl , 2)
      tt0-fin-doc-tax.sum-line-base      =  ROUND( tt0-fin-doc-tax.sum-line-base     , 2)
      tt0-fin-doc-tax.sum-vat-line-base  =  ROUND( tt0-fin-doc-tax.sum-vat-line-base , 2)
      tt0-fin-doc-tax.sum-line-contr     =  tt0-fin-doc-tax.sum-line-contr
      tt0-fin-doc-tax.sum-vat-line-contr =  tt0-fin-doc-tax.sum-vat-line-contr
    .
  end.

  /* анализируем получателя и плательщика */
  run CheckCli no-error .
  if error-status:error then do:
    return error string("Несоответствие плательщика или получателя договору!. Вн.н. договора " + string(b_fin-ob.contract-code) + " ,вн.н. фин.об. " + string(b_fin-ob.doc-code)) .
  end.

  run FindBank .

  if buf_contract.pay-nal = no  then do: /* безнал платеж */
    if available b1_fin-schet and available b2_fin-schet then do: if b1_fin-schet.curr-code <> b2_fin-schet.curr-code then return error "Валюта счета плательщика отличается от валюты счета получателя." . end.
    else  return error string("Не найден счет плательщика или счет получателя. Вн.н. договора " + string(b_fin-ob.contract-code) + " ,вн.н. фин.об. " + string(b_fin-ob.doc-code))  .

    if buf_contract.doc-type = {&income} then do:
      if tt-fin-doc.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&expense-cashless} .
      else                           assign tt-fin-doc.fin-doc-type = {&income-cashless} .
    end.
    else do:
      if tt-fin-doc.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&income-cashless} .
      else                           assign tt-fin-doc.fin-doc-type = {&expense-cashless} .
    end.

    /* ecли вал счета <> р_у_бл, б.в. или вал дог  и надо б.н. , то считаем*/
    find first ub.currency no-lock where ub.currency.curr-code = b2_fin-schet.curr-code .
    assign tt-fin-doc.curr-code = b2_fin-schet.curr-code .

    case b2_fin-schet.curr-code :
      when 0 then do:
        assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl .
        for each tt0-fin-doc-tax no-lock :
          assign
            tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-rubl
            tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-rubl
            tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-rubl
          .
        end.
      end.
      when v-curr-r-b then do:
        assign tt-fin-doc.sum-doc = tt-fin-doc.sum-base .
        for each tt0-fin-doc-tax no-lock :
          assign
            tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-base
            tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-base
            tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-base
          .
        end.
      end.
      when buf_contract.curr-code then do:
        assign tt-fin-doc.sum-doc = tt-fin-doc.sum-contr .
        for each tt0-fin-doc-tax no-lock :
          assign
            tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-contr
            tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-contr
            tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-contr
          .
        end.
      end.
      otherwise do:
        { gbl/exchrate.i  b2_fin-schet.curr-code today tt-fin-doc.exch-rate tt-fin-doc.exch-scale curr-rc }
        assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.exch-rate .
        for each tt0-fin-doc-tax :
          assign
            tt0-fin-doc-tax.sum-line-doc       =  tt0-fin-doc-tax.sum-line-rubl      * tt-fin-doc.exch-scale / tt-fin-doc.exch-rate
            tt0-fin-doc-tax.sum-vat-line-doc   =  tt0-fin-doc-tax.sum-vat-line-rubl  * tt-fin-doc.exch-scale / tt-fin-doc.exch-rate
          .
        end.
      end.
    end.
  end.
  else do: /* наличные или  акт погашения */
    if buf_contract.pay-nal = yes then do:
      if buf_contract.doc-type = {&income} then do:
        if tt-fin-doc.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&expense-cash} .
        else                           assign tt-fin-doc.fin-doc-type = {&income-cash} .
      end.
      else do:
        if tt-fin-doc.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&income-cash} .
        else                           assign tt-fin-doc.fin-doc-type = {&expense-cash} .
      end.
    end.
    else do:
      if buf_contract.doc-type = {&income} then do:
        if tt-fin-doc.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&expense-payoff} .
        else                           assign tt-fin-doc.fin-doc-type = {&income-payoff} .
      end.
      else do:
        if tt-fin-doc.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&income-payoff} .
        else                           assign tt-fin-doc.fin-doc-type = {&expense-payoff} .
      end.
    end.
    assign
      tt-fin-doc.receiver-code-schet = 0
      tt-fin-doc.receiver-bank-name  = ""
      tt-fin-doc.receiver-c-schet    = ""
      tt-fin-doc.receiver-r-schet    = ""
      tt-fin-doc.payer-code-schet = 0
      tt-fin-doc.payer-bank-name  = ""
      tt-fin-doc.payer-c-schet    = ""
      tt-fin-doc.payer-r-schet    = ""
    .
  end.
  assign tt-fin-doc.fin-ext-doc-type = tt-fin-doc.fin-doc-type .

  if tt-fin-doc.sum-contr < 0 then do: /* надо перевернуть плател-получателя */
    assign
      tt-fin-doc.payer-sign1        = ub.firm.director
      tt-fin-doc.payer-sign2        = ub.sysconf.snr-accnt
      tt-fin-doc.payer-sign3        = ub.sysconf.cashier
    .
    run InvertCli .
  end.
  else
    assign
      tt-fin-doc.receiver-sign1        = ub.firm.director
      tt-fin-doc.receiver-sign2        = ub.sysconf.snr-accnt
      tt-fin-doc.receiver-sign3        = ub.sysconf.cashier
    .

  if buf_contract.pay-nal = no then do:  /* вставляем разбивку по налогам */
    run StrTax (input-output sss) .
    assign tt-fin-doc.naznach-plat = tt-fin-doc.naznach-plat + "@" + sss .
  end.
  else if buf_contract.pay-nal = yes then do:
    run StrTax (input-output tt-fin-doc.including) .
  end.

  define variable p-doc-rec as recid no-undo.

  &scop prfx tt-fin-doc.

  run UchetCode .
  tt-fin-doc.doc-author = "fin-ob".
  run ref/findoc0.p (
      input-output p-doc-rec
     ,input {&add-def}
     ,input no /*p-silent*/
     {&all-fin-doc-params-doc-status-transfer}
     {&all-fin-doc-params-doc-status-transfer-2}
     ,input table tt0-fin-doc-tax
     ,input table tt0-fin-doc-attr
     ,input no /*p-save-payment*/
     ,input table tt0-payment
   ) no-error .
  if error-status:error then do:
    undo, return error substitute("Вн.N договора &1 , вн.N ФО &2 &3 &4 " , b_fin-ob.contract-code , b_fin-ob.doc-cod , return-value , error-status :get-message(1) ) .
  end.


  /* связываем */
  create ub.fin-connect .
  assign
    ub.fin-connect.connect-code   = next-value( s-fin-connect, {&db-name_schema} )
    ub.fin-connect.host-code      = p-host-code
    ub.fin-connect.fin-doc-code   = tt-fin-doc.fin-doc-code
    ub.fin-connect.fin-ob-code    = b_fin-ob.doc-code
    ub.fin-connect.contract-code  = b_fin-ob.contract-code
    ub.fin-connect.curr-code      = b_fin-ob.curr-code
    ub.fin-connect.base-rate      = b_fin-ob.base-rate
    ub.fin-connect.base-scale     = b_fin-ob.base-scale
    ub.fin-connect.contract-curr  = b_fin-ob.contract-curr
    ub.fin-connect.contract-rate  = b_fin-ob.contract-rate
    ub.fin-connect.contract-scale = b_fin-ob.contract-scale
    ub.fin-connect.exch-rate      = b_fin-ob.exch-rate
    ub.fin-connect.exch-scale     = b_fin-ob.exch-scale
    ub.fin-connect.status_        = {&current-status}
    ub.fin-connect.sum-rubl-ob    = b_fin-ob.sum-rubl
    ub.fin-connect.sum-base-ob    = b_fin-ob.sum-base
    ub.fin-connect.sum-contr-ob   = b_fin-ob.sum-contract
    ub.fin-connect.sum-rubl       = b_fin-ob.sum-rubl
    ub.fin-connect.sum-base       = b_fin-ob.sum-base
    ub.fin-connect.sum-doc        = b_fin-ob.sum-doc
    ub.fin-connect.sum-contr      = b_fin-ob.sum-contr
/*    ub.fin-connect.sum-rubl       = tt-fin-doc.sum-rubl*/
/*    ub.fin-connect.sum-base       = tt-fin-doc.sum-base*/
/*    ub.fin-connect.sum-doc        = tt-fin-doc.sum-doc*/
/*    ub.fin-connect.sum-contr      = tt-fin-doc.sum-contr*/
  .
  { gbl/curdburt.i  ub.fin-connect.user-db-num  ub.fin-connect.user-name  ub.fin-connect.fact-date  p-sys-time  ub.fin-connect.fact-time }
  find first ub.fin-ob exclusive-lock where ub.fin-ob.host-code = p-host-code and ub.fin-ob.doc-code = b_fin-ob.doc-code .
  assign
    ub.fin-ob.con-sum-rubl  = ub.fin-connect.sum-rubl-ob
    ub.fin-ob.con-sum-base  = ub.fin-connect.sum-base-ob
    ub.fin-ob.con-sum-contr = ub.fin-connect.sum-contr-ob
    ub.fin-ob.con-sum-doc   = ub.fin-connect.sum-doc
    ub.fin-ob.con-stat      = 2
  .
  find first ub.fin-doc exclusive-lock where recid(ub.fin-doc) = p-doc-rec .
  assign
    ub.fin-doc.con-sum-rubl  = ub.fin-doc.sum-rubl
    ub.fin-doc.con-sum-base  = ub.fin-doc.sum-base
    ub.fin-doc.con-sum-doc   = ub.fin-doc.sum-doc
    ub.fin-doc.con-sum-contr = ub.fin-doc.sum-contr
    ub.fin-doc.con-stat      = 2
  .
end.