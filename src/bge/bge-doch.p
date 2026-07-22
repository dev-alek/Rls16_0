block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: bge-doch.p $
$Archive: bge/bge-doch.p $

Экспорт во Внешнюю Бухгалтерию документов и суммарного расхода по чекам

Автор: Хныкин Павел Андреевич
Дата создания: 05/12/06
Author: Pavel Khnykin
Creation date: 05/12/06

Input:

Output:

*/
define input parameter parparentproc    as handle               no-undo.
define input parameter p-date-from      as date             no-undo. /* начало периода экспорта */
define input parameter p-shift-num-from as integer          no-undo.
define input parameter p-date-to        as date             no-undo. /* конец  периода экспорта */
define input parameter p-shift-num-to   as integer          no-undo.
define input parameter p-shift-on       as logical          no-undo.
define input parameter p-range          as integer          no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-obj-list       as character        no-undo. /* Список объектов для p-range = 3 */
define input parameter p-doc-type-list  as character        no-undo. /* Список типов операций */
define input parameter p-pay-code       as logical          no-undo. /* надо ли экспортировать кассовые платежи */
define input parameter p-cst            as logical          no-undo. /* надо ли экспортировать ГТД из parts */
define input parameter p-parts          as logical          no-undo. /* надо ли экспортировать parts */
define input parameter p-chk-pay-code   as logical          no-undo. /* надо ли экспортировать разброс по типам касс платежей*/
define input parameter p-pay-desk       as logical          no-undo. /* надо ли экспортировать разброс по кассам */
define input parameter p-pay-desk-cards as logical          no-undo. /* надо ли экспортировать разброс по префиксам карт */
define input parameter p-deleted        as logical          no-undo. /* надо ли экспортировать удаленные документы */
define input parameter p-chk            as logical          no-undo. /* надо ли экспортировать чеки */
define input parameter p-doc-rvs        as logical          no-undo. /* надо ли выгружать сверки до/после слива по топливным приходным накладным */
define input parameter p-opened-docs    as logical          no-undo. /* надо ли экспортировать не закрытые документы */
define input parameter hedt             as handle           no-undo.
define input parameter hcnt             as handle           no-undo.

define variable v-shift-name-from     as character no-undo.
define variable v-shift-name-num-from as character no-undo.
define variable v-shift-name-to       as character no-undo.
define variable v-shift-name-num-to   as character no-undo.

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-doch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-doch.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию документов и суммарного расхода по чекам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }
{ gbl/getcntxt.i def }
{ trg/factord.i  }

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

    define variable v-out-dir           as character    no-undo.
    define variable v-log-file-name     as character    no-undo. /* имя log-файла */
    define variable v-log-string        as character    no-undo. /* имя log-файла */
    define variable v-obj-counter       as integer      no-undo.
    define variable v-db-num            as integer      no-undo.
    define variable v-yesno             as logical      no-undo.

do
on error undo, return error
:
    /*       "расход производство (перестает использоваться)",   {&TDEDT_Ras_Prvo},            */
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
    run init-temphost in this-procedure.
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
    run bge-xml-out-dir in this-procedure (
          output v-out-dir
        , output v-log-file-name
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Выгрузка по сменам в каталог &1.", v-out-dir )
    ).
    if p-shift-on = yes
    then do:
        { str/shiftnam.i
          temp-obj.obj-type
          temp-obj.obj-code
          p-date-from
          p-shift-num-from
          v-shift-name-from
          v-shift-name-num-from
          no-error
        }
        { str/shiftnam.i
          temp-obj.obj-type
          temp-obj.obj-code
          p-date-to
          p-shift-num-to
          v-shift-name-to
          v-shift-name-num-to
          no-error
        }

        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "................с параметрами: Дата с: &1, смена с: &2. Дата по: &3, смена по: &4"
                                    , p-date-from
                                    , v-shift-name-num-from
                                    , p-date-to
                                    , v-shift-name-num-to
                            )
        ).
    end.        /* if p-shift-on = yes  */
    else do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "................с параметрами: Дата с: &1, дата по: &2"
                                    , p-date-from
                                    , p-date-to
                            )
        ).
    end.        /* NOT ( if p-shift-on = yes  ) */
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
            , input v-out-dir
            , input v-log-file-name
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
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в каталог &1"
                                , v-out-dir
                          )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
end.

/*==========================================================================*/
procedure export-docs-by-object :
define input parameter p-host-code      as integer          no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-out-dir        as character        no-undo.
define input parameter p-log-file-name  as character        no-undo.

    define variable v-xml-file-name     as character    no-undo. /* имя файла вывода */
    define variable v-prefix            as character    no-undo.
    define variable v-locked            as logical      no-undo.
    define variable v-fact-order-from   as decimal      no-undo.
    define variable v-fact-order-to     as decimal      no-undo.
    define variable v-docs-exists       as logical      no-undo.
    define variable v-oper-num          as integer      no-undo. /* номер операции*/
    define variable v-date-from-decimal as decimal      no-undo.
    define variable v-date-to-decimal   as decimal      no-undo.
    define variable v-date-decimal      as decimal      no-undo.
    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.

    define buffer buf_shift-obj     for ub.shift-obj.
do
for buf_shift-obj
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
    export-shifts:
    for each buf_shift-obj no-lock
       where buf_shift-obj.obj-type     = p-obj-type
         and buf_shift-obj.obj-code     = p-obj-code
         and buf_shift-obj.shift-date   >= p-date-from
         and buf_shift-obj.shift-date   <= p-date-to
    :
        run bge-xml-get-decimal-shift-num in this-procedure (
              input p-date-from
            , input p-shift-num-from
            , output v-date-from-decimal
        ).
        run bge-xml-get-decimal-shift-num in this-procedure (
              input p-date-to
            , input p-shift-num-to
            , output v-date-to-decimal
        ).
        run bge-xml-get-decimal-shift-num in this-procedure (
              input buf_shift-obj.shift-date
            , input buf_shift-obj.shift-num
            , output v-date-decimal
        ).
        if v-date-decimal >= v-date-from-decimal
        and v-date-decimal <= v-date-to-decimal
        then do:
            { str/shiftnam.i
              buf_shift-obj.obj-type
              buf_shift-obj.obj-code
              buf_shift-obj.shift-date
              buf_shift-obj.shift-num
              v-shift-name-to
              v-shift-name-num-to
              no-error
            }

            run wp-XMLWriteEDT(
                  input hEDT
                , input 6
                , input substitute( "Смена: N &1 за &2 ...", v-shift-name-num-to, buf_shift-obj.shift-date  )
            ).
            
            assign
                v-prefix = substitute( "d_&1&2&3&4&5&6_"
                                        , substring( string( year( buf_shift-obj.shift-date ), "9999":U ), 3, 2 )
                                        , string( month( buf_shift-obj.shift-date ), "99":U )
                                        , string( day( buf_shift-obj.shift-date ), "99":U )
                                        , string( buf_shift-obj.shift-num, "99":U )
                                        , string( trim( buf_shift-obj.obj-type ), "X(3)":U )
                                        , string( buf_shift-obj.obj-code, "99999":U )
                                        )
            .
            run bge-xml-out-file in this-procedure (
                  input p-out-dir
                , input v-prefix
                , input no
                , output v-xml-file-name
                , output v-locked
            ).
            if v-locked = yes
            then do:
                run wp-XMLWriteLog in this-procedure (
                      input p-log-file-name
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
                , input p-shift-num-from
                , input p-date-to
                , input p-shift-num-to
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
            run rep/getfosht.p (
                  input p-obj-type
                , input p-obj-code
                , input buf_shift-obj.shift-date
                , input buf_shift-obj.shift-num
                , output v-fact-order-from
                , output v-fact-order-to
                , output v-docs-exists
            ).
            if v-docs-exists = yes
            then do:
                run wp-XMLShowCNT(hCNT).
                for each temp_ext-doc-type
                :
                    if lookup( temp_ext-doc-type.ext-doc-type, p-doc-type-list ) <> 0
                    or p-doc-type-list = "":U
                    then do:
                        if v-fact-order-from = 0 then do:
                          assign
                          v-date-from = 01/01/1990.
                        end.
                        else do:
                          run factord-to-date in this-procedure ( input v-fact-order-from
                                                                , output v-date-from
                                                                ) .
                        end.
                        if v-fact-order-to = 0 then do:
                          assign
                          v-date-to = 01/01/1990.
                        end.
                        else do:
                          run factord-to-date in this-procedure ( input v-fact-order-to
                                                                , output v-date-to
                                                                ) .
                        end.
                        run bge/doc-oper.p (
                              input p-host-code
                            , input p-obj-type
                            , input p-obj-code
                            , input temp_ext-doc-type.ext-doc-type
                            , input temp_ext-doc-type.ext-doc-type-label
                            , input v-fact-order-from
                            , input v-fact-order-to
                            , input v-date-from
                            , input v-date-to
                            , input p-pay-code
                            , input p-cst
                            , input p-parts
                            , input p-chk-pay-code
                            , input p-pay-desk
                            , input p-pay-desk-cards
                            , input p-chk
                            , input p-doc-rvs
                            , input v-xml-file-name
                            , input p-log-file-name
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
                end.        /* do v-oper-num = 1 to 16 */
                run wp-XMLHideCNT(hCNT).
            end.        /* if v-docs-exists = yes */
            if p-deleted = yes
            then do:
                run bge/doc-delh.p (
                      input p-obj-type
                    , input p-obj-code
                    , input buf_shift-obj.shift-date
                    , input buf_shift-obj.shift-num
                    , input v-xml-file-name
                    , input p-log-file-name
                    , input hEDT
                    , input hCNT
                ) no-error.
                if error-status :error
                then do:
                    run wp-XMLWriteEDT(
                          input hEDT
                        , input 1
                        , input substitute( "&1. &2. &3."
                                            , return-value
                                            , trim(error-status :get-message(1))
                                            , trim(error-status :get-message(2))
                                            )  ).
                end.
            end.
            run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
            { str/shiftnam.i
              buf_shift-obj.obj-type
              buf_shift-obj.obj-code
              buf_shift-obj.shift-date
              buf_shift-obj.shift-num
              v-shift-name-to
              v-shift-name-num-to
              no-error
            }
            run wp-XMLWriteEDT(
                  input hEDT
                , input 6
                , input substitute( "Смена: N &1 за &2 выгружена.", v-shift-name-num-to, buf_shift-obj.shift-date  )
            ).
        end.
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
