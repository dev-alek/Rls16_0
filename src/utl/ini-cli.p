block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-cli.p $
$Archive: utl/ini-cli.p $

Инициализация полных имен групп в clients, gds-obj

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
        p-mode       as character   - режим работы:
                                        "test":U            - только записать в лог необходимые изменения.
                                        "update":U          - произвести изменения с записью в лог.
Output:

*/
define input parameter p-mode   as character        no-undo.

on write of ub.cli-grp     override do: end.
on write of ub.clients     override do: end.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-cli.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-cli.p $":U .
define variable vss-description as character no-undo init "Инициализация полных имен групп в clients, gds-obj".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
/*{ ref/grplibfn.i }*/
{ ref/cgrplib.i   }
{ gbl/cur-time.i }


&scoped-define log-filename "ini-cli.txt":U

    define stream out-stream.

    define variable v-clients-counter       as integer      init 0  no-undo.
    define variable v-full-grp-name         as character            no-undo.
    define variable v-yesno                 as logical              no-undo.

    define frame a
        v-clients-counter       label "Обработано объектов"
    with.

    define buffer buf_clients       for ub.clients.
    define buffer buf_cli-grp       for ub.cli-grp.
do
for buf_clients
  , buf_cli-grp
on error undo, return error
:
    assign
        v-yesno = no
    .
    if p-mode = "update":U
    then do:
        message
            "Инициализация полных названий групп во всех объектах."
            skip "Вы уверены?"
        view-as alert-box question
        buttons OK-Cancel
        title "Группы объектов"
        update v-yesno.
    end.        /* if p-mode = "update":U */
    else do:
        message
            "Тест полных названий групп во всех объектах."
            skip "Вы уверены?"
        view-as alert-box question
        buttons OK-Cancel
        title "Группы объектов"
        update v-yesno.
    end.        /* NOT ( if p-mode = "update":U ) */
    if v-yesno <> yes
    then do:
        return.
    end.
    { gbl/working.i }

    view frame a.

    for each buf_clients no-lock
    on error undo, return error
    :
        run set-full-grp-name in this-procedure (
              input p-mode
            , input buf_clients.obj-type
            , input buf_clients.obj-code
            , input-output v-clients-counter
        ) no-error.
        if error-status :error
        then do:
            run write-log in this-procedure (
                  input 2
                , input substitute( "&1: *** Ошибка вычисления полного имени группы объекта. Объект: &2 &3. &4. &5."
                                    , p-mode
                                    , buf_clients.obj-type
                                    , buf_clients.obj-code
                                    , return-value
                                    , trim(error-status :get-message(1))
                                )
            ).
        end.
        display
            v-clients-counter
        with frame a
        view-as dialog-box.
    end.        /* for each buf_clients */
    for each buf_cli-grp no-lock
    on error undo, return error
    :
        run set-grp-fields in this-procedure (
              input p-mode
            , input buf_cli-grp.node-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка вычисления полей группы."
                skip(1)
                skip "Код группы:" buf_cli-grp.node-code
                skip "Имя группы:" buf_cli-grp.node-name
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
                skip(1)
                skip "Будет сделана запись об ошибке в лог."
            view-as alert-box error.
            run write-log in this-procedure (
                  input 2
                , input substitute( "&1: *** Ошибка вычисления полей группы объектов. Группа: &2 &3. &4. &5."
                                    , p-mode
                                    , buf_cli-grp.node-code
                                    , buf_cli-grp.node-name
                                    , return-value
                                    , trim(error-status :get-message(1))
                                )
            ).
        end.
    end.        /* for each buf_cli-grp */

    { gbl/stopwork.i }

    if p-mode = "update":U
    then do:
        message
            "Инициализация групп объектов завершена."
        view-as alert-box.
    end.        /* if p-mode = "update":U */
    else do:
        message
            "Тест групп объектов завершен."
            skip(1)
            skip "Результат проверки выведен в файл"
            skip {&log-filename}
        view-as alert-box.
    end.        /* NOT ( if p-mode = "update":U ) */
end.


/*==========================================================================
    Проверяет и устанавливает значения полей групп is-term и lvl-num
    input:
        p-mode       as character   - режим.
                                    "test":U            - только записать в лог необходимые изменения.
                                    "update":U          - произвести изменения с записью в лог.
        p-node-code  as integer     - код группы товаров
*/
procedure set-grp-fields :
define input parameter p-mode       as character        no-undo.
define input parameter p-node-code  as integer          no-undo.

    define variable v-is-terminal   as logical      no-undo.
    define variable v-lvl-num       as integer      no-undo.

    define buffer buf_cli-grp       for ub.cli-grp.
do
for buf_cli-grp
on error undo, return error
:
    if p-mode = "update":U
    then do:
        find first buf_cli-grp exclusive-lock
             where buf_cli-grp.node-code = p-node-code
        .
    end.
    else do:
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = p-node-code
        .
    end.
    run cgrplib-is-terminal in this-procedure (
          input p-node-code
        , output v-is-terminal
    ).
    if buf_cli-grp.is-term <> v-is-terminal
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение is-terminal для группы &2 &3: &4|&5"
                                , p-mode
                                , buf_cli-grp.node-code
                                , buf_cli-grp.node-name
                                , buf_cli-grp.is-term
                                , v-is-terminal )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_cli-grp.is-term = v-is-terminal
            .
        end.
    end.
    run cgrplib-get-lvl-num in this-procedure (
          input p-node-code
        , output v-lvl-num
    ).
    if buf_cli-grp.lvl-num <> v-lvl-num
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение lvl-num для группы &2 &3: &4|&5"
                                , p-mode
                                , buf_cli-grp.node-code
                                , buf_cli-grp.node-name
                                , buf_cli-grp.lvl-num
                                , v-lvl-num )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_cli-grp.lvl-num = v-lvl-num
            .
        end.
    end.
end.
end procedure. /* set-grp-fields */


/*==========================================================================*/
procedure write-log :
define input parameter p-tab-position   as integer          no-undo.
define input parameter p-log-text       as character        no-undo.
do
on error undo, return error
:
    output stream out-stream to {&log-filename} append.
    if p-tab-position <> 0
    then do:
        put stream out-stream unformatted
            cur-time-string-sec()
        .
        put stream out-stream unformatted
            space( p-tab-position * 2 + 1 )
        .
    end.
    put stream out-stream unformatted
        p-log-text
    .
    put stream out-stream unformatted
        {&new-line}
    .
    output stream out-stream close.
end.
end procedure. /* impgds-write-log */


/*==========================================================================
    Проверяет и устанавливает значение полного имени группы товара.
    input:
        p-mode       as character   - режим.
                                    "test":U            - только записать в лог необходимые изменения.
                                    "update":U          - произвести изменения с записью в лог.
        p-node-code  as integer     - код товара
*/
procedure set-full-grp-name :
define input parameter p-mode                       as character        no-undo.
define input parameter p-obj-type                   as character        no-undo.
define input parameter p-obj-code                   as integer          no-undo.
define input-output parameter p-clients-counter     as integer          no-undo.

    define buffer buf_clients         for ub.clients.
do
for buf_clients
on error undo, return error
:
    assign
        p-clients-counter = p-clients-counter + 1
    .
    if p-mode = "update":U
    then do:
        find first buf_clients exclusive-lock
             where buf_clients.obj-type = p-obj-type
               and buf_clients.obj-code = p-obj-code
        .
    end.
    else do:
        find first buf_clients no-lock
             where buf_clients.obj-type = p-obj-type
               and buf_clients.obj-code = p-obj-code
        .
    end.
    run cli-grplib-get-full-name in this-procedure (
          input buf_clients.grp-code
        , output v-full-grp-name
    ).
    if buf_clients.grp-name <> v-full-grp-name
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение полного имени группы объекта: &2|&3. Объект: &4 &5."
                                , p-mode
                                , buf_clients.grp-name
                                , v-full-grp-name
                                , buf_clients.obj-type
                                , buf_clients.obj-code
                              )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_clients.grp-name = v-full-grp-name
            .
        end.
    end.
end.
end procedure. /* set-full-grp-name */