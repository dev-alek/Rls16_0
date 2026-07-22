/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

‘ункции и процедуры св€занные с калорийностью

јвтор: ’ныкин ѕавел јндреевич
ƒата создани€: 09/17/09
Author: Pavel Khnykin
Creation date: 09/17/09

Required:
  gbl/getcntxt.i
  ref/gds-attr.i
  ref/gdsoattr.i

  ¬се процедуры и функции при невозможности найти или рассчитать ѕиЁц  возращают - ?

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

function nutro_get-carbohydrate returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-carbohydrate as decimal   no-undo .

  run nutro_proc-get-carbohydrate in this-procedure ( input p-artic
                                                    , input p-prod-type
                                                    , input p-prod-code
                                                    , input p-obj-type
                                                    , input p-obj-code
                                                    , output v-carbohydrate
                                                    ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-carbohydrate = ?
    .
  end.
  return v-carbohydrate.
end function.

function nutro_get-fat returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-fat as decimal   no-undo .

  run nutro_proc-get-fat in this-procedure ( input p-artic
                                           , input p-prod-type
                                           , input p-prod-code
                                           , input p-obj-type
                                           , input p-obj-code
                                           , output v-fat
                                           ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-fat = ?
    .
  end.
  return v-fat.
end function.

function nutro_get-protein returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-protein as decimal   no-undo .

  run nutro_proc-get-protein in this-procedure ( input p-artic
                                               , input p-prod-type
                                               , input p-prod-code
                                               , input p-obj-type
                                               , input p-obj-code
                                               , output v-protein
                                               ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-protein = ?
    .
  end.
  return v-protein.
end function.

function nutro_get-calories returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-calories as decimal   no-undo .

  run nutro_proc-get-calories in this-procedure ( input  p-artic
                                                , input  p-prod-type
                                                , input  p-prod-code
                                                , input p-obj-type
                                                , input p-obj-code
                                                , output v-calories
                                                ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-calories = ?
    .
  end.
  return v-calories.
end function.


/*======================================================================================================================*/
procedure nutro_proc-get-carbohydrate :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-carbohydrate  as decimal   no-undo .

  define buffer buf_goods    for ub.goods .

  define variable v-attr-value   as character no-undo .
  define variable v-attr-type    as character no-undo .

  define variable v-calories     as decimal   no-undo .
  define variable v-protein      as decimal   no-undo .
  define variable v-carbohydrate as decimal   no-undo .
  define variable v-fat          as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    p-carbohydrate = ?
  .

  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return . /* --->>>--- */
  end.
  assign
    p-carbohydrate = v-carbohydrate
  .
end.

end procedure. /* proc-get-carbohydrate */

/*======================================================================================================================*/
procedure nutro_proc-get-fat :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-fat           as decimal   no-undo .

  define buffer buf_goods    for ub.goods .

  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .


do
on error undo, return error return-value
:
  assign
    p-fat = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return . /* --->>>--- */
  end.
  assign
    p-fat = v-fat
  .
end.

end procedure. /* proc-get-fat */

/*======================================================================================================================*/
procedure nutro_proc-get-protein :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-protein       as decimal   no-undo .

  define buffer buf_goods    for ub.goods .

  define variable v-attr-value  as character no-undo .
  define variable v-attr-type   as character no-undo .
  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .

do
on error undo, return error return-value
:
  assign
    p-protein = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return . /* --->>>--- */
  end.
  assign
    p-protein = v-protein
  .
end.

end procedure. /* proc-get-protein */

/*======================================================================================================================*/
procedure nutro_proc-get-calories :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-calories      as decimal   no-undo .

  define buffer buf_goods    for ub.goods .

  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .

do
on error undo, return error return-value
:
  assign
    p-calories = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return . /* --->>>--- */
  end.
  assign
    p-calories = v-calories
  .

end.

end procedure. /* proc-get-calories */

/*======================================================================================================================*/
procedure nutro_get-nutrition-info :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-calories      as decimal   no-undo .
  define output parameter p-protein       as decimal   no-undo .
  define output parameter p-carbohydrate  as decimal   no-undo .
  define output parameter p-fat           as decimal   no-undo .

  define buffer buf_goods    for ub.goods .

  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  define variable v-attr-code     as character no-undo .
  define variable v-exist         as logical   no-undo .
  define variable v-is-global     as logical   no-undo .
  define variable v-nutro-value   as decimal   no-undo .

  define buffer buf_fbr-gds-obj  for ub.fbr-gds-obj.
  define buffer buf_recipe       for ub.recipe.
do
on error undo, return error return-value
:
&scop get-glob-attr assign ~
                      v-nutro-value = ? ~
                    . ~
                    run gds-attr-exist in this-procedure ( input  buf_goods.gds-code ~
                                                         , input  v-attr-code ~
                                                         , output v-exist ~
                                                         ) no-error . ~
                    if error-status :error = yes or  ~
                       v-exist = no ~
                    then do: ~
                      assign ~
                        v-nutro-value = ? ~
                      . ~
                    end. ~
                    else do: ~
                      run gds-attr-value in this-procedure ( input  buf_goods.gds-code ~
                                                          , input  v-attr-code ~
                                                          , output v-attr-value ~
                                                          , output v-attr-type ~
                                                          ) no-error . ~
                      if error-status :error ~
                      then do: ~
                        assign ~
                          v-nutro-value = ? ~
                        . ~
                      end. ~
                      assign ~
                        v-nutro-value = decimal( v-attr-value ) ~
                      no-error . ~
                      if error-status :error = yes ~
                      then do: ~
                        assign ~
                          v-nutro-value = ? ~
                        . ~
                      end. ~
                    end.

&scop get-obj-attr assign ~
                     v-nutro-value = ? ~
                   . ~
                   run gdsoattr-exist in this-procedure ( input buf_goods.gds-code ~
                                                        , input p-obj-type ~
                                                        , input p-obj-code ~
                                                        , input v-attr-code ~
                                                        , output v-exist ~
                                                        ) no-error . ~
                   if error-status :error = yes or ~
                      v-exist = no ~
                   then do: ~
                    assign ~
                      v-nutro-value = ? ~
                    . ~
                   end. ~
                   else do: ~
                    run gdsoattr-value in this-procedure ( input  v-attr-code ~
                                                          , input  buf_goods.gds-code ~
                                                          , input  p-obj-type ~
                                                          , input  p-obj-code ~
                                                          , output v-attr-value ~
                                                          , output v-attr-type ~
                                                          ) no-error . ~
                    if error-status :error = yes ~
                    then do: ~
                      assign ~
                        v-nutro-value = ? ~
                      . ~
                    end. ~
                    assign ~
                      v-nutro-value = decimal(v-attr-value) ~
                    no-error . ~
                    if error-status :error = yes ~
                    then do: ~
                      assign ~
                        v-nutro-value = ? ~
                      . ~
                    end. ~
                   end.

  assign
    p-carbohydrate  = ?
    p-fat           = ?
    p-protein       = ?
    p-calories      = ?
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

  /*
    если товар из производства то определ€ем основной рецепт и по типу рецепта определ€ем из каких атрибутов брать ѕ»Ё÷,
    дл€ "простых" ингридиентов всегда берем глобальные атрибуты товара
  */

  assign
    v-is-global = yes
  .

  find first buf_fbr-gds-obj no-lock
    where buf_fbr-gds-obj.obj-type = p-obj-type
      and buf_fbr-gds-obj.obj-code = p-obj-code
      and buf_fbr-gds-obj.gds-code = buf_goods.gds-code
  no-error .
  if available buf_fbr-gds-obj
  then do:
    if  buf_fbr-gds-obj.is-semi-finished or
        buf_fbr-gds-obj.is-menu
    then do:
      assign
        v-is-global = no
      .
      find first buf_recipe no-lock
        where buf_recipe.recipe-code = buf_fbr-gds-obj.default-recipe-code
      no-error .
      if available buf_recipe
      then do:
        assign
          v-is-global = ( buf_recipe.host-code = 0    ) and
                        ( buf_recipe.obj-type  = "":U ) and
                        ( buf_recipe.obj-code  = 0    )
        .
      end.
    end.
  end.

  if v-is-global = yes
  then do:
    assign
      v-attr-code = {&attr-calories}
    .
    {&get-glob-attr}
    assign
      p-calories  = v-nutro-value
      v-attr-code = {&attr-carbohydrate}
    .
    {&get-glob-attr}

    assign
      p-carbohydrate  = v-nutro-value
      v-attr-code     = {&attr-fat}
    .
    {&get-glob-attr}
    assign
      p-fat       = v-nutro-value
      v-attr-code = {&attr-protein}
    .
    {&get-glob-attr}
    assign
      p-protein = v-nutro-value
    .
  end. /* if v-is-global = yes */
  else do:
    assign
      v-attr-code = {&attr-calories-o}
    .
    {&get-obj-attr}
    assign
      p-calories  = v-nutro-value
      v-attr-code = {&attr-carbohydrate-o}
    .
    {&get-obj-attr}

    assign
      p-carbohydrate  = v-nutro-value
      v-attr-code     = {&attr-fat-o}
    .
    {&get-obj-attr}
    assign
      p-fat       = v-nutro-value
      v-attr-code = {&attr-protein-o}
    .
    {&get-obj-attr}
    assign
      p-protein = v-nutro-value
    .
  end.

end.

end procedure. /* nutro_get-nutrition-info */
/* $Workfile$ e n d */