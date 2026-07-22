block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bge-shft.p $
$Archive: bge/bge-shft.p $

Экспорт XML данных по сменам

Автор: Хныкин Павел Андреевич
Дата создания: 10/24/05
Author: Pavel Khnykin
Creation date: 10/24/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-date-from          as date             no-undo.
define input parameter p-shift-num-from     as integer          no-undo.
define input parameter p-date-to            as date             no-undo.
define input parameter p-shift-num-to       as integer          no-undo.
define input parameter p-range              as integer          no-undo.
define input parameter p-obj-list           as character        no-undo.
define input parameter p-bge-editor-handle  as handle           no-undo.
define input parameter p-bge-fillin-handle  as handle           no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-shft.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-shft.p $":U .
define variable vss-description as character no-undo init "Экспорт XML данных по сменам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }
{ gbl/getcntxt.i def }

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

    define variable v-out-dir           as character    no-undo.
    define variable v-prefix            as character    no-undo.
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
    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.
    define variable v-date-from-decimal as decimal      no-undo.
    define variable v-date-to-decimal   as decimal      no-undo.
    define variable v-date-decimal      as decimal      no-undo.
    define variable v-shift-name-from     as character no-undo.
    define variable v-shift-name-num-from as character no-undo.
    define variable v-shift-name-to       as character no-undo.
    define variable v-shift-name-num-to   as character no-undo.

    define buffer buf_shift-obj     for ub.shift-obj.
do
for buf_shift-obj
on error undo, return error
:
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
        , input substitute( "Начало выгрузки в каталог &1"
                                , v-out-dir
                          )
    ).
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
    object-of-list:
    for each temp-obj
    :
        process events.
        run wp-XMLWriteEDT( p-bge-editor-handle, 1, string( temp-obj.obj-type ) + " " + string( temp-obj.obj-code ) ).
        run wp-XMLWriteEDT( p-bge-editor-handle, 4,  "Расчёт архивов").
        run bge/bge-ahz.p (
              input p-mainmenu-handle
            , input temp-obj.obj-type
            , input temp-obj.obj-code
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
                , input substitute( "*** Смены по объекту &1 &2 в интервале дат &3 - &4 не будут выгружены. Архивы по объекту в заданном интервале дат не целостные. &5."
                                        , temp-obj.obj-type
                                        , temp-obj.obj-code
                                        , p-date-from
                                        , p-date-to
                                        , v-comment       )
            ).
            next object-of-list.
        end.
        process events.
        for each buf_shift-obj no-lock
           where buf_shift-obj.obj-type   = temp-obj.obj-type
             and buf_shift-obj.obj-code   = temp-obj.obj-code
             and buf_shift-obj.status_    = {&sht-closed}
             and buf_shift-obj.shift-date >= p-date-from
             and buf_shift-obj.shift-date <= p-date-to
        use-index stts
        :
            run get-decimal-shift-num in this-procedure (
                  input p-date-from
                , input p-shift-num-from
                , output v-date-from-decimal
            ).
            run get-decimal-shift-num in this-procedure (
                input p-date-to
                , input p-shift-num-to
                , output v-date-to-decimal
            ).
            run get-decimal-shift-num in this-procedure (
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
                      input p-bge-editor-handle
                    , input 6
                    , input substitute( "Выгрузка смены N &1 за &2 "
                                        , v-shift-name-num-to
                                        , string( buf_shift-obj.shift-date, "99.99.99" )
                                      )
                ).
                assign
                    v-prefix = substitute( "s_&1&2&3&4&5&6_"
                                            , substring( string( year( buf_shift-obj.shift-date ), "9999":U ), 3, 2 )
                                            , string( month( buf_shift-obj.shift-date ), "99":U )
                                            , string( day( buf_shift-obj.shift-date ), "99":U )
                                            , string( buf_shift-obj.shift-num, "99":U )
                                            , string( trim( buf_shift-obj.obj-type ), "X(3)":U )
                                            , string( buf_shift-obj.obj-code, "99999":U )
                                            )
                .
                run bge-xml-out-file in this-procedure (
                      input v-out-dir
                    , input v-prefix
                    , input no
                    , output v-xml-file-name
                    , output v-locked
                ).
                if v-locked = yes
                then do:
                    message
                        skip "Файл выгрузки заблокирован другим процессом."
                        skip "Полное имя файла:"
                        skip v-xml-file-name "xml"
                    view-as alert-box error.
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
                    , input p-shift-num-from
                    , input p-date-to
                    , input p-shift-num-to
                    , input p-obj-list
                    , input "":U      /* p-doc-type-list   */
                    , input no        /* p-pay-code        */
                    , input no        /* p-cst             */
                    , input no        /* p-parts           */
                    , input no        /* p-chk-pay-code    */
                    , input no        /* p-pay-desk        */
                    , input no        /* p-pay-desk-cards  */
                    , input no        /* p-deleted         */
                    , input no        /* p-opened-docs     */
                ).
                run bge/shtoper.p (
                      input temp-obj.host-code
                    , input temp-obj.obj-type
                    , input temp-obj.obj-code
                    , input buf_shift-obj.shift-date
                    , input buf_shift-obj.shift-num
                    , input v-xml-file-name
                    , input v-log-file-name
                    , input p-bge-editor-handle
                    , input p-bge-fillin-handle
                ) no-error.
                if error-status :error
                then do:
                    run wp-XMLWriteEDT(
                          input p-bge-editor-handle
                        , input 1
                        , input substitute( "&1. &2. &3."
                                        , return-value
                                        , trim( error-status :get-message( 1 ) )
                                        , trim( error-status :get-message( 2 ) ) )
                    ).
                end.
                run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
            end.        /* if buf_shift-obj */
        end.        /* for each buf_shift-obj */
    end.        /* for each temp-obj */
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в каталог"
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
procedure get-decimal-shift-num :
define input parameter p-shift-date     as date             no-undo.
define input parameter p-shift-num      as integer          no-undo.
define output parameter p-shift-decimal as decimal          no-undo.

do
on error undo, return error
:
    assign
        p-shift-decimal = ( p-shift-date - 01/01/1990 ) + truncate( p-shift-num / 1000, 3 )
    .
end.
end procedure. /* get-decimal-shift-num */