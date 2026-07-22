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
    when "c-fin-ob-tax" then do:
      create locb-c-fin-ob-tax.
      { nws/impl-nws.i "c-fin-ob-tax" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- c-fin-ob-tax ---------------------------------------------- */
for each buf_c-fin-ob-tax where buf_c-fin-ob-tax.doc-code  = wt-c-fin-ob.doc-code and
                                buf_c-fin-ob-tax.host-code = wt-c-fin-ob.host-code and
                                buf_c-fin-ob-tax.chip-num  = wt-c-fin-ob.chip-num

on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fin-ob-tax.
end.
for each locb-c-fin-ob-tax where locb-c-fin-ob-tax.doc-code = wt-c-fin-ob.doc-code   and
                                 locb-c-fin-ob-tax.host-code = wt-c-fin-ob.host-code and
                                 locb-c-fin-ob-tax.chip-num  = wt-c-fin-ob.chip-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fin-ob-tax.
  buffer-copy locb-c-fin-ob-tax to buf_c-fin-ob-tax.
end.
/* ------------------------------- c-fin-ob ---------------------------------------------- */
if not available tb-c-fin-ob then do:
  create tb-c-fin-ob.
end.

/* обновляем документ */
buffer-copy wt-c-fin-ob to tb-c-fin-ob.

/* -------------------- почистим за собой ------------------------ */
for each locb-c-fin-ob-tax
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fin-ob-tax.
end.

/* $Workfile$ */