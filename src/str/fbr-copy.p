block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Копирование накладной в документ производства.

Автор: Белоусов Илья Александрович
Дата создания: 12/12/05
Author: Ilia Belousov
Creation date: 12/12/05

Input:

Output:

*/
define input parameter parparentproc            as handle           no-undo.
define input parameter p-fbr-doc-doc-code       as character        no-undo.
define input parameter p-trn-doc-doc-code       as character        no-undo.   /* номер накладной - источника */
define input parameter p-fbr-doc-obj-type       as character        no-undo.   /* тип объекта для поиска прод цены */
define input parameter p-fbr-doc-obj-code       as integer          no-undo.   /* код объекта для поиска прод цены */
define input parameter p-price-sale-obj-type    as character        no-undo.
define input parameter p-price-sale-obj-code    as integer          no-undo.
define input parameter p-fbrhist-handle         as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Копирование накладной в документ производства.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/lib-def.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ str/writelog.i def "'fbr.log'" no-create }
{ str/trdcalib.i }
{ str/tpsidoc.i "NEW SHARED"  proc }
{ str/dtl-rest.i new }
{ str/dtlrestm.i " new shared " }
{ trg/partslib.i }
{ str/temp_upd.i }
{ gbl/objsrv.i }
{ str/fbrcode.i  }
{ str/fbrlib.i   }
{ str/fbrrest.i  }
{ str/fbradd.i   }
{ ref/gds-attr.i }
{ ref/gdsoattr.i }
{ gbl/ggoattr.i  }

    define variable v-copy-qnty             like doc-line.fact-qnty     no-undo.    /* количество из источника */
    define variable v-auto-select-recipes   as logical                  no-undo.

    define variable v-gds-code              as integer       no-undo.
    define variable v-trn-type              as character     no-undo.
    define variable v-need-qnty             as decimal       no-undo.
    define variable v-recipe-type           as character     no-undo.
    define variable v-recipe-code           as character     no-undo.
    define variable v-recipe-found          as logical       no-undo.
    define variable v-same-good             as logical       no-undo.
    define variable v-same-good-old-qnty    as decimal       no-undo.
    define variable v-no-add-good           as logical       no-undo.

    define buffer buf_doc-line          for doc-line.                       /* строка ВН продажи */
    define buffer buf_trn-doc           for trn-doc.
    define buffer buf_return_doc-line   for doc-line.
    define buffer buf_goods             for goods.
do
for buf_doc-line
  , buf_trn-doc
  , buf_return_doc-line
  , buf_goods
on error undo, return error
:

  { gbl/getcntxt.i get }

    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-doc-code
    .
    assign
        v-auto-select-recipes = yes
    .
    message
        "Добавление строк из накладной (продажи) №" buf_trn-doc.doc-code
        skip (2)
        skip "YES - выбирать рецепты автоматически"
        skip "NO - давать выбирать и добавлять рецепты по ходу работы"
        skip "CANCEL - отказ от добавления из документа"
    view-as alert-box question
    buttons YES-NO-CANCEL
    update v-auto-select-recipes.
    if v-auto-select-recipes = ?
    then do:
        return error.
    end.
    if buf_trn-doc.discnt-type = {&cash-desk}
    then do:
        run str/dtlrests.p (
                        input  buf_trn-doc.doc-code
                        ,input no /*from-close*/
                        ,input "parts":U
                        ,input yes /*p-all-goods*/
                        ,input yes /*p-is-catering*/
                        ,input no /*p-is-tpsi-obj нам н важно*/
                        ,input no /*p-neg-tpsi-weight*/
                        ,input no /*p-neg-tpsi-qnty*/
                        ,input no /*p-neg-tpsi-oper*/
        ).
    end.
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic     = buf_doc-line.artic
               and buf_goods.prod-type = buf_doc-line.prod-type
               and buf_goods.prod-code = buf_doc-line.prod-code
        .
        if buf_trn-doc.doc-type = {&expense}
        or buf_trn-doc.doc-type = {&write-off}
        then do:        /* вычисляем количество для копирования */
            if buf_trn-doc.discnt-type = {&cash-desk}
            then do:
                find first dtl-rests no-lock
                     where dtl-rests.gds-code = buf_goods.gds-code
                no-error.
                if available dtl-rests
                then do:
                    assign
                        v-copy-qnty = dtl-rests.need-qnty
                    .
                end.
                else do:
                    assign
                        v-copy-qnty = 0
                    .
                end.
            end.
            else do:
                assign
                    v-copy-qnty = buf_doc-line.fact-qnty
                .
            end.
            if v-copy-qnty <> 0
            then do:
                run str/fbrselr.p (
                      input parparentproc
                    , input p-fbr-doc-obj-type
                    , input p-fbr-doc-obj-code
                    , input buf_goods.gds-code
                    , input ( if v-copy-qnty > 0
                            then {&income}
                            else {&write-off} )
                    , input absolute( v-copy-qnty )
                    , input no
                    , input no
                    , output v-gds-code
                    , output v-trn-type
                    , output v-need-qnty
                    , output v-recipe-type
                    , output v-recipe-code
                    , output v-recipe-found
                    , output v-no-add-good
                ) no-error.
                if not error-status :error
                and v-recipe-found = yes
                and v-no-add-good  = no
                then do:
                    find first buf_goods no-lock
                        where buf_goods.gds-code = v-gds-code
                    .
                    run create-initial-temp-goods in this-procedure (
                          input p-fbr-doc-doc-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
                        , input v-trn-type
                        , input v-recipe-type
                        , input v-recipe-code
                        , input v-need-qnty
                        , output v-same-good
                        , output v-same-good-old-qnty
                    ).
                    run calc-not-calculated-goods in this-procedure (
                          input parparentproc
                        , input p-fbrhist-handle
                        , input p-fbr-doc-doc-code
                        , input v-same-good
                        , input v-same-good-old-qnty
                        , input NOT( v-auto-select-recipes )
                        , input yes
                        , input p-price-sale-obj-type
                        , input p-price-sale-obj-code
                        , input no
                        , input no
                    ).
                end.        /* if v-recipe-found = yes */
            end.        /* if v-copy-qnty <> 0 */
        end.
        else do:
            /* Нет рецепта для добавления такого товара - ничего не делаем. */
        end.
    end.
end.