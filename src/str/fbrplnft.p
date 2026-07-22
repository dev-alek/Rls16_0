block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закрытие плана-меню на факт

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

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закрытие плана-меню на факт".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/doc-code.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ str/writelog.i def "'fbrpln.log'" no-create }
{ trg/partslib.i }
{ str/temp_upd.i }
{ gbl/objsrv.i   }
{ str/fbrlib.i   }
{ str/fbrpln.i   }
{ str/fbrrest.i  }
{ str/fbradd.i   }
{ trg/factord.i  }
{ str/fbrhist.i  }
{ str/trdcalib.i }
{ str/fbrattr.i  }

    define temp-table temp_fbr-objects no-undo
        field obj-type      as character
        field obj-code      as integer
        field have-recipe   as logical

        index pi is primary unique obj-type obj-code
    .
    define variable v-fbr-doc-code          as character      no-undo.
    define variable v-same-good             as logical        no-undo.
    define variable v-same-good-old-qnty    as decimal        no-undo.
    define variable v-is-comp               as logical        no-undo.
    define variable v-trn-type              as character      no-undo.
    define variable v-reserved              as logical        no-undo.
    define variable v-from-obj-type         as character      no-undo.
    define variable v-from-obj-code         as integer        no-undo.
    define variable v-fact-order            as decimal        no-undo .
    define variable v-shift-end-fact-order  as decimal        no-undo .
    define variable v-day-end-fact-order    as decimal        no-undo .
    define variable v-shift-on              as logical        no-undo.

    define buffer buf_fbr-pln       for fbr-pln.
    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-pln-line  for fbr-pln-line.
    define buffer buf_goods         for goods.
    define buffer buf_recipe        for recipe.
do
for buf_fbr-pln
  , buf_fbr-doc
  , buf_fbr-pln-line
  , buf_goods
  , buf_recipe
on error undo, return error
:
    { gbl/working.i }

    { gbl/getcntxt.i get }
    for each temp_fbr-objects
    on error undo, return error
    :
        delete temp_fbr-objects.
    end.        /* for each temp_fbr-objects */
    lines-by-kitchen:
    for each buf_fbr-pln-line no-lock
       where buf_fbr-pln-line.doc-code     = p-doc-code
    on error undo, return error
    :
        if buf_fbr-pln-line.fbr-obj-code = 0
        then do:
            undo lines-by-kitchen, next lines-by-kitchen.
        end.
        find first temp_fbr-objects
             where temp_fbr-objects.obj-type = buf_fbr-pln-line.fbr-obj-type
               and temp_fbr-objects.obj-code = buf_fbr-pln-line.fbr-obj-code
        no-error.
        if not available temp_fbr-objects
        then do:
            create temp_fbr-objects.
            assign
                temp_fbr-objects.obj-type    = buf_fbr-pln-line.fbr-obj-type
                temp_fbr-objects.obj-code    = buf_fbr-pln-line.fbr-obj-code
                temp_fbr-objects.have-recipe = ( if buf_fbr-pln-line.recipe-code <> "" then yes else no )
            .
        end.
        else do:
            if temp_fbr-objects.have-recipe = no
            then do:
                if buf_fbr-pln-line.recipe-code <> ""
                then do:
                    assign
                        temp_fbr-objects.have-recipe = yes
                    .
                end.
            end.
        end.
    end.        /* for each buf_fbr-pln-line */
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
        run str/fbrplnop.p (
            input p-doc-code
        ).
        for each temp_fbr-objects
        on error undo, return error
        :
            if temp_fbr-objects.have-recipe = yes
            then do:
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
                run fbrattr-write in this-procedure (
                      input {&fbrattr-type-fbr-doc}
                    , input v-fbr-doc-code
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
                find first buf_fbr-doc no-lock
                     where buf_fbr-doc.doc-code = v-fbr-doc-code
                .
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
                            , input buf_fbr-doc.obj-type    /* p-price-sale-obj-type  */
                            , input buf_fbr-doc.obj-code    /* p-price-sale-obj-code  */
                            , input yes                     /* p-autofbr    */
                            , input no                      /* p-have-store */
                        ).
                    end.        /* buf_fbr-pln-line.recipe-code <> "" */
                    assign
                        buf_fbr-pln-line.status_ = {&fact}
                    .
                end.        /* for each buf_fbr-pln-line */
                run write-counter in p-log-handle (
                    input ""
                ).
                run write-log in p-log-handle (
                    input 5
                    , input substitute( "Создан документ производства '&1'. Идет резервирование ингредиентов..."
                                        , v-fbr-doc-code
                                    )
                ).
                run writelog in this-procedure (
                    input log-file-name
                    , input 0
                    , input substitute( "Создан документ производства '&1'. Идет резервирование ингредиентов..."
                                        , v-fbr-doc-code
                                    )
                ).
                run str/fbr-rsrv.p (
                      input parparentproc
                    , input p-fbrhist-handle
                    , input recid( buf_fbr-doc )
                    , input no /*p-silent*/
                    , input yes              /* autofbr */
                    , input no
                    , input no
                    , output v-reserved
                ) no-error.
                if error-status :error
                or v-reserved = no
                then do:
                    message
                        "Не удалось зарезервировать товары для производства."
                        skip (1)
                        skip "Объект (кухня):" buf_fbr-doc.obj-type buf_fbr-doc.obj-code
                        skip (1)
                        skip (0) return-value
                        skip trim(error-status :get-message(1))
                                trim(error-status :get-message(2))
                                trim(error-status :get-message(3))
                    view-as alert-box error.
                    run fbrhist-write in p-fbrhist-handle (
                          input v-cntxt-userid
                        , input buf_fbr-doc.obj-type
                        , input buf_fbr-doc.obj-code
                        , input {&fbrhist-type-close-fact}
                        , input 1
                        , input "str/fbrplnft.p"
                        , input substitute( "doc-code:&1", p-doc-code )
                        , input p-doc-code
                        , input {&plnmenu}
                        , input {&permitted}
                        , input no
                        , input ""
                        , input ""
                        , input 0
                        , input ""
                        , input 0
                        , input substitute( "Не удалось зарезервировать товары для производства на объекте (кухня) &1 &2."
                                            , buf_fbr-doc.obj-type
                                            , buf_fbr-doc.obj-code
                                          )
                        , input yes
                    ).
                    undo, return error .
                end.
                run write-log in p-log-handle (
                    input 5
                    , input "Резервирование ингредиентов завершено. Идет закрытие документа производства..."
                ).
                run writelog in this-procedure (
                    input log-file-name
                    , input 0
                    , input "Резервирование ингредиентов завершено. Идет закрытие документа производства..."
                ).
                run str/fbr-fact.p ( input parparentproc
                                   , input recid( buf_fbr-doc )
                                   , input no                   /* p-silent */
                                   ) no-error.
                if error-status :error
                then do:
                    message
                        "Не удалось закрыть документ производства."
                        skip (1)
                        skip "Объект (кухня):" buf_fbr-doc.obj-type buf_fbr-doc.obj-code
                        skip (1)
                        skip trim(error-status :get-message(1))
                                trim(error-status :get-message(2))
                                trim(error-status :get-message(3))
                    view-as alert-box error.
                    run fbrhist-write in p-fbrhist-handle (
                          input v-cntxt-userid
                        , input buf_fbr-doc.obj-type
                        , input buf_fbr-doc.obj-code
                        , input {&fbrhist-type-close-fact}
                        , input 1
                        , input "str/fbrplnft.p"
                        , input substitute( "doc-code:&1", p-doc-code )
                        , input p-doc-code
                        , input {&plnmenu}
                        , input {&permitted}
                        , input no
                        , input ""
                        , input ""
                        , input 0
                        , input ""
                        , input 0
                        , input substitute( "Не удалось закрыть документ производства на объекте (кухня) &1 &2."
                                            , buf_fbr-doc.obj-type
                                            , buf_fbr-doc.obj-code
                                          )
                        , input yes
                    ).
                    undo, return error .
                end.
                run write-log in p-log-handle (
                    input 5
                    , input "Документ производства закрыт."
                ).
                run writelog in this-procedure (
                    input log-file-name
                    , input 0
                    , input "Документ производства закрыт."
                ).
            end.        /* if temp_fbr-objects.have-recipe = yes */
            else do:
            end.        /* NOT ( if temp_fbr-objects.have-recipe = yes ) */
            if temp_fbr-objects.obj-code <> buf_fbr-pln.obj-code
            then do:
                if temp_fbr-objects.have-recipe = yes
                then do:
                    run write-log in p-log-handle (
                          input 5
                        , input "Идет перемещение блюд на объект ресторан..."
                    ).
                    run writelog in this-procedure (
                          input log-file-name
                        , input 0
                        , input "Идет перемещение блюд на объект ресторан..."
                    ).
                end.        /* if temp_fbr-objects.have-recipe = yes */
                else do:
                    run write-log in p-log-handle (
                        input 3
                        , input substitute( "Перемещение со склада &1 &2."
                                            , temp_fbr-objects.obj-type
                                            , temp_fbr-objects.obj-code
                                        )
                    ).
                    run writelog in this-procedure (
                          input log-file-name
                        , input 0
                        , input substitute( "Перемещение со склада &1 &2."
                                            , temp_fbr-objects.obj-type
                                            , temp_fbr-objects.obj-code
                                        )
                    ).
                end.        /* NOT ( if temp_fbr-objects.have-recipe = yes ) */
                run str/fbrplnin.p (
                      input parparentproc
                    , input buf_fbr-doc.doc-code
                    , input p-fbrhist-handle
                    , input temp_fbr-objects.obj-code
                    , input buf_fbr-pln.obj-code
                    , input buf_fbr-pln.doc-code
                ) no-error.
                if error-status :error
                then do:
                    message
                            vss-workfile vss-revision vss-description
                        skip "Ошибка перемещения товаров."
                        skip return-value
                        skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                    view-as alert-box error.
                    run write-log in p-log-handle (
                        input 5
                        , input substitute( "Ошибка перемещения товаров. &1. &2. &3"
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                        )
                    ).
                    run writelog in this-procedure (
                        input log-file-name
                        , input 0
                        , input substitute( "Ошибка перемещения товаров. &1. &2. &3"
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                        )
                    ).
                    run fbrhist-write in p-fbrhist-handle (
                          input v-cntxt-userid
                        , input buf_fbr-doc.obj-type
                        , input buf_fbr-doc.obj-code
                        , input {&fbrhist-type-close-fact}
                        , input 1
                        , input "str/fbrplnft.p"
                        , input substitute( "doc-code:&1", p-doc-code )
                        , input p-doc-code
                        , input {&plnmenu}
                        , input {&permitted}
                        , input no
                        , input ""
                        , input ""
                        , input 0
                        , input ""
                        , input 0
                        , input substitute( "Ошибка перемещения товаров. &1. &2. &3."
                                            , return-value
                                            , trim(error-status :get-message(1))
                                            , trim(error-status :get-message(2))
                                          )
                        , input yes
                    ).
                    undo, return error .
                end.
                run write-log in p-log-handle (
                    input 5
                    , input "Перемещение товаров завершено."
                ).
                run writelog in this-procedure (
                    input log-file-name
                    , input 0
                    , input "Перемещение товаров завершено."
                ).
            end.        /* if temp_fbr-objects.obj-code <> buf_fbr-pln.obj-code */
        end.        /* for each temp_fbr-objects */
        run gbl/factdate.p (
              input buf_fbr-pln.obj-type
            , input buf_fbr-pln.obj-code
            , input-output buf_fbr-pln.fact-date
            , input-output buf_fbr-pln.fact-time
            , input-output buf_fbr-pln.shift-date
            , input-output buf_fbr-pln.shift-num
            , input-output buf_fbr-pln.shift-name
            , input        yes
        ) no-error.
        if error-status:error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка при установке даты в документе производства (buf_fbr-doc)"
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            run fbrhist-write in p-fbrhist-handle (
                  input v-cntxt-userid
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
                , input {&fbrhist-type-close-fact}
                , input 1
                , input "str/fbrplnft.p"
                , input substitute( "doc-code:&1", p-doc-code )
                , input p-doc-code
                , input {&plnmenu}
                , input {&permitted}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input substitute( "Ошибка при установке даты в документе производства (buf_fbr-doc). &1. &2. &3."
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                    )
                , input yes
            ).
            undo, return error.
        end.
        assign
            buf_fbr-pln.fact-num    = next-value( s-trn-fact, {&db-name_schema} )
        .
        /* определяем fact-order */
        { gbl/objat.i
            buf_fbr-pln.obj-type
            buf_fbr-pln.obj-code
            "'shift-on=request'"
            v-shift-on
        no-error
        }
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при запросе, включены ли смены"
                skip error-status :get-message(1)
                skip return-value
            view-as alert-box error .
            undo, return error .
        end.
        run factord in this-procedure (
              input  buf_fbr-pln.fact-date  /* p-fact-date            */
            , input  buf_fbr-pln.fact-time  /* p-fact-time            */
            , input  buf_fbr-pln.fact-num   /* p-fact-num             */
            , input  buf_fbr-pln.shift-date /* p-shift-date           */
            , input  buf_fbr-pln.shift-num  /* p-shift-num            */
            , input  v-shift-on              /* p-shift-on             */
            , output v-fact-order            /* p-fact-order           */
            , output v-shift-end-fact-order  /* p-shift-end-fact-order */
            , output v-day-end-fact-order    /* p-day-end-fact-order   */
        ) no-error .
        if error-status :error
        or v-fact-order = ?
        or v-fact-order = 0
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при определении фактического номера"
                skip "документа план-меню"
                skip "doc-code"                buf_fbr-pln.doc-code
                skip "fact-date"               buf_fbr-pln.fact-date
                skip "fact-time"               buf_fbr-pln.fact-time
                skip "fact-num"                buf_fbr-pln.fact-num
                skip "shift-date"              buf_fbr-pln.shift-date
                skip "shift-num"               buf_fbr-pln.shift-num
                skip "v-fact-order"            v-fact-order
                skip "v-shift-end-fact-order"  v-shift-end-fact-order
                skip "v-day-end-fact-order"    v-day-end-fact-order
                skip error-status :get-message(1)
                skip return-value
            view-as alert-box error .
            run fbrhist-write in p-fbrhist-handle (
                  input v-cntxt-userid
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
                , input {&fbrhist-type-close-fact}
                , input 1
                , input "str/fbrplnft.p"
                , input substitute( "doc-code:&1", p-doc-code )
                , input p-doc-code
                , input {&plnmenu}
                , input {&permitted}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input substitute( "Ошибка при определении фактического номера документа план-меню. &1. &2. &3."
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                    )
                , input yes
            ).
            undo, return error .
        end.
        assign
            buf_fbr-pln.fact-order = v-fact-order
        .
        assign
            buf_fbr-pln.status_     = {&fact}
        .
        run write-log in p-log-handle (
              input 5
            , input "Документ план-меню закрыт."
        ).
        run writelog in this-procedure (
              input log-file-name
            , input 0
            , input "Документ план-меню закрыт."
        ).
    end.        /* do transaction */
    { gbl/stopwork.i }
end.



















