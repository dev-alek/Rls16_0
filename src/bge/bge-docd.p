block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: bge-docd.p $
$Archive: bge/bge-docd.p $

Экспорт во Внешнюю Бухгалтерию документов с выводом в dbf

Автор: Хныкин Павел Андреевич
Дата создания: 10/13/05
Author: Pavel Khnykin
Creation date: 10/13/05

Input:

Output:

*/
define input parameter parparentproc    as handle               no-undo.
define input parameter p-date-from      as date       no-undo. /* начало периода экспорта */
define input parameter p-date-to        as date       no-undo. /* конец  периода экспорта */
define input parameter p-range          as integer    no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-obj-list       as character  no-undo. /* Список объектов для p-range = 3 */
define input parameter p-doc-type-list  as character  no-undo. /* Список типов операций */
define input parameter p-pay-code       as logical    no-undo. /* надо ли экспортировать кассовые платежи */
define input parameter p-cst            as logical    no-undo. /* надо ли экспортировать ГТД из parts */
define input parameter p-parts          as logical    no-undo. /* надо ли экспортировать parts */
define input parameter p-chk-pay-code   as logical    no-undo. /* надо ли экспортировать разброс по типам касс платежей*/
define input parameter p-pay-desk       as logical    no-undo. /* надо ли экспортировать разброс по кассам */
define input parameter p-pay-desk-cards as logical    no-undo. /* надо ли экспортировать разброс по префиксам карт */
define input parameter p-deleted        as logical    no-undo. /* надо ли экспортировать удаленные документы */
define input parameter p-chk            as logical    no-undo. /* надо ли выгружать чеки */
define input parameter p-doc-rvs        as logical    no-undo. /* надо ли выгружать сверки до/после слива по топливным приходным накладным */
define input parameter p-opened-docs    as logical    no-undo. /* надо ли экспортировать не закрытые документы */
define input parameter hedt             as handle     no-undo.
define input parameter hcnt             as handle     no-undo.

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-docd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-docd.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию документов с выводом в dbf".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ gbl/filelist.i        }
{ gbl/temphost.i        }
{ bge/bge-xml.i         }
{ gbl/dbflib.i          }
{ gbl/getcntxt.i def    }

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

define stream in-stream.

    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */
    define variable v-locked            as logical              no-undo.
    define variable v-log-string        as character            no-undo. /* имя log-файла */
    define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-obj-counter       as integer              no-undo.
    define variable v-db-num            as integer              no-undo.
    define variable v-yesno             as logical              no-undo.
do
on error undo, return error return-value
:
    { gbl/getcntxt.i get }
    run bge-xml-init-ext-doc-type in this-procedure .
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_documents_export':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    yes
    v-yesno
    }
    if v-yesno = no
    then do:
        return error.
    end.
    run init-temphost.
    assign
        v-log-string = ", по всем фирмам"
    .
    case p-range:
    when 2      /* Экспорт по текущей фирме */
    then do:
        for each temp-obj
        where temp-obj.host-code <> v-cntxt-host-code-obj
        :
            delete temp-obj.
        end.
        assign
            v-log-string = ", по фирме (код фирмы " + string( v-cntxt-host-code-obj ) + ")"
        .
    end.
    when 3      /* Экспорт по списку объектов */
    then do:
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
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка чтения списка объектов"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
            { gbl/hostcode.i temp-obj.obj-type temp-obj.obj-code temp-obj.host-code no-error }
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Не найдена фирма для объекта" temp-obj.obj-type temp-obj.obj-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        assign
            v-log-string = ", по объектам: " + p-obj-list
        .

    end.
    end case.
    run bge-xml-read-config in this-procedure ( input p-date-to
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
          input "doc"
        , input "document"
        , input "no"
        , output v-xml-file-name
        , output v-log-file-name
        , output v-locked
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки в DBF" )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: Дата с: &1, дата по: &2"
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
        , input substitute( "................с параметрами: ... надо ли виды платежей: &1, ГТД: &2, партии: &3, типы кассовых платежей: &4, кассы: &5, преф.карт: &6, удал.документы: &7, незакр.документы: &8"
                                                      , p-pay-code
                                                      , p-cst
                                                      , p-parts
                                                      , p-chk-pay-code
                                                      , p-pay-desk
                                                      , p-pay-desk-cards
                                                      , p-deleted
                                                      , p-opened-docs )
    ).
    object-of-list:
    for each temp-obj
    :
        run export-docs-by-object (
              input temp-obj.host-code
            , input temp-obj.obj-type
            , input temp-obj.obj-code
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка экспорта документов по объекту"
            skip "Тип объекта:" temp-obj.obj-type
            skip "Код объекта:" temp-obj.obj-code
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            next object-of-list.
        end.
/*        run cb-fill_bge-xml_clients in this-procedure (*/
/*              input temp-obj.obj-type*/
/*            , input temp-obj.obj-code*/
/*        ).*/
    end.        /* for each temp-obj */
/*    r u n   c a t - f i r m . p (*/
/*          input "list":U*/
/*        , input v-cntxt-host-code-obj*/
/*        , input table temp_bge-xml_clients*/
/*    ).*/
/*    r u n   c a t - g o o d . p (*/
/*          input "good-ext,list":U*/
/*        , input table temp_bge-xml_goods*/
/*    ).*/
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в .D - файлы. Идёт преобразование в DBF..." )
    ).
    run convert-to-dbf in this-procedure (
          input v-xml-file-name
        , input v-log-file-name
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные преобразованы в DBF" )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
end.

/*==========================================================================*/
procedure export-docs-by-object :
define input parameter p-host-code  as integer      no-undo.
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.

    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.
    define variable v-err-message       as character    no-undo.
do
on error undo, return error return-value
:
    run wp-XMLWriteEDT( hEDT, 1, string( p-obj-type ) + " " + string( p-obj-code ) ).

/*---S-------- Расчет архивов на объекте ------------------*/
    run wp-XMLWriteEDT( hEDT, 4,  "Расчет архивов").
    run bge/bge-ahz.p (
          input parparentproc
        , input p-obj-type
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
        assign
            v-err-message = substitute( "*** Документы по объекту &1 &2 в интервале дат &3 - &4 не будут выгружены. Архивы по объекту в заданном интервале дат не целостные. &5."
                                    , p-obj-type
                                    , p-obj-code
                                    , p-date-from
                                    , p-date-to
                                    , v-comment       )
        .
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input v-err-message
        ).
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip v-err-message
        view-as alert-box error.
        undo, return error.
    end.
    process events.
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
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка определения границ fact-order для поиска по архивам"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    if v-docs-exists = no
    then do:
        run wp-XMLWriteEDT( hEDT, 4, "В заданном диапазоне дат нет закрытых документов").
    end.        /* if v-docs-exists = no */
    else do:
        run wp-XMLShowCNT(hCNT).
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
                    , input p-chk
                    , input p-doc-rvs
                    , input v-xml-file-name
                    , input v-log-file-name
                    , input this-procedure
                    , input hEDT
                    , input hCNT
                ) no-error.
                if error-status :error
                then do:
                    run wp-XMLWriteEDT(
                          input hEDT
                        , input 1
                        , input substitute( "Ошибка экспорта документов. &1. &2. &3."
                                            , return-value
                                            , trim(error-status :get-message( 1 ) )
                                            , trim(error-status :get-message( 2 ) ) )
                    ).
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка экспорта документов."
                        skip return-value
                        skip trim( error-status :get-message( 1 ) )
                             trim( error-status :get-message( 2 ) )
                             trim( error-status :get-message( 3 ) )
                    view-as alert-box error.
                    undo, return error.
                end.
            end.
        end.        /* for each temp_ext-doc-type */
        run wp-XMLHideCNT(hCNT).
    end.        /* NOT ( if v-docs-exists = no ) */
    process events.
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


/*==========================================================================*/
procedure cb-fill_bge-xml_clients :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.

    define buffer buf_temp_bge-xml_clients      for temp_bge-xml_clients.
do
for buf_temp_bge-xml_clients
on error undo, return error
:
    find first buf_temp_bge-xml_clients
         where buf_temp_bge-xml_clients.obj-type = p-obj-type
           and buf_temp_bge-xml_clients.obj-code = p-obj-code
    no-error.
    if not available buf_temp_bge-xml_clients
    then do:
        create buf_temp_bge-xml_clients.
        assign
            buf_temp_bge-xml_clients.obj-type = p-obj-type
            buf_temp_bge-xml_clients.obj-code = p-obj-code
        .
    end.
end.
end procedure. /* cb-fill_bge-xml_goods */


/*==========================================================================*/
procedure convert-to-dbf :
define input parameter p-dir-name       as character        no-undo.
define input parameter p-log-filename   as character        no-undo.

    define variable v-field-name     as character    no-undo.
    define variable v-field-length   as integer      no-undo.
    define variable v-field-value    as character    no-undo.

    define buffer buf_temp-filelist     for temp-filelist.
do
for buf_temp-filelist
on error undo, return error return-value
:
    run filelist-clear in this-procedure .
    run filelist-init in this-procedure (
          input p-dir-name
        , input yes
        , input "d":U
        , input ?
    ).
    for each buf_temp-filelist
    :
        input stream in-stream from value( buf_temp-filelist.full-name ).
        case substring( buf_temp-filelist.file-name, 1, 4 )
        :
            when "head":U           /* Шапка документа */
            or when "hpss":U        /* Переоценка, тэг saleSum */
            or when "hcss":U        /* Коды оплат paycode, тэг CassSum */
            or when "hdsm":U        /* Цены документа, тэг docSum */
            or when "hcsm":U        /* Учётные цены, тэг costSum */
            or when "hssm":U        /* Цены продажи, тэг saleSum */
            or when "hbiv":U        /* Суммы до инвентаризации, тэг beforeSum */
            or when "haiv":U        /* Суммы после инвентаризации, тэг afterSum */
            or when "hspc":U        /* По поставщикам и кодам оплат в учётных ценах */
            or when "hsps":U        /* По поставщикам и кодам оплат в ценах документа */
            or when "lhdr":U        /* Строка документа */
            or when "ldtl":U        /* Признаки товара */
            or when "lprt":U        /* Партии товара */
            or when "ldsm":U        /* Цены документа, тэг docSum */
            or when "lcsm":U        /* Учётные цены, тэг costSum */
            or when "lssm":U        /* Цены продажи, тэг saleSum */
            or when "lbiv":U        /* Суммы до инвентаризации, тэг beforeSum */
            or when "laiv":U        /* Суммы после инвентаризации, тэг afterSum */
            or when "lspc":U        /* По поставщикам и кодам оплат в учётных ценах */
            or when "lsps":U        /* По поставщикам и кодам оплат в ценах документа */
            then do:
                run dbflib-init in this-procedure.
                repeat:
                    import stream in-stream
                        v-field-name
                        v-field-value
                    .
                    if v-field-value = ?
                    then do:
                        assign
                            v-field-value = "":U
                            v-field-length = 0
                        .
                    end.
                    else do:
                        assign
                            v-field-length = length( v-field-value )
                        .
                    end.
                    run dbflib-add-field in this-procedure (
                          input v-field-name
                        , input 255
                        , input "character":U
                        , input 0
                    ).
                    run dbflib-add-data in this-procedure (
                          input 1
                        , input v-field-name
                        , input v-field-value
                    ).
                end.
                run dbflib-write-dbf in this-procedure (
                    input substitute( "&1/&2.dbf":U, p-dir-name, buf_temp-filelist.file-name-no-ext )
                  , input 1
                ) no-error.
                if error-status :error
                then do:
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка записи файла формата dbf."
                        skip return-value
                        skip trim( error-status :get-message( 1 ) )
                             trim( error-status :get-message( 2 ) )
                             trim( error-status :get-message( 3 ) )
                    view-as alert-box error.
                    undo, return error.
                end.
            end.        /* when "hd":U */
        end case.       /* case file-name */
        input stream in-stream close.
        os-delete value( buf_temp-filelist.full-name ).
    end.
end.
end procedure. /* convert-to-dbf */