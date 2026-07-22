/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбор справочника рецептов в новостях

Автор: Белоусов Илья Александрович
Дата создания: 10/23/07
Author: Ilia Belousov
Creation date: 10/23/07

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "recipe-gds" then do:
      create locb-recipe-gds.
      { nws/impl-nws.i "recipe-gds" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

if not available tb-recipe then do:
  create tb-recipe.
end.
/* обновляем справочник */
buffer-copy wt-recipe to tb-recipe.

for each buf_recipe-gds where buf_recipe-gds.recipe-code = wt-recipe.recipe-code
on error  undo, return error
:
  delete buf_recipe-gds.
end.
for each locb-recipe-gds where locb-recipe-gds.recipe-code = wt-recipe.recipe-code
                       no-lock
on error  undo, return error
:
  create buf_recipe-gds.
  buffer-copy locb-recipe-gds to buf_recipe-gds.
end.

/* ---------------------------- почистим за собой -------------------------------- */
for each locb-recipe-gds
on error  undo, return error
:
  delete locb-recipe-gds.
end.


/* $Workfile$ e n d */