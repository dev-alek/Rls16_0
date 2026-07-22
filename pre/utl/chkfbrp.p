block-level on error undo, throw.
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
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
    end.
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
    end.
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
    end.
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
    end.
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
    end.
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
    end.
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_recipe.artic
  ,input  buf_recipe.prod-type
  ,input  buf_recipe.prod-code
  ,output v-gds-code
  )  .
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
    end.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_recipe-gds.artic
  ,input  buf_recipe-gds.prod-type
  ,input  buf_recipe-gds.prod-code
  ,output v-gds-code
  )  .
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
    end.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_fbr-recipe.artic
  ,input  buf_fbr-recipe.prod-type
  ,input  buf_fbr-recipe.prod-code
  ,output v-gds-code
  )  .
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
    end.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_fbr-recipe-gds.artic
  ,input  buf_fbr-recipe-gds.prod-type
  ,input  buf_fbr-recipe-gds.prod-code
  ,output v-gds-code
  )  .
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
    end.
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
