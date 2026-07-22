/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбор удалённой строки документа производства в новостях

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
    when "c-fbr-line" then do:
      create locb-c-fbr-line.
      { nws/impl-nws.i "c-fbr-line" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

for each buf_c-fbr-line where buf_c-fbr-line.doc-code = wt-c-fbr-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fbr-line.
end.
for each locb-c-fbr-line where locb-c-fbr-line.doc-code = wt-c-fbr-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fbr-line.
  buffer-copy locb-c-fbr-line to buf_c-fbr-line.
end.

if not available tb-c-fbr-doc then do:
  create tb-c-fbr-doc.
end.
buffer-copy wt-c-fbr-doc to tb-c-fbr-doc.

/* ---------------------------- почистим за собой -------------------------------- */
for each locb-c-fbr-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fbr-line.
end.

/* $Workfile$ e n d */
