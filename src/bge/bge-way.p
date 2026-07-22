block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bge-way.p $
$Archive: bge/bge-way.p $

Экспорт во Внешнюю Бухгалтерию товаров в пути на момент выгрузки

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

input:
    p-host-code - Код фирмы (если не по расписанию)
    p-shedule   - По расписанию
    p-db-num    - БД выгрузки (если по расписанию)
    p-obj-list  - Список объектов (если по расписанию)
    hedt        - handle поля лога     (editor)
    hcnt        - handle поля счетчика (fill-in)
*/

define input parameter p-host-code  as integer      no-undo.
define input parameter p-shedule    as logical      no-undo.
define input parameter p-db-num     as integer      no-undo.
define input parameter p-obj-list   as character    no-undo.
define input parameter hedt         as handle       no-undo.
define input parameter hcnt         as handle       no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-way.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-way.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию товаров в пути на момент выгрузки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }

&scoped-define out-file-name "way"
&scoped-define version-string "15.0 " + vss-revision + vss-date

    define variable v-xml-file-name     as character            no-undo.
    define variable v-log-file-name     as character            no-undo.
    define variable v-obj-counter       as integer       no-undo.
do
on error undo, return error
:
/*Шапка XML*/
run bge/bge-head.p (
      input "exp-acc"
    , input {&out-file-name}
    , input "XML - Вывод данных по товарам в пути"
    , input p-shedule
    , output v-xml-file-name
    , output v-log-file-name
) no-error.
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Ошибка при создании файла выгрузки."
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
run bge-xml-write-header in this-procedure (
      input v-xml-file-name         /* p-xml-file-name */
    , input {&out-file-name}        /* p-doc-name      */
    , input {&version-string}       /* p-version       */
    , input p-db-num                /* p-db-num        */
    , input ?                       /* p-date-from     */
    , input 0
    , input ?                       /* p-date-to       */
    , input 0
    , input p-obj-list              /* p-obj-list      */
    , input ""                      /* p-doc-type-list */
    , input ?                       /* p-pay-code      */
    , input ?                       /* p-cst           */
    , input ?                       /* p-parts         */
    , input ?                       /* p-chk-pay-code  */
    , input ?                       /* p-pay-desk      */
    , input ?                       /* p-pay-desk-cards*/
    , input ?                       /* p-deleted       */
    , input ?                       /* p-opened-docs   */
) no-error.
if error-status :error
then do:
    return error.
end.

/* Экспорт из архивов */

if p-shedule = no
then do:
    run init-temphost.
    object-of-firm:
    for each temp-obj
       where temp-obj.host-code = p-host-code
    break by temp-obj.obj-type
          by temp-obj.obj-code
    :
        run wp-XMLWriteEDT( hEDT, 1, string( temp-obj.obj-type ) + " " + string( temp-obj.obj-code ) ).
        run wp-XMLShowCNT(hCNT).
        run bge/way-oper.p (
              input temp-obj.obj-type
            , input temp-obj.obj-code
            , input v-xml-file-name
            , input v-log-file-name
            , input hEDT
            , input hCNT
        ) no-error.
        if error-status :error
        then do:
            message
                "Ошибка при выгрузке данных по товарам в пути"
            view-as alert-box.
            run wp-XMLWriteEDT( hEDT, 1, string( return-value ) ).
        end.
        run wp-XMLHideCNT( hCNT ).
    end.        /* for each temp-obj */
end.        /* if p-shedule = no  */
else do:
    for each temp-obj
    :
        delete temp-obj.
    end.
    do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
    :
        run wp-XMLWriteEDT( hEDT, 1, entry( v-obj-counter * 2 - 1, p-obj-list ) + " " + entry( v-obj-counter * 2, p-obj-list ) ).
        run wp-XMLShowCNT(hCNT).
        run bge/way-oper.p (
              input entry( v-obj-counter * 2 - 1, p-obj-list )
            , input integer( entry( v-obj-counter * 2, p-obj-list ) )
            , input v-xml-file-name
            , input v-log-file-name
            , input hEDT
            , input hCNT
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip "Ошибка при выгрузке данных по товарам в пути"
                skip return-value
                skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
            view-as alert-box error.
            run wp-XMLWriteEDT( hEDT, 1, string( return-value ) ).
            undo, return error return-value . /* --->>>--- */
        end.
        run wp-XMLHideCNT( hCNT ).
    end.        /* do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2 */
end.        /* NOT ( if p-shedule = no  ) */

run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).

end.