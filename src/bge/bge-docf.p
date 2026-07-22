block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: bge-docf.p $
$Archive: bge/bge-docf.p $

Экспорт XML документов с разбивкой по фирмам

Автор: Хныкин Павел Андреевич
Дата создания: 02/22/06
Author: Pavel Khnykin
Creation date: 02/22/06

Input:
    p-date-from       as date       -  начало периода экспорта
    p-date-to         as date       -  конец  периода экспорта
    p-range           as integer    -  Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов
    p-obj-list        as character  -  Список объектов для p-range = 3
    p-doc-type-list   as character  -  Список типов операций
    p-pay-code        as logical    -  надо ли экспортировать кассовые платежи
    p-cst             as logical    -  надо ли экспортировать ГТД из parts
    p-parts           as logical    -  надо ли экспортировать parts
    p-chk-pay-code    as logical    -  надо ли экспортировать разброс по типам касс платежей
    p-pay-desk        as logical    -  надо ли экспортировать разброс по кассам
    p-pay-desk-cards  as logical    -  надо ли экспортировать разброс по префиксам карт
    p-deleted         as logical    -  надо ли экспортировать удаленные документы
    p-chk             as logical    -  надо ли экспортировать чеки
    p-doc-rvs         as logical    -  надо ли выгружать сверки до/после слива по топливным приходным накладным
    p-opened-docs     as logical    -  надо ли экспортировать не закрытые документы
    hedt              as handle     -
    hcnt              as handle     -

Output:

*/
define input parameter parparentproc    as handle               no-undo.
define input parameter p-date-from      as date                 no-undo.
define input parameter p-date-to        as date                 no-undo.
define input parameter p-range          as integer              no-undo.
define input parameter p-obj-list       as character            no-undo.
define input parameter p-doc-type-list  as character            no-undo.
define input parameter p-pay-code       as logical              no-undo.
define input parameter p-cst            as logical              no-undo.
define input parameter p-parts          as logical              no-undo.
define input parameter p-chk-pay-code   as logical              no-undo.
define input parameter p-pay-desk       as logical              no-undo.
define input parameter p-pay-desk-cards as logical              no-undo.
define input parameter p-deleted        as logical              no-undo.
define input parameter p-chk            as logical              no-undo.
define input parameter p-doc-rvs        as logical              no-undo. 
define input parameter p-opened-docs    as logical              no-undo.
define input parameter hedt             as handle               no-undo.
define input parameter hcnt             as handle               no-undo.

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-docf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-docf.p $":U .
define variable vss-description as character no-undo init "Экспорт XML документов с разбивкой по фирмам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }
{ gbl/getcntxt.i def }

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

define temp-table temp_firm no-undo

    field host-code  as integer

    index pi is primary unique
        host-code
.

    define variable v-xml-home-dir      as character    no-undo. /* каталог вывода */
    define variable v-xml-out-dir       as character    no-undo. /* каталог вывода */
    define variable v-xml-file-name     as character    no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character    no-undo. /* имя log-файла */
    define variable v-locked            as logical      no-undo.
    define variable v-log-string        as character    no-undo. /* имя log-файла */
    define variable v-fact-order-from   as decimal      no-undo.
    define variable v-fact-order-to     as decimal      no-undo.
    define variable v-docs-exists       as logical      no-undo.
    define variable v-obj-counter       as integer      no-undo.
    define variable v-db-num            as integer      no-undo.
    define variable v-yesno             as logical      no-undo.
    define variable v-prefix            as character    no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-command           as character    no-undo.
    define variable v-bat-file-path     as character    no-undo.


    define buffer buf_temp_firm     for temp_firm.
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
      true
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
    when 1      /* Экспорт по всем фирмам БД */
    then do:
        for each temp-obj
        :
            find first buf_temp_firm
                 where buf_temp_firm.host-code = temp-obj.host-code
            no-error.
            if not available buf_temp_firm
            then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_documents_export':U
                  {&cntxt-firm}
                  temp-obj.host-code
                  '':U
                  0
                  0
                  0
                  0
                  false
                  v-yesno
                }
                if v-yesno = yes
                then do:
                    create buf_temp_firm.
                    assign
                        buf_temp_firm.host-code = temp-obj.host-code
                    .
                end.
            end.
        end.
    end.        /* when 1 */
    when 2      /* Экспорт по текущей фирме */
    then do:
        create buf_temp_firm.
        assign
            buf_temp_firm.host-code = v-cntxt-host-code-obj
        .
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
            find first buf_temp_firm
                 where buf_temp_firm.host-code = temp-obj.host-code
            no-error.
            if not available buf_temp_firm
            then do:
                create buf_temp_firm.
                assign
                    buf_temp_firm.host-code = temp-obj.host-code
                .
            end.
        end.        /* do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2 */
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
    run bge-xml-out-dir in this-procedure (
          output v-xml-home-dir
        , output v-log-file-name
    ).
    export-by-firm:
    for each buf_temp_firm
    on error undo, return error
    :
        run wp-XMLWriteEDT( hEDT, 1, substitute( "*** Экспорт по фирме: &1 ***", buf_temp_firm.host-code ) ).
        process events.
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
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input "&DLine"
        ).
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "Начало выгрузки в файл &1"
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
        if v-locked = yes
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input "*** Ошибка выгрузки: Файл выгрузки заблокирован другим процессом."
            ).
            undo, return error .
        end.
        run bge-xml-write-header in this-procedure (
              input v-xml-file-name
            , input v-xml-file-name + "xml":U
            , input {&version-string}
            , input 0
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
            , input p-deleted
            , input p-opened-docs
        ).
        object-of-list:
        for each temp-obj
           where temp-obj.host-code = buf_temp_firm.host-code
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
            run cb-fill_bge-xml_clients in this-procedure (
                  input temp-obj.obj-type
                , input temp-obj.obj-code
            ).
        end.        /* for each temp-obj */
        run bge/cat-firm.p (
              input "list":U
            , input v-cntxt-host-code-obj
            , input table temp_bge-xml_clients
            , ""
        ).
        run bge/cat-good.p (
              input "good-ext,list":U
            , input table temp_bge-xml_goods
            , ""
        ).
        run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "Данные выгружены в файл &1"
                                    , replace( v-xml-file-name, "/":U, "\":U ) + "xml":U
                            )
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
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input "&DLine"
        ).
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
                    run wp-XMLWriteEDT( hEDT, 1, substitute( "&1. &2. &3."
                                            , return-value
                                            , trim(error-status :get-message(1))
                                            , trim(error-status :get-message(2))
                                            )  ).
                end.
            end.
        end.        /* for each temp_ext-doc-type */
        run wp-XMLHideCNT(hCNT).
    end.        /* NOT ( if v-docs-exists = no ) */
    if p-deleted = yes
    then do:
        run wp-XMLShowCNT(hCNT).
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
            run wp-XMLWriteEDT( hEDT, 1, substitute( "&1. &2. &3."
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                    )  ).
        end.
        run wp-XMLHideCNT(hCNT).
    end.
    process events.
    if p-opened-docs = yes
    then do:
        run wp-XMLShowCNT(hCNT).
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
            run wp-XMLWriteEDT( hEDT, 1, substitute( "&1. &2. &3."
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                    )  ).
        end.
        run wp-XMLHideCNT(hCNT).
    end.
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