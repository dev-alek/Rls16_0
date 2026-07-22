block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавление любой строки в документ производства по рецепту при заданном товаре

Автор: Белоусов Илья Александрович
Дата создания: 09/15/05
Author: Ilia Belousov
Creation date: 09/15/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle               no-undo.
define input parameter p-fbrhist-handle     as widget-handle        no-undo.
define input parameter p-goods-recid        as recid                no-undo.
define input parameter p-fbr-doc-recid      as recid                no-undo.
define input parameter p-trn-type           like fbr-line.trn-type  no-undo. /* тип строки для составного товара - можно указать для комплектации */
define input parameter p-qnty               like fbr-line.fact-qnty no-undo. /* количество товара, ? - вызывается форма */
define input parameter p-recipe-recursive   as logical              no-undo. /* вызвано из рекурсивного добавления товара */
define input parameter p-recursive-enabled  as logical              no-undo. /* рекурсивное добавление товара */
define input parameter p-fbr-obj-type       like clients.obj-type   no-undo. /* тип объекта для поиска прод цены */
define input parameter p-fbr-obj-code       like clients.obj-code   no-undo. /* код объекта для поиска прод цены */
define input parameter p-ingr-line-exists   as logical              no-undo.
define input parameter p-autofbr            as logical              no-undo.  /* раскрутка для ресторана, от продажи, на кухне */
define input parameter p-have-store         as logical              no-undo.  /* при раскрутке остатки смотреть на складе кухни */
define output parameter p-new-goods-recid   as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "добавление любой строки в документ производства по рецепту при заданном товаре".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ str/writelog.i def "'fbr.log'" }
{ gbl/getcntxt.i def }

do
on error undo, return error
:

/*define shared buffer f-doc for fbr-doc.*/

    define variable ref-list                as character                no-undo.
    define variable r-code                  like recipe.recipe-code     no-undo.    /* номер выбираемого рецепта */
    define variable r-type                  as character                no-undo.    /* вхождение товара в рецепт: "recipe" или "recipe-gds" */
    define variable v-recipe-OK             as logical  init yes        no-undo.    /* составной рецепт выбран корректно */
   define variable v-value-character as character  no-undo .
   define variable v-value-date      as date       no-undo .
   define variable v-value-decimal   as decimal    no-undo .
   define variable v-value-integer   as integer    no-undo .
   define variable v-value-logical   as logical    no-undo .
   define variable v-tth             as handle     no-undo .
   define variable v-param-type            as character no-undo .
    define variable par-type                as character                no-undo.    /* тип параметра конфигурации */
    define variable comp-qnty               like fbr-line.fact-qnty     no-undo.    /* количество составного товара */
    define variable v-recipe-list           as character                no-undo.
    define variable v-need-goods            as logical                  no-undo.
    define variable v-need-goods-list       as character                no-undo.
    define variable v-need-goods-qnty-list  as character                no-undo.
    define variable v-cancel                as logical                  no-undo.
    define variable v-goods-recid           as recid        no-undo.
    define variable v-yesno                 as logical      no-undo.
    define variable v-fbr-line-recid        as recid        no-undo.

    define buffer buf_goods             for goods.
    define buffer buf_comp_goods        for goods.
    define buffer buf_recipe            for recipe.
    define buffer buf_selected_recipe   for recipe.
    define buffer buf_recipe-gds        for recipe-gds.
    define buffer buf_fbr-doc           for fbr-doc.

    find first buf_fbr-doc no-lock
         where recid( buf_fbr-doc ) = p-fbr-doc-recid
    .
    assign
        v-goods-recid = p-goods-recid
    .
    if p-qnty <= 0
    then do:
        run writelog (log-file-name, 0, "&Line").
        run writelog (log-file-name, 0, string(vss-workfile) + ". Передано количество товара <= 0, " + string(p-qnty) + ". Нечего добавлять").
        run writelog (log-file-name, 0, "&Line").
        assign
            p-new-goods-recid = v-goods-recid
        .
        return.
    end.
    { gbl/getcntxt.i get " " p-mainmenu-handle }
    find first buf_goods no-lock
         where recid (buf_goods) = v-goods-recid
    .
    find first gds-prt no-lock
         where gds-prt.upper-code = buf_goods.prt-root
    .
    run writelog (log-file-name, 0, "&Line").
    run writelog (log-file-name, 1, string( vss-workfile )
                                    + {&space-char}                       + string(buf_goods.artic       , "X(17)")
                                    + {&space-char}                       + string(buf_goods.gds-name    , "X(30)")
                                    + {&space-char} + ". Кол-во: "        + (if p-qnty = ? then "?" else string(p-qnty))
                                    + {&space-char} + ". Тип строки: "    + (if p-trn-type = ? then "?" else string(p-trn-type))
                        ).
    /* проверяем товар */
    if buf_goods.gds-type = {&gds-office}
    then do:
        message
            "Нельзя добавить услугу."
            skip "Товар:" buf_goods.artic buf_goods.gds-name
        view-as alert-box error.
        run writelog (log-file-name, 0, "Тип товара - Услуга. Добавление невозможно").
        assign
            p-new-goods-recid = v-goods-recid
        .
        undo, return error.
    end.
    if buf_goods.stts <> 0
    then do:
        message
            "Нельзя добавить удаленный товар."
            skip "Товар:" buf_goods.artic buf_goods.gds-name
        view-as alert-box error.
        run writelog (log-file-name, 0, "Товар удален. Добавление невозможно").
        assign
            p-new-goods-recid = v-goods-recid
        .
        undo, return error.
    end.
    /* выбираем тип рецепта в зависимости от p-trn-type
    - он задан при рекурсии
        (уже известно, приход или списание требуется для раскрутки по всем рецептам)
    - неизвестен при добавлении первой строки на выбранный юзером товар
        (независимо от рекурсии)
    */
    if p-recipe-recursive
    then do:    /* работаем в рекурсии - нужно автоматически выбрать рецепт нужного типа */
        run writelog (log-file-name, 2, "Работаем в рекурсии").
        if p-trn-type = ?
        then do:
            run writelog (log-file-name, 0, "Не определен тип строки. Добавление невозможно").
            assign
                p-new-goods-recid = v-goods-recid
            .
            undo, return error.
        end.
         run adm/shattri.p ( input "get":U
                           , input  '':u
                           , input  0
                           , input  {&attr-fbrattr}
                           , input  {&attr-fbrattr_fbr-frcp}
                           , output v-value-character
                           , output v-value-date
                           , output v-value-decimal
                           , output v-value-integer
                           , output v-value-logical
                           , output v-param-type
                           , input-output table-handle v-tth
                           ) no-error .
         if error-status :error then do:
            /* параметр может быть не задан */
            assign
               v-value-logical = FALSE
            .
         end.

        /* сначала ищем подходящий рецепт для составного */
        assign
            r-code = ?
            r-type = ?
        .
        comp-recipe:
        for each buf_recipe no-lock
           where buf_recipe.artic     = buf_goods.artic
             and buf_recipe.prod-type = buf_goods.prod-type
             and buf_recipe.prod-code = buf_goods.prod-code
        :
            run writelog (log-file-name, 3, "Рецепт: " + string(buf_recipe.recipe-code) + ", Тип: " + string(buf_recipe.recipe-type)).
            if p-trn-type = {&income}
            and buf_recipe.recipe-type = {&dressing}
            then do:        /* разделка для составного не может дать прихода */
                run writelog (log-file-name, 4, "Разделка для составного не может дать прихода. Ищем следующий рецепт").
                next comp-recipe.
            end.
            if p-trn-type = {&write-off}
            and buf_recipe.recipe-type <> {&dressing}
            and buf_recipe.recipe-type <> {&gathering}
            then do:        /* только разделка или разукомплектация для составного может дать списание */
                run writelog (log-file-name, 4, "Только разделка или разукомплектация для составного может дать списание. Ищем следующий рецепт").
                next comp-recipe.
            end.
            if r-type = ?
            then do:        /* найден первый подходящий рецепт для составного */
                assign
                    r-code = buf_recipe.recipe-code
                    r-type = "recipe"
                .
                run writelog (log-file-name, 4, "Найден первый подходящий рецепт для составного").
                if v-value-logical
                or p-autofbr = yes
                then do:
                    run writelog (log-file-name, 4, "Больше рецепт не ищем: включен параметр fbr-frcp или раскрутка для ресторана.").
                    leave comp-recipe.
                end.
            end.
            else do:        /* найден еще один подходящий */
                run writelog (log-file-name, 4, "Найден еще один подходящий рецепт").
                run ref/rcp-all.w (
                      input p-mainmenu-handle
                    , input "b-sel"
                    , input {&all}
                    , input recid( buf_goods )
                    , input v-cntxt-obj-type
                    , input v-cntxt-obj-code
                    , output v-recipe-list
                ).
                find first buf_selected_recipe no-lock
                        where recid( buf_selected_recipe ) = integer( entry( 1, v-recipe-list ) )
                no-error.
                if not available buf_selected_recipe
                then do:
                    assign
                        r-code = ?
                    .
                end.
                else do:
                    assign
                        r-code = buf_selected_recipe.recipe-code
                        r-type = "recipe"
                    .
                    leave comp-recipe.
                end.
            end.
        end.
        if r-type = ?
        then do:        /* составной не найден - ищем вхождения в рецепт */
            search-recipe-gds:
            for each buf_recipe-gds
               where buf_recipe-gds.artic       = buf_goods.artic
                 and buf_recipe-gds.prod-type   = buf_goods.prod-type
                 and buf_recipe-gds.prod-code   = buf_goods.prod-code
             , first buf_recipe no-lock
               where buf_recipe.recipe-code = buf_recipe-gds.recipe-code
            :
                if p-trn-type = {&income}
                and buf_recipe.recipe-type <> {&dressing}
                and buf_recipe.recipe-type <> {&gathering}
                then do:        /* только разделка или разукомплектация для ингредиента может дать приход */
                    next search-recipe-gds.
                end.
                if p-trn-type = {&write-off}
                and buf_recipe.recipe-type = {&dressing}
                then do:        /* разделка для ингредиента не может дать списания */
                    next search-recipe-gds.
                end.
                if r-type = ?
                then do:        /* найден первый подходящий рецепт для ингредиента */
                    assign
                        r-code = buf_recipe.recipe-code
                        r-type = "recipe-gds"
                    .
                    if v-value-logical
                    then do:
                        leave search-recipe-gds.
                    end.
                end.
                else do:        /* найден еще один подходящий */
                    assign
                        r-code = ?
                    .
                end.
            end.
        end.
        if r-code = ?
        then do:
            assign
                v-recipe-OK = no
            .
            assign
                p-new-goods-recid = v-goods-recid
            .
            return.
        end.
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = r-code
        .
    end.
    else do:    /* не рекурсия - вызываем справочник для выбора рецепта, при отсутствии рецептов в нем можно ввести */
        run ref/rcp-all.w (
              input p-mainmenu-handle
            , input "b-add,b-sel"
            , input {&all}
            , input v-goods-recid
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , output v-recipe-list
        ).
        find first buf_recipe no-lock
             where recid( buf_recipe ) = integer( ref-list )
        no-error.
        if not available buf_recipe
        then do:
            assign
                v-recipe-OK = no
            .
            assign
                p-new-goods-recid = v-goods-recid
            .
            return.
        end.
        /* при ручном выборе требуется установить p-trn-type и r-type в зависимости от рецепта */
        if buf_recipe.artic = buf_goods.artic
        and buf_recipe.prod-type = buf_goods.prod-type
        and buf_recipe.prod-code = buf_goods.prod-code
        then do:
            assign
                r-type = "recipe"
            .
        end.
        else do:
            assign
                r-type = "recipe-gds"
            .
        end.
        case buf_recipe.recipe-type
        :
            when {&manufacturing}
            then do:
                if r-type = "recipe"
                then do:
                    assign
                        p-trn-type = {&income}
                    .
                end.
                else do:
                    assign
                        p-trn-type = {&write-off}
                    .
                end.
            end.
            when {&alternative}
            then do:
                if r-type = "recipe"
                then do:
                    assign
                        p-trn-type = {&income}
                    .
                end.
                else do:
                    assign
                        p-trn-type = {&write-off}
                    .
                end.
            end.
            when {&dressing}
            then do:
                if r-type = "recipe-gds"
                then do:
                    assign
                        p-trn-type = {&income}
                    .
                end.
                else do:
                    assign
                        p-trn-type = {&write-off}
                    .
                end.
            end.
            when {&gathering}
            then do:
                assign
                    v-yesno = yes
                .
                message
                    "Выберите тип операции по рецепту комплектации:"
                    skip (2) "YES - комплектация"
                    skip     "NO - разукомплектация"
                view-as alert-box question
                buttons YES-NO
                update v-yesno.
                if v-yesno
                then do:
                    if r-type = "recipe"
                    then do:
                        assign
                            p-trn-type = {&income}
                        .
                    end.
                    else do:
                        assign
                            p-trn-type = {&write-off}
                        .
                    end.
                end.
                else do:
                    if r-type = "recipe-gds"
                    then do:
                        assign
                            p-trn-type = {&income}
                        .
                    end.
                    else do:
                        assign
                            p-trn-type = {&write-off}
                        .
                    end.
                end.
            end.
        end case.
    end.
    /* в этой точке всегда available recipe */
    if r-type = "recipe-gds"
    then do:
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.artic         = buf_goods.artic
               and buf_recipe-gds.prod-type     = buf_goods.prod-type
               and buf_recipe-gds.prod-code     = buf_goods.prod-code
               and buf_recipe-gds.recipe-code   = buf_recipe.recipe-code
        .
    end.
    /* в этой точке available recipe-gds */
    /* проверяем права */
    case buf_recipe.recipe-type
    :
      when {&manufacturing}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_manufacturing_manufacturing':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          0
          0
          true
          v-yesno
        }
      end.
      when {&gathering}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_manufacturing_gathering':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          0
          0
          true
          v-yesno
        }
      end.
      when {&dressing}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_manufacturing_dressing':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          0
          0
          true
          v-yesno
        }
      end.
      when {&alternative}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_manufacturing_alternative':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          0
          0
          true
          v-yesno
        }
      end.
      when {&petrolium-manufacturing}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_manufacturing_petrolium-manufacturing':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          0
          0
          true
          v-yesno
        }
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип рецепта" buf_recipe.recipe-type skip
          "Код рецепта" buf_recipe.recipe-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    if not v-yesno
    then do:
        assign
            v-recipe-OK = no
        .
        assign
            p-new-goods-recid = v-goods-recid
        .
        return.
    end.
    do
    on error undo, return error
    on stop undo, return error
    :       /* создаем строки производства */
            /* создаем строку для конкретного рецепта */
        run str/fbr-crln.p (
              input p-mainmenu-handle
            , input p-fbr-doc-recid
            , input v-goods-recid
            , input buf_recipe.recipe-code
            , input p-trn-type
            , input (r-type = "recipe")
            , input p-recipe-recursive
            , input p-fbr-obj-type
            , input p-fbr-obj-code
            , output v-fbr-line-recid
        ).
        find first fbr-line
             where recid( fbr-line ) = v-fbr-line-recid
        .
        if p-qnty = ?
        then do:
            run str/fbr-line.w (
                  input p-fbrhist-handle
                , input {&update}
                , input fbr-line.doc-code
                , input v-fbr-line-recid
                , input ?
                , output v-cancel
            ).
        end.
        else do:
            assign
                fbr-line.fact-qnty = fbr-line.fact-qnty + p-qnty
            .
        end.
        if r-type = "recipe-gds"
        then do:        /* теперь считаем количество составного */
            find first buf_comp_goods no-lock
                 where buf_comp_goods.artic     = buf_recipe.artic
                   and buf_comp_goods.prod-type = buf_recipe.prod-type
                   and buf_comp_goods.prod-code = buf_recipe.prod-code
            .
            assign
                v-goods-recid = recid( buf_comp_goods )
            .
            if buf_recipe.recipe-type = {&alternative}
            then do:
                assign
                    comp-qnty = fbr-line.fact-qnty * buf_recipe-gds.brutto-qnty
                .
            end.
            else do:
                assign
                    comp-qnty = fbr-line.fact-qnty / buf_recipe-gds.brutto-qnty * buf_recipe.qnty
                .
            end.
            /* создаем строку для составного товара для конкретного рецепта */
            run str/fbr-crln.p (
                  input p-mainmenu-handle
                , input p-fbr-doc-recid
                , input v-goods-recid
                , input buf_recipe.recipe-code
                , input (if p-trn-type = {&write-off} then {&income} else {&write-off})
                , input yes
                , input p-recipe-recursive
                , input p-fbr-obj-type
                , input p-fbr-obj-code
                , output v-fbr-line-recid
            ).
            /* читаем составной в тот же буфер, v-fbr-line-recid - recid составного ! */
            find first fbr-line
                 where recid( fbr-line ) = v-fbr-line-recid
            .
            assign
                fbr-line.fact-qnty = /*fbr-line.fact-qnty + */comp-qnty
                    - ( if p-ingr-line-exists = yes then fbr-line.fact-qnty else 0 )
            .
        end.
        run str/fbr-qnty.p (
              input p-mainmenu-handle
            , input p-fbrhist-handle
            , input p-fbr-doc-recid
            , input recid( fbr-line )
            , input no
            , input "ingr"
            , input p-recursive-enabled
            , input p-fbr-obj-type
            , input p-fbr-obj-code
            , input no
            , input p-autofbr
            , input p-have-store
            , output v-need-goods
            , output v-need-goods-list
            , output v-need-goods-qnty-list
        ).
        assign      /* восстанавливаем на свой goods - нужно при r-type = "recipe-gds" */
            v-goods-recid = recid( buf_goods )
        .
    end.        /* создаем строки производства */
    assign
        p-new-goods-recid = v-goods-recid
    .
end.