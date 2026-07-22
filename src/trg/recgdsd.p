block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление строки рецепта

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

TRIGGER PROCEDURE FOR DELETE OF ub.recipe-gds.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление строки рецепта".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/tbl-name.i }
{ gbl/cur-time.i }

main-block:
do
on error undo main-block, return error
:
    define variable v-recipe-recid  as recid no-undo .

    define buffer buf_recipe        for recipe.

    if ub.recipe-gds.nws-self = yes
    then do:
        run nws/cmd-del.p (
              input {&table_recipe-gds}
            , input ( buffer ub.recipe-gds :handle )
            , input "":U
        ) no-error .
        if error-status :error
        then do:
            undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4"
                                , vss-workfile
                                , {&new-line}
                                , return-value
                                , error-status :get-message ( error-status :num-messages ) ).
        end.
        assign
            ub.recipe-gds.nws-self = no
        .
    end.        /* if ub.recipe-gds.nws-self = yes  */
    else do:
        /* Отправка в новости идет только при установленном флаге */
    end.        /* NOT ( if ub.recipe-gds.nws-self = yes  ) */
    if not g#news
    then do:
        run write-history in this-procedure.
    end.        /* if not g#news */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_recipe-gds}
        , input ( buffer ub.recipe-gds :handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&1. Ошибка отправки записи recipe-gds в систему OpenXML. &2&3&2&4"
                                    , vss-workfile
                                    , {&new-line}
                                    , return-value
                                    , error-status :get-message ( 1 ) ).
    end.
    end.
end.

/*==========================================================================*/
procedure write-history :

    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-recipe-chip-num   as integer      no-undo.
    define variable v-recipe-type       as character    no-undo.
    define variable v-is-default        as logical      no-undo.

    define buffer buf_c-recipe-gds      for ub.c-recipe-gds.
    define buffer buf_c-table-bind      for ub.c-table-bind.
    define buffer buf_c-recipe-hist     for ub.c-recipe-hist.
    define buffer buf_c-gds-hist        for ub.c-gds-hist.
do
for buf_c-recipe-gds
  , buf_c-table-bind
  , buf_c-recipe-hist
  , buf_c-gds-hist
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    create buf_c-recipe-gds.
    buffer-copy ub.recipe-gds to buf_c-recipe-gds.
    assign
        buf_c-recipe-gds.corr-user-db-num = g#db-num
        buf_c-recipe-gds.chip-num         = next-value( s-fbr-chip, {&db-name_schema} )
        buf_c-recipe-gds.corr-time        = v-time
        buf_c-recipe-gds.corr-user-name   = g#userid
        buf_c-recipe-gds.corr-date        = v-today
        buf_c-recipe-gds.corr-action      = integer( {&hn-delete} )
    .
    run get-recipe-for-this-line in this-procedure (
          input buf_c-recipe-gds.recipe-code
        , input buf_c-recipe-gds.chip-num
        , output v-recipe-chip-num
        , output v-recipe-type
        , output v-is-default
    ).
    create buf_c-recipe-hist.
    assign
        buf_c-recipe-hist.subject              = {&table_recipe-gds}
        buf_c-recipe-hist.corr-date             = v-today
        buf_c-recipe-hist.corr-time             = v-time
        buf_c-recipe-hist.corr-user-name        = g#userid
        buf_c-recipe-hist.chip-num              = next-value( s-fbr-chip, {&db-name_schema} )
        buf_c-recipe-hist.corr-user-db-num      = g#db-num
        buf_c-recipe-hist.gds-code              = buf_c-recipe-gds.gds-code
        buf_c-recipe-hist.is-default            = v-is-default
        buf_c-recipe-hist.recipe-chip-num       = v-recipe-chip-num
        buf_c-recipe-hist.recipe-code           = buf_c-recipe-gds.recipe-code
        buf_c-recipe-hist.recipe-gds-chip-num   = buf_c-recipe-gds.chip-num
        buf_c-recipe-hist.recipe-type           = v-recipe-type
        buf_c-recipe-hist.action                = buf_c-recipe-gds.corr-action
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-recipe-hist
    except chip-num
    to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = integer({&hn-delete})
    buf_c-gds-hist.subject = {&table_recipe-gds}
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.chip-num = next-value (s-gds-chip, {&db-name_schema})
    buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .

    create buf_c-table-bind.
    assign
    buf_c-table-bind.corr-user-db-num     = g#db-num
    buf_c-table-bind.tbl-name-src   = {&table_c-recipe-gds}
    buf_c-table-bind.chip-num-src   = buf_c-recipe-gds.chip-num
    buf_c-table-bind.tbl-name-rec   = {&table_c-gds-hist}
    buf_c-table-bind.chip-num-rec   = buf_c-gds-hist.chip-num
    buf_c-table-bind.is-news         = g#news
    buf_c-table-bind.corr-user-name  = g#userid
    buf_c-table-bind.subject         = {&table_recipe-gds}
    .
end.
end procedure. /* write-history */



/*==========================================================================*/
procedure get-recipe-for-this-line :
define input parameter p-recipe-code        as character        no-undo.
define input parameter p-chip-num           as integer          no-undo.
define output parameter p-recipe-chip-num   as integer          no-undo.
define output parameter p-recipe-type       as character        no-undo.
define output parameter p-is-default        as logical          no-undo.

    define variable v-recipe-found      as logical      no-undo.

    define buffer buf_c-recipe          for ub.c-recipe.
    define buffer buf_recipe            for ub.recipe.
do
for buf_c-recipe
  , buf_recipe
on error undo, return error
:
    assign
        v-recipe-found = no
    .
    for each buf_c-recipe no-lock
       where buf_c-recipe.recipe-code = p-recipe-code
         and buf_c-recipe.chip-num    < p-chip-num
    on error undo, return error
    :
        assign
            v-recipe-found      = yes
            p-recipe-chip-num   = buf_c-recipe.chip-num
            p-recipe-type       = buf_c-recipe.recipe-type
            p-is-default        = buf_c-recipe.is-default
        .
    end.        /* for each buf_c-recipe */
    if v-recipe-found = no
    then do:
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = p-recipe-code
        no-error.
        if available buf_recipe
        then do:
            assign
                v-recipe-found      = yes
                p-recipe-chip-num   = 0
                p-recipe-type       = buf_recipe.recipe-type
                p-is-default        = buf_recipe.is-default
            .
        end.
        else do:
            assign
                v-recipe-found      = no
                p-recipe-chip-num   = 0
                p-recipe-type       = "":U
                p-is-default        = no
            .
        end.
    end.
end.
end procedure. /* get-recipe-for-this-line */