/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции расчета калорийности в производстве

Автор: Хныкин Павел Андреевич
Дата создания: 09/09/09
Author: Pavel Khnykin
Creation date: 09/09/09

Required:
  gbl/getcntxt.i
  ref/gds-attr.i
  ref/gdsoattr.i

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

/*
  Проверка является ли рецепт глобальным
*/
function fbrnutro_is-global-recipe RETURNS logical
  ( input p-recipe-code as character
  )
:
  define variable v-is-global-recipe as logical   no-undo .

  run fbrnutro_proc-is-global-recipe in this-procedure ( input p-recipe-code
                                                       , output v-is-global-recipe
                                                       ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-is-global-recipe = no
    .
  end.
  return v-is-global-recipe .
end function.

/*
  Получение значения пищ. или эн. ценности ингридиента рецепта
  При невозможности вычислить возвращает - ?
*/
function fbrnutro_get-gds-recipe-nutrition-by-code returns decimal
  ( input p-recipe-code as character
  , input p-artic       as character
  , input p-prod-type   as character
  , input p-prod-code   as integer
  , input p-attr-code   as character
  )
:
  define variable v-nutro as decimal   no-undo .

  run fbrnutro_proc-get-gds-recipe-nutrition-by-code in this-procedure ( input  p-recipe-code
                                                                       , input  p-artic
                                                                       , input  p-prod-type
                                                                       , input  p-prod-code
                                                                       , input  p-attr-code
                                                                       , output v-nutro
                                                                       ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-nutro = ?
    .
  end.
  return v-nutro.
end function.

/*
  Получение значения пищ. или эн. ценности рецепта
  При невозможности вычислить возвращает - ?
*/
function fbrnutro_get-recipe-nutrition-by-code returns decimal
  ( input p-recipe-code as character
  , input p-artic       as character
  , input p-prod-type   as character
  , input p-prod-code   as integer
  , input p-attr-code   as character
  , input p-recipe-qnty as decimal
  )
:
  define variable v-nutro-value as decimal   no-undo .

  run fbrnutro_proc-get-recipe-nutrition-by-code in this-procedure ( input p-recipe-code
                                                                   , input p-artic
                                                                   , input p-prod-type
                                                                   , input p-prod-code
                                                                   , input p-attr-code
                                                                   , input p-recipe-qnty
                                                                   , output v-nutro-value
                                                                   ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-nutro-value = ?
    .
  end.
  return v-nutro-value.
END FUNCTION.



/*======================================================================================================================*/
procedure fbrnutro_proc-is-global-recipe :
  define input  parameter p-recipe-code       as character no-undo .
  define output parameter p-is-global-recipe  as logical   no-undo .

  define buffer buf_recipe    for ub.recipe .
do
on error undo, return error return-value
:
  find first buf_recipe no-lock
    where buf_recipe.recipe-code = p-recipe-code
  no-error .
  if not available buf_recipe
  then do:
    return . /* --->>>--- */
  end.

  assign
    p-is-global-recipe =  ( buf_recipe.host-code = 0    ) and
                          ( buf_recipe.obj-type  = "":U ) and
                          ( buf_recipe.obj-code  = 0    )
  .
end.

end procedure. /* fbrnutro_proc-is-global-recipe */

/*======================================================================================================================*/
/*
  Если рецепт локальный то ищем в атрибутах объекта
*/
procedure fbrnutro_proc-get-gds-recipe-nutrition-by-code :
  define input  parameter p-recipe-code as character no-undo .
  define input  parameter p-artic       as character no-undo .
  define input  parameter p-prod-type   as character no-undo .
  define input  parameter p-prod-code   as integer   no-undo .
  define input  parameter p-attr-code   as character no-undo .
  define output parameter p-nutro-value as decimal   no-undo .

  define buffer buf_goods       for ub.goods .
  define buffer buf_fbr-gds-obj for ub.fbr-gds-obj .

  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  define variable v-attr-code     as character no-undo .
  define variable v-nutro-value   as decimal   no-undo .
  define variable v-is-global     as logical   no-undo .
  define variable v-exist         as logical   no-undo .
  define variable v-is-fbr-gds    as logical   no-undo .

do
on error undo, return error return-value
:

&scop get-glob-attr run gds-attr-exist in this-procedure ( input  buf_goods.gds-code ~
                                                         , input  v-attr-code ~
                                                         , output v-exist ~
                                                         ) no-error . ~
                    if error-status :error = yes or  ~
                       v-exist = no ~
                    then do: ~
                      return . /* --->>>--- */ ~
                    end. ~
                    run gds-attr-value in this-procedure ( input  buf_goods.gds-code ~
                                                         , input  v-attr-code ~
                                                         , output v-attr-value ~
                                                         , output v-attr-type ~
                                                         ) no-error . ~
                    if error-status :error ~
                    then do: ~
                      return . /* --->>>--- */ ~
                    end. ~
                    assign ~
                      v-nutro-value = decimal( v-attr-value ) ~
                    no-error . ~
                    if error-status :error = yes ~
                    then do: ~
                      return . /* --->>>--- */ ~
                    end.

&scop get-obj-attr run gdsoattr-exist in this-procedure ( input buf_goods.gds-code ~
                                                        , input v-cntxt-obj-type ~
                                                        , input v-cntxt-obj-code ~
                                                        , input v-attr-code ~
                                                        , output v-exist ~
                                                        ) no-error . ~
                   if error-status :error = yes or ~
                      v-exist = no ~
                   then do: ~
                     return . /* --->>>--- */ ~
                   end. ~
                   run gdsoattr-value in this-procedure ( input  v-attr-code ~
                                                        , input  buf_goods.gds-code ~
                                                        , input v-cntxt-obj-type ~
                                                        , input v-cntxt-obj-code ~
                                                        , output v-attr-value ~
                                                        , output v-attr-type ~
                                                        ) no-error . ~
                   if error-status :error = yes ~
                   then do: ~
                     return . /* --->>>--- */ ~
                   end. ~
                   assign ~
                     v-nutro-value = decimal(v-attr-value) ~
                   no-error . ~
                   if error-status :error = yes ~
                   then do: ~
                     return . /* --->>>--- */ ~
                   end.


  assign
    p-nutro-value = ?
  .
  find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
  no-error .
  if not available buf_goods
  then do:
    return . /* --->>>--- */
  end.

  /* товар из производства ? */
  assign
    v-is-fbr-gds = no
  .
  find first buf_fbr-gds-obj no-lock
    where buf_fbr-gds-obj.obj-type = v-cntxt-obj-type
      and buf_fbr-gds-obj.obj-code = v-cntxt-obj-code
      and buf_fbr-gds-obj.gds-code = buf_goods.gds-code
  no-error .
  if available buf_fbr-gds-obj
  then do:
    if  buf_fbr-gds-obj.is-semi-finished or
        buf_fbr-gds-obj.is-menu
    then do:
      assign
        v-is-fbr-gds = yes
        v-is-global  = fbrnutro_is-global-recipe(buf_fbr-gds-obj.default-recipe-code)
      .
    end.
  end.

  /* если товар не полуфабрикат, то берем глобальные атрибуты */
  if v-is-fbr-gds = no
  then do:
    assign
      v-is-global = yes
    .
  end.


  case p-attr-code
  :
    when {&attr-calories}
    then do:
      if v-is-global = yes
      then do:
        assign
          v-attr-code = {&attr-calories}
        .
        {&get-glob-attr}
      end. /* if v-is-global = yes */
      else do:
        assign
          v-attr-code = {&attr-calories-o}
        .
        {&get-obj-attr}
      end.
    end.
    when {&attr-carbohydrate}
    then do:
      if v-is-global = yes
      then do:
        assign
          v-attr-code = {&attr-carbohydrate}
        .
        {&get-glob-attr}
      end. /* if v-is-global = yes */
      else do:
        assign
          v-attr-code = {&attr-carbohydrate-o}
        .
        {&get-obj-attr}
      end.
    end.
    when {&attr-fat}
    then do:
      if v-is-global = yes
      then do:
        assign
          v-attr-code = {&attr-fat}
        .
        {&get-glob-attr}
      end. /* if v-is-global = yes */
      else do:
        assign
          v-attr-code = {&attr-fat-o}
        .
        {&get-obj-attr}
      end.
    end.
    when {&attr-protein}
    then do:
      if v-is-global = yes
      then do:
        assign
          v-attr-code = {&attr-protein}
        .
        {&get-glob-attr}
      end. /* if v-is-global = yes */
      else do:
        assign
          v-attr-code = {&attr-protein-o}
        .
        {&get-obj-attr}
      end.
    end.
    otherwise do:
      return . /* --->>>--- */
    end.
  end case.
  assign
    p-nutro-value = v-nutro-value
  .
end.

end procedure. /* fbrnutro_proc-get-gds-recipe-nutrition-by-code */

/*======================================================================================================================*/
/*
  p-recipe-qnty - передается т.к. сохраняется в буффер только по выходу из рецепта
*/
procedure fbrnutro_proc-get-recipe-nutrition-by-code :
  define input  parameter p-recipe-code as character no-undo .
  define input  parameter p-artic       as character no-undo .
  define input  parameter p-prod-type   as character no-undo .
  define input  parameter p-prod-code   as integer   no-undo .
  define input  parameter p-attr-code   as character no-undo .
  define input  parameter p-recipe-qnty as decimal   no-undo .
  define output parameter p-nutro-value as decimal   no-undo .

  define buffer buf_goods          for ub.goods      .
  define buffer buf_units          for ub.units.
  define buffer buf_recipe-gds     for ub.recipe-gds .
  define buffer buf_recipe         for ub.recipe     .

  define variable v-attr-value        as character no-undo .
  define variable v-attr-type         as character no-undo .
  define variable v-nutro-ingr        as decimal   no-undo .
  define variable v-nutro             as decimal   no-undo .
  define variable v-is-global         as logical   no-undo .
  define variable v-line-weight       as decimal   no-undo .
  define variable v-tot-weight        as decimal   no-undo .
  define variable v-recipe-have-lines as logical   no-undo .
do
on error undo, return error return-value
:
  assign
    p-nutro-value = ?
  .

  if p-recipe-qnty = ? or
     p-recipe-qnty = 0
  then do:
    return . /* --->>>--- */
  end.

  if  p-recipe-code <> "":u
  and p-recipe-code <> ?
  then do:
    /* для глобального, вся цепочка - глобальная */
    find first buf_recipe no-lock
        where buf_recipe.recipe-code = p-recipe-code
          and buf_recipe.artic      = p-artic
          and buf_recipe.prod-type  = p-prod-type
          and buf_recipe.prod-code  = p-prod-code
    no-error .
    if available buf_recipe
    then do:
      /*
        Считаем ценность рецепта
        N(i) - ценность ингридиента i-й строки
        M(i) - масса ингридиента i-й строки
        Ценность рецепта ( на 100 гр) = СУММ(M(i)*N(i)) / ( Вес готового изделия )
      */
      _recipe-gds-cycle:
      for each buf_recipe-gds no-lock
        where buf_recipe-gds.recipe-code = p-recipe-code
      , first buf_goods no-lock
          where buf_goods.gds-code = buf_recipe-gds.gds-code
      , first buf_units no-lock
          where buf_units.unit-name = buf_goods.unit-base
      :
          assign
            v-recipe-have-lines = yes
            v-nutro-ingr = fbrnutro_get-gds-recipe-nutrition-by-code ( input p-recipe-code
                                                                     , input buf_recipe-gds.artic
                                                                     , input buf_recipe-gds.prod-type
                                                                     , input buf_recipe-gds.prod-code
                                                                     , input p-attr-code
                                                                     )
          .
          if v-nutro-ingr = ?
          then do:
            return . /* --->>>--- */
          end.
          /* для весового товара берем количество */
          if lookup({&weight}, buf_units.type) > 0
          then do:
            assign
              v-line-weight = buf_recipe-gds.qnty
            .
          end.
          /* для штучного товара рассчитываем исходя из веса указаного в карточке */
          else do:
            assign
              v-line-weight = buf_recipe-gds.qnty * buf_goods.wt-base
            .
          end.
          assign
            v-nutro       = v-nutro + ( v-nutro-ingr * v-line-weight )
            v-tot-weight  = v-tot-weight + v-line-weight
          .
      end. /* for each buf_recipe-gds no-lock */
      assign
        v-nutro = v-nutro / ( p-recipe-qnty )
      .
    end.
    else do:
      return . /* --->>>--- */
    end.
  end.
  else do:
    /* я пока не понял что это за ветка такая была ?  */
    return . /* --->>>--- */
  end.
  if v-recipe-have-lines = yes and
     v-tot-weight <> 0
  then do:
    assign
      p-nutro-value = v-nutro
    .
  end.
end.

end procedure. /* fbrnutro_proc-get-recipe-nutrition-by-code */


/*
Сохраняем атрибуты ПиЭц для рецепта
Если рецепт глобальный то в глобальные атрибуты товара иначе - по объекту
*/
procedure fbrnutro_proc-save-nutrition :
  define input  parameter p-recipe-code   as character no-undo .
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-calories      as decimal   no-undo .
  define input  parameter p-protein       as decimal   no-undo .
  define input  parameter p-carbohydrate  as decimal   no-undo .
  define input  parameter p-fat           as decimal   no-undo .

  define buffer buf_recipe    for ub.recipe.
  define buffer buf_goods     for ub.goods.

  define variable v-is-global as logical   no-undo .
  define variable v-attr-code as character no-undo .

do
on error undo, return error return-value
:

&scop ret-error if error-status :error = yes ~
                then do: ~
                  return error substitute( "Ошибка при сохранении атрибута &1&2&3&2&4&2&5" ~
                                         , v-attr-code ~
                                         , {&new-line} ~
                                         , return-value ~
                                         , error-status :get-message(1) ~
                                         , error-status :get-message(2) ~
                                         ) . ~
                end.

  find first buf_recipe no-lock
    where buf_recipe.recipe-code = p-recipe-code
  no-error .
  if not available buf_recipe
  then do:
    return error substitute( "Не найден рецепт с кодом &1" , p-recipe-code ). /* --->>>--- */
  end.

  find first buf_goods no-lock
    where buf_goods.artic     = p-artic
      and buf_goods.prod-type = p-prod-type
      and buf_goods.prod-code = p-prod-code
  no-error .
  if not available buf_goods
  then do:
    return error substitute( "Не найден товар &1 &2 &3"
                           , p-artic
                           , p-prod-type
                           , p-prod-code
                           ). /* --->>>--- */
  end.
  assign
    v-is-global = fbrnutro_is-global-recipe(p-recipe-code)
  .
  if v-is-global
  then do:
    assign
      v-attr-code = {&attr-carbohydrate}
    .
    run gds-attr-write in this-procedure ( input buf_goods.gds-code
                                         , input v-attr-code
                                         , input p-carbohydrate
                                         ) no-error .
    {&ret-error}
    assign
      v-attr-code = {&attr-fat}
    .
    run gds-attr-write in this-procedure ( input buf_goods.gds-code
                                         , input v-attr-code
                                         , input p-fat
                                         ) no-error .
    {&ret-error}
    assign
      v-attr-code = {&attr-protein}
    .
    run gds-attr-write in this-procedure ( input buf_goods.gds-code
                                         , input v-attr-code
                                         , input p-protein
                                         ) no-error .
    {&ret-error}
    assign
      v-attr-code = {&attr-calories}
    .
    run gds-attr-write in this-procedure ( input buf_goods.gds-code
                                         , input v-attr-code
                                         , input p-calories
                                         ) no-error .
    {&ret-error}
  end.
  else do:
    assign
      v-attr-code = {&attr-carbohydrate-o}
    .
    run gdsoattr-write in this-procedure ( input buf_goods.gds-code
                                         , input v-cntxt-obj-type
                                         , input v-cntxt-obj-code
                                         , input v-attr-code
                                         , input p-carbohydrate
                                         ) no-error .
    {&ret-error}
    assign
      v-attr-code = {&attr-fat-o}
    .
    run gdsoattr-write in this-procedure ( input buf_goods.gds-code
                                         , input v-cntxt-obj-type
                                         , input v-cntxt-obj-code
                                         , input v-attr-code
                                         , input p-fat
                                         ) no-error .
    {&ret-error}
    assign
      v-attr-code = {&attr-protein-o}
    .
    run gdsoattr-write in this-procedure ( input buf_goods.gds-code
                                         , input v-cntxt-obj-type
                                         , input v-cntxt-obj-code
                                         , input v-attr-code
                                         , input p-protein
                                         ) no-error .
    {&ret-error}
    assign
      v-attr-code = {&attr-calories-o}
    .
    run gdsoattr-write in this-procedure ( input buf_goods.gds-code
                                         , input v-cntxt-obj-type
                                         , input v-cntxt-obj-code
                                         , input v-attr-code
                                         , input p-calories
                                         ) no-error .
    {&ret-error}
  end.
end.

end procedure. /* fbrnutro_proc-save-nutrition */

/* $Workfile$ e n d */