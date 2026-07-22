block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись коррекции рецепта

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-recipe OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись коррекции рецепта".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error undo main-block, return error
:
    if ub.c-recipe.host-code = 0
    and ub.c-recipe.obj-type = ""
    and ub.c-recipe.obj-code = 0
    then do:        /* Глобальный рецепт */
        if g#db-num <> 0
        and g#news
        then do:
            /* УБД, новости. Назад не отсылать. */
        end.
        else do:        /* Глобальный рецепт отослать всюду кроме той УБД, откуда он пришел (это определить в callnews.p). */
            run send-news in this-procedure.
        end.
    end.
    else do:        /* Локальный рецепт */
        if g#db-num = 0
        then do:
            /* Из ГБД не отсылать */
        end.
        else do:        /* Из УБД всегда отсылать */
            run send-news in this-procedure.
        end.
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-recipe}
        , input ( buffer ub.c-recipe:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.

/*==========================================================================*/
procedure send-news :

    define buffer buf_recipe-gds    for ub.c-recipe-gds.
do
for buf_recipe-gds
on error undo, return error
:
    for each buf_recipe-gds exclusive-lock
       where buf_recipe-gds.recipe-code = ub.c-recipe.recipe-code
    on error undo, return error
    :
        assign
            buf_recipe-gds.nws-self = no
        .
    end.        /* for each buf_recipe-gds */
    run str/callnews.p (
          input "c-recipe"
        , input ( buffer ub.c-recipe :handle )
    ) no-error.
    if error-status :error
    then do:
        message
                vss-workfile vss-revision vss-description
            skip "Ошибка пересылки истории рецепта по новостям."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure. /* send-news */