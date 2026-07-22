block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcs-bcod.p $
$Archive: rcs/rcs-bcod.p $

Экспорт бар-кодов во внешнюю систему

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/09/05
Author: Victor Guntner
Creation date: 09/09/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-xml-file-name      as character        no-undo.
define input parameter p-date               as date             no-undo. /* день экспорта */
define input parameter p-range              as integer          no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-obj-list           as character        no-undo. /* Список объектов для p-range = 3 */
define input parameter p-ed                 as handle           no-undo.
define input parameter p-fi                 as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcs-bcod.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcs-bcod.p $":U .
define variable vss-description as character no-undo init "Экспорт бар-кодов во внешнюю систему".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ rcs/rcs-xml.i  }
{ rcs/rcsfunc.i  }

&global-define TabSpaces 4
&global-define LogLineSize 80

    define variable v-counter           as integer           no-undo.
    define variable v-log-file-name     as character         no-undo.
    define variable v-destination-rowid as character         no-undo.
    define variable v-good-counter      as integer           no-undo.
    define variable v-product-id        as character         no-undo.
    define variable v-have-prod-bc      as logical  init no  no-undo.

    define buffer buf_rcs-shops             for rcs-shops.
    define buffer buf_gds-obj               for gds-obj.
    define buffer buf_goods                 for goods.
    define buffer buf_units                 for units.
    define buffer buf_rcs-retail1product    for rcs-retail1product.
    define buffer buf_prod-bc               for prod-bc.
    define buffer buf_bar-code              for bar-code.
do
for buf_rcs-shops
  , buf_gds-obj
  , buf_goods
  , buf_units
  , buf_rcs-retail1product
  , buf_prod-bc
  , buf_bar-code
on error undo, return error
:
    ASSIGN v-log-file-name = p-xml-file-name + ".log".
/*Шапка XML*/
    run get-destination-id in this-procedure (
          input "RETAIL1_TH_PRODUCT"
        , output v-destination-rowid
    ) no-error.
    if error-status :error
    or v-destination-rowid = ""
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось получить DESTINATION-ROWID для RETAIL1_BARCODE."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.


    run rcs-xml-write-header in this-procedure (
              input 1
            , input p-xml-file-name
            , input v-destination-rowid
            , input ""
            , input ""
    ) no-error .
    if error-status :error
    then do:
        undo, return error "rcs-docs: Ошибка записи заголовка файла." + {&new-line} + return-value.
    end.

/* Экспорт */
    output stream stmXMLHead to value( p-xml-file-name + ".xm1") convert target "1251" append.

    for each buf_units no-lock
/*       where buf_units.type = {&weight}*/
    :
        for each buf_goods no-lock
           where buf_goods.unit-base = buf_units.unit-name
        :
            assign
                v-good-counter = v-good-counter + 1
                v-have-prod-bc = no
            .
            find first buf_rcs-retail1product no-lock
                 where buf_rcs-retail1product.gds-code = buf_goods.gds-code
            no-error.
            if not available buf_rcs-retail1product
            then do:
                run write-to-log-editor in this-procedure ( p-ed, v-log-file-name, 1, "Товар с кодом " + string( buf_goods.gds-code ) + " не был импортирован." ).
                assign
                    v-product-id = "0"
                .
            end.
            else do:
                assign
                    v-product-id = buf_rcs-retail1product.id
                .
            end.
            for each buf_prod-bc no-lock
               where buf_prod-bc.b-code   = buf_goods.gds-code
            :
                assign
                    v-have-prod-bc = yes
                .
                run process-result in this-procedure (
                      input v-product-id
                    , input buf_goods.gds-code
                    , input buf_prod-bc.b-str
                    , input buf_goods.prod-code
                    , input buf_goods.prod-type
                    , input buf_goods.artic
                    , input buf_goods.gds-name
                ) no-error.
                if error-status :error
                then do:
                    message
                      vss-workfile vss-revision vss-description
                      skip "Ошибка при выводе бар-кодов для товара с ID " + v-product-id +  ", кодом " + string( buf_goods.gds-code )
                      skip return-value
                      skip trim(error-status :get-message(1))
                           trim(error-status :get-message(2))
                           trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
                if v-good-counter modulo 25 = 0
                then do:
                    run wp-XMLWriteCnt( p-fi, "Единица измерения: " + buf_units.unit-name + ". Бар-код для товара с ID " + v-product-id +  "  " + string( v-good-counter ) ).
                    process events.
                end.
            end.
            if v-have-prod-bc = no      /* Если нет доп. бар-кодов, выгрузить основной */
            then do:
                for each buf_bar-code no-lock
                   where buf_bar-code.gds-code  = buf_goods.gds-code
                :
                    run process-result in this-procedure (
                          input v-product-id
                        , input buf_goods.gds-code
                        , input string( buf_bar-code.b-code )
                        , input buf_goods.prod-code
                        , input buf_goods.prod-type
                        , input buf_goods.artic
                        , input buf_goods.gds-name
                    ) no-error.
                    if error-status :error
                    then do:
                        message
                        vss-workfile vss-revision vss-description
                        skip "Ошибка при выводе основного бар-кода для товара с ID " + v-product-id +  ", кодом " + string( buf_goods.gds-code )
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                        view-as alert-box error.
                        undo, return error .
                    end.
                    if v-good-counter modulo 25 = 0
                    then do:
                        run wp-XMLWriteCnt( p-fi, "Единица измерения: " + buf_units.unit-name + ". Бар-код для товара с ID " + v-product-id +  "  " + string( v-good-counter ) ).
                        process events.
                    end.
                end.
            end.        /* if v-have-prod-bc = no */
        end.        /* for each buf_goods */
    end.        /* for each buf_units */

    output stream stmXMLHead close.

/* Закрыть тэги шапки*/

    run rcs-xml-write-footer in this-procedure (
              input 1
            , input p-xml-file-name
            , input ""
    ) no-error .
    if error-status :error
    then do:
        undo, return error "rcs-docs: Ошибка окончания записи файла." + {&new-line} + return-value.
    end.
end.

/*==========================================================================*/
procedure process-result :
do
on error undo, return error
:
define input parameter p-product-id as character    no-undo.
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-barcode    as character    no-undo.
define input parameter p-prod-code  as integer      no-undo.
define input parameter p-prod-type  as character    no-undo.
define input parameter p-artic      as character    no-undo.
define input parameter p-gds-name   as character    no-undo.
    run wp-xmltagopen( 1, 1, "ROW","").
        run wp-xmltagput( 1, 2, "PRODUCT_ID"    , string( p-product-id ), 0 ).
        run wp-xmltagput( 1, 2, "WEIGHT_CODE"   , string( p-barcode    ), 0 ).
        run wp-xmltagput( 1, 2, "gdsCode"       , string( p-gds-code   ), 0 ).
        run wp-xmltagput( 1, 2, "PRODUCER_CODE" , string( p-prod-code  ), 0 ).
        run wp-xmltagput( 1, 2, "PRODUCER_TYPE" , string( p-prod-type  ), 0 ).
        run wp-xmltagput( 1, 2, "ARTICUL"       , string( p-artic      ), 0 ).
        run wp-xmltagput( 1, 2, "NAME"          , string( p-gds-name   ), 0 ).
    run wp-xmltagclose( 1, 1, "ROW").
end.
end procedure. /* eval-sum-and-write-result */

PROCEDURE write-to-log-editor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  define input parameter hedt               as handle       no-undo.
  define input parameter p-log-file-name    as character    no-undo.
  define input parameter iloglevel          as integer      no-undo.
  define input parameter stowrite           as character    no-undo.
/*
  Процедура выводит запись в EDITOR, определенный параметром hEDT.
  Запись выглядит следующим образом:
     <Текущая дата><Пробелы, определяемые параметром iLogLevel><sToWrite>
  Специальные значения для iLogLevel:
       0 - не выводить дату (1 - без отступа)
  Специальные значения для sToWrite:
      "&Line"  - Вывести разделительную линию из символов "-"
      "&DLine" - Вывести разделительную линию из символов "="
    Длина разделительных линий задается в LogLineSize.
*/
    if valid-handle ( hedt )
    then do:
        hedt :move-to-eof().
        hedt :insert-string( if ( iloglevel = 0
                             or stowrite = "&dline"
                             or stowrite = "&line" )
                             then ""
                             else cur-time-string-sec() + " "
                           ).
        hedt :insert-string( if stowrite = "&line"
                             then fill("-", {&loglinesize} )
                             else if stowrite = "&dline"
                             then fill("=", {&loglinesize})
                             else fill(" ", iloglevel) + stowrite).
        hedt :insert-string({&new-line}).
    end.
    output to p-log-file-name append.
    put unformatted
        skip {&new-line} cur-time-string-sec() fill(" ", iloglevel) stowrite
    .
    output close.
end.
END PROCEDURE. /* write-to-log-editor */