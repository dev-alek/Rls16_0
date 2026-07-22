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
    when "schet-fact-line" then do:
      create locb-schet-fact-line.
      { nws/impl-nws.i "schet-fact-line" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- schet-fact-line ---------------------------------------------- */
for each buf_schet-fact-line where buf_schet-fact-line.doc-code = wt-schet-fact-doc.doc-code and
                                   buf_schet-fact-line.db-num = wt-schet-fact-doc.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_schet-fact-line.
end.
for each locb-schet-fact-line where locb-schet-fact-line.doc-code = wt-schet-fact-doc.doc-code and
                                    locb-schet-fact-line.db-num = wt-schet-fact-doc.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_schet-fact-line.
  buffer-copy locb-schet-fact-line to buf_schet-fact-line.
end.

/* ------------------------------- contract ---------------------------------------------- */
if not available tb-schet-fact-doc then do:
  create tb-schet-fact-doc.
end.

/* обновляем документ */
buffer-copy wt-schet-fact-doc to tb-schet-fact-doc.

/* -------------------- почистим за собой ------------------------ */
for each locb-schet-fact-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-schet-fact-line.
end.


/* $Workfile$ */