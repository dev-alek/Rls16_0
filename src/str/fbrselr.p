block-level on error undo, throw.
/*

$Revision: 54c02665e029, 526, rls $
$Author: SShalanin $
$Date: Thu Mar 17 18:42:29 2016 +0400 $
$Workfile: fbrselr.p $
$Archive: str/fbrselr.p $

Выбор рецепта для производства товара

Автор: Белоусов Илья Александрович
Дата создания: 11/17/05
Author: Ilia Belousov
Creation date: 11/17/05

Input:

Output:

*/
define input parameter parparentproc        as handle       no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-gds-code           as integer      no-undo.
define input parameter p-trn-type           as character    no-undo.
define input parameter p-gds-qnty           as decimal      no-undo.
define input parameter p-autofbr            as logical      no-undo.  /* раскрутка для ресторана, от продажи, на кухне */
define input parameter p-have-store         as logical      no-undo.  /* при раскрутке остатки смотреть на складе кухни */
define output parameter p-out-gds-code      as integer      no-undo.
define output parameter p-out-trn-type      as character    no-undo.
define output parameter p-out-gds-qnty      as decimal      no-undo.
define output parameter p-out-recipe-type   as character    no-undo.
define output parameter p-out-recipe-code   as character    no-undo.
define output parameter p-recipe-found      as logical      no-undo.
define output parameter p-no-need-good      as logical      no-undo.

define variable vss-revision    as character no-undo init "$Revision: 54c02665e029, 526, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Thu Mar 17 18:42:29 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrselr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbrselr.p $":U .
define variable vss-description as character no-undo init "Выбор рецепта для производства товара".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ str/writelog.i def "'fbr.log'" no-create }
{ str/fbrlib.i   }

define variable v-host-code             as integer      no-undo.
define variable v-fbr-frcp              as logical    no-undo.
define variable v-type                  as character    no-undo.
define variable v-recipe-type           as character    no-undo.
define variable v-recipe-list           as character    no-undo.
define variable v-is-comp               as logical      no-undo.
define variable v-is-integration        as logical      no-undo.   /* для рецепта комплектации: yes - комплектация, no - разукомплектация */
define variable v-cancel                as logical      no-undo.
define variable v-yesno                 as logical      no-undo.
define variable v-default-recipe-code   as character    no-undo.

define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-tth             as handle     no-undo .
define variable v-param-type            as character no-undo .

define buffer buf_recipe            for recipe.
define buffer buf_goods             for goods.
define buffer buf_selected_recipe   for recipe.
define buffer buf_recipe-gds        for recipe-gds.

do
for buf_recipe
  , buf_goods
  , buf_selected_recipe
  , buf_recipe-gds
on error undo, return error
:
    run writelog in this-procedure (
          input log-file-name
        , input 0
        , input "******** select-recipe ***************************************"
    ).
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    if p-trn-type = ?
    then do:
        run writelog in this-procedure ( log-file-name, 0, "Не определен тип строки. Добавление невозможно" ).
        undo, return error.
    end.
    { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
    }
/*    run gbl/conf-rd.p (    */
/*          input "fbr-frcp" */
/*        , input v-host-code*/
/*        , input p-obj-type */
/*        , input p-obj-code */
/*        , input "":U       */
/*        , input "":U       */
/*        , input "":U       */
/*        , input no         */
/*        , output v-fbr-frcp*/
/*        , output v-type    */
/*    ) no-error.            */
    
   run adm/shattri.p ( input "get":U
                     , input  '':u
                     , input  0
                     , input  {&attr-fbrattr}
                     , input  {&attr-fbrattr_fbr-frcp}
                     , output v-value-character
                     , output v-value-date
                     , output v-value-decimal
                     , output v-value-integer
                     , output v-fbr-frcp
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .
/*                     message v-fbr-frcp view-as alert-box.*/
   if error-status :error then do:
      /* параметр может быть не задан */
      assign
         v-fbr-frcp = FALSE
      .
   end.

    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input substitute( "v-fbr-frcp = '&1'", v-fbr-frcp )
    ).
    /* сначала ищем подходящий рецепт для составного */
    assign
        p-out-recipe-type = ?
        p-out-recipe-code = ?
        v-recipe-type = ?
    .
    run fbrlib-get-obj-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-gds-code
        , output v-default-recipe-code
    ).
    
/*    run gbl/inidebug.p.*/
    comp-recipe:
        
    for each buf_recipe no-lock
       where ( buf_recipe.obj-type = p-obj-type
           and buf_recipe.obj-code = p-obj-code
           and buf_recipe.artic     = buf_goods.artic
           and buf_recipe.prod-type = buf_goods.prod-type
           and buf_recipe.prod-code = buf_goods.prod-code
          )
          or ( buf_recipe.obj-type = ""
           and buf_recipe.obj-code = 0
           and buf_recipe.artic     = buf_goods.artic
           and buf_recipe.prod-type = buf_goods.prod-type
           and buf_recipe.prod-code = buf_goods.prod-code
          )
/*    by buf_recipe.recipe-order*/
    :
        if ( p-autofbr = yes or v-fbr-frcp = yes )
        and buf_recipe.recipe-code <> v-default-recipe-code
        then do:        /* Для автоматической раскрутки и включённого параметра fbr-frcp надо брать только основной рецепт. */
            undo comp-recipe, next comp-recipe.
        end.
        run writelog in this-procedure (
              input log-file-name
            , input 3
            , input substitute( "Рецепт: &1. Тип: &2 " , buf_recipe.recipe-code, buf_recipe.recipe-type )
        ).
        if p-autofbr = yes
        and buf_recipe.recipe-type <> {&manufacturing}
        and buf_recipe.recipe-type <> {&alternative}
        then do:        /* При раскрутке для ресторанов берутся только рецепты производства и альтернативы. */
            next comp-recipe.
        end.
        if p-trn-type = {&income}
        and buf_recipe.recipe-type = {&dressing}
        then do:        /* разделка для составного не может дать прихода */
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Разделка для составного не может дать прихода. Ищем следующий рецепт"
            ).
            next comp-recipe.
        end.
        if p-trn-type = {&write-off}
        and buf_recipe.recipe-type <> {&dressing}
        and buf_recipe.recipe-type <> {&gathering}
        then do:        /* только разделка или разукомплектация для составного может дать списание */
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Только разделка или разукомплектация для составного может дать списание. Ищем следующий рецепт"
            ).
            next comp-recipe.
        end.
        if v-recipe-type = ?
        then do:        /* найден первый подходящий рецепт для составного */
            assign
                p-out-recipe-type = buf_recipe.recipe-type
                p-out-recipe-code = buf_recipe.recipe-code
                v-recipe-type = "recipe"
                v-is-integration = yes
            .
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Найден первый подходящий рецепт для составного"
            ).
            if v-fbr-frcp = yes
            then do:
                run writelog in this-procedure (
                    input log-file-name
                    , input 4
                    , input "Включен параметр v-fbr-frcp. Больше рецепт не ищем"
                ).
                leave comp-recipe.
            end.
            if p-autofbr = yes
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 4
                    , input "Раскрутка для ресторана. Больше рецепт не ищем"
                ).
                leave comp-recipe.
            end.
        end.
        else do:        /* найден еще один подходящий */
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Найден еще один подходящий рецепт"
            ).
            assign
                v-yesno = ?
                p-no-need-good = yes
            .
            do while v-yesno = ?
            and p-no-need-good = yes
            :
                run ref/rcp-all.w (
                      input parparentproc
                    , input "b-sel"
                    , input {&all}
                    , input recid( buf_goods )
                    , input p-obj-type
                    , input p-obj-code
                    , output v-recipe-list

                ) no-error.
                if error-status :error
                or v-recipe-list = ""
                then do:
                    message
                        "Отменить добавление товара?"
                        skip(1)
                        skip "Товар:" buf_goods.artic buf_goods.gds-name
                        skip(1)
                        skip "Yes - отменить добавление текущего товара"
                        skip "No  - отменить добавление товаров"
                        skip "Cancel - вернуться к выбору рецептов"
                    view-as alert-box question
                    buttons yes-no-cancel
                    title "Отмена"
                    update v-yesno
                    .
                end.
                else do:
                    assign
                        p-no-need-good = no
                    .
                end.
            end.        /* do while v-yesno = ? */
            if p-no-need-good = yes
            then do:
                if v-yesno = no
                then do:
                    undo, return error .
                end.
                else do:
                    return.
                end.
            end.        /* p-no-need-good = yes */
            find first buf_selected_recipe no-lock
                 where recid( buf_selected_recipe ) = integer( entry( 1, v-recipe-list ) )
            no-error.
            if not available buf_selected_recipe
            then do:
                assign
                    p-out-recipe-type = ?
                    p-out-recipe-code = ?
                    v-is-integration  = ?
                .
            end.
            else do:
                assign
                    p-out-recipe-type   = buf_selected_recipe.recipe-type
                    p-out-recipe-code   = buf_selected_recipe.recipe-code
                    v-recipe-type       = "recipe"
                    v-is-integration    = yes
                .
                leave comp-recipe.
            end.
        end.
    end.
    if v-recipe-type = ?
    and p-autofbr = no      /* Для ресторана разделку или разукомплектацию не ищем */
    then do:        /* составной не найден - ищем вхождения в рецепт */
        run writelog in this-procedure (
              input log-file-name
            , input 3
            , input "Поиск товара среди ингредиентов рецептов."
        ).
        search-recipe-gds:
        for each buf_recipe-gds
           where buf_recipe-gds.artic       = buf_goods.artic
             and buf_recipe-gds.prod-type   = buf_goods.prod-type
             and buf_recipe-gds.prod-code   = buf_goods.prod-code
        :
            find first buf_recipe no-lock
                 where buf_recipe.recipe-code = buf_recipe-gds.recipe-code
            .
            if AVAILABLE buf_recipe then do:
            run writelog in this-procedure (
                  input log-file-name
                , input 3
                , input substitute( "Рецепт: &1. Тип: &2 " , buf_recipe.recipe-code, buf_recipe.recipe-type )
            ).
            if p-trn-type = {&income}
            and buf_recipe.recipe-type <> {&dressing}
            and buf_recipe.recipe-type <> {&gathering}
            then do:        /* только разделка или разукомплектация для ингредиента может дать приход */
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input "Тип не подходит. Только разделка или разукомплектация для ингредиента может дать приход"
                ).
                next search-recipe-gds.
            end.
            if p-trn-type = {&write-off}
            and buf_recipe.recipe-type = {&dressing}
            then do:        /* разделка для ингредиента не может дать списания */
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input "Тип не подходит. Разделка для ингредиента не может дать списания"
                ).
                next search-recipe-gds.
            end.
            if v-recipe-type = ?
            then do:        /* найден первый подходящий рецепт для ингредиента */
                assign
                    p-out-recipe-type   = buf_recipe.recipe-type
                    p-out-recipe-code   = buf_recipe.recipe-code
                    v-recipe-type       = "recipe-gds"
                    v-is-integration    = no
                .
                if v-fbr-frcp = yes
                then do:
                    leave search-recipe-gds.
                end.
            end.
            else do:        /* найден еще один подходящий */
                assign
                    p-out-recipe-type = ?
                    p-out-recipe-code = p-out-recipe-code + {&comma-char} + buf_recipe.recipe-code
                    v-is-integration  = ?
                .
            end.
          end.
    end.
    end.
    if p-out-recipe-type = ?
    and p-out-recipe-code = ?
    then do:
        assign
            p-recipe-found = no
        .
    end.        /* p-out-recipe-code = ? */
    else do:    /* Рецепт найден. Определяем количества. */
        if p-out-recipe-type = ?
        then do:        /* fbr-frcp = no и есть несколько рецептов */
            define variable v-recipe-recid-list as character     no-undo.
            run str/rcp-sel.w (
                  input parparentproc
                , input buf_goods.gds-code
                , input {&income}
                , output p-out-recipe-code
                , output v-is-integration
                , output v-cancel
            ) .
            if v-cancel = yes
            then do:        /* Отказ от выбора рецепта. Не раскручиваем товар. */
                assign
                    p-recipe-found = no
                    p-no-need-good = yes
                .
                return.
            end.
        end.
        assign
            p-recipe-found = yes
        .
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = p-out-recipe-code
        .
        find first buf_goods no-lock
             where buf_goods.artic      = buf_recipe.artic
               and buf_goods.prod-type  = buf_recipe.prod-type
               and buf_goods.prod-code  = buf_recipe.prod-code
        .
        assign
            p-out-recipe-type   = buf_recipe.recipe-type
            p-out-gds-code      = buf_goods.gds-code
        .
        run fbrlib-get-trn-type in this-procedure (
              input buf_recipe.recipe-code
            , input recid( buf_goods )
            , input v-is-integration
            , output v-is-comp
            , output p-out-trn-type
        ).
        run writelog in this-procedure (
              input log-file-name
            , input 1
            , input substitute( "Найден рецепт '&1' с is-comp = &2, товаром '&3 &4', типом &5"
                                , p-out-recipe-code
                                , v-is-comp
                                , buf_goods.artic
                                , buf_goods.gds-name
                                , p-out-trn-type )
        ).
        if p-out-gds-code <> p-gds-code
        then do:        /* товар, который надо произвести, в полученном рецепте является ингредиентом */
            run writelog in this-procedure (
                  input log-file-name
                , input 1
                , input "Необходимый товар является ингредиентом"
            ).
            find first buf_goods no-lock
                 where buf_goods.gds-code = p-gds-code
            .
            find first buf_recipe-gds no-lock
                 where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
                   and buf_recipe-gds.artic       = buf_goods.artic
                   and buf_recipe-gds.prod-type   = buf_goods.prod-type
                   and buf_recipe-gds.prod-code   = buf_goods.prod-code
            .
            if buf_recipe-gds.brutto-qnty = ?
            or buf_recipe-gds.brutto-qnty = 0
            then do:
                message
                    "При раскрутке рецепта обнаружен ингредиент с количеством " buf_recipe-gds.brutto-qnty
                    skip "Продолжение расчета документа невозможно."
                    skip(1) "Код рецепта:      " buf_recipe.recipe-code
                    skip    "Товар ингредиента:" buf_recipe-gds.artic buf_goods.gds-name
                view-as alert-box error.
                undo, return error .
            end.
            assign
                p-out-gds-qnty = p-gds-qnty / buf_recipe-gds.brutto-qnty * buf_recipe.qnty
                p-out-trn-type = ( if p-trn-type = {&write-off} then {&income} else {&write-off} )
            .
            run writelog in this-procedure (
                input log-file-name
                , input 1
                , input substitute( "Количество товара: &1. Для его производства необходимо: &2 по рецепту: &3. Тип строки составного: &4."
                                    , p-gds-qnty
                                    , p-out-gds-qnty
                                    , p-out-recipe-code
                                    , p-out-trn-type )
            ).
        end.        /* p-out-gds-code <> p-gds-code */
        else do:
            assign
                p-out-gds-qnty = p-gds-qnty
                p-out-trn-type = p-trn-type
            .
            run writelog in this-procedure (
                  input log-file-name
                , input 1
                , input substitute( "Для производства товара необходимо: &1 по рецепту: &2. Тип строки: &3."
                                    , p-out-gds-qnty
                                    , p-out-recipe-code
                                    , p-out-trn-type )
            ).
        end.        /* p-out-gds-code = p-gds-code  */
    end.        /* p-out-recipe-code <> ? */
end.