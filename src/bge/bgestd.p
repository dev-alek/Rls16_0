block-level on error undo, throw.
/*

$Revision: 54afbbf3cb8d, 191, rls $
$Author: EShklyar $
$Date: Thu Apr 23 14:36:42 2015 +0400 $
$Workfile: bgestd.p $
$Archive: bge/bgestd.p $

Экспорт во Внешнюю Бухгалтерию товарных остатков

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:
    p-host-code     - код фирмы (если не по расписанию)
    p-date-from     - начало периода экспорта
    p-date-to       - конец  периода экспорта
    p-export-supp   - разбить остатки по поставщикам
    p-shedule       - выгрузка по расписанию
    p-db-num        - БД выгрузки (если по расписанию)
    p-obj-list      - список объектов (если по расписанию)
    hedt            - handle поля лога     (editor)
    hcnt            - handle поля счетчика (fill-in)
*/

define input parameter parparentproc    as handle           no-undo.
define input parameter p-host-code      as integer          no-undo.
define input parameter p-range          as integer      no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-obj-list       as character    no-undo. /* Список объектов для p-range = 3 */
define input parameter p-date-to        as date         no-undo.
define input parameter p-export-supp    as logical      no-undo.
define input parameter p-parts          as logical      no-undo.
define input parameter p-shedule        as logical      no-undo.
define input parameter p-db-num         as integer      no-undo.
define input parameter hedt             as handle       no-undo.
define input parameter hcnt           as handle  no-undo.

define variable vss-revision    as character no-undo init "$Revision: 54afbbf3cb8d, 191, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Apr 23 14:36:42 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bgestd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bgestd.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию товарных остатков".
{ cmp/vssrevis.i     }
{ cmp/trg-def.i      }
{ gbl/temphost.i     }
{ bge/bgelib.i       }
{ cmp/library.i      }
{ gbl/getcntxt.i def }

do
on error undo, return error
:

&scoped-define version-string "14.0 " + replace( vss-revision + vss-date, "$", " " )

    define variable v-xml-file-name     as character    no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character    no-undo. /* имя log-файла */
    define variable v-list-file-name    as character    no-undo. /* имя list-файла */
    define variable v-xml-file-number   as integer      no-undo. /* порядковый номер выгружаемого файла */
    define variable v-locked            as logical      no-undo.
    define variable v-log-string        as character    no-undo. /* имя log-файла */
    define variable v-docs-exists       as logical      no-undo.
    define variable v-obj-counter       as integer      no-undo.
    define variable v-yesno             as logical      no-undo.
    define variable v-cancel            as logical      no-undo.
    define variable v-parameter-list    as character    no-undo.


    /* Права на экспорт документов*/
    if p-shedule = no
    then do:
        { gbl/getcntxt.i get }
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
        if not v-yesno then do:
            return error.
        end.
    end.
    RUN init-temphost.
    assign
        v-log-string = ", по всем фирмам"
    .
    case p-range:
    when 2      /* Экспорт по текущей фирме */
    then do:
        for each temp-obj
        where temp-obj.host-code <> p-host-code
        :
            delete temp-obj.
        end.
        assign
            v-log-string = ", по фирме (код фирмы " + string( p-host-code ) + ")"
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
    run bgelib-filename in this-procedure (
          input "std"
        , output v-xml-file-name
        , output v-log-file-name
        , output v-list-file-name
    ).
    run gbl/waitfrsp.w (
          input substring( v-xml-file-name, 1, 1 )
        , input {&bgelib_minimum-free-mbytes}
        , output v-cancel
    ) .
    assign
        v-parameter-list = "":U
    .
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
        , input substitute( "Начало выгрузки остатков в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + "xm1"
                          )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: Дата: &1"
                                , p-date-to
                          )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... список объектов: &1", p-obj-list )
    ).
    if v-locked = yes
    then do:
        run bgelib-write-log in this-procedure (
              input v-log-file-name
            , input 1
            , input "*** Ошибка выгрузки: Файл выгрузки заблокирован другим процессом."
        ).
        undo, return error .
    end.
    run bgelib-write-header in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input 1                                           /* p-file-number   */
        , input no                                          /* p-have-prev     */
        , input ""                                          /* p-prev-filename */
        , input p-obj-list
        , input ""
        , input v-parameter-list
    ).
    object-of-list:
    for each temp-obj
    :
        run export-stk-by-object in this-procedure (
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
            skip "Ошибка экспорта остатков по объекту"
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
procedure export-stk-by-object :
define input parameter p-host-code  as integer      no-undo.
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-xml-file-name          as character    no-undo.
define input parameter p-log-file-name          as character    no-undo.
define input parameter p-list-file-name         as character    no-undo.
define input parameter p-xml-file-number        as integer      no-undo.
define output parameter p-new-xml-file-name     as character    no-undo.
define output parameter p-new-xml-file-number   as integer      no-undo.

    define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.
do
on error undo, return error return-value
:
    assign
        p-new-xml-file-name     = p-xml-file-name
        p-new-xml-file-number   = p-xml-file-number
    .
    run bgelib-write-edt(
          input hEDT
        , input 1
        , input substitute( "&1 &2. Расчет архивов...", p-obj-type, p-obj-code )
    ).
/*---S-------- Расчет архивов на объекте ------------------*/
    run bge/bge-ahz.p (
          input parparentproc
        , input p-obj-type
        , input p-obj-code
        , input yes
        , input no
        , input no
        , input p-date-to
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
        undo, return error return-value.
    end.
    if v-archive-ok = no
    then do:
        run bgelib-write-log in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "*** Остатки по объекту &1 &2 за дату &3 не будут выгружены. Архивы по объекту за эту дату не целостные. &4."
                                    , p-obj-type
                                    , p-obj-code
                                    , p-date-to
                                    , v-comment       )
        ).
        undo, return error 'Остатки по объекту не будут выгружены. Архивы по объекту за эту дату не целостные.'.
    end.
    
    process events.
/*---S----- Границы fact-order для дат dFrom - dTo --------*/
    run bgelib-write-edt( hEDT, 4,  "Расчет архивов завершен. Вывод данных по товарам...").
    run rep/get-fo.p (
          input  p-obj-type
        , input  p-obj-code
        , input  ?
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
        undo, return error return-value.
    end.

    run bge/stdoper.p (
          input p-obj-type
        , input p-obj-code
        , input p-date-to
        , input v-fact-order-to
        , input p-obj-list
        , input v-parameter-list
        , input p-parts
        , input v-xml-file-name
        , input v-log-file-name
        , input p-list-file-name
        , input p-xml-file-number
        , input hEDT
        , input hCNT
        , output p-new-xml-file-name
        , output p-new-xml-file-number
    ) no-error.
    if error-status :error
    then do:
        run bgelib-write-edt( hEDT, 1, string(return-value)).
    end.
    assign
        p-xml-file-name     = p-new-xml-file-name
        p-xml-file-number   = p-new-xml-file-number
    .
end.
end procedure. /* export-stk-by-object */
