block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcs-docs.p $
$Archive: rcs/rcs-docs.p $

Экспорт документов во внешнюю систему

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/09/05
Author: Victor Guntner
Creation date: 09/09/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-head-filename      as character        no-undo.
define input parameter p-body-filename      as character        no-undo.
define input parameter p-date-from          as date             no-undo. /* начало периода экспорта */
define input parameter p-date-to            as date             no-undo. /* конец  периода экспорта */
define input parameter p-range              as integer          no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-obj-list           as character        no-undo. /* Список объектов для p-range = 3 */
define input parameter p-pay-code           as logical          no-undo. /* надо ли экспортировать кассовые платежи */
define input parameter p-cst                as logical          no-undo. /* надо ли экспортировать ГТД из parts */
define input parameter hedt                 as handle           no-undo.
define input parameter hcnt                 as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcs-docs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcs-docs.p $":U .
define variable vss-description as character no-undo init "Экспорт документов во внешнюю систему".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/library.i  }
{ gbl/temphost.i }
{ rcs/rcs-xml.i  }
{ rcs/rcsfunc.i  }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }

    define variable v-log-file-name             as character            no-undo. /* имя log-файла */
    define variable v-log-string                as character            no-undo. /* имя log-файла */
    define variable v-oper-num                  as integer              no-undo. /* номер операции*/
    define variable v-fact-order-from           like stk-tot.fact-order no-undo.
    define variable v-fact-order-to             like stk-tot.fact-order no-undo.
    define variable v-docs-exists               as logical              no-undo.
    define variable v-obj-counter               as integer              no-undo.
    define variable v-counter                   as integer              no-undo.
    define variable v-header-destination-rowid  as character            no-undo.
    define variable v-body-destination-rowid    as character            no-undo.
    define variable v-ext-doc-type-list         as character extent 54 init
    [
        "приход внешний",                                   {&TDEDT_Pri_Vnesh},             2,
        "расход внешний",                                   {&TDEDT_Ras_Vnesh},             0,
        "расход внешний возврат поставщику",                {&TDEDT_Ras_Vnesh_VP},          3,
        "расход внешний продажа через кассу",               {&TDEDT_Ras_Vnesh_Kass},        0,
        "возврат внешний",                                  {&TDEDT_Vozvrat_Vnesh},         3,
        "возврат внешний через кассу",                      {&TDEDT_Vozvrat_Vnesh_Kass},    0,
        "списание внешнее",                                 {&TDEDT_Spi_Vnesh},             4,
        "инвентаризация",                                   {&TDEDT_Inv},                   6,
        "пересортица",                                      {&TDEDT_Peresort},              6,
        "коррекция учетных цен",                            {&TDEDT_Corr_Acc_Price},        6,
        "смена типа приобретения",                          {&TDEDT_Chg_Purch_Code},        6,
        "корретировка отрицательных партий",                {&TDEDT_Corr_Minus_Parts},      6,
        "приход перемещение",                               {&TDEDT_Pri_Perem},             2,
        "расход перемещение",                               {&TDEDT_Ras_Perem},             0,
        "возврат перемещение",                              {&TDEDT_Vozvrat_Perem},         3,
        "списание производство",                            {&TDEDT_Spi_Prvo},              4,
        "приход производство",                              {&TDEDT_Pri_Prvo},              2,
        "документ переоценки",                              {&TDEDT_Overturn},              5
    ]                                                           no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
do
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    { gbl/getcntxt.i get " " p-mainmenu-handle }
    RUN init-temphost.
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

    ASSIGN v-log-file-name = p-head-filename + ".log".

    run get-destination-id in this-procedure (
          input "DOC_HEAD"
        , output v-header-destination-rowid
    ) no-error.
    if error-status :error
    or v-header-destination-rowid = ""
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось получить DESTINATION-ROWID для DOC_HEAD."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run get-destination-id in this-procedure (
          input "DOC_BODY"
        , output v-body-destination-rowid
    ) no-error.
    if error-status :error
    or v-body-destination-rowid = ""
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось получить DESTINATION-ROWID для DOC_BODY."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.



    run rcs-xml-write-header in this-procedure (
              input 2
            , input p-head-filename
            , input v-header-destination-rowid
            , input p-body-filename
            , input v-body-destination-rowid
    ) no-error .
    if error-status :error
    then do:
        undo, return error "rcs-docs: Ошибка записи заголовка файла." + {&new-line} + return-value.
    end.
    object-of-list:
    for each temp-obj
    :
        run export-docs-by-object (   input temp-obj.host-code
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
    end.

    run rcs-xml-write-footer in this-procedure (
              input 2
            , input p-head-filename
            , input p-body-filename
    ) no-error .
    if error-status :error
    then do:
        undo, return error "rcs-docs: Ошибка окончания записи файла." + {&new-line} + return-value.
    end.

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
    process events.
    run bge/bge-ahz.p (
          input p-mainmenu-handle
        , input p-obj-type
        , input p-obj-code
        , input yes
        , input no
        , input no
        , input v-today
        , input v-today
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
        process events.
    end.
    else do:

        run wp-XMLShowCNT(hCNT).
/*---E----- Границы fact-order для дат dFrom - dTo --------*/

        do v-oper-num = 1 to 14:
            run rcs/rcs-oper.p (
                              input p-host-code
                            , input p-obj-type
                            , input p-obj-code
                            , input v-ext-doc-type-list [v-oper-num * 3 - 1]
                            , input v-ext-doc-type-list [v-oper-num * 3 - 2]
                            , input v-ext-doc-type-list [v-oper-num * 3]
                            , input v-fact-order-from
                            , input v-fact-order-to
                            , input p-pay-code
                            , input p-cst
                            , input p-head-filename
                            , input p-body-filename
                            , input p-head-filename + ".log"
                            , input hEDT
                            , input hCNT
                            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteEDT( hEDT, 1, string(return-value)).
            end.
        end.
        run wp-XMLHideCNT(hCNT).
    end.
end.
end procedure. /* export-docs-by-object */