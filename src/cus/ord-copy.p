block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Копирование заказов в документ производства

Автор: Чернова Светлана Александровна
Дата создания: 06/04/09
Author: Svetlana Chernova
Creation date: 06/04/09

*/

define input parameter parparentproc            as handle           no-undo.
define input parameter p-fbr-doc-doc-code       as character        no-undo.
define input parameter p-ord-doc-code           as character        no-undo.   /* номер накладной - источника */
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
define variable vss-description as character no-undo init "Копирование заказов в документ производства.".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/lib-def.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ str/writelog.i def "'fbr.log'" no-create }
{ str/trdcalib.i }
{ str/tpsidoc.i   "NEW SHARED"  proc }
{ str/dtl-rest.i new }
{ str/dtlrestm.i  " new shared " }
{ trg/partslib.i }
{ str/temp_upd.i }
{ gbl/objsrv.i   }
{ str/fbrcode.i  }
{ str/fbrlib.i   }
{ str/fbrrest.i  }
{ str/fbradd.i   }

define variable v-copy-qnty             like ub.ord-line.fact-qnty     no-undo.    /* количество из источника */
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

define buffer buf_ord-line          for ub.ord-line.
define buffer buf_ord-doc           for ub.ord-doc.
define buffer buf_goods             for ub.goods.

do
for buf_ord-line
  , buf_ord-doc
  , buf_goods
on error undo, return error
:

  { gbl/getcntxt.i get }

    find first buf_ord-doc no-lock
         where buf_ord-doc.doc-code = p-ord-doc-code
    .
    assign
        v-auto-select-recipes = yes
    .
    message
        "Добавление строк из заказа №" buf_ord-doc.doc-code
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

    for each buf_ord-line no-lock
       where buf_ord-line.doc-code = buf_ord-doc.doc-code
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic     = buf_ord-line.artic
               and buf_goods.prod-type = buf_ord-line.prod-type
               and buf_goods.prod-code = buf_ord-line.prod-code .


          v-copy-qnty = buf_ord-line.qnty .

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
end.