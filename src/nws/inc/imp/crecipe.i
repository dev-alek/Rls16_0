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
    when "c-recipe-gds" then do:
      create locb-c-recipe-gds.
      { nws/impl-nws.i "c-recipe-gds" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

if not available tb-c-recipe then do:
  create tb-c-recipe.
end.
/* обновляем справочник */
buffer-copy wt-c-recipe to tb-c-recipe.

for each buf_c-recipe-gds where buf_c-recipe-gds.recipe-code = wt-c-recipe.recipe-code
on error  undo, return error
:
  delete buf_c-recipe-gds.
end.
for each locb-c-recipe-gds where locb-c-recipe-gds.recipe-code = wt-c-recipe.recipe-code
                       no-lock
on error  undo, return error
:
  create buf_c-recipe-gds.
  buffer-copy locb-c-recipe-gds to buf_c-recipe-gds.
end.

/* ---------------------------- почистим за собой -------------------------------- */
for each locb-c-recipe-gds
on error  undo, return error
:
  delete locb-c-recipe-gds.
end.


/* $Workfile$ e n d */