/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры проверки для документов производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define temp-table temp_fbrtest_recipe no-undo
    field recipe-code   as character
    field error-code    as integer
    field gds-code      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer

    index pi is primary unique recipe-code error-code artic prod-type prod-code
    index gc gds-code
    index ar artic prod-type prod-code
.

define variable v-fbrtest-error-description as character extent 3 init
    [ "Нет товара в рецепте"
    , "Количество составного товара не равно 1 в рецепте альтернативы"
    ] no-undo.

/*==========================================================================*/
/*
Тестирование рецептов производства.
Input:
    p-recipe-code      - код рецепта
    p-append-error     - не очищать temp-table ошибок
    p-error-code-list  - список кодов ошибок, которые надо тестировать:
        "" - все ошибки,
        "1" - отсутствие товаров в рецепте,
        "2" - количество <> 1 в составном товаре альтернативы
Output:
    p-bad-recipe - ошибки найдены.
    При ошибках заполняется temp-table temp_fbrtest_recipe.
*/
procedure fbrtest-test-recipe :
do
on error undo, return error
:
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-append-error       as logical      no-undo.
define input parameter p-error-code-list    as character    no-undo.
define output parameter p-bad-recipe        as logical      no-undo.

    define variable v-have-error    as logical       no-undo.

    if p-append-error = no
    then do:
        for each temp_fbrtest_recipe
        :
            delete temp_fbrtest_recipe.
        end.
    end.
    if p-error-code-list = ""
    or lookup( "1", p-error-code-list ) > 0
    then do:
        run fbrtest-test-goods-in-recipe in this-procedure (
              input p-recipe-code
            , output v-have-error
        ).
        if v-have-error = yes
        then do:
            assign
                p-bad-recipe = yes
            .
        end.
    end.
    if p-error-code-list = ""
    or lookup( "2", p-error-code-list ) > 0
    then do:
        run fbrtest-test-alt-qnty-in-recipe in this-procedure (
              input p-recipe-code
            , output v-have-error
        ).
        if v-have-error = yes
        then do:
            assign
                p-bad-recipe = yes
            .
        end.
    end.
end.
end procedure. /* fbrtest-test-recipe */

/*==========================================================================*/
procedure fbrtest-test-goods-in-recipe :
do
on error undo, return error
:
define input parameter p-recipe-code        as character    no-undo.
define output parameter p-no-exists-good    as logical      no-undo.

    define buffer buf_recipe                for ub.recipe.
    define buffer buf_recipe-gds            for ub.recipe-gds.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_temp_fbrtest_recipe   for temp_fbrtest_recipe.

    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_recipe.artic
           and buf_goods.prod-type  = buf_recipe.prod-type
           and buf_goods.prod-code  = buf_recipe.prod-code
    no-error.
    if not available buf_goods
    then do:
        assign
            p-no-exists-good = yes
        .
        create buf_temp_fbrtest_recipe.
        assign
            buf_temp_fbrtest_recipe.recipe-code  = p-recipe-code
            buf_temp_fbrtest_recipe.error-code   = 1
            buf_temp_fbrtest_recipe.artic        = buf_recipe.artic
            buf_temp_fbrtest_recipe.prod-type    = buf_recipe.prod-type
            buf_temp_fbrtest_recipe.prod-code    = buf_recipe.prod-code
            buf_temp_fbrtest_recipe.gds-code     = buf_recipe.gds-code
        .
    end.
    for each buf_recipe-gds no-lock
       where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic      = buf_recipe-gds.artic
               and buf_goods.prod-type  = buf_recipe-gds.prod-type
               and buf_goods.prod-code  = buf_recipe-gds.prod-code
        no-error.
        if not available buf_goods
        then do:
            assign
                p-no-exists-good = yes
            .
            create buf_temp_fbrtest_recipe.
            assign
                buf_temp_fbrtest_recipe.recipe-code  = p-recipe-code
                buf_temp_fbrtest_recipe.error-code   = 1
                buf_temp_fbrtest_recipe.artic        = buf_recipe-gds.artic
                buf_temp_fbrtest_recipe.prod-type    = buf_recipe-gds.prod-type
                buf_temp_fbrtest_recipe.prod-code    = buf_recipe-gds.prod-code
                buf_temp_fbrtest_recipe.gds-code     = buf_recipe-gds.gds-code
            .
        end.
    end.        /* for each buf_recipe-gds */
end.
end procedure. /* fbrtest-test-goods-in-recipe */

/*==========================================================================*/
procedure fbrtest-test-alt-qnty-in-recipe :
do
on error undo, return error
:
define input parameter p-recipe-code    as character    no-undo.
define output parameter p-bad-qnty      as logical      no-undo.

    define buffer buf_recipe                for ub.recipe.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_temp_fbrtest_recipe   for temp_fbrtest_recipe.

    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_recipe.artic
           and buf_goods.prod-type  = buf_recipe.prod-type
           and buf_goods.prod-code  = buf_recipe.prod-code
    no-error.
    if buf_recipe.recipe-type = {&alternative}
    then do:
        if buf_recipe.qnty <> 1
        then do:
            assign
                p-bad-qnty = yes
            .
            create buf_temp_fbrtest_recipe.
            assign
                buf_temp_fbrtest_recipe.recipe-code  = p-recipe-code
                buf_temp_fbrtest_recipe.error-code   = 2
                buf_temp_fbrtest_recipe.artic        = buf_recipe.artic
                buf_temp_fbrtest_recipe.prod-type    = buf_recipe.prod-type
                buf_temp_fbrtest_recipe.prod-code    = buf_recipe.prod-code
                buf_temp_fbrtest_recipe.gds-code     = buf_recipe.gds-code
            .
        end.
    end.        /* buf_recipe.recipe-type = {&alternative} */
end.
end procedure. /* fbrtest-test-alt-qnty-in-recipe */

/* $Workfile$ e n d */