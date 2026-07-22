/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

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
    when "c-price-list" then do:
      create locb-c-price-list.
      { nws/impl-nws.i "c-price-list" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории переоценки."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

for each buf_c-price-list where buf_c-price-list.doc-num = wt-c-price-doc.doc-num and
                              buf_c-price-list.chip-num = wt-c-price-doc.chip-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-price-list.
end.
for each locb-c-price-list where locb-c-price-list.doc-num = wt-c-price-doc.doc-num and
                               locb-c-price-list.chip-num = wt-c-price-doc.chip-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-price-list.
  buffer-copy locb-c-price-list to buf_c-price-list.
end.

if not available tb-c-price-doc then do:
  create tb-c-price-doc.
end.
buffer-copy wt-c-price-doc to tb-c-price-doc.

/* ---------------------------- почистим за собой -------------------------------- */
for each locb-c-price-list
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-price-list.
end.

/* $Workfile$ e n d */