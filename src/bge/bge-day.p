block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bge-day.p $
$Archive: bge/bge-day.p $

Экспорт документов по дням

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:

Output:

*/

define input parameter parparentproc  as handle     no-undo.
define input parameter p-date-from    as date       no-undo. /* начало периода экспорта */
define input parameter p-date-to      as date       no-undo. /* конец  периода экспорта */
define input parameter p-range        as integer    no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-obj-list     as character  no-undo. /* Список объектов для p-range = 3 */
define input parameter p-host-code    as integer    no-undo. /* Код текущей фирмы (для p-range = 2, не по расписанию) */
define input parameter p-shedule      as logical    no-undo. /* Выгрузка по расписанию */
define input parameter hedt           as handle     no-undo.
define input parameter hcnt           as handle     no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-day.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-day.p $":U .
define variable vss-description as character no-undo init "Экспорт документов по дням".
{ cmp/vssrevis.i        }
{ cmp/trg-def.i         }
{ gbl/temphost.i        }
{ bge/bge-xml.i         }
{ cmp/library.i         }
{ gbl/getcntxt.i def    }

&scoped-define version-string "14.0 " + replace( vss-revision + vss-date, "$", " " )

define variable v-xml-file-name            as character            no-undo. /* имя файла вывода */
define variable v-log-file-name            as character            no-undo. /* имя LOG-файла */
define variable v-date              as date                 no-undo. /* дата для суммирования продаж товара */
define variable v-yesno             as logical       no-undo.
define variable v-locked            as logical              no-undo.

define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
define variable v-docs-exists       as logical              no-undo.
define variable v-object-state      as character            no-undo.
define variable v-log-string        as character            no-undo.
define variable v-obj-counter       as integer          no-undo.
define variable v-host-code         as integer          no-undo.
define variable v-archive-ok        as logical          no-undo.
define variable v-comment           as character        no-undo.

do
on error undo, return error
:
/* Права на экспорт документов*/

if p-shedule = no
then do:
    { gbl/getcntxt.i get     }
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
end.

/* Экспорт из архивов */

    run init-temphost.
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
          input "day"
        , input "day"
        , input no
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
        , input substitute( "Начало выгрузки в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + "xm1"
                          )
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
        , input v-xml-file-name + "xml"
        , input {&version-string}
        , input 0
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
object-of-firm:
for each temp-obj
break by temp-obj.obj-type
      by temp-obj.obj-code
:
    assign
        v-object-state = ""
    .
    if first-of( temp-obj.obj-code )
    then do:
        assign
            v-object-state = "start"
        .
    end.
    if last-of( temp-obj.obj-code )
    then do:
        assign
            v-object-state = v-object-state + "end"
        .
    end.
    run wp-XMLWriteEDT( hEDT, 1, string(temp-obj.obj-type) + " " + string(temp-obj.obj-code) ).
    /*---S-------- Расчет архивов на объекте ------------------*/
    run wp-XMLWriteEDT( hEDT, 4,  "Расчет архивов").
    process events.
    run bge/bge-ahz.p (
          input parparentproc
        , input temp-obj.obj-type
        , input temp-obj.obj-code
        , input yes
        , input no
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
        skip "Тип объекта:" temp-obj.obj-type
        skip "Код объекта:" temp-obj.obj-code
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
                                    , temp-obj.obj-type
                                    , temp-obj.obj-code
                                    , p-date-from
                                    , p-date-to
                                    , v-comment       )
        ).
        undo object-of-firm, next object-of-firm.
    end.
    process events.
    run wp-XMLWriteEDT( hEDT, 4,  "Расчет архивов завершен. Идет выгрузка данных по объекту").
    process events.
    /*---E-------- Расчет архивов на объекте ------------------*/
    assign
        v-date = p-date-from
    .
    date-of-object:
    do while v-date <= p-date-to
    :
        /*---S----- Границы fact-order для даты v-date --------*/
        run rep/get-fo.p (
                      input  temp-obj.obj-type
                    , input  temp-obj.obj-code
                    , input  v-date
                    , input  v-date
                    , output v-fact-order-from
                    , output v-fact-order-to
                    , output v-docs-exists
                    ).
        if v-docs-exists = no
        then do:
            run wp-XMLWriteEDT( hEDT, 4, "Нет закрытых документов за дату " + string( v-date ) ).
            assign
                v-date = v-date + 1
            .
            process events.
            next date-of-object.
        end.

        run wp-XMLShowCNT(hCNT).
        /*---E----- Границы fact-order для даты v-date --------*/

        run bge/day-oper.p (
                          input v-object-state
                        , input temp-obj.obj-type
                        , input temp-obj.obj-code
                        , input v-date
                        , input v-fact-order-from
                        , input v-fact-order-to
                        , input v-xml-file-name
                        , input v-log-file-name
                        , input hEDT
                        , input hCNT
                    ) no-error.


        if error-status :error
        then do:
            message
                "Ошибка при выгрузке данных по товарам по дням"
            view-as alert-box.
            run wp-XMLWriteEDT( hEDT, 1, string(return-value)).
            process events.
        end.
        run wp-XMLHideCNT(hCNT).
        assign
            v-date = v-date + 1
        .
    end.
    run wp-XMLWriteEDT( hEDT, 4,  "Выгрузка данных по объекту завершена").
    process events.
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

end.