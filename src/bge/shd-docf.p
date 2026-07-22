block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: shd-docf.p $
$Archive: bge/shd-docf.p $

Экспорт во Внешнюю Бухгалтерию документов и суммарного расхода по чекам

Автор: Хныкин Павел Андреевич
Дата создания: 05/12/06
Author: Pavel Khnykin
Creation date: 05/12/06

Input:

Output:

*/
define input parameter p-db-num         as integer    no-undo.    /* БД, по объктам которой необходим экспорт */
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
define input parameter p-opened-docs    as logical    no-undo. /* надо ли экспортировать не закрытые документы */
define input parameter p-doc-rvs        as logical    no-undo. /* надо ли выгружать сверки до/после слива по топливным приходным накладным */
define input parameter hedt             as handle     no-undo.
define input parameter hcnt             as handle     no-undo.

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shd-docf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/shd-docf.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию документов и суммарного расхода по чекам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }

define new shared variable to-arm        as character           no-undo.
define new shared variable g#host-code   as integer             no-undo.

define temp-table temp_firm no-undo

    field host-code  as integer
    field enabled    as logical

    index pi is primary unique
        host-code
.

&scop out-file-name "docum"
&scop version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */
    define variable v-locked            as logical              no-undo.
    define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-obj-counter       as integer              no-undo.

    define variable v-xml-home-dir      as character    no-undo. /* каталог вывода */
    define variable v-xml-out-dir       as character    no-undo. /* каталог вывода */
    define variable v-prefix            as character    no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-command           as character    no-undo.
    define variable v-bat-file-path     as character    no-undo.
    define variable v-obj-type          as character    no-undo.
    define variable v-obj-code          as integer      no-undo.
    define variable v-host-code         as integer      no-undo.
    define variable v-yesno             as logical      no-undo.

    define buffer buf_temp_firm     for temp_firm.
do
for buf_temp_firm
on error undo, return error
:
    run bge-xml-out-dir in this-procedure ( output v-xml-home-dir
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
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки в каталог &1", v-xml-home-dir )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: Номер базы: &1, дата с: &2, дата по: &3"
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
    object-of-user:
    do
    v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
    :
        assign
            v-obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
            v-obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
        no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input substitute( "Ошибка чтения списка объектов. &1."
                                    , trim( error-status :get-message( 1 ) ) )
            ).
            undo, return error .
        end.
        { gbl/hostcode.i
            v-obj-type
            v-obj-code
            v-host-code
        no-error }
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input substitute( "*** Ошибка заданных параметров: Не найдена фирма для объекта &1 &2. &3. &4"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , trim( error-status :get-message( 1 ) )
                                , trim( error-status :get-message( 2 ) ) )
            ).
            next object-of-user.
        end.
        find first buf_temp_firm
             where buf_temp_firm.host-code = v-host-code
        no-error.
        if not available buf_temp_firm
        then do:
            create buf_temp_firm.
            assign
                buf_temp_firm.host-code = v-host-code
                g#host-code             = v-host-code
                buf_temp_firm.enabled   = yes
            .
        end.        /* if not available buf_temp_firm */
        if buf_temp_firm.enabled = no
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input substitute( "*** Недостаточно прав на фирме &1 для экспорта объекта &2 &3."
                                , v-host-code
                                , v-obj-type
                                , v-obj-code )
            ).
        end.        /* if buf_temp_firm.enabled = no  */
        else do:
            create temp-obj.
            assign
                temp-obj.obj-type   = v-obj-type
                temp-obj.obj-code   = v-obj-code
                temp-obj.host-code  = v-host-code
            .
        end.        /* NOT ( if buf_temp_firm.enabled = no  ) */
    end.
    export-by-firm:
    for each buf_temp_firm
       where buf_temp_firm.enabled = yes
    on error undo, return error
    :
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "  Экспорт по фирме: &1 "
                            , buf_temp_firm.host-code )
        ).
        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        assign
            v-xml-out-dir   = substitute( "&1/&2" , v-xml-home-dir, trim( string( buf_temp_firm.host-code ) ) )
            v-prefix        = substitute( "d&1_&2&3&4_"
                                        , trim( string( buf_temp_firm.host-code ) )
                                        , string( year( v-today ), "9999" )
                                        , string( month( v-today ), "99"  )
                                        , string( day( v-today ), "99" )
                                        )
        .
        run gbl/dir-cre.p (
            input v-xml-out-dir
        ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input substitute( "*** Ошибка создания каталога. &1. &2. &3. &4."
                                    , v-xml-out-dir
                                    , return-value
                                    , trim( error-status :get-message( 1 ) )
                                    , trim( error-status :get-message( 2 ) )
                                  )
            ).
            undo export-by-firm, next export-by-firm.
        end.
        run bge-xml-out-file in this-procedure (
              input v-xml-out-dir
            , input v-prefix
            , input no
            , output v-xml-file-name
            , output v-locked
        ).
        if v-locked = yes
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input "*** Ошибка выгрузки: Файл выгрузки заблокирован другим процессом."
            ).
            undo export-by-firm, next export-by-firm.
        end.
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
           where temp-obj.host-code = buf_temp_firm.host-code
        on error undo object-of-list, next object-of-list
        :
            run export-docs-by-object (
                  input temp-obj.host-code
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
        run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
        run wp-XMLWriteLog in this-procedure (
            input v-log-file-name
            , input 1
            , input substitute( "Данные выгружены в файл &1 " , replace( v-xml-file-name, "/", "\" ) + "xml" )
        ).
        assign
            v-bat-file-path = search( "expfirm.bat" )
        .
        if v-bat-file-path = ?
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input substitute( "*** Не найден файл expfirm.bat. Окончательная обработка выгруженного файла невозможна. Могут быть ошибки при последующих выгрузках." )
            ).
        end.
        else do:
            assign
                file-info :file-name    = v-bat-file-path
            .
            assign
                v-command       = substitute( '&1 "&2arj" "&2xml"':U
                                        , trim( file-info :full-pathname )
                                        , replace( v-xml-file-name, "/":U, "\":U ) )
            .
/*            output to d:\111.bat.*/
/*            put unformatted v-command .*/
/*            output close.*/
            os-command value( v-command ).
        end.
    end.        /* for each buf_temp_firm */
end.

/*==========================================================================*/
procedure export-docs-by-object :
define input parameter p-host-code  as integer      no-undo.
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.

    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.
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
    run bge/shd-ahz.p (
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