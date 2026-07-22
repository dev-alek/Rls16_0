block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление группы клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.cli-grp.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление группы клиентов".
{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.cli-grp.node-code,ub.cli-grp.upper-code,ub.cli-grp.node-name)" }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ ref/cgrplbfn.i }
{ trg/clientsh.i }
{ trg/cli-grph.i cli-grp-trig ub.cli-grp ub.cli-grp }


define buffer b-cli-grp     for ub.cli-grp.
define buffer other_cli-grp for ub.cli-grp.
define variable name     as char    no-undo.
define variable uc       as int     no-undo.
define variable conf-par as char    no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char    no-undo.                  /* тип параметра конфигурации */
define variable v-date   as date    no-undo .
define variable v-time   as integer no-undo .
define buffer buf_dis-grp-rule for ub.dis-grp-rule.

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

    /* в отличие от удаления документов, маршрутизацию чистить не надо,
      т.к. должны дойти все команды на изменение */

    if not g#news and ( g#db-num > 0 ) then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя удалять запись ГРУППЫ КЛИЕНТОВ в УБД" skip
            "Номер текущей БД" g#db-num
            view-as alert-box error .
        undo , return error .
    end.
    /* отменяем триггер для ускорения - товары в новости не идут, передается 1 команда */
    on write of ub.clients override 
        do: 
        end.

    /* считаем путь к ВЫШЕСТОЯЩЕМУ узлу */
    run cli-grplib-get-full-name in this-procedure
        (input ub.cli-grp.upper-code
        ,output name
        ).

    /* переносим клиентов или товары + gds-obj в вышестоящий узел и переписываем в них полный путь */
    for each ub.clients where
        ub.clients.grp-code = ub.cli-grp.node-code
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        run clientsh_write-clients-proc   in this-procedure (
            buffer ub.clients
            ,input {&hn-source-grp-chg} /*p-source-type*/
            ,input string(ub.cli-grp.node-code)
            ).

        assign
            ub.clients.grp-code = ub.cli-grp.upper-code
            ub.clients.grp-name = name
            .
    end.

    /* нижестоящие узлы переносим наверх,
      при этом триггеры cligrpw.p обрабатывают все остальные узлы и товары.
      История будет записана не только на удаление данного узла, но и на изменение всех узлов из этого цикла */
    for each b-cli-grp  where
        b-cli-grp.upper-code = ub.cli-grp.node-code
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
        assign
            b-cli-grp.upper-code = ub.cli-grp.upper-code
            .
    end.
    for each buf_dis-grp-rule where
        buf_Dis-grp-rule.classif-type = {&table_cli-grp}
        and buf_Dis-grp-rule.node-code = ub.cli-grp.node-code
        and buf_Dis-grp-rule.host-code = 0
        and buf_Dis-grp-rule.obj-type = '':U
        and buf_Dis-grp-rule.obj-code = 0
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        delete buf_Dis-grp-rule.
    end.

    find first b-cli-grp where
        b-cli-grp.node-code = ub.cli-grp.upper-code.

    if not can-find(first other_cli-grp no-lock where
        other_cli-grp.upper-code = b-cli-grp.node-code
        AND recid(other_cli-grp) <> recid(ub.cli-grp)) then 
    do:
        assign
            b-cli-grp.is-term = yes
            .
    end.


    /* признак изменения справочника */
    define variable v-synch-cli-grp as integer no-undo .
    assign
        v-synch-cli-grp = next-value(synch-cli-grp, {&db-name_schema})
        .

    run nws/cmd-del.p
        ( input {&table_cli-grp}
        ,input (buffer ub.cli-grp:handle)
        ,input "":U
        ) no-error .
    if error-status :error then 
    do:
        undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.

    if not g#news then 
    do:
        run cli-grph_write-cli-grp-trigger in this-procedure (
            no
            ,"":U
            ,"":U
            , integer({&hn-delete})
            ).
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_cli-grp}
            , input ( buffer ub.cli-grp:handle )
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    
    end.
    run trg/userlog.p (
        input {&nwsdochs_action_delete}
        , input {&table_cli-grp}
        , input ( buffer ub.cli-grp :handle )
        , input ?
        , input ""
        ) no-error.
    if error-status :error
        then 
    do:
        undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
end.