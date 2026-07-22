/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток информации о валютах-оплатах - пока только MAGIA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/09/03
Author: Bakhtadze Natalya
Creation date: 12/09/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-curp.
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo.

define buffer buf_clients for ub.clients.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_currency for ub.currency.

/*некий виртуально сконструированный код кассового платежа*/
define variable v-mag-code like ub.cash-pay.cdpay-code no-undo .
define variable v-rate as decimal no-undo .
define variable v-scale as integer no-undo .
define variable v-rate-rubl as decimal no-undo .
define variable v-scale-rubl as integer no-undo .
define variable v-rate-base as decimal no-undo .
define variable v-scale-base as integer no-undo .
define variable v-curr-abbr like ub.currency.curr-abbr no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .

do
on error undo, return error
:

/*определим баз вал для магазина к которому приписана касса*/

CASE p-pos-type:
  when {&cd-type-MAGIA-XML} then do:
    _for:
    for each buf_cash-pay no-lock,
        first buf_currency no-lock where
              buf_currency.curr-code = buf_Cash-pay.curr-code:
       if p-selective and
       LOOKUP(string(recid(buf_cash-pay)), p-rid-list) = 0 then NEXT.
      if buf_cash-pay.status_ <> {&current-status} and action = 'U' and not p-selective then NEXT.
      if v-cp-is-use then do:
        run cp-attr-value  in this-procedure (
                                                input  buf_cash-pay.cdpay-code
                                                ,input  buf_cash-pay.curr-code
                                                ,input  v-host-code
                                                ,input  {&shop}
                                                ,input  p-obj-code
                                                ,input  {&cp-attr-is-use}
                                                ,output v-value
                                                ,output v-type) no-error .

        if error-status:error
        or v-value = '':u then do:
          run cp-attr-value  in this-procedure (
                                                    input buf_cash-pay.cdpay-code
                                                  ,input  buf_cash-pay.curr-code
                                                  ,input  v-host-code
                                                  ,input  '':U /*p-obj-type     */
                                                  ,input  0 /*p-obj-code     */
                                                  ,input  {&cp-attr-is-use}
                                                  ,output v-value
                                                  ,output v-type) no-error .
          if error-status:error
          or v-value = '':u then do:
            run cp-attr-value  in this-procedure (
                                                      input  buf_cash-pay.cdpay-code
                                                    ,input  buf_cash-pay.curr-code
                                                    ,input  0 /*p-host-code*/
                                                    ,input  '':U /*p-obj-type     */
                                                    ,input  0 /*p-obj-code     */
                                                    ,input  {&cp-attr-is-use}
                                                    ,output v-value
                                                    ,output v-type) no-error .
          end.
        end.
        if v-value <> '*':U
        and lookup(string(p-cash-num) + {&comma-char} + p-pos-type, {&delim-par}) = 0 then next _for.
      end.

      /*для кассы MAGIA будем создавать некий виртуальный код из кода cash-pay.cdpay-code и cash-pay.curr-code*/
      /*по следующим правилам*/
      /*для оплат в которых стоит флаг наличные передаем код валюты OKВ - он трехзначный*/
      /*тех оплат где код наличные не стоит передаем cash-pay.cdpay-code + 10000 */
      /*те оплаты у которых cash-pay.cdpay-code > 10000 - игнорируем*/
      if buf_cash-pay.is-cash then do:
        if buf_currency.okv-code = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Для валюты &1 с кодом &2 не задан код ОКВ"
                                  , buf_currency.curr-abbr
                                  , buf_currency.curr-code
                                )
                                                ).
          assign
          p-view-log = yes
          .
          NEXT _for.
        end.
      end.
      else do:
        if buf_cash-pay.cdpay-code > 10000 then  do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Нельзя передать тип кассового платежа &1 с кодом большим 10000: &2"
                                  , buf_cash-pay.obj-name
                                  , buf_cash-pay.cdpay-code
                                )
                                                ).
          assign
          p-view-log = yes
          .
          NEXT _for.
        end.
      end.

      assign
      v-mag-code = (if buf_cash-pay.is-cash
                then (if buf_currency.curr-code = 0 then 1 else buf_currency.okv-code)
                else (10000 + buf_cash-pay.cdpay-code)
                )
      .
      if buf_cash-pay.curr-code = v-r-b-code then do:
        assign
        v-rate = 1
        v-scale = 1
        .
      end.
      else do:
        run cur-time in this-procedure(output v-date, output v-time).
        { gbl/exchrate.i buf_cash-pay.curr-code today v-rate-rubl v-scale-rubl v-curr-abbr }
        if v-r-b-code = 0 then  do:
          assign
          v-rate = v-rate-rubl
          v-scale = v-scale-rubl
          .
        end.
        else do:
          { gbl/exchrate.i v-r-b-code today v-rate-base v-scale-base v-curr-abbr }
          assign
          v-rate = v-rate-rubl / (v-rate-base / v-scale-base)
          .
        end.

      end.
      run bgelib-tag-open in this-procedure ( input 2, input "Payment"
                                            , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
                                                                                                then "ADD":U
                                                                                                else "DEL":U),
                                            OS2-time, v-mag-code)).
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentBaseCode"
                                           , input string(v-mag-base-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentShort":U
                                           , input (if buf_cash-pay.is-cash
                                                    then string(buf_currency.curr-abbr)
                                                    else substr(buf_cash-pay.obj-name, 1, 3)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentName":U
                                           , input (if buf_cash-pay.is-cash
                                                    then substr(buf_currency.curr-name, 1, 12)
                                                    else substr(buf_cash-pay.obj-name, 1, 12)), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentCurrencyRate":U
                                           , input  string(v-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentCurrencyDecimal":U
                                           , input string(v-scale), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentCurrencyLock":U
                                           , input (if action = "D":U
                                                    then string(1)
                                                    else string(0)), input 1 ).
      run bgelib-tag-open in this-procedure ( input 3, input "PaymentStatus"
                                            , input "":U).
      run bgelib-tag-put in this-procedure ( input 4, input "PSCash":U
                                           , input string(if buf_cash-pay.is-cash then 1 else 0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PSCreditCard":U
                                           , input string(if buf_cash-pay.is-credit-card  and not buf_cash-pay.atr16
                                                         then 1
                                                         else 0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PSAuthorize":U
                                           , input string(if buf_cash-pay.is-credit-card  and buf_cash-pay.atr16
                                                         then 1
                                                         else 0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PSCard":U
                                           , input string(if buf_cash-pay.is-debet-card
                                                         then 1
                                                         else 0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PSCashless":U
                                           , input string(if buf_cash-pay.cdpay-code = v-cashless-code
                                                   then 1
                                                   else 0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PSNoPay":U
                                           , input string(if buf_cash-pay.cdpay-code = v-no-pay-code
                                                          then  1
                                                          else 0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "PSVIPClient":U
                                           , input string(if buf_cash-pay.cdpay-code = v-VIP-pay-code
                                                          then 1
                                                          else 0), input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "PaymentStatus").
      run bgelib-tag-close in this-procedure ( input 2, input "Payment").

    end.
  end.
END CASE .

end. /*doe*/
END PROCEDURE .

/* $Workfile$ e n d */