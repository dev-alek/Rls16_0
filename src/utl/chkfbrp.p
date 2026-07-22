block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkfbrp.p $
$Archive: utl/chkfbrp.p $

Проверка рецептов и документов производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle  as widget-handle    no-undo.
define input parameter p-log-handle     as handle           no-undo.
define input parameter p-parameters     as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkfbrp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chkfbrp.p $":U .
define variable vss-description as character no-undo init "Проверка рецептов и документов производства".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

    define variable v-file-name    as character    no-undo.
    define variable v-gds-code     as integer      no-undo.
    define variable v-stop-check   as logical      no-undo.

    define buffer buf_goods             for goods.
    define buffer buf_recipe            for recipe.
    define buffer buf_recipe-gds        for recipe-gds.
    define buffer buf_fbr-recipe        for fbr-recipe.
    define buffer buf_fbr-recipe-gds    for fbr-recipe-gds.
do
on error undo, return error
:
    assign
        v-file-name = "chkfbrp.txt"
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка товаров в рецептах."
    ).
    for each buf_recipe no-lock
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic     = buf_recipe.artic
               and buf_goods.prod-type = buf_recipe.prod-type
               and buf_goods.prod-code = buf_recipe.prod-code
        no-error.
        if not available buf_goods
        then do:
            run write-log-and-file in p-log-handle (
                  input 4
                , input v-file-name
                , input 4
                , input substitute( "Не найден товар &1 &2 &3 в рецепте &4"
                    , buf_recipe.artic
                    , buf_recipe.prod-type
                    , buf_recipe.prod-code
                    , buf_recipe.recipe-code )
            ).
        end.
    end.        /* for each buf_recipe */
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка товаров в рецептах завершена."
    ).
    run get-stop-state in p-log-handle (
        output v-stop-check
    ).
    if v-stop-check = yes
    then do:
        message
            "Прервать выполнение процедуры проверки?"
        view-as alert-box question
        buttons yes-no
        title "Прервать операцию"
        update v-stop-check.
        if v-stop-check = yes
        then do:
            undo, return.
        end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка товаров в ингредиентах рецептов."
    ).
    for each buf_recipe-gds no-lock
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic     = buf_recipe-gds.artic
               and buf_goods.prod-type = buf_recipe-gds.prod-type
               and buf_goods.prod-code = buf_recipe-gds.prod-code
        no-error.
        if not available buf_goods
        then do:
            run write-log-and-file in p-log-handle (
                  input 4
                , input v-file-name
                , input 4
                , input substitute( "Не найден товар &1 &2 &3 в ингредиенте рецепта &4"
                    , buf_recipe-gds.artic
                    , buf_recipe-gds.prod-type
                    , buf_recipe-gds.prod-code
                    , buf_recipe-gds.recipe-code )
            ).
        end.
    end.        /* for each buf_recipe-gds */
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка товаров в ингредиентах рецептов завершена."
    ).
    run get-stop-state in p-log-handle (
        output v-stop-check
    ).
    if v-stop-check = yes
    then do:
        message
            "Прервать выполнение процедуры проверки?"
        view-as alert-box question
        buttons yes-no
        title "Прервать операцию"
        update v-stop-check.
        if v-stop-check = yes
        then do:
            undo, return.
        end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка товаров в рецептах документов."
    ).
    for each buf_fbr-recipe no-lock
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic     = buf_fbr-recipe.artic
               and buf_goods.prod-type = buf_fbr-recipe.prod-type
               and buf_goods.prod-code = buf_fbr-recipe.prod-code
        no-error.
        if not available buf_goods
        then do:
            run write-log-and-file in p-log-handle (
                  input 4
                , input v-file-name
                , input 4
                , input substitute( "Не найден товар &1 &2 &3 в рецепте &4 документа &5"
                    , buf_fbr-recipe.artic
                    , buf_fbr-recipe.prod-type
                    , buf_fbr-recipe.prod-code
                    , buf_fbr-recipe.recipe-code
                    , buf_fbr-recipe.doc-code )
            ).
        end.
    end.        /* for each buf_fbr-recipe */
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка товаров в рецептах документов завершена."
    ).
    run get-stop-state in p-log-handle (
        output v-stop-check
    ).
    if v-stop-check = yes
    then do:
        message
            "Прервать выполнение процедуры проверки?"
        view-as alert-box question
        buttons yes-no
        title "Прервать операцию"
        update v-stop-check.
        if v-stop-check = yes
        then do:
            undo, return.
        end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка товаров в ингредиентах рецептов документов."
    ).
    for each buf_fbr-recipe-gds no-lock
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic     = buf_fbr-recipe-gds.artic
               and buf_goods.prod-type = buf_fbr-recipe-gds.prod-type
               and buf_goods.prod-code = buf_fbr-recipe-gds.prod-code
        no-error.
        if not available buf_goods
        then do:
            run write-log-and-file in p-log-handle (
                  input 4
                , input v-file-name
                , input 4
                , input substitute( "Не найден товар &1 &2 &3 в ингредиенте рецепта &4 документа &5"
                    , buf_fbr-recipe-gds.artic
                    , buf_fbr-recipe-gds.prod-type
                    , buf_fbr-recipe-gds.prod-code
                    , buf_fbr-recipe-gds.recipe-code
                    , buf_fbr-recipe-gds.doc-code )
            ).
        end.
    end.        /* for each buf_fbr-recipe-gds */
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка товаров в ингредиентах рецептов документов завершена."
    ).
    run get-stop-state in p-log-handle (
        output v-stop-check
    ).
    if v-stop-check = yes
    then do:
        message
            "Прервать выполнение процедуры проверки?"
        view-as alert-box question
        buttons yes-no
        title "Прервать операцию"
        update v-stop-check.
        if v-stop-check = yes
        then do:
            undo, return.
        end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка на ингредиенты без рецептов."
    ).
    for each buf_recipe-gds no-lock
    on error undo, return error
    :
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = buf_recipe-gds.recipe-code
        no-error.
        if not available buf_recipe
        then do:
            run write-log-and-file in p-log-handle (
                  input 4
                , input v-file-name
                , input 4
                , input substitute( "Не найден рецепт &1 для ингредиента с артикулом &2"
                    , buf_recipe-gds.recipe-code
                    , buf_recipe-gds.artic       )
            ).
        end.
    end.        /* for each buf_recipe */
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка на ингредиенты без рецептов завершена."
    ).
    run get-stop-state in p-log-handle (
        output v-stop-check
    ).
    if v-stop-check = yes
    then do:
        message
            "Прервать выполнение процедуры проверки?"
        view-as alert-box question
        buttons yes-no
        title "Прервать операцию"
        update v-stop-check.
        if v-stop-check = yes
        then do:
            undo, return.
        end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка на ингредиенты без рецептов в документе."
    ).
    for each buf_fbr-recipe-gds no-lock
    on error undo, return error
    :
        find first buf_fbr-recipe no-lock
             where buf_fbr-recipe.doc-code    = buf_fbr-recipe-gds.doc-code
               and buf_fbr-recipe.recipe-code = buf_fbr-recipe-gds.recipe-code
        no-error.
        if not available buf_fbr-recipe
        then do:
            run write-log-and-file in p-log-handle (
                  input 4
                , input v-file-name
                , input 4
                , input substitute( "Не найден рецепт &1 в документе &2 для ингредиента с артикулом &3"
                    , buf_fbr-recipe-gds.recipe-code
                    , buf_fbr-recipe-gds.doc-code
                    , buf_fbr-recipe-gds.artic       )
            ).
        end.
    end.        /* for each buf_recipe */
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка на ингредиенты без рецептов в документе завершена."
    ).
    run get-stop-state in p-log-handle (
        output v-stop-check
    ).
    if v-stop-check = yes
    then do:
        message
            "Прервать выполнение процедуры проверки?"
        view-as alert-box question
        buttons yes-no
        title "Прервать операцию"
        update v-stop-check.
        if v-stop-check = yes
        then do:
            undo, return.
        end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка соответствия кода товара артикулу в рецептах."
    ).
    for each buf_recipe no-lock
    on error undo, return error
    :
        { gbl/gds-code.i
            buf_recipe.artic
            buf_recipe.prod-type
            buf_recipe.prod-code
            v-gds-code
        }
        if v-gds-code <> buf_recipe.gds-code
        then do:
            run write-log-and-file in p-log-handle (
                  input 4
                , input v-file-name
                , input 4
                , input substitute( "Неверный код товара с артикулом &1 в рецепте &2"
                    , buf_recipe.artic
                    , buf_recipe.recipe-code )
            ).
        end.
    end.        /* for each buf_recipe */
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка соответствия кода товара артикулу в рецептах завершена."
    ).
    run get-stop-state in p-log-handle (
        output v-stop-check
    ).
    if v-stop-check = yes
    then do:
        message
            "Прервать выполнение процедуры проверки?"
        view-as alert-box question
        buttons yes-no
        title "Прервать операцию"
        update v-stop-check.
        if v-stop-check = yes
        then do:
            undo, return.
        end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка соответствия кода товара артикулу в ингредиентах рецептов."
    ).
    for each buf_recipe-gds no-lock
    on error undo, return error
    :
        { gbl/gds-code.i
            buf_recipe-gds.artic
            buf_recipe-gds.prod-type
            buf_recipe-gds.prod-code
            v-gds-code
        }
        if v-gds-code <> buf_recipe-gds.gds-code
        then do:
            run write-log-and-file in p-log-handle (
                  input 4
                , input v-file-name
                , input 4
                , input substitute( "Неверный код товара с артикулом &1 в ингредиентах рецепта &2"
                    , buf_recipe-gds.artic
                    , buf_recipe-gds.recipe-code )
            ).
        end.
    end.        /* for each buf_recipe */
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка соответствия кода товара артикулу в ингредиентах рецептов завершена."
    ).
    run get-stop-state in p-log-handle (
        output v-stop-check
    ).
    if v-stop-check = yes
    then do:
        message
            "Прервать выполнение процедуры проверки?"
        view-as alert-box question
        buttons yes-no
        title "Прервать операцию"
        update v-stop-check.
        if v-stop-check = yes
        then do:
            undo, return.
        end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка соответствия кода товара артикулу в рецептах документов."
    ).
    for each buf_fbr-recipe no-lock
    on error undo, return error
    :
        { gbl/gds-code.i
            buf_fbr-recipe.artic
            buf_fbr-recipe.prod-type
            buf_fbr-recipe.prod-code
            v-gds-code
        }
        if v-gds-code <> buf_fbr-recipe.gds-code
        then do:
            run write-log-and-file in p-log-handle (
                  input 4
                , input v-file-name
                , input 4
                , input substitute( "Неверный код товара с артикулом &1 в рецепте &2 документа &3"
                    , buf_fbr-recipe.artic
                    , buf_fbr-recipe.recipe-code
                    , buf_fbr-recipe.doc-code
                    )
            ).
        end.
    end.        /* for each buf_fbr-recipe */
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка соответствия кода товара артикулу в рецептах документов завершена."
    ).
    run get-stop-state in p-log-handle (
        output v-stop-check
    ).
    if v-stop-check = yes
    then do:
        message
            "Прервать выполнение процедуры проверки?"
        view-as alert-box question
        buttons yes-no
        title "Прервать операцию"
        update v-stop-check.
        if v-stop-check = yes
        then do:
            undo, return.
        end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка соответствия кода товара артикулу в ингредиентах рецептов документов."
    ).
    for each buf_fbr-recipe-gds no-lock
    on error undo, return error
    :
        { gbl/gds-code.i
            buf_fbr-recipe-gds.artic
            buf_fbr-recipe-gds.prod-type
            buf_fbr-recipe-gds.prod-code
            v-gds-code
        }
        if v-gds-code <> buf_fbr-recipe-gds.gds-code
        then do:
            run write-log-and-file in p-log-handle (
                  input 4
                , input v-file-name
                , input 4
                , input substitute( "Неверный код товара с артикулом &1 в ингредиентах рецепта &2 документа &3"
                    , buf_fbr-recipe-gds.artic
                    , buf_fbr-recipe-gds.recipe-code
                    , buf_fbr-recipe-gds.doc-code
                  )
            ).
        end.
    end.        /* for each buf_recipe */
    run write-log-and-file in p-log-handle (
          input 1
        , input v-file-name
        , input 1
        , input "Проверка соответствия кода товара артикулу в ингредиентах рецептов документов завершена."
    ).
    run write-log in p-log-handle (
          input 1
        , input substitute( "Лог программы выведен в файл &1", v-file-name )
    ).
end.