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
    when "fin-ob-tax-before" then do:
      create locb-fin-ob-tax-before.
      { nws/impl-nws.i "fin-ob-tax-before" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- fin-ob-tax-before ---------------------------------------------- */
for each buf_fin-ob-tax-before where buf_fin-ob-tax-before.before-code = wt-fin-ob-before.before-code and
                              buf_fin-ob-tax-before.host-code = wt-fin-ob-before.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-ob-tax-before.
end.
for each locb-fin-ob-tax-before where locb-fin-ob-tax-before.before-code = wt-fin-ob-before.before-code and
                               locb-fin-ob-tax-before.host-code = wt-fin-ob-before.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-ob-tax-before.
  buffer-copy locb-fin-ob-tax-before to buf_fin-ob-tax-before.
end.


/* ------------------------------- fin-ob-before ---------------------------------------------- */
if not available tb-fin-ob-before then do:
  create tb-fin-ob-before.
end.

/* обновляем документ */
buffer-copy wt-fin-ob-before to tb-fin-ob-before.

/* -------------------- почистим за собой ------------------------ */
for each locb-fin-ob-tax-before
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-tax-before.
end.
/* $Workfile$ */