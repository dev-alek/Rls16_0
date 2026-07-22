/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием истории фин документов в новостях

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
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
    when "c-fin-doc-tax" then do:
      create locb-c-fin-doc-tax.
      { nws/impl-nws.i "c-fin-doc-tax" "locb-" }
    end.
    when "c-fin-doc-attr" then do:
      create locb-c-fin-doc-attr.
      { nws/impl-nws.i "c-fin-doc-attr" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- c-fin-doc-tax ---------------------------------------------- */
for each buf_c-fin-doc-tax where buf_c-fin-doc-tax.fin-doc-code = wt-c-fin-doc.fin-doc-code and
                              buf_c-fin-doc-tax.host-code = wt-c-fin-doc.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fin-doc-tax.
end.
for each locb-c-fin-doc-tax where locb-c-fin-doc-tax.fin-doc-code = wt-c-fin-doc.fin-doc-code and
                               locb-c-fin-doc-tax.host-code = wt-c-fin-doc.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fin-doc-tax.
  buffer-copy locb-c-fin-doc-tax to buf_c-fin-doc-tax.
end.

/* ------------------------------- c-fin-doc-attr ---------------------------------------------- */
for each buf_c-fin-doc-attr where buf_c-fin-doc-attr.fin-doc-code = wt-c-fin-doc.fin-doc-code and
                              buf_c-fin-doc-attr.host-code = wt-c-fin-doc.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fin-doc-attr.
end.
for each locb-c-fin-doc-attr where locb-c-fin-doc-attr.fin-doc-code = wt-c-fin-doc.fin-doc-code and
                               locb-c-fin-doc-attr.host-code = wt-c-fin-doc.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fin-doc-attr.
  buffer-copy locb-c-fin-doc-attr to buf_c-fin-doc-attr.
end.



/* ------------------------------- c-fin-doc ---------------------------------------------- */
if not available tb-c-fin-doc then do:
  create tb-c-fin-doc.
end.

/* обновляем документ */
buffer-copy wt-c-fin-doc to tb-c-fin-doc.

/* -------------------- почистим за собой ------------------------ */
for each locb-c-fin-doc-tax
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fin-doc-tax.
end.

for each locb-c-fin-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fin-doc-attr.
end.


/* $Workfile$ */