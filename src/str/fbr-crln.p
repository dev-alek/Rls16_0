block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbr-crln.p $
$Archive: str/fbr-crln.p $

создание и/или заполнение строки производства, в т.ч. цен

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-fbr-doc-recid      as recid                    no-undo.
define input parameter p-goods-recid        as recid                    no-undo.
define input parameter p-recipe-code        like fbr-line.recipe-code   no-undo.    /* номер рассчитываемого рецепта */
define input parameter p-trn-type           like fbr-line.trn-type      no-undo.    /* тип обрабатываемой строки, ? не допускается */
define input parameter p-is-comp            like fbr-line.is-comp       no-undo.    /* составная / ингредиент */
define input parameter p-is-recursive       as logical                  no-undo.    /* вызвано из рекурсивного добавления товара */
define input parameter p-price-obj-type     like clients.obj-type       no-undo.    /* тип объекта для поиска прод цены */
define input parameter p-price-obj-code     like clients.obj-code       no-undo.    /* код объекта для поиска прод цены */
define output parameter p-fbr-line-recid    as recid                no-undo.    /* recid новой / измененной строки */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbr-crln.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbr-crln.p $":U .
define variable vss-description as character no-undo init "создание и/или заполнение строки производства, в т.ч. цен".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ trg/partslib.i }
{ str/fbrlib.i   }

do
on error undo, return error
:

    define variable v-price-sale    as decimal       no-undo.
    define variable v-yesno         as logical       no-undo.

    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-line      for fbr-line.
    define buffer buf_goods         for goods.
    define buffer buf_fbr-recipe-gds    for fbr-recipe-gds.

    find first buf_fbr-doc no-lock
         where recid( buf_fbr-doc ) = p-fbr-doc-recid
    .
    find first buf_goods no-lock
        where recid( buf_goods ) = p-goods-recid
    .
    /* ищем строку для конкретного товара для конкретного рецепта */
    find first buf_fbr-line
         where buf_fbr-line.prod-code   = buf_goods.prod-code
           and buf_fbr-line.prod-type   = buf_goods.prod-type
           and buf_fbr-line.artic       = buf_goods.artic
           and buf_fbr-line.doc-code    = buf_fbr-doc.doc-code
           and buf_fbr-line.is-comp     = p-is-comp
           and buf_fbr-line.recipe-code = p-recipe-code
    no-error.
    do on error undo, return error
    :
        if available buf_fbr-line
        then do:
            if not p-is-recursive
            then do:
                assign
                    v-yesno = no
                .
                message "Товар: " buf_goods.artic buf_goods.gds-name skip
                        "Рецепт:" p-recipe-code skip
                        "- УЖЕ ЕСТЬ в этом документе. Добавить в эти строки?"
                        view-as alert-box question buttons YES-NO update v-yesno.
                if not v-yesno
                then do:
                    return error.
                end.
            end.
        end.        /* available buf_fbr-line */
        else do:
            find first buf_fbr-recipe-gds no-lock
                 where buf_fbr-recipe-gds.doc-code    = buf_fbr-doc.doc-code
                   and buf_fbr-recipe-gds.recipe-code = p-recipe-code
                   and buf_fbr-recipe-gds.prod-type   = buf_goods.prod-type
                   and buf_fbr-recipe-gds.prod-code   = buf_goods.prod-code
                   and buf_fbr-recipe-gds.artic       = buf_goods.artic
            no-error.
            create buf_fbr-line.
            assign
                buf_fbr-line.recipe-code        = p-recipe-code
                buf_fbr-line.trn-type           = p-trn-type
                buf_fbr-line.doc-code           = buf_fbr-doc.doc-code
                buf_fbr-line.artic              = buf_goods.artic
                buf_fbr-line.prod-code          = buf_goods.prod-code
                buf_fbr-line.prod-type          = buf_goods.prod-type
                buf_fbr-line.is-calc            = no                /* прод. цена будет браться из прайс-листа */
                buf_fbr-line.is-comp            = p-is-comp
                buf_fbr-line.is-waste           = ( if available buf_fbr-recipe-gds and buf_fbr-recipe-gds.is-waste = yes then yes else no )
                buf_fbr-line.calc-method        = ( if available buf_fbr-recipe-gds then buf_fbr-recipe-gds.calc-method  else 1 )
                buf_fbr-line.coeff-value        = ( if available buf_fbr-recipe-gds then buf_fbr-recipe-gds.coeff-value  else 0 )
                buf_fbr-line.coeff-waste        = ( if available buf_fbr-recipe-gds then buf_fbr-recipe-gds.coeff-waste  else 0 )
                buf_fbr-line.price-base         = ?
                buf_fbr-line.price-rubl         = ?
                buf_fbr-line.price-sum-base     = ?
                buf_fbr-line.price-sum-rubl     = ?
                buf_fbr-line.price-sum-vat-base = ?
                buf_fbr-line.price-sum-vat-rubl = ?
            .
            run fbrlib-calc-prices in this-procedure (
                  input recid( buf_fbr-line )
                , input p-price-obj-type
                , input p-price-obj-code
                , output v-price-sale
            ) no-error.
            if error-status:error then do:
              undo, return error substitute("Ошибка при расчете цен по док-ту пр-ва &4&1&2&1&3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  , buf_fbr-line.doc-code
                                  ).
            end.
            if v-price-sale <> ?
            then do:    /* нулевую цену не ставим, чтобы можно было задать вручную */
                assign
                    buf_fbr-line.price-sale = v-price-sale
                .
                if p-price-obj-type <> buf_fbr-doc.obj-type
                or p-price-obj-code <> buf_fbr-doc.obj-code
                then do:    /* цена с другого объекта - фиксируем */
                    assign
                        buf_fbr-line.is-calc = yes
                    .
                end.
            end.        /* if v-price-sale <> ? */
            else if buf_fbr-line.trn-type     = {&income} then  buf_fbr-line.price-sale = 0.  /*если производятся модификаторы, то цена у них нулевая*/
        end.        /* not available buf_fbr-line */
    end.
    assign
        p-fbr-line-recid = recid (buf_fbr-line)
    .
end.