block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет строк ингредиентов для одной строки составного товара ИЛИ НАОБОРОТ

Автор: Белоусов Илья Александрович
Дата создания: 09/15/05
Author: Ilia Belousov
Creation date: 09/15/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-fbrhist-handle         as widget-handle        no-undo.
define input parameter p-fbr-doc-recid          as recid                no-undo.
define input parameter p-fbr-line-recid         as recid                no-undo.
define input parameter msg-on                   as logical              no-undo.    /* ругаться или нет */
define input parameter p-calc-direct            as character            no-undo.    /* ingr - СЧИТАЕМ ингреДИЕНТЫ; comp - СОСТАВНОЙ */
define input parameter p-recursive              as logical              no-undo.    /* рекурсивное добавление товара */
define input parameter p-price-obj-type         like clients.obj-type   no-undo.    /* тип объекта для поиска прод цены */
define input parameter p-price-obj-code         like clients.obj-code   no-undo.    /* код объекта для поиска прод цены */
define input parameter p-new-algorithm          as logical              no-undo.    /* новый алгоритм - вместо вызова fbr-add присвоить p-need-goods = yes */
define input parameter p-autofbr                as logical              no-undo.    /* раскрутка для ресторана, от продажи, на кухне */
define input parameter p-have-store             as logical              no-undo.    /* при раскрутке остатки смотреть на складе кухни */
define output parameter p-need-goods            as logical init no      no-undo.    /* yes, если надо добавить рецепт */
define output parameter p-need-goods-list       as character init ""    no-undo.    /* список gds-code для добавления */
define output parameter p-need-goods-qnty-list  as character init ""    no-undo.    /* список количеств для добавления */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет строк ингредиентов для одной строки составного товара ИЛИ НАОБОРОТ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/partslib.i }
{ str/fbrlib.i   }
{ str/fbrrest.i  }
{ str/fbrhist.i  }
{ str/writelog.i def "'fbr.log'" no-create }
/*кто вставит сюда g e t c n t x t  - ОБОРВУ РУКИ И НОГИ!!!*/

define variable v-free-qnty             as decimal      no-undo.    /* свободное количество */
define variable v-available-qnty        as decimal      no-undo.    /* доступное количество ингредиента (свободное - уже назначенное) */
define variable v-required-qnty         as decimal      no-undo.    /* количество, которое требуется произвести */
define variable v-produced-qnty         as decimal      no-undo.    /* количество, доступное по другим рецептам */
define variable v-need-qnty             as decimal      no-undo.    /* количество, доступное по другим рецептам */
define variable v-comp-shortage         as decimal      no-undo.    /* количество по составному, которое недобрали */
define variable v-ingr-qnty             as decimal      no-undo.

define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-ioff   as logical    no-undo .
define variable v-value-qntc   as logical    no-undo .
define variable v-tth             as handle     no-undo .
define variable v-param-type            as character no-undo .

define variable v-par-type              as character    no-undo.    /* тип параметра конфигурации */
define variable v-sum-recipe-ingr       as decimal      no-undo.
define variable v-sum-ingr-fact-qnty    as decimal      no-undo.
define variable v-count-ingr-line       as integer      no-undo.
define variable v-min-ingr-fact-qnty    as decimal      no-undo.
define variable v-ingr-fact-qnty        as decimal      no-undo.
define variable v-price-sale            as decimal      no-undo.
define variable v-ingr-line-exists      as logical      no-undo.
define variable v-catering-obj-type         as character      no-undo.
define variable v-catering-obj-code         as integer        no-undo.

define buffer buf_fbr-line          for fbr-line.
define buffer buf_fbr-doc           for fbr-doc.
define buffer buf_goods             for goods.
define buffer buf_units             for units.
define buffer buf_fbr-recipe        for fbr-recipe.
define buffer buf_fbr-recipe-gds    for fbr-recipe-gds.
define buffer buf_ingr_fbr-line     for fbr-line.                    /* строка ингредиента */
define buffer buf_ingr_goods        for goods.                       /* буфер товара для ингредиента */
define buffer buf_ingr_units        for units.                       /* буфер едизма для ингредиента */

calc-ingr:
do
on stop  undo calc-ingr, return error
on error undo calc-ingr, return error
:
    find first buf_fbr-doc
         where recid( buf_fbr-doc )  = p-fbr-doc-recid
    .

    run adm/shattri.p ( input "get":U
                       , input  buf_fbr-doc.obj-type
                       , input  buf_fbr-doc.obj-code
                       , input  {&attr-fbrattr}
                       , input  {&attr-fbrattr_fbr-ioff}
                       , output v-value-character
                       , output v-value-date
                       , output v-value-decimal
                       , output v-value-integer
                       , output v-value-ioff
                       , output v-param-type
                       , input-output table-handle v-tth
                       ) no-error .
    if error-status :error then do:
      /* параметр может быть не задан */
      assign
         v-value-ioff = FALSE
      .
    end.

    run adm/shattri.p ( input "get":U
                       , input  buf_fbr-doc.obj-type
                       , input  buf_fbr-doc.obj-code
                       , input  {&attr-fbrattr}
                       , input  {&attr-fbrattr_fbr-qntc}
                       , output v-value-character
                       , output v-value-date
                       , output v-value-decimal
                       , output v-value-integer
                       , output v-value-qntc
                       , output v-param-type
                       , input-output table-handle v-tth
                       ) no-error .
    if error-status :error then do:
      /* параметр может быть не задан */
      assign
         v-value-qntc = FALSE
      .
    end.
    
    if p-have-store = no
    then do:
        assign
            v-catering-obj-type = buf_fbr-doc.obj-type
            v-catering-obj-code = buf_fbr-doc.obj-code
        .
    end.        /* if p-have-store = no */
    else do:
        run fbrrest-get-catering-object in this-procedure (
              input buf_fbr-doc.obj-code
            , output v-catering-obj-type
            , output v-catering-obj-code
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка определения склада для кухни ресторана."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.        /* NOT ( if p-have-store = no ) */
    find first buf_fbr-line     /* строка составного товара */
         where recid( buf_fbr-line ) = p-fbr-line-recid
    .
    find first buf_goods no-lock      /* of buf_fbr-line no-lock. */
         where buf_goods.artic     = buf_fbr-line.artic
           and buf_goods.prod-type = buf_fbr-line.prod-type
           and buf_goods.prod-code = buf_fbr-line.prod-code
    .
    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = buf_fbr-doc.doc-code
           and buf_fbr-recipe.recipe-code = buf_fbr-line.recipe-code
    no-error.
    if not available buf_fbr-recipe
    then do:
        message
            "Товар без рецепта. Расчет количеств по рецепту невозможен."
        view-as alert-box.
        return error.
    end.
    { str/writelog.i write 0 '&Line'}
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input vss-workfile
    ).
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input substitute( "Составной: &1. Рецепт: &2. Товар: &3 &4. Факт. кол.: &5. Зарезерв.кол.: &6"
                            , buf_fbr-line.is-comp
                            , buf_fbr-line.recipe-code
                            , buf_fbr-line.artic
                            , buf_goods.gds-name
                            , buf_fbr-line.fact-qnty
                            , buf_fbr-line.rsrv-qnty
                          )
    ).
    /*---S-------------------- Проверки для составного товара --------------------------*/
    if p-calc-direct = "ingr"
    then do:
        run writelog in this-procedure  (
            input log-file-name
            , input 2
            , input substitute( "Проверки количества составного товара = &1. тип ЕИ = &2."
                                , buf_fbr-line.fact-qnty
                                , buf_units.type
                              )
        ).
        if not ( lookup ( {&weight}, buf_units.type ) > 0        /* проверка на целое количество */
        or lookup ( {&divisional}, buf_units.type ) > 0 )
        then do:
            run writelog in this-procedure  ( log-file-name, 3,  "Невесовой товар" ).
            if buf_fbr-line.fact-qnty <> truncate( buf_fbr-line.fact-qnty, 0 )
            then do:
                run writelog in this-procedure  (log-file-name, 4,  "Фактическое количество - не целое").
                if buf_fbr-recipe.recipe-type = {&gathering}      /*Комплектация*/
                then do:
                    if buf_fbr-line.fact-qnty / buf_fbr-recipe.qnty <> trunc (buf_fbr-line.fact-qnty / buf_fbr-recipe.qnty, 0)
                    then do:
                        message
                            "Артикул:" buf_goods.artic buf_goods.gds-name
                            skip "Рецепт:" buf_fbr-recipe.recipe-code
                            skip (2)
                            skip buf_fbr-line.fact-qnty "не кратно" buf_fbr-recipe.qnty
                            skip "Заменяем на" ( truncate( buf_fbr-line.fact-qnty / buf_fbr-recipe.qnty, 0) + 1) * buf_fbr-recipe.qnty
                        view-as alert-box error.
                        assign
                            buf_fbr-line.fact-qnty      = ( truncate( buf_fbr-line.fact-qnty / buf_fbr-recipe.qnty, 0 ) + 1 ) * buf_fbr-recipe.qnty
                        .
                        run writelog in this-procedure ( log-file-name, 4,  substitute( "Заменяем количество на &1", buf_fbr-line.fact-qnty ) ).
                    end.
                end.
                else do:                              /* не комплектация */
                    run writelog in this-procedure  (log-file-name, 6,  "Не комплектация - замена на целое количество").
                    message
                        "Артикул:" buf_goods.artic buf_goods.gds-name
                        skip "Рецепт:" buf_fbr-recipe.recipe-code
                        skip (2)
                        skip buf_fbr-line.fact-qnty "не целое"
                        skip "Заменяем на" ( truncate( buf_fbr-line.fact-qnty, 0 ) + 1 )
                    view-as alert-box error.
                    assign
                        buf_fbr-line.fact-qnty = ( truncate( buf_fbr-line.fact-qnty, 0 ) + 1 )
                    .
                    run writelog in this-procedure ( log-file-name, 5,  substitute( "Заменяем количество на &1", buf_fbr-line.fact-qnty ) ).
                end.
            end.
        end.
        if not (buf_fbr-line.fact-qnty > 0)
        then do:
            run writelog in this-procedure ( log-file-name, 3, substitute( "Рецепт: &1. Товар: &1 &2. Количество: &3. Количество меньше или равно 0! "
                                                        , buf_fbr-recipe.recipe-code
                                                        , buf_goods.artic
                                                        , buf_goods.gds-name
                                                        , buf_fbr-line.fact-qnty
                                                      )
            ).
            message
                "Артикул:" buf_goods.artic buf_goods.gds-name
                skip "Рецепт:" buf_fbr-recipe.recipe-code
                skip (2)
                skip "Количество равно 0!"
            view-as alert-box error.
            return error.
        end.
    end.
    /*---E-------------------- Проверки для составного товара --------------------------*/
    /*---S----------------- Продажная цена и начальное кол-во составного товара -----------------*/
    /* считаем продажную цену для составного */
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
    assign
        v-comp-shortage = buf_fbr-line.fact-qnty.
    .
    run writelog in this-procedure (
          input log-file-name
        , input 2
        , input substitute( "Расчитана продажная цена для составного товара: &1", buf_fbr-line.price-sale )
    ).
    run writelog in this-procedure (
          input log-file-name
        , input 2
        , input substitute( "Не хватает составного товара: &1", v-comp-shortage )
    ).
    if buf_fbr-recipe.recipe-type = {&alternative}
    then do:                                          /* считаем те строки, что уже назначены по альтернативному рецепту */
        run writelog in this-procedure (
              input log-file-name
            , input 2
            , input substitute( "Рецепт: &1. Товар: &2. Тип рецепта: Альтернатива. "
                                , buf_fbr-recipe.recipe-code
                                , buf_goods.artic
                                , buf_goods.gds-name
                              )
        ).
        for each buf_ingr_fbr-line
           where buf_ingr_fbr-line.doc-code       = buf_fbr-doc.doc-code
             and buf_ingr_fbr-line.recipe-code    = buf_fbr-line.recipe-code
             and buf_ingr_fbr-line.is-comp        = no
        :
            find first buf_fbr-recipe-gds no-lock
                 where buf_fbr-recipe-gds.doc-code      = buf_ingr_fbr-line.doc-code
                   and buf_fbr-recipe-gds.recipe-code   = buf_fbr-recipe.recipe-code
                   and buf_fbr-recipe-gds.prod-type     = buf_ingr_fbr-line.prod-type
                   and buf_fbr-recipe-gds.prod-code     = buf_ingr_fbr-line.prod-code
                   and buf_fbr-recipe-gds.artic         = buf_ingr_fbr-line.artic
            .
            assign
                v-comp-shortage = v-comp-shortage - ( buf_ingr_fbr-line.fact-qnty * buf_fbr-recipe-gds.brutto-qnty ).
            .
        end.
        run writelog in this-procedure (
              input log-file-name
            , input 2
            , input substitute( "Не хватает составного товара: &1", v-comp-shortage )
        ).
        /* комментируем, чтоб сообщала, когда ингредиентов больше чем нужно
        if v-comp-shortage < 0 then
            v-comp-shortage = 0.
        */
    end.
    assign
        v-sum-recipe-ingr       = 0
        v-sum-ingr-fact-qnty    = 0
        v-count-ingr-line       = 0
        v-min-ingr-fact-qnty    = ?
    .
    /*---E----------------- Продажная цена и начальное кол-во составного товара -----------------*/
    for each buf_fbr-recipe-gds no-lock
       where buf_fbr-recipe-gds.doc-code    = buf_fbr-doc.doc-code
         and buf_fbr-recipe-gds.recipe-code = buf_fbr-recipe.recipe-code
    by buf_fbr-recipe-gds.proc-number       /* порядок обработки строк рецепта - важен для альтернативы */
    on error undo calc-ingr, return error
    :
        find first buf_ingr_goods no-lock
             where buf_ingr_goods.artic     = buf_fbr-recipe-gds.artic
               and buf_ingr_goods.prod-type = buf_fbr-recipe-gds.prod-type
               and buf_ingr_goods.prod-code = buf_fbr-recipe-gds.prod-code
        .
        find first buf_ingr_units no-lock
             where buf_ingr_units.unit-name = buf_ingr_goods.unit-base
        .
        if p-calc-direct = "ingr"
        and buf_fbr-recipe.recipe-type = {&alternative}
        and ( v-comp-shortage = 0 and v-value-ioff )
        then do:        /* Если по альтернативе товар уже набран - берем следующий */
            next.
        end.
        run writelog in this-procedure (
              input log-file-name
            , input 2
            , input substitute( "Бежим по ингредиентам. Ингредиент: &1 &2. ЕИ: &3 "
                                , buf_fbr-recipe-gds.artic
                                , buf_ingr_goods.gds-name
                                , buf_ingr_units.unit-name
                                )
        ).
        /*---S----------------- Определяем строку ингредиента ------------------------*/
            find first buf_ingr_fbr-line
                 where buf_ingr_fbr-line.doc-code     = buf_fbr-doc.doc-code
                   and buf_ingr_fbr-line.is-comp      = no
                   and buf_ingr_fbr-line.recipe-code  = buf_fbr-line.recipe-code
                   and buf_ingr_fbr-line.artic        = buf_fbr-recipe-gds.artic
                   and buf_ingr_fbr-line.prod-type    = buf_fbr-recipe-gds.prod-type
                   and buf_ingr_fbr-line.prod-code    = buf_fbr-recipe-gds.prod-code
            no-error.
            if not available buf_ingr_fbr-line
            then do:
                create buf_ingr_fbr-line.
                assign
                    buf_ingr_fbr-line.artic       = buf_fbr-recipe-gds.artic
                    buf_ingr_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                    buf_ingr_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
                    buf_ingr_fbr-line.doc-code    = buf_fbr-doc.doc-code
                    buf_ingr_fbr-line.recipe-code = buf_fbr-line.recipe-code
                    buf_ingr_fbr-line.trn-type    = ( if buf_fbr-line.trn-type    = {&income}
                                                      or buf_ingr_goods.gds-type  = {&gds-office} /* услуги могут только списываться */
                                                      then {&write-off}
                                                      else {&income}
                                                    )
                    buf_ingr_fbr-line.is-calc               = no  /* прод. цена будет браться из прайс-листа */
                    buf_ingr_fbr-line.is-comp               = no
                    buf_ingr_fbr-line.is-waste              = buf_fbr-recipe-gds.is-waste
                    buf_ingr_fbr-line.price-base            = 0
                    buf_ingr_fbr-line.price-rubl            = 0
                    buf_ingr_fbr-line.price-sum-base        = 0
                    buf_ingr_fbr-line.price-sum-rubl        = 0
                    buf_ingr_fbr-line.price-sum-vat-base    = 0
                    buf_ingr_fbr-line.price-sum-vat-rubl    = 0
                    buf_ingr_fbr-line.fact-qnty             = 0
                .
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input  substitute( "Создана строка ингредиента. Тип: &1" , buf_ingr_fbr-line.trn-type )
                ).
                assign
                    v-ingr-line-exists = no
                .
            end.
            else do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input  substitute( "Найдена строка ингредиента. Тип: &1" , buf_ingr_fbr-line.trn-type )
                ).
                assign
                    v-ingr-line-exists = yes
                .
            end.
        /*---E----------------- Определяем строку ингредиента ------------------------*/
            assign
                buf_ingr_fbr-line.calc-method           = buf_fbr-recipe-gds.calc-method
                buf_ingr_fbr-line.coeff-value           = buf_fbr-recipe-gds.coeff-value
                buf_ingr_fbr-line.coeff-waste           = buf_fbr-recipe-gds.coeff-waste
            .
        /*---S----------------------- Очищаем rsrv-qnty ------------------------------*/
            if buf_fbr-recipe-gds.is-waste            /* не учитываем отходы */
            then do:
                assign
                    buf_ingr_fbr-line.price-sale = 0
                    buf_ingr_fbr-line.rsrv-qnty = ?
                .
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input  "Отходы. Делаем цену для ингредиента = 0, зарезервированное количество = ?"
                ).
            end.
            else do:
                assign
                    buf_ingr_fbr-line.rsrv-qnty = 0
                .
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input "Делаем зарезервированное количество для ингредиента = 0"
                ).
            end.
        /*---E----------------------- Очищаем rsrv-qnty ------------------------------*/
            if p-calc-direct = "ingr"
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input "Направление расчёта - 'ingr'"
                ).
            /*---S----------------- Определяем свободное количество ------------------*/
                define variable v-gds-code  as integer       no-undo.

                { gbl/gds-code.i
                    buf_fbr-recipe-gds.artic
                    buf_fbr-recipe-gds.prod-type
                    buf_fbr-recipe-gds.prod-code
                    v-gds-code
                }
                run fbrrest-get-free-qnty in this-procedure (
                      input v-catering-obj-type
                    , input v-catering-obj-code
                    , input v-gds-code
                    , input p-autofbr
                    , output v-free-qnty
                ).
                if p-have-store = yes
                and ( v-catering-obj-type <> buf_fbr-doc.obj-type
                or v-catering-obj-code <> buf_fbr-doc.obj-code )
                then do:        /* При затаривании со склада надо учитывать не только склад, но и то, что есть на кухне */
                    define variable v-kitchen-free-qnty    as decimal      no-undo.
                    run fbrrest-get-free-qnty in this-procedure (
                          input buf_fbr-doc.obj-type
                        , input buf_fbr-doc.obj-code
                        , input v-gds-code
                        , input p-autofbr
                        , output v-kitchen-free-qnty
                    ).
                    assign
                        v-free-qnty = v-free-qnty + v-kitchen-free-qnty
                    .
                end.
                run writelog in this-procedure (
                      input log-file-name
                    , input 4
                    , input substitute( "Свободное количество: &1", v-free-qnty )
                ).
            /*---E----------------- Определяем свободное количество ------------------*/
            /*---S---------------- Cчитаем количество ингредиентов -------------------*/
                if buf_fbr-recipe.recipe-type = {&alternative}
                then do:
                    run writelog in this-procedure (
                        input log-file-name
                        , input 4
                        , input "Тип рецепта: Альтернатива"
                    ).
                /*---S------------- Для Альтернативы ------------------------------------*/
                    if v-value-ioff     /* отключено раскидывание по ингредиентам */
                    then do:
                        assign
                            v-comp-shortage = 0
                        .
                        run writelog in this-procedure (
                              input log-file-name
                            , input 5
                            , input "Отключено раскидывание по ингредиентам (параметр конфигурации fbr-ioff). Товар не набираем."
                        ).
                    end.
                    assign                      /* а что у нас тут в альтернативе с точностью, а ? */
                        v-available-qnty = v-free-qnty - buf_ingr_fbr-line.fact-qnty
                    .
                    run writelog in this-procedure (
                          input log-file-name
                        , input 5
                        , input substitute( "Количество ингредиента: &1", v-available-qnty )
                    ).
                    if v-comp-shortage > 0
                    and buf_fbr-recipe-gds.brutto-qnty > 0 /* <= 0, а также ? не допускается в рецепте, но в старых может быть */
                    and v-free-qnty > buf_ingr_fbr-line.fact-qnty /* меняем только в сторону увеличения - т.е. только по своб. кол-ву */
                    then do:
                        run writelog in this-procedure (
                              input log-file-name
                            , input 5
                            , input "Количество товара > 0 и Количество ингредиента > 0 и Свободное количество по ингредиенту > фактического кол-ва в линии"
                        ).
                        if v-available-qnty * buf_fbr-recipe-gds.brutto-qnty > v-comp-shortage
                        then do:                        /* хватает */
                            run writelog in this-procedure (
                                  input log-file-name
                                , input 6
                                , input "Товара хватает"
                            ).
                            if lookup ({&weight}, buf_ingr_units.type) > 0
                            or lookup ({&divisional}, buf_ingr_units.type) > 0
                            or truncate (v-comp-shortage / buf_fbr-recipe-gds.brutto-qnty, 0) = v-comp-shortage / buf_fbr-recipe-gds.brutto-qnty
                            then do:                 /* никаких излишков быть не может */
                                assign
                                    buf_ingr_fbr-line.fact-qnty = buf_ingr_fbr-line.fact-qnty + v-comp-shortage / buf_fbr-recipe-gds.brutto-qnty
                                .
                                run writelog in this-procedure (
                                      input log-file-name
                                    , input 7
                                    , input substitute( "Ингредиент весовой, дробный или количество укладывается в необходимое: прописываем факт ингредиента: &1"
                                                        , buf_ingr_fbr-line.fact-qnty )
                                ).
                            end.
                            else do:                   /* образовавшиеся излишки кидаем на составной - а куда еще ? */
                                assign
                                    buf_ingr_fbr-line.fact-qnty = buf_ingr_fbr-line.fact-qnty
                                                                    + truncate( v-comp-shortage / buf_fbr-recipe-gds.brutto-qnty, 0 )
                                                                    + 1
                                    buf_fbr-line.fact-qnty      = buf_fbr-line.fact-qnty
                                                                    + ( truncate( v-comp-shortage / buf_fbr-recipe-gds.brutto-qnty, 0 ) + 1 )
                                                                    * buf_fbr-recipe-gds.brutto-qnty
                                                                    - v-comp-shortage
                                .
                                run writelog in this-procedure (
                                      input log-file-name
                                    , input 7
                                    , input substitute( "Ингредиент штучный и количество не укладывается в необходимое, берем больше: &1, а остаток - на составной: &2"
                                                , buf_ingr_fbr-line.fact-qnty
                                                , buf_fbr-line.fact-qnty )
                                ).
                            end.
                            assign
                                v-comp-shortage = 0
                            .
                            run writelog in this-procedure (
                                  input log-file-name
                                , input 6
                                , input "Недобор по составному сделали = 0"
                            ).
                        end.
                        else do:
                            run writelog in this-procedure (
                                  input log-file-name
                                , input 6
                                , input "Товара не хватает"
                            ).
                            assign                     /* не хватает */
                                v-comp-shortage             = v-comp-shortage - v-available-qnty * buf_fbr-recipe-gds.brutto-qnty
                                buf_ingr_fbr-line.fact-qnty = v-free-qnty
                            .
                            run writelog in this-procedure (
                                  input log-file-name
                                , input 7
                                , input substitute( 'Недобор по составному уменьшили на: &1. Не хватает теперь: &2'
                                                    , v-available-qnty * buf_fbr-recipe-gds.brutto-qnty
                                                    , v-comp-shortage )
                            ).
                            run writelog in this-procedure (
                                input log-file-name
                                , input 7
                                , input substitute( "В строке ингредиента фактическое количество = свободному количеству: &1"
                                                    , buf_ingr_fbr-line.fact-qnty )
                            ).
                        end.
                    end.
                /*---E------------- Для Альтернативы ------------------------------------*/
                end.
                else do:                               /* любой нормальный рецепт, не альтернатива */
                /*---S-------------- НЕ Альтернатива ------------------------------------*/
                    run writelog in this-procedure (
                        input log-file-name
                        , input 4
                        , input "Тип рецепта: НЕ Альтернатива").
                                                        /* Считаем ингредиенты просто по рецепту */
                    assign
                        v-ingr-qnty = ( if buf_ingr_fbr-line.trn-type = {&income} then buf_fbr-recipe-gds.brutto-qnty else buf_fbr-recipe-gds.brutto-qnty )
                    .
                    if buf_ingr_fbr-line.fact-qnty = ?
                    or ( buf_fbr-line.fact-qnty * v-ingr-qnty / buf_fbr-recipe.qnty ) <> ?
                    then do:
                        assign                         /* Это условие требуется, чтоб не переписывалось ? уже назначенное
                                                    значение ингредиента.
                                                            Например, когда этот промежуточный ингредиент
                                                    нужен был для производства по другому рецепту, его количество было
                                                    назначено из того рецепта, а сейчас для его получения раскручиваес
                                                    разделка с вопросительными количествами по рецепту
                                                    */
                            buf_ingr_fbr-line.fact-qnty = buf_fbr-line.fact-qnty * v-ingr-qnty / buf_fbr-recipe.qnty
                        .
                        run writelog in this-procedure (
                            input log-file-name
                            , input 5
                            , input substitute( "Вычисляем фактическое кол-во ингредиента из кол-ва составного по рецепту: &1"
                                                , buf_ingr_fbr-line.fact-qnty )
                        ).
                    end.
                /*---E-------------- НЕ Альтернатива ------------------------------------*/
                end.
            /*---E---------------- Cчитаем количество ингредиентов -------------------*/
            /*---S------ Проверяем, чтобы штучных ингредиентов нельзя было списать (получить) нецелое количество ---*/
                /*  */
                if not (lookup ({&weight}, buf_ingr_units.type) > 0
                        or lookup ({&divisional}, buf_ingr_units.type) > 0)
                and buf_ingr_fbr-line.fact-qnty <> trunc (buf_ingr_fbr-line.fact-qnty, 0)
                then do:
                    message          "Артикул:" buf_ingr_goods.artic buf_ingr_goods.gds-name
                            skip     "Рецепт:" buf_ingr_fbr-line.recipe-code
                            skip (2) "Количество:" buf_ingr_fbr-line.fact-qnty "- не целое, как требуется для штучного товара."
                    view-as alert-box error.
                    run writelog in this-procedure (
                          input log-file-name
                        , input 4
                        , input substitute( "Получили не целое кол-во для ингредиента: &1", buf_ingr_fbr-line.fact-qnty )
                    ).
                    undo calc-ingr, return error.
                end.
            /*---E------ Проверяем, чтобы штучных ингредиентов нельзя было списать (получить) нецелое количество ---*/
            /*---S------ Пытаемся производить недостающие ингредиенты не для Альт, отх, усл ------------------------*/
                define variable v-goods-recid    as recid        no-undo.
                if  ( p-recursive = yes or p-new-algorithm )
                and buf_fbr-recipe.recipe-type      <> {&alternative}   /* в случае рецепта альтернатива вызов производства не пойдет (даже при наличии рецепта)*/
                and buf_ingr_fbr-line.rsrv-qnty <> ?                /* отходы не производим */
                and buf_ingr_goods.gds-type     <> {&gds-office}    /* услуги не производим */
                and buf_ingr_fbr-line.trn-type  = {&write-off}      /* не пытаемся списать промежуточные */
                then do:
                    assign
                        v-goods-recid = recid (buf_ingr_goods).
                    .
                    /*включен анализ множественных рецептов по одному товару: */
                    /*вычисляем по всем рецептам разницу между произведенным и */
                    /*израсходованным по данному товару */
                    define buffer buf_old_fbr-line      for fbr-line.

                    find first buf_old_fbr-line
                         where buf_old_fbr-line.prod-type    = buf_ingr_fbr-line.prod-type
                           and buf_old_fbr-line.prod-code    = buf_ingr_fbr-line.prod-code
                           and buf_old_fbr-line.artic        = buf_ingr_fbr-line.artic
                           and buf_old_fbr-line.doc-code     = buf_fbr-doc.doc-code
                           and buf_old_fbr-line.is-comp      = buf_ingr_fbr-line.is-comp
                           and recid( buf_old_fbr-line )    <> recid( buf_ingr_fbr-line )
                    no-error.
                    if available buf_old_fbr-line
                    then do:
                        run str/fbr-mrcp.p (
                              input buf_ingr_goods.gds-code
                            , input buf_ingr_fbr-line.doc-code
                            , output v-required-qnty
                            , output v-produced-qnty
                        ).
                    end.
                    else do :
                      assign
                        v-required-qnty = buf_ingr_fbr-line.fact-qnty
                        v-produced-qnty = 0
                      .
                    end .
                    if v-value-qntc
                    then do:
                      assign v-produced-qnty = 0 .
                    end.
                    assign
                        v-need-qnty = v-required-qnty - ( v-produced-qnty + v-free-qnty )
                    .
                     run writelog in this-procedure (
                              input log-file-name
                            , input 4
                            , input substitute( "Производим недостающее количество: &1", v-need-qnty )
                        ).
                    if v-need-qnty > 0
                    then do:
                        run writelog in this-procedure (
                              input log-file-name
                            , input 4
                            , input substitute( "Производим недостающее количество: &1", v-need-qnty )
                        ).
                        /* пытаемся произвести недостающее количество */
                        assign
                            p-need-goods            = yes
                            p-need-goods-list       = p-need-goods-list
                                                        + ( if p-need-goods-list <> "" then "," else "" )
                                                        + string( buf_ingr_goods.gds-code )
                            p-need-goods-list       = p-need-goods-list
                                                        + ( if p-need-goods-list <> "" then "," else "" )
                                                        + string( buf_fbr-line.trn-type )
                            p-need-goods-qnty-list  = p-need-goods-qnty-list
                                                        + ( if p-need-goods-qnty-list <> "" then "," else "" )
                                                        + string( v-need-qnty )
                        .
                        if p-new-algorithm = no
                        then do:
                            run writelog in this-procedure  ( log-file-name, 0, "&DLine" ).
                            run writelog in this-procedure  ( log-file-name, 0, "*** ------- Начало рекурсии --------" ).
                            run str/fbr-add.p (
                                  input p-mainmenu-handle
                                , input p-fbrhist-handle
                                , input v-goods-recid
                                , input recid( buf_fbr-doc )
                                , input buf_fbr-line.trn-type /* тип строки, которую нужно добавить: <> buf_ingr_fbr-line, т.е. = buf_fbr-line */
                                , input v-need-qnty
                                , input yes
                                , input yes
                                , input p-price-obj-type
                                , input p-price-obj-code
                                , input v-ingr-line-exists
                                , input p-autofbr
                                , input p-have-store
                                , output v-goods-recid
                            ).
                            run writelog in this-procedure  ( log-file-name, 0, "*** ------- Выход из рекурсии --------" ).
                            run writelog in this-procedure  ( log-file-name, 0, "&DLine" ).
                        end.
                    end.
                end.
            /*---E--------------------------- Пытаемся производить недостающие ингредиенты -------------------------*/
            end.        /* if p-calc-direct = "ingr" */
            else do:        /* При направлении расчета comp */
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input substitute( "Направление расчёта: &1", p-calc-direct )
                ).
                if buf_fbr-recipe.recipe-type = {&alternative}  /* расчет количества составного товара от ингредиентов */
                then do:                                /* СЧИТАЕМ СОСТАВНОЙ - сумма ингредиентов */
                    if buf_ingr_fbr-line.fact-qnty <> ?
                    and buf_fbr-recipe-gds.brutto-qnty <> ?
                    then do:
                        assign
                            v-sum-recipe-ingr   = v-sum-recipe-ingr + ( buf_ingr_fbr-line.fact-qnty * buf_fbr-recipe-gds.brutto-qnty )
                        .
                    end.
                end.
                else do:
                    if buf_fbr-recipe.recipe-type = {&dressing}
                    then do:                              /* СЧИТАЕМ СОСТАВНОЙ - сумма ингредиентов */
                        if buf_ingr_fbr-line.fact-qnty <> ?
                        then do:
                            assign
                                v-sum-ingr-fact-qnty = v-sum-ingr-fact-qnty + buf_ingr_fbr-line.fact-qnty
                            .
                        end.
                    end.
                    else do:
                        assign      /* рецепт - не альтернатива и не разделка */
                            v-count-ingr-line       = v-count-ingr-line + 1
                            v-ingr-fact-qnty        = buf_ingr_fbr-line.fact-qnty / buf_fbr-recipe-gds.brutto-qnty * buf_fbr-recipe.qnty
                            v-min-ingr-fact-qnty    = ( if v-min-ingr-fact-qnty = ?
                                                        then ? else
                                                            if v-ingr-fact-qnty = ?
                                                            then ?
                                                            else minimum( v-min-ingr-fact-qnty , v-ingr-fact-qnty ) )
                        .
                        /* просто проверять на ? нельзя, min не выдает правильного ? */
                    end.
                end.
            end.        /* if p-calc-direct <> "ingr" */
            assign      /* Восстанавливаем gds-rec */
                v-goods-recid = recid( buf_goods ).
            .
            run fbrlib-calc-prices in this-procedure (
                  input recid( buf_ingr_fbr-line )
                , input p-price-obj-type
                , input p-price-obj-code
                , output v-price-sale
            ) no-error.
            if error-status:error then do:
              undo, return error substitute("Ошибка при расчете цен по док-ту пр-ва &4&1&2&1&3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  , buf_ingr_fbr-line.doc-code
            ).
            end.
            if v-price-sale <> ?
            then do:    /* нулевую цену не ставим, чтобы можно было задать вручную */
                assign
                    buf_ingr_fbr-line.price-sale = v-price-sale
                .
                if p-price-obj-type <> buf_fbr-doc.obj-type
                or p-price-obj-code <> buf_fbr-doc.obj-code
                then do:    /* цена с другого объекта - фиксируем */
                    assign
                        buf_ingr_fbr-line.is-calc = yes
                    .
                end.
            end.        /* if v-price-sale <> ? */
            find first buf_goods where recid(buf_goods) = v-goods-recid.
    end.        /* for each buf_fbr-recipe-gds */
    /*---S------- Удаляем строки ингредиентов документа, которых уже нет в рецепте --------------*/
    for each buf_ingr_fbr-line
        where buf_ingr_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
        and buf_ingr_fbr-line.doc-code = buf_fbr-doc.doc-code
        and buf_ingr_fbr-line.is-comp = no
    on stop undo calc-ingr, return error
    on error undo calc-ingr, return error
    :
        if not can-find (buf_fbr-recipe-gds
                  where buf_fbr-recipe-gds.doc-code     = buf_fbr-recipe.doc-code
                    and buf_fbr-recipe-gds.recipe-code  = buf_fbr-recipe.recipe-code
                    and buf_fbr-recipe-gds.artic        = buf_ingr_fbr-line.artic
                    and buf_fbr-recipe-gds.prod-type    = buf_ingr_fbr-line.prod-type
                    and buf_fbr-recipe-gds.prod-code    = buf_ingr_fbr-line.prod-code)
        then delete
            buf_ingr_fbr-line
        .
    end.
    /*---E------- Удаляем строки ингредиентов документа, которых уже нет в рецепте --------------*/
    /*---S---- Проверка на недостаток товара = 0 и удаление строк с нулевым кол-вом для альтернативы -----*/
    if buf_fbr-recipe.recipe-type = {&alternative}
    and p-calc-direct = "ingr"
    then do:
        if v-comp-shortage > 0
        and p-have-store = no
        then do:
            if p-autofbr = no
            then do:
                message
                            "Не удалось произвести необходимое количество: " buf_fbr-line.fact-qnty " " buf_goods.unit-base
                    skip    "Разница по количеству: " v-comp-shortage buf_goods.unit-base

                    skip    "Количество составного товара не будет соответствовать сумме по ингредиентам."
                    skip    "Его можно пересчитать после формирования строк документа (кнопка Составной)."
                    skip(2) "Товар:                 " buf_goods.artic buf_goods.gds-name
                    skip    "Рецепт альтернативы:  " buf_fbr-recipe.recipe-code
                view-as alert-box warning
                title "Ошибка при производстве по рецепту (альтернатива)"
                .
                run fbrhist-write in p-fbrhist-handle (
                      input g#userid
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , input {&fbrhist-type-change-doc-line}
                    , input 1
                    , input "str/fbr-qnty.p"
                    , input substitute( "doc-code:&1,artic:&2,msg-on:&3,calc-direct:&4,recursive:&5,price-object:&6&7,new-algorithm:&8,autofbr:&9"
                                        , buf_fbr-recipe.doc-code
                                        , buf_goods.artic
                                        , msg-on
                                        , p-calc-direct
                                        , p-recursive
                                        , p-price-obj-type
                                        , p-price-obj-code
                                        , p-new-algorithm
                                        , p-autofbr
                                        )
                             + substitute( ",have-store:&1", p-have-store )
                    , input buf_fbr-recipe.doc-code
                    , input {&manufacturing}
                    , input buf_fbr-doc.status_
                    , input buf_fbr-doc.is-free
                    , input buf_fbr-recipe.recipe-code
                    , input buf_fbr-recipe.recipe-type
                    , input buf_goods.gds-code
                    , input buf_fbr-line.trn-type
                    , input buf_fbr-line.fact-qnty
                    , input substitute( "Рецепт альтернативы. Не удалось произвести необходимое количество: &1 &2. Разница по количеству: &3."
                                        , buf_fbr-line.fact-qnty
                                        , buf_goods.unit-base
                                        , v-comp-shortage
                                    )
                    , input no
                ).
            end.
            else do:
                message
                            "Не удалось произвести необходимое количество: " buf_fbr-line.fact-qnty " " buf_goods.unit-base
                    skip    "Разница по количеству: " v-comp-shortage buf_goods.unit-base
                    skip    "Количество составного товара не будет соответствовать сумме по ингредиентам."
                    skip(2)
                    skip    "Объект:                " buf_fbr-doc.obj-type buf_fbr-doc.obj-code
                    skip    "Товар:                 " buf_goods.artic buf_goods.gds-name
                    skip    "Рецепт альтернативы:  " buf_fbr-recipe.recipe-code
                view-as alert-box error
                title "Ошибка при производстве по рецепту (альтернатива)"
                .
                run fbrhist-write in p-fbrhist-handle (
                      input g#userid
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , input {&fbrhist-type-change-doc-line}
                    , input 1
                    , input "str/fbr-qnty.p"
                    , input substitute( "doc-code:&1,artic:&2,msg-on:&3,calc-direct:&4,recursive:&5,price-object:&6&7,new-algorithm:&8,autofbr:&9"
                                        , buf_fbr-recipe.doc-code
                                        , buf_goods.artic
                                        , msg-on
                                        , p-calc-direct
                                        , p-recursive
                                        , p-price-obj-type
                                        , p-price-obj-code
                                        , p-new-algorithm
                                        , p-autofbr
                                        )
                             + substitute( ",have-store:&1", p-have-store )
                    , input buf_fbr-recipe.doc-code
                    , input {&manufacturing}
                    , input buf_fbr-doc.status_
                    , input buf_fbr-doc.is-free
                    , input buf_fbr-recipe.recipe-code
                    , input buf_fbr-recipe.recipe-type
                    , input buf_goods.gds-code
                    , input buf_fbr-line.trn-type
                    , input buf_fbr-line.fact-qnty
                    , input substitute( "Рецепт альтернативы. Не удалось произвести необходимое количество: &1 &2. Разница по количеству: &3."
                                        , buf_fbr-line.fact-qnty
                                        , buf_goods.unit-base
                                        , v-comp-shortage
                                    )
                    , input yes
                ).
                undo, return error .
            end.
        end.
        else do:
/*            if v-value-ioff */
/*            then do:*/
/*                delete-zero-or-null-rsrv:*/
/*                for each buf_ingr_fbr-line*/
/*                where buf_ingr_fbr-line.recipe-code     = buf_fbr-recipe.recipe-code*/
/*                  and buf_ingr_fbr-line.doc-code        = buf_fbr-doc.doc-code*/
/*                  and buf_ingr_fbr-line.is-comp         = no*/
/*                  and ( buf_ingr_fbr-line.fact-qnty     = 0*/
/*                        or buf_ingr_fbr-line.fact-qnty  = ? )*/
/*                on stop undo calc-ingr, return error*/
/*                on error undo calc-ingr, return error*/
/*                :*/
/*                    delete buf_ingr_fbr-line.*/
/*                end.*/
/*            end.*/
        end.
    end.
    /*---E---- Проверка на недостаток товара = 0 и удаление строк с нулевым кол-вом для альтернативы -----*/
    /*---S------- Для направления расчета comp:  нужно записать результат в строчку -------------*/
    if p-calc-direct = "comp"
    then do:
        case buf_fbr-recipe.recipe-type
        :
            when {&alternative}             /* по альтернативе - сумму ингредиентов (с коэффициентами) */
            then do:
                assign
                    buf_fbr-line.fact-qnty = v-sum-recipe-ingr
                .
            end.
            when {&dressing}                /* по разделке - сумму ингредиентов (весовых) */
            then do:
                assign
                    buf_fbr-line.fact-qnty = v-sum-ingr-fact-qnty
                .
            end.
            otherwise do:
                if v-count-ingr-line = 0    /* нет строк ингредиентов - количество составного 0 */
                then do:
                    assign
                        buf_fbr-line.fact-qnty = 0
                    .
                end.
                else do:
                    assign
                        buf_fbr-line.fact-qnty = v-min-ingr-fact-qnty
                    .
                end.
            end.
        end case.
    end.
    /*---E------- Для направления расчета comp:  нужно записать результат в строчку -------------*/
    { str/writelog.i write 0 '&Line'}
end.