block-level on error undo, throw.
/*

$Revision: c89b59c2f62e, 135, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:48:25 2015 +0400 $
$Workfile: cat-dcrt.p $
$Archive: bge/cat-dcrt.p $

Выгрузка справочника дисконтных карт

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:
    p-mode                  - режим экспорта (список):
                                "list"     - экспорт дисконтных карт с кодами из временной таблицы temp_bgelib_clients
    temp_bge-xml_dis-card   - список дисконтных карт для режима "list"

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: c89b59c2f62e, 135, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:25 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cat-dcrt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cat-dcrt.p $":U .
define variable vss-description as character no-undo init "Выгрузка справочника дисконтных карт".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/bge-xml.i  }

define input parameter p-mode           as character    no-undo.
define input parameter table for temp_bge-xml_dis-card .
define input parameter p-file-name      as character    no-undo.

&scop out-file-name "dcard"
&scop version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

do
on error undo, return error
:
    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */

    define buffer buf_dis-card      for ub.dis-card.

    run bge/bge-head.p (
          input "dict"
        , input {&out-file-name} + trim(p-file-name, ".")
        , input "XML - Вывод справочника дисконтных карт"
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
    if lookup( "list":U, p-mode ) = 0
    then do:
        for each buf_dis-card no-lock
        :
            run write-dcard in this-procedure (
                  input buf_dis-card.d-card
                , input v-xml-file-name
                , input v-log-file-name
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog(
                      input v-log-file-name
                    , input 1
                    , input substitute(  "*** ERR: *** Ошибка выгрузки дисконтной карты номер &1. &2. &3.", buf_dis-card.d-card, trim(error-status :get-message(1)), trim(error-status :get-message(2)) )
                ).
            end.
        end.        /* for each buf_dis-card */
    end.        /* if lookup( "list":U, p-mode ) = 0 */
    else do:
        for each temp_bge-xml_dis-card no-lock
        :
            run write-dcard in this-procedure (
                  input temp_bge-xml_dis-card.d-card
                , input v-xml-file-name
                , input v-log-file-name
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog(
                      input v-log-file-name
                    , input 1
                    , input substitute(  "*** ERR: *** Ошибка выгрузки дисконтной карты номер &1. &2. &3.", temp_bge-xml_dis-card.d-card, trim(error-status :get-message(1)), trim(error-status :get-message(2)) )
                ).
            end.
        end.        /* for each buf_dis-card */
    end.        /* NOT ( if lookup( "list":U, p-mode ) = 0 ) */

    output stream stmxmlout close.
    run xml-bge-write-footer in this-procedure (
        input v-xml-file-name
    ).
end.


/*==========================================================================*/
procedure write-dcard :
do
on error undo, return error
:
define input parameter p-dcard          as character    no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-log-file-name  as character    no-undo.

    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */

    define buffer buf_dis-card      for ub.dis-card.

    find first buf_dis-card no-lock
         where buf_dis-card.d-card = p-dcard
    .

run wp-XMLTagOpen( input 2, input {&out-file-name}, input "").
run wp-XMLTagPut( input 3, "cardID"         , input buf_dis-card.d-card                      , input 0 ).
run wp-XMLTagPut( input 3, "cardNum"        , input string( buf_dis-card.card-num           ), input 0 ).  /* Внутренний номер карты - для суррогатного ключа                    */
run wp-XMLTagPut( input 3, "sourceDCard"    , input string( buf_dis-card.sourced-card       ), input 0 ).  /* Номер первичной дисконтной карты авторизованного покупателя        */
run wp-XMLTagPut( input 3, "validDate"      , input string( buf_dis-card.valid-date         ), input 0 ).  /* Дата окончания дейсвия                                             */
run wp-XMLTagPut( input 3, "cliType"        , input string( buf_dis-card.cli-type           ), input 0 ).
run wp-XMLTagPut( input 3, "cliCode"        , input string( buf_dis-card.cli-code           ), input 0 ).
run wp-XMLTagPut( input 3, "hostcode"       , input string( buf_dis-card.emitent-host-code  ), input 0 ).  /* Код фирмы                                                          */
run wp-XMLTagPut( input 3, "isCreditCard"   , input string( buf_dis-card.credit-card        ), input 0 ).
run wp-XMLTagPut( input 3, "creditLimit"    , input string( buf_dis-card.lim-kr             ), input 0 ).  /* Лимит кредита                                                      */
run wp-XMLTagPut( input 3, "pcntDiscount"   , input string( buf_dis-card.d-pcnt             ), input 0 ).  /* Процент скидки                                                     */
run wp-XMLTagPut( input 3, "pcntDiscItog"   , input string( buf_dis-card.cash-d-pcnt        ), input 0 ).  /* Скидки на итог                                                     */
run wp-XMLTagPut( input 3, "pcntDiscMethod" , input string( buf_dis-card.d-pcnt-method      ), input 0 ).  /* Как использовать скидки и скидки на итог                           */
run wp-XMLTagPut( input 3, "issureCode"     , input string( buf_dis-card.issue-code         ), input 0 ).  /* Код магазина, выдавшего карту (0 - офис)                           */
run wp-XMLTagPut( input 3, "issureDate"     , input string( buf_dis-card.issue-date         ), input 0 ).  /* Дата выдачи карты клиенту                                          */
run wp-XMLTagPut( input 3, "saldoBase"      , input string( buf_dis-card.saldo-base         ), input 0 ).  /* Сальдо в базовой валюте (эквивалент)                               */
run wp-XMLTagPut( input 3, "saldoRubl"      , input string( buf_dis-card.saldo-rubl         ), input 0 ).  /* Сальдо в р у б л я х (эквивалент)                                       */
run wp-XMLTagPut( input 3, "status"         , input string( buf_dis-card.status_            ), input 0 ).  /*                                                                    */
run wp-XMLTagPut( input 3, "type"           , input string( buf_dis-card.type               ), input 0 ).  /* тип дисконтной карты: начальная скидка, алгоритм пересчета скидки  */
run wp-XMLTagClose( input 2, input {&out-file-name} ).


end.
end procedure. /* write-dcard */