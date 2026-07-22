block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: paypvavt.p $
$Archive: str/paypvavt.p $

Автомат. оплата фин. обязательств

Автор: Чернова Светлана Александровна
Дата создания: 03/23/06
Author: Svetlana Chernova
Creation date: 03/23/06

*/

/* Parameters Definitions ---                                           */

/*  define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.*/
define input  parameter p-host-code    as integer   no-undo . /* надо передавать фирму */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: paypvavt.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/paypvavt.p $":u .
define variable vss-description as character no-undo init "Автомат. оплата фин. обязательств" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ ref/fndocip.i }
{ cmp/library.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ trg/new-bcod.i }

do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:

  DEFINE temp-table temp-cli no-undo
    field   obj-type            as character
    field   obj-code            as integer
    field   obj-name            as character
    INDEX pi  IS PRIMARY obj-type  obj-code
  .
  DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc
    field   str-fo            as character
  .
  DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax
    INDEX pi1 vat-pc slt-pc with-vat with-slt
  .
  define temp-table tt0-payment no-undo like ub.payment.
  DEFINE TEMP-TABLE tt_fin-doc NO-UNDO LIKE ub.fin-doc.
  DEFINE TEMP-TABLE tt0_fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
  DEFINE TEMP-TABLE tt_fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
  DEFINE TEMP-TABLE tt_fin-connect NO-UNDO LIKE ub.fin-connect.

  define stream LogStream.

  define buffer buf_contract for ub.contract .
  define buffer buf_fin-ob for ub.fin-ob .
  define buffer b1_fin-schet for ub.fin-schet .
  define buffer b2_fin-schet for ub.fin-schet .

  define variable f-name as character no-undo .
  define variable g#log  as logical   no-undo .
  define variable s-list as character no-undo .
  define variable v-message-text as character no-undo .
  define variable line as integer initial 1 no-undo .
  define variable v-curr-r-b as integer   no-undo .
  define variable curr-rc    as character no-undo .
  define variable sss    as character no-undo .
  define variable p-sys-time  as character no-undo .
  define variable p-koef-rubl as decimal   no-undo .
  define variable p-koef-base as decimal   no-undo .
  define variable p-koef-cont as decimal   no-undo .
  define variable p-koef-doc  as decimal   no-undo .
  define variable v-err as logical   no-undo .

  assign
    v-message-text = "paypvavt.log"
    f-name = "default.cli"
    g#log = yes
  .
  system-dialog get-file f-name
          filters "Списки клиентов *.cli" "*.cli"
          use-filename
          update g#log
          default-extension "cli".
  if not g#log then return  error .
  input from value (f-name).
  REPEAT :
     CREATE temp-cli.
     IMPORT temp-cli.obj-type temp-cli.obj-code NO-ERROR.
     IF ERROR-STATUS :ERROR THEN DO:
       DELETE temp-cli.
       UNDO, NEXT.
     END.
     find first ub.clients no-lock where ub.clients.obj-type = temp-cli.obj-type and ub.clients.obj-code = temp-cli.obj-code no-error .
     assign
       temp-cli.obj-name = ub.clients.obj-name
       s-list = s-list + {&new-line} + temp-cli.obj-type + ' ' + string(temp-cli.obj-code) + '  ' + ub.clients.obj-name
     .
  END.
  input close.

  define variable choice as integer   no-undo .
  run gbl/d-askw.w (input "Автоматическая оплата по списку клиентов",
                input ("Выбраны клиенты :" + s-list ),
                input "|",
                input "Совокупный платеж по договору|Раздельные платежи по ФО|Отказ",
                input "||",
                input 1,
                input 3,
                output choice).

  if choice <> 3 then do:
    run waitfram-show("Ждите...").

    os-delete VALUE(v-message-text).
    output to value (v-message-text).
    OUTPUT CLOSE.

    { gbl/basecode.i p-host-code v-curr-r-b }
    find first ub.sysconf no-lock      where ub.sysconf.host-code = p-host-code .
    find first ub.firm no-lock         where ub.firm.firm-code    = p-host-code .

    case choice :
      when 2 then run pay-fin-fo . /* Раздельные платежи по ФО */
      when 1 then run pay-contract . /* Совокупный платеж по договору */
    end.

    OUTPUT CLOSE.
    run waitfram-hide.

    run gbl/prnfilen.w (
      input  "Результат создания платежей",
      input  0,
      input  v-message-text,
      input  7,
      output sss,
      output g#log
      ).
  end.
  else return  error .
end.

procedure pay-fin-fo :
define variable v-fd-code as integer no-undo .
  do  on error undo, return error return-value  :
    for each temp-cli, each buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.cli-type = temp-cli.obj-type and buf_contract.cli-code = temp-cli.obj-code :
      for each buf_fin-ob no-lock
        where buf_fin-ob.host-code     = p-host-code
          and buf_fin-ob.contract-code = buf_contract.contract-code
          and buf_fin-ob.doc-type      = {&expense}
          and buf_fin-ob.status_       =  {&fact}
          and buf_fin-ob.con-stat      < 2
        :
        assign v-err = no .
        run gen-b-code in this-procedure ( input {&gbl-fd-code}
                                        , output v-fd-code) no-error .
        if error-status:error then do:
          define variable v-mess as character no-undo .
          v-mess = substitute("Ошибка при генерации внутреннего номера фин. док-та&1" +
                                "Вн.№ договора &1  ФО №  &2  от &3:&1&4&1&5"
                                , buf_contract.contract-code
                                , buf_fin-ob.prn-doc-code
                                , buf_fin-ob.doc-date
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
          if error-status:error then do:
            output stream LogStream to Value(v-message-text) append.
            put stream Logstream unformatted
            v-mess skip.
            output stream LogStream close.
          end.
          undo, return error.
        end.
        create tt-fin-doc .
        assign
          tt-fin-doc.host-code       = p-host-code
          tt-fin-doc.fin-doc-code    = v-fd-code
          tt-fin-doc.base-rate       = buf_fin-ob.base-rate
          tt-fin-doc.base-scale      = buf_fin-ob.base-scale
          tt-fin-doc.contract-code   = buf_fin-ob.contract-code
          tt-fin-doc.contract-curr   = buf_fin-ob.contract-curr
          tt-fin-doc.contract-rate   = buf_fin-ob.contract-rate
          tt-fin-doc.contract-scale  = buf_fin-ob.contract-scale
          tt-fin-doc.curr-code       = buf_fin-ob.curr-code
          tt-fin-doc.obj-code        = buf_fin-ob.obj-code
          tt-fin-doc.obj-type        = buf_fin-ob.obj-type
          tt-fin-doc.doc-date        = today
          tt-fin-doc.exch-rate       = buf_fin-ob.exch-rate
          tt-fin-doc.exch-scale      = buf_fin-ob.exch-scale
          tt-fin-doc.PS              = ""
          tt-fin-doc.ocher-pl        = "6"
          tt-fin-doc.stat-pl         = ""
          tt-fin-doc.naznach-plat    = "Оплата по договору № " + buf_contract.contract-prn-code + " от " + string( buf_contract.contract-date,"99/99/9999")
          tt-fin-doc.payer-name      = buf_fin-ob.payer-name
          tt-fin-doc.payer-code      = buf_fin-ob.payer-code
          tt-fin-doc.payer-type      = buf_fin-ob.payer-type
          tt-fin-doc.receiver-code   = buf_fin-ob.receiver-code
          tt-fin-doc.receiver-name   = buf_fin-ob.receiver-name
          tt-fin-doc.receiver-type   = buf_fin-ob.receiver-type
          tt-fin-doc.prn-doc-code    = string(tt-fin-doc.fin-doc-code)
          tt-fin-doc.sum-doc         = buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc
          tt-fin-doc.sum-base        = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
          tt-fin-doc.sum-rubl        = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
          tt-fin-doc.sum-contr       = buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr
          p-koef-rubl                = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl ) / buf_fin-ob.sum-rubl
          p-koef-base                = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-base ) / buf_fin-ob.sum-rubl
          p-koef-cont                = ( buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr) / buf_fin-ob.sum-contract
          p-koef-doc                 = ( buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc  ) / buf_fin-ob.sum-doc
        .
        for each ub.fin-ob-tax no-lock where ub.fin-ob-tax.host-code = p-host-code and ub.fin-ob-tax.doc-code = buf_fin-ob.doc-code :
          create tt0-fin-doc-tax .
          BUFFER-COPY ub.fin-ob-tax TO tt0-fin-doc-tax .
          assign
            tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
            tt0-fin-doc-tax.sum-line-doc       = ROUND(tt0-fin-doc-tax.sum-line-doc       , 2)  * p-koef-doc
            tt0-fin-doc-tax.sum-vat-line-doc   = ROUND(tt0-fin-doc-tax.sum-vat-line-doc   , 2)  * p-koef-doc
            tt0-fin-doc-tax.sum-slt-line-doc   = ROUND(tt0-fin-doc-tax.sum-slt-line-doc   , 2)  * p-koef-doc
            tt0-fin-doc-tax.sum-line-rubl      = ROUND(tt0-fin-doc-tax.sum-line-rubl      , 2)  * p-koef-rubl
            tt0-fin-doc-tax.sum-vat-line-rubl  = ROUND(tt0-fin-doc-tax.sum-vat-line-rubl  , 2)  * p-koef-rubl
            tt0-fin-doc-tax.sum-slt-line-rubl  = ROUND(tt0-fin-doc-tax.sum-slt-line-rubl  , 2)  * p-koef-rubl
            tt0-fin-doc-tax.sum-line-base      = ROUND(tt0-fin-doc-tax.sum-line-base      , 2)  * p-koef-base
            tt0-fin-doc-tax.sum-vat-line-base  = ROUND(tt0-fin-doc-tax.sum-vat-line-base  , 2)  * p-koef-base
            tt0-fin-doc-tax.sum-slt-line-base  = ROUND(tt0-fin-doc-tax.sum-slt-line-base  , 2)  * p-koef-base
            tt0-fin-doc-tax.sum-line-contr     = tt0-fin-doc-tax.sum-line-contr      * p-koef-cont
            tt0-fin-doc-tax.sum-vat-line-contr = tt0-fin-doc-tax.sum-vat-line-contr  * p-koef-cont
            tt0-fin-doc-tax.sum-slt-line-contr = tt0-fin-doc-tax.sum-slt-line-contr  * p-koef-cont
/*            tt0-fin-doc-tax.sum-line-contr     = ROUND(tt0-fin-doc-tax.sum-line-contr     , 2)  * p-koef-cont*/
/*            tt0-fin-doc-tax.sum-vat-line-contr = ROUND(tt0-fin-doc-tax.sum-vat-line-contr , 2)  * p-koef-cont*/
/*            tt0-fin-doc-tax.sum-slt-line-contr = ROUND(tt0-fin-doc-tax.sum-slt-line-contr , 2)  * p-koef-cont*/
          .
        end.

        /* анализируем получателя и плательщика */
        run CheckCli no-error .
        if error-status:error then do:
          assign v-err = yes .
          output stream LogStream to Value(v-message-text) append.
          put stream Logstream unformatted
          substitute("Несоответствие плательщика или получателя договору! Вн.№ договора &1  ФО №  &2  от &3", buf_contract.contract-code, buf_fin-ob.prn-doc-code, buf_fin-ob.doc-date) skip.
          output stream LogStream close.
        end.

        run FindBank .

        if buf_contract.pay-nal = no  then do: /* безнал платеж */
/*          if b1_fin-schet.curr-code <> b2_fin-schet.curr-code then return error "Валюта счета плательщика отличается от валюты счета получателя." .*/
          if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&expense-cashless} .
          else                             assign tt-fin-doc.fin-doc-type = {&income-cashless} .
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
            end.
          end.
        end.
        else do: /* наличные или  акт погашения */
          if buf_contract.pay-nal = yes then do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&expense-cash} .
            else                             assign tt-fin-doc.fin-doc-type = {&income-cash} .
          end.
          else do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&expense-payoff} .
            else                             assign tt-fin-doc.fin-doc-type = {&income-payoff} .
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

        if v-err = no then do:
          tt-fin-doc.doc-author = "fin-ob".
          run ref/findoc0.p (
            input-output p-doc-rec
           ,input {&add-def}
           ,input yes /*p-silent*/
           {&all-fin-doc-params-doc-status-transfer}
           {&all-fin-doc-params-doc-status-transfer-2}
           ,input table tt0-fin-doc-tax
           ,input table tt_fin-doc-attr
           ,input no /*p-save-payment*/
           ,input table tt0-payment
           ) no-error .
          if error-status:error then do:
            assign v-err = yes .
            output stream LogStream to Value(v-message-text) append.
            put stream Logstream unformatted
            substitute("Ошибка создания платежа! Вн.№ договора &1  ФО №  &2  от &3&4&5"
                       , buf_contract.contract-code
                       , buf_fin-ob.prn-doc-code
                       , buf_fin-ob.doc-date
                       ,{&new-line}
                       ,substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message (1))
                       ) skip.
            output stream LogStream close.
          end.
        end.

        if v-err = no then do:   /* связываем */
          create ub.fin-connect .
          assign
            ub.fin-connect.connect-code   = next-value( s-fin-connect, {&db-name_schema} )
            ub.fin-connect.host-code      = p-host-code
            ub.fin-connect.fin-doc-code   = tt-fin-doc.fin-doc-code
            ub.fin-connect.fin-ob-code    = buf_fin-ob.doc-code
            ub.fin-connect.contract-code  = buf_fin-ob.contract-code
            ub.fin-connect.curr-code      = buf_fin-ob.curr-code
            ub.fin-connect.base-rate      = buf_fin-ob.base-rate
            ub.fin-connect.base-scale     = buf_fin-ob.base-scale
            ub.fin-connect.contract-curr  = buf_fin-ob.contract-curr
            ub.fin-connect.contract-rate  = buf_fin-ob.contract-rate
            ub.fin-connect.contract-scale = buf_fin-ob.contract-scale
            ub.fin-connect.exch-rate      = buf_fin-ob.exch-rate
            ub.fin-connect.exch-scale     = buf_fin-ob.exch-scale
            ub.fin-connect.status_        = {&current-status}
            ub.fin-connect.sum-rubl-ob    = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
            ub.fin-connect.sum-base-ob    = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
            ub.fin-connect.sum-contr-ob   = buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr
            ub.fin-connect.sum-rubl       = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
            ub.fin-connect.sum-base       = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
            ub.fin-connect.sum-doc        = buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc
            ub.fin-connect.sum-contr      = buf_fin-ob.sum-contr    - buf_fin-ob.con-sum-contr
/*            ub.fin-connect.sum-rubl       = tt-fin-doc.sum-rubl*/
/*            ub.fin-connect.sum-base       = tt-fin-doc.sum-base*/
/*            ub.fin-connect.sum-doc        = tt-fin-doc.sum-doc*/
/*            ub.fin-connect.sum-contr      = tt-fin-doc.sum-contr*/
          .
          { gbl/curdburt.i  ub.fin-connect.user-db-num  ub.fin-connect.user-name  ub.fin-connect.fact-date  p-sys-time  ub.fin-connect.fact-time }
          find first ub.fin-ob exclusive-lock where ub.fin-ob.host-code = p-host-code and ub.fin-ob.doc-code = buf_fin-ob.doc-code .
          assign
            ub.fin-ob.con-sum-doc   = ub.fin-ob.sum-doc
            ub.fin-ob.con-sum-rubl  = ub.fin-ob.sum-rubl
            ub.fin-ob.con-sum-base  = ub.fin-ob.sum-base
            ub.fin-ob.con-sum-contr = ub.fin-ob.sum-contr
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
          output stream LogStream to Value(v-message-text) append.
          put stream Logstream unformatted
          substitute("Успешно создан &1 № &2 ! Вн.№ договора &3  ФО №  &4  от &5", tt-fin-doc.fin-doc-type, tt-fin-doc.prn-doc-code, buf_contract.contract-code, buf_fin-ob.prn-doc-code, buf_fin-ob.doc-date) skip.
          output stream LogStream close.
        end.
      end.
    end.
  end.
end procedure. /* pay-fin-fo */



procedure pay-contract :
define variable v-fd-code as integer no-undo .
  do on error undo, return error return-value :
    for each temp-cli, each buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.cli-type = temp-cli.obj-type and buf_contract.cli-code = temp-cli.obj-code :
      for each buf_fin-ob no-lock
        where buf_fin-ob.host-code     = p-host-code
          and buf_fin-ob.contract-code = buf_contract.contract-code
          and buf_fin-ob.doc-type      = {&expense}
          and buf_fin-ob.status_       =  {&fact}
          and buf_fin-ob.con-stat      < 2
        :
        assign v-err = no .

        if ub.sysconf.fin-calc = {&fin-calc-obj} then do:
          find first tt-fin-doc
            where tt-fin-doc.contract-code = buf_fin-ob.contract-code
              and tt-fin-doc.obj-type      = buf_fin-ob.obj-type
              and tt-fin-doc.obj-code      = buf_fin-ob.obj-code
          no-error .
        end.
        else do:
          find first tt-fin-doc where tt-fin-doc.contract-code = buf_contract.contract-code no-error .
        end.

        if not available tt-fin-doc then do:
          run gen-b-code in this-procedure ( input {&gbl-fd-code}
                                          , output v-fd-code) no-error .
          if error-status:error then do:
            define variable v-mess as character no-undo .
            v-mess = substitute("Ошибка при генерации внутреннего номера фин. док-та&1" +
                                 "Вн.№ договора &1  ФО №  &2  от &3:&1&4&1&5"
                                 , buf_contract.contract-code
                                 , buf_fin-ob.prn-doc-code
                                 , buf_fin-ob.doc-date
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value ).
            if error-status:error then do:
              output stream LogStream to Value(v-message-text) append.
              put stream Logstream unformatted
              v-mess skip.
              output stream LogStream close.
            end.
            undo, return error.
          end.

          create tt-fin-doc .
          assign
            tt-fin-doc.host-code       = p-host-code
            tt-fin-doc.fin-doc-code    = v-fd-code
            tt-fin-doc.prn-doc-code    = string(tt-fin-doc.fin-doc-code)
            tt-fin-doc.contract-code   = buf_fin-ob.contract-code
            tt-fin-doc.contract-curr   = buf_fin-ob.contract-curr
            tt-fin-doc.curr-code       = buf_fin-ob.curr-code
            tt-fin-doc.obj-code        = buf_fin-ob.obj-code
            tt-fin-doc.obj-type        = buf_fin-ob.obj-type
            tt-fin-doc.doc-date        = today
            tt-fin-doc.PS              = ""
            tt-fin-doc.ocher-pl        = "6"
            tt-fin-doc.stat-pl         = ""
            tt-fin-doc.naznach-plat    = "Оплата по договору № " + buf_contract.contract-prn-code + " от " + string( buf_contract.contract-date,"99/99/9999")
            tt-fin-doc.payer-name      = buf_fin-ob.payer-name
            tt-fin-doc.payer-code      = buf_fin-ob.payer-code
            tt-fin-doc.payer-type      = buf_fin-ob.payer-type
            tt-fin-doc.receiver-code   = buf_fin-ob.receiver-code
            tt-fin-doc.receiver-name   = buf_fin-ob.receiver-name
            tt-fin-doc.receiver-type   = buf_fin-ob.receiver-type
            tt-fin-doc.sum-base        = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
            tt-fin-doc.sum-rubl        = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
            tt-fin-doc.sum-contr       = buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr
            tt-fin-doc.sum-doc         = buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc
            tt-fin-doc.base-scale      = buf_fin-ob.base-scale
            tt-fin-doc.contract-scale  = buf_fin-ob.contract-scale
            tt-fin-doc.exch-scale      = buf_fin-ob.exch-scale
            p-koef-rubl                = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl ) / buf_fin-ob.sum-rubl
            p-koef-base                = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-base ) / buf_fin-ob.sum-rubl
            p-koef-cont                = ( buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr) / buf_fin-ob.sum-contract
            p-koef-doc                 = ( buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc  ) / buf_fin-ob.sum-doc
          .

          /* анализируем получателя и плательщика */
          run CheckCli no-error .
          if error-status:error then do:
            output stream LogStream to Value(v-message-text) append.
            put stream Logstream unformatted
            substitute("Несоответствие плательщика или получателя договору! Вн.№ договора &1  ФО №  &2  от &3", buf_contract.contract-code, buf_fin-ob.prn-doc-code, buf_fin-ob.doc-date) skip.
            output stream LogStream close.
          end.
        end.
        else do: /* не первое фин.об. в платеже */
          assign
            tt-fin-doc.sum-base  = tt-fin-doc.sum-base  + buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
            tt-fin-doc.sum-rubl  = tt-fin-doc.sum-rubl  + buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
            tt-fin-doc.sum-contr = tt-fin-doc.sum-contr + buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr
            tt-fin-doc.sum-doc   = tt-fin-doc.sum-doc   + buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc
            p-koef-rubl          = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl ) / buf_fin-ob.sum-rubl
            p-koef-base          = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-base ) / buf_fin-ob.sum-rubl
            p-koef-cont          = ( buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr) / buf_fin-ob.sum-contract
            p-koef-doc           = ( buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc  ) / buf_fin-ob.sum-doc
          .
          if tt-fin-doc.obj-code <> buf_fin-ob.obj-code or tt-fin-doc.obj-type <> buf_fin-ob.obj-type then assign tt-fin-doc.obj-type = "" tt-fin-doc.obj-code = 0 .
        end.
        if tt-fin-doc.str-fo <> "" then assign tt-fin-doc.str-fo = tt-fin-doc.str-fo + ", "  .
        assign tt-fin-doc.str-fo = tt-fin-doc.str-fo + string(buf_fin-ob.doc-code) .

        for each ub.fin-ob-tax no-lock where ub.fin-ob-tax.host-code = p-host-code and ub.fin-ob-tax.doc-code = buf_fin-ob.doc-code :
          find first tt0-fin-doc-tax
            where tt0-fin-doc-tax.vat-pc       = ub.fin-ob-tax.vat-pc
              and tt0-fin-doc-tax.slt-pc       = ub.fin-ob-tax.slt-pc
              and tt0-fin-doc-tax.with-vat     = ub.fin-ob-tax.with-vat
              and tt0-fin-doc-tax.with-slt     = ub.fin-ob-tax.with-slt
              and tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
          no-error .

          if not available tt0-fin-doc-tax then do:
            create tt0-fin-doc-tax .
            BUFFER-COPY ub.fin-ob-tax TO tt0-fin-doc-tax .
            assign
              tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
              tt0-fin-doc-tax.host-code    = p-host-code
              tt0-fin-doc-tax.line-num     = line
              line = line + 1
              tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-doc       * p-koef-doc
              tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-doc   * p-koef-doc
              tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-doc   * p-koef-doc
              tt0-fin-doc-tax.sum-line-rubl      = tt0-fin-doc-tax.sum-line-rubl      * p-koef-rubl
              tt0-fin-doc-tax.sum-vat-line-rubl  = tt0-fin-doc-tax.sum-vat-line-rubl  * p-koef-rubl
              tt0-fin-doc-tax.sum-slt-line-rubl  = tt0-fin-doc-tax.sum-slt-line-rubl  * p-koef-rubl
              tt0-fin-doc-tax.sum-line-base      = tt0-fin-doc-tax.sum-line-base      * p-koef-base
              tt0-fin-doc-tax.sum-vat-line-base  = tt0-fin-doc-tax.sum-vat-line-base  * p-koef-base
              tt0-fin-doc-tax.sum-slt-line-base  = tt0-fin-doc-tax.sum-slt-line-base  * p-koef-base
              tt0-fin-doc-tax.sum-line-contr     = tt0-fin-doc-tax.sum-line-contr     * p-koef-cont
              tt0-fin-doc-tax.sum-vat-line-contr = tt0-fin-doc-tax.sum-vat-line-contr * p-koef-cont
              tt0-fin-doc-tax.sum-slt-line-contr = tt0-fin-doc-tax.sum-slt-line-contr * p-koef-cont
            .
          end.
          else do:
            assign
              tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-doc       + ub.fin-ob-tax.sum-line-doc       * p-koef-doc
              tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-doc   + ub.fin-ob-tax.sum-vat-line-doc   * p-koef-doc
              tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-doc   + ub.fin-ob-tax.sum-slt-line-doc   * p-koef-doc
              tt0-fin-doc-tax.sum-line-rubl      = tt0-fin-doc-tax.sum-line-rubl      + ub.fin-ob-tax.sum-line-rubl      * p-koef-rubl
              tt0-fin-doc-tax.sum-vat-line-rubl  = tt0-fin-doc-tax.sum-vat-line-rubl  + ub.fin-ob-tax.sum-vat-line-rubl  * p-koef-rubl
              tt0-fin-doc-tax.sum-slt-line-rubl  = tt0-fin-doc-tax.sum-slt-line-rubl  + ub.fin-ob-tax.sum-slt-line-rubl  * p-koef-rubl
              tt0-fin-doc-tax.sum-line-base      = tt0-fin-doc-tax.sum-line-base      + ub.fin-ob-tax.sum-line-base      * p-koef-base
              tt0-fin-doc-tax.sum-vat-line-base  = tt0-fin-doc-tax.sum-vat-line-base  + ub.fin-ob-tax.sum-vat-line-base  * p-koef-base
              tt0-fin-doc-tax.sum-slt-line-base  = tt0-fin-doc-tax.sum-slt-line-base  + ub.fin-ob-tax.sum-slt-line-base  * p-koef-base
              tt0-fin-doc-tax.sum-line-contr     = tt0-fin-doc-tax.sum-line-contr     + ub.fin-ob-tax.sum-line-contr     * p-koef-cont
              tt0-fin-doc-tax.sum-vat-line-contr = tt0-fin-doc-tax.sum-vat-line-contr + ub.fin-ob-tax.sum-vat-line-contr * p-koef-cont
              tt0-fin-doc-tax.sum-slt-line-contr = tt0-fin-doc-tax.sum-slt-line-contr + ub.fin-ob-tax.sum-slt-line-contr * p-koef-cont
            .
          end.
        end.
        create tt_fin-connect .
        assign
         tt_fin-connect.connect-code   = next-value( s-fin-connect, {&db-name_schema} )
         tt_fin-connect.host-code      = p-host-code
         tt_fin-connect.fin-doc-code   = tt-fin-doc.fin-doc-code
         tt_fin-connect.fin-ob-code    = buf_fin-ob.doc-code
         tt_fin-connect.contract-code  = buf_fin-ob.contract-code
         tt_fin-connect.curr-code      = buf_fin-ob.curr-code
         tt_fin-connect.base-rate      = buf_fin-ob.base-rate
         tt_fin-connect.base-scale     = buf_fin-ob.base-scale
         tt_fin-connect.contract-curr  = buf_fin-ob.contract-curr
         tt_fin-connect.contract-rate  = buf_fin-ob.contract-rate
         tt_fin-connect.contract-scale = buf_fin-ob.contract-scale
         tt_fin-connect.exch-rate      = buf_fin-ob.exch-rate
         tt_fin-connect.exch-scale     = buf_fin-ob.exch-scale
         tt_fin-connect.status_        = {&current-status}
         tt_fin-connect.sum-rubl-ob    = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
         tt_fin-connect.sum-base-ob    = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
         tt_fin-connect.sum-contr-ob   = buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr
         tt_fin-connect.sum-rubl       = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
         tt_fin-connect.sum-base       = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
         tt_fin-connect.sum-doc        = buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc
         tt_fin-connect.sum-contr      = buf_fin-ob.sum-contr    - buf_fin-ob.con-sum-contr
/*         tt_fin-connect.sum-rubl       = tt-fin-doc.sum-rubl*/
/*         tt_fin-connect.sum-base       = tt-fin-doc.sum-base*/
/*         tt_fin-connect.sum-doc        = tt-fin-doc.sum-doc*/
/*         tt_fin-connect.sum-contr      = tt-fin-doc.sum-contr*/
         tt_fin-connect.user-db-num = 0
       .
      end.
    end.

    for each tt-fin-doc :
      find first buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.contract-code = tt-fin-doc.contract-code .
      run FindBank .
      /* посчитаем курсы по факту */
      assign
        tt-fin-doc.base-rate       = if tt-fin-doc.sum-base  <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.base-scale / tt-fin-doc.sum-base      else 0
        tt-fin-doc.contract-rate   = if tt-fin-doc.sum-contr <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.contract-scale / tt-fin-doc.sum-contr else 0
        tt-fin-doc.exch-rate       = if tt-fin-doc.sum-doc   <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.sum-doc       else 0
      .
      /* ecли вал сета <> р_у_бл, б.в. или вал дог, то считаем */
      find first ub.currency no-lock where ub.currency.curr-code = b2_fin-schet.curr-code .
      assign  curr-rc = ub.currency.curr-abbr  .
      if buf_contract.pay-nal = no then do:

        if buf_contract.doc-type = {&income} then do:
          if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&expense-cashless} .
          else                           assign tt-fin-doc.fin-doc-type = {&income-cashless} .
        end.
        else do:
          if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&income-cashless} .
          else                           assign tt-fin-doc.fin-doc-type = {&expense-cashless} .
        end.

        assign tt-fin-doc.curr-code = b2_fin-schet.curr-code  .
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
          end.
        end.
      end.
      else do: /* наличные или  акт погашения */
        if buf_contract.pay-nal = yes then do:
          if buf_contract.doc-type = {&income} then do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&expense-cash} .
            else                           assign tt-fin-doc.fin-doc-type = {&income-cash} .
          end.
          else do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&income-cash} .
            else                           assign tt-fin-doc.fin-doc-type = {&expense-cash} .
          end.
        end.
        else do:
          if buf_contract.doc-type = {&income} then do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&expense-payoff} .
            else                           assign tt-fin-doc.fin-doc-type = {&income-payoff} .
          end.
          else do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = {&income-payoff} .
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

      assign sss = " В т.ч.: "  .
      if buf_contract.pay-nal = no then do:  /* вставляем разбивку по налогам */
        for each tt0-fin-doc-tax where tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code :
          if tt0-fin-doc-tax.with-vat = no then next.
          if sss <> " В т.ч.: " then sss = sss + "," .
          if tt-fin-doc.curr-code = 0 then assign sss = sss + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " {&abbr_rub}. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
          else                             assign sss = sss + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
        end.
        if sss = " В т.ч.: " then assign sss = "" .
        assign tt-fin-doc.naznach-plat = tt-fin-doc.naznach-plat + "@" + sss .
      end.
      else if buf_contract.pay-nal = yes then do:
        for each tt0-fin-doc-tax where tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code :
          if tt0-fin-doc-tax.with-vat = no then next.
          if sss <> " В т.ч.: " then sss = sss + "," .
          if tt-fin-doc.curr-code = 0 then assign sss = sss + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " {&abbr_rub}. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
          else                             assign sss = sss + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
        end.
        if sss = " В т.ч.: " then assign sss = "" .
        assign tt-fin-doc.including = sss .
      end.

      run UchetCode .

      define variable p-doc-rec as recid no-undo.

      /* теперь копируем в новый буфер и записываем */

/*      create tt_fin-doc .*/
      BUFFER-COPY tt-fin-doc TO tt_fin-doc .

      for each tt0_fin-doc-tax :
        delete tt0_fin-doc-tax.
      end.

      assign line = 1 .
      for each tt0-fin-doc-tax where tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code :
        create tt0_fin-doc-tax .
        BUFFER-COPY tt0-fin-doc-tax TO tt0_fin-doc-tax .
        assign
          tt0_fin-doc-tax.line-num     = line
          line = line + 1
        .
      end.
      &scop prfx tt_fin-doc.

      run ref/findoc0.p (
        input-output p-doc-rec
       ,input {&add-def}
       ,input yes /*p-silent*/
       {&all-fin-doc-params-doc-status-transfer}
       {&all-fin-doc-params-doc-status-transfer-2}
       ,input table tt0_fin-doc-tax
       ,input table tt_fin-doc-attr
       ,input no /*p-save-payment*/
       ,input table tt0-payment
       ) no-error .
     if error-status:error then do:
       assign v-err = yes .
       output stream LogStream to Value(v-message-text) append.
       put stream Logstream unformatted
         substitute("Ошибка создания платежа! Вн.№ договора &1  ФО &2&3&4"
                    , tt-fin-doc.contract-code
                    , tt-fin-doc.str-fo
                    , {&new-line}
                    ,substitute( "&1&2&3", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
                    ) skip.
       output stream LogStream close.
     end.

     if v-err = no then do:   /* связываем */
       for each tt_fin-connect where tt_fin-connect.fin-doc-code = tt-fin-doc.fin-doc-code :
         create ub.fin-connect .
         BUFFER-COPY tt_fin-connect TO ub.fin-connect .
         { gbl/curdburt.i  ub.fin-connect.user-db-num  ub.fin-connect.user-name  ub.fin-connect.fact-date  p-sys-time  ub.fin-connect.fact-time }
         find first ub.fin-ob exclusive-lock where ub.fin-ob.host-code = p-host-code and ub.fin-ob.doc-code = ub.fin-connect.fin-ob-code .
         assign
           ub.fin-ob.con-sum-doc   = ub.fin-ob.sum-doc
           ub.fin-ob.con-sum-rubl  = ub.fin-ob.sum-rubl
           ub.fin-ob.con-sum-base  = ub.fin-ob.sum-base
           ub.fin-ob.con-sum-contr = ub.fin-ob.sum-contr
           ub.fin-ob.con-stat      = 2
         .
       end.
       find first ub.fin-doc exclusive-lock where recid(ub.fin-doc) = p-doc-rec .
       assign
         ub.fin-doc.con-sum-rubl  = ub.fin-doc.sum-rubl
         ub.fin-doc.con-sum-base  = ub.fin-doc.sum-base
         ub.fin-doc.con-sum-doc   = ub.fin-doc.sum-doc
         ub.fin-doc.con-sum-contr = ub.fin-doc.sum-contr
         ub.fin-doc.con-stat      = 2
       .
       output stream LogStream to Value(v-message-text) append.
       put stream Logstream unformatted
       substitute("Успешно создан &1 № &2 по фин.об &3 ! Вн.№ договора &4", tt-fin-doc.fin-doc-type, tt-fin-doc.prn-doc-code, tt-fin-doc.str-fo, buf_contract.contract-code) skip.
       output stream LogStream close.
     end.
   end.
  end.
end procedure. /* pay-contract */




{ str/pay-fo.i }