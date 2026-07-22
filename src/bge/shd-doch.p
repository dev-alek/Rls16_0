block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: shd-doch.p $
$Archive: bge/shd-doch.p $

Экспорт по сменам документов и суммарного расхода по чекам

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
define variable vss-workfile    as character no-undo init "$Workfile: shd-doch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/shd-doch.p $":U .
define variable vss-description as character no-undo init "Экспорт по сменам документов и суммарного расхода по чекам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }
{ trg/factord.i  }

&scop out-file-name "docum"
&scop version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

    define variable v-out-dir           as character    no-undo.
    define variable v-out-dirR          as character    no-undo.
    define variable v-xml-file-name     as character    no-undo.
    define variable v-log-file-name     as character    no-undo.
    define variable v-locked            as logical      no-undo.
    define variable v-log-string        as character    no-undo.
    define variable v-oper-num          as integer      no-undo.
    define variable v-obj-counter       as integer      no-undo.
    define variable v-shift-obj-on      as logical      no-undo.
    define variable v-shift-name        as character    no-undo.
    define variable v-shift-name-num    as character    no-undo.

do
on error undo, return error
:
    if v-bge-xml-bgefmt = "dbf":U
    then do:        /* Выгрузка каждого документа ведётся в отдельный файл. Нужна только проверка каталога */
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "*** Параметр bgefmt установлен в dbf. Для данного вида выгрузки экспорт в DBF не определён." )
        ).
        undo, return error .
    end.
    if p-range <> 3 then do:
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
    run bge-xml-out-dir2 in this-procedure ( output v-out-dir
                                          , output v-out-dirR
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
    /* 06/IX-2018 - заменено на xml-bge-filename0, чтобы не создавать повторно папки в "BGE" key "Dirfrg-acc" 
    run xml-bge-filename in this-procedure (
          input "doc"
        , input "document"
        , input yes
        , output v-xml-file-name
        , output v-log-file-name
        , output v-locked
    ).
    */
    run xml-bge-filename0 in this-procedure (
          input "doc"
        , input "document"
        , input yes
        , input ibs.th.gbl.gbl-inipar:dirfrgAcc
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
        undo, return error .
    end.
    
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки в каталог &1", v-out-dir )
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
                , input "Ошибка чтения списка объектов из входного перечня."
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
        { gbl/objat.i
            temp-obj.obj-type
            temp-obj.obj-code
            "'shift-on=request'"
            v-shift-obj-on
            no-error
        }
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
                , input substitute( "*** Ошибка при определении типа сменный/не-сменный для объекта &1 &2", temp-obj.obj-type, temp-obj.obj-code )
            ).
            undo object-of-list, next object-of-list.
        end.
        if v-shift-obj-on = yes
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                , input 1
               , input substitute(" > Экспорт документов по закрытым сменам объекта &1&2", temp-obj.obj-type, temp-obj.obj-code )
            ).
            run export-shifts-object (
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
                    , input substitute( "*** Ошибка экспорта документов по сменному объекту &1 &2", temp-obj.obj-type, temp-obj.obj-code )
                ).
                undo object-of-list, next object-of-list.
            end.
            else v-is-found = true .
        end.        /* if v-shift-obj-on = yes */
        else do:
            run wp-XMLWriteLog in this-procedure (
                input v-log-file-name
              , input 1
              , input substitute(" > Экспорт документов по несменному объекту &1&2", temp-obj.obj-type, temp-obj.obj-code )
            ).
            run export-not-shifts-object (
                  input temp-obj.host-code
                , input temp-obj.obj-type
                , input temp-obj.obj-code
                , input v-out-dir
                , input v-log-file-name
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                      input v-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка экспорта документов по несменному объекту &1 &2", temp-obj.obj-type, temp-obj.obj-code )
                ).
                undo object-of-list, next object-of-list.
            end.
        end.        /* NOT ( if v-shift-obj-on = yes ) */
    end.
    if v-is-found then
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1 " , replace( v-xml-file-name, "/", "\" ) + "xml" )
    ).
    else
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input "*** Во входном перечне отсутствуют объекты, по которым была выполнена выгрузка."
    ).
end.

/*==========================================================================*/
procedure export-shifts-object :
define input parameter p-host-code      as integer      no-undo.
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-out-dir        as character        no-undo.
define input parameter p-out-dirR       as character        no-undo.
define input parameter p-log-file-name  as character        no-undo.

    define variable v-fact-order-from   as decimal      no-undo.
    define variable v-fact-order-to     as decimal      no-undo.
    define variable v-docs-exists       as logical      no-undo.
    define variable v-prefix            as character    no-undo.
    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.

    define buffer buf_shift-obj     for ub.shift-obj.
do
for buf_shift-obj
on error undo, return error
:
    export-shifts:
    for each buf_shift-obj no-lock
       where buf_shift-obj.obj-type     = p-obj-type
         and buf_shift-obj.obj-code     = p-obj-code
         and buf_shift-obj.shift-date   >= p-date-from
         and buf_shift-obj.shift-date   <= p-date-to
         and buf_shift-obj.status_      = {&sht-closed}
    :
        do : /* рассёт архивов */
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
              skip error-status:get-message(1)
                   error-status :get-message(2)
                   error-status :get-message(3)
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
        end . /* end_of рассёт архивов */

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
              input p-log-file-name
            , input 2
            , input substitute( "Смена: N &1 за &2 ...", v-shift-name-num, buf_shift-obj.shift-date  )
        ).


      do : /* выгрузка d_файла */
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
            , input yes
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
            , input p-doc-type-list
            , input p-pay-code
            , input p-cst
            , input p-parts
            , input p-chk-pay-code
            , input p-pay-desk
            , input p-pay-desk-cards
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
                            , input substitute( " Последний fact-order(shd-doch) &1."
                                                 , v-fact-order-to                                                
                                                )  ).
        if v-docs-exists = yes
        then do:
            for each temp_ext-doc-type
            :
                if lookup( temp_ext-doc-type.ext-doc-type, p-doc-type-list ) <> 0
                or p-doc-type-list = "":U
                then do:
                    define variable v-date-from   as date      no-undo .
                    define variable v-date-to     as date      no-undo .
                    if v-fact-order-from = 0 then do:
                      v-date-from = 01/01/1990.
                    end.
                    else do:
                    run factord-to-date in this-procedure ( input  v-fact-order-from
                                                          , output v-date-from
                                                          ) .
                    end.
                    if v-fact-order-to = 0 then do:
                      v-date-to = 01/01/1990.
                    end.
                    else do:
                    run factord-to-date in this-procedure ( input  v-fact-order-to
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
                        , input no
                        , input p-doc-rvs
                        , input v-xml-file-name
                        , input p-log-file-name
                        , input this-procedure
                        , input hEDT
                        , input hCNT
                    ) no-error.
                    if error-status :error
                    then do:
                        run wp-XMLWriteLog in this-procedure (
                              input p-log-file-name
                            , input 1
                            , input "*** Ошибка экспорта документов. " + return-value + "." + trim( error-status :get-message( 1 ) ) + "." + trim( error-status :get-message( 2 ) )
                        ).
                    end.
                end.
            end.        /* for each temp_ext-doc-type */
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
                run wp-XMLWriteLog in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка экспорта удалённых документов. &1. &2. &3."
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                        )  ).
            end.
        end.        /* if v-docs-exists = yes  */
        run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
      end . /* end_of выгрузка d_файла */

      do : /* выгрузка s_файла */
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
            , input buf_shift-obj.shift-date
            , input buf_shift-obj.shift-num
            , input buf_shift-obj.shift-date
            , input buf_shift-obj.shift-num
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
              input p-host-code
            , input p-obj-type
            , input p-obj-code
            , input buf_shift-obj.shift-date
            , input buf_shift-obj.shift-num
            , input v-xml-file-name
            , input v-log-file-name
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
            undo export-shifts, next export-shifts.
        end.
        run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
      end . /* end_of выгрузка s_файла */


      /* 06/IX-2018 Отчет-реестр должен выгружаться только в ГБД
         21/XI-2018 в версии 16.0 отчёт-реестр должен выгружаеться и в УБД      
      */
      do : /* выгрузка r_файла */
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
              /* 30/III-2018 Отчет-реестр будет выгружаться в отдельную от основной выгрузки папку. */
              input p-out-dirR
            , input v-prefix
            , input no
            , output v-xml-file-name
            , output v-locked
        ).
        if v-locked then do:
            message
                skip "Файл выгрузки заблокирован другим процессом."
                skip "Полное имя файла:"
                skip v-xml-file-name + "xml"
            view-as alert-box error.
            run wp-XMLWriteLog in this-procedure (
                  input p-log-file-name
                , input 1
                , input "*** Ошибка выгрузки: Файл выгрузки " + v-xml-file-name + "xml" + " заблокирован другим процессом."
            ).
            undo, return error .
        end.
        run bge-xml-write-header in this-procedure (
              input v-xml-file-name
            , input v-xml-file-name + "xml"
            , input {&version-string}
            , input 0
            , input buf_shift-obj.shift-date
            , input buf_shift-obj.shift-num
            , input buf_shift-obj.shift-date
            , input buf_shift-obj.shift-num
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
        run bge/sht-reestr.p (
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
            undo export-shifts, next export-shifts.
        end.
        run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
      end . /* end_of выгрузка r_файла */


    end.        /* for each buf_shift-obj no-lock */
    run wp-XMLWriteLog in this-procedure (
          input p-log-file-name
        , input 1
        , input substitute( " < Экспорт документов по сменному объекту &1 &2 завершён.", p-obj-type, p-obj-code )
    ).
end.
end procedure. /* export-shifts-object */

/*==========================================================================*/
procedure export-not-shifts-object :
define input parameter p-host-code      as integer      no-undo.
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-out-dir        as character        no-undo.
define input parameter p-log-file-name  as character        no-undo.

    define variable v-fact-order-from   as decimal      no-undo.
    define variable v-fact-order-to     as decimal      no-undo.
    define variable v-docs-exists       as logical      no-undo.
    define variable v-prefix            as character    no-undo.
    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.

    define buffer buf_shift-obj     for ub.shift-obj.
do
for buf_shift-obj
on error undo, return error
:
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
    run rep/get-fo.p (
          input p-obj-type
        , input p-obj-code
        , input p-date-from
        , input p-date-to
        , output v-fact-order-from
        , output v-fact-order-to
        , output v-docs-exists
    ).
    if v-docs-exists = no
    then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 1
            , input substitute( "Нет закрытых на факт документов на объекте &1 &2", p-obj-type, p-obj-code )
        ).
    end.
    else do:
        assign
            v-prefix = substitute( "d__&1&2&3&4&5&6&7&8_"
                                    , substring( string( year( p-date-from ), "9999":U ), 3, 2 )
                                    , string( month( p-date-from ), "99":U )
                                    , string( day( p-date-from ), "99":U )
                                    , substring( string( year( p-date-to ), "9999":U ), 3, 2 )
                                    , string( month( p-date-to ), "99":U )
                                    , string( day( p-date-to ), "99":U )
                                    , string( trim( p-obj-type ), "X(3)":U )
                                    , string( p-obj-code, "99999":U )
                                    )
        .
        run bge-xml-out-file in this-procedure (
              input p-out-dir
            , input v-prefix
            , input yes
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
            , input no
        ).
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
                    , input p-log-file-name
                    , input this-procedure
                    , input hEDT
                    , input hCNT
                ) no-error.
                if error-status :error
                then do:
                    run wp-XMLWriteLog in this-procedure (
                        input p-log-file-name
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
            , input p-log-file-name
            , input ?
            , input ?
        ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input p-log-file-name
                , input 1
                , input substitute( "*** Ошибка экспорта удалённых документов. &1. &2. &3."
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                    )  ).
        end.
        run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
    end.        /* if v-docs-exists = yes  */
    run wp-XMLWriteLog in this-procedure (
          input p-log-file-name
        , input 1
        , input substitute( " < Экспорт документов по несменному объекту &1 &2 завершён.", p-obj-type, p-obj-code )
    ).
end.
end procedure. /* export-not-shifts-object */


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