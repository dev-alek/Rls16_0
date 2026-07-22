/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Глобальные настройки МПЛ

Автор: Чернова Светлана Александровна
Дата создания: 06/08/06
Author: Svetlana Chernova
Creation date: 06/08/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "global-state-attr" then do:
      create locb-global-state-attr.
      { nws/impl-nws.i "global-state-attr" "locb-" }
    end.
    when "c-global-state" then do:
      create locb-c-global-state.
      { nws/impl-nws.i "c-global-state" "locb-" }
    end.
    when "c-global-state-attr" then do:
      create locb-c-global-state-attr.
      { nws/impl-nws.i "c-global-state-attr" "locb-" }
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- c-global-state ---------------------------------------------- */
for each buf_c-global-state where buf_c-global-state.gls-id = wt-global-state.gls-id
on error  undo, return error
:
  delete buf_c-global-state.
end.

for each locb-c-global-state where locb-c-global-state.gls-id = wt-global-state.gls-id   no-lock
on error  undo, return error
:
  create buf_c-global-state.
  buffer-copy  locb-c-global-state to buf_c-global-state.
end.


/* ------------------------------- global-state-attr ---------------------------------------------- */
for each buf_global-state-attr where buf_global-state-attr.gls-id = wt-global-state.gls-id
on error  undo, return error
:
  delete buf_global-state-attr.
end.

for each locb-global-state-attr where locb-global-state-attr.gls-id = wt-global-state.gls-id
no-lock
on error  undo, return error
:
  create buf_global-state-attr.
  buffer-copy locb-global-state-attr to buf_global-state-attr.
end.
/* ------------------------------- c-global-state-attr ---------------------------------------------- */
for each buf_c-global-state-attr where buf_c-global-state-attr.gls-id = wt-global-state.gls-id
on error  undo, return error
:
  delete buf_c-global-state-attr.
end.

for each locb-c-global-state-attr where locb-c-global-state-attr.gls-id = wt-global-state.gls-id
no-lock
on error  undo, return error
:
  create buf_c-global-state-attr.
  buffer-copy locb-c-global-state-attr to buf_c-global-state-attr.
end.

/* ------------------------------- global-state ---------------------------------------------- */
if not available tb-global-state then do:
  create tb-global-state.
end.
buffer-copy wt-global-state to tb-global-state.

/*------------------------- почиcтим за cобой ----------------------------------------------- */

for each locb-c-global-state
on error  undo, return error
:
  delete locb-c-global-state.
end.

for each locb-global-state-attr
on error  undo, return error
:
  delete locb-global-state-attr.
end.

for each locb-c-global-state-attr
on error  undo, return error
:
  delete locb-c-global-state-attr.
end.
/* $Workfile$ e n d */