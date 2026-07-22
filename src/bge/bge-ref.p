block-level on error undo, throw.
/*

$Revision: c89b59c2f62e, 135, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:48:25 2015 +0400 $
$Workfile: bge-ref.p $
$Archive: bge/bge-ref.p $

Экспорт справочников

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:
    p-mode      - режим выгрузки: "good-ext" - расширенный экспорт товаров.
    p-shedule   - yes для выгрузки по расписанию.
    hEDT        - handle поля лога     (editor)
    hCNT        - handle поля счетчика (fill-in)
*/

define input parameter parparentproc    as handle           no-undo.
define input parameter p-mode       as character    no-undo.
define input parameter p-shedule    as logical      no-undo.
define input parameter p-host-code  as integer      no-undo.
define input parameter hEDT         as handle       no-undo.
define input parameter hCNT         as handle       no-undo.

define variable vss-revision    as character no-undo init "$Revision: c89b59c2f62e, 135, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:25 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-ref.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-ref.p $":U .
define variable vss-description as character no-undo init "Экспорт справочников".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ bge/bge-xml.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

&SCOP FRAME-NAME F-DUMMY

    define variable v-locked    as logical      no-undo.
    define variable v-counter       as integer      no-undo.
    define variable v-have-rights   as logical      no-undo.
do
on error undo, return error
:
    process events.
    /* Права на экспорт справочников*/
    if p-shedule = no
    then do:
        { gbl/getcntxt.i get }
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_references_export':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        yes
        v-have-rights
        }
        if not v-have-rights
        then do:
            undo, return error.
        end.
    end.
    run bge-xml-read-config in this-procedure ( input ?
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
    run wp-xmlWriteEdt(
          input hEDT
        , input 4
        , input "Экспорт справочника контрагентов..."
    ).
    process events.
    run bge/cat-firm.p (
          input p-mode
        , input p-host-code
        , input table temp_bge-xml_clients
        , ""
    ) no-error.
    if error-status :error
    then do:
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input substitute( "Экспорт справочника контрагентов невозможен. &1. &2. &3"
                                , ( if return-value = "locked"
                                  then {&new-line} + "Соответствующий выходной файл заблокирован."
                                  else "" )
                                , trim(error-status :get-message(1))
                                , trim(error-status :get-message(2))
                              )
        ).
    end.        /* if error-status :error "" */
    else do:
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input "Экспорт справочника контрагентов завершен."
        ).
    end.
    run wp-xmlWriteEdt(
          input hEDT
        , input 4
        , input "Экспорт справочника условий хранения..."
    ).
    process events.
    run bge/cat-conk.p (
          input p-mode
        , output v-locked
    ) no-error.
    if error-status :error
    then do:
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input substitute( "Экспорт справочника условий хранения невозможен. &1. &2. &3"
                                , ( if v-locked = yes
                                  then {&new-line} + "Соответствующий выходной файл заблокирован."
                                  else "" )
                                , trim(error-status :get-message(1))
                                , trim(error-status :get-message(2))
                              )
        ).
        process events.
    end.        /* if error-status :error "" */
    else do:
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input "Экспорт справочника условий хранения завершен."
        ).
    end.
    run wp-xmlWriteEdt(
          input hEDT
        , input 4
        , input "Экспорт справочника товаров..."
    ).
    process events.
    run bge/cat-good.p (
            input p-mode
          , input table temp_bge-xml_goods
          , ""
    ) no-error.
    if error-status :error
    then do:
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input substitute( "Экспорт справочника товаров невозможен. &1. &2. &3"
                                , ( if return-value = "locked"
                                  then {&new-line} + "Соответствующий выходной файл заблокирован."
                                  else "" )
                                , trim(error-status :get-message(1))
                                , trim(error-status :get-message(2))
                              )
        ).
        process events.
    end.        /* if error-status :error "" */
    else do:
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input "Экспорт справочника товаров завершен."
        ).
    end.
    process events.
    run wp-xmlWriteEdt(
          input hEDT
        , input 4
        , input "Экспорт справочника групп товаров..."
    ).
    process events.
    run bge/cat-grp.p (
          input 0
        , input ""
    ) no-error.
    if error-status :error
    then do:
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input substitute( "Экспорт справочника групп товаров невозможен. &1. &2. &3"
                                , ( if return-value = "locked"
                                  then {&new-line} + "Соответствующий выходной файл заблокирован."
                                  else "" )
                                , trim(error-status :get-message(1))
                                , trim(error-status :get-message(2))
                              )
        ).
        process events.
    end.        /* if error-status :error "" */
    else do:
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input "Экспорт справочника групп товаров завершен."
        ).
    end.
    if v-bge-xml-bgedict = yes
    then do:
        process events.
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input "Экспорт справочника дисконтных карт..."
        ).
        process events.
        run bge/cat-dcrt.p (
              input p-mode
            , input table temp_bge-xml_dis-card
            , ""
        ) no-error.
        if error-status :error
        then do:
            run wp-xmlWriteEdt(
                input hEDT
                , input 4
                , input substitute( "Экспорт справочника дисконтных карт невозможен. &1. &2. &3"
                                    , ( if return-value = "locked"
                                    then {&new-line} + "Соответствующий выходной файл заблокирован."
                                    else "" )
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                )
            ).
            process events.
        end.        /* if error-status :error */
        else do:
            run wp-xmlWriteEdt(
                input hEDT
                , input 4
                , input "Экспорт справочника дисконтных карт завершен."
            ).
        end.
        process events.
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input "Экспорт справочника видов оплат..."
        ).
        process events.
        run bge/cat-payt.p (
            input 0
            , input ""
            , input 0
        ) no-error.
        if error-status :error
        then do:
            run wp-xmlWriteEdt(
                input hEDT
                , input 4
                , input substitute( "Экспорт справочника видов оплат невозможен. &1. &2. &3"
                                    , ( if return-value = "locked"
                                    then {&new-line} + "Соответствующий выходной файл заблокирован."
                                    else "" )
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                )
            ).
            process events.
        end.        /* if error-status :error */
        else do:
            run wp-xmlWriteEdt(
                input hEDT
                , input 4
                , input "Экспорт справочника видов оплат завершен."
            ).
        end.
        process events.
        run wp-xmlWriteEdt(
              input hEDT
            , input 4
            , input "Экспорт справочника типов кассовых платежей..."
        ).
        process events.
        run bge/cat-payc.p (
              input 0
            , input ""
            , input 0
        ) no-error.
        if error-status :error
        then do:
            run wp-xmlWriteEdt(
                  input hEDT
                , input 4
                , input substitute( "Экспорт справочника типов кассовых платежей невозможен. &1. &2. &3"
                                    , ( if return-value = "locked"
                                    then {&new-line} + "Соответствующий выходной файл заблокирован."
                                    else "" )
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                )
            ).
            process events.
        end.        /* if error-status :error */
        else do:
            run wp-xmlWriteEdt(
                input hEDT
                , input 4
                , input "Экспорт справочника типов кассовых платежей завершен."
            ).
        end.
        process events.
    end.        /* if v-bge-xml-bgedict = yes */

end.