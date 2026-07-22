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
    when "fin-ob-tax" then do:
      create locb-fin-ob-tax.
      { nws/impl-nws.i "fin-ob-tax" "locb-" }
    end.
    when "fin-ob-trn" then do:
      create locb-fin-ob-trn.
      { nws/impl-nws.i "fin-ob-trn" "locb-" }
    end.

    when "fin-gds-part" then do:
      create locb-fin-gds-part.
      { nws/impl-nws.i "fin-gds-part" "locb-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- fin-ob-tax ---------------------------------------------- */
for each buf_fin-ob-tax where buf_fin-ob-tax.doc-code = wt-fin-ob.doc-code and
                              buf_fin-ob-tax.host-code = wt-fin-ob.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-ob-tax.
end.
for each locb-fin-ob-tax where locb-fin-ob-tax.doc-code = wt-fin-ob.doc-code and
                               locb-fin-ob-tax.host-code = wt-fin-ob.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-ob-tax.
  buffer-copy locb-fin-ob-tax to buf_fin-ob-tax.
end.
/* ------------------------------- fin-ob-trn ---------------------------------------------- */
for each buf_fin-ob-trn where buf_fin-ob-trn.doc-code = wt-fin-ob.doc-code and
                              buf_fin-ob-trn.host-code = wt-fin-ob.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-ob-trn.
end.
for each locb-fin-ob-trn where locb-fin-ob-trn.doc-code = wt-fin-ob.doc-code and
                               locb-fin-ob-trn.host-code = wt-fin-ob.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-ob-trn.
  buffer-copy locb-fin-ob-trn to buf_fin-ob-trn.
end.
/* ------------------------------- fin-gds-part ---------------------------------------------- */
for each buf_fin-gds-part where buf_fin-gds-part.fin-ob-code = wt-fin-ob.doc-code and
                                buf_fin-gds-part.host-code = wt-fin-ob.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-gds-part.
end.
for each locb-fin-gds-part where locb-fin-gds-part.fin-ob-code = wt-fin-ob.doc-code and
                                 locb-fin-gds-part.host-code   = wt-fin-ob.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-gds-part.
  buffer-copy locb-fin-gds-part to buf_fin-gds-part.
end.


/* ------------------------------- fin-ob ---------------------------------------------- */
if not available tb-fin-ob then do:
  create tb-fin-ob.
end.

/* обновляем документ */
buffer-copy wt-fin-ob to tb-fin-ob.

/* -------------------- почистим за собой ------------------------ */
for each locb-fin-ob-tax
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-tax.
end.
for each locb-fin-ob-trn
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-trn.
end.
for each locb-fin-gds-part
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-gds-part.
end.


/* $Workfile$ */