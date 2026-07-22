block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrclcin.p $
$Archive: str/fbrclcin.p $

Производство: размазывание учётной цены

Автор: Белоусов Илья Александрович
Дата создания: 09/29/05
Author: Ilia Belousov
Creation date: 09/29/05

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrclcin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbrclcin.p $":U .
define variable vss-description as character no-undo init "Производство: размазывание учётной цены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

define input parameter p-doc-code       as character        no-undo.
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-base           as logical          no-undo.
define input parameter p-base-rate      as decimal          no-undo.
define input parameter p-base-scale     as decimal          no-undo.


    define variable v-comp-sum-cost-rubl            as decimal      no-undo.
    define variable v-comp-sum-vat-cost-rubl        as decimal      no-undo.
    define variable v-comp-sum-cost-base            as decimal      no-undo.
    define variable v-comp-sum-vat-cost-base        as decimal      no-undo.
    define variable v-comp-sum-fixed-cost-rubl      as decimal      no-undo.
    define variable v-comp-sum-fixed-vat-cost-rubl  as decimal      no-undo.
    define variable v-comp-sum-fixed-cost-base      as decimal      no-undo.
    define variable v-comp-sum-fixed-vat-cost-base  as decimal      no-undo.
    define variable v-ingr-fixed-sum-cost-rubl      as decimal      no-undo.
    define variable v-ingr-fixed-sum-vat-cost-rubl  as decimal      no-undo.
    define variable v-ingr-fixed-sum-cost-base      as decimal      no-undo.
    define variable v-ingr-fixed-sum-vat-cost-base  as decimal      no-undo.
    define variable v-vat-pc                        as decimal      no-undo.

    define variable v-income-sum-price-sale     as decimal      no-undo.

    define buffer buf_fbr-line for fbr-line.

do
for buf_fbr-line
on error undo, return error
:
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = p-doc-code
           and buf_fbr-line.recipe-code = p-recipe-code
           and buf_fbr-line.is-comp     = no
           and buf_fbr-line.fix-cost    = no
           and buf_fbr-line.is-waste    = no
    no-error.
    if not available buf_fbr-line
    then do:
        message
            "Все строки прихода фиксированы."
            skip "Изменение учётной цены невозможно."
        view-as alert-box error
        title "Изменение учётной цены ингредиента".
        undo, return error.
    end.
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = p-doc-code
           and buf_fbr-line.recipe-code = p-recipe-code
           and buf_fbr-line.is-comp     = yes
    .
    assign
        v-comp-sum-cost-rubl         = buf_fbr-line.price-sum-rubl
        v-comp-sum-vat-cost-rubl     = buf_fbr-line.price-sum-vat-rubl
        v-comp-sum-cost-base         = buf_fbr-line.price-sum-base
        v-comp-sum-vat-cost-base     = buf_fbr-line.price-sum-vat-base
    .
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code    = p-doc-code
         and buf_fbr-line.recipe-code = p-recipe-code
         and buf_fbr-line.is-comp     = no
         and buf_fbr-line.fix-cost    = yes
    :
        assign
            v-ingr-fixed-sum-cost-rubl       = v-ingr-fixed-sum-cost-rubl     + buf_fbr-line.price-sum-rubl
            v-ingr-fixed-sum-vat-cost-rubl   = v-ingr-fixed-sum-vat-cost-rubl + buf_fbr-line.price-sum-vat-rubl
            v-ingr-fixed-sum-cost-base       = v-ingr-fixed-sum-cost-base     + buf_fbr-line.price-sum-base
            v-ingr-fixed-sum-vat-cost-base   = v-ingr-fixed-sum-vat-cost-base + buf_fbr-line.price-sum-vat-base
        .
    end.
    assign
        v-comp-sum-fixed-cost-rubl     = v-comp-sum-cost-rubl       - v-ingr-fixed-sum-cost-rubl
        v-comp-sum-fixed-vat-cost-rubl = v-comp-sum-vat-cost-rubl   - v-ingr-fixed-sum-vat-cost-rubl
        v-comp-sum-fixed-cost-base     = v-comp-sum-cost-base       - v-ingr-fixed-sum-cost-base
        v-comp-sum-fixed-vat-cost-base = v-comp-sum-vat-cost-base   - v-ingr-fixed-sum-vat-cost-base
    .
    if v-comp-sum-fixed-cost-rubl     < 0
    or v-comp-sum-fixed-vat-cost-rubl < 0
    or v-comp-sum-fixed-cost-base     < 0
    or v-comp-sum-fixed-vat-cost-base < 0
    then do:
        message
            "Фиксированная учётная цена слишком велика."
        view-as alert-box information.
        undo, return error .
    end.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code    = p-doc-code
         and buf_fbr-line.recipe-code = p-recipe-code
         and buf_fbr-line.is-comp     = no
         and buf_fbr-line.fix-cost    = no
         and buf_fbr-line.is-waste    = no
    :
        assign
            v-income-sum-price-sale = v-income-sum-price-sale + ( buf_fbr-line.price-sale * buf_fbr-line.fact-qnty )
        .
    end.
    do transaction
    on error undo, return no-apply
    :
        for each buf_fbr-line exclusive-lock
           where buf_fbr-line.doc-code    = p-doc-code
             and buf_fbr-line.recipe-code = p-recipe-code
             and buf_fbr-line.is-comp     = no
             and buf_fbr-line.fix-cost    = no
             and buf_fbr-line.is-waste    = no
        :
            if p-base = yes
            then do:
                assign
                    v-vat-pc = buf_fbr-line.price-sum-vat-base / buf_fbr-line.price-sum-base
                .
                assign
                    buf_fbr-line.price-base         = v-comp-sum-fixed-cost-base    * buf_fbr-line.price-sale / v-income-sum-price-sale
                    buf_fbr-line.price-sum-base     = buf_fbr-line.price-base       * buf_fbr-line.fact-qnty
                    buf_fbr-line.price-sum-vat-base = buf_fbr-line.price-sum-base   * v-vat-pc
                .
                assign
                    buf_fbr-line.price-rubl         = buf_fbr-line.price-base
                                                            * ( if p-base-rate = 0 then 1 else p-base-rate )
                                                            / ( if p-base-scale = 0 then 1 else p-base-scale )
                    buf_fbr-line.price-sum-rubl     = buf_fbr-line.price-rubl * buf_fbr-line.fact-qnty
                    buf_fbr-line.price-sum-vat-rubl = buf_fbr-line.price-sum-vat-base
                                                            * ( if p-base-rate = 0 then 1 else p-base-rate )
                                                            / ( if p-base-scale = 0 then 1 else p-base-scale )
                .
            end.        /* if v-base = yes */
            else do:
                assign
                    v-vat-pc = buf_fbr-line.price-sum-vat-rubl / buf_fbr-line.price-sum-rubl
                .
                assign
                    buf_fbr-line.price-rubl         = v-comp-sum-fixed-cost-rubl    * buf_fbr-line.price-sale / v-income-sum-price-sale
                    buf_fbr-line.price-sum-rubl     = buf_fbr-line.price-rubl       * buf_fbr-line.fact-qnty
                    buf_fbr-line.price-sum-vat-rubl = buf_fbr-line.price-sum-rubl   * v-vat-pc
                .
                assign
                    buf_fbr-line.price-base         = buf_fbr-line.price-rubl
                                                            / ( if p-base-rate = 0 then 1 else p-base-rate )
                                                            * ( if p-base-scale = 0 then 1 else p-base-scale )
                    buf_fbr-line.price-sum-base     = buf_fbr-line.price-base * buf_fbr-line.fact-qnty
                    buf_fbr-line.price-sum-vat-base = buf_fbr-line.price-sum-vat-rubl
                                                            / ( if p-base-rate = 0 then 1 else p-base-rate )
                                                            * ( if p-base-scale = 0 then 1 else p-base-scale )
                .
            end.        /* NOT( if v-base = yes ) */
        end.
        assign
            v-ingr-fixed-sum-cost-rubl      = 0
            v-ingr-fixed-sum-vat-cost-rubl  = 0
            v-ingr-fixed-sum-cost-base      = 0
            v-ingr-fixed-sum-vat-cost-base  = 0
        .
        for each buf_fbr-line exclusive-lock
           where buf_fbr-line.doc-code    = p-doc-code
             and buf_fbr-line.recipe-code = p-recipe-code
             and buf_fbr-line.is-comp     = no
        :
            assign
                v-ingr-fixed-sum-cost-rubl      = v-ingr-fixed-sum-cost-rubl        + buf_fbr-line.price-sum-rubl
                v-ingr-fixed-sum-vat-cost-rubl  = v-ingr-fixed-sum-vat-cost-rubl    + buf_fbr-line.price-sum-vat-rubl
                v-ingr-fixed-sum-cost-base      = v-ingr-fixed-sum-cost-base        + buf_fbr-line.price-sum-base
                v-ingr-fixed-sum-vat-cost-base  = v-ingr-fixed-sum-vat-cost-base    + buf_fbr-line.price-sum-vat-base
            .
        end.
        if v-ingr-fixed-sum-cost-rubl     <> v-comp-sum-cost-rubl
        or v-ingr-fixed-sum-vat-cost-rubl <> v-comp-sum-vat-cost-rubl
        or v-ingr-fixed-sum-cost-base     <> v-comp-sum-cost-base
        or v-ingr-fixed-sum-vat-cost-base <> v-comp-sum-vat-cost-base
        then do:
            max-ingr-plus-delta:
            for each buf_fbr-line exclusive-lock
               where buf_fbr-line.doc-code    = p-doc-code
                 and buf_fbr-line.recipe-code = p-recipe-code
                 and buf_fbr-line.is-comp     = no
                 and buf_fbr-line.fix-cost    = no
                 and buf_fbr-line.is-waste    = no
            by buf_fbr-line.price-sum-rubl descending
            :
                assign
                    buf_fbr-line.price-sum-rubl         = buf_fbr-line.price-sum-rubl      - v-ingr-fixed-sum-cost-rubl     + v-comp-sum-cost-rubl
                    buf_fbr-line.price-sum-vat-rubl     = buf_fbr-line.price-sum-vat-rubl  - v-ingr-fixed-sum-vat-cost-rubl + v-comp-sum-vat-cost-rubl
                    buf_fbr-line.price-sum-base         = buf_fbr-line.price-sum-base      - v-ingr-fixed-sum-cost-base     + v-comp-sum-cost-base
                    buf_fbr-line.price-sum-vat-base     = buf_fbr-line.price-sum-vat-base  - v-ingr-fixed-sum-vat-cost-base + v-comp-sum-vat-cost-base
                    buf_fbr-line.price-rubl             = buf_fbr-line.price-sum-rubl / buf_fbr-line.fact-qnty
                    buf_fbr-line.price-base             = buf_fbr-line.price-sum-base / buf_fbr-line.fact-qnty
                .
                leave max-ingr-plus-delta.
            end.
        end.        /* if v-ingr-fixed-sum-cost-rubl     <> v-comp-sum-cost-rubl */
    end.        /* do transaction */
end.