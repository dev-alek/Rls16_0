/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием документов icnt-doc

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/23/07
Author: Dmitry Ukhanov
Creation date: 10/23/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

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
    when "icnt-line" then do:
      create locb-icnt-line.
      { nws/impl-nws.i "icnt-line" "locb-" }
    end.
    when "doc-attr" then do:
      create locbi-doc-attr.
      { nws/impl-nws.i "doc-attr" "locbi-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе документов инв. счетчиков ТРК."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

for each buf_icnt-line where buf_icnt-line.doc-code = wt-icnt-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_icnt-line.
end.
for each locb-icnt-line where locb-icnt-line.doc-code = wt-icnt-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_icnt-line.
  buffer-copy locb-icnt-line to buf_icnt-line.
end.
for each buf_doc-attr where buf_doc-attr.doc-code = wt-icnt-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-attr.
end.
for each locbi-doc-attr where locbi-doc-attr.doc-code = wt-icnt-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-attr.
  buffer-copy locbi-doc-attr to buf_doc-attr.
end.
if not available tb-icnt-doc then do:
  create tb-icnt-doc.
end.


/* сохраняем историю изменения документа */
define variable v-old-icnt-doc-status as character no-undo .
define variable v-new-icnt-doc-status as character no-undo .

if tb-icnt-doc.status_ = ""
or tb-icnt-doc.status_ = ?
then do:
  assign
    v-old-icnt-doc-status = ""
  .
end.
else do:
  assign
    v-old-icnt-doc-status = tb-icnt-doc.status_ + string(tb-icnt-doc.flag_, '+/-':u)
  .
end.

assign
  v-new-icnt-doc-status = wt-icnt-doc.status_ + string(wt-icnt-doc.flag_, '+/-':u)
.

run trg/nwsdochs.p
  (input g#db-num                   /* p-db-num       */
  ,input {&nwsdochs_action_update}  /* p-action-type  */
  ,input wt-icnt-doc.doc-code       /* p-doc-code     */
  ,input wt-icnt-doc.obj-type       /* p-obj-type     */
  ,input wt-icnt-doc.obj-code       /* p-obj-code     */
  ,input {&table_icnt-doc}          /* p-doc-type     */
  ,input wt-icnt-doc.ext-doc-type   /* p-ext-doc-type */
  ,input wt-icnt-doc.fact-date      /* p-fact-date    */
  ,input wt-icnt-doc.state-mh-cnt   /* p-fact-qnty    */
  ,input 0                          /* p-fact-base    */
  ,input 0                          /* p-fact-rubl    */
  ,input 0                          /* p-num-line     */
  ,input v-old-icnt-doc-status      /* p-old-status   */
  ,input v-new-icnt-doc-status      /* p-new-status   */
  ,input g#news-source-db           /* p-pck-db-num   */
  ,input p-pck-num                  /* p-pck-pack-num */
  ,input wt-icnt-doc.user-db-num    /* p-user-db-num  */
  ,input wt-icnt-doc.user-name      /* p-user-name    */
  ,input wt-icnt-doc.sys-date       /* p-sys-date     */
  ,input wt-icnt-doc.sys-time       /* p-sys-time     */
  ,input wt-icnt-doc.sys-time-int   /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.

/* обновляем документ */
buffer-copy wt-icnt-doc to tb-icnt-doc.

/* -------------------- почистим за собой ------------------------ */
for each locb-icnt-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-icnt-line.
end.
for each locbi-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbi-doc-attr.
end.
/* $Workfile$ e n d */