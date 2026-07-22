/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Суммовые группы

Автор: Чернова Светлана Александровна
Дата создания: 06/09/06
Author: Svetlana Chernova
Creation date: 06/09/06

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
    when "sum-in-sum-group" then do:
      create locb-sum-in-sum-group.
      { nws/impl-nws.i "sum-in-sum-group" "locb-" }
    end.
    when "c-sum-group" then do:
      create locb-c-sum-group.
      { nws/impl-nws.i "c-sum-group" "locb-" }
    end.
    when "c-sum-in-sum-group" then do:
      create locb-c-sum-in-sum-group.
      { nws/impl-nws.i "c-sum-in-sum-group" "locb-" }
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- c-sum-group ---------------------------------------------- */
for each buf_c-sum-group where buf_c-sum-group.sgr-id = wt-sum-group.sgr-id
                           and buf_c-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
on error  undo, return error
:
  delete buf_c-sum-group.
end.

for each locb-c-sum-group where locb-c-sum-group.sgr-id     = wt-sum-group.sgr-id
                            and locb-c-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
  no-lock
on error  undo, return error
:
  create buf_c-sum-group.
  buffer-copy  locb-c-sum-group to buf_c-sum-group.
end.


/* ------------------------------- sum-in-sum-group ---------------------------------------------- */
for each buf_sum-in-sum-group where buf_sum-in-sum-group.sgr-id     = wt-sum-group.sgr-id
                                and buf_sum-in-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
on error  undo, return error
:
  delete buf_sum-in-sum-group.
end.

for each locb-sum-in-sum-group where locb-sum-in-sum-group.sgr-id     = wt-sum-group.sgr-id
                                  and locb-sum-in-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
no-lock
on error  undo, return error
:
  create buf_sum-in-sum-group.
  buffer-copy locb-sum-in-sum-group to buf_sum-in-sum-group.
end.
/* ------------------------------- c-sum-in-sum-group ---------------------------------------------- */
for each buf_c-sum-in-sum-group where buf_c-sum-in-sum-group.sgr-id     = wt-sum-group.sgr-id
                                  and buf_c-sum-in-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
on error  undo, return error
:
  delete buf_c-sum-in-sum-group.
end.

for each locb-c-sum-in-sum-group where locb-c-sum-in-sum-group.sgr-id = wt-sum-group.sgr-id
                                    and locb-c-sum-in-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
no-lock
on error  undo, return error
:
  create buf_c-sum-in-sum-group.
  buffer-copy locb-c-sum-in-sum-group to buf_c-sum-in-sum-group.
end.

/* ------------------------------- sum-group ---------------------------------------------- */
if not available tb-sum-group then do:
  create tb-sum-group.
end.
buffer-copy wt-sum-group to tb-sum-group.

/*------------------------- почиcтим за cобой ----------------------------------------------- */

for each locb-c-sum-group
on error  undo, return error
:
  delete locb-c-sum-group.
end.

for each locb-sum-in-sum-group
on error  undo, return error
:
  delete locb-sum-in-sum-group.
end.

for each locb-c-sum-in-sum-group
on error  undo, return error
:
  delete locb-c-sum-in-sum-group.
end.

/* $Workfile$ e n d */