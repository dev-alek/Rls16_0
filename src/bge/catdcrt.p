block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: catdcrt.p $
$Archive: bge/catdcrt.p $

Выгрузка справочника дисконтных карт

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:
    p-mode          - режим экспорта (список):
                        "list"     - экспорт дисконтных карт с кодами из временной таблицы temp_bgelib_clients
    temp_bgelib_dis-card - список дисконтных карт для режима "list"

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 10 12:04:11 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: catdcrt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/catdcrt.p $":U .
define variable vss-description as character no-undo init "Выгрузка справочника дисконтных карт".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/bgelib.i   }

define input parameter p-mode           as character    no-undo.
define input parameter table for temp_bgelib_dis-card .

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )
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

    define buffer buf_dis-card      for ub.dis-card.

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
          input "dct"
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
        , input substitute( "Начало выгрузки справочника дисконтных карт в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + {&bgelib-temp-extension}
                          )
    ).
    assign
        v-parameter-list         =  substitute( "&1,&2,&3,&4,&5,&6,&7,&8,&9"
                                               , {&parameters-amount}
                                               , "docName"          , "discCard":U
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
    if lookup( "list":U, p-mode ) = 0
    then do:
        for each buf_dis-card no-lock
        :
            run write-dcard in this-procedure (
                  input buf_dis-card.d-card
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
                    , input substitute(  "*** ERR: *** Ошибка выгрузки дисконтной карты номер &1. &2. &3.", buf_dis-card.d-card, trim(error-status :get-message(1)), trim(error-status :get-message(2)) )
                ).
            end.
        end.        /* for each buf_dis-card */
    end.        /* if lookup( "list":U, p-mode ) = 0 */
    else do:
        for each temp_bgelib_dis-card no-lock
        :
            run write-dcard in this-procedure (
                  input temp_bgelib_dis-card.d-card
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
                    , input substitute(  "*** ERR: *** Ошибка выгрузки дисконтной карты номер &1. &2. &3.", temp_bgelib_dis-card.d-card, trim(error-status :get-message(1)), trim(error-status :get-message(2)) )
                ).
            end.
        end.        /* for each buf_dis-card */
    end.        /* NOT ( if lookup( "list":U, p-mode ) = 0 ) */
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
procedure write-dcard :
do
on error undo, return error
:
define input parameter p-dcard                  as character    no-undo.
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

    define buffer buf_dis-card      for ub.dis-card.

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
              input "dct"
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
    find first buf_dis-card no-lock
         where buf_dis-card.d-card = p-dcard
    .
run bgelib-tag-open in this-procedure ( input 1, input "dct", input "").
run bgelib-tag-put in this-procedure ( input 2, "cardID"         , input buf_dis-card.d-card                      , input 0 ).
run bgelib-tag-put in this-procedure ( input 2, "cardNum"        , input string( buf_dis-card.card-num           ), input 0 ).  /* Внутренний номер карты - для суррогатного ключа                    */
run bgelib-tag-put in this-procedure ( input 2, "sourceDCard"    , input string( buf_dis-card.sourced-card       ), input 0 ).  /* Номер первичной дисконтной карты авторизованного покупателя        */
run bgelib-tag-put in this-procedure ( input 2, "validDate"      , input string( buf_dis-card.valid-date         ), input 0 ).  /* Дата окончания дейсвия                                             */
run bgelib-tag-put in this-procedure ( input 2, "cliType"        , input string( buf_dis-card.cli-type           ), input 0 ).
run bgelib-tag-put in this-procedure ( input 2, "cliCode"        , input string( buf_dis-card.cli-code           ), input 0 ).
run bgelib-tag-put in this-procedure ( input 2, "hostcode"       , input string( buf_dis-card.emitent-host-code  ), input 0 ).  /* Код фирмы                                                          */
run bgelib-tag-put in this-procedure ( input 2, "isCreditCard"   , input string( buf_dis-card.credit-card        ), input 0 ).
run bgelib-tag-put in this-procedure ( input 2, "creditLimit"    , input string( buf_dis-card.lim-kr             ), input 0 ).  /* Лимит кредита                                                      */
run bgelib-tag-put in this-procedure ( input 2, "pcntDiscount"   , input string( buf_dis-card.d-pcnt             ), input 0 ).  /* Процент скидки                                                     */
run bgelib-tag-put in this-procedure ( input 2, "pcntDiscItog"   , input string( buf_dis-card.cash-d-pcnt        ), input 0 ).  /* Скидки на итог                                                     */
run bgelib-tag-put in this-procedure ( input 2, "pcntDiscMethod" , input string( buf_dis-card.d-pcnt-method      ), input 0 ).  /* Как использовать скидки и скидки на итог                           */
run bgelib-tag-put in this-procedure ( input 2, "issureCode"     , input string( buf_dis-card.issue-code         ), input 0 ).  /* Код магазина, выдавшего карту (0 - офис)                           */
run bgelib-tag-put in this-procedure ( input 2, "issureDate"     , input string( buf_dis-card.issue-date         ), input 0 ).  /* Дата выдачи карты клиенту                                          */
run bgelib-tag-put in this-procedure ( input 2, "saldoBase"      , input string( buf_dis-card.saldo-base         ), input 0 ).  /* Сальдо в базовой валюте (эквивалент)                               */
run bgelib-tag-put in this-procedure ( input 2, "saldoRubl"      , input string( buf_dis-card.saldo-rubl         ), input 0 ).  /* Сальдо в р у б л я х (эквивалент)                                  */
run bgelib-tag-put in this-procedure ( input 2, "status"         , input string( buf_dis-card.status_            ), input 0 ).  /*                                                                    */
run bgelib-tag-put in this-procedure ( input 2, "type"           , input string( buf_dis-card.type               ), input 0 ).  /* тип дисконтной карты: начальная скидка, алгоритм пересчета скидки  */
run bgelib-tag-close in this-procedure ( input 1, input "dct" ).
    output stream stmxmlout close.
end.
end procedure. /* write-dcard */