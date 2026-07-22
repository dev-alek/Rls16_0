block-level on error undo, throw.
/*

$Revision: 3ac8d1d44d52, 3383, rls $
$Author: DRuban $
$Date: 2023/05/31 09:28:12 $
$Workfile: run-ext.p $
$Archive: str/run-ext.p $

Запуск внешней программы пользователя.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-recid          as recid           - recid выбранной записи
    table for temp_recid-list           - список recid выбранных записей
    p-place          as character       - интерфейс, для которого вызвана программа. См. ext-list.i, параметр 1
    p-init           as character       - если вызов сделан только для инициализации кнопки - передать "init"
Output:
    p-button-label    as character       - надпись для кнопки в случае p-init = "init"
*/

define temp-table temp_recid-list no-undo
    field string-recid as character
    index pi is primary unique string-recid
.
define input parameter p-recid          as recid            no-undo.
define input parameter table for temp_recid-list.
define input parameter p-place          as character        no-undo.
define input parameter p-init           as character        no-undo.
define output parameter p-button-label  as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: 3ac8d1d44d52, 3383, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/31 09:28:12 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: run-ext.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/run-ext.p $":U .
define variable vss-description as character no-undo init "Запуск внешней программы пользователя.".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u,p-recid,p-place,p-init)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
/* Temp-Table and Buffer definitions                                    */

do
on error undo, return error
:

define buffer buf_trn-doc       for ub.trn-doc.

define variable v-sys-key   as character         no-undo.
define variable v-par-type  as character         no-undo.
define variable l-was-error as logical  init yes. /* undo-переменная для диагностики ошибок */

define temp-table temp_ext-list no-undo
        field place         as character
        field button-name   as character
        field proc-name     as character
        field sys-key       as character
        field sys-key-black as character
index pi is primary unique place
.

{ str/ext-list.i }

find first temp_ext-list
     where temp_ext-list.place = p-place
no-error.
if not available temp_ext-list
then do:
    return error .
end.

{ gbl/currsysk.i
  v-sys-key
  no-error
}


if ( ( lookup( v-sys-key, temp_ext-list.sys-key ) <> 0 or v-sys-key = '' )
and lookup( v-sys-key, temp_ext-list.sys-key-black ) = 0 )
or caps( v-sys-key ) = {&SuperSysKey}
then do:
    if p-init = "init"
    then do:
        assign
            p-button-label          = temp_ext-list.button-name
            l-was-error = false
        .
    end.
    else do
    on error undo, leave
    on stop undo, leave
    :
        if search( entry( 1, temp_ext-list.proc-name, "." ) + ".r" ) = ?
           and search( entry( 1, temp_ext-list.proc-name, "." ) + ".p" ) = ?
        then do:
            message
                   "Не найдена внешняя программа " temp_ext-list.proc-name
            view-as alert-box error.
        end.
        else do:
            run value (temp_ext-list.proc-name)  (input p-recid, input table temp_recid-list  ).
            assign
                l-was-error = false
            .
        end.
    end.
    if l-was-error = true
    then do:
        message
            "При выполнении заказной программы" temp_ext-list.proc-name "возникла ошибка"
            skip "Обратитесь к администратору системы"
        view-as alert-box error .
        return error .
    end.
end.
else do: /* Кнопка не прописана в ext-list.i */
    undo, return error .
end.

end.