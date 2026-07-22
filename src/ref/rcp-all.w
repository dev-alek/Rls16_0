/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник рецептов

Автор: Белоусов Илья Александрович
Дата создания: 09/09/05
Author: Ilia Belousov
Creation date: 09/09/05

*/
/* ***************************  definitions  ************************** */
{ gbl/objsrv.i }
/* parameters definitions ---                                           */
define input  parameter p-mainmenu-handle as handle       no-undo.
define input  parameter bttns             as character    no-undo.
define input  parameter call-mode         as character    no-undo.
define input  parameter p-goods-recid     as recid        no-undo. /*goods - recid*/
define input  parameter p-store-type      as character    no-undo.
define input  parameter p-store-code      as integer      no-undo.
define output parameter rid-list          as character    no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник рецептов".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/showinf.i     }
{ cmp/r-pril.i new  }
{ cmp/operlist.i    }
{ gbl/cur-time.i    }
{ str/fbrtest.i     }
{ str/fbrcode.i     }
{ trg/partslib.i    }
{ gbl/ggoattr.i }
{ str/fbrlib.i      }
{ gbl/getcntxt.i def }
{ str/checkGroupAttr.i }
&scoped-define frame-name dialog-frame
/* local variable definitions ---                                       */
define variable ri                   as recid                    no-undo .
define variable show-as              as character init "all-all" no-undo .
define variable rg-artic-name        as character format "x(50)" no-undo.
define variable rcp-code             like ub.recipe.recipe-code     no-undo .
define variable new-type             like ub.recipe.recipe-type     no-undo.
define variable rgs                  as recid                    no-undo.
define variable log-res              as logical                  no-undo .
define variable prevvalue            as character                no-undo .
define variable v-recipe-qnty        as decimal                  no-undo.
define variable v-host-code          as integer                  no-undo.
define variable v-can-set-global     as logical                  no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define stream liststream.
define buffer b-recipe     for ub.recipe .
define buffer b-recipe-gds for ub.recipe-gds .
define buffer b-goods      for ub.goods.
define variable varobj-date as date no-undo.
define variable v-ban-altr      as logical      no-undo .

function get-ingr-qnty returns decimal
  ( input  v-browse-type     as  character,
    input  p-qnty-type       as  integer,
    buffer local-recipe      for ub.recipe,
    buffer local-recipe-gds  for ub.recipe-gds) :
  define variable v-output-qnty    as decimal  no-undo.
  define buffer bf_recipe-gds for ub.recipe-gds.
  define buffer bf_goods      for ub.goods.
  define variable varrecipe-qnty-season            as decimal no-undo.
  define variable varrecipe-brutto-qnty-season     as decimal no-undo.
  define variable varrecipe-gds-qnty-season        as decimal no-undo.
  define variable varrecipe-gds-brutto-qnty-season as decimal no-undo.
  define variable varcoeff                         as decimal no-undo.
  if v-browse-type = "recipe-gds":u
  then do:
    case p-qnty-type
    :
      when 1
      then do:
          assign
              v-output-qnty = local-recipe-gds.qnty / local-recipe.qnty
          .
      end.        /* when 1 */
      when 2
      then do:
        assign
          v-output-qnty = local-recipe-gds.brutto-qnty / local-recipe.brutto-qnty
        .
      end.        /* when 2 */
      otherwise do:
        message "Неверный режим просмотра списка рецептов." view-as alert-box error.
      end.
    end case.       /* case p-qnty-type */
  end.
  else do:
    case p-qnty-type
    :
      when 1
      then do:
        assign
          v-output-qnty = local-recipe.qnty.
      end.        /* when 1 */
      when 2
      then do:
        assign
          v-output-qnty = local-recipe.brutto-qnty.
      end.        /* when 2 */
      otherwise do:
        message "Неверный режим просмотра списка рецептов." view-as alert-box error.
      end.
    end case.       /* case p-qnty-type */
  end.

  return v-output-qnty.
end function.

function get-browse-field returns character
  ( input p-parameter-number as integer, input p-recipe-code as character, input p-gds-code as integer ) :

    define variable v-output-string    as character      no-undo.
    define variable v-recipe-code      as character    no-undo.
    define variable v-mark as logical no-undo .

    define buffer buf_recipe        for ub.recipe.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.

    case p-parameter-number
    :
        when 1
        then do:
            find first buf_recipe no-lock
                 where buf_recipe.recipe-code = p-recipe-code
            .
            if buf_recipe.host-code = 0
            and buf_recipe.obj-type = ""
            and buf_recipe.obj-code = 0
            then do:
                assign
                    v-output-string = "+"
                .
            end.
            else do:
                assign
                    v-output-string = "-"
                .
            end.
        end.        /* when 1 */
        when 2
        then do:
            { gbl/unitbase.i
                p-gds-code
                v-output-string
            }
        end.        /* when 2 */
        when 3
        then do:
            run fbrlib-get-obj-recipe (
                  input p-store-type
                , input p-store-code
                , input p-gds-code
                , output v-recipe-code
            ).
            if v-recipe-code = p-recipe-code
            then do:
                assign
                    v-output-string = " +"
                .
            end.
            else do:
                assign
                    v-output-string = " -"
                .
            end.
        end.        /* when 3 */
        when 4
        then do:
            run fbrlib-get-mark (
                  input p-recipe-code
                , output v-mark
            ).
            if v-mark then do:
                assign
                    v-output-string = "+"
                .
            end.
            else do:
                assign
                    v-output-string = "-"
                .
            end.
        end.        /* when 3 */
        otherwise do:
            message "Неверный режим просмотра списка рецептов." view-as alert-box error.
        end.
    end case.       /* case p-parameter-number */
    return v-output-string.
end function.

/* ***********************  control definitions  ********************** */
define button b-chg
     label "&Изменить"
     size 9 by 1.0.
define button b-copy
     label "&Копия"
     size 9 by 1.0.
define button b-del
     label "&Удалить"
     size 9 by 1.0.
define button b-exit auto-go
     label "&Выход ":l
     size 9 by 1.0.
define button b-help
     label "Помо&щь":l
     size 9 by 1.0.
define button b-hist
     label "Ис&тория"
     size 9 by 1.0.
define button b-lkp
     label "&Просмотр"
     size 9 by 1.0.
define button b-print
     label "Пе&чать":l
     size 9 by 1.0.
define button b-sel auto-go
     label "Вы&бор ":l
     size 9 by 1.0.
define button b-add
     label "&Добавить":l
     size 9 by 1.0.
define button b-down
     label "Вни&з"
     size 10 by 1.
define button b-up
     label "Ввер&х"
     size 10 by 1.
define button b-set-default
     label "Осн"
     size 4 by 1.
define variable nameorcode as character format "x(256)":u
     view-as fill-in
     size 34.63 by 1
     bgcolor 15  no-undo.


define variable find-by as character
     view-as radio-set horizontal
     radio-buttons
     "Все", "all":u,
     "Наименование рецепта", "name":u,
     "n", "number":u,
     "Артикул товара", "article":u,
     "Название товара", "goods":u
     size 65 by 1 initial "all":u
 fgcolor 4 no-undo.

define variable table-find as character
     view-as radio-set vertical
     radio-buttons
     "Рец. на товар",  "recipe":u,
     "В составе рец.", "recipe-gds":u
     size 17 by 2 initial "recipe":u
no-undo.

define variable recipetype as character
  view-as radio-set horizontal
  radio-buttons
  "Все",          "all":u,
  "Разделка",     {&dressing},
  "Производство", {&manufacturing},
  "Комплектация", {&gathering},
  "Альтернатива", {&alternative},
  "Топливо",      {&petrolium-manufacturing}
  size 70.25 by 1
  fgcolor 4  no-undo.

define variable recipeprop as character
  view-as radio-set horizontal
  radio-buttons
  "Все",          "all":u,
  "Глобальные",   "global":u,
  "По объекту",   "local":u
  size 40 by 1 initial "all"
  no-undo.

def menu m-types
    menu-item m-type-1 label "Комплектация" accelerator "alt-1"
    menu-item m-type-2 label "Производство" accelerator "alt-2"
    menu-item m-type-3 label "Разделка"     accelerator "alt-3"
    menu-item m-type-4 label "Альтернатива" accelerator "alt-4"
    menu-item m-type-5 label "Топливо"      accelerator "alt-5"
    .

define variable good-name like ub.goods.gds-name
      view-as text
     size 18 by 1 fgcolor 4 no-undo.

define variable good-prod like ub.clients.obj-name
      view-as text
     size 18 by 1 fgcolor 4 no-undo.

define rectangle rect-1
     edge-chars 0.25 graphic-edge  no-fill
     size 98 by 1.45.

define rectangle rect-2
     edge-chars 0.25 graphic-edge  no-fill
     size 98 by 1.45.

define rectangle rect-3
     edge-chars 0.25 graphic-edge  no-fill
     size 67 by 3.08.

define query br-recipe for
             ub.recipe-gds,
             ub.recipe,
             ub.goods,
             ub.clients scrolling.
define browse br-recipe
  query br-recipe no-lock display
      get-browse-field ( input 3, input ub.recipe.recipe-code, input ub.goods.gds-code ) column-label "Осн" format "x(3)"
      get-browse-field ( input 1, input ub.recipe.recipe-code, input ub.goods.gds-code ) column-label "Гл" format "x(2)"
      get-browse-field ( input 4, input ub.recipe.recipe-code, input ub.goods.gds-code ) column-label "М" format "x(1)"
      ub.recipe.recipe-code format "x(12)"
      ub.recipe.recipe-name column-label "Наименование рецепта" format "x(30)"
      ub.recipe.recipe-type column-label "Т" format "x(1)"
      get-ingr-qnty ( input table-find, input 1, buffer ub.recipe, buffer ub.recipe-gds) @ v-recipe-qnty  format "->,>>>,>>>.999" column-label "Количество"
      get-browse-field( input 2, input ub.recipe.recipe-code, input ub.goods.gds-code ) column-label "ЕИ" format "x(3)"
      ub.goods.artic
      ub.goods.gds-name column-label "Название рецептурного товара" format "x(30)"
      ub.recipe.prod-type + " " +  string (ub.recipe.prod-code) column-label "Производитель" format "x(13)"
      ub.clients.obj-name column-label "Наименование производителя" format "x(30)"
    with no-row-markers separators
    size 98 by 11.5
    bgcolor 15 fgcolor 0 .

/* ************************  frame definitions  *********************** */
define frame dialog-frame
     b-exit     at row 1 col 1
     b-sel      at row 1 col 10
     b-add      at row 1 col 19
     b-lkp      at row 1 col 28
     b-chg      at row 1 col 37
     b-copy     at row 1 col 46
     b-del      at row 1 col 55
     b-print    at row 1 col 64
     b-hist     at row 1 col 73
     b-help     at row 1 col 90
     recipetype at row 2.54 col 13.88 no-label
     recipeprop at row 4.17 col 23.88 no-label
     nameorcode at row 6.17 col 40.25 colon-aligned no-label
     find-by at row 7.17 col 2.25 no-label
      "Наим.товара: " view-as text
          size 13.75 by 1 at row 8.83 col 1.13
          fgcolor 0
     table-find   at row 6 col 80 colon-aligned no-label
     good-name at row 8.83 col 14.88 no-label
     "Произ-ль: " view-as text
          size 13.75 by 1 at row 8.83 col 44.75
          fgcolor 0
     good-prod at row 8.83 col 54.75 no-label
     b-set-default at row 8.83 col 74.5
     b-up at row 8.83 col 78.5
     b-down at row 8.83 col 88.5
     br-recipe at row 10 col 1
     rect-1 at row 2.35 col 1
     rect-2 at row 4.0 col 1
     rect-3 at row 5.63 col 1
     "Рецепты:" view-as text
          size 9 by 1 at row 2.54 col 4.13
          fgcolor 0
     "Распространение:" view-as text
          size 16 by 1 at row  4.17 col 4.13
          fgcolor 0
     "Фильтр :" view-as text
          size 8.5 by 1 at row 6.17 col 4.13
          fgcolor 0
     space(0) skip(0)
     with view-as dialog-box keep-tab-order
          scrollable side-labels no-underline three-d
     title "В С Е   Р Е Ц Е П Т Ы".


assign
  frame dialog-frame:scrollable                       = false
  frame dialog-frame:hidden                           = true
  br-recipe:num-locked-columns in frame {&frame-name} = 1
  b-add:popup-menu in frame {&frame-name}             = menu m-types:handle
  b-add:menu-mouse                                    = 1
  br-recipe:num-locked-columns in frame {&frame-name} = 2.

/*перемещение колонок*/
{ gbl/mv-clmn.i
    &browse-name = "br-recipe"
    &frame-name = "{&frame-name}"
    &ext-col = 10
    &start-column = 3
}

/* ************************  control triggers  ************************ */

on window-close of frame dialog-frame /* В С Е   Р Е Ц Е П Т Ы */
do:
    apply "end-error":u to self.
end.

on choose of b-set-default  in frame dialog-frame /* Осн */
do:     /* перемещение текущей строки рецепта вниз */
    { gbl/stdbtn.i }
    define variable v-focused-row     as integer      no-undo.
    define variable v-cur-line        as recid        no-undo.
    define variable v-proc-number     as integer      no-undo.
    define variable v-yesno           as logical      no-undo.
    if not available ub.recipe
    or not available ub.goods
    then do:
        return no-apply.
    end.
    apply "entry" to br-recipe .
    assign
        v-focused-row   = br-recipe :focused-row in frame {&frame-name}
        v-cur-line      = recid( ub.recipe )
        v-proc-number   = ub.recipe.recipe-order
    .
    message
        "Текущий рецепт будет использоваться"
        skip "по умолчанию при автоматическом выборе"
        skip "рецепта для данного товара."
        skip(1)
        skip "Рецепт: " ub.recipe.recipe-code ub.recipe.recipe-name
        skip "Товар:  " ub.goods.gds-name
        skip(1)
        skip "Изменить признак?"
    view-as alert-box question
    buttons yes-no
    title "Установка признака рецепта по умолчанию"
    update v-yesno .
    if v-yesno = yes
    then do:
        { gbl/working.i }
        run set-default-recipe in this-procedure (
            input ub.recipe.recipe-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка установки признака использования рецепта по умолчанию."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        run change-query .
        br-recipe :set-repositioned-row( v-focused-row, "always") in frame {&frame-name}.
        reposition br-recipe to row v-focused-row .
        apply "entry" to browse br-recipe.
        { gbl/stopwork.i }
    end.      /* if v-yesno = yes */
end.
on choose of b-down in frame dialog-frame /* Вниз */
do:     /* перемещение текущей строки рецепта вниз */
  { gbl/stdbtn.i }
  define variable v-cur-line          as recid          no-undo.
  define variable v-proc-number       as integer        no-undo.
  define variable v-old-proc-number   as integer        no-undo.
  define variable v-focused-row       as integer        no-undo.
  if not available ub.recipe
  then do:
      return no-apply.
  end.
  apply "entry" to br-recipe .
  assign
      v-focused-row   = br-recipe :focused-row in frame {&frame-name}
      v-cur-line      = recid( ub.recipe )
      v-proc-number   = ub.recipe.recipe-order
  .
  get next br-recipe.
  if not available ub.recipe
  then do:
      apply "entry" to br-recipe.
      return no-apply.
  end.
  { gbl/working.i }
  swap-down:
  do
  on error undo swap-down, return no-apply
  :
      assign
          v-old-proc-number    = ub.recipe.recipe-order
          v-focused-row        = v-focused-row + 1
      .
      run ref/recipord.p (
            input ub.recipe.recipe-code
          , input v-proc-number
      ).
      find first recipe
           where recid( recipe ) = v-cur-line
      .
      run ref/recipord.p (
            input ub.recipe.recipe-code
          , input v-old-proc-number
      ).
  end.
  run change-query .
  br-recipe :set-repositioned-row( v-focused-row, "always") in frame {&frame-name}.
  reposition br-recipe to row v-focused-row .
  apply "entry" to browse br-recipe.
  { gbl/stopwork.i }
end.
on choose of b-up in frame dialog-frame /* Вверх */
do:     /* перемещение текущей строки рецепта вверх */
  { gbl/stdbtn.i }
  define variable v-cur-line          as recid                    no-undo.
  define variable v-proc-number       as integer                  no-undo.
  define variable v-old-proc-number   as integer        no-undo.
  define variable v-focused-row       as integer        no-undo.

  if not available ub.recipe
  then do:
      return no-apply.
  end.
  apply "entry" to br-recipe .
  assign
      v-focused-row   = br-recipe :focused-row in frame {&frame-name}
      v-cur-line      = recid( ub.recipe )
      v-proc-number   = ub.recipe.recipe-order
  .
  get prev br-recipe.
  if not available ub.recipe
  then do:
      apply "entry" to br-recipe.
      return no-apply.
  end.
  { gbl/working.i }
  swap-up:
  do
  on error undo swap-up, return no-apply
  :
      assign
          v-old-proc-number    = ub.recipe.recipe-order
          v-focused-row        = v-focused-row  - 1
      .
      run ref/recipord.p (
            input ub.recipe.recipe-code
          , input v-proc-number
      ).
      find first ub.recipe no-lock
           where recid( ub.recipe ) = v-cur-line
      .
      run ref/recipord.p (
            input ub.recipe.recipe-code
          , input v-old-proc-number
      ).
  end.
  run change-query .
  br-recipe :set-repositioned-row( v-focused-row, "always") in frame {&frame-name}.
  reposition br-recipe to row v-focused-row .
  apply "entry" to browse br-recipe.
  { gbl/stopwork.i }
end.
on choose of b-chg in frame dialog-frame /* Изменить */
do:
  { gbl/stdbtn.i }
  define variable v-recipe-code           as character      no-undo.
  define variable v-have-rights-to-global as logical        no-undo.
  define variable v-mode                  as character      no-undo.
  if available ub.recipe
  then do:
      define variable v-lock-not-enabled  as logical       no-undo.
      run check-recipe-lock in this-procedure (
            input ub.recipe.recipe-code
          , output v-lock-not-enabled
      ).
      if v-lock-not-enabled = true
      then do:
          message
              "В данный момент рецепт используется другим процессом."
              skip "Изменение рецепта невозможно."
          view-as alert-box information.
          undo, return no-apply.
      end.
      assign
          g#log = false
      .

      if  ub.recipe.host-code = 0
      and ub.recipe.obj-type = ""
      and ub.recipe.obj-code = 0
      then do:
        /* глобальный рецепт */
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_recipe-reference_conjoint':U
          {&cntxt-global}
          0
          '':U
          0
          0
          0
          0
          true
          g#log
        }
        if not g#log
        then do:
            undo, return no-apply .
        end.
      end.
      else do:
        /* рецепт на объекте */
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_recipe-reference_input-deletion-updating':U
          {&cntxt-object}
          ub.recipe.host-code
          ub.recipe.obj-type
          ub.recipe.obj-code
          0
          0
          0
          true
          g#log
        }
        if not g#log
        then do:
            undo, return no-apply .
        end.
      end.


      if  ub.recipe.host-code = 0
      and ub.recipe.obj-type = ""
      and ub.recipe.obj-code = 0
      then do:
          if v-cntxt-db-num <> 0
          then do:
              message
                  "Глобальный рецепт может быть изменен только в ГБД."
                  skip(1)
                  skip "Изменение выбранного рецепта невозможно."
              view-as alert-box error
              title "Изменение рецепта".
              undo, return no-apply .
          end.
      end.
      assign
          ri                  = recid( ub.recipe )
          v-can-set-global    = yes
      .
      run ref/recipe.w (
            input p-mainmenu-handle
          , input {&update}
          , input recid( ub.goods )
          , input ub.recipe.recipe-type
          , input ub.recipe.recipe-code
          , input v-host-code
          , input p-store-type
          , input p-store-code
          , input ( v-cntxt-db-num = 0 )
          , input v-can-set-global
          , output v-recipe-code
      ) no-error.
      if error-status :error
      then do:
          message
                   vss-workfile vss-revision vss-description
              skip "Ошибка при изменении рецепта."
              skip return-value
              skip "Номер рецепта:" ub.recipe.recipe-code
              skip "Артикул товара:" ub.recipe.artic
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply .
      end.
      display
          ub.recipe.recipe-code
          ub.recipe.recipe-name
          ub.recipe.recipe-type
          ( if table-find = "recipe":u then ub.recipe.qnty else ub.recipe-gds.qnty / ub.recipe.qnty )  @ v-recipe-qnty
      with browse br-recipe no-error.
      run fbrlib-set-default-recipe in this-procedure (
            input p-store-type
          , input p-store-code
          , input ub.goods.gds-code
      ).
      br-recipe :refresh().
  end.
  apply "entry" to br-recipe.
  return no-apply.
end.
on choose of b-copy in frame dialog-frame /* Изменить */
do:
  define variable v-cur-line          as recid          no-undo.
  define variable v-focused-row       as integer        no-undo.
  define variable v-new-recipe-rowid  as rowid        no-undo.
  if available ub.recipe
  then do:
    { gbl/working.i }
    assign
      v-focused-row   = br-recipe :focused-row in frame {&frame-name}
      v-cur-line      = recid( ub.recipe )
    .
    run copy-recipe in this-procedure (
        input ub.recipe.recipe-code
      , input v-host-code
      , input p-store-type
      , input p-store-code
      , output v-new-recipe-rowid
    ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description
        skip "Ошибка при копировании рецепта."
        skip return-value
        skip trim(error-status :get-message(1))
             trim(error-status :get-message(2))
             trim(error-status :get-message(3))
        view-as alert-box error.
      undo, return no-apply .
    end.
    run change-query .

    br-recipe :set-repositioned-row( v-focused-row, "always") in frame {&frame-name}.
    reposition br-recipe to rowid rowid( ub.recipe-gds ), v-new-recipe-rowid .
    apply "entry" to browse br-recipe.
    { gbl/stopwork.i }
  end.
end.
on choose of b-del in frame dialog-frame /* Удалить */
do:
  define variable v-have-rights    as logical        no-undo.
  if available ub.recipe
  then do:
      assign
          v-have-rights = false
      .
      if  ub.recipe.host-code = 0
      and ub.recipe.obj-type = ""
      and ub.recipe.obj-code = 0
      then do:
        /* глобальный рецепт */
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_recipe-reference_conjoint':U
          {&cntxt-object}
          0
          '':U
          0
          0
          0
          0
          true
          v-have-rights
        }
        if not v-have-rights
        then do:
            undo, return no-apply .
        end.
      end.
      else do:
        /* рецепт на объекте */
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_recipe-reference_input-deletion-updating':U
          {&cntxt-object}
          ub.recipe.host-code
          ub.recipe.obj-type
          ub.recipe.obj-code
          0
          0
          0
          true
          v-have-rights
        }
        if not v-have-rights
        then do:
            undo, return no-apply .
        end.
      end.

      if ub.recipe.host-code = 0
      and ub.recipe.obj-type = ""
      and ub.recipe.obj-code = 0
      then do:
          if v-cntxt-db-num <> 0
          then do:
              message
                  "Глобальный рецепт может быть удален только в ГБД."
                  skip(1)
                  skip "Удаление выбранного рецепта невозможно."
              view-as alert-box error
              title "Удаление рецепта".
              undo, return no-apply .
          end.
      end.
      find first ub.fbr-line no-lock
           where ub.fbr-line.recipe-code = ub.recipe.recipe-code
      no-error.
      if not available ub.fbr-line
      then do:
          assign
              v-have-rights = no
          .
          message
              "Удаление выбранного рецепта не повлияет"
              skip "на сформированные по этому рецепту документы,"
              skip "однако он может использоваться для создания новых документов."
              skip(1)
              skip "Номер рецепта:" ub.recipe.recipe-code
              skip "Наименование: " ub.recipe.recipe-name
              skip(1)
              skip "Удалить рецепт?"
          view-as alert-box question
          buttons yes-no
          title "Удаление рецепта"
          update v-have-rights
          .
          if v-have-rights = yes
          then do:
                find first b-recipe exclusive-lock
                    where recid( b-recipe ) = recid( ub.recipe )
                .
                delete b-recipe .
                run fbrlib-set-default-recipe in this-procedure (
                      input p-store-type
                    , input p-store-code
                    , input ub.goods.gds-code
                ).
                run change-query .
                if available ub.recipe
                then do:
                    assign
                        log-res = br-recipe :select-row( 1 )
                    .
                end.
          end.
      end.
      else do:
          find first ub.fbr-doc no-lock
               where ub.fbr-doc.doc-code = ub.fbr-line.doc-code no-error.
          message
              "Удаление НЕВОЗМОЖНО :"
              skip "рецепт используется"
              skip "в производственных операциях."
              skip "Документ: " ub.fbr-doc.doc-type ub.fbr-doc.doc-code
              skip "От " ub.fbr-doc.doc-date
          view-as alert-box error .
      end.
  end.
  apply "entry" to br-recipe.
  return no-apply.
end.
on choose of b-hist in frame dialog-frame /* История */
do:
  if available ub.recipe then do:
        run str/crecip.w (
              input 1
            , input ub.recipe.recipe-code
            , input "":U
            , input ?
            , input ?
            , input 0
        ).
    apply "entry" to br-recipe.
    return no-apply.
  end.
end.
on choose of b-lkp in frame dialog-frame /* Просмотр */
do:
  define variable v-recipe-code    as character      no-undo.
  if available ub.recipe
  then do:
        v-can-set-global = false.
        run ref/recipe.w (
              input p-mainmenu-handle
            , input {&lookup}
            , input recid( ub.goods )
            , input ub.recipe.recipe-type
            , input ub.recipe.recipe-code
            , input v-host-code
            , input p-store-type
            , input p-store-code
            , input ( v-cntxt-db-num = 0 )
            , input v-can-set-global
            , output v-recipe-code
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при просмотре рецепта."
                skip return-value
                skip "Номер рецепта:" ub.recipe.recipe-code
                skip "Артикул товара:" ub.recipe.artic
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
  end.
  apply "entry" to br-recipe.
  return no-apply.
end.
on choose of b-print in frame dialog-frame /* Печать */
do:

/*------  Это можно включить когда понадобится печать списка форм по рецепту -------*/
/*    define variable v-print-list as logical no-undo.                              */
/*    run str/fbr-gprn.w (                                                              */
/*                        p-mainmenu-handle                                         */
/*                   , recid(recipe)                                                */
/*                  , output v-print-list                                           */
/*                   ).                                                             */
/*    if v-print-list = yes                                                         */
/*    then do:                                                                      */
/*------  Это можно включить когда понадобится печать списка форм по рецепту -------*/

  define variable sym1 as character init ":"   no-undo.
  define variable sym2 as character init ":"   no-undo.
  define variable sym3 as character init ":"   no-undo.
  define variable sym4 as character init ":"   no-undo.
  define variable sym5 as character init ":"   no-undo.
  define variable sym6 as character init ":"   no-undo.
  define variable sym7 as character init ":"   no-undo.
  define variable sym8 as character init ":"   no-undo.

  define variable line                    as character no-undo.
  define variable cli-attr                as character no-undo.
  define variable v-recipe-counter        as integer   no-undo.
  define variable startrecid              as recid     no-undo.

  define frame list
      sym1 column-label ":" format "x(1)" space(0)
      ub.recipe.recipe-code column-label "Номер" format "x(15)" space(0)
      sym2 column-label ":" format "x(1)" space(0)
      ub.recipe.recipe-name column-label "Наименование рецепта" format "x(25)" space(0)
      sym3 column-label ":" format "x(1)" space(0)
      ub.recipe.recipe-type column-label "Тип" format "x(16)" space(0)
      sym4 column-label ":" format "x(1)" space(0)
      ub.recipe.qnty column-label "Количество     " format "->>,>>>,>>9.<<<" space(0)
      sym5 column-label ":" format "x(1)" space(0)
      ub.goods.artic column-label "Артикул" format "x(16)" space(0)
      sym6 column-label ":" format "x(1)" space(0)
      ub.goods.gds-name column-label "Назв. рецептурного тов." format "x(30)" space(0)
      sym7 column-label ":" format "x(1)" space(0)
      cli-attr column-label "Произв-ль" format "x(10)" space(0)
      sym8 column-label ":" format "x(1)" space(0)
      header
          cur-time-print() at 5 format "x(35)"
              string( "Страница " + string( page-number( liststream ) , ">>9") )
                  at 56 format "x(15)" skip
          line format "x(135)" at 1
      with width {&a4_cw} down use-text stream-io no-box .

  if num-results( "br-recipe" ) = 0 then
      do:
          message "Список  П У С Т !" skip view-as alert-box information .
          return no-apply .
      end.

  { gbl/working.i }
  line = fill( "-" , 140 ) .
  if table-find = "recipe-gds":u
  then do:
    assign
      ri = recid( ub.recipe-gds )
      .
  end.
  else do:
    assign
      ri = recid( ub.recipe )
    .
  end.
  get first br-recipe no-lock.
  assign
    v-recipe-counter = 1
  .
  { cmp/open-out.i stream liststream }
  form header
    line format "x(135)" skip
    "Продолжение - на следующей странице" at 30 skip
    with frame clibottomframe width {&a4_cw} page-bottom no-labels no-box.
  view stream liststream frame clibottomframe .
  if show-as <> "all-all-all" or p-goods-recid <> ? then do:
    put stream liststream space(10)
        (string( "СПИСОК РЕЦЕПТОВ" ) +
        if p-goods-recid = ? then "" else
        (if table-find = "recipe":u then " НА ТОВАР " else
        (if table-find = "recipe-gds":u then " С ТОВАРОМ "  else
        " НА ТОВАР И С ТОВАРОМ ")) +
        rg-artic-name
        )
        format "x(100)" skip(2)
        space(10) string( "( ТИП : " + recipetype + " , фильтр - " + caps( find-by ) +
            ( if find-by = "all":u then "" else " : " ) +
            ( if find-by <> "all":u then ('"' + nameorcode + '"') else "" ) + " )" ) format "x(100)" skip(2) .
  end.
  else do:
      put stream liststream space(10)
          string( "П О Л Н Ы Й   С П И С О К   Р Е Ц Е П Т О В" ) format "x(100)" skip(2) .
  end.
  form with frame list .
  do while available ub.recipe-gds :
    display stream liststream
                   sym1 ub.recipe.recipe-code
                   sym2 ub.recipe.recipe-name
                   sym3 ub.recipe.recipe-type
                   sym4 ( if table-find = "recipe":u then ub.recipe.qnty else ub.recipe-gds.qnty / ub.recipe.qnty )  @ ub.recipe.qnty
                   sym5 ub.goods.artic
                   sym6 ub.goods.gds-name
                   sym7 ( ub.goods.prod-type + " " + string( ub.goods.prod-code ) ) @ cli-attr
                   sym8    with frame list .
    down stream liststream 1 with frame list .
    v-recipe-counter =  v-recipe-counter + 1 .
    get next br-recipe .
  end.
  put stream liststream line format "x(135)" skip.
  hide stream liststream frame clibottomframe .
  output stream liststream close .
    { gbl/stopwork.i }
    define variable v-user-action           as character            no-undo.
    define variable v-printed               as logical              no-undo.
    run gbl/prnfilen.w (
          input "":U
        , input 0
        , input string( session :temp-directory ) + {&DF_Name} + string( g#report-num )
        , input 7
        , output v-user-action
        , output v-printed
    ) .
  if table-find = "recipe-gds":u
  then do:
    reposition br-recipe to recid ri no-error.
  end.
  else do:
    get first br-recipe no-lock.
    assign
      v-recipe-counter = 1
    .
    if recid(ub.recipe) = ri
    then do:
        reposition br-recipe to row 1 no-error.
    end.
    else do:
        do while available ub.recipe-gds
        :
            get next br-recipe no-lock .
            assign
                v-recipe-counter = v-recipe-counter + 1
            .
            if recid(ub.recipe) = ri
            then do:
                leave.
            end.
        end.
    end.
    reposition br-recipe to row v-recipe-counter no-error.
  end.
end.
on choose of b-sel in frame dialog-frame /* Выбор */
do:
  if available ub.recipe
  and ub.recipe.stts = 2 /*Закрыт/Не действует */
  then do :
    message "Данный рецепт НЕ действует и не может быть использован!" view-as alert-box .
    return no-apply .
  end .
  if ( available ub.recipe ) and ( rid-list = "" ) then
    rid-list = string( recid( ub.recipe ) ) .
end.
on mouse-select-dblclick of br-recipe in frame dialog-frame
do:
  if b-sel:sensitive then do:
      apply "choose" to b-sel in frame {&frame-name}.
  end.
  else do:
    if b-lkp:sensitive then do:
      apply "choose" to b-lkp in frame {&frame-name}.
    end.
  end.
end.
on value-changed of br-recipe in frame dialog-frame /* Товары по рецепту */
do:
  define variable v-recipe-is-bad   as logical     no-undo.
  if num-results( "br-recipe" ) = 0
  then do:
      assign
          good-name   = ""
          good-prod   = ""
      .
  end.
  else do:
      if available ub.recipe
      then do:
          assign
              good-name = ub.goods.gds-name
              good-prod = ( if available ub.clients then ub.clients.obj-name else "" )
          .
      end.
  end.
  display
      good-name
      good-prod
  with frame {&frame-name}.
  if available ub.recipe
  then do:
      run fbrtest-test-recipe in this-procedure (
            input ub.recipe.recipe-code
          , input no
          , input ""
          , output v-recipe-is-bad
      ) .
      if v-recipe-is-bad
      then do:
          for each temp_fbrtest_recipe
          :
              message
                       "Рецепт содержит некорректные данные:"
                  skip "   " v-fbrtest-error-description[ temp_fbrtest_recipe.error-code ]
                  skip (1)
                  skip "Номер рецепта:" temp_fbrtest_recipe.recipe-code
                  skip "Артикул товара:" temp_fbrtest_recipe.artic
              view-as alert-box warning
              title "Ошибка в рецепте".
          end.
      end.
  end.        /* if available recipe */
end.
on return of br-recipe in frame dialog-frame
do:
  if b-sel:sensitive then do:
      apply "choose" to b-sel in frame {&frame-name}.
  end.
  else do:
    if b-lkp:sensitive then
       apply "choose" to b-lkp in frame {&frame-name}.
  end.
end.
on choose of b-add in frame dialog-frame /* Добавить */
do:
  run add-recipe in this-procedure .
  apply "entry" to br-recipe.
end.
on choose of menu-item m-type-1 in menu m-types do:
if p-goods-recid <> ? and lookup({&weight}, ub.units.type) > 0 then do:
  bell.
  return no-apply.
end.
new-type = {&gathering}.
apply "choose" to b-add in frame {&frame-name}.
return no-apply.
end.

on choose of menu-item m-type-2 in menu m-types do:
  new-type = {&manufacturing}.
  apply "choose" to b-add in frame {&frame-name}.
  return no-apply.
end.
on choose of menu-item m-type-3 in menu m-types do:
new-type = {&dressing}.
apply "choose" to b-add in frame {&frame-name}.
end.
on choose of menu-item m-type-4 in menu m-types do:
new-type = {&alternative}.
apply "choose" to b-add in frame {&frame-name}.
end.
on choose of menu-item m-type-5 in menu m-types do:
if menu-item m-type-5:label in menu m-types = "" then do:
bell.
return no-apply.
end.
new-type = {&petrolium-manufacturing}.
apply "choose" to b-add in frame {&frame-name}.
end.
on value-changed of table-find in frame dialog-frame
do:
  if p-goods-recid <> ? and table-find:screen-value = "recipe":u
  then do:
    if can-do("article,goods":u,find-by:screen-value)
    then do:
        assign
            find-by = "all":u
        .
    end.
    assign
        log-res = find-by :disable(radio-label("article":u, find-by:radio-buttons))
        log-res = find-by :disable(radio-label("goods":u, find-by:radio-buttons))
    .
    display
        find-by
    with frame {&frame-name}.
  end.
  if p-goods-recid <> ?
  and table-find:screen-value <> "recipe":u
  then do:
    assign
      log-res = find-by:enable(radio-label("article":u, find-by:radio-buttons))
      log-res = find-by:enable(radio-label("goods":u, find-by:radio-buttons))
    .
  end.
  assign
    table-find
  .
  display
    table-find
  with frame {&frame-name}.
  if not can-do("article,goods":u,find-by )
  then do:
    run change-query .
  end.
end.

on value-changed of find-by in frame dialog-frame
do:
 assign
   prevvalue = find-by .
  if find-by:screen-value = "all":u then do:
    assign
    log-res = find-by:enable(radio-label("name":u, find-by:radio-buttons))
    log-res = find-by:enable(radio-label("number":u, find-by:radio-buttons))
    log-res = find-by:enable(radio-label("article":u, find-by:radio-buttons))
    log-res = find-by:enable(radio-label("goods":u, find-by:radio-buttons))
    .
    run change-query .
    disable nameorcode with frame {&frame-name} .
    hide nameorcode .
  end.
  else  do:
    view nameorcode .
    enable nameorcode with frame {&frame-name} .
    case find-by:screen-value :
      when "number":u then do:
          assign
              log-res = find-by:disable(radio-label("name":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("article":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("goods":u, find-by:radio-buttons))
              .
      end.
      when "name":u then do:
          assign
              log-res = find-by:disable(radio-label("number":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("article":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("goods":u, find-by:radio-buttons))
               .
      end.
      when "article":u then do:
          assign
              log-res = find-by:disable(radio-label("name":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("number":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("goods":u, find-by:radio-buttons))
              .
      end.
      when "goods":u then do:
          assign
              log-res = find-by:disable(radio-label("name":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("article":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("number":u, find-by:radio-buttons))
              .
      end.
      otherwise do:
        message "Не верный тип сортировки." view-as alert-box error.
      end.
    end case .
    display table-find with frame {&frame-name}.
    apply "entry" to nameorcode in frame {&frame-name} .
    return no-apply.
  end.
end.
on leave of nameorcode in frame dialog-frame
do:
  disable nameorcode with frame {&frame-name} .
  hide    nameorcode .
end.
on return of nameorcode in frame dialog-frame
do:
  def buffer b-recipe for ub.recipe .

  assign
      recipetype find-by nameorcode .

  if nameorcode = "" then
      return no-apply .
  nameorcode = right-trim( trim( nameorcode ), "*" ) .
  run change-query .
  if available ub.recipe and num-results( "br-recipe" ) <> 0 then
      log-res = br-recipe:select-row( 1 ) .
end.

on value-changed of recipetype in frame dialog-frame
do:
  assign recipetype .
  if recipetype = "all" then
  assign b-add:popup-menu in frame {&frame-name} = menu m-types:handle.
  else
  assign b-add:popup-menu in frame {&frame-name} = ?.
  run change-query .
  apply "entry" to br-recipe.
end.

on value-changed of recipeprop in frame dialog-frame
do:
  assign recipeprop .
  run change-query .
  apply "entry" to br-recipe.
end.

/* ***************************  main block  *************************** */

/* parent the dialog-box to the active-window, if there is no parent.   */
if valid-handle(active-window) and frame {&frame-name}:parent eq ?
then frame {&frame-name}:parent = active-window.

{ gbl/app_help.i &browse-name="br-recipe" }

/* now enable the interface and wait for the exit condition.            */
/* (note: handle error and end-key so cleanup code will always fire.    */
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block:
   { gbl/getcntxt.i get " " p-mainmenu-handle }
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    assign
        v-can-set-global = no
    .
    { gbl/curobjdt.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      varobj-date
      no-error
    }
    if error-status:error then do:
      message "Ошибка при поиске даты на текущем объекте." view-as alert-box error.
      return error.
    end.
    if can-do(call-mode, "recipe-gds")
    then do:
      assign
          recipetype = entry(1,call-mode )
          table-find = "ub.recipe-gds":u
      .
    end.
    else do:
      assign
          recipetype = call-mode
      .
    end.
    { gbl/hostcode.i
      p-store-type
      p-store-code
      v-host-code
      no-error }
    if error-status :error then do:
      message
          "Не удалось получить код фирмы для текущего объекта."
          skip "Операции будут возможны только для глобальных рецептов."
      view-as alert-box warning.
      assign
          p-store-type = ""
          p-store-code = 0
          v-host-code  = 0
      .
    end.
    if recipetype <> {&dressing}
    and recipetype <> {&manufacturing}
    and recipetype <> {&gathering}
    and recipetype <> {&alternative}
    and recipetype <> {&petrolium-manufacturing}
    then do:
      assign
        recipetype = "all"
      .
    end.
    if p-goods-recid <> ? then do:
      find first b-goods where recid(b-goods) = p-goods-recid no-lock no-error.
      find first units where units.unit-name = b-goods.unit-base no-lock no-error.
      rg-artic-name = b-goods.artic + " " + b-goods.gds-name.
    end.
    find ub.db where ub.db.db-num = v-cntxt-db-num no-lock .
    run enable_ui.
    run change-query .
    hide nameorcode in frame {&frame-name} .
    wait-for go of frame {&frame-name} focus br-recipe.
end.
run disable_ui.

/* **********************  internal procedures  *********************** */

procedure change-query :
define variable v-recipe-gds-recid as recid no-undo .

define buffer buf_recipe-gds for ub.recipe-gds .

find first buf_recipe-gds no-lock  no-error.
if avail buf_recipe-gds then
assign
  v-recipe-gds-recid = recid(buf_recipe-gds)
.
assign frame dialog-frame
    find-by nameorcode
.
{ gbl/working.i }
case recipetype :
    when "all":u then
        frame {&frame-name}:title = "Все РЕЦЕПТЫ " .
    when {&dressing} then
        frame {&frame-name}:title = "РЕЦЕПТЫ для разделки " .
    when {&manufacturing} then
        frame {&frame-name}:title = "РЕЦЕПТЫ для производства " .
    when {&gathering} then
        frame {&frame-name}:title = "РЕЦЕПТЫ для комплектации " .
    when {&alternative} then
        frame {&frame-name}:title = "РЕЦЕПТЫ альтернативной замены " .
    when {&petrolium-manufacturing} then
        frame {&frame-name}:title = "РЕЦЕПТЫ на топливо " .
end case .
if p-goods-recid <> ? then do:
    frame {&frame-name}:title =
    frame {&frame-name}:title +
    (if  table-find = "recipe":u then ("НА ТОВАР "
                                                                                     + b-goods.artic + " " + b-goods.gds-name)
                                                                                else
                                                                                ("c ТОВАРОМ " + b-goods.artic + " " +
                                                                                 b-goods.gds-name)

    ).
end.
if find-by <> "all":u then
frame {&frame-name}:title = frame {&frame-name}:title + " ФИЛЬТР - " + find-by + " " +
'"' + nameorcode + '"'.
show-as = recipetype + "-" + find-by  + "-" + table-find.
if recipetype = "all" then do:
  case find-by :
    when "all":u then do:
      case table-find:
        when "recipe":u
        then do:
          if p-goods-recid = ? then do:
            if recipeprop = "all" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                each ub.recipe no-lock
               where ( ub.recipe.host-code = 0
                         and ub.recipe.obj-type = ""
                         and ub.recipe.obj-code = 0
                ) or ( ub.recipe.host-code = v-host-code
                         and ub.recipe.obj-type = p-store-type
                         and ub.recipe.obj-code = p-store-code
                ) use-index gds
              ,first ub.goods no-lock
                  where ub.goods.artic = ub.recipe.artic
                  and ub.goods.prod-type = ub.recipe.prod-type
                  and ub.goods.prod-code = ub.recipe.prod-code
              ,first ub.clients no-lock
                where ub.clients.obj-type = ub.recipe.prod-type
                  and ub.clients.obj-code = ub.recipe.prod-code
            by ub.recipe.recipe-order
            .
          end.
            if recipeprop = "global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                  each ub.recipe no-lock
                where ( ub.recipe.host-code = 0
                          and ub.recipe.obj-type = ""
                          and ub.recipe.obj-code = 0
                  ) use-index gds
                ,first ub.goods no-lock
                  where ub.goods.artic = ub.recipe.artic
                    and ub.goods.prod-type = ub.recipe.prod-type
                    and ub.goods.prod-code = ub.recipe.prod-code
                ,first ub.clients no-lock
                  where ub.clients.obj-type = ub.recipe.prod-type
                    and ub.clients.obj-code = ub.recipe.prod-code
              by ub.recipe.recipe-order
              .
            end.
            if recipeprop = "local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                  each ub.recipe no-lock
                where ( ub.recipe.host-code = v-host-code
                          and ub.recipe.obj-type = p-store-type
                          and ub.recipe.obj-code = p-store-code
                  ) use-index gds
                ,first ub.goods no-lock
                  where ub.goods.artic = ub.recipe.artic
                    and ub.goods.prod-type = ub.recipe.prod-type
                    and ub.goods.prod-code = ub.recipe.prod-code
                ,first ub.clients no-lock
                  where ub.clients.obj-type = ub.recipe.prod-type
                    and ub.clients.obj-code = ub.recipe.prod-code
              by ub.recipe.recipe-order
              .
            end.
          end.
          else do:
            if recipeprop = "all" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock
               where recid(ub.recipe-gds) = v-recipe-gds-recid
              , each ub.recipe no-lock
               where ub.recipe.artic = b-goods.artic
                 and ub.recipe.prod-type = b-goods.prod-type
                 and ub.recipe.prod-code = b-goods.prod-code
                 and ( ( ub.recipe.host-code = 0
                     and ub.recipe.obj-type = ""
                     and ub.recipe.obj-code = 0
                  ) or ( ub.recipe.host-code = v-host-code
                     and ub.recipe.obj-type = p-store-type
                     and ub.recipe.obj-code = p-store-code
                     ) )
               use-index gds
             , first ub.goods no-lock
               where recid(ub.goods) = p-goods-recid
             , first ub.clients no-lock
                where ub.clients.obj-type = recipe.prod-type
                  and ub.clients.obj-code = recipe.prod-code
              by ub.recipe.recipe-order
              .
            end.
            if recipeprop = "global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock
                where recid(ub.recipe-gds) = v-recipe-gds-recid
                , each ub.recipe no-lock
                where ub.recipe.artic = b-goods.artic
                  and ub.recipe.prod-type = b-goods.prod-type
                  and ub.recipe.prod-code = b-goods.prod-code
                  and ( ub.recipe.host-code = 0
                      and ub.recipe.obj-type = ""
                      and ub.recipe.obj-code = 0
                    ) use-index gds
              , first ub.goods no-lock
                where recid(ub.goods) = p-goods-recid
              , first ub.clients no-lock
                where ub.clients.obj-type = ub.recipe.prod-type
                  and ub.clients.obj-code = ub.recipe.prod-code
              by ub.recipe.recipe-order
              .
            end.
            if recipeprop = "local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock
                where recid(ub.recipe-gds) = v-recipe-gds-recid
                , each ub.recipe no-lock
                where ub.recipe.artic = b-goods.artic
                  and ub.recipe.prod-type = b-goods.prod-type
                  and ub.recipe.prod-code = b-goods.prod-code
                  and ( ub.recipe.host-code = v-host-code
                      and ub.recipe.obj-type = p-store-type
                      and ub.recipe.obj-code = p-store-code
                      ) use-index gds
              , first ub.goods no-lock
                where recid(ub.goods) = p-goods-recid
              , first ub.clients no-lock
               where ub.clients.obj-type = ub.recipe.prod-type
                 and ub.clients.obj-code = ub.recipe.prod-code
            by ub.recipe.recipe-order
            .
          end.
          end.
        end.        /*when recipe*/
        when "recipe-gds":u then do: /*может быть только для p-goods-recid <> ?*/
          if p-goods-recid <> ? then do:
            if recipeprop = "all" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where
                     ub.recipe-gds.artic     = b-goods.artic and
                     ub.recipe-gds.prod-type = b-goods.prod-type and
                     ub.recipe-gds.prod-code = b-goods.prod-code,
            first ub.recipe no-lock
            where ub.recipe-gds.recipe-code = ub.recipe.recipe-code
                     and ( ( ub.recipe.host-code = 0
                         and ub.recipe.obj-type  = ""
                         and ub.recipe.obj-code  = 0
                         ) or ( ub.recipe.host-code = v-host-code
                            and ub.recipe.obj-type  = p-store-type
                            and ub.recipe.obj-code  = p-store-code
                             ) )
            ,
              first ub.goods where ub.goods.artic     = ub.recipe.artic     and
                                ub.goods.prod-type = ub.recipe.prod-type and
                                ub.goods.prod-code = ub.recipe.prod-code no-lock,
              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop = "global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                      ub.recipe-gds.artic     = b-goods.artic and
                      ub.recipe-gds.prod-type = b-goods.prod-type and
                      ub.recipe-gds.prod-code = b-goods.prod-code,
              first ub.recipe no-lock
              where ub.recipe-gds.recipe-code = ub.recipe.recipe-code
                      and ( ub.recipe.host-code = 0
                          and ub.recipe.obj-type  = ""
                          and ub.recipe.obj-code  = 0
                          )
              ,
              first ub.goods where ub.goods.artic     = ub.recipe.artic     and
                                ub.goods.prod-type = ub.recipe.prod-type and
                                ub.goods.prod-code = ub.recipe.prod-code no-lock,
              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop = "local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                      ub.recipe-gds.artic     = b-goods.artic and
                      ub.recipe-gds.prod-type = b-goods.prod-type and
                      ub.recipe-gds.prod-code = b-goods.prod-code,
              first ub.recipe no-lock
              where ub.recipe-gds.recipe-code = ub.recipe.recipe-code
                      and ( ub.recipe.host-code = v-host-code
                              and ub.recipe.obj-type  = p-store-type
                              and ub.recipe.obj-code  = p-store-code
                              )
              ,
              first ub.goods where ub.goods.artic     = ub.recipe.artic     and
                              ub.goods.prod-type = ub.recipe.prod-type and
                              ub.goods.prod-code = ub.recipe.prod-code no-lock,
              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
          end.
        end. /*when recipe-gds*/
      end case.                            /*end of find - all*/
    end.
    when "name":u then do:
        case table-find:
        when "recipe":u then do:
           if p-goods-recid = ? then do :
             if recipeprop ="all" then do :
           open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                    each ub.recipe no-lock
                    where ub.recipe.recipe-name begins nameorcode
                            and ( ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                ) or ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                    ) )

                                                        use-index recipe-name,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                       ub.goods.prod-type = ub.recipe.prod-type and
                                                       ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop ="global" then do :
                open query br-recipe
                for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                        each ub.recipe no-lock
                        where ub.recipe.recipe-name begins nameorcode
                                and ( ub.recipe.host-code = 0
                                        and ub.recipe.obj-type = ""
                                        and ub.recipe.obj-code = 0
                                    )
                                                            use-index recipe-name,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop ="local" then do :
                open query br-recipe
                for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                        each ub.recipe no-lock
                        where ub.recipe.recipe-name begins nameorcode
                                and ( ub.recipe.host-code = v-host-code
                                        and ub.recipe.obj-type = p-store-type
                                        and ub.recipe.obj-code = p-store-code
                                    )
                                                            use-index recipe-name,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
           end.
           else do :
             if recipeprop = "all" then do :
           open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                    each ub.recipe no-lock
                    where  ub.recipe.artic = b-goods.artic and
                            ub.recipe.prod-type = b-goods.prod-type and
                            ub.recipe.prod-code = b-goods.prod-code and
                            ub.recipe.recipe-name begins nameorcode
                            and ( ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                ) or ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                    ) )
                        use-index recipe-name,
                       first ub.goods no-lock where recid(ub.goods) = p-goods-recid ,
                       first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                           ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "global" then do :
               open query br-recipe
               for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                       each ub.recipe no-lock
                       where  ub.recipe.artic = b-goods.artic and
                               ub.recipe.prod-type = b-goods.prod-type and
                               ub.recipe.prod-code = b-goods.prod-code and
                               ub.recipe.recipe-name begins nameorcode
                               and ( ub.recipe.host-code = 0
                                     and ub.recipe.obj-type = ""
                                     and ub.recipe.obj-code = 0
                                    )
                           use-index recipe-name,
                       first ub.goods no-lock where recid(ub.goods) = p-goods-recid ,
                       first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                           ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "local" then do :
               open query br-recipe
               for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                       each ub.recipe no-lock
                       where  ub.recipe.artic = b-goods.artic and
                               ub.recipe.prod-type = b-goods.prod-type and
                               ub.recipe.prod-code = b-goods.prod-code and
                               ub.recipe.recipe-name begins nameorcode
                               and ( ub.recipe.host-code = v-host-code
                                       and ub.recipe.obj-type = p-store-type
                                       and ub.recipe.obj-code = p-store-code
                                       )
                           use-index recipe-name,
                       first ub.goods no-lock where recid(ub.goods) = p-goods-recid ,
                       first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
           end.
        end.
        when "recipe-gds":u then do:
          if p-goods-recid <> ? then do :
            if recipeprop ="all" then do :
           open query br-recipe
              for each ub.recipe-gds no-lock where
                ub.recipe-gds.artic = b-goods.artic and
                ub.recipe-gds.prod-type = b-goods.prod-type and
                ub.recipe-gds.prod-code = b-goods.prod-code,
                first ub.recipe no-lock where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                                                                    ub.recipe.recipe-name begins nameorcode
                        and ( ( ub.recipe.host-code = 0
                                and ub.recipe.obj-type = ""
                                and ub.recipe.obj-code = 0
                            ) or ( ub.recipe.host-code = v-host-code
                                and ub.recipe.obj-type = p-store-type
                                and ub.recipe.obj-code = p-store-code
                             ) )
                    use-index gds,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop ="global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                ub.recipe-gds.artic = b-goods.artic and
                ub.recipe-gds.prod-type = b-goods.prod-type and
                ub.recipe-gds.prod-code = b-goods.prod-code,
                first ub.recipe no-lock where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                                                                    ub.recipe.recipe-name begins nameorcode
                        and ( ub.recipe.host-code = 0
                                and ub.recipe.obj-type = ""
                                and ub.recipe.obj-code = 0
                            )
                        use-index gds,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop ="local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                ub.recipe-gds.artic = b-goods.artic and
                ub.recipe-gds.prod-type = b-goods.prod-type and
                ub.recipe-gds.prod-code = b-goods.prod-code,
                first ub.recipe no-lock where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                                                                    ub.recipe.recipe-name begins nameorcode
                        and ( ub.recipe.host-code = v-host-code
                                and ub.recipe.obj-type = p-store-type
                                and ub.recipe.obj-code = p-store-code
                                )
                        use-index gds,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
          end.
        end.
      end case.                            /*end of find - name*/
    end.
    when "number":u then do:
      case table-find:
        when "recipe":u then do:
           if p-goods-recid = ? then do :
             if recipeprop = "all" then do :
           open query br-recipe
                for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                        each ub.recipe no-lock
                        where ub.recipe.recipe-code begins nameorcode
                                and ( ( ub.recipe.host-code = 0
                                        and ub.recipe.obj-type = ""
                                        and ub.recipe.obj-code = 0
                                    ) or ( ub.recipe.host-code = v-host-code
                                        and ub.recipe.obj-type = p-store-type
                                        and ub.recipe.obj-code = p-store-code
                                    ) )
                                                        use-index pi,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "global" then do :
              open query br-recipe
                for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                        each ub.recipe no-lock
                        where ub.recipe.recipe-code begins nameorcode
                                and ( ub.recipe.host-code = 0
                                        and ub.recipe.obj-type = ""
                                        and ub.recipe.obj-code = 0
                                    )
                                                            use-index pi,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "local" then do :
              open query br-recipe
                for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                        each ub.recipe no-lock
                        where ub.recipe.recipe-code begins nameorcode
                                and ( ub.recipe.host-code = v-host-code
                                        and ub.recipe.obj-type = p-store-type
                                        and ub.recipe.obj-code = p-store-code
                                        )
                                                            use-index pi,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
           end.
           else do :
             if recipeprop = "all" then do :
           open query br-recipe
              for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                      each ub.recipe no-lock
                      where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code begins nameorcode
                              and ( ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  ) or ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                    ) )
                                                        use-index pi,
                      first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                      each ub.recipe no-lock
                      where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code begins nameorcode
                              and ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  )
                                                          use-index pi,
                      first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                      each ub.recipe no-lock
                      where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code begins nameorcode
                              and ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                      )
                                                          use-index pi,
                      first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
           end.
        end.
        when "recipe-gds":u then do:
          if p-goods-recid <> ? then do :
            if recipeprop = "all" then do :
           open query br-recipe
              for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                      first ub.recipe no-lock
                      where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                          ub.recipe.recipe-code  begins nameorcode
                              and ( ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  ) or ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                    ) )
                        use-index pi,
                      first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                        ub.goods.prod-type = ub.recipe.prod-type and
                                                        ub.goods.prod-code = ub.recipe.prod-code no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop = "global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                      first ub.recipe no-lock
                      where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                          ub.recipe.recipe-code  begins nameorcode
                              and ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  )
                          use-index pi,
                      first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                        ub.goods.prod-type = ub.recipe.prod-type and
                                                        ub.goods.prod-code = ub.recipe.prod-code no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop = "local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                      first ub.recipe no-lock
                      where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                          ub.recipe.recipe-code  begins nameorcode
                              and ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                      )
                          use-index pi,
                      first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                        ub.goods.prod-type = ub.recipe.prod-type and
                                                        ub.goods.prod-code = ub.recipe.prod-code no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
          end.
        end.
      end case.                            /*end of find - number*/
    end.
    when "article":u then do:
      case table-find:
      when "recipe":u then
      if p-goods-recid = ? then do :
        if recipeprop = "all" then do :
      open query br-recipe
          for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                  each ub.recipe no-lock
                      where ub.recipe.artic begins nameorcode
                          and ( ( ub.recipe.host-code = 0
                                  and ub.recipe.obj-type = ""
                                  and ub.recipe.obj-code = 0
                              ) or ( ub.recipe.host-code = v-host-code
                                  and ub.recipe.obj-type = p-store-type
                                  and ub.recipe.obj-code = p-store-code
                                  ) )
                                                      use-index gds,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                     ub.goods.prod-type = ub.recipe.prod-type and
                                                     ub.goods.prod-code = ub.recipe.prod-code
                                                     no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                      ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
        if recipeprop = "global" then do :
          open query br-recipe
          for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                  each ub.recipe no-lock
                      where ub.recipe.artic begins nameorcode
                          and ( ub.recipe.host-code = 0
                                  and ub.recipe.obj-type = ""
                                  and ub.recipe.obj-code = 0
                              )
                                                      use-index gds,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                     ub.goods.prod-type = ub.recipe.prod-type and
                                                     ub.goods.prod-code = ub.recipe.prod-code
                                                     no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                      ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
        if recipeprop = "local" then do :
          open query br-recipe
          for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                  each ub.recipe no-lock
                      where ub.recipe.artic begins nameorcode
                          and ( ub.recipe.host-code = v-host-code
                                  and ub.recipe.obj-type = p-store-type
                                  and ub.recipe.obj-code = p-store-code
                                  )
                                                      use-index gds,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                     ub.goods.prod-type = ub.recipe.prod-type and
                                                     ub.goods.prod-code = ub.recipe.prod-code
                                                     no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                      ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
      end.
        when  "recipe-gds":u then do:
      if p-goods-recid <> ? then do :
        if recipeprop = "all" then do :
       open query br-recipe
          for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                  first ub.recipe no-lock
                  where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                    and ub.recipe.artic begins nameorcode
                              and ( ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  ) or ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                  ) )
                 use-index pi,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
        if recipeprop = "global" then do :
          open query br-recipe
          for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                  first ub.recipe no-lock
                  where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                    and ub.recipe.artic begins nameorcode
                              and ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  )
                    use-index pi,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
        if recipeprop = "local" then do :
          open query br-recipe
          for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                  first ub.recipe no-lock
                  where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                    and ub.recipe.artic begins nameorcode
                              and ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                      )
                    use-index pi,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
      end.
         end . /*when recipe-gds*/
       end case.                            /*end of find - article*/
    end.
    when "goods":u then do:
      case table-find:
      when "recipe":u then do:
        if p-goods-recid = ? then do :
          if recipeprop = "all" then do :
        open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                    each ub.recipe no-lock
                            where ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                ) or ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                )
                use-index pi,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code and
                                                      ub.goods.gds-name begins nameorcode
                                                   no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
          if recipeprop = "global" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                    each ub.recipe no-lock
                            where ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                )
                    use-index pi,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code and
                                                      ub.goods.gds-name begins nameorcode
                                                      no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
          if recipeprop = "local" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                    each ub.recipe no-lock
                            where ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                    )
                    use-index pi,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code and
                                                      ub.goods.gds-name begins nameorcode
                                                      no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
        end.
      end.
      when "recipe-gds":u then do:
        if p-goods-recid <> ? then do :
          if recipeprop = "all" then do :
        open query br-recipe
            for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                    first ub.recipe no-lock
                    where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                            and ( ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                ) or ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                 ) ) ,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  and
                                                      ub.goods.gds-name begins nameorcode no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
          if recipeprop = "global" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                    first ub.recipe no-lock
                    where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                            and ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                ) ,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  and
                                                      ub.goods.gds-name begins nameorcode no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
          if recipeprop = "local" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                    first ub.recipe no-lock
                    where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                            and ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                    ) ,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  and
                                                      ub.goods.gds-name begins nameorcode no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
        end.
      end.
      end case.                              /*end of find - goods*/
    end.
  end case . /*end recipetype - all*/
end.
else do:
  case find-by :
      when "all":u then
              case table-find:
              when "recipe":u then do:
                  if p-goods-recid = ? then do :
                    if recipeprop ="all" then do :
                  open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.recipe-type = recipetype
                              and ( ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  ) or ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                          ) )
                                  use-index gds,
                              first ub.goods where
                                                          ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                       ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop ="global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.recipe-type = recipetype
                              and ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  )
                              use-index gds,
                              first ub.goods where
                                                          ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                       ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop ="local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.recipe-type = recipetype
                              and ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                      )
                              use-index gds,
                              first ub.goods where
                                                          ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                       ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                  end.
                  else do :
                    if recipeprop = "all" then do :
                  open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic = b-goods.artic and
                                  ub.recipe.prod-type = b-goods.prod-type and
                                  ub.recipe.prod-code = b-goods.prod-code and
                                  ub.recipe.recipe-type = recipetype
                                  and ( ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      ) or ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          ) )
                                                             use-index gds,
                              first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic = b-goods.artic and
                                  ub.recipe.prod-type = b-goods.prod-type and
                                  ub.recipe.prod-code = b-goods.prod-code and
                                  ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      )
                                                             use-index gds,
                              first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic = b-goods.artic and
                                  ub.recipe.prod-type = b-goods.prod-type and
                                  ub.recipe.prod-code = b-goods.prod-code and
                                  ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          )
                                                             use-index gds,
                              first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                  end.
              end.        /*when recipe*/
              when "recipe-gds":u then do: /*может быть только для p-goods-recid <> ?*/
                  if p-goods-recid <> ? then do :
                    if recipeprop = "all" then do :
                  open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                        ub.recipe-gds.artic = b-goods.artic and
                                                                        ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                        ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                                and ub.recipe.recipe-type = recipetype
                                      and ( ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          ) or ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                          ) )
                                                                            use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                  ub.goods.prod-type = ub.recipe.prod-type and
                                                                  ub.goods.prod-code = ub.recipe.prod-code no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                        ub.recipe-gds.artic = b-goods.artic and
                                                                        ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                        ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                                and ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          )
                                                                                use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                  ub.goods.prod-type = ub.recipe.prod-type and
                                                                  ub.goods.prod-code = ub.recipe.prod-code no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                        ub.recipe-gds.artic = b-goods.artic and
                                                                        ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                        ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                                and ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                              )
                                                                                use-index gds,
                          first goods where goods.artic = recipe.artic and
                                                              goods.prod-type = recipe.prod-type and
                                                              goods.prod-code = recipe.prod-code no-lock,
                          first clients where clients.obj-type = recipe.prod-type and
                                                              clients.obj-code = recipe.prod-code no-lock.
                    end.
                  end.
              end. /*when recipe-gds*/
              end case.                                                       /*end of find - all*/
      when "name":u then
              case table-find:
              when "recipe":u then do:
                 if p-goods-recid = ? then do :
                   if recipeprop = "all" then do :
                  open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.recipe-name begins nameorcode
                               and ub.recipe.recipe-type = recipetype
                                     and ( ( ub.recipe.host-code = 0
                                             and ub.recipe.obj-type = ""
                                             and ub.recipe.obj-code = 0
                                         ) or ( ub.recipe.host-code = v-host-code
                                             and ub.recipe.obj-type = p-store-type
                                             and ub.recipe.obj-code = p-store-code
                                          ) )
                                                         use-index recipe-name,
                             first ub.goods where
                                                               ub.goods.artic = ub.recipe.artic and
                                                               ub.goods.prod-type = ub.recipe.prod-type and
                                                               ub.goods.prod-code = ub.recipe.prod-code no-lock,
                             first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                   if recipeprop = "global" then do :
                     open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.recipe-name begins nameorcode
                               and ub.recipe.recipe-type = recipetype
                                     and ( ub.recipe.host-code = 0
                                             and ub.recipe.obj-type = ""
                                             and ub.recipe.obj-code = 0
                                         )
                                                           use-index recipe-name,
                             first ub.goods where
                                                               ub.goods.artic = ub.recipe.artic and
                                                               ub.goods.prod-type = ub.recipe.prod-type and
                                                               ub.goods.prod-code = ub.recipe.prod-code no-lock,
                             first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                   if recipeprop = "local" then do :
                     open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.recipe-name begins nameorcode
                               and ub.recipe.recipe-type = recipetype
                                     and ( ub.recipe.host-code = v-host-code
                                             and ub.recipe.obj-type = p-store-type
                                             and ub.recipe.obj-code = p-store-code
                                             )
                                                           use-index recipe-name,
                             first ub.goods where
                                                               ub.goods.artic = ub.recipe.artic and
                                                               ub.goods.prod-type = ub.recipe.prod-type and
                                                               ub.goods.prod-code = ub.recipe.prod-code no-lock,
                             first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                 end.
                 else do :
                   if recipeprop = "all" then do :
                 open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.artic = b-goods.artic and
                                   ub.recipe.prod-type = b-goods.prod-type and
                                   ub.recipe.prod-code = b-goods.prod-code and
                                   ub.recipe.recipe-name begins nameorcode and
                                   ub.recipe.recipe-type = recipetype
                                       and ( ( ub.recipe.host-code = 0
                                               and ub.recipe.obj-type = ""
                                               and ub.recipe.obj-code = 0
                                           ) or ( ub.recipe.host-code = v-host-code
                                               and ub.recipe.obj-type = p-store-type
                                               and ub.recipe.obj-code = p-store-code
                                          ) )
                          use-index recipe-name,
                               first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                               first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                   if recipeprop = "global" then do :
                     open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.artic = b-goods.artic and
                                   ub.recipe.prod-type = b-goods.prod-type and
                                   ub.recipe.prod-code = b-goods.prod-code and
                                   ub.recipe.recipe-name begins nameorcode and
                                   ub.recipe.recipe-type = recipetype
                                       and ( ub.recipe.host-code = 0
                                               and ub.recipe.obj-type = ""
                                               and ub.recipe.obj-code = 0
                                           )
                               use-index recipe-name,
                               first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                               first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                   if recipeprop = "local" then do :
                     open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.artic = b-goods.artic and
                                   ub.recipe.prod-type = b-goods.prod-type and
                                   ub.recipe.prod-code = b-goods.prod-code and
                                   ub.recipe.recipe-name begins nameorcode and
                                   ub.recipe.recipe-type = recipetype
                                       and ( ub.recipe.host-code = v-host-code
                                               and ub.recipe.obj-type = p-store-type
                                               and ub.recipe.obj-code = p-store-code
                                               )
                               use-index recipe-name,
                               first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                               first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                 end.
              end.
              when "recipe-gds":u then do:
               if p-goods-recid <> ? then do :
                 if recipeprop = "all" then do :
                 open query br-recipe
                   for each ub.recipe-gds no-lock where
                                                                     ub.recipe-gds.artic = b-goods.artic and
                                                                     ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                     ub.recipe-gds.prod-code = b-goods.prod-code,
                         first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                              ub.recipe.recipe-name begins nameorcode and
                              ub.recipe.recipe-type = recipetype
                                  and ( ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      ) or ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          ) )
                         use-index gds,
                         first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                             ub.goods.prod-type = ub.recipe.prod-type and
                                                             ub.goods.prod-code = ub.recipe.prod-code no-lock,
                         first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                 end.
                 if recipeprop = "global" then do :
                   open query br-recipe
                   for each ub.recipe-gds no-lock where
                                                                     ub.recipe-gds.artic = b-goods.artic and
                                                                     ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                     ub.recipe-gds.prod-code = b-goods.prod-code,
                         first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                              ub.recipe.recipe-name begins nameorcode and
                              ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      )
                         use-index gds,
                         first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                             ub.goods.prod-type = ub.recipe.prod-type and
                                                             ub.goods.prod-code = ub.recipe.prod-code no-lock,
                         first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                 end.
                 if recipeprop = "local" then do :
                   open query br-recipe
                   for each ub.recipe-gds no-lock where
                                                                     ub.recipe-gds.artic = b-goods.artic and
                                                                     ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                     ub.recipe-gds.prod-code = b-goods.prod-code,
                         first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                              ub.recipe.recipe-name begins nameorcode and
                              ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          )
                         use-index gds,
                         first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                             ub.goods.prod-type = ub.recipe.prod-type and
                                                             ub.goods.prod-code = ub.recipe.prod-code no-lock,
                         first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                 end.
               end.
              end.
              end case.                            /*end of find - name*/
      when "number":u then
          case table-find:
              when "recipe":u then do:
              if p-goods-recid = ? then do :
                if recipeprop = "all" then do :
              open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.recipe-code = nameorcode
                            and ub.recipe.recipe-type = recipetype
                                      and ( ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          ) or ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                          ) )
                        use-index pi,
                          first ub.goods where
                                                                ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                             no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
                if recipeprop = "global" then do :
                  open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.recipe-code = nameorcode
                            and ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          )
                            use-index pi,
                          first ub.goods where
                                                                ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                                no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
                if recipeprop = "local" then do :
              open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.recipe-code = nameorcode
                            and ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                              )
                            use-index pi,
                          first ub.goods where
                                                                ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                                no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
              end.
              else do :
                if recipeprop ="all" then do :
                  open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code = nameorcode and
                              ub.recipe.recipe-type = recipetype
                                      and ( ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          ) or ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                          ) )
                                                         use-index pi,
                          first ub.goods where recid(ub.goods) = p-goods-recid  no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
                if recipeprop ="global" then do :
                  open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code = nameorcode and
                              ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          )
                                                            use-index pi,
                          first ub.goods where recid(ub.goods) = p-goods-recid  no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
                if recipeprop ="local" then do :
                  open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code = nameorcode and
                              ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                              )
                                                            use-index pi,
                          first ub.goods where recid(ub.goods) = p-goods-recid  no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
              end.
              end.
              when "recipe-gds":u then do:
                if p-goods-recid <> ? then do:
                  if recipeprop = "all" then do :
                  open query br-recipe
                    for each ub.recipe-gds no-lock where
                      ub.recipe-gds.artic = b-goods.artic and
                      ub.recipe-gds.prod-type = b-goods.prod-type and
                      ub.recipe-gds.prod-code = b-goods.prod-code,
                          first ub.recipe no-lock
                          where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                            ub.recipe.recipe-code = nameorcode and
                                                                            ub.recipe.recipe-type = recipetype
                                  and ( ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      ) or ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                        ) )
                                                                           use-index pi,
                          first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                              ub.goods.prod-type = ub.recipe.prod-type and
                                                              ub.goods.prod-code = ub.recipe.prod-code no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                  end.
                  if recipeprop = "global" then do :
                    open query br-recipe
                    for each ub.recipe-gds no-lock where
                      ub.recipe-gds.artic = b-goods.artic and
                      ub.recipe-gds.prod-type = b-goods.prod-type and
                      ub.recipe-gds.prod-code = b-goods.prod-code,
                          first ub.recipe no-lock
                          where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                            ub.recipe.recipe-code = nameorcode and
                                                                            ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      )
                                                                            use-index pi,
                          first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                              ub.goods.prod-type = ub.recipe.prod-type and
                                                              ub.goods.prod-code = ub.recipe.prod-code no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                  end.
                  if recipeprop = "local" then do :
                    open query br-recipe
                    for each ub.recipe-gds no-lock where
                      ub.recipe-gds.artic = b-goods.artic and
                      ub.recipe-gds.prod-type = b-goods.prod-type and
                      ub.recipe-gds.prod-code = b-goods.prod-code,
                          first ub.recipe no-lock
                          where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                            ub.recipe.recipe-code = nameorcode and
                                                                            ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          )
                                                                            use-index pi,
                          first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                              ub.goods.prod-type = ub.recipe.prod-type and
                                                              ub.goods.prod-code = ub.recipe.prod-code no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                  end.
                end.
              end.
          end case.                                       /*end of find - number*/
      when "article":u then
              case table-find:
              when "recipe":u then do:
                  if p-goods-recid = ? then do :
                    if recipeprop = "all" then do :
                  open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic begins nameorcode and
                                                                ub.recipe.recipe-type = recipetype
                                      and ( ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          ) or ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                          ) )
                                                             use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                             no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic begins nameorcode and
                                                                ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          )
                                                                use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                                no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic begins nameorcode and
                                                                ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                              )
                                                                use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                                no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                  end.
                end. /*when recipe*/
                when  "recipe-gds":u then do:
                  if p-goods-recid <> ? then do :
                    if recipeprop = "all" then do :
                    open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                      ub.recipe-gds.artic = b-goods.artic and
                                                                      ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                      ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                              ub.recipe.recipe-type = recipetype and
                                                                              ub.recipe.artic begins nameorcode
                                    and ( ( ub.recipe.host-code = 0
                                            and ub.recipe.obj-type = ""
                                            and ub.recipe.obj-code = 0
                                        ) or ( ub.recipe.host-code = v-host-code
                                            and ub.recipe.obj-type = p-store-type
                                            and ub.recipe.obj-code = p-store-code
                                          ) )
                                                                            use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                  ub.goods.prod-type = ub.recipe.prod-type and
                                                                  ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                      ub.recipe-gds.artic = b-goods.artic and
                                                                      ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                      ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                              ub.recipe.recipe-type = recipetype and
                                                                              ub.recipe.artic begins nameorcode
                                    and ( ub.recipe.host-code = 0
                                            and ub.recipe.obj-type = ""
                                            and ub.recipe.obj-code = 0
                                        )
                                                                              use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                  ub.goods.prod-type = ub.recipe.prod-type and
                                                                  ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                      ub.recipe-gds.artic = b-goods.artic and
                                                                      ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                      ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                              ub.recipe.recipe-type = recipetype and
                                                                              ub.recipe.artic begins nameorcode
                                    and ( ub.recipe.host-code = v-host-code
                                            and ub.recipe.obj-type = p-store-type
                                            and ub.recipe.obj-code = p-store-code
                                            )
                                                                              use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                  ub.goods.prod-type = ub.recipe.prod-type and
                                                                  ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                  end.
                  end. /*when recipe-gds*/
              end case.                            /*end of find - article*/
      when "goods":u then
          case table-find:
              when "recipe":u then do :
                  if p-goods-recid = ? then do :
                    if recipeprop = "all" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where recid( ub.recipe-gds ) = v-recipe-gds-recid
                        , each ub.recipe no-lock
                         where ub.recipe.recipe-type = recipetype
                                  and ( ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      ) or ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          ) )
                          use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                      .
                  end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where recid( ub.recipe-gds ) = v-recipe-gds-recid
                        , each ub.recipe no-lock
                         where ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      )
                          use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                      .
              end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where recid( ub.recipe-gds ) = v-recipe-gds-recid
                        , each ub.recipe no-lock
                         where ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          )
                          use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                      .
                    end.
                  end.
              end.
              when "recipe-gds":u then do :
                  if p-goods-recid <> ? then do :
                    if recipeprop = "all" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where ub.recipe-gds.artic      = b-goods.artic
                           and ub.recipe-gds.prod-type  = b-goods.prod-type
                           and ub.recipe-gds.prod-code  = b-goods.prod-code
                       , first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                           and ub.recipe.recipe-type = recipetype
                                  and ( ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      ) or ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          ) )
                         use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                       .
                  end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where ub.recipe-gds.artic      = b-goods.artic
                           and ub.recipe-gds.prod-type  = b-goods.prod-type
                           and ub.recipe-gds.prod-code  = b-goods.prod-code
                       , first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                           and ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      )
                         use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                       .
                    end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where ub.recipe-gds.artic      = b-goods.artic
                           and ub.recipe-gds.prod-type  = b-goods.prod-type
                           and ub.recipe-gds.prod-code  = b-goods.prod-code
                       , first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                           and ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          )
                         use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                       .
                    end.
                  end.
               end. /*when recipe-gds*/
          end case.                                       /*end of find - goods*/
  end case . /*end recipetype - один тип*/
end.
{ gbl/stopwork.i }
apply "value-changed" to br-recipe in frame {&frame-name}.
apply "entry" to br-recipe in frame {&frame-name}.
return no-apply.
end procedure.

procedure disable_ui :
  hide frame dialog-frame.
end procedure.

procedure enable_ui :
  define variable v-obj-is-active    as logical        no-undo.
  define variable v-have-rights      as logical        no-undo.
do
on error undo, return error
:
    { gbl/objat.i
        p-store-type
        p-store-code
        "'active=request'"
        v-obj-is-active
    no-error }
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Не удалось определить активность объекта."
            skip "Объект" v-cntxt-obj-type v-cntxt-obj-code
            skip return-value
            skip error-status :get-message(1)
        view-as alert-box error .
        undo, return error .
    end.
    if can-do( bttns, "b-add" )
    and can-do( "all":u, find-by )
    and can-do( "all":u, recipetype )
    /*  and not transaction*/
    /*  and g#db-num = 0*/
    and v-obj-is-active = yes
    then do:
        enable
            b-add /*when p-goods-recid <> ?*/
            b-del when not can-do (bttns, "nb-del")
            b-chg when not can-do (bttns, "nb-chg")
            b-copy when not can-do (bttns, "nb-copy")
            b-set-default when p-goods-recid <> ?
            b-down when p-goods-recid <> ?
            b-up when p-goods-recid <> ?
        with frame {&frame-name}.
    end.
    else do:
        if can-do( "all":u, find-by )
        and can-do( "all":u, recipetype )
        and v-obj-is-active = yes
        then do:
            enable
                b-set-default when p-goods-recid <> ?
                b-down when p-goods-recid <> ?
                b-up when p-goods-recid <> ?
            with frame {&frame-name}.
        end.
        else do:
            disable
                b-add
                b-del
                b-chg
                b-copy
                b-set-default
                b-down
                b-up
            with frame {&frame-name}.
        end.
    end.
    enable
        br-recipe
        b-lkp
        b-exit
        b-sel when can-do(  bttns, "b-sel" )
        recipetype
        recipeprop
        find-by
        nameorcode
        table-find
        b-print
        b-hist
        b-help
    with frame dialog-frame.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_recipe-reference_view_global':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      v-have-rights
    }
    if not v-have-rights
    then do :
      recipeprop :disable ( radio-label("all",recipeprop :radio-buttons ) ) .
      recipeprop :disable ( radio-label("global",recipeprop :radio-buttons ) ) .
      recipeprop = "local" .
    end.
    if p-goods-recid <> ?
    and lookup( {&weight}, ub.units.type ) > 0
    then do:
        if call-mode = {&gathering}
        then do:
            disable
                recipetype
            with frame {&frame-name}.
            assign
                menu-item m-type-1:label in menu m-types = "":U
            .
        end.
        else do:
            assign
                g#log = recipetype :disable ( radio-label( {&gathering}, recipetype :radio-buttons ) )
                menu-item m-type-1 :label in menu m-types = "":U
            .
        end.
    end.
    if p-goods-recid <> ?
    and lookup({&petrolium}, ub.units.type) = 0
    then do:
        assign
            g#log = recipetype :disable ( radio-label( {&petrolium-manufacturing}, recipetype :radio-buttons ) )
            menu-item m-type-5 :label in menu m-types = "":U
        .
    end.
    if p-goods-recid = ?
    then do:
        assign
            table-find  = "recipe":U
            log-res     = table-find :disable ( radio-label( "recipe-gds":U, table-find :radio-buttons ) )
        .
    end.
    if p-goods-recid <> ?
    and not table-find = "recipe-gds":U
    then do:
        assign
            table-find = "recipe":U
        .
    end.
    display
        recipetype
        recipeprop
        table-find
    with frame {&frame-name}.
    view frame dialog-frame.
end.
end procedure.

procedure check-recipe-lock :
define input parameter p-recipe-code        as character    no-undo.
define output parameter p-lock-not-enabled  as logical      no-undo.

    define buffer buf_recipe        for ub.recipe.
do
for buf_recipe
on error undo, return error
:
    find first buf_recipe exclusive-lock
         where buf_recipe.recipe-code = p-recipe-code
    no-error no-wait.
    if not available buf_recipe
    then do:
        assign
            p-lock-not-enabled = yes
        .
    end.
end.
end procedure. /* check-recipe-lock */

procedure add-recipe :
/*------------------------------------------------------------------------------
  purpose:
  parameters:  <none>
  notes:
------------------------------------------------------------------------------*/
    define variable v-br-line-num       as integer      no-undo.
    define variable v-recipe-code       as character    no-undo.
    define variable v-yesno             as logical      no-undo.
    define variable v-is-menu           as logical      no-undo.
    define variable v-fbr-gds-obj-recid as recid        no-undo.
    define variable v-goods-recid       as recid        no-undo.
    define variable v-goods-recid-list  as character    no-undo.
  define variable v-value   as character    no-undo.
  define variable v-type    as character    no-undo.
    define buffer buf_goods         for ub.goods.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
    define buffer buf_recipe        for ub.recipe.
do
for buf_goods
  , buf_fbr-gds-obj
on error undo, return error
:
    if p-goods-recid = ?
    then do:
        run ref/gds-ref.p (
              input p-mainmenu-handle
            , input "b-sel"
            , input {&current}
            , input {&all}
            , input {&g___object}
            , input ?
            , input ?
            , input ?
            , input ?
            , input p-store-type
            , input p-store-code
            , input ?
            , output v-goods-recid-list
        ).
       if v-goods-recid-list <> ''
          then 
       do:
          assign
             v-goods-recid = integer( entry( 1, v-goods-recid-list ) )
             .
          if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .
          if v-ban-altr then 
          do:       
             if recipetype = {&alternative} or new-type = {&alternative} then 
             do:    
                for first ub.goods no-lock where recid (ub.goods) = v-goods-recid:
                   if check-ban-sales-via-cd(ub.goods.gds-code) then 
                   do:

                   end.
               end.
            end.
         end.
      end.
      else 
      do:
         message
            "Не выбран товар"
            skip 
            "для создания рецепта."
            view-as alert-box error.
         undo, return.
      end.
   end.
   else 
   do:
      assign
         v-goods-recid = p-goods-recid
         .
   end.
    find first buf_goods no-lock
         where recid( buf_goods ) = v-goods-recid
    .
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_recipe-reference_input-deletion-updating':U
        {&cntxt-object}
        v-host-code
        p-store-type
        p-store-code
        0
        0
        0
        yes
        v-yesno
        no-error
    }
    if error-status :error then do :
      message
        error-status :get-message(1)
      view-as alert-box information.
    end.
    if v-yesno <> yes
    then do:
        undo, return error .
    end.
    if recipetype <> "all"
    then do:
        assign
            new-type = recipetype
        .
    end.
    else if new-type = ""
    then do:
        run gbl/pop-up.p (
              input self:handle
            , input no
        ) no-error.
      if error-status:error
      then do:
          return.
      end.
    end.
    do transaction
    on error undo, return error
    :
        find first buf_fbr-gds-obj exclusive-lock
             where buf_fbr-gds-obj.obj-type = p-store-type
               and buf_fbr-gds-obj.obj-code = p-store-code
               and buf_fbr-gds-obj.gds-code = buf_goods.gds-code
        no-error.
        if new-type = {&manufacturing}
        and ( not available buf_fbr-gds-obj
                    or ( buf_fbr-gds-obj.is-menu = no
                        and buf_fbr-gds-obj.is-semi-finished = no ) )
        and p-store-type = {&shop}
        then do:
            message
                "Рецепт производства можно создать только для товара"
                skip "с атрибутом блюдо или полуфабрикат."
                skip (1)
                skip "Поэтому будет создан атрибут товара:"
                skip (1)
                skip "Да - блюдо"
                skip "Нет  - полуфабрикат"
                skip "Отмена - отменить добавление рецепта"
                skip (1)
                skip "Выберите значение атрибута."
            view-as alert-box question
            buttons yes-no-cancel
            title "Изменение атрибутов товара"
            update v-yesno.
            if v-yesno = ?
            then do:
                undo, return error .
            end.
            if v-yesno = yes
            then do:
                assign
                    v-is-menu = yes
                .
            end.        /* if v-yesno = yes */
            else do:
                assign
                    v-is-menu = no
                .
            end.        /* NOT ( if v-yesno = yes ) */
            if available buf_fbr-gds-obj
            then do:
                assign
                    buf_fbr-gds-obj.is-menu          = v-is-menu
                    buf_fbr-gds-obj.is-semi-finished = ( if v-is-menu = yes then no else yes )
                .
            end.        /* if available buf_fbr-gds-obj */
            else do:
                assign
                    v-fbr-gds-obj-recid = ?
                .
                run ref/fgdsobj1.p (
                      input-output v-fbr-gds-obj-recid
                    , input {&add-def}
                    , input no /*p-silent*/
                    , input buf_goods.gds-code
                    , input p-store-type
                    , input p-store-code
                    , input 0
                    , input p-store-type                                /* Тип объекта кухни */
                    , input p-store-code                                /* Код объекта кухни */
                    , input no                                          /* Отправлять на кассу ресторана */
                    , input v-is-menu                                   /* Является блюдом   */
                    , input no                                          /* Модификатор блюда */
                    , input no                                          /* Без цены */
                    , input no                                          /* Применять сезонный коэффициент */
                    , input ( if v-is-menu = yes then no else yes )     /* Является полуфабрикатом */
                ) no-error.
                if error-status:error
                then do:
                    message
                            vss-workfile vss-revision vss-description
                        skip "Ошибка изменения атрибутов товара на объекте"
                        skip return-value
                        skip trim(error-status :get-message(1))
                                trim(error-status :get-message(2))
                                trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.        /* NOT ( if available buf_fbr-gds-obj ) */
        end.        /* if new-type = {&manufacturing} */
    end.        /* do transaction */
    assign
        ri = ?
        v-can-set-global = true
    .
    run ref/recipe.w (
        input p-mainmenu-handle
        , input {&add-def}
        , input v-goods-recid
        , input new-type
        , input ""
        , input v-host-code
        , input p-store-type
        , input p-store-code
        , input ( v-cntxt-db-num = 0 )
        , input v-can-set-global
        , output v-recipe-code
    ) no-error.
    if error-status :error
    then do:
        message
                vss-workfile vss-revision vss-description
            skip "Ошибка при добавлении рецепта."
            skip return-value
            skip "Артикул товара:" buf_goods.artic
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    assign
        new-type = "":U
    .
    if v-recipe-code <> "":U
    then do:        /* ri = recid( recipe ) */
        run fbrlib-set-default-recipe in this-procedure (
              input p-store-type
            , input p-store-code
            , input buf_goods.gds-code
        ).
        run change-query .
        if table-find = "recipe":U
        then do:
            get first br-recipe no-lock.
            assign
                v-br-line-num = 1
            .
            if ub.recipe.recipe-code = v-recipe-code
            then do:
                reposition br-recipe to row 1 no-error.
            end.
            else do:
                do while available ub.recipe-gds
                :
                    get next br-recipe no-lock .
                    assign
                        v-br-line-num = v-br-line-num + 1
                    .
                    if ub.recipe.recipe-code = v-recipe-code
                    then do:
                        leave.
                    end.
                end.
            end.
            reposition br-recipe to row v-br-line-num no-error.
        end.
    end.
end.
end procedure. /* add-recipe */

procedure copy-recipe :
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-host-code          as integer      no-undo.
define input parameter p-store-type         as character    no-undo.
define input parameter p-store-code         as integer      no-undo.
define output parameter p-new-recipe-rowid  as rowid        no-undo.

    define buffer buf_recipe            for ub.recipe.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_copy_recipe       for ub.recipe.
    define buffer buf_copy_recipe-gds   for ub.recipe-gds.
do
for buf_recipe
  , buf_recipe-gds
  , buf_copy_recipe
  , buf_copy_recipe-gds
on error undo, return error
:
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    do transaction
    on error undo, return error
    :
        create buf_copy_recipe.
        buffer-copy buf_recipe
             except buf_recipe.recipe-code
                    buf_recipe.host-code
                    buf_recipe.obj-type
                    buf_recipe.obj-code
        to buf_copy_recipe.
        run fbrcode-gen-recipe-code in this-procedure (
              input p-store-type
            , input p-store-code
            , output buf_copy_recipe.recipe-code
        ).
        assign
            buf_copy_recipe.host-code = p-host-code
            buf_copy_recipe.obj-type  = p-store-type
            buf_copy_recipe.obj-code  = p-store-code
        .
        assign
            p-new-recipe-rowid        = rowid( buf_copy_recipe )
        .
    end.        /* do transaction */
    do transaction
    on error undo, return error
    :
        for each buf_recipe-gds no-lock
           where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
        :
            create buf_copy_recipe-gds.
            buffer-copy buf_recipe-gds
            except buf_recipe-gds.recipe-code
            to buf_copy_recipe-gds.
            assign
                buf_copy_recipe-gds.recipe-code = buf_copy_recipe.recipe-code
            .
        end.
    end.        /* do transaction */
end.
end procedure. /* copy-recipe */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-default-recipe {&FRAME-NAME}
PROCEDURE set-default-recipe :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-recipe-code    as character    no-undo.

    define variable v-gds-code    as integer      no-undo.

    define buffer buf_recipe    for ub.recipe.
    define buffer buf_fbr-gds-obj       for ub.fbr-gds-obj.

do
for buf_recipe
  , buf_fbr-gds-obj
on error undo, return error
:
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    { gbl/gds-code.i
        buf_recipe.artic
        buf_recipe.prod-type
        buf_recipe.prod-code
        v-gds-code
    }
    run fbrlib-set-default-recipe in this-procedure (
          input p-store-type
        , input p-store-code
        , input v-gds-code
    ).
    for each buf_fbr-gds-obj exclusive-lock
       where buf_fbr-gds-obj.obj-type = p-store-type
         and buf_fbr-gds-obj.obj-code = p-store-code
         and buf_fbr-gds-obj.gds-code = v-gds-code
    on error undo, return error
    :
        assign
            buf_fbr-gds-obj.default-recipe-code = p-recipe-code
        .
    end.        /* for each buf_recipe */
end.
END PROCEDURE. /* set-default-recipe */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

