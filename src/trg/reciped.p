block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление рецепта

Автор: Белоусов Илья Александрович
Дата создания: 03/23/06
Author: Ilia Belousov
Creation date: 03/23/06

Input:

Output:

*/

TRIGGER PROCEDURE FOR DELETE OF ub.recipe.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление рецепта".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/tbl-name.i }
{ gbl/cur-time.i }

main-block:
do
on error undo main-block, return error
:
    run nws/cmd-del.p (
          input {&table_recipe}
        , input ( buffer ub.recipe:handle )
        , input "":U
    ) no-error .
    if error-status :error
    then do:
        undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
    for each ub.recipe-gds
       where ub.recipe-gds.recipe-code = ub.recipe.recipe-code
    on error undo main-block, return error
    :
        delete ub.recipe-gds .
    end .
    if not g#news
    then do:
        run write-history in this-procedure.
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_recipe}
        , input ( buffer ub.recipe:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                            , {&new-line}
                            , vss-workfile
                            , return-value
                            , error-status :get-message ( 1 ) ).
    end.
    end.
end.

/*==========================================================================*/
procedure write-history :

    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.

    define buffer buf_c-recipe          for ub.c-recipe.
    define buffer buf_c-table-bind      for ub.c-table-bind.
    define buffer buf_c-recipe-hist     for ub.c-recipe-hist.
    define buffer buf_c-gds-hist        for ub.c-gds-hist.
do
for buf_c-recipe
  , buf_c-table-bind
  , buf_c-recipe-hist
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    create buf_c-recipe.
    buffer-copy ub.recipe to buf_c-recipe.
    assign
        buf_c-recipe.corr-user-db-num = g#db-num
        buf_c-recipe.chip-num         = next-value( s-fbr-chip, {&db-name_schema} )
        buf_c-recipe.corr-time        = v-time
        buf_c-recipe.corr-user-name   = g#userid
        buf_c-recipe.corr-date        = v-today
        buf_c-recipe.corr-action      = integer( {&hn-delete} )
    .
    create buf_c-recipe-hist.
    assign
        buf_c-recipe-hist.subject             = {&table_recipe}
        buf_c-recipe-hist.corr-date           = v-today
        buf_c-recipe-hist.corr-time           = v-time
        buf_c-recipe-hist.corr-user-name      = g#userid
        buf_c-recipe-hist.chip-num            = next-value( s-fbr-chip, {&db-name_schema} )
        buf_c-recipe-hist.corr-user-db-num    = g#db-num
        buf_c-recipe-hist.gds-code            = buf_c-recipe.gds-code
        buf_c-recipe-hist.is-default          = buf_c-recipe.is-default
        buf_c-recipe-hist.recipe-chip-num     = buf_c-recipe.chip-num
        buf_c-recipe-hist.recipe-code         = buf_c-recipe.recipe-code
        buf_c-recipe-hist.recipe-gds-chip-num = 0
        buf_c-recipe-hist.recipe-type         = buf_c-recipe.recipe-type
        buf_c-recipe-hist.action              = integer( {&hn-delete} )
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-recipe-hist
    except chip-num
    to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = integer({&hn-delete})
    buf_c-gds-hist.subject = {&table_recipe}
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.chip-num = next-value (s-gds-chip, {&db-name_schema})
    buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
    create buf_c-table-bind.
    assign
        buf_c-table-bind.corr-user-db-num     = g#db-num
        buf_c-table-bind.tbl-name-src   = {&table_c-recipe}
        buf_c-table-bind.chip-num-src   = buf_c-recipe.chip-num
        buf_c-table-bind.tbl-name-rec   = {&table_c-gds-hist}
        buf_c-table-bind.chip-num-rec   = buf_c-gds-hist.chip-num
        buf_c-table-bind.is-news         = g#news
        buf_c-table-bind.corr-user-name  = g#userid
        buf_c-table-bind.subject         = {&table_recipe}
        buf_c-gds-hist.subject = {&table_recipe}
    .


end.
end procedure. /* write-history */