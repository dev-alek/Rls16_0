/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавление товаров в документ производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Required:
    { cmp/str-glbl.i }
    { cmp/library.i  }
    { str/fbrrest.i  }
    { str/fbrlib.i   }
    { gbl/getcntxt.i def }
    { gbl/getcntxt.i get }
*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

               { str/checkGroupAttr.i }
define temp-table temp_goods-qnty no-undo
    field gds-code      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field recipe-type   as character
    field recipe-code   as character
    field trn-type      as character
    field need-qnty     as decimal
    field calculated    as logical

    index pi is primary unique gds-code recipe-code
    index cl calculated
.

PROCEDURE create-initial-temp-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-artic              as character    no-undo.
define input parameter p-prod-type          as character    no-undo.
define input parameter p-prod-code          as integer      no-undo.
define input parameter p-trn-type           as character    no-undo.
define input parameter p-recipe-type        as character    no-undo.
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-need-qnty          as decimal      no-undo.
define output parameter p-same-good             as logical      no-undo.
define output parameter p-same-good-old-qnty    as decimal      no-undo.

    define variable v-gds-code    as integer      no-undo.

    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_fbr-line              for ub.fbr-line.
    define buffer buf_recipe                for ub.fbr-recipe.
    define buffer buf_obj_recipe            for ub.recipe.
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.

    run clear-temp-tables in this-procedure.
    { gbl/gds-code.i
        p-artic
        p-prod-type
        p-prod-code
        v-gds-code
    }
    create buf_temp_goods-qnty.
    assign
        buf_temp_goods-qnty.gds-code    = v-gds-code
        buf_temp_goods-qnty.artic       = p-artic
        buf_temp_goods-qnty.prod-type   = p-prod-type
        buf_temp_goods-qnty.prod-code   = p-prod-code
        buf_temp_goods-qnty.trn-type    = p-trn-type
        buf_temp_goods-qnty.recipe-type = p-recipe-type
        buf_temp_goods-qnty.recipe-code = p-recipe-code
        buf_temp_goods-qnty.need-qnty   = p-need-qnty
        buf_temp_goods-qnty.calculated  = no
    .
    assign
        p-same-good                 = no
        p-same-good-old-qnty        = 0
    .
    find first buf_fbr-doc where buf_fbr-doc.doc-code = p-fbr-doc-doc-code exclusive-lock.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_fbr-line.is-comp  = yes
    on error undo, return error
    :
        find first buf_temp_goods-qnty      /* Добавляем товар, который уже есть в рецепте */
             where buf_temp_goods-qnty.artic        = buf_fbr-line.artic
               and buf_temp_goods-qnty.prod-type    = buf_fbr-line.prod-type
               and buf_temp_goods-qnty.prod-code    = buf_fbr-line.prod-code
/*               and buf_temp_goods-qnty.trn-type     = buf_fbr-line.trn-type*/
        no-error.
        if available buf_temp_goods-qnty
        then do:
            assign
                p-same-good                 = yes
                p-same-good-old-qnty        = buf_fbr-line.fact-qnty
                buf_temp_goods-qnty.calculated  = no
            .
        end.        /* if available buf_temp_goods-qnty */
        else do:
            define variable v-recipe-type   as character     no-undo.
            run copy-recipe-in-doc in this-procedure (
                  input p-fbr-doc-doc-code
                , input buf_fbr-line.recipe-code
                , input buf_fbr-doc.doc-date
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
            ).
            find first buf_recipe no-lock
                 where buf_recipe.doc-code      = p-fbr-doc-doc-code
                   and buf_recipe.recipe-code   = buf_fbr-line.recipe-code
            no-error.
            if available buf_recipe
            then do:
                assign
                    v-recipe-type = buf_recipe.recipe-type
                .
                if v-recipe-type = {&dressing}
                or ( v-recipe-type = {&gathering}
                    and buf_fbr-line.trn-type = {&write-off} )
                then do:
                    run fill-temp-dressing-ingr in this-procedure (
                          input buf_fbr-line.doc-code
                        , input buf_recipe.recipe-code
                    ).
                end.
            end.
            else do:
                assign
                    v-recipe-type = ?
                .
            end.
            { gbl/gds-code.i
                buf_fbr-line.artic
                buf_fbr-line.prod-type
                buf_fbr-line.prod-code
                v-gds-code
            }
            create buf_temp_goods-qnty.
            assign
                buf_temp_goods-qnty.gds-code    = v-gds-code
                buf_temp_goods-qnty.artic       = buf_fbr-line.artic
                buf_temp_goods-qnty.prod-type   = buf_fbr-line.prod-type
                buf_temp_goods-qnty.prod-code   = buf_fbr-line.prod-code
                buf_temp_goods-qnty.trn-type    = buf_fbr-line.trn-type
                buf_temp_goods-qnty.need-qnty   = buf_fbr-line.fact-qnty
                buf_temp_goods-qnty.recipe-type = v-recipe-type
                buf_temp_goods-qnty.recipe-code = buf_fbr-line.recipe-code
                buf_temp_goods-qnty.calculated  = yes
            .
        end.        /* if NOT available temp_goods-qnty */
    end.        /* for each buf_fbr-line */
end.
END PROCEDURE. /* create-initial-temp-goods */


PROCEDURE calc-not-calculated-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-mainmenu-handle        as handle           no-undo.
define input parameter p-fbrhist-handle         as widget-handle    no-undo.
define input parameter p-fbr-doc-doc-code       as character        no-undo.
define input parameter p-same-good              as logical          no-undo.
define input parameter p-same-good-old-qnty     as decimal          no-undo.
define input parameter p-always-select-recipe   as logical          no-undo.
define input parameter p-add-childs             as logical          no-undo.
define input parameter p-price-sale-obj-type    as character        no-undo.
define input parameter p-price-sale-obj-code    as integer          no-undo.
define input parameter p-autofbr                as logical          no-undo.
define input parameter p-have-store             as logical          no-undo.  /* при раскрутке остатки смотреть на складе кухни */

    define variable v-counter               as integer       no-undo.
    define variable v-recipe-type           as character     no-undo.
    define variable v-recipe-code           as character     no-undo.
    define variable v-recipe-found          as logical       no-undo.
    define variable v-gds-code              as integer       no-undo.
    define variable v-yesno                 as logical       no-undo.
    define variable v-fbr-line-recid        as recid         no-undo.
    define variable v-recipe-recid-list     as character     no-undo.
    define variable v-need-goods            as logical       no-undo.
    define variable v-need-goods-list       as character     no-undo.
    define variable v-need-goods-qnty-list  as character     no-undo.
    define variable v-have-rights           as logical       no-undo.
    define variable v-trn-type              as character     no-undo.
    define variable v-is-comp               as logical       no-undo.
    define variable v-host-code             as integer       no-undo.
    define variable v-is-manual-input       as logical       no-undo.
    define variable v-add-good              as logical       no-undo.
    define variable v-cancel                as logical       no-undo.

    define variable v-value          as character no-undo .
    define variable v-type           as character no-undo .
    define variable v-attr-value     as character no-undo .
    define variable v-attr-value-rec as character no-undo .
    define variable v-attr-type      as character no-undo .
    
    define variable v-mark-qnty      as decimal no-undo init ? .

    define buffer buf_obj_recipe            for recipe.
    define buffer buf_obj_recipe-gds        for recipe-gds.
    define buffer buf_fbr-recipe            for fbr-recipe.
    define buffer buf_fbr-recipe-gds        for fbr-recipe-gds.
    define buffer buf_goods                 for goods.
    define buffer buf_fbr-doc               for fbr-doc.
    define buffer buf_fbr-line              for fbr-line.
    define buffer buf_comp_fbr-line         for fbr-line.
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_new_temp_goods-qnty   for temp_goods-qnty.
    define buffer buf_start_temp_goods-qnty for temp_goods-qnty.
    define buffer buf_del_temp_goods-qnty   for temp_goods-qnty.
    define buffer buf_marking-lines         for ub.marking-lines .
    define buffer buf_marking               for ub.marking .
   { gbl/objsrv.i }
   define variable v-ban-recipes as logical no-undo .
   define variable v-ban-altr    as logical no-undo .
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanRecipes then v-ban-recipes = true . 
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-doc-code
    .
    run test-temp-tables in this-procedure ( "Заполнена временная таблица по товарам документа." ).
    find first buf_start_temp_goods-qnty
         where buf_start_temp_goods-qnty.calculated = no
    no-error.
    calc-not-calculated-goods:
    do while available buf_start_temp_goods-qnty
    :
        run writelog in this-procedure ( log-file-name, 2, substitute( "Расчет товара с артикулом &1", buf_start_temp_goods-qnty.artic ) ).
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_start_temp_goods-qnty.gds-code
        .
        if buf_start_temp_goods-qnty.recipe-code = ?
        then do:
            assign
                v-is-manual-input = yes
            .
        end.
        else do:
            assign
                v-is-manual-input = no
            .
        end.
        if buf_start_temp_goods-qnty.recipe-code = ?
        or p-always-select-recipe = yes
        then do:
            assign
                v-yesno     = ?
                v-add-good  = no
            .
            do while v-yesno = ?
            and v-add-good = no
            :
                run ref/rcp-all.w (
                      input p-mainmenu-handle
                    , input "b-add,b-sel"
                    , input {&all}
                    , input recid( buf_goods )
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , output v-recipe-recid-list
                ) no-error.
                if error-status :error
                or v-recipe-recid-list = ""
                then do:
                    message
                        "Отменить добавление товара?"
                        skip(1)
                        skip "Товар:" buf_goods.artic buf_goods.gds-name
                        skip(1)
                        skip "Yes - отменить добавление текущего товара"
                        skip "No  - отменить добавление всех товаров списка"
                        skip "Cancel - вернуться к выбору рецепта"
                    view-as alert-box question
                    buttons yes-no-cancel
                    title "Отмена"
                    update v-yesno
                    .
                end.
                else do:
      if v-ban-altr or v-ban-recipes then 
      do:
          /*проверка */
         for each buf_obj_recipe no-lock where recid (buf_obj_recipe) = integer(v-recipe-recid-list):
            if buf_obj_recipe.recipe-type = {&manufacturing} and v-ban-recipes then
            do:
               for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_obj_recipe.recipe-code:
                  run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                     , input  {&attr-mark-type}
                     , output v-attr-value
                     , output v-attr-type
                     ) no-error .
                  if v-attr-value <> "" and v-attr-value <> "not-type" then
                  do:
                     message "Рецепт производства " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + " содержит маркированный товар."
                        view-as alert-box.
                     return .
                  end.
               end.
            end.
            if buf_obj_recipe.recipe-type = {&alternative} and v-ban-altr then
            do:
               if not check-ban-sales-via-cd(buf_goods.gds-code) then 
               do:
                  message "Рецепт альтернатива " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + {&new-line} + "входит в группу, у которой не установлен атрибут: " + {&new-line} + "Запрет передачи на кассу."
                     view-as alert-box.
                  return .
               end.
            end.
            if buf_obj_recipe.recipe-type = {&gathering} and v-ban-recipes then
            do:
               for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_obj_recipe.recipe-code:
                  run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                     , input  {&attr-mark-type}
                     , output v-attr-value
                     , output v-attr-type
                     ) no-error .
                  if v-attr-value <> "" and v-attr-value <> "not-type" then
                  do:
                     run gds-attr-value in this-procedure  ( input  buf_obj_recipe.gds-code
                        , input  {&attr-mark-type}
                        , output v-attr-value-rec
                        , output v-attr-type
                        ) no-error .
                     if v-attr-value-rec = "" or v-attr-value-rec = "not-type" then
                     do:
                        message "Рецепт комплектации " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + " должен быть маркированным"
                           view-as alert-box.
                        return .
                     end.
                     else leave.
                  end.
               end.
            end.
         end.
      end.                         
                    assign
                        v-add-good = yes
                    .
                end.
            end.        /* do while v-yesno = ? */
            if v-add-good = no
            then do:
                if v-yesno = yes
                then do:
                    for each tt-marking-lines where tt-marking-lines.gds-code = buf_start_temp_goods-qnty.gds-code
                    :
                      for first buf_marking exclusive-lock where buf_marking.mark begins tt-marking-lines.mark :
                        assign
                          buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB
                        .
                      end .
                      delete tt-marking-lines .
                    end .
                    delete buf_start_temp_goods-qnty.
                    find first buf_start_temp_goods-qnty
                            where buf_start_temp_goods-qnty.calculated = no
                    no-error.
                    next calc-not-calculated-goods.
                end.        /* if v-yesno = yes */
                else do:
                    undo, return error .
                end.        /* if NOT( v-yesno = yes ) */
            end.        /* v-add-good = no */
            find first buf_obj_recipe no-lock
                 where recid( buf_obj_recipe ) = integer( v-recipe-recid-list )
            no-error.
            if not available buf_obj_recipe
            then do:
                if p-always-select-recipe = yes
                then do:
                    assign
                        buf_start_temp_goods-qnty.calculated = yes
                    .
                    find first buf_start_temp_goods-qnty
                         where buf_start_temp_goods-qnty.calculated = no
                    no-error.
                    next calc-not-calculated-goods.
                end.
                else do:
                    message
                        "Неверно выбран рецепт для товара."
                    view-as alert-box information.
                    undo, return error .
                end.
            end.        /* if not available buf_fbr-recipe */
            else do:
                run copy-recipe-in-doc in this-procedure (
                      input buf_fbr-doc.doc-code
                    , input buf_obj_recipe.recipe-code
                    , input buf_fbr-doc.doc-date
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                ).
                find first buf_fbr-recipe no-lock
                     where buf_fbr-recipe.doc-code    = p-fbr-doc-doc-code
                       and buf_fbr-recipe.recipe-code = buf_obj_recipe.recipe-code
                .
                assign
                    buf_start_temp_goods-qnty.recipe-code = buf_fbr-recipe.recipe-code
                    buf_start_temp_goods-qnty.recipe-type = buf_fbr-recipe.recipe-type
                .
            end.
            run writelog in this-procedure ( log-file-name, 3, substitute( "В диалоге выбран рецепт номер &1", buf_start_temp_goods-qnty.recipe-code ) ).
        end.        /* if buf_start_temp_goods-qnty.recipe-code = ? */
        else do:
            run copy-recipe-in-doc in this-procedure (
                  input p-fbr-doc-doc-code
                , input buf_start_temp_goods-qnty.recipe-code
                , input buf_fbr-doc.doc-date
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
            ).
            find first buf_fbr-recipe no-lock
                 where buf_fbr-recipe.doc-code    = p-fbr-doc-doc-code
                   and buf_fbr-recipe.recipe-code = buf_start_temp_goods-qnty.recipe-code
            .
            run writelog in this-procedure ( log-file-name, 3, substitute( "Выбран рецепт номер &1", buf_start_temp_goods-qnty.recipe-code ) ).
        end.        /* if buf_start_temp_goods-qnty.recipe-code <> ? */

        case buf_fbr-recipe.recipe-type
        :
          when {&manufacturing}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_manufacturing_manufacturing':U
              {&cntxt-object}
              buf_fbr-doc.host-code
              buf_fbr-doc.obj-type
              buf_fbr-doc.obj-code
              0
              0
              0
              false
              v-have-rights
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
              buf_fbr-doc.host-code
              buf_fbr-doc.obj-type
              buf_fbr-doc.obj-code
              0
              0
              0
              false
              v-have-rights
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
              buf_fbr-doc.host-code
              buf_fbr-doc.obj-type
              buf_fbr-doc.obj-code
              0
              0
              0
              false
              v-have-rights
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
              buf_fbr-doc.host-code
              buf_fbr-doc.obj-type
              buf_fbr-doc.obj-code
              0
              0
              0
              false
              v-have-rights
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
              buf_fbr-doc.host-code
              buf_fbr-doc.obj-type
              buf_fbr-doc.obj-code
              0
              0
              0
              false
              v-have-rights
            }
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип рецепта производства" skip
              "Тип рецепта" buf_fbr-recipe.recipe-type skip
              "Документ производства" buf_fbr-recipe.doc-code skip
              "Код рецепта" buf_fbr-recipe.recipe-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .

        if v-have-rights = no
        then do:
            message
                "Недостаточно прав для производства."
                skip(1) "Обратитесь к администратору."
                skip(1) return-value
            view-as alert-box information.
            run clear-temp-tables in this-procedure .
            undo, return error.
        end.
        find first buf_fbr-line no-lock
             where buf_fbr-line.doc-code    = p-fbr-doc-doc-code
               and buf_fbr-line.is-comp     = yes
               and buf_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
        no-error.
        if available buf_fbr-line
        then do:
            define buffer buf_change_fbr-line      for ub.fbr-line.
            run writelog in this-procedure ( log-file-name, 3, "В документе уже есть выбранный рецепт." ).
            if buf_start_temp_goods-qnty.need-qnty = ?
            and v-is-manual-input = yes
            then do:
                define variable v-old-fact-qnty  as decimal       no-undo.
                define variable v-old-price-sale as decimal       no-undo.
                assign
                    v-old-fact-qnty  = buf_fbr-line.fact-qnty
                    v-old-price-sale = buf_fbr-line.price-sale
                .
                run str/fbr-line.w (
                      input p-fbrhist-handle
                    , input buf_fbr-doc.status_
                    , input p-fbr-doc-doc-code
                    , input recid( buf_fbr-line )
                    , input ?
                    , output v-cancel
                ).
                if error-status :error
                or v-cancel = yes
                then do:
                    find first buf_change_fbr-line exclusive-lock
                         where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                           and buf_change_fbr-line.is-comp     = yes
                           and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                    .
                    message
                             vss-workfile vss-revision vss-description
                        skip "Ошибка изменения строки."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                        skip buf_change_fbr-line.fact-qnty
                    view-as alert-box error.
                    assign
                        buf_change_fbr-line.fact-qnty  = v-old-fact-qnty
                        buf_change_fbr-line.price-sale = v-old-price-sale
                    .
                    run clear-temp-tables in this-procedure.
                    return.
                end.
                if buf_fbr-line.fact-qnty <= v-old-fact-qnty
                then do:
                    define variable v-gds-name    as character    no-undo.
                    { gbl/gds-arnm.i
                        buf_fbr-line.artic
                        buf_fbr-line.prod-type
                        buf_fbr-line.prod-code
                        v-gds-name
                    }
                    message
                             "Для производства товаров документа необходимо"
                        skip "большее количество товара, чем было добавлено."
                        skip "Количество товара в документе будет восстановлено."
                        skip(1)
                        skip "Товар: " buf_fbr-line.artic v-gds-name
                        skip "Количество в строке документа производства:" v-old-fact-qnty
                        skip "Новое количество:" buf_fbr-line.fact-qnty
                    view-as alert-box information
                    title "Изменение строки документа производства".
                    find first buf_change_fbr-line exclusive-lock
                         where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                           and buf_change_fbr-line.is-comp     = yes
                           and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                    .
                    assign
                        buf_change_fbr-line.fact-qnty  = v-old-fact-qnty
                        buf_change_fbr-line.price-sale = v-old-price-sale
                    .
                    delete buf_start_temp_goods-qnty.
                end.
                else do:
                    find first buf_change_fbr-line exclusive-lock
                         where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                           and buf_change_fbr-line.is-comp     = yes
                           and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                    .
                    assign
                        buf_start_temp_goods-qnty.need-qnty  = buf_fbr-line.fact-qnty
                        buf_start_temp_goods-qnty.calculated = no
                        buf_change_fbr-line.fact-qnty     = 0
                    .
                end.
                run test-temp-tables in this-procedure ( "Товар добавлять не надо - параметр fbr-frcp=yes, но введенное в диалоге количество меньше необходимого." ).
                find first buf_start_temp_goods-qnty
                     where buf_start_temp_goods-qnty.calculated = no
                no-error.
                next calc-not-calculated-goods.
            end.        /* if buf_start_temp_goods-qnty.need-qnty = ? */
            else do:
                find first buf_change_fbr-line exclusive-lock
                     where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                       and buf_change_fbr-line.is-comp     = yes
                       and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                .
                assign
                    buf_start_temp_goods-qnty.need-qnty  = buf_start_temp_goods-qnty.need-qnty + buf_fbr-line.fact-qnty
                    buf_change_fbr-line.fact-qnty        = buf_start_temp_goods-qnty.need-qnty
                .
                if buf_start_temp_goods-qnty.recipe-code <> "":U
                then do:
                    assign
                        buf_start_temp_goods-qnty.calculated = no
                    .
                end.
            end.        /* if NOT( buf_start_temp_goods-qnty.need-qnty = ? ) */
            run writelog in this-procedure ( log-file-name, 3, substitute( "Изменена рассчитанная строка документа. Новое количество &1", buf_fbr-line.fact-qnty ) ).
        end.        /* if available buf_fbr-line */  /* Товар, который надо добавить, уже есть в документе как составной. */
        run fbrlib-get-trn-type in this-procedure (
              input buf_fbr-recipe.recipe-code
            , input recid( buf_goods )
            , input ( if buf_start_temp_goods-qnty.trn-type = ?
                      then ?                      /* В случае рецепта комплектации спросить */
                      else ( if buf_start_temp_goods-qnty.trn-type = {&income}
                             then yes             /* Если надо добавить строку прихода, то это комплектация */
                             else no ) )          /* Если надо добавить строку расхода, то это разукомплектация */
            , output v-is-comp
            , output v-trn-type
        ).
        assign
            buf_start_temp_goods-qnty.trn-type = v-trn-type
        .
        run str/fbr-crln.p (
              input p-mainmenu-handle
            , input recid( buf_fbr-doc )
            , input recid( buf_goods )
            , input buf_fbr-recipe.recipe-code
            , input v-trn-type
            , input v-is-comp
            , input yes
            , input buf_fbr-doc.obj-type
            , input buf_fbr-doc.obj-code
            , output v-fbr-line-recid
        ).
/*        assign*/
/*            line-rec = v-fbr-line-recid*/
/*        .*/
        if buf_start_temp_goods-qnty.need-qnty = ?
        then do:
            find first tt-marking-lines no-error .
            if available tt-marking-lines
            then do :
              assign v-mark-qnty = 0 .
              for first buf_fbr-line no-lock where recid(buf_fbr-line) = v-fbr-line-recid,
              first buf_goods no-lock where buf_goods.artic     = buf_fbr-line.artic
                                        and buf_goods.prod-type = buf_fbr-line.prod-type
                                        and buf_goods.prod-code = buf_fbr-line.prod-code,
              each tt-marking-lines where tt-marking-lines.gds-code = buf_goods.gds-code
              :
                assign v-mark-qnty = v-mark-qnty + tt-marking-lines.box-qnty .
              end .
            end .
            run str/fbr-line.w (
                  input p-fbrhist-handle
                , input buf_fbr-doc.status_
                , input p-fbr-doc-doc-code
                , input v-fbr-line-recid
                , input v-mark-qnty
                , output v-cancel
            ) no-error.
            if error-status :error
            or v-cancel = yes
            then do:
                find first buf_fbr-line exclusive-lock
                     where recid( buf_fbr-line ) = v-fbr-line-recid
                .
                for first buf_goods no-lock where buf_goods.artic     = buf_fbr-line.artic
                                          and buf_goods.prod-type = buf_fbr-line.prod-type
                                          and buf_goods.prod-code = buf_fbr-line.prod-code,
                each tt-marking-lines where tt-marking-lines.gds-code = buf_goods.gds-code
                :
                  for first buf_marking exclusive-lock where buf_marking.mark begins tt-marking-lines.mark :
                    assign
                      buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB
                    .
                  end .
                end .
                delete buf_fbr-line.
                run clear-temp-tables in this-procedure.
                return.
            end.
            for first buf_fbr-line no-lock where recid(buf_fbr-line) = v-fbr-line-recid,
            first buf_goods no-lock where buf_goods.artic     = buf_fbr-line.artic
                                      and buf_goods.prod-type = buf_fbr-line.prod-type
                                      and buf_goods.prod-code = buf_fbr-line.prod-code,
            each tt-marking-lines where tt-marking-lines.gds-code = buf_goods.gds-code
            :
              create buf_marking-lines .
              assign 
                buf_marking-lines.mark      = tt-marking-lines.mark
                buf_marking-lines.obj-type  = buf_fbr-doc.obj-type
                buf_marking-lines.obj-code  = buf_fbr-doc.obj-code
                buf_marking-lines.gds-code  = buf_goods.gds-code
                buf_marking-lines.in-code   = "manufacturing"
                buf_marking-lines.out-code  = buf_fbr-line.doc-code
                buf_marking-lines.part-code = buf_fbr-line.recipe-code
                buf_marking-lines.prt-code  = 0
                buf_marking-lines.doc-level = 1
              .
            end .
            find first buf_fbr-line exclusive-lock
                 where recid( buf_fbr-line ) = v-fbr-line-recid
            .
            if p-same-good = yes
            then do:
                if p-autofbr = yes
                then do:
                    assign
                        v-yesno = yes
                    .
                end.        /* if p-autofbr = yes */
                else do:
                    message
                             "Товар уже есть в документе."
                        skip "Вы можете добавить введенное количество в строку документа,"
                        skip "изменить количество в документе на введенное"
                        skip "или отменить добавление товара, оставив рецепт без изменений"
                        skip(1)
                        skip "Артикул товара:        " buf_start_temp_goods-qnty.artic
                        skip "Количество в документе:" p-same-good-old-qnty
                        skip(1)
                        skip "Добавить в строку?"
                    view-as alert-box question
                    buttons yes-no-cancel
                    title "Добавление товара"
                    update v-yesno.
                    if v-yesno = ?
                    then do:
                        assign
                            buf_start_temp_goods-qnty.need-qnty   = p-same-good-old-qnty
                            buf_start_temp_goods-qnty.calculated  = yes
                        .
                        run writelog in this-procedure ( log-file-name, 3, substitute( "Товар уже есть в документе. Расчитанная строка документа оставлена без изменений. Количество &1", buf_start_temp_goods-qnty.need-qnty ) ).
                        run test-temp-tables in this-procedure ( "Добавили товар." ).
                        find first buf_start_temp_goods-qnty
                             where buf_start_temp_goods-qnty.calculated = no
                        no-error.
                        next calc-not-calculated-goods.
                    end.        /* if v-yesno = ? */
                end.        /* NOT ( if p-autofbr = yes ) */
                assign
                    buf_start_temp_goods-qnty.calculated  = no
                .
                if v-yesno = yes
                then do:
                    assign
                        buf_fbr-line.fact-qnty = buf_fbr-line.fact-qnty + p-same-good-old-qnty
                    .
                end.
                run writelog in this-procedure ( log-file-name, 3, substitute( "Товар уже есть в документе. Количество в рассчитанной строке документа изменено на &1", buf_fbr-line.fact-qnty ) ).
            end.        /* if p-same-good = yes */
            assign
                buf_start_temp_goods-qnty.recipe-code = buf_fbr-line.recipe-code
                buf_start_temp_goods-qnty.need-qnty   = buf_fbr-line.fact-qnty
                buf_start_temp_goods-qnty.trn-type    = buf_fbr-line.trn-type
            .
        end.
        run writelog in this-procedure ( log-file-name, 2, "Идем по ингредиентам товара." ).
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = buf_fbr-recipe.doc-code
             and buf_fbr-recipe-gds.recipe-code = buf_fbr-recipe.recipe-code
        on error undo, return error
        :
            find first buf_goods no-lock
                 where buf_goods.artic      = buf_fbr-recipe-gds.artic
                   and buf_goods.prod-type  = buf_fbr-recipe-gds.prod-type
                   and buf_goods.prod-code  = buf_fbr-recipe-gds.prod-code
            .
            /*
            run fbrlib-get-trn-type in this-procedure (
                  input buf_fbr-recipe.recipe-code
                , input recid( buf_goods )
                , input ?
                , output v-is-comp
                , output v-trn-type
            ).
            */
            assign
                v-is-comp = no
                v-trn-type = ( if buf_start_temp_goods-qnty.trn-type = {&income} then {&write-off} else {&income} )
            .
            run str/fbr-crln.p (
                  input p-mainmenu-handle
                , input recid( buf_fbr-doc )
                , input recid( buf_goods )
                , input buf_fbr-recipe.recipe-code
                , input v-trn-type
                , input v-is-comp
                , input yes
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
                , output v-fbr-line-recid
            ).
            find first buf_fbr-line no-lock
                 where recid( buf_fbr-line ) = v-fbr-line-recid
            .
            run writelog in this-procedure ( log-file-name, 3, substitute( "Создана строка ингредиента с артикулом '&1'", buf_fbr-line.artic ) ).
        end.
        run writelog in this-procedure ( log-file-name, 2, substitute( "Упорядочивание рецептов. Идем по рецептам с последнего." ) ).
        run fbrlib-put-in-order-recipe in this-procedure (
            input buf_fbr-doc.doc-code
        ) no-error.
        if error-status :error
        then do:
            for each buf_del_temp_goods-qnty
            :
                delete buf_del_temp_goods-qnty.
            end.
            undo, return error.
        end.
        find last temp_recipe-order.
        calc-all-recipes:
        do while available temp_recipe-order
        :
            run writelog in this-procedure ( log-file-name, 3, substitute( "Обработка рецепта номер: &1", temp_recipe-order.recipe-code ) ).
            find first buf_comp_fbr-line exclusive-lock
                 where buf_comp_fbr-line.doc-code    = p-fbr-doc-doc-code
                   and buf_comp_fbr-line.is-comp     = yes
                   and buf_comp_fbr-line.recipe-code = temp_recipe-order.recipe-code
            .
            find first buf_temp_goods-qnty
                 where buf_temp_goods-qnty.artic        = buf_comp_fbr-line.artic
                   and buf_temp_goods-qnty.prod-type    = buf_comp_fbr-line.prod-type
                   and buf_temp_goods-qnty.prod-code    = buf_comp_fbr-line.prod-code
                   and buf_temp_goods-qnty.recipe-code  = buf_comp_fbr-line.recipe-code
            no-error.
            if not available buf_temp_goods-qnty
            or buf_temp_goods-qnty.calculated = no
            then do:
                run writelog in this-procedure ( log-file-name, 4, "Товар рецепта не рассчитан. Рассчитываем." ).
                if available buf_temp_goods-qnty
                and buf_temp_goods-qnty.need-qnty <> buf_comp_fbr-line.fact-qnty
                then do:
                    assign
                        buf_comp_fbr-line.fact-qnty = buf_temp_goods-qnty.need-qnty
                    .
                    run writelog in this-procedure ( log-file-name, 5, substitute( "Прописываем количество в строку составного товара: &1", buf_comp_fbr-line.fact-qnty  ) ).
                end.
                run str/fbr-qnty.p (
                      input p-mainmenu-handle
                    , input p-fbrhist-handle
                    , input recid( buf_fbr-doc )
                    , input recid( buf_comp_fbr-line )
                    , input no
                    , input "ingr"
                    , input no
                    , input p-price-sale-obj-type
                    , input p-price-sale-obj-code
                    , input yes
                    , input p-autofbr
                    , input p-have-store
                    , output v-need-goods
                    , output v-need-goods-list
                    , output v-need-goods-qnty-list
                ).
                if p-add-childs  = yes
                and v-need-goods = yes
                then do:
                    do v-counter = 1 to num-entries( v-need-goods-list ) / 2
                    :
                        run add-new-recipe in this-procedure (
                              input p-mainmenu-handle
                            , input buf_fbr-doc.doc-code
                            , input entry( 2 * v-counter, v-need-goods-list )                 /* trn-type  */
                            , input integer( entry( 2 * v-counter - 1 , v-need-goods-list ) ) /* gds-code  */
                            , input decimal( entry( v-counter, v-need-goods-qnty-list ) )      /* need-qnty */
                            , input p-autofbr
                            , input p-have-store
                        ).
                    end.        /* do v-counter = 1 to num-entries( v-need-goods-list ) / 2 */
                    leave calc-all-recipes.
                end.        /* if p-add-childs  = yes */
            end.        /* Рецепт еще не был рассчитан */
            find prev temp_recipe-order no-error.
        end.        /* do while available temp_recipe-order */
        assign
            buf_start_temp_goods-qnty.calculated = yes
        .
        if buf_start_temp_goods-qnty.recipe-type = {&dressing}
        or ( buf_start_temp_goods-qnty.recipe-type = {&gathering}
             and buf_start_temp_goods-qnty.trn-type = {&write-off} )
        then do:
            run fill-temp-dressing-ingr in this-procedure (
                  input buf_fbr-doc.doc-code
                , input buf_start_temp_goods-qnty.recipe-code
            ).
        end.
        run test-temp-tables in this-procedure ( "Добавили товар." ).
        find first buf_start_temp_goods-qnty
             where buf_start_temp_goods-qnty.calculated = no
        no-error.
    end.        /* do while available buf_start_temp_goods-qnty */
end.
END PROCEDURE. /* calc-not-calculated-goods */

PROCEDURE clear-temp-tables :
/*------------------------------------------------------------------------------
  Purpose:     Очистка временных таблиц
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.

    for each buf_temp_goods-qnty
    on error undo, return error
    :
        delete buf_temp_goods-qnty.
    end.        /* for each temp_goods-qnty */
    for each buf_temp_dressing-ingr
    on error undo, return error
    :
        delete buf_temp_dressing-ingr.
    end.        /* for each temp_goods-qnty */
end.
END PROCEDURE. /* clear-temp-tables */

PROCEDURE copy-recipe-in-doc :
define input parameter p-doc-code       as character             no-undo.
define input parameter p-recipe-code    as character             no-undo.
define input parameter p-obj-date       as date                  no-undo.
define input parameter p-obj-type       like ub.clients.obj-type no-undo.
define input parameter p-obj-code       like ub.clients.obj-code no-undo.

    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_recipe            for ub.recipe.
    define buffer buf_recipe-gds        for ub.recipe-gds.
do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_recipe
  , buf_recipe-gds
on error undo, return error return-value
:
find first buf_recipe no-lock
     where buf_recipe.recipe-code = p-recipe-code
.
find first buf_fbr-recipe exclusive-lock
     where buf_fbr-recipe.doc-code      = p-doc-code
       and buf_fbr-recipe.recipe-code   = p-recipe-code
no-error.
if not available buf_fbr-recipe
then do:
  create buf_fbr-recipe.
  assign
    buf_fbr-recipe.doc-code     = p-doc-code
    buf_fbr-recipe.recipe-code  = p-recipe-code
    buf_fbr-recipe.recipe-type  = buf_recipe.recipe-type
  .
  for each buf_recipe-gds exclusive-lock
     where buf_recipe-gds.recipe-code = p-recipe-code
  on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
        run fbrlib_create-fbr-recipe-gds in this-procedure (
              input p-doc-code
            , input buf_recipe-gds.recipe-code
            , input buf_recipe-gds.prod-type
            , input buf_recipe-gds.prod-code
            , input buf_recipe-gds.artic
            , input buf_recipe-gds.gds-code
            , input buf_recipe-gds.is-waste
            , input buf_recipe-gds.proc-number
            , input p-obj-date
            , input p-obj-type
            , input p-obj-code
            , input buf_recipe-gds.calc-method
            , input buf_recipe-gds.coeff-waste
            , input buf_recipe-gds.qnty
            , input buf_recipe-gds.brutto-qnty
      ) no-error.
      if error-status:error
      then do:
            return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
      end.
  end.
  buffer-copy buf_recipe to buf_fbr-recipe.
end.
end.
END PROCEDURE. /* copy-recipe-in-doc */


PROCEDURE fill-temp-dressing-ingr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:        При автоматической раскрутке производства не использовать или добавить
                параметр p-autofbr.
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.

    define variable v-free-qnty     as decimal       no-undo.

    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_c_fbr-line            for ub.fbr-line.
    define buffer buf_i_fbr-line            for ub.fbr-line.
    define buffer buf_i_other_fbr-line      for ub.fbr-line.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_recipe                for ub.fbr-recipe.
    define buffer buf_recipe-gds            for ub.fbr-recipe-gds.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.

    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-doc-code
    .
    find first buf_recipe no-lock
         where buf_recipe.doc-code    = p-doc-code
           and buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_c_fbr-line no-lock
         where buf_c_fbr-line.doc-code    = p-doc-code
           and buf_c_fbr-line.is-comp     = yes
           and buf_c_fbr-line.recipe-code = p-recipe-code
    .
    if buf_recipe.recipe-type <> {&dressing}
    and ( buf_recipe.recipe-type <> {&gathering}
         or buf_c_fbr-line.trn-type <> {&write-off} )
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Процедура fill-temp-dressing-ingr применима только к рецептам разделки и разукомплектации."
            skip return-value
        view-as alert-box error.
        undo, return error .
    end.
    for each buf_temp_dressing-ingr
    :
        delete buf_temp_dressing-ingr.
    end.        /* for each buf_temp_dressing-ingr */
    for each buf_i_fbr-line no-lock
       where buf_i_fbr-line.doc-code    = p-doc-code
         and buf_i_fbr-line.is-comp     = no
         and buf_i_fbr-line.recipe-code = p-recipe-code
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic      = buf_i_fbr-line.artic
               and buf_goods.prod-type  = buf_i_fbr-line.prod-type
               and buf_goods.prod-code  = buf_i_fbr-line.prod-code
        .
        find first buf_temp_dressing-ingr
             where buf_temp_dressing-ingr.recipe-code = p-recipe-code
               and buf_temp_dressing-ingr.gds-code    = buf_goods.gds-code
        no-error.
        if not available buf_temp_dressing-ingr
        then do:
            create buf_temp_dressing-ingr.
            assign
                buf_temp_dressing-ingr.recipe-code  = p-recipe-code
                buf_temp_dressing-ingr.gds-code     = buf_goods.gds-code
                buf_temp_dressing-ingr.used-qnty    = 0
                buf_temp_dressing-ingr.line-qnty    = 0
                buf_temp_dressing-ingr.recipe-qnty  = 0
            .
        end.
        run fbrrest-get-free-qnty in this-procedure (
              input buf_fbr-doc.obj-type
            , input buf_fbr-doc.obj-code
            , input buf_goods.gds-code
            , input no
            , output v-free-qnty
        ).
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
               and buf_recipe-gds.recipe-code = p-recipe-code
               and buf_recipe-gds.prod-type   = buf_i_fbr-line.prod-type
               and buf_recipe-gds.prod-code   = buf_i_fbr-line.prod-code
               and buf_recipe-gds.artic       = buf_i_fbr-line.artic
        .
        for each buf_i_other_fbr-line no-lock
           where buf_i_other_fbr-line.doc-code    = p-doc-code
             and buf_i_other_fbr-line.is-comp     = no
             and buf_i_other_fbr-line.recipe-code <> p-recipe-code
             and buf_i_other_fbr-line.artic       = buf_i_fbr-line.artic
             and buf_i_other_fbr-line.prod-type   = buf_i_fbr-line.prod-type
             and buf_i_other_fbr-line.prod-code   = buf_i_fbr-line.prod-code
        :
            assign
                buf_temp_dressing-ingr.line-qnty    = buf_temp_dressing-ingr.line-qnty
                                                        + buf_i_other_fbr-line.fact-qnty
            .
        end.        /* for each buf_i_other_fbr-line no-lock */
        if available buf_temp_dressing-ingr
        then do:
            assign
                buf_temp_dressing-ingr.used-qnty = buf_temp_dressing-ingr.line-qnty - v-free-qnty
            .
        end.
    end.        /* for each buf_i_fbr-line */
    for each buf_temp_dressing-ingr
       where buf_temp_dressing-ingr.recipe-code = p-recipe-code
    :
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_temp_dressing-ingr.gds-code
        .
        for each buf_i_other_fbr-line no-lock
           where buf_i_other_fbr-line.doc-code    = p-doc-code
             and buf_i_other_fbr-line.is-comp     = no
             and buf_i_other_fbr-line.recipe-code = buf_temp_dressing-ingr.recipe-code
             and buf_i_other_fbr-line.artic       = buf_goods.artic
             and buf_i_other_fbr-line.prod-type   = buf_goods.prod-type
             and buf_i_other_fbr-line.prod-code   = buf_goods.prod-code
        on error undo, return error
        :
            assign
                buf_temp_dressing-ingr.recipe-qnty = buf_temp_dressing-ingr.recipe-qnty
                                                    + buf_i_other_fbr-line.fact-qnty
            .
        end.
    end.
end.
END PROCEDURE. /* fill-temp-dressing-ingr */


PROCEDURE test-temp-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.
do
on error undo, return error
:
define input parameter p-title  as character    no-undo.

define variable v-str               as character        no-undo.

    assign
        v-str = p-title + " temp_goods-qnty:"
    .
    run writelog in this-procedure (  log-file-name, 0, v-str ).
    for each buf_temp_goods-qnty
    on error undo, return error
    :
        assign
            v-str   = string( buf_temp_goods-qnty.gds-code )
                    + "   " + ( if buf_temp_goods-qnty.recipe-type = ? then "?" else string( buf_temp_goods-qnty.recipe-type ) )
                    + "   " + ( if buf_temp_goods-qnty.recipe-code = ? then "?" else string( buf_temp_goods-qnty.recipe-code ) )
                    + "   " + ( if buf_temp_goods-qnty.trn-type = ?    then "?" else string( buf_temp_goods-qnty.trn-type ) )
                    + "   " + ( if buf_temp_goods-qnty.need-qnty = ?   then "?" else string( buf_temp_goods-qnty.need-qnty ) )
                    + "   " + string( buf_temp_goods-qnty.calculated )
        .
        run writelog in this-procedure (  log-file-name, 1, v-str ).
    end.
    assign
        v-str = "        temp_dressing-ingr:"
    .
    run writelog in this-procedure (  log-file-name, 0, v-str ).
    for each buf_temp_dressing-ingr
    on error undo, return error
    :
        assign
            v-str   = string( buf_temp_dressing-ingr.recipe-code  )
                    + "   " + string( buf_temp_dressing-ingr.gds-code )
                    + "   " + ( if buf_temp_dressing-ingr.line-qnty = ?   then "?" else string( buf_temp_dressing-ingr.line-qnty ) )
                    + "   " + ( if buf_temp_dressing-ingr.used-qnty = ?   then "?" else string( buf_temp_dressing-ingr.used-qnty ) )
                    + "   " + ( if buf_temp_dressing-ingr.recipe-qnty = ? then "?" else string( buf_temp_dressing-ingr.recipe-qnty ) )
        .
        run writelog in this-procedure (  log-file-name, 1, v-str ).
    end.        /* for each temp_dressing-ingr */
end.
END PROCEDURE. /* test-temp-tables */

PROCEDURE add-new-recipe :
/*------------------------------------------------------------------------------
  Purpose:     Добавляет товар с рецептом в таблицу temp_goods-qnty
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-doc-code           as character        no-undo.
define input parameter p-trn-type           as character        no-undo.
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-need-qnty          as decimal          no-undo.
define input parameter p-autofbr            as logical          no-undo.
define input parameter p-have-store         as logical          no-undo.  /* при раскрутке остатки смотреть на складе кухни */

    define variable v-comp-gds-code         as integer          no-undo.
    define variable v-comp-trn-type         as character        no-undo.
    define variable v-comp-need-qnty        as decimal          no-undo.
    define variable v-comp-recipe-type      as character        no-undo.
    define variable v-comp-recipe-code      as character        no-undo.
    define variable v-comp-recipe-found     as logical          no-undo.
    define variable v-ext-comp-recipe-type  as character        no-undo.
    define variable v-no-add-good           as logical          no-undo.

    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_new_temp_goods-qnty   for temp_goods-qnty.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_fbr-line              for ub.fbr-line.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    
    define variable v-value          as character no-undo .
    define variable v-type           as character no-undo .
    define variable v-attr-value     as character no-undo .
    define variable v-attr-value-rec as character no-undo .
    define variable v-attr-type      as character no-undo .

    define variable v-ban-recipes as logical no-undo .
    define variable v-ban-altr    as logical no-undo .
    { gbl/objsrv.i }
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanRecipes then v-ban-recipes = true . 
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .
   

    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-doc-code
    .
    run extend-noweight-gds-qnty in this-procedure (
          input p-gds-code
        , input p-need-qnty
        , output p-need-qnty
    ).
    run select-recipe in this-procedure (
          input p-mainmenu-handle
        , input buf_fbr-doc.obj-type
        , input buf_fbr-doc.obj-code
        , input p-gds-code
        , input p-trn-type
        , input p-need-qnty
        , input p-autofbr
        , input p-have-store
        , output v-comp-gds-code
        , output v-comp-trn-type
        , output v-comp-need-qnty
        , output v-comp-recipe-type
        , output v-comp-recipe-code
        , output v-comp-recipe-found
        , output v-no-add-good
    ) no-error.
    if not error-status :error
    and v-comp-recipe-found = yes
    and v-no-add-good       = no
    then do:
        find first buf_goods no-lock
             where buf_goods.gds-code = v-comp-gds-code
        .
        assign
            v-ext-comp-recipe-type = v-comp-recipe-type
        .
        if v-comp-recipe-type = {&gathering}
        and v-comp-trn-type   = {&write-off}
        then do:
            assign
                v-ext-comp-recipe-type = {&dressing}
            .
        end.
        case v-ext-comp-recipe-type
        :
            when {&dressing}
            then do:
                find first buf_temp_goods-qnty
                     where buf_temp_goods-qnty.gds-code    = v-comp-gds-code
                       and buf_temp_goods-qnty.recipe-code = v-comp-recipe-code
                no-error.
                if not available buf_temp_goods-qnty
                then do:
                    create buf_temp_goods-qnty.
                    assign
                        buf_temp_goods-qnty.gds-code    = v-comp-gds-code
                        buf_temp_goods-qnty.recipe-type = v-comp-recipe-type
                        buf_temp_goods-qnty.recipe-code = v-comp-recipe-code
                        buf_temp_goods-qnty.artic       = buf_goods.artic
                        buf_temp_goods-qnty.prod-type   = buf_goods.prod-type
                        buf_temp_goods-qnty.prod-code   = buf_goods.prod-code
                        buf_temp_goods-qnty.trn-type    = v-comp-trn-type
                        buf_temp_goods-qnty.need-qnty   = v-comp-need-qnty
                        buf_temp_goods-qnty.calculated  = no
                    .
                end.        /* not available buf_temp_goods-qnty */
                else do:    /* рецепт уже есть во временной таблице */
                    find first buf_goods no-lock
                         where buf_goods.gds-code = p-gds-code
                    .
                    find first buf_fbr-line no-lock
                         where buf_fbr-line.doc-code    = p-doc-code
                           and buf_fbr-line.trn-type    = p-trn-type
                           and buf_fbr-line.recipe-code = v-comp-recipe-code
                           and buf_fbr-line.artic       = buf_goods.artic
                           and buf_fbr-line.prod-type   = buf_goods.prod-type
                           and buf_fbr-line.prod-code   = buf_goods.prod-code
                    no-error.
                    if available buf_fbr-line
                    then do:    /* рецепт уже был прописан в линию документа */
                        define variable v-line-qnty             as decimal   no-undo.
                        define variable v-used-qnty             as decimal   no-undo.
                        define variable v-free-qnty             as decimal   no-undo.
                        define variable v-recipe-qnty           as decimal   no-undo.
                        define variable v-comp-fbr-line-recid   as recid     no-undo.

                        run get-temp_dressing-ingr-used-qnty in this-procedure (
                              input v-comp-recipe-code
                            , input p-gds-code
                            , output v-line-qnty
                            , output v-used-qnty
                            , output v-recipe-qnty
                        ).
                        run fbrrest-get-free-qnty in this-procedure (
                              input buf_fbr-doc.obj-type
                            , input buf_fbr-doc.obj-code
                            , input p-gds-code
                            , input p-autofbr
                            , output v-free-qnty
                        ).
                        assign
                            /*p-need-qnty = p-need-qnty + v-line-qnty - v-free-qnty */
                            p-need-qnty = p-need-qnty + v-recipe-qnty /*v-used-qnty + ( v-recipe-qnty - v-line-qnty )*/
                        .
                        run calc-comp-from-ingr in this-procedure (
                              input recid( buf_fbr-line )
                            , input p-need-qnty
                            , output v-comp-fbr-line-recid
                            , output v-comp-need-qnty
                        ) .
                    end.
                    assign
                        buf_temp_goods-qnty.need-qnty   = maximum( buf_temp_goods-qnty.need-qnty, v-comp-need-qnty )
                        buf_temp_goods-qnty.calculated  = no
                    .
                end.        /* NOT( not available buf_temp_goods-qnty ) */
            end.        /* when {&dressing} */
            otherwise do:
      if v-ban-altr or v-ban-recipes then 
      do:
          /*проверка */
          if v-ext-comp-recipe-type = {&manufacturing} and v-ban-recipes then
          do:
             for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = v-comp-recipe-code:
                run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                   , input  {&attr-mark-type}
                   , output v-attr-value
                   , output v-attr-type
                   ) no-error .
                if v-attr-value <> "" and v-attr-value <> "not-type" then
                do:
                   message "Рецепт производства " + v-comp-recipe-code + " содержит маркированный товар."
                      view-as alert-box.
                   return .
                end.
             end.
          end.
          if v-ext-comp-recipe-type = {&alternative} and v-ban-altr then
          do:
             if not check-ban-sales-via-cd(buf_goods.gds-code) then 
             do:
               message "Рецепт альтернатива " + v-comp-recipe-code + " входит в группу, у которой не установлен атрибут: " + {&new-line} + "Запрет передачи на кассу."
                 view-as alert-box.
               return .
             end.
          end.
          if v-ext-comp-recipe-type = {&gathering} and v-ban-recipes then
          do:
             for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = v-comp-recipe-code:
                run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                   , input  {&attr-mark-type}
                   , output v-attr-value
                   , output v-attr-type
                   ) no-error .
                if v-attr-value <> "" and v-attr-value <> "not-type" then
                do:
                   run gds-attr-value in this-procedure  ( input  p-gds-code
                      , input  {&attr-mark-type}
                      , output v-attr-value-rec
                      , output v-attr-type
                      ) no-error .
                   if v-attr-value-rec = "" or v-attr-value-rec = "not-type" then
                   do:
                      message "Рецепт комплектации " + v-comp-recipe-code + " должен быть маркированным"
                         view-as alert-box.
                      return .
                   end.
                   else leave.
                end.
             end.
          end.
      end.
                find first buf_temp_goods-qnty
                     where buf_temp_goods-qnty.gds-code = p-gds-code
                       and buf_temp_goods-qnty.trn-type = p-trn-type
                no-error.
                if available buf_temp_goods-qnty
                then do:        /* В документе уже есть такой товар - просто добавляем */
/*                    assign*/
/*                        buf_temp_goods-qnty.need-qnty  = ( if buf_temp_goods-qnty.calculated = no*/
/*                                                            or buf_temp_goods-qnty.recipe-type = {&alternative}*/
/*                                                            then buf_temp_goods-qnty.need-qnty*/
/*                                                            else 0 )*/
/*                                                            + p-need-qnty*/
/*                    .*/
                    assign
                        buf_temp_goods-qnty.need-qnty  = buf_temp_goods-qnty.need-qnty + p-need-qnty
                    .
                    if buf_temp_goods-qnty.recipe-code <> ""
                    then do:        /* Если добавили к товару с рецептом - его надо пересчитать */
                        assign
                            buf_temp_goods-qnty.calculated = no
                        .
                    end.        /* if buf_temp_goods-qnty.recipe-code <> "" */
                    run writelog in this-procedure ( log-file-name, 5, substitute( "Раскрутка ингредиетнов: добавляем товар '&1' к уже рассчитанному: &2", buf_temp_goods-qnty.artic, buf_temp_goods-qnty.need-qnty  ) ).
                end.        /* if available buf_temp_goods-qnty */
                else do:        /* Добавить надо или ингредиент, или товар, которого еще нет в рецепте */
/*                    assign*/
/*                        p-trn-type = ( if p-trn-type = {&income} then {&write-off} else {&income} )*/
/*                    .*/
                    find first buf_temp_goods-qnty
                         where buf_temp_goods-qnty.gds-code = v-comp-gds-code
                           and buf_temp_goods-qnty.trn-type = v-comp-trn-type
                    no-error.
                    if not available buf_temp_goods-qnty
                    then do:
                        create buf_temp_goods-qnty.
                        find first buf_goods no-lock
                             where buf_goods.gds-code = v-comp-gds-code
                        .
                        assign
                            buf_temp_goods-qnty.gds-code    = v-comp-gds-code
                            buf_temp_goods-qnty.artic       = buf_goods.artic
                            buf_temp_goods-qnty.prod-type   = buf_goods.prod-type
                            buf_temp_goods-qnty.prod-code   = buf_goods.prod-code
                            buf_temp_goods-qnty.trn-type    = v-comp-trn-type
                            buf_temp_goods-qnty.need-qnty   = v-comp-need-qnty
                            buf_temp_goods-qnty.recipe-type = v-comp-recipe-type
                            buf_temp_goods-qnty.recipe-code = v-comp-recipe-code
                            buf_temp_goods-qnty.calculated  = no
                        .
                        run writelog in this-procedure ( log-file-name, 5, "Раскрутка ингредиентов: добавляем товар как не рассчитанный." ).
                    end.        /* NOT available buf_temp_goods-qnty  */
                end.        /* if NOT available buf_temp_goods-qnty */
            end.        /* otherwise */
        end case.       /* case v-ext-comp-recipe-type */
        if available buf_temp_goods-qnty
        then do:
            run extend-noweight-gds-qnty in this-procedure (
                  input buf_temp_goods-qnty.gds-code
                , input buf_temp_goods-qnty.need-qnty
                , output buf_temp_goods-qnty.need-qnty
            ).
        end.
        find first buf_goods no-lock
             where buf_goods.gds-code = v-comp-gds-code
        .
        if v-ext-comp-recipe-type = {&dressing}
        then do:
            find first buf_fbr-line exclusive-lock
                where buf_fbr-line.doc-code    = p-doc-code
                and buf_fbr-line.trn-type    = v-comp-trn-type
                and buf_fbr-line.recipe-code = v-comp-recipe-code
                and buf_fbr-line.artic       = buf_goods.artic
                and buf_fbr-line.prod-type   = buf_goods.prod-type
                and buf_fbr-line.prod-code   = buf_goods.prod-code
            no-error.
            if available buf_fbr-line
            then do:
                assign
                    buf_fbr-line.fact-qnty = 0
                .
            end.
        end.
        else do:
            for each buf_fbr-line exclusive-lock
            where buf_fbr-line.doc-code    = p-doc-code
                and buf_fbr-line.recipe-code = v-comp-recipe-code
            on error undo, return error
            :
                delete buf_fbr-line.
            end.        /* for each buf_fbr-line */
        end.
    end.        /* if v-comp-recipe-found = yes */
end.
END PROCEDURE. /* add-new-recipe */


PROCEDURE extend-noweight-gds-qnty :
/*------------------------------------------------------------------------------
  Purpose:     Если ЕИ товара - не дробная, то вычислить целое количество для производства.
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-in-qnty    as decimal      no-undo.
define output parameter p-out-qnty  as decimal      no-undo.

    define buffer buf_goods                 for ub.goods.
    define buffer buf_units                 for ub.units.

    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base
    .
    assign
        p-out-qnty = p-in-qnty
    .
    if not ( lookup( {&weight}, buf_units.type ) > 0
             or lookup ({&divisional}, buf_units.type) > 0 )
    then do:        /* Количество товара не может быть дробным. Округляем в большую сторону. */
        if p-out-qnty <> truncate( p-out-qnty, 0 )
        then do:
            assign
                p-out-qnty = truncate( p-out-qnty, 0 ) + 1
            .
        end.
    end.
end.
END PROCEDURE. /* extend-noweight-gds-qnty */


PROCEDURE select-recipe :
/*------------------------------------------------------------------------------
  Purpose:     Найти рецепт для заданного товара и типа строки производства
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-trn-type           as character        no-undo.
define input parameter p-gds-qnty           as decimal          no-undo.
define input parameter p-autofbr            as logical          no-undo.  /* раскрутка для ресторана, от продажи, на кухне */
define input parameter p-have-store         as logical          no-undo.  /* при раскрутке остатки смотреть на складе кухни */
define output parameter p-out-gds-code      as integer          no-undo.
define output parameter p-out-trn-type      as character        no-undo.
define output parameter p-out-gds-qnty      as decimal          no-undo.
define output parameter p-out-recipe-type   as character        no-undo.
define output parameter p-out-recipe-code   as character        no-undo.
define output parameter p-recipe-found      as logical          no-undo.
define output parameter p-no-need-good      as logical          no-undo.

define variable v-host-code             as integer      no-undo.
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-tth             as handle     no-undo .
define variable v-param-type            as character no-undo .
define variable v-type                  as character    no-undo.
define variable v-recipe-type           as character    no-undo.
define variable v-recipe-list           as character    no-undo.
define variable v-is-comp               as logical      no-undo.
define variable v-is-integration        as logical      no-undo.   /* для рецепта комплектации: yes - комплектация, no - разукомплектация */
define variable v-cancel                as logical      no-undo.
define variable v-yesno                 as logical      no-undo.
define variable v-default-recipe-code   as character    no-undo.

    define buffer buf_recipe            for ub.recipe.
    define buffer buf_goods             for ub.goods.
    define buffer buf_selected_recipe   for ub.recipe.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_ingr_goods        for ub.goods.

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

    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input substitute( "fbr-frcp = '&1'", v-value-logical )
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
           and buf_recipe.stts      <> 2
          )
          or ( buf_recipe.obj-type = ""
           and buf_recipe.obj-code = 0
           and buf_recipe.artic     = buf_goods.artic
           and buf_recipe.prod-type = buf_goods.prod-type
           and buf_recipe.prod-code = buf_goods.prod-code
           and buf_recipe.stts      <> 2
          )
/*    by buf_recipe.recipe-order*/
    :
        if  ( p-autofbr = yes or v-value-logical = yes ) and buf_recipe.recipe-code <> v-default-recipe-code
        then do:
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
        and buf_recipe.recipe-type <> {&gathering}
        and buf_recipe.recipe-type <> {&gathering}
        then do:        /* При раскрутке для ресторанов берутся только рецепты производства и альтернативы и комплепкты. */
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
            if v-value-logical
            then do:
                run writelog in this-procedure (
                    input log-file-name
                    , input 4
                    , input "Включен параметр fbr-frcp. Больше рецепт не ищем"
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
                      input p-mainmenu-handle
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
                   and buf_recipe.obj-type    = p-obj-type 
                   and buf_recipe.obj-code    = p-obj-code
                 no-error
            .
            if not available buf_recipe then next search-recipe-gds.
            find buf_ingr_goods no-lock
                where buf_ingr_goods.gds-code = buf_recipe.gds-code
            .
            
            if buf_ingr_goods.stts <> 0 then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input subst("Рецепт &1 на товар &2 не подходит т.к. товар удален", buf_recipe.recipe-code, buf_ingr_goods.gds-code)
                ).
                next search-recipe-gds.
            end.
            
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
                if v-value-logical
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
                  input p-mainmenu-handle
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
END PROCEDURE. /* select-recipe */

/* $Workfile$ e n d */