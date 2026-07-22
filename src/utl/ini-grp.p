block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-grp.p $
$Archive: utl/ini-grp.p $

Инициализация полных имен групп в goods, gds-obj

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

on write of ub.gds-grp     override do: end.
on write of ub.goods       override do: end.
on write of ub.gds-obj     override do: end.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-grp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-grp.p $":U .
define variable vss-description as character no-undo init "Инициализация полных имен групп в goods, gds-obj".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
/*{ ref/grplibfn.i }*/
{ ref/grplib.i   }
{ gbl/cur-time.i }


&scoped-define log-filename "ini-grp.txt":U

    define stream out-stream.

    define variable v-goods-counter         as integer      init 0  no-undo.
    define variable v-relations-counter     as integer      init 0  no-undo.
    define variable v-full-grp-name         as character            no-undo.
    define variable v-yesno                 as logical              no-undo.

    define frame a
        v-goods-counter       label "Обработано товаров"
        v-relations-counter   label "Обработано связей"
    with.

    define buffer buf_goods         for ub.goods.
    define buffer buf_gds-grp       for ub.gds-grp.
do
for buf_goods
  , buf_gds-grp
on error undo, return error
:
    assign
        v-yesno = no
    .
    if p-mode = "update":U
    then do:
        message
            "Инициализация полных названий групп во всех товарах."
            skip "Вы уверены?"
        view-as alert-box question
        buttons OK-Cancel
        title "Группы товаров"
        update v-yesno.
    end.        /* if p-mode = "update":U */
    else do:
        message
            "Тест полных названий групп во всех товарах."
            skip "Вы уверены?"
        view-as alert-box question
        buttons OK-Cancel
        title "Группы товаров"
        update v-yesno.
    end.        /* NOT ( if p-mode = "update":U ) */
    if v-yesno <> yes
    then do:
        return.
    end.
    { gbl/working.i }

    view frame a.

    for each buf_goods no-lock
    on error undo, return error
    :
        run set-full-grp-name in this-procedure (
              input p-mode
            , input buf_goods.gds-code
            , input-output v-goods-counter
            , input-output v-relations-counter
        ) no-error.
        if error-status :error
        then do:
            run write-log in this-procedure (
                  input 2
                , input substitute( "&1: *** Ошибка вычисления полного имени группы товара. Товар: &2. &3. &4."
                                    , p-mode
                                    , buf_goods.artic
                                    , return-value
                                    , trim(error-status :get-message(1))
                                )
            ).
        end.
        display
            v-goods-counter
            v-relations-counter
        with frame a
        view-as dialog-box.
    end.        /* for each buf_goods */
    for each buf_gds-grp no-lock
    on error undo, return error
    :
        run set-grp-fields in this-procedure (
              input p-mode
            , input buf_gds-grp.node-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка вычисления полей группы."
                skip(1)
                skip "Код группы:" buf_gds-grp.node-code
                skip "Имя группы:" buf_gds-grp.node-name
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
                skip(1)
                skip "Будет сделана запись об ошибке в лог."
            view-as alert-box error.
            run write-log in this-procedure (
                  input 2
                , input substitute( "&1: *** Ошибка вычисления полей группы товара. Группа: &2 &3. &4. &5."
                                    , p-mode
                                    , buf_gds-grp.node-code
                                    , buf_gds-grp.node-name
                                    , return-value
                                    , trim(error-status :get-message(1))
                                )
            ).
        end.
    end.        /* for each buf_gds-grp */
    for each buf_gds-grp no-lock
    by buf_gds-grp.lvl-num descending
    on error undo, return error
    :
        run set-unit-base in this-procedure (
              input p-mode
            , input buf_gds-grp.node-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка установки unit-base для группы."
                skip(1)
                skip "Код группы:" buf_gds-grp.node-code
                skip "Имя группы:" buf_gds-grp.node-name
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
                skip(1)
                skip "Будет сделана запись об ошибке в лог."
            view-as alert-box error.
            run write-log in this-procedure (
                  input 2
                , input substitute( "&1: *** Ошибка вычисления unit-base. Группа: &2 &3. &4. &5."
                                    , p-mode
                                    , buf_gds-grp.node-code
                                    , buf_gds-grp.node-name
                                    , return-value
                                    , trim(error-status :get-message(1))
                                )
            ).
        end.
    end.        /* for each buf_gds-grp */

    { gbl/stopwork.i }

    if p-mode = "update":U
    then do:
        message
            "Инициализация групп товаров завершена."
        view-as alert-box.
    end.        /* if p-mode = "update":U */
    else do:
        message
            "Тест групп товаров завершен."
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

    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_el_gds-grp    for ub.gds-grp.
    define buffer buf_goods         for ub.goods.
do
for buf_gds-grp
  , buf_el_gds-grp
  , buf_goods
on error undo, return error
:
    if p-mode = "update":U
    then do:
        find first buf_gds-grp exclusive-lock
             where buf_gds-grp.node-code = p-node-code
        .
    end.
    else do:
        find first buf_gds-grp no-lock
            where buf_gds-grp.node-code = p-node-code
        .
    end.
    run grplib-is-terminal in this-procedure (
          input p-node-code
        , output v-is-terminal
    ).
    if buf_gds-grp.is-term <> v-is-terminal
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение is-terminal для группы &2 &3: &4|&5"
                                , p-mode
                                , buf_gds-grp.node-code
                                , buf_gds-grp.node-name
                                , buf_gds-grp.is-term
                                , v-is-terminal )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_gds-grp.is-term = v-is-terminal
            .
        end.
    end.
    if buf_gds-grp.is-term = no
    then do:
        find first buf_goods no-lock
             where buf_goods.grp-code = buf_gds-grp.node-code
        no-error.
        if available buf_goods
        then do:
            run write-log in this-procedure (
                  input 2
                , input substitute( "test: Товар привязан к нетерминальной группе. Код товара: &1. Артикул: &2. Группа &3 &4."
                                    , buf_goods.gds-code
                                    , buf_goods.artic
                                    , buf_gds-grp.node-code
                                    , buf_gds-grp.node-name
                                  )
            ).
        end.
    end.
    run grplib-get-lvl-num in this-procedure (
          input p-node-code
        , output v-lvl-num
    ).
    if buf_gds-grp.lvl-num <> v-lvl-num
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение lvl-num для группы &2 &3: &4|&5"
                                , p-mode
                                , buf_gds-grp.node-code
                                , buf_gds-grp.node-name
                                , buf_gds-grp.lvl-num
                                , v-lvl-num )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_gds-grp.lvl-num = v-lvl-num
            .
        end.
    end.
end.
end procedure. /* set-grp-fields */

/*==========================================================================*/
procedure set-unit-base :
define input parameter p-mode       as character        no-undo.
define input parameter p-node-code  as integer          no-undo.

    define variable v-is-first-goods-in-grp     as logical      no-undo.
    define variable v-is-first-lower-grp        as logical      no-undo.
    define variable v-unit-base                 as character    no-undo.
    define variable v-is-terminal               as logical      no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_lower_gds-grp for ub.gds-grp.
    define buffer buf_goods         for ub.goods.
do
for buf_gds-grp
  , buf_lower_gds-grp
  , buf_goods
on error undo, return error
:
    assign
        v-unit-base             = ?
        v-is-first-goods-in-grp = yes
        v-is-first-lower-grp    = yes
    .
    if p-mode = "update":U
    then do:
        find first buf_gds-grp exclusive-lock
             where buf_gds-grp.node-code = p-node-code
        .
    end.        /* if p-mode = "update":U */
    else do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = p-node-code
        .
    end.        /* NOT ( if p-mode = "update":U ) */
    run grplib-is-terminal in this-procedure (
          input p-node-code
        , output v-is-terminal
    ).
    if v-is-terminal = yes
    then do:
        loop-by-goods:
        for each buf_goods no-lock
           where buf_goods.grp-code = buf_gds-grp.node-code
        on error undo, return error
        :
            if v-is-first-goods-in-grp = yes
            then do:
                assign
                    v-unit-base             = buf_goods.unit-base
                    v-is-first-goods-in-grp = no
                .
            end.        /* if v-is-first-goods-in-grp = yes */
            else do:
                if buf_goods.unit-base <> v-unit-base
                then do:
                    assign
                        v-unit-base = ?
                    .
                    leave loop-by-goods.
                end.
            end.        /* NOT ( if v-is-first-goods-in-grp = yes ) */
        end.        /* for each buf_goods */
    end.        /* if v-is-terminal = yes */
    else do:
        loop-by-lower-groups:
        for each buf_lower_gds-grp no-lock
           where buf_lower_gds-grp.upper-code = p-node-code
        on error undo, return error
        :
            if v-is-first-lower-grp = yes
            then do:
                assign
                    v-unit-base             = buf_lower_gds-grp.unit-base
                    v-is-first-lower-grp    = no
                .
            end.        /* if v-is-first-lower-grp = yes */
            else do:
                if buf_lower_gds-grp.unit-base <> v-unit-base
                then do:
                    assign
                        v-unit-base = ?
                    .
                    leave loop-by-lower-groups.
                end.        /* if buf_lower_gds-grp.unit-base <> v-unit-base */
            end.        /* NOT ( if v-is-first-lower-grp = yes ) */
        end.        /* for each buf_lower_gds-grp */
    end.        /* NOT ( if v-is-terminal = yes ) */
    if buf_gds-grp.unit-base <> v-unit-base
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение unit-base для группы &2 &3: &4|&5"
                    , p-mode
                    , buf_gds-grp.node-code
                    , buf_gds-grp.node-name
                    , buf_gds-grp.unit-base
                    , v-unit-base
                    )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_gds-grp.unit-base = v-unit-base
            .
        end.
    end.
end.
end procedure. /* set-unit-base */


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
define input parameter p-gds-code                   as integer          no-undo.
define input-output parameter p-goods-counter       as integer          no-undo.
define input-output parameter p-relations-counter   as integer          no-undo.

    define buffer buf_goods         for ub.goods.
    define buffer buf_gds-obj       for ub.gds-obj.
    define buffer buf_el_gds-obj    for ub.gds-obj.
do
for buf_goods
  , buf_gds-obj
  , buf_el_gds-obj
on error undo, return error
:
    assign
        p-goods-counter = p-goods-counter + 1
    .
    if p-mode = "update":U
    then do:
        find first buf_goods exclusive-lock
             where buf_goods.gds-code = p-gds-code
        .
    end.
    else do:
        find first buf_goods no-lock
             where buf_goods.gds-code = p-gds-code
        .
    end.
    run grplib-get-full-name in this-procedure (
          input buf_goods.grp-code
        , output v-full-grp-name
    ).
    if buf_goods.grp-name <> v-full-grp-name
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение полного имени группы товара: &2|&3. Товар: &4."
                                , p-mode
                                , buf_goods.grp-name
                                , v-full-grp-name
                                , buf_goods.artic
                              )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_goods.grp-name = v-full-grp-name
            .
        end.
    end.
    for each buf_gds-obj no-lock
       where buf_gds-obj.artic      = buf_goods.artic
         and buf_gds-obj.prod-type  = buf_goods.prod-type
         and buf_gds-obj.prod-code  = buf_goods.prod-code
    :
        assign
            p-relations-counter     = p-relations-counter + 1
        .
        if buf_gds-obj.grp-name <> v-full-grp-name
        then do:
            run write-log in this-procedure (
                  input 2
                , input substitute( "&1: изменение полного имени группы товара на объекте: &2|&3. Товар: &4. Объект: &5&6"
                                    , p-mode
                                    , buf_gds-obj.grp-name
                                    , v-full-grp-name
                                    , buf_goods.artic
                                    , buf_gds-obj.obj-type
                                    , buf_gds-obj.obj-code
                                  )
            ).
            if p-mode = "update":U
            then do:
                find first buf_el_gds-obj exclusive-lock
                     where recid( buf_el_gds-obj ) = recid( buf_gds-obj )
                .
                assign
                    buf_el_gds-obj.grp-name = v-full-grp-name
                .
            end.
        end.
    end.
end.
end procedure. /* set-full-grp-name */