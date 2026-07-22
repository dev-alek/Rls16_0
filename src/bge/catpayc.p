block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: catpayc.p $
$Archive: bge/catpayc.p $

Выгрузка справочника типов кассовых платежей

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-host-code          as integer      no-undo.
define input parameter p-rec-amount         as integer      no-undo.
define input parameter p-rec-code-list      as character    no-undo.

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 10 12:04:11 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: catpayc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/catpayc.p $":U .
define variable vss-description as character no-undo init "Выгрузка справочника типов кассовых платежей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/bgelib.i   }

&scoped-define version-string "12.3 " + replace( vss-revision + vss-date, "$", " " )
&scoped-define parameters-amount 4

do
on error undo, return error
:
    define variable v-counter           as integer       no-undo.
    define variable v-xml-file-name     as character     no-undo.
    define variable v-log-file-name     as character     no-undo.
    define variable v-list-file-name    as character     no-undo.
    define variable v-xml-file-number   as integer       no-undo.
    define variable v-cancel            as logical       no-undo.
    define variable v-parameter-list    as character     no-undo.

    define buffer buf_cash-pay      for ub.cash-pay.

    run bgelib-read-config in this-procedure no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка чтения параметров экспорта."
        skip "Для экспорта данных будут приняты параметры по умолчанию."
        skip return-value
        skip trim(error-status :get-message(1))
             trim(error-status :get-message(2))
             trim(error-status :get-message(3))
        view-as alert-box error.
    end.
    run bgelib-filename in this-procedure (
          input "pcp"
        , output v-xml-file-name
        , output v-log-file-name
        , output v-list-file-name
    ).
    run gbl/waitfrsp.w (
          input substring( v-xml-file-name, 1, 1 )
        , input {&bgelib_minimum-free-mbytes}
        , output v-cancel
    ) .
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки справочника типов кассовых платежей в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + {&bgelib-temp-extension}
                          )
    ).
    if p-rec-amount = ?
    or p-rec-code-list = ?
    or ( p-rec-amount <> 0
        and num-entries( p-rec-code-list ) = 0 )
    then do:
        run bgelib-write-log in this-procedure (
              input v-log-file-name
            , input 1
            , input "Неверно заданы входные параметры."
        ).
        undo, return error.
    end.
    assign
        v-parameter-list         =  substitute( "&1,&2,&3,&4,&5,&6,&7,&8,&9"
                                               , {&parameters-amount}
                                               , "docName"          , "cashPay":U
                                               , "version"          , replace({&version-string},',','')
                                               , "exportDate"       , string( today,          "99/99/9999" )
                                               , "exportTime"       , string( time,           "HH:MM:SS"   )
                                              )
        v-xml-file-number       =   1
    .
    run bgelib-write-header in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input v-xml-file-number                           /* p-file-number   */
        , input no                                          /* p-have-prev     */
        , input ""                                          /* p-prev-filename */
        , input ""
        , input ""
        , input v-parameter-list
    ).
    for each buf_cash-pay no-lock
    :
        run write-body in this-procedure (
              input buf_cash-pay.cdpay-code
            , input buf_cash-pay.curr-code
            , input v-parameter-list
            , input v-xml-file-name
            , input v-log-file-name
            , input v-list-file-name
            , input v-xml-file-number
            , output v-xml-file-name
            , output v-xml-file-number
        ) no-error.
        if error-status :error
        then do:
            run bgelib-write-log in this-procedure (
                  input v-log-file-name
                , input 1
                , input substitute(  "*** ERR: *** Ошибка выгрузки типа кассового платежа &1. &2. &3. &4", buf_cash-pay.cdpay-code, buf_cash-pay.curr-code, trim(error-status :get-message(1)), trim(error-status :get-message(2)) )
            ).
        end.
    end.        /* for each buf_dis-card */
    run bgelib-write-footer in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input no
        , input ""
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + "xml"
                          )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
end.


/*==========================================================================*/
procedure write-body :
do
on error undo, return error
:
define input parameter p-obj-code               as integer      no-undo.
define input parameter p-curr-code              as integer      no-undo.
define input parameter p-parameter-list         as character    no-undo.
define input parameter p-xml-file-name          as character    no-undo.
define input parameter p-log-file-name          as character    no-undo.
define input parameter p-list-file-name         as character    no-undo.
define input parameter p-xml-file-number        as integer      no-undo.
define output parameter p-last-xml-file-name    as character    no-undo.
define output parameter p-last-xml-file-number  as integer      no-undo.

    define variable v-need-new-file as logical      no-undo.
    define variable v-void-string   as character      no-undo.
    define variable v-prev-filename as character      no-undo.

    define buffer buf_cash-pay      for ub.cash-pay.

    assign
        p-last-xml-file-name   = p-xml-file-name
        p-last-xml-file-number = p-xml-file-number
    .
    run bgelib-check-file-size in this-procedure (
          input p-xml-file-name + {&bgelib-temp-extension}
        , output v-need-new-file
    ).
    if v-need-new-file = yes
    then do:
        assign
            v-prev-filename = p-xml-file-name
        .
        run bgelib-filename in this-procedure (
              input "pcp"
            , output p-xml-file-name
            , output v-void-string
            , output v-void-string
        ).
        run bgelib-write-footer in this-procedure (
              input no
            , input v-prev-filename
            , input p-list-file-name
            , input yes
            , input p-xml-file-name + "xml":U
        ).
        run bgelib-write-log in this-procedure (
              input p-log-file-name
            , input 1
            , input substitute( "Данные выгружены в файл &1"
                                    , replace( p-xml-file-name, "/", "\" ) + "xml"
                            )
        ).
        assign
            p-last-xml-file-number   = p-xml-file-number + 1
            p-last-xml-file-name     = p-xml-file-name
        .
        run bgelib-write-header in this-procedure (
              input no
            , input p-last-xml-file-name
            , input p-list-file-name
            , input p-last-xml-file-number
            , input yes
            , input v-prev-filename + "xml":U
            , input ""
            , input ""
            , input p-parameter-list
        ).
        assign
            v-need-new-file = no
        .
    end.        /* if v-need-new-file = yes */
    output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
    find first buf_cash-pay no-lock
         where buf_cash-pay.cdpay-code  = p-obj-code
           and buf_cash-pay.curr-code = p-curr-code
    .
run bgelib-tag-open in this-procedure ( input 1, input "pcp", input "").
run bgelib-tag-put in this-procedure ( input 2, "payTypeID"      , input string( buf_cash-pay.cdpay-code          ), input 0 ).
run bgelib-tag-put in this-procedure ( input 2, "currCodeID"     , input string( buf_cash-pay.curr-code         ), input 0 ).
run bgelib-tag-put in this-procedure ( input 2, "name"           , input string( buf_cash-pay.obj-name          ), input 0 ).
run bgelib-tag-put in this-procedure ( input 2, "payCode"        , input string( buf_cash-pay.pay-code          ), input 0 ).   /* Код вида оплаты                           */
run bgelib-tag-put in this-procedure ( input 2, "payLimit"       , input string( buf_cash-pay.pay-limit         ), input 0 ).   /* Предел без авторизации                    */
run bgelib-tag-put in this-procedure ( input 2, "wthCode"        , input string( buf_cash-pay.wth-code          ), input 0 ).   /* Уникальный код МЦ                         */
run bgelib-tag-put in this-procedure ( input 2, "isCash"         , input string( buf_cash-pay.is-cash           ), input 0 ).   /* Наличные                                  */
run bgelib-tag-put in this-procedure ( input 2, "isCreditCard"   , input string( buf_cash-pay.is-credit-card    ), input 0 ).   /* Кред.карта                                */
run bgelib-tag-put in this-procedure ( input 2, "isDebetCard"    , input string( buf_cash-pay.is-debet-card     ), input 0 ).   /* Расчетная карта - дебетовая               */
run bgelib-tag-put in this-procedure ( input 2, "payCardView"    , input string( buf_cash-pay.pay-card-view     ), input 0 ).   /* список префиксов номеров платежных карт, которые должны быть видны. Для карт типа VISA должен быть "" */
run bgelib-tag-put in this-procedure ( input 2, "atr1"           , input string( buf_cash-pay.atr1              ), input 0 ).   /* Разрешается сдача на платеж               */
run bgelib-tag-put in this-procedure ( input 2, "atr2"           , input string( buf_cash-pay.atr2              ), input 0 ).   /* Разрешается перевод оплаты на платеж      */
run bgelib-tag-put in this-procedure ( input 2, "atr4"           , input string( buf_cash-pay.atr4              ), input 0 ).   /* Принудительная печать слипа по платежу    */
run bgelib-tag-put in this-procedure ( input 2, "atr8"           , input string( buf_cash-pay.atr8              ), input 0 ).   /* Принудительная печать фактуры по платежу  */
run bgelib-tag-put in this-procedure ( input 2, "atr16"          , input string( buf_cash-pay.atr16             ), input 0 ).   /* Необходима on-line авторизация            */
run bgelib-tag-put in this-procedure ( input 2, "atr32"          , input string( buf_cash-pay.atr32             ), input 0 ).   /* Обязателен ввод PIN-кода                  */
run bgelib-tag-put in this-procedure ( input 2, "atr64"          , input string( buf_cash-pay.atr64             ), input 0 ).   /* Топливный платеж                          */
run bgelib-tag-put in this-procedure ( input 2, "atr128"         , input string( buf_cash-pay.atr128            ), input 0 ).   /* Smart карта                               */
run bgelib-tag-close in this-procedure ( input 1, input "pcp" ).
    output stream stmxmlout close.
end.
end procedure. /* write-body */