block-level on error undo, throw.
/*

$Revision: deb925b3c67c, 1358, rls $
$Author: SMMolotkov $
$Date: Tue May 22 14:25:44 2018 +0300 $
$Workfile: fbr-rcp.p $
$Archive: str/fbr-rcp.p $

Резервирование и расчет учетных цен товаров рецепта.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-fbr-doc-recid     - recid документа производства
    p-recipe-code       - код рецепта

*/
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbrhist-handle as widget-handle    no-undo.
define input parameter p-fbr-doc-recid  as recid            no-undo.  /* номер рассчитываемого рецепта */
define input parameter p-silent         as logical          no-undo .
define input parameter p-recipe-code    as character        no-undo.  /* номер рассчитываемого рецепта */
define input parameter p-autofbr        as logical          no-undo.  /* раскрутка для ресторана, от продажи, на кухне */
define input parameter p-have-store     as logical          no-undo.  /* при раскрутке остатки смотреть на складе кухни */

define variable vss-revision    as character no-undo init "$Revision: deb925b3c67c, 1358, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Tue May 22 14:25:44 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbr-rcp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbr-rcp.p $":U .
define variable vss-description as character no-undo init "Резервирование и расчет учетных цен товаров рецепта.".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',p-fbr-doc-recid,p-recipe-code,p-autofbr,p-have-store)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ str/writelog.i def "'fbr.log'" no-create }
{ str/fbr-log.i  }

    define variable v-unit-type     as character            no-undo.  /* тип единицы измерения */
    define variable v-alt-in-qnty   like ub.fbr-line.fact-qnty no-undo.  /* количество в приходной строке альтернативного рецепта */

    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle     no-undo .
    define variable v-param-type            as character no-undo .

    define variable v-min-mrgn      as decimal      no-undo.      /* мин  наценка на произведенные товары */
    define variable v-max-mrgn      as decimal      no-undo.      /* макс наценка на произведенные товары */
    define variable v-sum-alternative-qnty              as decimal       no-undo.
    define variable v-sum-write-off-qnty                as decimal       no-undo.
    define variable v-sum-income-qnty                   as decimal       no-undo.
    define variable v-sum-write-off-price-r-b           as decimal       no-undo.
    define variable v-sum-write-off-price-not-r-b       as decimal       no-undo.
    define variable v-sum-vat-write-off-price-r-b       as decimal       no-undo.
    define variable v-sum-vat-write-off-price-notrb     as decimal       no-undo.
    define variable v-count-rsrv-qnty                   as integer       no-undo.
    define variable v-sum-fix-cost-price-r-b            as decimal       no-undo.
    define variable v-sum-vat-fix-cost-price-r-b        as decimal       no-undo.
    define variable v-sum-input-price-sale              as decimal       no-undo.
    define variable v-count-input-fact-qnty             as integer       no-undo.
    define variable v-sum-input-price-r-b               as decimal       no-undo.
    define variable v-sum-vat-input-price-r-b           as decimal       no-undo.
    define variable v-margin                            as decimal       no-undo.
    define variable v-rb-is-base        as logical      no-undo.
    define variable v-not-reserved      as logical      no-undo.

    define buffer buf_zero_fbr-line  for  ub.fbr-line.                   /* поиск нулевых строк альтернативы */
    define buffer buf_in_fbr-line   for  ub.fbr-line.                    /* строка производства при */

    define buffer buf_fbr-doc       for ub.fbr-doc.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_goods         for ub.goods.

do
on error undo, return error
:
    { gbl/rbisbase.i
        v-rb-is-base
    }

   run adm/shattri.p ( input "get":U
                     , input  '':u
                     , input  0
                     , input  {&attr-fbrattr}
                     , input  {&attr-fbrattr_fbr-mrgn-max}
                     , output v-value-character
                     , output v-value-date
                     , output v-max-mrgn
                     , output v-value-integer
                     , output v-value-logical
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .
   if error-status :error then do:
      /* параметр может быть не задан */
      assign
         v-max-mrgn = 0
      .
   end.

   run adm/shattri.p ( input "get":U
                     , input  '':u
                     , input  0
                     , input  {&attr-fbrattr}
                     , input  {&attr-fbrattr_fbr-mrgn-min}
                     , output v-value-character
                     , output v-value-date
                     , output v-min-mrgn
                     , output v-value-integer
                     , output v-value-logical
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .
   if error-status :error then do:
      /* параметр может быть не задан */
      assign
         v-min-mrgn = 0
      .
   end.

    run writelog in this-procedure (
          input log-file-name
        , input 0
        , input "=====*** fbr-rcp.p ***================================================"
    ).
    find first buf_fbr-doc exclusive-lock
         where recid( buf_fbr-doc ) = p-fbr-doc-recid
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = buf_fbr-doc.doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code
    .
    run writelog in this-procedure (
          input log-file-name
        , input 0
        , input substitute( "Документ &1. Рецепт &2"
                            , buf_fbr-doc.doc-code
                            , p-recipe-code )
    ).
    { gbl/working.i }
    /*---START--------- считаем учетные цены для списания и продажные для прихода ---------------------*/
    run calc-prices in this-procedure (
          input buf_fbr-doc.doc-code
        , input p-recipe-code
        , input v-rb-is-base
        , output v-unit-type
        , output v-sum-alternative-qnty
        , output v-sum-write-off-qnty
        , output v-sum-income-qnty
        , output v-sum-write-off-price-r-b
        , output v-sum-write-off-price-not-r-b
        , output v-sum-vat-write-off-price-r-b
        , output v-sum-vat-write-off-price-notrb
        , output v-count-rsrv-qnty
        , output v-sum-fix-cost-price-r-b
        , output v-sum-vat-fix-cost-price-r-b
        , output v-sum-input-price-sale
        , output v-count-input-fact-qnty
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    run writelog in this-procedure (
          input log-file-name
        , input 3
        , input substitute( "Расчитаны суммы учетных цен:"
                + {&new-line} + "                           v-unit-type                      &1"
                + {&new-line} + "                           v-sum-alternative-qnty           &2"
                + {&new-line} + "                           v-sum-write-off-qnty             &3"
                + {&new-line} + "                           v-sum-income-qnty                &4"
                + {&new-line} + "                           v-sum-write-off-price-r-b        &5"
                + {&new-line} + "                           v-sum-write-off-price-not-r-b    &6"
                + {&new-line} + "                           v-sum-vat-write-off-price-r-b    &7"
                + {&new-line} + "                           v-sum-vat-write-off-price-notrb  &8"
                + {&new-line} + "                           v-count-rsrv-qnty                &9"
                , string( v-unit-type                      )
                , string( v-sum-alternative-qnty           )
                , string( v-sum-write-off-qnty             )
                , string( v-sum-income-qnty                )
                , string( v-sum-write-off-price-r-b        )
                , string( v-sum-write-off-price-not-r-b    )
                , string( v-sum-vat-write-off-price-r-b    )
                , string( v-sum-vat-write-off-price-notrb  )
                , string( v-count-rsrv-qnty                ) )
                + substitute(
                  {&new-line} + "                           v-sum-fix-cost-price-r-b         &1"
                + {&new-line} + "                           v-sum-vat-fix-cost-price-r-b     &2"
                + {&new-line} + "                           v-sum-input-price-sale           &3"
                + {&new-line} + "                           v-count-input-fact-qnty          &4"
                , string( v-sum-fix-cost-price-r-b         )
                , string( v-sum-vat-fix-cost-price-r-b     )
                , string( v-sum-input-price-sale           )
                , string( v-count-input-fact-qnty          ) )
    ).
    /*---END----------- считаем учетные цены для списания и продажные для прихода ---------------------*/
    /* проверка возможности разложить оставшиеся приходные строки */
    if v-sum-fix-cost-price-r-b     > v-sum-write-off-price-r-b
    or v-sum-vat-fix-cost-price-r-b > v-sum-vat-write-off-price-r-b
    then do:    /* сумма в учетных ценах по фиксированным строкам больше, чем вся сумма списания */
        message "Сумма в учетных ценах по фиксированным строкам больше, чем вся сумма списания."
                skip(1) "Сумма приходных строк с фиксированной учетной ценой:"
                            v-sum-fix-cost-price-r-b
                skip    "Cумма списанных товаров в учетных ценах:            "
                            v-sum-write-off-price-r-b
                skip(1) "Сумма НДС приходных строк с фиксированной учетной ценой:"
                            v-sum-vat-fix-cost-price-r-b
                skip    "Cумма НДС списанных товаров в учетных ценах:            "
                            v-sum-vat-write-off-price-r-b
                skip(1) "Рецепт:" p-recipe-code
        view-as alert-box error.
        { gbl/stopwork.i }
        undo, return error.
    end.
    if v-count-input-fact-qnty = 0      /* все приходные цены фиксированы */
    and ( v-sum-fix-cost-price-r-b     <> v-sum-write-off-price-r-b
       or v-sum-vat-fix-cost-price-r-b <> v-sum-vat-write-off-price-r-b )
    then do:                            /* и сумма в учетных ценах по строкам прихода не равна сумме списания */
        message     "При всех фиксированных приходных ценах "
            skip    "сумма в учетных ценах по строкам прихода не равна сумме списания."
            skip(2) "Сумма приходных строк в учетных ценах:"
                    v-sum-fix-cost-price-r-b
            skip    "Сумма строк списания в учетных ценах: "
                    v-sum-write-off-price-r-b
            skip(2) "Сумма НДС приходных строк в учетных ценах:"
                    v-sum-vat-fix-cost-price-r-b
            skip    "Сумма НДС строк списания в учетных ценах: "
                    v-sum-vat-write-off-price-r-b
            skip    "Эти суммы должны быть равны, поскольку ВСЕ приходные цены фиксированы!"
            skip(1) "Рецепт:" p-recipe-code
        view-as alert-box error.
        { gbl/stopwork.i }
        undo, return error.
    end.
    if available buf_fbr-recipe
    and buf_fbr-recipe.recipe-type = {&alternative}
    then do:
        run check-alternative in this-procedure (
              input buf_fbr-doc.doc-code
            , input buf_fbr-recipe.recipe-code
            , input buf_fbr-recipe.artic
            , input buf_fbr-recipe.prod-type
            , input buf_fbr-recipe.prod-code
            , input v-alt-in-qnty
            , input v-sum-alternative-qnty
        ) no-error.
      if error-status:error then do:
        undo, return error substitute("Ошибка при проверке товаров для рецепта типа АЛЬТЕРНАТИВА:&1&2&1&3"
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
        ).
      end.
    end.        /* проверка альтернативного рецепта по суммарному количеству */
    if  v-unit-type <> ""
    and v-unit-type <> "units-differ"
    and v-unit-type <> "not-weight"
    and buf_fbr-recipe.recipe-type = {&dressing}
    then do:        /* весовой едизм - проверка весового товара по суммарному количеству */
                    /* решили производство на вес не проверять, чтоб могло выжариться или усохнуть - */
                    /*   зато будет проверка на соответствие рецепту, которой нет в разделке */
        if abs( v-sum-income-qnty + v-sum-write-off-qnty )  > 0.01
        and ( not available buf_fbr-recipe or buf_fbr-recipe.recipe-type <> {&manufacturing} )
        then do:
            message     "Для весовых товаров не совпадают количества списанного и оприходованного товара."
                skip(2) "Количество списанного товара:     " ( -1 * v-sum-write-off-qnty )
                skip    "Количество оприходованного товара:" v-sum-income-qnty
                skip(1) "Рецепт: " p-recipe-code
            view-as alert-box error.
            { gbl/stopwork.i }
            undo, return error.
        end.
    end.
    /*---START--------- проверка на отходы ---------------------*/
    if v-count-rsrv-qnty = 0
    or v-count-input-fact-qnty = 0
    then do:        /* для какого-то номера рецепта (в т.ч. пустого) в НС или ПН нет ничего кроме отходов, */
                    /* либо для альтернативы нет ни одного ненулевого ингредиента */
        message     "Среди израсходованных или произведенных товаров"
            skip    "нет ничего кроме отходов,"
            skip    "либо не заданы ингредиенты в альтернативе."
            skip(1) "Рецепт: " p-recipe-code
                view-as alert-box error.
        { gbl/stopwork.i }
        undo, return error.
    end.
    /*---END----------- проверка на отходы ---------------------*/
    /*---START--------- рассчитываем учетные цены для каждой строки при в r-b  ---------------------*/
    assign
        v-sum-input-price-r-b       = 0
        v-sum-vat-input-price-r-b   = 0
    .
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input "Расчет сумм для строки. "
    ).
    calc-cost-for-fbr-line:
    for each buf_in_fbr-line exclusive-lock
       where buf_in_fbr-line.doc-code       = buf_fbr-doc.doc-code
         and buf_in_fbr-line.trn-type       = {&income}
         and buf_in_fbr-line.recipe-code    = p-recipe-code
    on error undo, return error
    :
        run writelog in this-procedure (
              input log-file-name
            , input 2
            , input "Строка товара с артикулом " + buf_in_fbr-line.artic
        ).
        if buf_in_fbr-line.rsrv-qnty = ?
        then do:        /* отходы */
            assign
                buf_in_fbr-line.price-rubl            = 0
                buf_in_fbr-line.price-base            = 0
                buf_in_fbr-line.price-sum-rubl        = 0
                buf_in_fbr-line.price-sum-base        = 0
                buf_in_fbr-line.price-sum-vat-rubl    = 0
                buf_in_fbr-line.price-sum-vat-base    = 0
            .
            run writelog in this-procedure (
                input log-file-name
                , input 3
                , input "Отходы. Учетная цена 0. "
            ).

        end.        /* отходы */
        else do:
            if not buf_in_fbr-line.fix-cost
            then do:        /* размазываем нефиксированные */
/*
( < сумма списаний в уч.ц. > - < сумма фиксированных приходов в уч.ц. > )
------------------------------------------------------------------------  * < прод.ц. прихода по данной строке >
    < сумма нефиксированных приходов в продажных ценах >
*/
                if v-rb-is-base = yes
                then do:
                assign
                        buf_in_fbr-line.price-base            = if buf_in_fbr-line.price-sale > 0 then ( v-sum-write-off-price-r-b - v-sum-fix-cost-price-r-b )
                                                                    * buf_in_fbr-line.price-sale
                                                                    / v-sum-input-price-sale           else   ( v-sum-write-off-price-r-b - v-sum-fix-cost-price-r-b )
                        buf_in_fbr-line.price-sum-base        = buf_in_fbr-line.price-base * buf_in_fbr-line.fact-qnty
                        buf_in_fbr-line.price-sum-vat-base    = if buf_in_fbr-line.price-sale > 0 then  ( v-sum-vat-write-off-price-r-b - v-sum-vat-fix-cost-price-r-b )
                                                                    * buf_in_fbr-line.price-sale
                                                                    / v-sum-input-price-sale
                                                                    * buf_in_fbr-line.fact-qnty      else  ( v-sum-vat-write-off-price-r-b - v-sum-vat-fix-cost-price-r-b ) *  buf_in_fbr-line.fact-qnty
                    .
                    run writelog in this-procedure (
                          input log-file-name
                        , input 3
                        , input substitute( "Цены не фиксированы. В строку записаны суммы в учетных ценах: "
                                + {&new-line} + "                           price-sum-base       : &1"
                                + {&new-line} + "                           price-sum-vat-base   : &2"
                                , buf_in_fbr-line.price-sum-base
                                , buf_in_fbr-line.price-sum-vat-base  )
                    ).
                end.        /* if v-rb-is-base = yes */
                else do:
 assign
                        buf_in_fbr-line.price-rubl            = if buf_in_fbr-line.price-sale > 0 then ( v-sum-write-off-price-r-b - v-sum-fix-cost-price-r-b )
                                                                    * buf_in_fbr-line.price-sale
                                                                    / v-sum-input-price-sale           else  ( v-sum-write-off-price-r-b - v-sum-fix-cost-price-r-b )

                        buf_in_fbr-line.price-sum-rubl        = buf_in_fbr-line.price-rubl * buf_in_fbr-line.fact-qnty
                        buf_in_fbr-line.price-sum-vat-rubl    = if buf_in_fbr-line.price-sale > 0 then ( v-sum-vat-write-off-price-r-b - v-sum-vat-fix-cost-price-r-b )
                                                                    * buf_in_fbr-line.price-sale
                                                                    / v-sum-input-price-sale
                                                                    * buf_in_fbr-line.fact-qnty     else ( v-sum-vat-write-off-price-r-b - v-sum-vat-fix-cost-price-r-b )  * buf_in_fbr-line.fact-qnty
                                     .
                    run writelog in this-procedure (
                        input log-file-name
                        , input 3
                        , input substitute( "Цены не фиксированы. В строку записаны суммы в учетных ценах: "
                                + {&new-line} + "                           price-sum-rubl       : &1"
                                + {&new-line} + "                           price-sum-vat-rubl   : &2"
                                , buf_in_fbr-line.price-sum-rubl
                                , buf_in_fbr-line.price-sum-vat-rubl  )
                    ).
                end.        /* NOT ( if v-rb-is-base = yes ) */
            end.
            assign
                buf_in_fbr-line.rsrv-qnty = buf_in_fbr-line.fact-qnty.
            .
            run writelog in this-procedure (
                input log-file-name
                , input 2
                , input substitute( "Записано зарезервированное количество: &1"
                                    , string( buf_in_fbr-line.rsrv-qnty ) )
            ).
        end.        /* не отходы */
        assign      /* сумма всех приходов в r-b */
            v-sum-input-price-r-b       = v-sum-input-price-r-b
                                            + ( buf_in_fbr-line.fact-qnty
                                                * ( if v-rb-is-base = yes then buf_in_fbr-line.price-base else buf_in_fbr-line.price-rubl ) )
            v-sum-vat-input-price-r-b   = v-sum-vat-input-price-r-b
                                            + ( if v-rb-is-base = yes then buf_in_fbr-line.price-sum-vat-base else buf_in_fbr-line.price-sum-vat-rubl )
        .
        run writelog in this-procedure (
            input log-file-name
            , input 1
            , input substitute( "Вычислены суммы по приходу: "
                    + {&new-line} + "                           v-sum-input-price-r-b     :  &1"
                    + {&new-line} + "                           v-sum-vat-input-price-r-b :  &2"
                    , string( v-sum-input-price-r-b )
                    , string( v-sum-vat-input-price-r-b  )  )
        ).
        if v-min-mrgn = 0
        and v-max-mrgn = 0
        or buf_in_fbr-line.rsrv-qnty = ?
        then do:
            next calc-cost-for-fbr-line.
        end.
        find first buf_goods no-lock
             where buf_goods.artic     = buf_in_fbr-line.artic
               and buf_goods.prod-type = buf_in_fbr-line.prod-type
               and buf_goods.prod-code = buf_in_fbr-line.prod-code
        no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Не найден товар для строки рецепта " p-recipe-code
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        assign
            v-margin = ( buf_in_fbr-line.price-sale * buf_in_fbr-line.fact-qnty
                        - ( if v-rb-is-base = yes then buf_in_fbr-line.price-sum-base     else buf_in_fbr-line.price-sum-rubl     )
                        - ( if v-rb-is-base = yes then buf_in_fbr-line.price-sum-vat-base else buf_in_fbr-line.price-sum-vat-rubl )
                       ) / ( ( if v-rb-is-base = yes then buf_in_fbr-line.price-sum-base     else buf_in_fbr-line.price-sum-rubl     )
                            + ( if v-rb-is-base = yes then buf_in_fbr-line.price-sum-vat-base else buf_in_fbr-line.price-sum-vat-rubl )
                           ) * 100
        .
        if v-margin < v-min-mrgn
        or v-margin > v-max-mrgn
        then do:
            message  "Наценка выходит за значения, определенные параметрами"
                skip "минимальной и максимальной наценок для производства."
                skip(1) "Товар:  " buf_goods.artic buf_goods.gds-name
                skip    "Рецепт: " buf_fbr-recipe.recipe-code
                skip    "Наценка:" v-margin "%"
                skip(1) "В соответствии с настройкой fbr-mrgn "
                skip    "минимальная наценка:  " v-min-mrgn "%"
                skip    "максимальная наценка: " v-max-mrgn "%."
            view-as alert-box warning .
        end.
    end.    /* for each buf_in_fbr-line */
    /*---END----------- рассчитываем учетные цены для каждой строки при в r-b  ---------------------*/
    /*---START--------- рассчитываем учетные цены для каждой строки при НЕ в r-b   ---------------------*/
    calc-cost-for-fbr-line-not-r-b:
    for each buf_in_fbr-line exclusive-lock
    where buf_in_fbr-line.doc-code       = buf_fbr-doc.doc-code
        and buf_in_fbr-line.trn-type       = {&income}
        and buf_in_fbr-line.recipe-code    = p-recipe-code
    on error undo, return error
    :
        if buf_in_fbr-line.rsrv-qnty = ?
        then do:                                        /* отходы - 0 уже поставили в предыдущем цикле */
            next calc-cost-for-fbr-line-not-r-b.
        end.
        if v-rb-is-base = yes
        then do:
            assign
                /* сумма всех списаний в учетных ценах * цена прихода в r-b по данной строке / сумма всех приходов в r-b */
                buf_in_fbr-line.price-rubl            = ( if v-sum-input-price-r-b = 0
                                                                then 0
                                                                else v-sum-write-off-price-not-r-b
                                                                        * buf_in_fbr-line.price-base
                                                                        / v-sum-input-price-r-b
                                                            )
                buf_in_fbr-line.price-sum-rubl        = buf_in_fbr-line.price-rubl
                                                                * buf_in_fbr-line.fact-qnty
                buf_in_fbr-line.price-sum-vat-rubl    = ( if v-sum-vat-input-price-r-b = 0
                                                                then 0
                                                                else v-sum-vat-write-off-price-notrb
                                                                        * buf_in_fbr-line.price-sum-vat-base
                                                                        / v-sum-vat-input-price-r-b
                                                            )
            .
        end.        /* if v-rb-is-base = yes */
        else do:
            assign
                /* сумма всех списаний в учетных ценах * цена прихода в r-b по данной строке / сумма всех приходов в r-b */
                buf_in_fbr-line.price-base            = ( if v-sum-input-price-r-b = 0
                                                                then 0
                                                                else v-sum-write-off-price-not-r-b
                                                                        * buf_in_fbr-line.price-rubl
                                                                        / v-sum-input-price-r-b
                                                            )
                buf_in_fbr-line.price-sum-base        = buf_in_fbr-line.price-base
                                                                * buf_in_fbr-line.fact-qnty
                buf_in_fbr-line.price-sum-vat-base    = ( if v-sum-vat-input-price-r-b = 0
                                                                then 0
                                                                else v-sum-vat-write-off-price-notrb
                                                                        * buf_in_fbr-line.price-sum-vat-rubl
                                                                        / v-sum-vat-input-price-r-b
                                                            )
            .
        end.        /* NOT ( if v-rb-is-base = yes ) */
    end.    /* for each buf_in_fbr-line */
    /*---END----------- рассчитываем учетные цены для каждой строки при НЕ в r-b   ---------------------*/
    assign
        buf_fbr-doc.status_ = {&permitted}
    .
    { gbl/stopwork.i }
end.

/*==========================================================================*/
procedure calc-prices :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code                as character    no-undo.
define input parameter p-recipe-code                     as character    no-undo.
define input parameter p-rb-is-base                      as logical      no-undo.
define output parameter p-unit-type                      as character    no-undo.
define output parameter p-sum-alternative-qnty           as decimal      no-undo.
define output parameter p-sum-write-off-qnty             as decimal      no-undo.
define output parameter p-sum-income-qnty                as decimal      no-undo.
define output parameter p-sum-write-off-price-r-b        as decimal      no-undo.
define output parameter p-sum-write-off-price-not-r-b    as decimal      no-undo.
define output parameter p-sum-vat-write-off-price-r-b    as decimal      no-undo.
define output parameter p-sum-vat-write-off-price-notrb  as decimal      no-undo.
define output parameter p-count-rsrv-qnty                as decimal      no-undo.
define output parameter p-sum-fix-cost-price-r-b         as decimal      no-undo.
define output parameter p-sum-vat-fix-cost-price-r-b     as decimal      no-undo.
define output parameter p-sum-input-price-sale           as decimal      no-undo.
define output parameter p-count-input-fact-qnty          as decimal      no-undo.

    define variable v-count-fix-cost    as integer      no-undo.

    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input "calc-prices: Вычисление сумм по строкам списания. "
    ).
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_comp_fbr-line for ub.fbr-line.                    /* строка производства составного товара */
    define buffer buf_goods         for ub.goods.
    define buffer buf_units         for ub.units.

    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = p-fbr-doc-doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code
    .
    assign
        p-unit-type                         = ""
        p-sum-alternative-qnty              = 0
        p-sum-write-off-qnty                = 0
        p-sum-income-qnty                   = 0
        p-sum-write-off-price-r-b           = 0
        p-sum-write-off-price-not-r-b       = 0
        p-sum-vat-write-off-price-r-b       = 0
        p-sum-vat-write-off-price-notrb     = 0
        p-count-rsrv-qnty                   = 0
        v-count-fix-cost                    = 0
        p-sum-fix-cost-price-r-b            = 0
        p-sum-vat-fix-cost-price-r-b        = 0
        p-sum-input-price-sale              = 0
        p-count-input-fact-qnty             = 0
    .
    calc-prices-for-each-fbr-line:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code      = p-fbr-doc-doc-code
         and buf_fbr-line.recipe-code   = p-recipe-code
    on error undo, return error
    :
        run writelog in this-procedure (
              input log-file-name
            , input 2
            , input substitute( "Товар с артикулом &1"
                                , buf_fbr-line.artic )
        ).
        find first buf_goods no-lock
             where buf_goods.artic     = buf_fbr-line.artic
               and buf_goods.prod-type = buf_fbr-line.prod-type
               and buf_goods.prod-code = buf_fbr-line.prod-code
        .
        find first buf_units no-lock
             where buf_units.unit-name = buf_goods.unit-base
        .
        if buf_fbr-line.fact-qnty = ?
        then do:
            { gbl/stopwork.i }
          undo, return error substitute("Не указано количество товара в документе пр-ва &5.&1Рецепт:  &2&1Товар:   &3 &4"
                                        , {&new-line}
                                        , buf_fbr-line.recipe-code
                                        , buf_fbr-line.artic
                                        , buf_goods.gds-name
                                        ,p-fbr-doc-doc-code
                                        ).
        end.
        /*---START------ проверка количества товара в строке документа на соответствие рецепту  ------------------*/
        if buf_fbr-recipe.recipe-type <> {&dressing}               /* по рецепту разделки ничего проверить нельзя */
        and ( buf_fbr-recipe.artic <> buf_fbr-line.artic
            or buf_fbr-recipe.prod-type <> buf_fbr-line.prod-type
            or buf_fbr-recipe.prod-code <> buf_fbr-line.prod-code ) /* это не товар заголовка рецепта */
        then do:
            find first buf_fbr-recipe-gds no-lock
                 where buf_fbr-recipe-gds.doc-code      = buf_fbr-line.doc-code
                   and buf_fbr-recipe-gds.recipe-code   = buf_fbr-line.recipe-code
                   and buf_fbr-recipe-gds.prod-type     = buf_fbr-line.prod-type
                   and buf_fbr-recipe-gds.prod-code     = buf_fbr-line.prod-code
                   and buf_fbr-recipe-gds.artic         = buf_fbr-line.artic
            no-error.
            if not available buf_fbr-recipe-gds
            then do:
                { gbl/stopwork.i }
                undo, return error substitute("Отсутствует строка рецепта. Расчет невозможен. Измените документ &1.&2" +
                                              "Артикул: &3 &4&2Рецепт: &4"
                                        ,p-fbr-doc-doc-code
                                        , {&new-line}
                                        , buf_goods.artic
                                        , buf_goods.gds-name
                                        , buf_fbr-line.recipe-code
                                        ).
            end.
            find first buf_comp_fbr-line
                 where buf_comp_fbr-line.doc-code     = p-fbr-doc-doc-code
                   and buf_comp_fbr-line.recipe-code  = p-recipe-code
                   and buf_comp_fbr-line.is-comp      = yes
            no-error.
            if not available buf_comp_fbr-line
            then do:
                undo, return error substitute("&1 &2 &3&4Не найдена строка составного товара в документе пр-ва &7.&4&5&4&6"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value
                                              ,p-fbr-doc-doc-code
                                              ).
            end.
            if buf_fbr-recipe.recipe-type = {&alternative}
            then do:        /* вычисляем сумму по рецепту альтернатива */
                assign
                    p-sum-alternative-qnty = p-sum-alternative-qnty + ( buf_fbr-line.fact-qnty * buf_fbr-recipe-gds.brutto-qnty )
                .
            end.
            else do:        /* проверяем соответствие рецепту НЕ альтернатива */
                if round( buf_fbr-line.fact-qnty / buf_fbr-recipe-gds.brutto-qnty * buf_fbr-recipe.qnty, 3 ) <> round( buf_comp_fbr-line.fact-qnty, 3 )
                then do:
                    { gbl/stopwork.i }
                  undo, return error
                  substitute("Не соответствуют рецепту количество ингридиента и количество составного товара&1в док-те пр-ва &7&1" +
                              "Рецепт: &2&1Товар: &3 &4&1Количество ингридиента:       &5&1"  +
                              "Количество составного товара: &6"
                              , {&new-line}
                              , buf_fbr-line.recipe-code
                              , buf_goods.artic
                              , buf_goods.gds-name
                              , buf_fbr-line.fact-qnty
                              , buf_comp_fbr-line.fact-qnty
                              , buf_fbr-line.doc-code
                              )

                  .
                end.
            end.
        end.
        /*---END-------- проверка количества товара в строке документа на соответствие рецепту ------------------*/
        if buf_goods.gds-type <> {&gds-office}
        then do:                                        /* услуги в проверку на вес не входят */
            if lookup ( {&weight}, buf_units.type ) > 0
            then do:                                    /* весовой товар */
                if p-unit-type = buf_units.unit-name
                or p-unit-type = ""
                then do:                    /* все ОК, весовые едизмы пока совпадают, надо проверять совпадение весов */
                    assign
                        p-unit-type = buf_units.unit-name
                    .
                /* считаем количество по всем приходам и всем списаниям для данного номера рецепта;
                    если товар не весовой, он не суммируется и весь рецепт помечается как не подлежащий контролю */
                    if buf_fbr-line.trn-type = {&write-off}
                    then do:
                        assign
                            p-sum-write-off-qnty = p-sum-write-off-qnty - buf_fbr-line.fact-qnty
                        .
                    end.
                    else do:
                        assign
                            p-sum-income-qnty = p-sum-income-qnty + buf_fbr-line.fact-qnty
                        .
                    end.
                end.
                else do:                                /* разные едизмы - сравнивать бесполезно */
                    assign
                        p-unit-type = "units-differ"
                    .
                end.
            end.        /* весовой товар */
            else do:    /* невесовой товар - сравнивать бесполезно */
                assign
                    p-unit-type = "not-weight"
                .
            end.
        end.        /* не услуга */
        if buf_fbr-line.rsrv-qnty = ?
        then do:                        /*  для вычисления учетных цен в ПН не учитываем отходы */
            run writelog in this-procedure (
                  input log-file-name
                , input 3
                , input "calc-prices: Строка отходов. В сумме не учитывается."
            ).
            next calc-prices-for-each-fbr-line.
        end.
        if buf_fbr-line.trn-type = {&write-off}
        then do:                        /* строка для списания */
            run str/fbr-gds.p (
                  INPUT parparentproc
                , input p-fbrhist-handle
                , input p-fbr-doc-recid
                , input yes /*всегда тихий режим, что бы была возможность пройти по всем строкам. и потом выдать ошибку*/
                , input recid( buf_goods )
                , input p-autofbr
                , input p-have-store
            ) no-error.                 /* делаем попытку за(пере)резервировать товар */
            if error-status :error
            then do:
                if return-value = 'not-reserved' then do:
                  run writelog in this-procedure (
                    input {&fbr-rsrv-log-file-name}
                  , input 0
                  , input substitute("Не зарезервирован товар &1 &2 &3 кол-во &4 рецепт &5",
                      buf_fbr-line.artic,
                      buf_fbr-line.prod-type,
                      buf_fbr-line.prod-code,
                      buf_fbr-line.fact-qnty,
                      buf_fbr-line.recipe-code)
                  ).
                  v-not-reserved = true.
                  next calc-prices-for-each-fbr-line.
                end.
                if error-status :get-message(1) <> ""
                or return-value <> "user-interrupt":U
                then do:
                  if true /*p-silent*/ then do:
                     run writelog in this-procedure (
                                        input {&fbr-rsrv-log-file-name}
                                      , input 0
                                      , input substitute("&1 &2 &3&4Ошибка при резервировании товара.&4Товар:     &5 &6&4В рецепте: &7&8&9"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,{&new-line}
                                                    ,buf_goods.artic
                                                    ,buf_goods.gds-name
                                                    ,p-recipe-code
                                                    ,{&new-line}
                                                    ,return-value)
                                                    ).
                     v-not-reserved = true.
                     next calc-prices-for-each-fbr-line.
                  end.
                  else do:
                    message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка при резервировании товара."
                    skip "Товар:     " buf_goods.artic "  " buf_goods.gds-name
                    skip "В рецепте: " p-recipe-code
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                    view-as alert-box error.
                end.
                end.
                undo, return error return-value.
            end.
            run writelog in this-procedure (
                  input log-file-name
                , input 0
                , input "calc-prices: =====*** fbr-rcp.p ***=== Возврат после fbr-gds ========"
            ).
            if buf_fbr-line.rsrv-qnty <> buf_fbr-line.fact-qnty
            then do:        /* проверяем, все ли зарезервировано - если не все, нет смысла дальше считать рецепт */
                { gbl/stopwork.i }
              undo, return error substitute("Не удалось зарезервировать товар. Рецепт не может быть рассчитан.&1" +
                                            "Товар:     &2 &3&1В рецепте: &4"
                                            , {&new-line}
                                            , buf_goods.artic
                                            ,buf_goods.gds-name
                                            ,p-recipe-code).

            end.
            if p-rb-is-base = yes
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input substitute( "calc-prices: Резервирование товара прошло успешно. Количество, цена и сумма НДС в строке товара: "
                                + {&new-line} + "                           buf_fbr-line.rsrv-qnty            &1"
                                + {&new-line} + "                           buf_fbr-line.price-base           &2"
                                + {&new-line} + "                           buf_fbr-line.price-sum-vat-base   &3"
                                , string( buf_fbr-line.rsrv-qnty )
                                , string( buf_fbr-line.price-base   )
                                , string( buf_fbr-line.price-sum-vat-base   ) )
                ).
            end.        /* if p-rb-is-base = yes */
            else do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input substitute( "calc-prices: Резервирование товара прошло успешно. Количество, цена и сумма НДС в строке товара: "
                                + {&new-line} + "                           buf_fbr-line.rsrv-qnty            &1"
                                + {&new-line} + "                           buf_fbr-line.price-rubl           &2"
                                + {&new-line} + "                           buf_fbr-line.price-sum-vat-rubl   &3"
                                , string( buf_fbr-line.rsrv-qnty )
                                , string( buf_fbr-line.price-rubl   )
                                , string( buf_fbr-line.price-sum-vat-rubl   ) )
                ).
            end.        /* NOT ( if p-rb-is-base = yes ) */
            if buf_fbr-line.fact-qnty <> 0  /* сумма списания в учетных ценах - только по зарезервированному */
            then do:                        /* 0 м/б при альтернативе */
                assign
                    p-sum-write-off-price-r-b       = p-sum-write-off-price-r-b
                                                    + ( buf_fbr-line.rsrv-qnty * ( if p-rb-is-base = yes then buf_fbr-line.price-base else buf_fbr-line.price-rubl ) )
                    p-sum-write-off-price-not-r-b   = p-sum-write-off-price-not-r-b
                                                    + ( buf_fbr-line.rsrv-qnty * ( if p-rb-is-base = yes then buf_fbr-line.price-rubl else buf_fbr-line.price-base ) )
                    p-sum-vat-write-off-price-r-b   = p-sum-vat-write-off-price-r-b
                                                    + ( if p-rb-is-base = yes then buf_fbr-line.price-sum-vat-base else buf_fbr-line.price-sum-vat-rubl )
                    p-sum-vat-write-off-price-notrb = p-sum-vat-write-off-price-notrb
                                                    + ( if p-rb-is-base = yes then buf_fbr-line.price-sum-vat-rubl else buf_fbr-line.price-sum-vat-base )
                    p-count-rsrv-qnty = p-count-rsrv-qnty + 1
                .
                run writelog in this-procedure (
                    input log-file-name
                    , input 3
                    , input substitute( "calc-prices: Вычислены суммы списания: "
                            + {&new-line} + "                           p-sum-write-off-price-r-b     &1"
                            + {&new-line} + "                           p-sum-vat-write-off-price-r-b &2"
                            , string( p-sum-write-off-price-r-b )
                            , string( p-sum-vat-write-off-price-r-b  ) )
                ).
            end.
        end.                /* if buf_fbr-line.trn-type = {&write-off} */
        else do:            /* приход */
            if buf_fbr-line.fix-cost
            then do:
                assign
                    p-sum-fix-cost-price-r-b        = p-sum-fix-cost-price-r-b
                            + ( buf_fbr-line.fact-qnty * ( if p-rb-is-base = yes then buf_fbr-line.price-base else buf_fbr-line.price-rubl ) )
                    p-sum-vat-fix-cost-price-r-b    = p-sum-vat-fix-cost-price-r-b
                            + ( if p-rb-is-base = yes then buf_fbr-line.price-sum-vat-base else buf_fbr-line.price-sum-vat-rubl )
                    v-count-fix-cost                = v-count-fix-cost + 1
                .
            end.
            else do:
                assign      /* сумма прихода в продажных ценах - по факт количеству, т.к. резервов в ПН еще нет */
                    p-sum-input-price-sale  = p-sum-input-price-sale
                            + ( buf_fbr-line.fact-qnty * buf_fbr-line.price-sale )
                    p-count-input-fact-qnty = p-count-input-fact-qnty + 1
                .
            end.
            assign          /* запоминаем приходное количество для проверки альтернативного рецепта */
                v-alt-in-qnty = buf_fbr-line.fact-qnty
            .
            run writelog in this-procedure (
                input log-file-name
                , input 3
                , input substitute( "calc-prices: Вычислена сумма прихода в продажных ценах: "
                        + {&new-line} + "                           p-sum-input-price-sale     &1"
                        ,  string( p-sum-input-price-sale ) )
            ).
        end.
    end.        /* for each buf_fbr-line */
    
    if v-not-reserved then
      return error 'not-reserved'.
end.
end procedure. /* calc-prices */

/*==========================================================================*/
procedure check-alternative :
do
on error undo, return error
:
    define input parameter p-doc-code       as character    no-undo.
    define input parameter p-recipe-code    as character    no-undo.
    define input parameter p-artic          as character    no-undo.
    define input parameter p-prod-type      as character    no-undo.
    define input parameter p-prod-code      as integer      no-undo.
    define input parameter p-income-qnty    as decimal      no-undo.
    define input parameter p-write-off-qnty as decimal      no-undo.

    define variable v-del-zero             as logical        no-undo.

    define buffer buf_goods         for ub.goods.
    define buffer buf_zero_fbr-line for ub.fbr-line.                   /* поиск нулевых строк альтернативы */
    define buffer buf_fbr-line      for ub.fbr-line.

        find first buf_goods no-lock
             where buf_goods.artic     = p-artic
               and buf_goods.prod-type = p-prod-type
               and buf_goods.prod-code = p-prod-code
        .
        if round ( p-income-qnty, 3 ) <> round ( p-write-off-qnty, 3 )
        then do:
            { gbl/stopwork.i }
            undo, return error substitute("Док-нт пр-ва &7&1Количество оприходованного товара не равно количеству списанного.&1" +
                                          "Количество оприходованного товара: &2&1"  +
                                          "Количество списанного товара:     &3&1Товар: &4 &5&1Рецепт: &6"
                                          , {&new-line}
                                          , p-income-qnty
                                          ,p-write-off-qnty
                                          ,buf_goods.artic
                                          ,buf_goods.gds-name
                                          ,buf_fbr-recipe.recipe-code
                                          ,p-doc-code
                                          ).

        end.
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code     = p-doc-code
             and buf_fbr-line.is-comp      = no
             and buf_fbr-line.recipe-code  = p-recipe-code
             and buf_fbr-line.fact-qnty    = 0
        on error undo, return error
        :
            find first buf_goods no-lock
                 where buf_goods.artic     = buf_fbr-line.artic
                   and buf_goods.prod-type = buf_fbr-line.prod-type
                   and buf_goods.prod-code = buf_fbr-line.prod-code
            .
            if p-autofbr    = yes
            then do:
                assign
                    v-del-zero = yes
                .
            end.
            else do:
                if v-del-zero = no
                then do:
                   if p-silent then do:
                      v-del-zero = yes.
                   end.
                   else do:
                    message
                            "В сбалансированном рецепте альтернативы"
                        skip "есть строки с количеством 0."
                        skip "Необходимо либо удалить эти строки,"
                        skip "либо продолжить редактирование документа."
                        skip(1) "Рецепт: " p-recipe-code
                        skip(1) "Удалить строки с количеством 0?"
                    view-as alert-box information
                    buttons yes-no
                    title "Нулевые строки в рецепте альтернативы"
                    update v-del-zero .
                    if v-del-zero = no
                    then do:
                        undo, return error.
                    end.
                end.
            end.
            end.
            if v-del-zero = no
            then do:
                undo, return error.
            end.
            else do:
                find first buf_zero_fbr-line exclusive-lock
                     where recid( buf_zero_fbr-line ) = recid( buf_fbr-line )
                .
                delete buf_zero_fbr-line.
            end.
        end.        /* for each buf_fbr-line no-lock */
end.
end procedure. /* check-alternative */