/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Приема в новостях платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

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
    when "fin-doc-tax" then do:
      create locb-fin-doc-tax.
      { nws/impl-nws.i "fin-doc-tax" "locb-" }
    end.
    when "fin-doc-attr" then do:
      create locb-fin-doc-attr.
      { nws/impl-nws.i "fin-doc-attr" "locb-" }
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/* ------------------------------- fin-doc-tax ---------------------------------------------- */
for each buf_fin-doc-tax where buf_fin-doc-tax.fin-doc-code = wt-fin-doc.fin-doc-code and
                              buf_fin-doc-tax.host-code = wt-fin-doc.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-doc-tax.
end.
for each locb-fin-doc-tax where locb-fin-doc-tax.fin-doc-code = wt-fin-doc.fin-doc-code and
                               locb-fin-doc-tax.host-code = wt-fin-doc.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-doc-tax.
  buffer-copy locb-fin-doc-tax to buf_fin-doc-tax.
end.

/* ------------------------------- fin-doc-attr ---------------------------------------------- */
for each buf_fin-doc-attr where buf_fin-doc-attr.fin-doc-code = wt-fin-doc.fin-doc-code and
                              buf_fin-doc-attr.host-code = wt-fin-doc.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-doc-attr.
end.
for each locb-fin-doc-attr where locb-fin-doc-attr.fin-doc-code = wt-fin-doc.fin-doc-code and
                               locb-fin-doc-attr.host-code = wt-fin-doc.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-doc-attr.
  buffer-copy locb-fin-doc-attr to buf_fin-doc-attr.
end.



/* ------------------------------- fin-doc ---------------------------------------------- */
if not available tb-fin-doc then do:
  create tb-fin-doc.
end.

/* обновляем документ */
buffer-copy wt-fin-doc to tb-fin-doc.

/* -------------------- почистим за собой ------------------------ */
for each locb-fin-doc-tax
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-doc-tax.
end.

for each locb-fin-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-doc-attr.
end.

if tb-fin-doc.status_ = {&fin-fact} then do:
  /*убедимся что мы либо на БД фирмы, либо на объекте*/
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = tb-fin-doc.host-code.
  if not (tb-fin-doc.obj-type = '' and tb-fin-doc.obj-code = 0) then do:
    { gbl/objdbnum.i tb-fin-doc.obj-type tb-fin-doc.obj-code v-obj-db-num }
  end.
  if g#db-num = v-obj-db-num
  or g#db-num = buf_sysconf.firm-db-num then do:
    { str/taskclcd.i tb-fin-doc.host-code tb-fin-doc.fin-doc-code "'all':U" g#userid "'close':u" no-error }
    if error-status:error then do:
      undo, return error substitute("Ошибка при расчете архивов по платежу: &1 &2", return-value, error-status:get-message(1)).
    end.
  end.
end.


/* $Workfile$ */