block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: shd-inch.p $
$Archive: bge/shd-inch.p $

Инкрементальный экспорт по сменам документов, чеков и справочников

Автор: Хныкин Павел Андреевич
Дата создания: 05/12/06
Author: Pavel Khnykin
Creation date: 05/12/06

Input:

Output:

*/
define input parameter p-db-num         as integer    no-undo. /* БД, по объктам которой необходим экспорт */
define input parameter p-range          as integer    no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-obj-list       as character  no-undo. /* Список объектов для p-range = 3 */
define input parameter p-need-checks    as logical    no-undo. /* надо ли экспортировать чеки по документам */
define input parameter p-doc-rvs        as logical    no-undo. /* надо ли выгружать сверки до/после слива по топливным приходным накладным */

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shd-inch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/shd-inch.p $":U .
define variable vss-description as character no-undo init "Инкрементальный экспорт во Внешнюю Бухгалтерию документов, чеков и справочников".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/temphost.i }
{ gbl/clntattr.i }
{ bge/bge-xml.i  }
{ trg/factord.i  }

&scop version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

    define variable v-out-dir           as character    no-undo.
    define variable v-out-dirR          as character    no-undo.
    define variable v-log-file-name     as character    no-undo.
    define variable v-log-string        as character    no-undo.
    define variable v-oper-num          as integer      no-undo.
    define variable v-obj-counter       as integer      no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-last-shift-date   as date         no-undo.
    define variable v-last-shift-num    as integer      no-undo.
    define variable v-shift-name        as character    no-undo.
    define variable v-shift-name-num    as character    no-undo.

    define buffer buf_temp_doc-code     for temp_doc-code.
    define buffer buf_temp_del-doc-code for temp_del-doc-code.
    define buffer buf_temp_pr-doc-num   for temp_pr-doc-num.
    define buffer buf_clients-attr for ub.clients-attr.
do
for buf_temp_doc-code
  , buf_temp_del-doc-code
  , buf_temp_pr-doc-num
on error undo, return error
:

    if p-range <> 3
    then do:
        run wp-XMLWriteLog in this-procedure (
            input v-log-file-name
            , input 1
            , input "Неверно заданы объекты для выгрузки."
        ).
        undo, return error .
    end.

    /* 06/IX-2018 Отчет-реестр должен выгружаться только в ГБД
       21/XI-2018 в версии 16.0 отчёт-реестр должен выгружаеться и в УБД
    */
    run bge-xml-out-dir2 in this-procedure (
          output v-out-dir
        , output v-out-dirR
        , output v-log-file-name
    ).
    run bge-xml-init-ext-doc-type in this-procedure .
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run bge-xml-read-config in this-procedure ( input v-today
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
        , input substitute( "Начало выгрузки в каталог &1", v-out-dir )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: Номер базы: &1.", p-db-num )
    ).
    run wp-XMLWriteLog in this-procedure (
        input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... список объектов: &1", p-obj-list )
    ).
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... надо ли выгружать чеки: &1", p-need-checks )
    ).
    // RUN init-temphost. 07/IX-2018 - не используется; заполняет temp-host и temp-obj
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
    v-log-string = if can-find (first temp-obj) then (", по объектам: " + p-obj-list) else ", по всем фирмам" .

define variable v-is-found as logical no-undo .
    v-is-found = false .
     
    object-of-list:
    for each temp-obj
    :
        run bge/lock-bge-incr.p (input temp-obj.obj-type, input temp-obj.obj-code, buffer buf_clients-attr) no-error.
        if error-status:error then do:

              run wp-XMLWriteLog in this-procedure (
                    input v-log-file-name
                  , input 1
                  , input "Ошибка экспорта документов по объекту " + temp-obj.obj-type + string( temp-obj.obj-code ) + ". Объект выгружается в другой сессии."
              ).
              next object-of-list. /* пойдём дальше по списку объектов */
          end.
          
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( " > Экспорт документов по объекту &1&2", temp-obj.obj-type, temp-obj.obj-code)
        ).
        run export-docs-by-object in this-procedure (
              input temp-obj.host-code
            , input temp-obj.obj-type
            , input temp-obj.obj-code
            , input v-out-dir
            , input v-out-dirR
            , input v-log-file-name
        ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input "Ошибка экспорта документов по объекту " + temp-obj.obj-type + string( temp-obj.obj-code )
            ).
            find current buf_clients-attr no-lock. /* снять блокировку */
            next object-of-list.
        end.
        
        v-is-found = true .
        find current buf_clients-attr no-lock. /* снять блокировку */
    end. /* object-of-list: */

    /* дата выгрузки для контрагентов - сегодня */
   /*  run fill-clntattr in this-procedure ( input v-today ).  */
    run wp-XMLWriteLog in this-procedure ( input v-log-file-name
                                         , input 1
                                         , input "Дата выгрузки для контрагентов - установлена"
                                         ).

    /* объекты добавляем отдельно, чтобы не покоцать даты выгрузки */
    for each temp-obj
    :
        run cb-fill_bge-xml_clients in this-procedure ( input temp-obj.obj-type
                                                      , input temp-obj.obj-code
                                                      ).
        v-is-found = true .
    end.
    run wp-XMLWriteLog in this-procedure ( input v-log-file-name
                                         , input 1
                                         , input "Объекты добавлены в список контрагентов"
                                         ).
    if v-is-found then                                    
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в каталог &1 " , v-out-dir )
    ).
    else
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "Отсутствуют данные для выгрузки"
    ).
end.

/*==========================================================================*/
procedure export-docs-by-object :
define input parameter p-host-code      as integer          no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-out-dir        as character        no-undo.
define input parameter p-out-dirR       as character        no-undo.
define input parameter p-log-file-name  as character        no-undo.

    define variable v-xml-file-name         as character    no-undo.
    define variable v-prefix                as character    no-undo.
    define variable v-locked                as logical      no-undo.
    define variable v-start-shift-date      as date         no-undo.
    define variable v-start-shift-num       as integer      no-undo.
    define variable v-not-exists            as logical      no-undo.
    define variable v-fact-order-from       as decimal      no-undo.
    define variable v-fact-order-to         as decimal      no-undo.
    define variable v-docs-exists           as logical      no-undo.
    define variable v-attr-value            as character    no-undo.
    define variable v-attr-type             as character    no-undo.
    define variable v-start-date-decimal    as decimal      no-undo.
    define variable v-date-decimal          as decimal      no-undo.
    define variable v-archive-ok            as logical      no-undo.
    define variable v-comment               as character    no-undo.

    define buffer buf_shift-obj     for ub.shift-obj.
do
for buf_shift-obj
on error undo, return error
:
/*---S-------- Расчет архивов на объекте ------------------*/
    run wp-XMLWriteLog in this-procedure (
          input p-log-file-name
        , input 2
        , input "Расчет архивов"
    ).
    run bge/bge-ahzs.p (
          input p-obj-type
        , input p-obj-code
        , input yes
        , input yes
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
    if v-archive-ok = no
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "*** Документы по объекту &1 &2 на дату &3 не будут выгружены. Архивы по объекту в заданном интервале дат не целостные. &4."
                                    , p-obj-type
                                    , p-obj-code
                                    , v-today
                                    , v-comment       )
        ).
        undo, return error .
    end.
    run clntattr-value in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input {&attr-bge-incr-last-shift-date}
        , output v-attr-value
        , output v-attr-type
    ).
    assign
        v-start-shift-date = date( v-attr-value )
    no-error.
    if error-status :error
    or v-start-shift-date = ?
    then do:
        assign
            v-start-shift-date = 01/01/1990
        .
    end.
    run clntattr-value in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input {&attr-bge-incr-last-shift-num}
        , output v-attr-value
        , output v-attr-type
    ).
    assign
        v-start-shift-num = integer( v-attr-value )
    no-error.
    if error-status :error
    then do:
        assign
            v-start-shift-num = 0
        .
    end.
    assign
        v-last-shift-date = v-start-shift-date
        v-last-shift-num  = v-start-shift-num
    .

    run wp-XMLWriteLog in this-procedure ( input v-log-file-name
                                         , input 2
                                         , input substitute( "Последняя выгруженная смена: N &1 за &2 ...", v-start-shift-num, v-start-shift-date  )
                                         ).
    run bge-xml-get-decimal-shift-num in this-procedure (
              input v-start-shift-date
            , input v-start-shift-num
            , output v-start-date-decimal
    ).
        
define variable v-is-found as logical no-undo .
    v-is-found = false .
            
    export-shifts:
    for each buf_shift-obj no-lock
       where buf_shift-obj.obj-type     = p-obj-type
         and buf_shift-obj.obj-code     = p-obj-code
         and buf_shift-obj.shift-date   >= v-start-shift-date
         and buf_shift-obj.status_      = {&sht-closed}
    use-index pi
    on error  undo export-shifts, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo export-shifts, return error substitute( "&1. stop", vss-workfile )
    on endkey undo export-shifts, return error substitute( "&1. endkey", vss-workfile )
    :
        run bge-xml-get-decimal-shift-num in this-procedure (
              input buf_shift-obj.shift-date
            , input buf_shift-obj.shift-num
            , output v-date-decimal
        ).
        if v-date-decimal > v-start-date-decimal
        then do:
            { str/shiftnam.i
              buf_shift-obj.obj-type
              buf_shift-obj.obj-code
              buf_shift-obj.shift-date
              buf_shift-obj.shift-num
              v-shift-name
              v-shift-name-num
              no-error
            }
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 2
                , input substitute( "Смена: N &1 за &2 ...", v-shift-name-num, buf_shift-obj.shift-date  )
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
                    , input substitute( "*** Ошибка выгрузки: Файл выгрузки &1 заблокирован другим процессом.", v-xml-file-name )
                ).
                undo, return error .
            end.
            run bge-xml-write-header in this-procedure (
                  input v-xml-file-name
                , input v-xml-file-name + "xml"
                , input {&version-string}
                , input p-db-num
                , input buf_shift-obj.shift-date
                , input buf_shift-obj.shift-num
                , input buf_shift-obj.shift-date
                , input buf_shift-obj.shift-num
                , input p-obj-list
                , input "":U
                , input yes
                , input yes
                , input yes
                , input yes
                , input yes
                , input yes
                , input yes
                , input no
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
            run wp-XMLWriteLog (
                              input p-log-file-name
                            , input 1
                            , input substitute( " Последний fact-order(shd-inch) &1. &2&3"
                                                 , v-fact-order-to 
                                                ,p-obj-type
                                                ,p-obj-code                                               
                                                )  ).
            if v-docs-exists = yes
            then do:
                for each temp_ext-doc-type
                :
                    define variable v-date-from as date      no-undo .
                    define variable v-date-to   as date      no-undo .
                    if v-fact-order-from = 0 then do:
                      v-date-from = 01/01/1990.
                    end.
                    else do:
                    run factord-to-date in this-procedure ( input v-fact-order-from
                                                          , output v-date-from
                                                          ).
                    end.
                    if v-fact-order-to = 0 then do:
                      v-date-to = 01/01/1990.
                    end.
                    else do:
                    run factord-to-date in this-procedure ( input v-fact-order-to
                                                          , output v-date-to
                                                          ).
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
                        , input yes
                        , input yes
                        , input yes
                        , input yes
                        , input yes
                        , input yes
                        , input p-need-checks
                        , input p-doc-rvs
                        , input v-xml-file-name
                        , input p-log-file-name
                        , input this-procedure
                        , input ?
                        , input ?
                    ) no-error.
                    if error-status :error
                    then do:
                        run wp-XMLWriteLog (
                              input p-log-file-name
                            , input 1
                            , input substitute( "&5&6 &1. &2. &3."
                                                , return-value
                                                , trim(error-status :get-message(1))
                                                , trim(error-status :get-message(2))
                                                ,p-obj-type
                                                ,p-obj-code
                                                )  ).
                    end.
                end.        /* do v-oper-num = 1 to 16 */
            end.        /* if v-docs-exists = yes */
            run bge/doc-delh.p (
                  input p-obj-type
                , input p-obj-code
                , input buf_shift-obj.shift-date
                , input buf_shift-obj.shift-num
                , input v-xml-file-name
                , input p-log-file-name
                , input ?
                , input ?
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog (
                      input p-log-file-name
                    , input 1
                    , input substitute( "&1. &2. &3."
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                        )  ).
            end.
            run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
            v-is-found = true .
            
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
                    , input substitute( "*** Ошибка выгрузки: Файл выгрузки &1 заблокирован другим процессом.", v-xml-file-name )
                ).
                undo, return error .
            end.
            run bge-xml-write-header in this-procedure (
                  input v-xml-file-name
                , input v-xml-file-name + "xml"
                , input {&version-string}
                , input p-db-num
                , input buf_shift-obj.shift-date
                , input buf_shift-obj.shift-num
                , input buf_shift-obj.shift-date
                , input buf_shift-obj.shift-num
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
            ).
            run bge/shtoper.p (
                  input p-host-code
                , input p-obj-type
                , input p-obj-code
                , input buf_shift-obj.shift-date
                , input buf_shift-obj.shift-num
                , input v-xml-file-name
                , input p-log-file-name
                , input ?
                , input ?
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                    input v-log-file-name
                    , input 1
                    , input substitute( "Ошибка экспорта смены объекта &1 &2. Смена  &3 от &4. &5. &6. &7."
                                            , p-obj-type
                                            , p-obj-code
                                            , buf_shift-obj.shift-date
                                            , buf_shift-obj.shift-num
                                            , return-value
                                            , trim( error-status :get-message( 1 ) )
                                            , trim( error-status :get-message( 2 ) )
                                        )
                ).
                undo, return error.
            end.
            run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).

          do :
            assign
                v-prefix = substitute( "r_&1&2&3&4&5&6_"
                                        , substring( string( year( buf_shift-obj.shift-date ), "9999":U ), 3, 2 )
                                        , string( month( buf_shift-obj.shift-date ), "99":U )
                                        , string( day( buf_shift-obj.shift-date ), "99":U )
                                        , string( buf_shift-obj.shift-num, "99":U )
                                        , string( trim( buf_shift-obj.obj-type ), "X(3)":U )
                                        , string( buf_shift-obj.obj-code, "99999":U )
                                        )
            .
            run bge-xml-out-file in this-procedure (
                  input p-out-dirR
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
                    , input substitute( "*** Ошибка выгрузки: Файл выгрузки &1 заблокирован другим процессом.", v-xml-file-name )
                ).
                undo, return error .
            end.
            run bge-xml-write-header in this-procedure (
                  input v-xml-file-name
                , input v-xml-file-name + "xml"
                , input {&version-string}
                , input p-db-num
                , input buf_shift-obj.shift-date
                , input buf_shift-obj.shift-num
                , input buf_shift-obj.shift-date
                , input buf_shift-obj.shift-num
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
            ).
            run bge/sht-reestr.p (
              input p-obj-type
            , input p-obj-code
            , input buf_shift-obj.shift-date
            , input buf_shift-obj.shift-num
            , input v-xml-file-name
            , input p-log-file-name
            , input ? /* hEDT */
            , input ? /* hCNT */
            ) no-error.
            if error-status :error
            then do:
              run wp-XMLWriteLog in this-procedure (
                  input p-log-file-name
                , input 1
                , input substitute( "*** Ошибка экспорта реестра документов &1 &2. Смена  &3 от &4. &5. &6. &7."
                                        , p-obj-type
                                        , p-obj-code
                                        , buf_shift-obj.shift-date
                                        , buf_shift-obj.shift-num
                                        , return-value
                                        , error-status :get-message(1)
                                        , error-status :get-message(2)
                                        )
              ).
                undo, return error.
            end.
            run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
          end . // end_of r_file (только для g#db-num = 0)

            { str/shiftnam.i
              buf_shift-obj.obj-type
              buf_shift-obj.obj-code
              buf_shift-obj.shift-date
              buf_shift-obj.shift-num
              v-shift-name
              v-shift-name-num
              no-error
            }
        assign
            v-last-shift-date = buf_shift-obj.shift-date
            v-last-shift-num  = buf_shift-obj.shift-num
        .


    run clntattr-write in this-procedure ( input p-obj-type
                                         , input p-obj-code
                                         , input {&attr-bge-incr-last-shift-date}
                                         , input string(v-last-shift-date)
                                         ) no-error .
    if error-status :error
    then do:
      run wp-XMLWriteLog in this-procedure ( input v-log-file-name
                                           , input 1
                                           , input substitute( "Ошибка установки атрибута даты последней выгрузки объекта &1 &2, дата &3.&4&5&6&7"
                                                             , buf_shift-obj.obj-type
                                                             , buf_shift-obj.obj-code
                                                             , v-last-shift-date
                                                             , {&new-line}
                                                             , return-value
                                                             , trim( error-status :get-message( 1 ) )
                                                             , trim( error-status :get-message( 2 ) )
                                                             )
                                           ).
      undo, return error.

    end.
    run clntattr-write in this-procedure ( input p-obj-type
                                         , input p-obj-code
                                         , input {&attr-bge-incr-last-shift-num}
                                         , input string(v-last-shift-num)
                                         ) no-error .
    if error-status :error
    then do:
      run wp-XMLWriteLog in this-procedure ( input v-log-file-name
                                           , input 1
                                           , input substitute( "Ошибка установки атрибута даты последней выгрузки объекта &1 &2, дата &3 порядок смены &4.&5&6&7&8"
                                                             , buf_shift-obj.obj-type
                                                             , buf_shift-obj.obj-code
                                                             , v-last-shift-date
                                                             , v-last-shift-num
                                                             , {&new-line}
                                                             , return-value
                                                             , trim( error-status :get-message( 1 ) )
                                                             , trim( error-status :get-message( 2 ) )
                                                             )
                                           ).
      undo, return error.
    end.
            if v-is-found then
            run wp-XMLWriteLog (
                  input p-log-file-name
                , input 2
                , input substitute( "Смена: N &1 за &2 выгружена.", v-shift-name-num, buf_shift-obj.shift-date  )
            ).
            else
            run wp-XMLWriteLog (
                  input p-log-file-name
                , input 2
                , input substitute( "В смене: N &1 за &2 отсутствуют файлы для выгрузки.", v-shift-name-num, buf_shift-obj.shift-date  )
            ).
        end.        /* if v-date-decimal > v-start-date-decimal */
    end.        /* for each buf_shift-obj no-lock */
    run wp-XMLWriteLog in this-procedure (
          input p-log-file-name
        , input 1
        , input substitute( " < Экспорт документов по объекту &1 &2 завершен.", p-obj-type, p-obj-code )
    ).
end.
end procedure. /* export-docs-by-object */

/*==========================================================================*/
procedure get-start-date :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define output parameter p-start-date    as date         no-undo.
define output parameter p-not-exist     as logical      no-undo.

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_price-doc     for ub.price-doc.
    define buffer buf_ot-tot        for ub.ot-tot.

    find-first-ot-tot:
    for each buf_ot-tot no-lock
       where buf_ot-tot.obj-type = p-obj-type
         and buf_ot-tot.obj-code = p-obj-code
    :
        find first buf_trn-doc no-lock
             where buf_trn-doc.doc-code = buf_ot-tot.doc-code
        no-error.
        if available buf_trn-doc
        and buf_trn-doc.fact-date <> ?
        then do:
            assign
                p-not-exist     = no
                p-start-date    = buf_trn-doc.fact-date
            .
            leave find-first-ot-tot.
        end.        /* if available buf_trn-doc  */
        else do:
            find first buf_price-doc no-lock
                 where buf_price-doc.doc-num = buf_ot-tot.doc-code
            no-error.
            if available buf_price-doc
            and buf_price-doc.fact-date <> ?
            then do:
                assign
                    p-not-exist     = no
                    p-start-date    = buf_price-doc.fact-date
                .
                leave find-first-ot-tot.
            end.        /* if available buf_trn-doc  */
        end.
    end.        /* for each buf_ot-tot no-lock */
end.
end procedure. /* get-start-date */


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
procedure fill-clntattr :
define input parameter p-cur-date   as date             no-undo.

    define buffer buf_temp_bge-xml_clients      for temp_bge-xml_clients.
do
for buf_temp_bge-xml_clients
on error undo, return error
:
    for each buf_temp_bge-xml_clients no-lock
    on error undo, return error
    :
      if not (buf_temp_bge-xml_clients.obj-type = {&shop}
              or
              buf_temp_bge-xml_clients.obj-type <> {&stock}) then do:
        /*ЗАЧЕМ ЭТО НУЖНО - НЕПОНЯТНО!!!!*/
        run clntattr-write in this-procedure (
              input buf_temp_bge-xml_clients.obj-type
            , input buf_temp_bge-xml_clients.obj-code
            , input {&attr-bge-incr-last-shift-date}
            , input v-last-shift-date
        ).
        run clntattr-write in this-procedure (
              input buf_temp_bge-xml_clients.obj-type
            , input buf_temp_bge-xml_clients.obj-code
            , input {&attr-bge-incr-last-shift-num}
            , input v-last-shift-num
        ).
      end. /*if not (buf_temp_bge-xml_clients.obj-type = {&shop}*/
    end.        /* for each buf_temp_bge-xml_clients */
end.
end procedure. /* fill-clntattr */