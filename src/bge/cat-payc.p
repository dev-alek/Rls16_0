block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cat-payc.p $
$Archive: bge/cat-payc.p $

Выгрузка справочника типов кассовых платежей

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-rec-amount as integer      no-undo.
define input parameter p-rec-list   as character    no-undo.
define input parameter p-host-code  as integer      no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cat-payc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cat-payc.p $":U .
define variable vss-description as character no-undo init "Выгрузка справочника типов кассовых платежей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/bge-xml.i  }

&scop out-file-name "paycode"
&scop version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

do
on error undo, return error
:
    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */

    define buffer buf_cash-pay      for ub.cash-pay.

    run bge/bge-head.p (
          input "dict"
        , input {&out-file-name}
        , input "XML - Вывод справочника типов кассовых платежей"
        , input no
        , output v-xml-file-name
        , output v-log-file-name
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка при создании файла выгрузки."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run bge-xml-write-header in this-procedure (
          input v-xml-file-name
        , input {&out-file-name}
        , input {&version-string}
        , input 0
        , input ?
        , input 0
        , input ?
        , input 0
        , input "":U
        , input "":U
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
    ).
    output stream stmxmlout to value( v-xml-file-name + "xm1" ) convert target "1251" append.
    for each buf_cash-pay no-lock
    :
        run write-body in this-procedure (
              input buf_cash-pay.cdpay-code
            , input buf_cash-pay.curr-code
            , input v-xml-file-name
            , input v-log-file-name
        ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog(
                  input v-log-file-name
                , input 1
                , input substitute(  "*** ERR: *** Ошибка выгрузки типа кассового платежа &1. &2. &3. &4", buf_cash-pay.cdpay-code, buf_cash-pay.cdpay-code, trim(error-status :get-message(1)), trim(error-status :get-message(2)) )
            ).
        end.
    end.        /* for each buf_dis-card */
    output stream stmxmlout close.
    run xml-bge-write-footer in this-procedure (
        input v-xml-file-name
    ).
end.


/*==========================================================================*/
procedure write-body :
do
on error undo, return error
:
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-curr-code      as integer      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-log-file-name  as character    no-undo.

    define buffer buf_cash-pay      for ub.cash-pay.

    find first buf_cash-pay no-lock
         where buf_cash-pay.cdpay-code  = p-obj-code
           and buf_cash-pay.curr-code = p-curr-code
    .

run wp-XMLTagOpen( input 2, input {&out-file-name}, input "").
run wp-XMLTagPut( input 3, "payTypeID"      , input string( buf_cash-pay.cdpay-code       ), input 0 ).
run wp-XMLTagPut( input 3, "currCodeID"     , input string( buf_cash-pay.curr-code      ), input 0 ).
run wp-XMLTagPut( input 3, "name"           , input string( buf_cash-pay.obj-name       ), input 0 ).
run wp-XMLTagPut( input 3, "payCode"        , input string( buf_cash-pay.pay-code       ), input 0 ).   /* Код вида оплаты                           */
run wp-XMLTagPut( input 3, "payLimit"       , input string( buf_cash-pay.pay-limit      ), input 0 ).   /* Предел без авторизации                    */
run wp-XMLTagPut( input 3, "wthCode"        , input string( buf_cash-pay.wth-code       ), input 0 ).   /* Уникальный код МЦ                         */
run wp-XMLTagPut( input 3, "isCash"         , input string( buf_cash-pay.is-cash        ), input 0 ).   /* Наличные                                  */
run wp-XMLTagPut( input 3, "isCreditCard"   , input string( buf_cash-pay.is-credit-card ), input 0 ).   /* Кред.карта                                */
run wp-XMLTagPut( input 3, "isDebetCard"    , input string( buf_cash-pay.is-debet-card  ), input 0 ).   /* Расчетная карта - дебетовая               */
run wp-XMLTagPut( input 3, "payCardView"    , input string( buf_cash-pay.pay-card-view  ), input 0 ).   /* список префиксов номеров платежных карт, которые должны быть видны. Для карт типа VISA должен быть "" */
run wp-XMLTagPut( input 3, "atr1"           , input string( buf_cash-pay.atr1           ), input 0 ).   /* Разрешается сдача на платеж               */
run wp-XMLTagPut( input 3, "atr2"           , input string( buf_cash-pay.atr2           ), input 0 ).   /* Разрешается перевод оплаты на платеж      */
run wp-XMLTagPut( input 3, "atr4"           , input string( buf_cash-pay.atr4           ), input 0 ).   /* Принудительная печать слипа по платежу    */
run wp-XMLTagPut( input 3, "atr8"           , input string( buf_cash-pay.atr8           ), input 0 ).   /* Принудительная печать фактуры по платежу  */
run wp-XMLTagPut( input 3, "atr16"          , input string( buf_cash-pay.atr16          ), input 0 ).   /* Необходима on-line авторизация            */
run wp-XMLTagPut( input 3, "atr32"          , input string( buf_cash-pay.atr32          ), input 0 ).   /* Обязателен ввод PIN-кода                  */
run wp-XMLTagPut( input 3, "atr64"          , input string( buf_cash-pay.atr64          ), input 0 ).   /* Топливный платеж                          */
run wp-XMLTagPut( input 3, "atr128"         , input string( buf_cash-pay.atr128         ), input 0 ).   /* Smart карта                               */
run wp-XMLTagClose( input 2, input {&out-file-name} ).

end.
end procedure. /* write-body */