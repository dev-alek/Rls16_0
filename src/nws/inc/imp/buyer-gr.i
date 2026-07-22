/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Группы покупателей

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
    when "c-buyer-group" then do:
      create locb-c-buyer-group.
      { nws/impl-nws.i "c-buyer-group" "locb-" }
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


/* ------------------------------- c-buyer-group ---------------------------------------------- */
for each buf_c-buyer-group where buf_c-buyer-group.bgr-id = wt-buyer-group.bgr-id
                             and buf_c-buyer-group.bgr-db-num = wt-buyer-group.bgr-db-num
on error  undo, return error
:
  delete buf_c-buyer-group.
end.

for each locb-c-buyer-group where locb-c-buyer-group.bgr-id     = wt-buyer-group.bgr-id
                              and locb-c-buyer-group.bgr-db-num = wt-buyer-group.bgr-db-num
  no-lock
on error  undo, return error
:
  create buf_c-buyer-group.
  buffer-copy  locb-c-buyer-group to buf_c-buyer-group.
end.

/* ------------------------------- buyer-group ---------------------------------------------- */
if not available tb-buyer-group then do:
  create tb-buyer-group.
end.
buffer-copy wt-buyer-group to tb-buyer-group.

/*------------------------- почиcтим за cобой ----------------------------------------------- */

for each locb-c-buyer-group
on error  undo, return error
:
  delete locb-c-buyer-group.
end.
/* $Workfile$ e n d */