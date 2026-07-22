block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: bgedocs.p $
$Archive: bge/bgedocs.p $

Экспорт документов производства (плоский)

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:
    p-date-from      as date      - начало периода экспорта
    p-date-to        as date      - конец  периода экспорта
    p-range          as integer   - Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов
    p-obj-list       as character - Список объектов для p-range = 3
    p-doc-type-list  as character - Список типов операций
    p-pay-code       as logical   - надо ли экспортировать кассовые платежи
    p-cst            as logical   - надо ли экспортировать ГТД из parts
    p-parts          as logical   - надо ли экспортировать parts
    p-chk-pay-code   as logical   - надо ли экспортировать разброс по типам касс платежей
    p-pay-desk       as logical   - надо ли экспортировать разброс по кассам
    p-pay-desk-cards as logical   - надо ли экспортировать разброс по префиксам карт
    p-deleted        as logical   - надо ли экспортировать удаленные документы
    p-opened-docs    as logical   - надо ли экспортировать не закрытые документы
    hedt             as handle    - handle поля лога
    hcnt             as handle    - handle поля счетчика

*/

define input parameter p-mainmenu-handle as handle           no-undo.
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
define input parameter p-deleted        as logical    no-undo.
define input parameter p-opened-docs    as logical    no-undo.
define input parameter hedt             as handle     no-undo.
define input parameter hcnt             as handle     no-undo.

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 10 12:04:11 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bgedocs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bgedocs.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию документов и суммарного расхода по чекам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bgelib.i   }
{ gbl/getcntxt.i def }

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )
&scoped-define parameters-amount 12

    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */
    define variable v-list-file-name    as character            no-undo. /* имя log-файла */
    define variable v-xml-file-number   as integer              no-undo.
    define variable v-log-string        as character            no-undo. /* имя log-файла */
    define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-obj-counter       as integer              no-undo.
    define variable v-db-num            as integer              no-undo.
    define variable v-cancel            as logical              no-undo.
    define variable v-space-available   as logical              no-undo.
    define variable v-yesno             as logical              no-undo.
    define variable v-parameter-list    as character            no-undo.


do
on error undo, return error
:
    run bgelib-init-ext-doc-type in this-procedure .
    { gbl/getcntxt.i get " " p-mainmenu-handle }
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
                view-as alert-box error.
                undo, return error .
            end.
        end.
        assign
            v-log-string = ", по объектам: " + p-obj-list
        .
    end.
    end case.
    run bgelib-filename in this-procedure (
          input "doc"
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
        , input substitute( "Начало выгрузки в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + {&bgelib-temp-extension}
                          )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: Дата с: &1, дата по: &2"
                                , p-date-from
                                , p-date-to
                          )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... список объектов: &1", p-obj-list )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... типы документов: &1", p-doc-type-list )
    ).
    run bgelib-write-log in this-procedure (
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
    assign
        v-parameter-list         =  substitute( "&1,&2,&3,&4,&5,&6,&7,&8,&9"
                                               , {&parameters-amount}
                                               , "docName"          , "document":U
                                               , "version"          , replace({&version-string},',','')
                                               , "exportDate"       , string( today,          "99/99/9999" )
                                               , "exportTime"       , string( time,           "HH:MM:SS"   )
                                              )
                                  + substitute( ",&1,&2,&3,&4,&5,&6,&7,&8"
                                               , "baseNum"          , 0
                                               , "dateFrom"         , string( p-date-from,    "99/99/9999" )
                                               , "dateto"           , string( p-date-to,      "99/99/9999" )
                                               , "needPaySupp"      , p-pay-code
                                              )
                                  + substitute( ",&1,&2,&3,&4,&5,&6,&7,&8"
                                               , "needLineCST"          , p-cst
                                               , "needLineParts"        , p-parts
                                               , "needLineChkPayCode"   , p-chk-pay-code
                                               , "needLineChkPayDesk"   , p-pay-desk
                                              )
                                  + substitute( ",&1,&2,&3,&4"
                                               , "needLineChkPayDeskCards"  , p-pay-desk-cards
                                               , "needOpenedDocs"           , p-opened-docs
                                              )
    .
    run bgelib-write-header in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input 1                                           /* p-file-number   */
        , input no                                          /* p-have-prev     */
        , input ""                                          /* p-prev-filename */
        , input p-obj-list
        , input p-doc-type-list
        , input v-parameter-list
    ).
    object-of-list:
    for each temp-obj
    :
        run cb-fill_bgelib_clients in this-procedure (
              input temp-obj.obj-type
            , input temp-obj.obj-code
        ).
        run export-docs-by-object (
              input temp-obj.host-code
            , input temp-obj.obj-type
            , input temp-obj.obj-code
            , input v-xml-file-name
            , input v-log-file-name
            , input v-list-file-name
            , input v-xml-file-number
            , output v-xml-file-name
            , output v-xml-file-number
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
            view-as alert-box error.
            next object-of-list.
        end.
    end.
    run bge/catgood.p (
          input "good-ext,list"
        , input table temp_bgelib_goods
    ).
    run bge/catfirm.p (
          input "list":U
        , input v-cntxt-host-code-obj
        , input table temp_bgelib_clients
    ).
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
procedure export-docs-by-object :
define input parameter p-host-code              as integer      no-undo.
define input parameter p-obj-type               as character    no-undo.
define input parameter p-obj-code               as integer      no-undo.
define input parameter p-xml-file-name          as character    no-undo.
define input parameter p-log-file-name          as character    no-undo.
define input parameter p-list-file-name         as character    no-undo.
define input parameter p-xml-file-number        as integer      no-undo.
define output parameter p-new-xml-file-name     as character    no-undo.
define output parameter p-new-xml-file-number   as integer      no-undo.

    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.
do
on error undo, return error
:
    assign
        p-new-xml-file-name     = p-xml-file-name
        p-new-xml-file-number   = p-xml-file-number
    .
    run bgelib-write-edt( hEDT, 1, string( p-obj-type ) + " " + string( p-obj-code ) ).

/*---S-------- Расчет архивов на объекте ------------------*/
    run bgelib-write-edt( hEDT, 4,  "Расчет архивов").

    run bge/bge-ahz.p (
          input p-mainmenu-handle
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
        run bgelib-write-log in this-procedure (
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
/*---S----- Границы fact-order для дат dFrom - dto --------*/
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
        view-as alert-box error.
        undo, return error .
    end.
    if v-docs-exists = no
    then do:
        run bgelib-write-edt( hEDT, 4, "В заданном диапазоне дат нет закрытых документов").
    end.
    else do:
        run bgelib-show-cnt(hCNT).
/*---E----- Границы fact-order для дат dFrom - dto --------*/

        for each temp_ext-doc-type
        :
            if lookup( temp_ext-doc-type.ext-doc-type, p-doc-type-list ) <> 0
            or p-doc-type-list = ""
            then do:
                run bge/docoper.p (
                      input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input temp_ext-doc-type.ext-doc-type
                    , input temp_ext-doc-type.ext-doc-type-label
                    , input v-fact-order-from
                    , input v-fact-order-to
                    , input p-pay-code
                    , input p-cst
                    , input p-parts
                    , input p-chk-pay-code
                    , input p-pay-desk
                    , input p-pay-desk-cards
                    , input p-obj-list
                    , input p-doc-type-list
                    , input v-parameter-list
                    , input p-xml-file-name
                    , input p-log-file-name
                    , input p-list-file-name
                    , input p-xml-file-number
                    , input this-procedure
                    , input hEDT
                    , input hCNT
                    , output p-new-xml-file-name
                    , output p-new-xml-file-number
                ) no-error.
                if error-status :error
                then do:
                  message
                      vss-workfile vss-revision vss-description
                      skip(1)
                      skip "Ошибка вызова bge/docoper.p"
                      skip return-value
                      skip trim(error-status :get-message(2))
                      skip trim(error-status :get-message(2))
                           trim(error-status :get-message(3))
                  view-as alert-box error.
                  run bgelib-write-edt( hEDT, 1, substitute( "&1. &2. &3."
                                                           , return-value
                                                           , trim(error-status :get-message(1))
                                                           , trim(error-status :get-message(2))
                                                           )
                                      ).
                  undo, return error return-value . /* --->>>--- */
                end.
                assign
                    p-xml-file-name     = p-new-xml-file-name
                    p-xml-file-number   = p-new-xml-file-number
                .
            end.
        end.        /* for each temp_ext-doc-type */
        run bgelib-hide-cnt( hCNT ).
    end.
    if p-deleted = yes
    then do:
        run bgelib-show-CNT( hCNT ).
        run bge/docdeld.p (
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
            run bgelib-write-edt( hEDT, 1, substitute( "&1. &2. &3."
                                            , return-value
                                            , trim(error-status :get-message(1))
                                            , trim(error-status :get-message(2))
                                            )  ).
        end.
        run bgelib-hide-cnt( hCNT ).
    end.
    process events.
    if p-opened-docs = yes
    then do:
        run bgelib-show-cnt(hCNT).
        run bge/docopnd.p (
              input p-host-code
            , input p-obj-type
            , input p-obj-code
            , input p-cst
            , input p-parts
            , input p-xml-file-name
            , input p-log-file-name
            , input this-procedure
            , input hEDT
            , input hCNT
        ) no-error.
        if error-status :error
        then do:
            run bgelib-write-edt( hEDT, 1, substitute( "&1. &2. &3."
                                            , return-value
                                            , trim(error-status :get-message(1))
                                            , trim(error-status :get-message(2))
                                            )  ).
        end.
        process events.
        run bgelib-hide-cnt(hCNT).
    end.
    process events.
end.
end procedure. /* export-docs-by-object */



/*==========================================================================*/
procedure cb-fill_bgelib_goods :
define input parameter p-gds-code   as integer          no-undo.

    define buffer buf_temp_bgelib_goods     for temp_bgelib_goods.
do
for buf_temp_bgelib_goods
on error undo, return error
:
    find first buf_temp_bgelib_goods
         where buf_temp_bgelib_goods.gds-code = p-gds-code
    no-error.
    if not available buf_temp_bgelib_goods
    then do:
        create buf_temp_bgelib_goods.
        assign
            buf_temp_bgelib_goods.gds-code = p-gds-code
        .
    end.
end.
end procedure. /* cb-fill_bgelib_goods */


/*==========================================================================*/
procedure cb-fill_bgelib_clients :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.

    define buffer buf_temp_bgelib_clients     for temp_bgelib_clients.
do
for buf_temp_bgelib_clients
on error undo, return error
:
    find first buf_temp_bgelib_clients
         where buf_temp_bgelib_clients.obj-type = p-obj-type
           and buf_temp_bgelib_clients.obj-code = p-obj-code
    no-error.
    if not available buf_temp_bgelib_clients
    then do:
        create buf_temp_bgelib_clients.
        assign
            buf_temp_bgelib_clients.obj-type = p-obj-type
            buf_temp_bgelib_clients.obj-code = p-obj-code
        .
    end.
end.
end procedure. /* cb-fill_bgelib_goods */