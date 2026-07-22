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
    when "c-ord-line" then do:
      create locb-c-ord-line.
      { nws/impl-nws.i "c-ord-line" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории заказа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

for each buf_c-ord-line where buf_c-ord-line.doc-code = wt-c-ord-doc.doc-code and
                              buf_c-ord-line.chip-num = wt-c-ord-doc.chip-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-ord-line.
end.
for each locb-c-ord-line where locb-c-ord-line.doc-code = wt-c-ord-doc.doc-code and
                               locb-c-ord-line.chip-num = wt-c-ord-doc.chip-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-ord-line.
  buffer-copy locb-c-ord-line to buf_c-ord-line.
end.

if not available tb-c-ord-doc then do:
  create tb-c-ord-doc.
end.
buffer-copy wt-c-ord-doc to tb-c-ord-doc.

/* ---------------------------- почистим за собой -------------------------------- */
for each locb-c-ord-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-ord-line.
end.

/* $Workfile$ e n d */