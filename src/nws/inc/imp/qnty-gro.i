/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Колличеcтвенные группы

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
    when "qnty-in-qnty-group" then do:
      create locb-qnty-in-qnty-group.
      { nws/impl-nws.i "qnty-in-qnty-group" "locb-" }
    end.
    when "c-qnty-group" then do:
      create locb-c-qnty-group.
      { nws/impl-nws.i "c-qnty-group" "locb-" }
    end.
    when "c-qnty-in-qnty-group" then do:
      create locb-c-qnty-in-qnty-group.
      { nws/impl-nws.i "c-qnty-in-qnty-group" "locb-" }
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


/* ------------------------------- c-qnty-group ---------------------------------------------- */
for each buf_c-qnty-group where buf_c-qnty-group.qgr-id = wt-qnty-group.qgr-id
                            and buf_c-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
on error  undo, return error
:
  delete buf_c-qnty-group.
end.

for each locb-c-qnty-group where locb-c-qnty-group.qgr-id     = wt-qnty-group.qgr-id
                             and locb-c-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
  no-lock
on error  undo, return error
:
  create buf_c-qnty-group.
  buffer-copy  locb-c-qnty-group to buf_c-qnty-group.
end.


/* ------------------------------- qnty-in-qnty-group ---------------------------------------------- */
for each buf_qnty-in-qnty-group where buf_qnty-in-qnty-group.qgr-id     = wt-qnty-group.qgr-id
                                  and buf_qnty-in-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
on error  undo, return error
:
  delete buf_qnty-in-qnty-group.
end.

for each locb-qnty-in-qnty-group where locb-qnty-in-qnty-group.qgr-id     = wt-qnty-group.qgr-id
                                    and locb-qnty-in-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
no-lock
on error  undo, return error
:
  create buf_qnty-in-qnty-group.
  buffer-copy locb-qnty-in-qnty-group to buf_qnty-in-qnty-group.
end.
/* ------------------------------- c-qnty-in-qnty-group ---------------------------------------------- */
for each buf_c-qnty-in-qnty-group where buf_c-qnty-in-qnty-group.qgr-id     = wt-qnty-group.qgr-id
                                  and buf_c-qnty-in-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
on error  undo, return error
:
  delete buf_c-qnty-in-qnty-group.
end.

for each locb-c-qnty-in-qnty-group where locb-c-qnty-in-qnty-group.qgr-id = wt-qnty-group.qgr-id
                                    and locb-c-qnty-in-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
no-lock
on error  undo, return error
:
  create buf_c-qnty-in-qnty-group.
  buffer-copy locb-c-qnty-in-qnty-group to buf_c-qnty-in-qnty-group.
end.

/* ------------------------------- qnty-group ---------------------------------------------- */
if not available tb-qnty-group then do:
  create tb-qnty-group.
end.
buffer-copy wt-qnty-group to tb-qnty-group.

/*------------------------- почиcтим за cобой ----------------------------------------------- */

for each locb-c-qnty-group
on error  undo, return error
:
  delete locb-c-qnty-group.
end.

for each locb-qnty-in-qnty-group
on error  undo, return error
:
  delete locb-qnty-in-qnty-group.
end.

for each locb-c-qnty-in-qnty-group
on error  undo, return error
:
  delete locb-c-qnty-in-qnty-group.
end.

/* $Workfile$ e n d */