block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrclcln.p $
$Archive: str/fbrclcln.p $

Пересчет учетных сумм строки документа производства по партиям.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-trn-doc-code       as character        no-undo.
define input parameter p-fbr-doc-code       as character        no-undo.
define input parameter p-trn-type           as character        no-undo.
define input parameter p-recipe-code        as character        no-undo.
define input parameter p-artic              as character        no-undo.
define input parameter p-prod-type          as character        no-undo.
define input parameter p-prod-code          as integer          no-undo.
define input parameter p-is-free            as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrclcln.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbrclcln.p $":U .
define variable vss-description as character no-undo init "Пересчет учетных сумм строки документа производства по партиям.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/clcprtsl.i }
{ str/fbrlib.i   }

    define variable v-write-off-sum-price-rubl        as decimal        no-undo.
    define variable v-write-off-sum-price-base        as decimal        no-undo.
    define variable v-write-off-sum-vat-price-rubl    as decimal        no-undo.
    define variable v-write-off-sum-vat-price-base    as decimal        no-undo.

    define buffer buf_doc-line      for doc-line.
    define buffer buf_fbr-line      for fbr-line.
do
for buf_doc-line
  , buf_fbr-line
on error undo, return error
:
        find first buf_doc-line no-lock
             where buf_doc-line.doc-code    = p-trn-doc-code
               and buf_doc-line.artic       = p-artic
               and buf_doc-line.prod-type   = p-prod-type
               and buf_doc-line.prod-code   = p-prod-code
        .
        run clcprtsl_calc-line in this-procedure (
            input recid( buf_doc-line )
        ).
        find first tt-allsum-line
             where tt-allsum-line.sum-type = {&sum-general}
        .
        find first buf_fbr-line exclusive-lock
             where buf_fbr-line.doc-code    = p-fbr-doc-code
               and buf_fbr-line.trn-type    = p-trn-type
               and buf_fbr-line.recipe-code = p-recipe-code
               and buf_fbr-line.artic       = p-artic
               and buf_fbr-line.prod-type   = p-prod-type
               and buf_fbr-line.prod-code   = p-prod-code
        .
        assign
            buf_fbr-line.price-sum-base     = tt-allsum-line.sum-dsc-base-acc - tt-allsum-line.vat-base-acc
            buf_fbr-line.price-sum-rubl     = tt-allsum-line.sum-dsc-rubl-acc - tt-allsum-line.vat-rubl-acc
            buf_fbr-line.price-sum-vat-base = tt-allsum-line.vat-base-acc
            buf_fbr-line.price-sum-vat-rubl = tt-allsum-line.vat-rubl-acc
            buf_fbr-line.price-base         = buf_fbr-line.price-sum-base / buf_fbr-line.fact-qnty
            buf_fbr-line.price-rubl         = buf_fbr-line.price-sum-rubl / buf_fbr-line.fact-qnty
        .
        if p-is-free = yes
        then do:
            assign
                v-write-off-sum-price-rubl     = 0
                v-write-off-sum-price-base     = 0
                v-write-off-sum-vat-price-rubl = 0
                v-write-off-sum-vat-price-base = 0
            .
            for each buf_fbr-line no-lock
               where buf_fbr-line.doc-code    = p-fbr-doc-code
                 and buf_fbr-line.trn-type    = {&write-off}
            on error undo, return error
            :
                assign
                    v-write-off-sum-price-rubl     = v-write-off-sum-price-rubl     + buf_fbr-line.price-sum-rubl
                    v-write-off-sum-price-base     = v-write-off-sum-price-base     + buf_fbr-line.price-sum-base
                    v-write-off-sum-vat-price-rubl = v-write-off-sum-vat-price-rubl + buf_fbr-line.price-sum-vat-rubl
                    v-write-off-sum-vat-price-base = v-write-off-sum-vat-price-base + buf_fbr-line.price-sum-vat-base
                .
            end.        /* for each buf_fbr-line */
            run fbrlib-calc-free-doc-in-costs in this-procedure (
                  input p-fbr-doc-code
                , input v-write-off-sum-price-rubl
                , input v-write-off-sum-price-base
                , input v-write-off-sum-vat-price-rubl
                , input v-write-off-sum-vat-price-base
            ) no-error .
           if error-status:error then do:
              undo, return error substitute("Ошибка при расчете цен для документа производства &1&2&3&2&4"
                                           , p-fbr-doc-code
                                           , {&new-line}
                                           , error-status:get-message(1)
                                           , return-value
            ).
           end.
        end.        /* if p-is-free = yes  */
        else do:
            run fbrlib-calc-all-cost-prices in this-procedure (
                input p-fbr-doc-code
            ) no-error.
           if error-status:error then do:
              undo, return error substitute("Ошибка при расчете учетных цен для документа производства &1&2&3&2&4"
                                           , p-fbr-doc-code
                                           , {&new-line}
                                           , error-status:get-message(1)
                                           , return-value
            ).
           end.
        end.        /* NOT ( if p-is-free = yes  ) */
end.


/*==========================================================================*/
procedure fbrlib-calc-all-cost-prices :
    define input parameter p-fbr-doc-code   as character    no-undo.

    define buffer buf_fbr-line      for fbr-line.
    define buffer buf_recipe        for recipe.
    define buffer buf_fbr-doc       for fbr-doc.

do
for buf_fbr-line
  , buf_recipe
  , buf_fbr-doc
on error undo, return error
:
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-code
    .
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-code
         and buf_fbr-line.is-comp  = yes
    :       /* Пересчитываем учетные цены всех товаров */
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = buf_fbr-line.recipe-code
        no-error.
        if ( available buf_recipe
           and ( buf_recipe.recipe-type <> {&dressing}
           and ( buf_recipe.recipe-type <> {&gathering} ) )
        or buf_fbr-line.trn-type  <> {&income} )
        then do:
            run fbrlib-calc-inc-fbr-ln-costs in this-procedure (
                  input buf_fbr-line.doc-code
                , input buf_fbr-line.recipe-code
            ) no-error.
           if error-status:error then do:
              undo, return error substitute("Ошибка при расчете цен для документа производства &1&2&3&2&4"
                                           , p-fbr-doc-code
                                           , {&new-line}
                                           , error-status:get-message(1)
                                           , return-value
            ).
        end.
        end.
        else do:        /* Для разделки и разукомплектации надо раскидывать измененную цену по компонентам */
            run fbrlib-calc-w-o-fbr-ln-costs in this-procedure (
                  input buf_fbr-line.doc-code
                , input buf_fbr-line.recipe-code
            ) no-error .
          undo, return error substitute("Ошибка при расчете цен для компонентов документа производства &1&2&3&2&4"
                                        , p-fbr-doc-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
            ).

        end.
    end.        /* for each buf_fbr-line no-lock */
    run fbrlib-fill-sum-fbr-doc in this-procedure (
          input recid( buf_fbr-doc )
        , input {&rsrv-dtl_action_reserv}
    ) no-error.
    if error-status:error then do:
      undo, return error substitute("Ошибка при заполнении сумм по документу производства &1&2&3&2&4"
                                    , p-fbr-doc-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
    ).
end.
end.
end procedure. /* fbrlib-calc-all-cost-prices */

/*==========================================================================
Расчет учетных цен для рецептов КРОМЕ разделки и разукомплектации в документе производства.
Учетная цена составного товара рассчитывается как сумма учетных цен ингредиентов.
*/
procedure fbrlib-calc-inc-fbr-ln-costs :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-recipe-code        as character    no-undo.

    define variable v-sum-price-rubl     as decimal       no-undo.
    define variable v-sum-price-base     as decimal       no-undo.
    define variable v-sum-vat-price-rubl as decimal       no-undo.
    define variable v-sum-vat-price-base as decimal       no-undo.

    define buffer buf_income_fbr-line     for fbr-line.
    define buffer buf_write-off_fbr-line     for fbr-line.

    for each buf_write-off_fbr-line no-lock
       where buf_write-off_fbr-line.doc-code    = p-fbr-doc-doc-code
         and buf_write-off_fbr-line.trn-type    = {&write-off}
         and buf_write-off_fbr-line.recipe-code = p-recipe-code
    on error undo, return error
    :
        assign
            v-sum-price-rubl     = v-sum-price-rubl     + ( if buf_write-off_fbr-line.price-rubl <> ? then buf_write-off_fbr-line.fact-qnty * buf_write-off_fbr-line.price-rubl else 0 )
            v-sum-price-base     = v-sum-price-base     + ( if buf_write-off_fbr-line.price-base <> ? then buf_write-off_fbr-line.fact-qnty * buf_write-off_fbr-line.price-base else 0 )
            v-sum-vat-price-rubl = v-sum-vat-price-rubl + ( if buf_write-off_fbr-line.price-sum-vat-rubl <> ? then buf_write-off_fbr-line.price-sum-vat-rubl else 0 )
            v-sum-vat-price-base = v-sum-vat-price-base + ( if buf_write-off_fbr-line.price-sum-vat-base <> ? then buf_write-off_fbr-line.price-sum-vat-base else 0 )
        .
    end.
    do transaction
    on error undo, return error
    :
        find first buf_income_fbr-line exclusive-lock
             where buf_income_fbr-line.doc-code    = p-fbr-doc-doc-code
               and buf_income_fbr-line.trn-type    = {&income}
               and buf_income_fbr-line.recipe-code = p-recipe-code
        .
        assign
            buf_income_fbr-line.price-sum-rubl        = v-sum-price-rubl
            buf_income_fbr-line.price-sum-base        = v-sum-price-base
            buf_income_fbr-line.price-sum-vat-rubl    = v-sum-vat-price-rubl
            buf_income_fbr-line.price-sum-vat-base    = v-sum-vat-price-base
            buf_income_fbr-line.price-rubl            = v-sum-price-rubl / buf_income_fbr-line.fact-qnty
            buf_income_fbr-line.price-base            = v-sum-price-base / buf_income_fbr-line.fact-qnty
        .
    end.        /* do transaction */
end.
end procedure. /* fbrlib-calc-inc-fbr-ln-costs */

/*==========================================================================
Расчет учетных цен для рецептов разделки и разукомплектации в документе производства.
Учетная цена составного товара распределяется по строкам полученных ингредиентов
пропорционально продажной цене.
*/
procedure fbrlib-calc-w-o-fbr-ln-costs :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-recipe-code        as character    no-undo.

    define variable v-sum-price-sale            as decimal      no-undo.
    define variable v-sum-price-cost-rubl       as decimal      no-undo.
    define variable v-sum-price-cost-base       as decimal      no-undo.
    define variable v-sum-price-vat-cost-rubl   as decimal      no-undo.
    define variable v-sum-price-vat-cost-base   as decimal      no-undo.
    define variable v-cost-factor               as decimal      no-undo.
    define variable v-write-off-qnty            as decimal      no-undo.

    define buffer buf_income_fbr-line     for fbr-line.
    define buffer buf_write-off_fbr-line     for fbr-line.

    for each buf_income_fbr-line no-lock
       where buf_income_fbr-line.doc-code    = p-fbr-doc-doc-code
         and buf_income_fbr-line.trn-type    = {&income}
         and buf_income_fbr-line.recipe-code = p-recipe-code
         and buf_income_fbr-line.fix-cost    = no
         and buf_income_fbr-line.is-waste    = no
    on error undo, return error
    :       /* Собираем сумму нефиксированных приходов в продажных ценах */
        assign
            v-sum-price-sale = v-sum-price-sale + ( buf_income_fbr-line.price-sale * buf_income_fbr-line.fact-qnty )
        .
    end.
    find first buf_write-off_fbr-line no-lock
         where buf_write-off_fbr-line.doc-code    = p-fbr-doc-doc-code
           and buf_write-off_fbr-line.trn-type    = {&write-off}
           and buf_write-off_fbr-line.recipe-code = p-recipe-code
    .
    assign      /* Суммы списанного товара в учетных ценах */
        v-write-off-qnty          = buf_write-off_fbr-line.fact-qnty
        v-sum-price-cost-rubl     = buf_write-off_fbr-line.price-sum-rubl
        v-sum-price-cost-base     = buf_write-off_fbr-line.price-sum-base
        v-sum-price-vat-cost-rubl = buf_write-off_fbr-line.price-sum-vat-rubl
        v-sum-price-vat-cost-base = buf_write-off_fbr-line.price-sum-vat-base
    .
    for each buf_income_fbr-line exclusive-lock
       where buf_income_fbr-line.doc-code    = p-fbr-doc-doc-code
         and buf_income_fbr-line.trn-type    = {&income}
         and buf_income_fbr-line.recipe-code = p-recipe-code
         and ( buf_income_fbr-line.fix-cost    = yes
               /*or buf_income_fbr-line.is-waste = yes*/ )
    on error undo, return error
    :       /* Вычитаем фиксированные суммы и суммы отходов из суммы списанного товара, которую надо распределить по нефиксированным приходам */
        assign
            v-write-off-qnty          = v-write-off-qnty          - buf_income_fbr-line.fact-qnty
            v-sum-price-cost-rubl     = v-sum-price-cost-rubl     - buf_income_fbr-line.price-sum-rubl
            v-sum-price-cost-base     = v-sum-price-cost-base     - buf_income_fbr-line.price-sum-base
            v-sum-price-vat-cost-rubl = v-sum-price-vat-cost-rubl - buf_income_fbr-line.price-sum-vat-rubl
            v-sum-price-vat-cost-base = v-sum-price-vat-cost-base - buf_income_fbr-line.price-sum-vat-base
        .
    end.
    do transaction
    on error undo, return error
    :
        for each buf_income_fbr-line exclusive-lock
           where buf_income_fbr-line.doc-code    = p-fbr-doc-doc-code
             and buf_income_fbr-line.trn-type    = {&income}
             and buf_income_fbr-line.recipe-code = p-recipe-code
             and buf_income_fbr-line.fix-cost    = no
             and buf_income_fbr-line.is-waste    = no
        on error undo, return error
        :       /* Распределяем сумму списанного товара по нефиксированным товарам прихода */
            assign
                v-cost-factor                            = buf_income_fbr-line.price-sale * buf_income_fbr-line.fact-qnty / v-sum-price-sale
                buf_income_fbr-line.price-sum-rubl       = v-sum-price-cost-rubl        * v-cost-factor
                buf_income_fbr-line.price-sum-base       = v-sum-price-cost-base        * v-cost-factor
                buf_income_fbr-line.price-sum-vat-rubl   = v-sum-price-vat-cost-rubl    * v-cost-factor
                buf_income_fbr-line.price-sum-vat-base   = v-sum-price-vat-cost-base    * v-cost-factor
                buf_income_fbr-line.price-rubl           = buf_income_fbr-line.price-sum-rubl / buf_income_fbr-line.fact-qnty
                buf_income_fbr-line.price-base           = buf_income_fbr-line.price-sum-base / buf_income_fbr-line.fact-qnty
            .
        end.
    end.        /* do transaction */
end.
end procedure. /* fbrlib-calc-w-o-fbr-ln-costs */


/*==========================================================================
Процедура раскидывает суммы учетных цен списания в свободном документе
по строкам прихода
*/
procedure fbrlib-calc-free-doc-in-costs :
define input parameter p-doc-code                       as character    no-undo.
define input parameter p-write-off-sum-price-rubl       as decimal      no-undo.
define input parameter p-write-off-sum-price-base       as decimal      no-undo.
define input parameter p-write-off-sum-vat-price-rubl   as decimal      no-undo.
define input parameter p-write-off-sum-vat-price-base   as decimal      no-undo.

    define variable v-fbr-line-cost-coeff   as decimal       no-undo.
    define variable v-income-sum-price-sale as decimal       no-undo.

    define buffer buf_fbr-line      for fbr-line.
do
for buf_fbr-line
on error undo, return error
:

    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-doc-code
         and buf_fbr-line.trn-type = {&income}
    on error undo, return error
    :
        assign
            v-income-sum-price-sale = v-income-sum-price-sale   + buf_fbr-line.price-sale * buf_fbr-line.fact-qnty
        .
    end.        /* for each buf_fbr-line */
    for each buf_fbr-line exclusive-lock
       where buf_fbr-line.doc-code = p-doc-code
         and buf_fbr-line.trn-type = {&income}
    on error undo, return error
    :
        assign
            buf_fbr-line.rsrv-qnty          = buf_fbr-line.fact-qnty
            v-fbr-line-cost-coeff           = buf_fbr-line.price-sale * buf_fbr-line.fact-qnty / v-income-sum-price-sale
            buf_fbr-line.price-sum-rubl     = p-write-off-sum-price-rubl     * v-fbr-line-cost-coeff
            buf_fbr-line.price-sum-base     = p-write-off-sum-price-base     * v-fbr-line-cost-coeff
            buf_fbr-line.price-sum-vat-rubl = p-write-off-sum-vat-price-rubl * v-fbr-line-cost-coeff
            buf_fbr-line.price-sum-vat-base = p-write-off-sum-vat-price-base * v-fbr-line-cost-coeff
            buf_fbr-line.price-rubl         = buf_fbr-line.price-sum-rubl / buf_fbr-line.fact-qnty
            buf_fbr-line.price-base         = buf_fbr-line.price-sum-base / buf_fbr-line.fact-qnty
        .
    end.        /* for each buf_fbr-line */
end.
end procedure. /* fbrlib-calc-free-doc-in-costs */