block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: shd-docs.p $
$Archive: bge/shd-docs.p $

Экспорт во Внешнюю Бухгалтерию документов и суммарного расхода по чекам.

Автор: Хныкин Павел Андреевич
Дата создания: 03/31/06
Author: Pavel Khnykin
Creation date: 03/31/06

Input:
    p-db-num         as integer    - БД, по объктам которой необходим экспорт
    p-date-from      as date       - начало периода экспорта
    p-date-to        as date       - конец  периода экспорта
    p-range          as integer    - Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов
    p-obj-list       as character  - Список объектов для p-range = 3
    p-doc-type-list  as character  - Список типов операций
    p-pay-code       as logical    - надо ли экспортировать кассовые платежи
    p-cst            as logical    - надо ли экспортировать ГТД из parts
    p-parts          as logical    - надо ли экспортировать parts
    p-chk-pay-code   as logical    - надо ли экспортировать разброс по типам касс платежей
    p-pay-desk       as logical    - надо ли экспортировать разброс по кассам
    p-pay-desk-cards as logical    - надо ли экспортировать разброс по префиксам карт
    p-opened-docs    as logical    - надо ли экспортировать не закрытые документы
    hedt             as handle     -
    hcnt             as handle     -

*/
define input parameter p-db-num         as integer    no-undo.
define input parameter p-date-from      as date       no-undo.
define input parameter p-date-to        as date       no-undo.
define input parameter p-range          as integer    no-undo.
define input parameter p-obj-list       as character  no-undo.
define input parameter p-doc-type-list  as character  no-undo.
define input parameter p-pay-code       as logical    no-undo.
define input parameter p-cst            as logical    no-undo.
define input parameter p-parts          as logical    no-undo.
define input parameter p-chk-pay-code   as logical    no-undo.
define input parameter p-pay-desk       as logical    no-undo.
define input parameter p-pay-desk-cards as logical    no-undo.
define input parameter p-opened-docs    as logical    no-undo.
define input parameter p-doc-rvs        as logical    no-undo. 
define input parameter hedt             as handle     no-undo.
define input parameter hcnt             as handle     no-undo.

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shd-docs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/shd-docs.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию документов и суммарного расхода по чекам.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }

&scop out-file-name "docum":U
&scop version-string "14.0 " + replace( vss-revision + vss-date, "$", " " )

    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */
    define variable v-out-dir           as character            no-undo.
    define variable v-locked            as logical              no-undo.
    define variable v-log-string        as character            no-undo. /* имя log-файла */
    define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-obj-counter       as integer              no-undo.
    define variable v-obj-num           as character            no-undo.
    define variable v-obj-list          as character            no-undo.


do
on error undo, return error
:    
    run bge-xml-out-dir in this-procedure ( output v-out-dir
                                          , output v-log-file-name
                                          ).

    run bge-xml-init-ext-doc-type in this-procedure .
    run bge-xml-read-config in this-procedure ( input p-date-to
                                              , input p-db-num
                                              ) no-error.
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "Ошибка чтения параметров экспорта. &1. &2. Для экспорта данных будут приняты параметры по умолчанию."
                                , return-value, trim( error-status :get-message( 1 ) ) )
        ).
    end.
    run xml-bge-filename in this-procedure (
          input "doc"
        , input "document"
        , input yes
        , output v-xml-file-name
        , output v-log-file-name
        , output v-locked
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки в файл &1", replace( v-xml-file-name, "/", "\" ) + "xm1" )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: Номер базы: &2, дата с: &3, дата по: &4"
                                                      , replace( v-xml-file-name, "/", "\" ) + "xm1"
                                                      , p-db-num
                                                      , p-date-from
                                                      , p-date-to
                                                      )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... список объектов: &1", p-obj-list )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... типы документов: &1", p-doc-type-list )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... надо ли виды платежей: &1, ГТД: &2, партии: &3, типы кассовых платежей: &4, кассы: &5, преф.карт: &6, незакр.документы: &7"
                                                      , p-pay-code
                                                      , p-cst
                                                      , p-parts
                                                      , p-chk-pay-code
                                                      , p-pay-desk
                                                      , p-pay-desk-cards
                                                      , p-opened-docs  )
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
    RUN init-temphost.
    assign
        v-log-string = ", по всем фирмам"
    .
    if p-range <> 3
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input "Неверно заданы объекты для выгрузки."
        ).
        undo, return error .
    end.
    for each temp-obj
    :
        delete temp-obj.
    end.
    do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
    :
        create temp-obj.
        assign
            temp-obj.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
            temp-obj.obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
        no-error .
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input "Ошибка чтения списка объектов."
            ).
            undo, return error .
        end.
        { gbl/hostcode.i temp-obj.obj-type temp-obj.obj-code temp-obj.host-code no-error }
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input "Не найдена фирма для объекта" + temp-obj.obj-type + string( temp-obj.obj-code )
            ).
            undo, return error .
        end.
    end.
    assign
        v-log-string = ", по объектам: " + p-obj-list
    .

    run bge-xml-write-header in this-procedure (
          input v-xml-file-name
        , input v-xml-file-name + "xml"
        , input {&version-string}
        , input p-db-num
        , input p-date-from
        , input 0
        , input p-date-to
        , input 0
        , input p-obj-list
        , input p-doc-type-list
        , input p-pay-code
        , input p-cst
        , input p-parts
        , input p-chk-pay-code
        , input p-pay-desk
        , input p-pay-desk-cards
        , input yes
        , input p-opened-docs
    ).
    object-of-list:
    for each temp-obj
    :
        run export-docs-by-object (   input temp-obj.host-code
                                    , input temp-obj.obj-type
                                    , input temp-obj.obj-code
                                  ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input "Ошибка экспорта документов по объекту " + temp-obj.obj-type + string( temp-obj.obj-code )
            ).
            next object-of-list.
        end.
    end.

    if v-bge-xml-bgeflold <> "oracle"
    then do:
      run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
    end.

    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1 " , replace( v-xml-file-name, "/", "\" ) + "xml" )
    ).
end.

/*==========================================================================*/
procedure export-docs-by-object :
define input parameter p-host-code  as integer      no-undo.
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.

    define variable v-archive-ok            as logical      no-undo.
    define variable v-comment               as character    no-undo.
do
on error undo, return error
:
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input " > Экспорт документов по объекту " + p-obj-type + string( p-obj-code )
    ).
/*---S-------- Расчет архивов на объекте ------------------*/
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 2
        , input "Расчет архивов"
    ).
    run bge/bge-ahzs.p (
          input p-obj-type
        , input p-obj-code
        , input yes
        , input yes
        , input no
        , input p-date-from
        , input p-date-to
        , output v-archive-ok
        , output v-comment
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка проверки архивов на объекте."
        skip "Тип объекта:" p-obj-type
        skip "Код объекта:" p-obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-archive-ok = no
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "*** Документы по объекту &1 &2 в интервале дат &3 - &4 не будут выгружены. Архивы по объекту в заданном интервале дат не целостные. &5."
                                    , p-obj-type
                                    , p-obj-code
                                    , p-date-from
                                    , p-date-to
                                    , v-comment       )
        ).
        undo, return error .
    end.
/*---E-------- Расчет архивов на объекте ------------------*/
/*---S----- Границы fact-order для дат dFrom - dTo --------*/
    run rep/get-fo.p (
          input  p-obj-type
        , input  p-obj-code
        , input  p-date-from
        , input  p-date-to
        , output v-fact-order-from
        , output v-fact-order-to
        , output v-docs-exists
        ) no-error .
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input "*** Ошибка определения границ fact-order для поиска по архивам. " + return-value + ". Объект " + p-obj-type + string( p-obj-code )
        ).
        undo, return error .
    end.
    if v-docs-exists = no
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 2
            , input "В заданном диапазоне дат нет закрытых документов."
        ).
        if p-opened-docs = yes
        then do:
            run bge/doc-opnd.p (
                  input p-host-code
                , input p-obj-type
                , input p-obj-code
                , input p-cst
                , input p-parts
                , input v-xml-file-name
                , input v-log-file-name
                , input this-procedure
                , input hEDT
                , input hCNT
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                      input v-log-file-name
                    , input 1
                    , input "*** Ошибка экспорта незакрытых документов. " + return-value
                ).
            end.
        end.
    end.        /* if v-docs-exists = no */
    else do:
/*---E----- Границы fact-order для дат dFrom - dTo --------*/
        for each temp_ext-doc-type
        :
            if lookup( temp_ext-doc-type.ext-doc-type, p-doc-type-list ) <> 0
            or p-doc-type-list = "":U
            then do:
                run bge/doc-oper.p (
                      input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input temp_ext-doc-type.ext-doc-type
                    , input temp_ext-doc-type.ext-doc-type-label
                    , input v-fact-order-from
                    , input v-fact-order-to
                    , input p-date-from
                    , input p-date-to
                    , input p-pay-code
                    , input p-cst
                    , input p-parts
                    , input p-chk-pay-code
                    , input p-pay-desk
                    , input p-pay-desk-cards
                    , input no
                    , input p-doc-rvs
                    , input v-xml-file-name
                    , input v-log-file-name
                    , input this-procedure
                    , input hEDT
                    , input hCNT
                ) no-error.
                if error-status :error
                then do:
                    run wp-XMLWriteLog in this-procedure (
                          input v-log-file-name
                        , input 1
                        , input "*** Ошибка экспорта документов. " + return-value + "." + trim( error-status :get-message( 1 ) ) + "." + trim( error-status :get-message( 2 ) )
                    ).
                end.
            end.
        end.        /* for each temp_ext-doc-type */
        run bge/doc-deld.p (
              input p-host-code
            , input p-obj-type
            , input p-obj-code
            , input p-date-from
            , input p-date-to
            , input v-xml-file-name
            , input v-log-file-name
            , input hEDT
            , input hCNT
        ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input "*** Ошибка экспорта удаленных документов. " + return-value + "." + trim( error-status :get-message( 1 ) ) + "." + trim( error-status :get-message( 2 ) )
            ).
        end.
        if p-opened-docs = yes
        then do:
            run bge/doc-opnd.p (
                  input p-host-code
                , input p-obj-type
                , input p-obj-code
                , input p-cst
                , input p-parts
                , input v-xml-file-name
                , input v-log-file-name
                , input this-procedure
                , input hEDT
                , input hCNT
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                      input v-log-file-name
                    , input 1
                    , input "*** Ошибка экспорта незакрытых документов. " + return-value
                ).
            end.
        end.        /* if p-opened-docs = yes  */
    end.        /* if NOT( v-docs-exists = no ) */
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input " < Экспорт документов по объекту " + p-obj-type + string( p-obj-code ) + " завершен."
    ).

end.
end procedure. /* export-docs-by-object */


/*==========================================================================*/
procedure cb-fill_bge-xml_goods :
define input parameter p-gds-code   as integer          no-undo.

do
on error undo, return error
:
    find first temp_bge-xml_goods
         where temp_bge-xml_goods.gds-code = p-gds-code
    no-error.
    if not available temp_bge-xml_goods
    then do:
        create temp_bge-xml_goods.
        assign
            temp_bge-xml_goods.gds-code = p-gds-code
        .
    end.
end.
end procedure. /* cb-fill_bge-xml_goods */