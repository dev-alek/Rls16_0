/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/24/06
Author: Michael Kochetkov
Creation date: 03/24/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".

DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "c-schet-fact-line" then do:
      create locb-c-schet-fact-line.
      { nws/impl-nws.i "c-schet-fact-line" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- c-schet-fact-line ---------------------------------------------- */
for each buf_c-schet-fact-line where buf_c-schet-fact-line.doc-code = wt-c-schet-fact-doc.doc-code and
                                     buf_c-schet-fact-line.db-num = wt-c-schet-fact-doc.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-schet-fact-line.
end.
for each locb-c-schet-fact-line where locb-c-schet-fact-line.doc-code = wt-c-schet-fact-doc.doc-code and
                                    locb-c-schet-fact-line.db-num = wt-c-schet-fact-doc.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-schet-fact-line.
  buffer-copy locb-c-schet-fact-line to buf_c-schet-fact-line.
end.

/* ------------------------------- contract ---------------------------------------------- */
if not available tb-c-schet-fact-doc then do:
  create tb-c-schet-fact-doc.
end.

/* обновляем документ */
buffer-copy wt-c-schet-fact-doc to tb-c-schet-fact-doc.

/* -------------------- почистим за собой ------------------------ */
for each locb-c-schet-fact-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-schet-fact-line.
end.


/* $Workfile$ */