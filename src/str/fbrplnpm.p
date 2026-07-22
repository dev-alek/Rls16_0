block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закрытие плана-меню до статуса разрешен.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbrhist-handle as widget-handle    no-undo .
define input parameter p-log-handle     as handle           no-undo.
define input parameter p-doc-code       as character        no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Закрытие плана-меню до статуса разрешен.":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/doc-code.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ str/writelog.i def "'fbr.log'" no-create }
{ trg/partslib.i }
{ str/temp_upd.i }
{ gbl/objsrv.i   }
{ str/fbrlib.i   }
{ str/fbrpln.i   }
{ str/fbrrest.i  }
{ str/fbradd.i   }
{ str/fbrhist.i  }
{ str/trdcalib.i }
{ str/fbrattr.i  }

    define temp-table temp_fbr-objects no-undo
        field obj-type  as character
        field obj-code  as integer

        index pi is primary unique obj-type obj-code
    .

    define variable v-fbr-doc-code              as character      no-undo.
    define variable v-same-good                 as logical        no-undo.
    define variable v-same-good-old-qnty        as decimal        no-undo.
    define variable v-is-comp                   as logical        no-undo.
    define variable v-trn-type                  as character      no-undo.
    define variable v-store-obj-type            as character      no-undo.
    define variable v-store-obj-code            as integer        no-undo.
    define variable v-fbrplnpm-history-level    as integer      no-undo.
    define variable v-fbrplnpm-hst-upper-code   as integer      no-undo.
    define variable v-upper-code                as integer      no-undo.

    define buffer buf_fbr-pln       for fbr-pln.
    define buffer buf_fbr-pln-line  for fbr-pln-line.
    define buffer buf_goods         for goods.
    define buffer buf_recipe        for recipe.
    define buffer buf_fbr-doc       for fbr-doc.

do
for buf_fbr-pln
  , buf_fbr-pln-line
  , buf_goods
  , buf_recipe
  , buf_fbr-doc
on error undo, return error
:
    { gbl/working.i }
    { gbl/getcntxt.i get }

    for each temp_fbr-objects
    on error undo, return error
    :
        delete temp_fbr-objects.
    end.        /* for each temp_fbr-objects */

    for each buf_fbr-pln-line no-lock
       where buf_fbr-pln-line.doc-code     = p-doc-code
    on error undo, return error
    :
        if buf_fbr-pln-line.recipe-code <> ""
        and buf_fbr-pln-line.recipe-code <> ?
        then do:
            if buf_fbr-pln-line.fbr-obj-type <> {&shop}
            then do:
                find first buf_goods no-lock
                     where buf_goods.gds-code = buf_fbr-pln-line.gds-code
                .
                message
                         "Для производства товара указан объект"
                    skip "недопустимого типа. Производство"
                    skip "может быть только на объекте типа магазин."
                    skip(1)
                    skip "Товар:" buf_goods.artic buf_goods.gds-name
                    skip "Объект:" buf_fbr-pln-line.fbr-obj-type buf_fbr-pln-line.fbr-obj-code
                    skip(1)
                    skip "Измените данные плана-меню."
                view-as alert-box error.
                undo, return error.
            end.
            find first temp_fbr-objects
                 where temp_fbr-objects.obj-type = buf_fbr-pln-line.fbr-obj-type
                   and temp_fbr-objects.obj-code = buf_fbr-pln-line.fbr-obj-code
            no-error.
            if not available temp_fbr-objects
            then do:
                create temp_fbr-objects.
                assign
                    temp_fbr-objects.obj-type = buf_fbr-pln-line.fbr-obj-type
                    temp_fbr-objects.obj-code = buf_fbr-pln-line.fbr-obj-code
                .
            end.
        end.        /* if buf_fbr-pln-line.recipe-code <> 0 */
    end.        /* for each buf_fbr-pln-line */

    for each temp_fbr-objects
    on error undo, return error
    :
        run fbrrest-get-catering-object in this-procedure (
              input temp_fbr-objects.obj-code
            , output v-store-obj-type
            , output v-store-obj-code
        ).
        if v-store-obj-type = ""
        and v-store-obj-code = 0
        then do:
            message
                     "Для объекта не указан склад ингредиентов."
                skip(1)
                skip "Объект:" {&shop} temp_fbr-objects.obj-code
            view-as alert-box error.
            undo, return error.
        end.
    end.

    do transaction
    on error undo, return error
    :
        find first buf_fbr-pln exclusive-lock
             where buf_fbr-pln.doc-code = p-doc-code
        .
        run write-log in p-log-handle (
              input 1
            , input substitute( "Ресторан &1 &2. Документ план-меню '&3'."
                                , buf_fbr-pln.obj-type
                                , buf_fbr-pln.obj-code
                                , p-doc-code
                            )
        ).
        run writelog in this-procedure (
              input log-file-name
            , input 0
            , input substitute( "Ресторан &1 &2. Документ план-меню '&3'."
                                , buf_fbr-pln.obj-type
                                , buf_fbr-pln.obj-code
                                , p-doc-code
                            )
        ).
        for each temp_fbr-objects
        on error undo, return error
        :
            run write-log in p-log-handle (
                  input 3
                , input substitute( "Кухня &1 &2."
                                    , temp_fbr-objects.obj-type
                                    , temp_fbr-objects.obj-code
                                )
            ).
            run writelog in this-procedure (
                  input log-file-name
                , input 0
                , input substitute( "Кухня &1 &2."
                                    , temp_fbr-objects.obj-type
                                    , temp_fbr-objects.obj-code
                                )
            ).
            run fbrpln-create-fbr-doc in this-procedure (
                  input temp_fbr-objects.obj-type
                , input temp_fbr-objects.obj-code
                , input p-doc-code
                , input ( v-cntxt-db-num <> 0 )
                , input v-cntxt-userid
                , output v-fbr-doc-code
            ).
            run write-log in p-log-handle (
                  input 5
                , input substitute( "Создается документ производства '&1'..."
                                    , v-fbr-doc-code
                                )
            ).
            run writelog in this-procedure (
                  input log-file-name
                , input 0
                , input substitute( "Создается документ производства '&1'..."
                                    , v-fbr-doc-code
                                )
            ).
                define variable v-fbroperator-string    as character    no-undo.

                run fbrattr-value in this-procedure (
                      input {&fbrattr-type-fbr-pln}
                    , input buf_fbr-pln.doc-code
                    , input {&trdcattr-fbroperator}
                    , output v-fbroperator-string
                ) no-error.
                if error-status :error
                then do:
                    message
                            vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка определения оператора план-меню."
                        skip(1)
                        skip "Выберите ответственного за операции план-меню."
                        skip return-value
                        skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                    view-as alert-box warning.
                    assign
                        v-fbroperator-string = "":U
                    .
                end.
                run str/fbrattrw.p (
                      input v-fbr-doc-code
                    , input {&trdcattr-fbroperator}
                    , input v-fbroperator-string
                ) no-error.
                if error-status :error
                then do:
                    message
                            vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Не удалось записать оператора производства."
                        skip return-value
                        skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                    view-as alert-box warning.
                end.
            if valid-handle( p-fbrhist-handle )
            then do:
                run fbrhist-write in p-fbrhist-handle (
                      input v-cntxt-userid
                    , input temp_fbr-objects.obj-type
                    , input temp_fbr-objects.obj-code
                    , input {&fbrhist-type-close-doc}
                    , input 2
                    , input "fbrplnlm.p"
                    , input "doc-code:" + p-doc-code
                    , input p-doc-code
                    , input {&plnmenu}
                    , input {&g___new}
                    , input no
                    , input ""
                    , input ""
                    , input 0
                    , input ""
                    , input 0
                    , input substitute( "Создан документ производства &1 на &2 &3"
                                        , v-fbr-doc-code
                                        , temp_fbr-objects.obj-type
                                        , temp_fbr-objects.obj-code
                                    )
                    , input no
                ).
            end.        /* if valid-handle( p-fbrhist-handle ) */
            for each buf_fbr-pln-line exclusive-lock
               where buf_fbr-pln-line.doc-code      = p-doc-code
                 and buf_fbr-pln-line.fbr-obj-type  = temp_fbr-objects.obj-type
                 and buf_fbr-pln-line.fbr-obj-code  = temp_fbr-objects.obj-code
            on error undo, return error
            :
                if buf_fbr-pln-line.recipe-code <> ?
                and buf_fbr-pln-line.recipe-code <> ""
                then do:
                    find first buf_recipe no-lock
                         where buf_recipe.recipe-code = buf_fbr-pln-line.recipe-code
                    .
                    find first buf_goods no-lock
                         where buf_goods.gds-code = buf_fbr-pln-line.gds-code
                    .
                    run write-counter in p-log-handle (
                        input substitute( "Расчет блюда: &1 &2 ..."
                            , buf_goods.artic
                            , buf_goods.gds-name
                        )
                    ).
                    run fbrlib-get-trn-type in this-procedure (
                          input buf_fbr-pln-line.recipe-code
                        , input recid( buf_goods )
                        , input yes
                        , output v-is-comp
                        , output v-trn-type
                    ).
                    run create-initial-temp-goods in this-procedure (
                          input v-fbr-doc-code
                        , input buf_fbr-pln-line.artic
                        , input buf_fbr-pln-line.prod-type
                        , input buf_fbr-pln-line.prod-code
                        , input v-trn-type
                        , input buf_recipe.recipe-type
                        , input buf_recipe.recipe-code
                        , input buf_fbr-pln-line.fact-qnty
                        , output v-same-good
                        , output v-same-good-old-qnty
                    ).
                    run calc-not-calculated-goods in this-procedure (
                          input parparentproc
                        , input p-fbrhist-handle
                        , input v-fbr-doc-code
                        , input v-same-good
                        , input v-same-good-old-qnty
                        , input no                      /* p-always-select-recipe */
                        , input yes                     /* p-add-childs           */
                        , input buf_fbr-pln.obj-type            /* p-price-sale-obj-type  */
                        , input buf_fbr-pln.obj-code            /* p-price-sale-obj-code  */
                        , input yes
                        , input yes
                    ).
                end.        /* buf_fbr-pln-line.recipe-code <> "" */
                assign
                    buf_fbr-pln-line.status_ = {&permitted}
                .
                if valid-handle( p-fbrhist-handle )
                then do:
                    run fbrhist-write in p-fbrhist-handle (
                          input v-cntxt-userid
                        , input temp_fbr-objects.obj-type
                        , input temp_fbr-objects.obj-code
                        , input {&fbrhist-type-close-doc}
                        , input 3
                        , input "fbrplnlm.p"
                        , input "doc-code:" + p-doc-code
                        , input p-doc-code
                        , input {&plnmenu}
                        , input {&g___new}
                        , input no
                        , input buf_recipe.recipe-code
                        , input buf_recipe.recipe-type
                        , input buf_goods.gds-code
                        , input {&income}
                        , input buf_fbr-pln-line.fact-qnty
                        , input substitute( "Создана строка документа производства &1 на &2 &3"
                                            , v-fbr-doc-code
                                            , temp_fbr-objects.obj-type
                                            , temp_fbr-objects.obj-code
                                        )
                        , input no
                    ).
                end.        /* if valid-handle( p-fbrhist-handle ) */
            end.        /* for each buf_fbr-pln-line */
            find first buf_fbr-doc exclusive-lock
                 where buf_fbr-doc.doc-code = v-fbr-doc-code
            .
            assign
                buf_fbr-doc.status_ = {&doc-froze}
            .
            run write-counter in p-log-handle (
                input ""
            ).
            run write-log in p-log-handle (
                  input 5
                , input substitute( "Создан документ производства '&1'"
                                    , v-fbr-doc-code
                                )
            ).
            run writelog in this-procedure (
                  input log-file-name
                , input 0
                , input substitute( "Создан документ производства '&1'"
                                    , v-fbr-doc-code
                                )
            ).
            run fbrrest-get-catering-object in this-procedure (
                  input temp_fbr-objects.obj-code
                , output v-store-obj-type
                , output v-store-obj-code
            ).
            if temp_fbr-objects.obj-type <> v-store-obj-type
            or temp_fbr-objects.obj-code <> v-store-obj-code
            then do:
                define variable v-doc-created    as logical      no-undo.
                run write-log in p-log-handle (
                      input 5
                    , input "Идет создание запроса..."
                ).
                run writelog in this-procedure (
                      input log-file-name
                    , input 0
                    , input "Идет создание запроса..."
                ).
                run str/fbrplnst.p (
                          input parparentproc
                        , input p-fbrhist-handle
                        , input v-fbrplnpm-hst-upper-code
                        , input p-doc-code                /* код план-меню                */
                        , input temp_fbr-objects.obj-code /* код объекта кухни            */
                        , input v-fbr-doc-code            /* код документа производства   */
                        , output v-doc-created            /* запрос создан */
                ).
                if v-doc-created = yes
                then do:
                    run write-log in p-log-handle (
                        input 5
                        , input "Запрос создан."
                    ).
                    run writelog in this-procedure (
                        input log-file-name
                        , input 0
                        , input "Запрос создан."
                    ).
                    if valid-handle( p-fbrhist-handle )
                    then do:
                        run fbrhist-write in p-fbrhist-handle (
                              input v-cntxt-userid
                            , input temp_fbr-objects.obj-type
                            , input temp_fbr-objects.obj-code
                            , input {&fbrhist-type-close-doc}
                            , input 2
                            , input "fbrplnlm.p"
                            , input "doc-code:" + p-doc-code
                            , input p-doc-code
                            , input {&plnmenu}
                            , input {&g___new}
                            , input no
                            , input ""
                            , input ""
                            , input 0
                            , input ""
                            , input 0
                            , input substitute( "Создан запрос на &1 &2"
                                                , temp_fbr-objects.obj-type
                                                , temp_fbr-objects.obj-code
                                            )
                            , input no
                        ).
                    end.        /* if valid-handle( p-fbrhist-handle ) */
                end.
                else do:
                    run write-log in p-log-handle (
                          input 5
                        , input "Ингредиентов достаточно. Нет необходимости создавать запрос."
                    ).
                    run writelog in this-procedure (
                        input log-file-name
                        , input 0
                        , input "Ингредиентов достаточно. Нет необходимости создавать запрос."
                    ).
                end.
            end.        /* if temp_fbr-objects.obj-type <> v-store-obj-type */
        end.        /* for each temp_fbr-objects */
        assign
            buf_fbr-pln.status_ = {&permitted}
        .
    end.        /* do transaction */
    run write-log in p-log-handle (
          input 3
        , input substitute( "Документ план-меню '&1' закрыт до статуса разрешен."
                        , p-doc-code
                            )
    ).
    run writelog in this-procedure (
          input log-file-name
        , input 0
        , input substitute( "Документ план-меню '&1' закрыт до статуса разрешен."
                        , p-doc-code
                            )
    ).
    { gbl/stopwork.i }
end.
