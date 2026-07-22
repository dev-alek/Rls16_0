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
    when "factur-connect-line" then do:
      create locb-factur-connect-line.
      { nws/impl-nws.i "factur-connect-line" "locb-" }
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
for each buf_factur-connect-line where buf_factur-connect-line.connect-code = wt-factur-connect.connect-code and
                                       buf_factur-connect-line.db-num    = wt-factur-connect.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_factur-connect-line.
end.
for each locb-factur-connect-line where locb-factur-connect-line.connect-code = wt-factur-connect.connect-code and
                                        locb-factur-connect-line.db-num    = wt-factur-connect.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_factur-connect-line.
  buffer-copy locb-factur-connect-line to buf_factur-connect-line.
end.

/* ------------------------------- contract ---------------------------------------------- */
if not available tb-factur-connect then do:
  create tb-factur-connect.
end.

/* обновляем документ */
buffer-copy wt-factur-connect to tb-factur-connect.

/* -------------------- почистим за собой ------------------------ */
for each locb-factur-connect-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-factur-connect-line.
end.


/* $Workfile$ */