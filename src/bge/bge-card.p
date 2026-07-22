block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bge-card.p $
$Archive: bge/bge-card.p $

Экспорт данных продаж по дисконтным картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/05/03
Author: Bakhtadze Natalya
Creation date: 08/05/03

*/

define input parameter p-mainmenu-handle  as handle           no-undo.
define input parameter p-date-from      as date       no-undo. /* начало периода экспорта */
define input parameter p-date-to        as date       no-undo. /* конец  периода экспорта */
define input parameter p-range          as integer    no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-obj-list       as character  no-undo. /* Список объектов для p-range = 3 */
define input parameter hEDT             AS HANDLE NO-UNDO.
define input parameter hCNT             AS HANDLE NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-card.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-card.p $":U .
define variable vss-description as character no-undo init "Экспорт данных продаж по дисконтным картам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ bge/bge-xml.i }
{ gbl/temphost.i }
{ gbl/getcntxt.i def }

&SCOP FRAME-NAME F-DUMMY

&scop out-file-name "cardsale"
&scop version-string "14.0 " + replace( vss-revision + vss-date, "$", " " )

define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
define variable v-log-file-name     as character            no-undo. /* имя log-файла */
define variable v-out-dir           as character            no-undo.
define variable v-locked            as logical              no-undo.
define variable v-log-string        as character            no-undo. /* имя log-файла */
define variable v-oper-num          as integer              no-undo. /* номер операции*/
define variable v-obj-counter       as integer              no-undo.
define variable v-obj-list          as character            no-undo.
define variable loc#log             as logical              no-undo.

define variable strDummy    AS CHAR view-as editor size 50 by 4 NO-UNDO.
define variable intRep      AS INT NO-UNDO.                         /* повторитель   */
define temp-table temp-dis-card no-undo like ub.dis-card.

do
on error undo, return error
:
/*
define temp-table temp-dis-obj no-undo like ub.dis-obj.
define temp-table temp-dis-host no-undo like ub.dis-host.
*/

/* Права на экспорт данных продаж по дисконтным картам*/
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_references_export':U
{&cntxt-global}
0
'':U
0
0
0
0
true
loc#log
}

IF NOT loc#log THEN RETURN ERROR.
{ gbl/getcntxt.i get " " p-mainmenu-handle }
run bge-xml-out-dir in this-procedure ( output v-out-dir
                                      , output v-log-file-name
                                      ).

case p-range:
when 1
then do:
    run init-temphost.
end.
when 2      /* Экспорт по текущей фирме */
then do:
    run init-temphost.
    for each temp-obj
        where temp-obj.host-code <> v-cntxt-host-code-obj
    :
        delete temp-obj.
    end.
end.
when 3      /* Экспорт по списку объектов */
then do:
    for each temp-obj
    :
        delete temp-obj.
    end.
    do v-obj-counter = 1 to num-entries ( v-obj-list ) / 2
    :
        create temp-obj.
        assign
            temp-obj.obj-type = entry( v-obj-counter * 2 - 1, v-obj-list )
            temp-obj.obj-code = integer( entry( v-obj-counter * 2, v-obj-list ) )
        no-error .
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                input v-log-file-name
                , input 1
                , input substitute( "*** Ошибка чтения списка объектов. &1. &2. &3. &4."
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                    , trim(error-status :get-message(3))
                                )
            ).
            undo, return error .
        end.
        { gbl/hostcode.i
            temp-obj.obj-type
            temp-obj.obj-code
            temp-obj.host-code
        no-error }
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                input v-log-file-name
                , input 1
                , input substitute( "*** Не найдена фирма для объекта &1 &2. &3. &4. &5. &6."
                                    , temp-obj.obj-type
                                    , temp-obj.obj-code
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                    , trim(error-status :get-message(3))
                                )
            ).
            undo, return error .
        end.
    end.
end.
end case.

run bge-xml-read-config in this-procedure ( input ?
                                          , input ?
                                          ) no-error.
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
run xml-bge-filename in this-procedure (
      input "crd"
    , input "card"
    , input no
    , output v-xml-file-name
    , output v-log-file-name
    , output v-locked
).
if v-locked = yes
then do:
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "*** Ошибка выгрузки: Файл выгрузки заблокирован другим процессом."
    ).
    undo, return error .
end.


run wp-XMLWriteLog in this-procedure (
      input v-log-file-name
    , input 1
    , input "&DLine"
).
run wp-XMLWriteLog in this-procedure (
      input v-log-file-name
    , input 1
    , input substitute( "Начало выгрузки данных продаж по дисконтным картам в файл &1"
                            , replace( v-xml-file-name, "/", "\" ) + "xm1"
                      )
).

run wp-XMLWriteLog in this-procedure (
      input v-log-file-name
    , input 1
    , input substitute( "................с параметрами: Дата с: &1, дата по: &2"
                            , p-date-from
                            , p-date-to
                      )
).
CASE p-range:
  when 3 then do:
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... список объектов: &1", p-obj-list )
    ).
  end.
  when 1 then do:
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input  ("................с параметрами: ... все объекты")
    ).
  end.
  when 2 then do:
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... объекты фирмы: &1", string( v-cntxt-host-code-obj ) )
    ).

  end.
END.
run bge-xml-write-header in this-procedure (
      input v-xml-file-name
    , input "cardsale"
    , input {&version-string}
    , input ?
    , input p-date-from
    , input 0
    , input p-date-to
    , input 0
    , input p-obj-list
    , input "":U
    , input no
    , input no
    , input no
    , input no
    , input no
    , input no
    , input no
    , input no
) no-error.
if error-status :error
then do:
    run wp-XMLWriteLog in this-procedure (
            input v-log-file-name
        , input 1
        , input substitute( "*** Ошибка записи шапки файла. Процедура: &1 (v.&2 &3). &4. &5"
                            , vss-workfile
                            , vss-revision
                            , vss-description
                            , return-value
                            , trim( error-status :get-message( 1 ) )
                            )
    ).
    undo, return error.
end.
if not avail temp-dis-card then create temp-dis-card.
/*
if not avail temp-dis-obj then create temp-dis-obj.
if not avail temp-dis-host then create temp-dis-host.
*/
object-of-list:
for each temp-obj where temp-obj.obj-type = {&shop}
:

    run export-cardsale-by-object (   input temp-obj.host-code
                                    , input temp-obj.obj-type
                                    , input temp-obj.obj-code
                                  ) no-error.
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "*** Ошибка выгрузки данных продаж по дисконтным картам по объекту &1 &2. &3. &4. &5."
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , return-value
                                , trim(error-status :get-message(1))
                                , trim(error-status :get-message(2))
                                , trim(error-status :get-message(3))
                              )
        ).
    end.
end.

run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).

run wp-XMLWriteLog in this-procedure (
      input v-log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1"
                            , replace( v-xml-file-name, "/", "\" ) + "xml"
                      )
).
run wp-XMLWriteLog in this-procedure (
      input v-log-file-name
    , input 1
    , input "&DLine"
).

     { gbl/stopwork.i }
end. /*doe*/


procedure export-cardsale-by-object :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type  no-undo .
define input parameter p-obj-code  like ub.clients.obj-code  no-undo .

define variable v-d-card like ub.dis-card.d-card no-undo .
define variable v-discnt-name as character no-undo .

define buffer buf_inkas for ub.inkas.
define buffer buf_payment for ub.payment.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_dis-host for ub.dis-host.

  do
  on error undo, return error
  :

    run wp-XMLWriteEDT( hEDT, 1, string( p-obj-type ) + " " + string( p-obj-code ) ).

    run wp-XMLShowCNT(hCNT).

    output stream stmxmlout to value( v-xml-file-name + "xm1" ) convert target "1251" append.
    _payment:
    for each buf_inkas no-lock where
             buf_inkas.obj-type = p-obj-type
         AND buf_inkas.obj-code = p-obj-code
         AND buf_inkas.doc-date >= p-date-from
         AND buf_inkas.doc-date <= p-date-to
         AND buf_inkas.status_ = {&fact},
        each buf_payment no-lock where
             buf_payment.host-code = p-host-code
        AND buf_payment.source-type = {&pmnt-cash-desk}
        AND buf_payment.source-ref = buf_inkas.inkas-code
        AND buf_payment.d-card <> "":U
     by buf_payment.d-card
        :
      if v-d-card <> buf_payment.d-card then do:
        find first buf_dis-card no-lock where
                  buf_dis-card.d-card = buf_payment.d-card
        no-error .
        if not avail buf_dis-card then do:
          run wp-XMLWriteLog( v-Log-File-name, 1, "Не найдена дисконтная карта " + string( buf_payment.d-card ) ).
          next _payment.
        end.
        buffer-copy buf_dis-card to temp-dis-card.
/*
        find first buf_dis-obj no-lock where
                  buf_dis-obj.d-card = buf_dis-card.d-card
              AND buf_dis-obj.obj-type = p-obj-type
              AND buf_dis-obj.obj-code = p-obj-code
              AND buf_dis-obj.dt-code = 0
        no-error.
        if not avail buf_dis-obj then do:
          run wp-XMLWriteLog( v-Log-File-name, 1, "Не найдены данные о дисконтной карте " + string( buf_payment.d-card ) +
                                                   " на объекте " + p-obj-type + string(p-obj-code) ).
          next _payment.
          buffer-copy buf_dis-obj to temp-dis-obj.
        end.
        find first buf_dis-host no-lock where
                  buf_dis-host.d-card = buf_dis-card.d-card
              AND buf_dis-host.host-code = p-host-code
              AND buf_dis-host.dt-code = 0
        no-error.
        if not avail buf_dis-host then do:
          run wp-XMLWriteLog( v-Log-File-name, 1, "Не найдены данные о дисконтной карте " + string( buf_payment.d-card ) +
                                                   " на фирме " + string(p-host-code) ).
          next _payment.
          buffer-copy buf_dis-host to temp-dis-host.
        end.
*/
        assign
        v-d-card = buf_payment.d-card
        .
        CASE buf_dis-card.d-pcnt:
          when 0.0 then do:
            assign
            v-discnt-name = "без скидки"
            .
          end.
          otherwise do:
            assign
            v-discnt-name = string(round(buf_dis-card.d-pcnt, 0), ">9 %":U)
            .
          end.
        END CASE.
      end.
      run wp-xmltagopen in this-procedure ( input 2, input "card", input "" ).
      run wp-xmltagput in this-procedure ( input 3, input "cardNumber"       , input string( temp-dis-card.d-card    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "cardType"         , input string( temp-dis-card.type    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "client"           , input (string(temp-dis-card.cli-type) +
                                                                                      string(temp-dis-card.cli-code)), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "status"           , input string( temp-dis-card.status_    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "creditCard"       , input string( temp-dis-card.credit-card, "yes/no":U), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "discountPercent"  , input string( temp-dis-card.d-pcnt), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "discountName"     , input v-discnt-name, input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "emitentHost"      , input string( temp-dis-card.emitent-host-code), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "issuingObject"    , input string( temp-dis-card.issue-code), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "issuingDate"      , input string( temp-dis-card.issue-date, "99/99/9999":U), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "saldoBase"        , input string( temp-dis-card.saldo-base), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "saldoRubl"        , input string( temp-dis-card.saldo-rubl), input 0 ).


    /*
      run wp-xmltagopen in this-procedure ( input 2, input "cardObject"      , input "" ).
      run wp-xmltagput in this-procedure ( input 3, input "cardNumber"       , input string( buf_dis-obj.d-card    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "object"           , input (string( buf_dis-obj.obj-type) +
                                                                                      string(buf_dis-obj.obj-code)), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "numberChecks"     , input string( buf_dis-obj.num-chk), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "totalBase"        , input string( buf_dis-obj.gds-tot-base), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "totalRubl"        , input string( buf_dis-obj.gds-tot-rubl), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "discntBase"       , input string( buf_dis-obj.gds-dis-base), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "discntRubl"       , input string( buf_dis-obj.gds-dis-rubl), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "payBase"          , input string( buf_dis-obj.pay-tot-base), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "payRubl"          , input string( buf_dis-obj.pay-tot-rubl), input 0 ).
      run wp-xmltagclose in this-procedure ( input 2, input "cardObject").

      run wp-xmltagopen in this-procedure ( input 2, input "cardHost"        , input "" ).
      run wp-xmltagput in this-procedure ( input 3, input "cardNumber"       , input string( buf_dis-host.d-card    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "Host"             , input string(buf_dis-host.host-code), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "numberChecks"     , input string( buf_dis-host.num-chk), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "totalBase"        , input string( buf_dis-host.gds-tot-base), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "totalRubl"        , input string( buf_dis-host.gds-tot-rubl), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "discntBase"       , input string( buf_dis-host.gds-dis-base), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "discntRubl"       , input string( buf_dis-host.gds-dis-rubl), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "payBase"          , input string( buf_dis-host.pay-tot-base), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "payRubl"          , input string( buf_dis-host.pay-tot-rubl), input 0 ).
      run wp-xmltagclose in this-procedure ( input 2, input "cardHost").
      */

      run wp-xmltagput in this-procedure ( input 3, input "ID"               , input string( buf_payment.pmnt-code    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "cardNumber"       , input string( buf_payment.d-card    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "host"             , input string( p-host-code), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "object"           , input (string( p-obj-type    ) + string(p-obj-code)), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "date"             , input string( buf_payment.exch-date, "99/99/9999" ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "currency"         , input string( buf_payment.exch-code    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "totSum"           , input string( buf_payment.tot-cli     ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "totRubl"          , input string( buf_payment.tot-rubl    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "totBase"          , input string( buf_payment.tot-base    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "payCode"          , input string( buf_payment.pay-code    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "saleDoc"          , input string( buf_inkas.inkas-code    ), input 0 ).
      run wp-xmltagclose in this-procedure ( input 2, input "card").
    end. /*for each inkas... payment*/

    run wp-XMLHideCNT(hCNT).

    output stream stmxmlout close.
  end.

end procedure. /* export-cardsale-by-object */