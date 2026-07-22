/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Покупатели в Группе покупателей

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
    when "c-buyer-in-buyer-group" then do:
      create locb-c-buyer-in-buyer-group.
      { nws/impl-nws.i "c-buyer-in-buyer-group" "locb-" }
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- c-buyer-in-buyer-group ---------------------------------------------- */
for each buf_c-buyer-in-buyer-group where buf_c-buyer-in-buyer-group.bgr-id     = wt-buyer-in-buyer-group.bgr-id
                                      and buf_c-buyer-in-buyer-group.bgr-db-num = wt-buyer-in-buyer-group.bgr-db-num
                                      and buf_c-buyer-in-buyer-group.bbg-obj-type = wt-buyer-in-buyer-group.bbg-obj-type
                                      and buf_c-buyer-in-buyer-group.bbg-obj-code = wt-buyer-in-buyer-group.bbg-obj-code
on error  undo, return error
:
  delete buf_c-buyer-in-buyer-group.
end.

for each locb-c-buyer-in-buyer-group where locb-c-buyer-in-buyer-group.bgr-id       = wt-buyer-in-buyer-group.bgr-id
                                       and locb-c-buyer-in-buyer-group.bgr-db-num   = wt-buyer-in-buyer-group.bgr-db-num
                                       and locb-c-buyer-in-buyer-group.bbg-obj-type = wt-buyer-in-buyer-group.bbg-obj-type
                                       and locb-c-buyer-in-buyer-group.bbg-obj-code = wt-buyer-in-buyer-group.bbg-obj-code
no-lock
on error  undo, return error
:
  create buf_c-buyer-in-buyer-group.
  buffer-copy locb-c-buyer-in-buyer-group to buf_c-buyer-in-buyer-group.
end.

/* ------------------------------- buyer-in-buyer-group ---------------------------------------------- */
if not available tb-buyer-in-buyer-group then do:
  create tb-buyer-in-buyer-group.
end.
buffer-copy wt-buyer-in-buyer-group to tb-buyer-in-buyer-group.

/*------------------------- почиcтим за cобой ----------------------------------------------- */

for each locb-c-buyer-in-buyer-group
on error  undo, return error
:
  delete locb-c-buyer-in-buyer-group.
end.

/* $Workfile$ e n d */