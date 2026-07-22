/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Группы  оборотов

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
    when "tnv-in-turnover-group" then do:
      create locb-tnv-in-turnover-group.
      { nws/impl-nws.i "tnv-in-turnover-group" "locb-" }
    end.
    when "c-turnover-group" then do:
      create locb-c-turnover-group.
      { nws/impl-nws.i "c-turnover-group" "locb-" }
    end.
    when "c-tnv-in-turnover-group" then do:
      create locb-c-tnv-in-turnover-group.
      { nws/impl-nws.i "c-tnv-in-turnover-group" "locb-" }
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


/* ------------------------------- c-turnover-group ---------------------------------------------- */
for each buf_c-turnover-group where buf_c-turnover-group.tog-id = wt-turnover-group.tog-id
                            and buf_c-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
on error  undo, return error
:
  delete buf_c-turnover-group.
end.

for each locb-c-turnover-group where locb-c-turnover-group.tog-id     = wt-turnover-group.tog-id
                             and locb-c-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
  no-lock
on error  undo, return error
:
  create buf_c-turnover-group.
  buffer-copy  locb-c-turnover-group to buf_c-turnover-group.
end.


/* ------------------------------- tnv-in-turnover-group ---------------------------------------------- */
for each buf_tnv-in-turnover-group where buf_tnv-in-turnover-group.tog-id     = wt-turnover-group.tog-id
                                  and buf_tnv-in-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
on error  undo, return error
:
  delete buf_tnv-in-turnover-group.
end.

for each locb-tnv-in-turnover-group where locb-tnv-in-turnover-group.tog-id     = wt-turnover-group.tog-id
                                    and locb-tnv-in-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
no-lock
on error  undo, return error
:
  create buf_tnv-in-turnover-group.
  buffer-copy locb-tnv-in-turnover-group to buf_tnv-in-turnover-group.
end.
/* ------------------------------- c-tnv-in-turnover-group ---------------------------------------------- */
for each buf_c-tnv-in-turnover-group where buf_c-tnv-in-turnover-group.tog-id     = wt-turnover-group.tog-id
                                  and buf_c-tnv-in-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
on error  undo, return error
:
  delete buf_c-tnv-in-turnover-group.
end.

for each locb-c-tnv-in-turnover-group where locb-c-tnv-in-turnover-group.tog-id = wt-turnover-group.tog-id
                                    and locb-c-tnv-in-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
no-lock
on error  undo, return error
:
  create buf_c-tnv-in-turnover-group.
  buffer-copy locb-c-tnv-in-turnover-group to buf_c-tnv-in-turnover-group.
end.

/* ------------------------------- turnover-group ---------------------------------------------- */
if not available tb-turnover-group then do:
  create tb-turnover-group.
end.
buffer-copy wt-turnover-group to tb-turnover-group.

/*------------------------- почиcтим за cобой ----------------------------------------------- */

for each locb-c-turnover-group
on error  undo, return error
:
  delete locb-c-turnover-group.
end.

for each locb-tnv-in-turnover-group
on error  undo, return error
:
  delete locb-tnv-in-turnover-group.
end.

for each locb-c-tnv-in-turnover-group
on error  undo, return error
:
  delete locb-c-tnv-in-turnover-group.
end.

/* $Workfile$ e n d */